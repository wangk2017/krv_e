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
// File Name: 		predictor_m2n2.v			||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		a 2-leve 2b predictor			|| 
// History:   							||
//===============================================================

`include "core_defines.vh"

module predictor_m2n2(
input     			cpu_clk,
input     			cpu_rstn,
input      			branch_ex,
input     			branch_taken_ex,
input [`ADDR_WIDTH - 1 : 0] 	next_pc,
input [`ADDR_WIDTH - 1 : 0] 	branch_pc_ex,
output [1:0]			predictor
);
//parameters
parameter ENTRY_NUM = 256;
parameter PR_ADDR_WIDTH = $clog2(ENTRY_NUM);


//level 1
reg [1 :0] global_history;
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		global_history <= 2'b00;
	end
	else 
	begin
		if(branch_ex)
		begin
			global_history <= {global_history[0],branch_taken_ex};
		end
	end
end

wire select_bank0 = (~(|global_history));
wire select_bank1 = ((~global_history[1]) && global_history[0] );
wire select_bank2 = ((global_history[1]) && (~global_history[0]));
wire select_bank3 = (&global_history);

//level 2
wire [PR_ADDR_WIDTH - 1 : 0] predictor_raddr = next_pc[PR_ADDR_WIDTH + 1 : 2];
wire [PR_ADDR_WIDTH - 1 : 0] predictor_waddr = branch_pc_ex[PR_ADDR_WIDTH + 1 : 2];

wire predictor_bank0_wen = branch_ex && select_bank0;
wire[1:0] predictor_bank0_rd_data;

basic_predictor_2b #(.entry_num(ENTRY_NUM),.addr_width(PR_ADDR_WIDTH)) u_predictor_bank0 (
.cpu_clk		(cpu_clk),
.cpu_rstn		(cpu_rstn),
.predictor_raddr 	(predictor_raddr),
.predictor_waddr 	(predictor_waddr),
.predictor_wen	 	(predictor_bank0_wen),
.branch_taken_ex 	(branch_taken_ex),
.predictor_rd_data	(predictor_bank0_rd_data)
);


wire predictor_bank1_wen = branch_ex && select_bank1;
wire[1:0] predictor_bank1_rd_data;

basic_predictor_2b #(.entry_num(ENTRY_NUM),.addr_width(PR_ADDR_WIDTH)) u_predictor_bank1 (
.cpu_clk		(cpu_clk),
.cpu_rstn		(cpu_rstn),
.predictor_raddr 	(predictor_raddr),
.predictor_waddr 	(predictor_waddr),
.predictor_wen	 	(predictor_bank1_wen),
.branch_taken_ex 	(branch_taken_ex),
.predictor_rd_data	(predictor_bank1_rd_data)
);


wire predictor_bank2_wen = branch_ex && select_bank2;
wire[1:0] predictor_bank2_rd_data;

basic_predictor_2b #(.entry_num(ENTRY_NUM),.addr_width(PR_ADDR_WIDTH)) u_predictor_bank2 (
.cpu_clk		(cpu_clk),
.cpu_rstn		(cpu_rstn),
.predictor_raddr 	(predictor_raddr),
.predictor_waddr 	(predictor_waddr),
.predictor_wen	 	(predictor_bank2_wen),
.branch_taken_ex 	(branch_taken_ex),
.predictor_rd_data	(predictor_bank2_rd_data)
);


wire predictor_bank3_wen = branch_ex && select_bank3;
wire[1:0] predictor_bank3_rd_data;

basic_predictor_2b #(.entry_num(ENTRY_NUM),.addr_width(PR_ADDR_WIDTH)) u_predictor_bank3 (
.cpu_clk		(cpu_clk),
.cpu_rstn		(cpu_rstn),
.predictor_raddr 	(predictor_raddr),
.predictor_waddr 	(predictor_waddr),
.predictor_wen	 	(predictor_bank3_wen),
.branch_taken_ex 	(branch_taken_ex),
.predictor_rd_data	(predictor_bank3_rd_data)
);

assign predictor =  ({2{select_bank0}} & predictor_bank0_rd_data) |
			({2{select_bank1}} & predictor_bank1_rd_data) |
			({2{select_bank2}} & predictor_bank2_rd_data) |
			({2{select_bank3}} & predictor_bank3_rd_data) ;
	


endmodule
