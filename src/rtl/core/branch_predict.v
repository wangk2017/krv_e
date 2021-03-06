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
	output predict0_taken,
	output predict1_taken,
	output predict3_taken,
	output is_loop,
	output [`ADDR_WIDTH - 1 : 0] predict_target_pc,
	input predict0_taken_ex,
	input predict1_taken_ex,
	input predict3_taken_ex,
	input [`ADDR_WIDTH - 1 : 0] branch_target_pc,
	input branch_ex,
	input jal_dec,
	input jalr_ex,
	input [`ADDR_WIDTH - 1 : 0] branch_pc_ex,
	input [`DATA_WIDTH - 1 : 0] src_data1_ex,
	input [`DATA_WIDTH - 1 : 0] src_data2_ex,
	input is_loop_dec,
	input is_loop_ex,
	input branch_taken_ex
);



//parameters
parameter ENTRY_NUM = 512;
parameter PR_ADDR_WIDTH = $clog2(ENTRY_NUM);

//----------------------------------------------------------------------------//
//BHT - branch history table
//----------------------------------------------------------------------------//
wire [PR_ADDR_WIDTH - 1 : 0] bht_raddr = next_pc[PR_ADDR_WIDTH + 1 : 2];
wire [PR_ADDR_WIDTH - 1 : 0] bht_waddr = branch_pc_ex[PR_ADDR_WIDTH + 1 : 2];
wire [`ADDR_WIDTH - 1 : 0] bht_w_pc = branch_pc_ex;
wire bht_wen = branch_ex;
reg [ENTRY_NUM - 1 : 0] bht_item_valid;
reg [ENTRY_NUM - 1 : 0] bht_item_is_loop;
reg bht_read_item_valid;
reg is_loop_rec;

reg[15:0] predict0_credit[ENTRY_NUM - 1 : 0];
reg[15:0] predict1_credit[ENTRY_NUM - 1 : 0];
reg[15:0] predict3_credit[ENTRY_NUM - 1 : 0];
reg[15:0] predict0_rd_credit;
reg[15:0] predict1_rd_credit;
reg[15:0] predict3_rd_credit;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		bht_item_valid <= {ENTRY_NUM{1'b0}};	
		bht_item_is_loop <= {ENTRY_NUM{1'b0}};
		bht_read_item_valid <= 1'b0;
		is_loop_rec <= 1'b0;
		predict0_rd_credit <= 16'h0;
		predict1_rd_credit <= 16'h0;
		predict3_rd_credit <= 16'h0;
	end
	else
	begin
		bht_read_item_valid <= bht_item_valid[bht_raddr];
		is_loop_rec <= bht_item_is_loop[bht_raddr];
		predict0_rd_credit <= predict0_credit[bht_raddr];
		predict1_rd_credit <= predict1_credit[bht_raddr];
		predict3_rd_credit <= predict3_credit[bht_raddr];
		if(bht_wen)
		begin
			bht_item_valid[bht_waddr] <= 1'b1;
			bht_item_is_loop[bht_waddr] <= is_loop_ex;
		end
	end
end


integer i;
wire predict0_credit_full = (predict0_credit[bht_waddr] == 16'hffff);
wire predict1_credit_full = (predict1_credit[bht_waddr] == 16'hffff);
wire predict3_credit_full = (predict3_credit[bht_waddr] == 16'hffff);
wire predict0_score = predict0_taken_ex ~^ branch_taken_ex;
wire predict1_score = predict1_taken_ex ~^ branch_taken_ex;
wire predict3_score = predict3_taken_ex ~^ branch_taken_ex;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		for(i=0; i<ENTRY_NUM; i=i+1)
		begin
			predict0_credit[i] <= 16'h0;
			predict1_credit[i] <= 16'h0;
			predict3_credit[i] <= 16'h0;
		end
	end
	else
	begin
		if(bht_wen)
		begin
			if(predict0_score && (!predict0_credit_full) && (!is_loop_ex))
			predict0_credit[bht_waddr] <= predict0_credit[bht_waddr] + 16'h1;
			if(predict1_score && (!predict1_credit_full) && (!is_loop_ex))
			predict1_credit[bht_waddr] <= predict1_credit[bht_waddr] + 16'h1;
			if(predict3_score && (!predict3_credit_full) && (!is_loop_ex))
			predict3_credit[bht_waddr] <= predict3_credit[bht_waddr] + 16'h1;
		end
	end
end


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
reg[`ADDR_WIDTH - 1 : 0] bht [ENTRY_NUM - 1 : 0];
reg[`ADDR_WIDTH - 1 : 0] bht_r_pc;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	bht_r_pc <= bht[bht_raddr];
	if(bht_wen)
	begin
		bht[bht_waddr] <= bht_w_pc;
	end
end
`endif

wire hit = bht_read_item_valid ? (pc == bht_r_pc) : 1'b0;

wire predict1_rd_data;
//predict0 - 2-level 2-bit predictor
predictor_m2n2 u_predict0(
.cpu_clk		(cpu_clk		),
.cpu_rstn		(cpu_rstn		),
.branch_ex		(branch_ex		),
.is_loop_ex		(is_loop_ex		),
.branch_taken_ex	(branch_taken_ex	),
.next_pc		(next_pc		),
.branch_pc_ex		(branch_pc_ex		),
.predictor		(predict0_rd_data	)
);

//predict1 - basic predictor
wire [PR_ADDR_WIDTH - 1 : 0] predict1_raddr = next_pc[PR_ADDR_WIDTH + 1 : 2];
wire [PR_ADDR_WIDTH - 1 : 0] predict1_waddr = branch_pc_ex[PR_ADDR_WIDTH + 1 : 2];
wire predict1_wen = branch_ex;


basic_predictor_2b #(.entry_num(ENTRY_NUM),.addr_width(PR_ADDR_WIDTH)) u_predict1 (
.cpu_clk		(cpu_clk),
.cpu_rstn		(cpu_rstn),
.predictor_raddr 	(predict1_raddr),
.predictor_waddr 	(predict1_waddr),
.predictor_wen	 	(predict1_wen),
.branch_taken_ex 	(branch_taken_ex),
.predictor_rd_data	(predict1_rd_data)
);

//predict2 - loop predictor
wire predict2_rd_data;
wire is_loop_det;
loop_predictor u_predict2(
.cpu_clk		(cpu_clk),
.cpu_rstn		(cpu_rstn),
.pc_ex			(branch_pc_ex),
.branch_ex		(branch_ex),
.branch_taken_ex	(branch_taken_ex),
.jal_dec		(jal_dec),
.jalr_ex		(jalr_ex),
.pc			(pc),
.is_loop_dec		(is_loop_dec),
.is_loop_ex		(is_loop_ex),
.src_data1_ex		(src_data1_ex),
.src_data2_ex		(src_data2_ex),
.is_loop		(is_loop_det),
.loop_predict_taken	(predict2_rd_data)
);

//assign is_loop = is_loop_rec || is_loop_det;
assign is_loop = is_loop_det;

//predict3 - 10 record predictor
wire [PR_ADDR_WIDTH - 1 : 0] predict3_raddr = next_pc[PR_ADDR_WIDTH + 1 : 2];
wire [PR_ADDR_WIDTH - 1 : 0] predict3_waddr = branch_pc_ex[PR_ADDR_WIDTH + 1 : 2];
wire predict3_wen = branch_ex;
wire predict3_rd_data;
wire predict3_rd_valid;
predictor_rec #(.entry_num(ENTRY_NUM),.addr_width(PR_ADDR_WIDTH),.rec_num(8)) u_predict3 (
.cpu_clk		(cpu_clk),
.cpu_rstn		(cpu_rstn),
.predictor_raddr 	(predict3_raddr),
.predictor_waddr 	(predict3_waddr),
.predictor_wen	 	(predict3_wen),
.branch_taken_ex 	(branch_taken_ex),
.rec_entry_valid	(predict3_rd_valid),
.predictor_rd_data	(predict3_rd_data)
);

//predictor selector
wire predictor;
wire predict0_win = (predict0_rd_credit > predict1_rd_credit) && (predict0_rd_credit > predict3_rd_credit);
wire predict1_win = (predict1_rd_credit >= predict3_rd_credit) && (predict1_rd_credit >= predict0_rd_credit);
wire predict3_win = (predict3_rd_credit > predict0_rd_credit) && (predict3_rd_credit > predict1_rd_credit);
//assign predictor = predict1_rd_data[1];
assign predictor = is_loop_det? predict2_rd_data : (predict1_win ? predict1_rd_data : (predict3_win? predict3_rd_data : predict0_rd_data));

//assign predict_taken = 1'b0;

assign predict0_taken = hit && predict0_rd_data;
assign predict1_taken = hit && predict1_rd_data;
assign predict3_taken = hit && predict3_rd_data;

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
reg[`ADDR_WIDTH - 1 : 0] btt [ENTRY_NUM - 1 : 0];
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
