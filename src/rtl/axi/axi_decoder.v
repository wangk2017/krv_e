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
// File Name: 		axi_decoder.v 				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		axi decoder		        	|| 
// History:   							||
//                      2019/9/16 				||
//                      First version				||
//===============================================================

`include "axi_defines.vh"
module axi_decoder (

input [`AXI_ADDR_WIDTH - 1 : 0] 	addr,
output reg [2:0]			slave_no

);

/*
//---------------------------------------------------------------------//
Block Name		Address Range
Reserved for FLASH	0x0000_0000 ~ 0x3FFF_FFFF
KPLIC			0x4000_0000 ~ 0x43FF_FFFF
MTIMER			0x4400_0000 ~ 0x4FFF_FFFF
Reserved		0x5000_0000 ~ 0x6FFF_FFFF
APB			0x7000_0000 ~ 0x7FFF_FFFF
Reserved		0x8000_0000 ~ 0xFFFF_FFFF
//---------------------------------------------------------------------//
*/
wire[3:0] nibble_0 = addr[3:0];
wire[3:0] nibble_1 = addr[7:4];
wire[3:0] nibble_2 = addr[11:8];
wire[3:0] nibble_3 = addr[15:12];
wire[3:0] nibble_4 = addr[19:16];
wire[3:0] nibble_5 = addr[23:20];
wire[3:0] nibble_6 = addr[27:24];
wire[3:0] nibble_7 = addr[31:28];

wire SEL_S0 = (
	(nibble_7 < 4'h4)
);	

wire SEL_S1 = (
	(nibble_7 == 4'h4) &&
	(nibble_6 < 4'h4)
);

wire SEL_S2 = (
	(nibble_7 == 4'h4) &&
	(nibble_6 >= 4'h4)
);

wire SEL_S3 = (
	(nibble_7 == 4'h5) || (nibble_7 == 4'h6)
);

wire SEL_S4 = (
	nibble_7 == 4'h7
);

wire SEL_S5 = (
	(nibble_7 >= 4'h8)
);

always @ *
begin
	if(SEL_S0)
	slave_no = 3'h0;
	else if(SEL_S1)
	slave_no = 3'h1;
	else if(SEL_S2)
	slave_no = 3'h2;
	else if(SEL_S3)
	slave_no = 3'h3;
	else if(SEL_S4)
	slave_no = 3'h4;
	else if(SEL_S5)
	slave_no = 3'h5;
end

endmodule
