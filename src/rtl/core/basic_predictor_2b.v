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
// File Name: 		basic_predictor_2b.v 			||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		basic 2-bit predictor			|| 
// History:   							||
//===============================================================

`include "core_defines.vh"

module basic_predictor_2b #
(
parameter entry_num = 256,
parameter addr_width = $clog2(entry_num)
)
(
input cpu_clk,					
input cpu_rstn,		
input wire [addr_width - 1 : 0] predictor_raddr,
input wire [addr_width - 1 : 0] predictor_waddr,
input wire predictor_wen,
input wire branch_taken_ex,

output reg[1:0] predictor_rd_data
);

reg[1:0] predictor[entry_num - 1 : 0];
//test 
wire[1:0] predictor_f5 = predictor[245];
integer i;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		for(i=0; i<entry_num; i=i+1)
		predictor[i] <= 2'b01;	
	end
	else
	begin
		predictor_rd_data <= predictor[predictor_raddr];	
		if(predictor_wen)
		begin
			case(predictor[predictor_waddr])
			2'b00: begin
				if(branch_taken_ex)
				predictor[predictor_waddr] <= 2'b01;
				else
				predictor[predictor_waddr] <= 2'b00;
			end
			2'b01: begin
				if(branch_taken_ex)
				predictor[predictor_waddr] <= 2'b10;
				else
				predictor[predictor_waddr] <= 2'b00;
			end
			2'b10: begin
				if(branch_taken_ex)
				predictor[predictor_waddr] <= 2'b11;
				else
				predictor[predictor_waddr] <= 2'b01;
			end
			2'b11: begin
				if(branch_taken_ex)
				predictor[predictor_waddr] <= 2'b11;
				else
				predictor[predictor_waddr] <= 2'b10;
			end
			endcase
		end
	end
end


endmodule
