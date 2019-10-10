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
//global signals 
	input cpu_clk,						//cpu clock
	input cpu_rstn,						//cpu reset, active low
//interface with fetch
	input [`ADDR_WIDTH - 1 : 0] next_pc,
	input [`ADDR_WIDTH - 1 : 0] pc,
	output predict_taken,
	output [`ADDR_WIDTH - 1 : 0] predict_target_pc,
	input [`ADDR_WIDTH - 1 : 0] branch_target_pc,
//interface with alu
	input branch_ex,
	input [`ADDR_WIDTH - 1 : 0] branch_pc_ex,
	input branch_taken_ex
);

//BHT - branch history table
wire [7:0] bht_raddr = next_pc[9:2];
wire [7:0] bht_waddr = branch_pc_ex[9:2];
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


//predict1
wire [7:0] predict1_raddr = next_pc[9:2];
wire [7:0] predict1_waddr = branch_pc_ex[9:2];
wire predict1_wen = branch_ex;

reg[1:0] predict1[255:0];
reg[1:0] predict1_rd_data;

integer i;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		for(i=0; i<256; i=i+1)
		predict1[i] <= 2'b00;	
	end
	else
	begin
		predict1_rd_data <= predict1[predict1_raddr];	
		if(predict1_wen)
		begin
			case(predict1[predict1_waddr])
			2'b00: begin
				if(branch_taken_ex)
				predict1[predict1_waddr] <= 2'b01;
				else
				predict1[predict1_waddr] <= 2'b00;
			end
			2'b01: begin
				if(branch_taken_ex)
				predict1[predict1_waddr] <= 2'b10;
				else
				predict1[predict1_waddr] <= 2'b00;
			end
			2'b10: begin
				if(branch_taken_ex)
				predict1[predict1_waddr] <= 2'b11;
				else
				predict1[predict1_waddr] <= 2'b01;
			end
			2'b11: begin
				if(branch_taken_ex)
				predict1[predict1_waddr] <= 2'b11;
				else
				predict1[predict1_waddr] <= 2'b10;
			end
			endcase
		end
	end
end

//predictor selector
wire predictor;
assign predictor = predict1_rd_data[1];

assign predict_taken = hit && predictor;

//BTT - branch target table

wire [7:0] btt_raddr = next_pc[9:2];
wire [7:0] btt_waddr = branch_pc_ex[9:2];
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
