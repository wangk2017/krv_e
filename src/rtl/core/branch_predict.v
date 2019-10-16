/*
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
  Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.      
*/

//==============================================================||
// File Name: 		branch_predict.v			||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		branch predict module			|| 
// History:   							||
//===============================================================

`include "core_defines.vh"

module branch_predict (
	input cpu_clk,						
	input cpu_rstn,				
	input [`ADDR_WIDTH - 1 : 0] next_pc,
	input [`ADDR_WIDTH - 1 : 0] pc,
	output predict_taken,
	output is_loop,
	output [`ADDR_WIDTH - 1 : 0] predict_target_pc,
	input [`ADDR_WIDTH - 1 : 0] branch_target_pc,
	input branch_ex,
	input jal_dec,
	input jalr_ex,
	input [`ADDR_WIDTH - 1 : 0] branch_pc_ex,
	input [`DATA_WIDTH - 1 : 0] src_data1_ex,
	input [`DATA_WIDTH - 1 : 0] src_data2_ex,
	input is_loop_ex,
	input branch_taken_ex
);



//parameters
parameter ENTRY_NUM = 256;
parameter PR_ADDR_WIDTH = $clog2(ENTRY_NUM);

//----------------------------------------------------------------------------//
//BHT - branch history table
//----------------------------------------------------------------------------//
wire [PR_ADDR_WIDTH - 1 : 0] bht_raddr = next_pc[PR_ADDR_WIDTH + 1 : 2];
wire [PR_ADDR_WIDTH - 1 : 0] bht_waddr = branch_pc_ex[PR_ADDR_WIDTH + 1 : 2];
wire [`ADDR_WIDTH - 1 : 0] bht_w_pc = branch_pc_ex;
wire bht_wen = branch_ex;

`ifdef ASIC
wire [`ADDR_WIDTH - 1 : 0] bht_r_pc;
sram_256x32 bht(
    .CLK	(cpu_clk),
    .RADDR	(bht_raddr),
    .WADDR	(bht_waddr),
    .WD		(bht_w_pc),
    .WEN	(bht_wen),
    .RD		(bht_r_pc)
);

`else
reg[`ADDR_WIDTH - 1 : 0] bht [255:0];
reg[`ADDR_WIDTH - 1 : 0] bht_r_pc;

always @ (posedge cpu_clk)
begin
	bht_r_pc <= bht[bht_raddr];
	if(bht_wen)
	begin
		bht[bht_waddr] <= bht_w_pc;
	end
end
`endif

wire hit = (pc == bht_r_pc);


//predict1 - basic predictor
wire [PR_ADDR_WIDTH - 1 : 0] predict1_raddr = next_pc[PR_ADDR_WIDTH + 1 : 2];
wire [PR_ADDR_WIDTH - 1 : 0] predict1_waddr = branch_pc_ex[PR_ADDR_WIDTH + 1 : 2];
wire predict1_wen = branch_ex;

wire[1:0] predict1_rd_data;

basic_predictor_2b #(.entry_num(ENTRY_NUM),.addr_width(PR_ADDR_WIDTH)) u_predict1 (
.cpu_clk		(cpu_clk),
.cpu_rstn		(cpu_rstn),
.predictor_raddr 	(predict1_raddr),
.predictor_waddr 	(predict1_waddr),
.predictor_wen	 	(predict1_wen),
.branch_taken_ex 	(branch_taken_ex),
.predictor_rd_data	(predict1_rd_data)
);

wire predict2_rd_data;
loop_predictor u_predict2(
.cpu_clk		(cpu_clk),
.cpu_rstn		(cpu_rstn),
.pc_ex			(branch_pc_ex),
.branch_ex		(branch_ex),
.jal_dec		(jal_dec),
.jalr_ex		(jalr_ex),
.pc			(pc),
.is_loop_ex		(is_loop_ex),
.src_data1_ex		(src_data1_ex),
.src_data2_ex		(src_data2_ex),
.is_loop		(is_loop),
.loop_predict_taken	(predict2_rd_data)
);



//predictor selector
wire predictor;
assign predictor = is_loop? predict2_rd_data : predict1_rd_data[1];

//assign predict_taken = 1'b0;
assign predict_taken = hit && predictor;

//BTT - branch target table

wire [PR_ADDR_WIDTH - 1 : 0] btt_raddr = next_pc[PR_ADDR_WIDTH + 1 : 2];
wire [PR_ADDR_WIDTH - 1 : 0] btt_waddr = branch_pc_ex[PR_ADDR_WIDTH + 1 : 2];
wire [`ADDR_WIDTH - 1 : 0] btt_w_pc = branch_target_pc;
wire btt_wen = branch_ex;

`ifdef ASIC
wire [`ADDR_WIDTH - 1 : 0] btt_r_pc;
sram_256x32 btt(
    .CLK	(cpu_clk),
    .RADDR	(btt_raddr),
    .WADDR	(btt_waddr),
    .WD		(btt_w_pc),
    .WEN	(btt_wen),
    .RD		(btt_r_pc)
);

`else
reg[`ADDR_WIDTH - 1 : 0] btt [255:0];
reg[`ADDR_WIDTH - 1 : 0] btt_r_pc;

always @ (posedge cpu_clk)
begin
	btt_r_pc <= btt[btt_raddr];
	if(btt_wen)
	begin
		btt[btt_waddr] <= btt_w_pc;
	end
end
`endif

assign predict_target_pc = btt_r_pc;


endmodule
