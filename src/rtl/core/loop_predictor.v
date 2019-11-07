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
// File Name: 		loop_predictor.v 			||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		loop predictor				|| 
// History:   							||
//===============================================================

`include "core_defines.vh"

module loop_predictor(
input wire cpu_clk,
input wire cpu_rstn,

input wire[`ADDR_WIDTH - 1 : 0] pc_ex,
input wire branch_ex,
input wire branch_taken_ex,
input wire jal_dec,
input wire jalr_ex,
input wire[`ADDR_WIDTH - 1 : 0] pc,

input wire is_loop_dec,
input wire is_loop_ex,
input wire[`DATA_WIDTH - 1 : 0] src_data1_ex,
input wire[`DATA_WIDTH - 1 : 0] src_data2_ex,

output wire is_loop,
output wire loop_predict_taken
);

//--------------------------------------------------------//
//loop detection logic
//if the next pc matches with the previous branch pc, 
//it is predicted as a loop 
//--------------------------------------------------------//

//loop pc:
//record the previous branch addr
reg[`ADDR_WIDTH - 1 : 0] loop_pc;
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		loop_pc <= {`ADDR_WIDTH{1'b0}};
	end
	else 
	begin
		if(jal_dec || jalr_ex)
		loop_pc <= {`ADDR_WIDTH{1'b0}};
		else if(branch_ex)
		loop_pc <= pc_ex;
	end
end

assign is_loop = (pc == loop_pc);


//predict the loop times
reg[`DATA_WIDTH - 1 : 0] loop_src_data1;
reg[`DATA_WIDTH - 1 : 0] loop_src_data2;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		loop_src_data1 <= {`DATA_WIDTH{1'b0}};
		loop_src_data2 <= {`DATA_WIDTH{1'b0}};
	end
	else 
	begin
		if(branch_taken_ex)
		begin
			loop_src_data1 <= src_data1_ex;
			loop_src_data2 <= src_data2_ex;
		end
		else if(branch_ex && !is_loop_dec && !is_loop)
		begin
			loop_src_data1 <= src_data1_ex;
			loop_src_data2 <= src_data2_ex;
		end
	end
end

wire [`DATA_WIDTH - 1 : 0] branch_src_data1_ex = {32{branch_ex & is_loop_ex}} & src_data1_ex;
wire [`DATA_WIDTH - 1 : 0] branch_src_data2_ex = {32{branch_ex & is_loop_ex}} & src_data2_ex;


wire [`DATA_WIDTH - 1 : 0] src_data1_incr = is_loop_ex ? ((branch_src_data1_ex > loop_src_data1) ?  (branch_src_data1_ex - loop_src_data1) : (loop_src_data1 - branch_src_data1_ex)) : 0;
wire [`DATA_WIDTH - 1 : 0] src_data2_incr = is_loop_ex ? ((branch_src_data2_ex > loop_src_data2) ?  (branch_src_data2_ex - loop_src_data2) : (loop_src_data2 - branch_src_data2_ex)) : 0;

wire [`DATA_WIDTH - 1 : 0] loop_incr_i = src_data1_incr | src_data2_incr;
reg [`DATA_WIDTH - 1 : 0] loop_incr;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		loop_incr <= {`DATA_WIDTH{1'b0}};
	end
	else 
	begin
		if(branch_ex && is_loop_ex)
		begin
			loop_incr <= loop_incr_i;
		end
	end
end

wire [`DATA_WIDTH - 1 : 0] loop_gap = is_loop ? ((loop_src_data1 > loop_src_data2 ) ? (loop_src_data1 - loop_src_data2) : (loop_src_data2 - loop_src_data1)) : {`DATA_WIDTH{1'b0}};


assign loop_predict_taken = (loop_gap > loop_incr);


endmodule
