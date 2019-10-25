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
// File Name: 		ret_stack.v          			||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		return stack         			|| 
// History:   							||
//===============================================================

`include "core_defines.vh"

module ret_stack #
(
parameter entry_num = 32,
parameter addr_width = $clog2(entry_num)
)
(
input cpu_clk,					
input cpu_rstn,		
input wire ret_stack_wen,
input wire[`ADDR_WIDTH - 1 : 0] pc_dec,
input wire ret_stack_ren,

output wire stack_empty,
output wire[`ADDR_WIDTH - 1 : 0] ret_addr
);

reg [addr_width - 1 : 0] ret_sp;

reg[`ADDR_WIDTH : 0] stack[entry_num - 1 : 0];
assign stack_empty = (ret_sp == 0);
wire stack_full = (ret_sp == entry_num - 1 );

integer i;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		ret_sp <= {addr_width{1'b0}};
		for(i=0; i<entry_num; i=i+1)
		stack[i] <= {`ADDR_WIDTH{1'b0}};	
	end
	else
	begin
		if(ret_stack_wen)
		begin
			stack[ret_sp] <= pc_dec + 32'h4;
			ret_sp <= ret_sp + 1;
		end
		if(ret_stack_ren)
		begin
			ret_sp <= ret_sp - 1;
		end
	end
end



assign ret_addr = stack[ret_sp - 1];

endmodule
