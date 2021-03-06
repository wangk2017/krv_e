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
// File Name: 		gprs.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		general purpose register          	|| 
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//===============================================================
`include "core_defines.vh"
`include "dbg_defines.vh"
module gprs (
//global signals
input cpu_clk,					//cpu clock
input cpu_rstn,					//cpu reset, active low

//1x write point
input wr_valid,					//write valid
input [`DATA_WIDTH - 1 : 0] wr_data, 		//write data
input [`RD_WIDTH - 1 : 0] rd_wb,		//rd in WB stage

//2x read point
input [`RS1_WIDTH - 1 : 0] rs1_dec,		//source 1 index in DEC stage
output [`DATA_WIDTH - 1 : 0] gprs_data1,	//source 1 data from gprs
input [`RS2_WIDTH - 1 : 0] rs2_dec,		//source 2 index in DEC stage
output [`DATA_WIDTH - 1 : 0] gprs_data2 	//source 2 data from gprs

//debug interface
`ifdef KRV_HAS_DBG
,
input				dbg_reg_access,		//debugger access register	
input 				dbg_wr1_rd0,		//debugger access register cmd 0: read; 1: write
input[`CMD_REGNO_SIZE - 1 : 0]	dbg_regno,		//debugger access register number
input[`DATA_WIDTH - 1 : 0]	dbg_write_data,		//debugger access register write data
output[`DATA_WIDTH - 1 : 0]	dbg_read_data,		//debugger access register read data
output				dbg_read_data_valid	//debugger access register read data valid
`endif

);

//----------------------------------------//
//Register File
//----------------------------------------//
`ifdef KRV_HAS_DBG
wire dbg_gprs_range = (dbg_regno >= 16'h1000) && (dbg_regno <= 16'h101f);
wire dbg_wr = dbg_reg_access && dbg_wr1_rd0 && dbg_gprs_range;
wire dbg_rd = dbg_reg_access && !dbg_wr1_rd0 && dbg_gprs_range;
assign dbg_read_data_valid = dbg_rd;
assign dbg_read_data = dbg_rd ? gprs_X[dbg_regno[4:0]] : 32'h0;
`else
wire dbg_wr = 1'b0;
wire [`CMD_REGNO_SIZE - 1 : 0]	dbg_regno = 16'h0;
wire [`DATA_WIDTH - 1 : 0]	dbg_write_data = 32'h0;
`endif

wire [`DATA_WIDTH - 1 : 0] gprs_X [31:0];
reg wr_en [31:1];

integer i;
always @ *
begin
	for(i=1; i<32; i=i+1)
	begin
		wr_en[i] = (wr_valid && (i==rd_wb)) || (dbg_wr && (i==dbg_regno[4:0]));
	end
end

wire [`DATA_WIDTH - 1 : 0] gprs_wr_data = dbg_wr ? dbg_write_data : wr_data; 		//write data

genvar gprs_index;

generate 
	for (gprs_index = 0; gprs_index <32; gprs_index = gprs_index + 1)
	begin : GPRS_X
		if (gprs_index == 0)
		begin
		gpr0 u_gpr0 (
			     .rd_data 	(gprs_X[gprs_index])
		);
		end
		else
		begin
		gpr u_gpr (.clk		(cpu_clk),
			   .rstn	(cpu_rstn),
			   .wr_en 	(wr_en[gprs_index]),
			   .wr_data	(gprs_wr_data),
			   .rd_data	(gprs_X[gprs_index])
				);
		end
	end
endgenerate

assign gprs_data1 = gprs_X[rs1_dec];
assign gprs_data2 = gprs_X[rs2_dec];


endmodule


module gpr0 (
output wire [`DATA_WIDTH - 1 : 0] rd_data
);
assign rd_data = {`DATA_WIDTH {1'b0}};


endmodule

module gpr (
input clk,
input rstn,
input wr_en,
input [`DATA_WIDTH - 1 : 0]wr_data,
output reg [`DATA_WIDTH - 1 : 0] rd_data
);

always @ (posedge clk or negedge rstn)
begin
	if (!rstn)
	begin
		rd_data <= {`DATA_WIDTH {1'b0}};
	end
	else
	begin
		if (wr_en)
		begin
			rd_data <= wr_data;
		end
	end
end

endmodule

