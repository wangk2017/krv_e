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
// File Name: 		mem_ctrl.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		instruction memory control block        ||
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//===============================================================

`include "top_defines.vh"
module imem_ctrl (
//global signals
input wire cpu_clk,					//cpu clock
input wire cpu_rstn,					//cpu reset, active low

//interface with fetch
input wire [`ADDR_WIDTH - 1 : 0] pc,			//pc
output wire [`INSTR_WIDTH - 1 : 0] instr_read_data,  	//instruction
output wire instr_read_data_valid,			//instruction valid

//interface with ITCM
output wire instr_itcm_access,				//ITCM access
output wire [`ADDR_WIDTH - 1 : 0] instr_itcm_addr,	//ITCM access address
input wire [`INSTR_WIDTH - 1 : 0] instr_itcm_read_data,	//ITCM read data
input wire instr_itcm_read_data_valid,			//ITCM read data valid
input wire itcm_auto_load,			//ITCM is in auto-load process

//interface with IAXI
output wire IAXI_access,				//IAXI access 
output wire [`ADDR_WIDTH - 1 : 0] IAXI_addr,		//IAXI access address
input wire [`INSTR_WIDTH - 1 : 0] IAXI_read_data,	//IAXI read data
input wire IAXI_read_data_valid				//IAXI read data valid
);


//NOTE: memory access should be aligned for now!

//---------------------------------------------//
//address decoder
//---------------------------------------------//
wire addr_itcm;
//wire addr_dtcm;
`ifdef KRV_HAS_ITCM
assign addr_itcm =(pc >= `ITCM_START_ADDR) && (pc < `ITCM_START_ADDR + `ITCM_SIZE);
`else
assign addr_itcm = 1'b0;
`endif

wire addr_AXI;
assign addr_AXI = ~(addr_itcm);

//reg addr_itcm_r;
reg addr_AXI_r;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		//addr_itcm_r <= 1'b0;
		addr_AXI_r <= 1'b0;
	end
	else
	begin
		//addr_itcm_r <= addr_itcm;
		addr_AXI_r <= addr_AXI;
	end
end

//---------------------------------------------//
//Drive interface
//---------------------------------------------//
assign instr_itcm_access = addr_itcm;
assign instr_itcm_addr = pc;

assign IAXI_access = addr_AXI_r;
assign IAXI_addr = pc;
 
//---------------------------------------------//
//read data MUX 
//---------------------------------------------//
assign instr_read_data = ({`INSTR_WIDTH{(addr_itcm & instr_itcm_read_data_valid)}} & instr_itcm_read_data)
			|({`INSTR_WIDTH{(!itcm_auto_load & addr_AXI_r &  IAXI_read_data_valid)}} & IAXI_read_data);
assign instr_read_data_valid = (addr_itcm && instr_itcm_read_data_valid) || (!itcm_auto_load && addr_AXI_r && IAXI_read_data_valid);

endmodule
