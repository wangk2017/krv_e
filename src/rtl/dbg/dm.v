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
// File Name: 		dm.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		Debug Module                            ||
// History:   		2019.05.12				||
//                      First version				||
//===============================================================
`include "top_defines.vh"

module dm(
//AXI4-lite master memory interface
//AXI4-lite global signal

input ACLK,						
input ARESETn,						

//AXI4-lite Write Address Channel
output 					AWVALID,	
input  					AWREADY,	
output [`AXI_ADDR_WIDTH - 1 : 0] 	AWADDR,
output [2:0]				AWPROT,

//AXI4-lite Write Data Channel
output 					WVALID,
input  					WREADY,
output [`AXI_DATA_WIDTH - 1 : 0] 	WDATA,
output [`AXI_STRB_WIDTH - 1 : 0]	WSTRB,

//AXI4-lite Write Response Channel
input					BVALID,
output 					BREADY,
input [1:0]				BRESP,

//AXI4-lite Read Address Channel
output 					ARVALID,			
input					ARREADY,
output [`AXI_ADDR_WIDTH - 1 : 0]	ARADDR,
output [2:0]				ARPROT,

//AXI4-lite Read Data Channel
input 					RVALID,
output					RREADY,
input [`AXI_DATA_WIDTH - 1 : 0]		RDATA,
input [1:0]				RRESP,

//global signals
input				sys_clk,
input				sys_rstn,

//DTM interface
input				dtm_req_valid,
output				dtm_req_ready,
input[`DBUS_M_WIDTH - 1 : 0]	dtm_req_bits,

output				dm_resp_valid,
input				dm_resp_ready,
output[`DBUS_S_WIDTH - 1 : 0]	dm_resp_bits,

//core interface
output				resumereq_w1,
output				dbg_reg_access,
output 				dbg_wr1_rd0,
output[`CMD_REGNO_SIZE - 1 : 0]	dbg_regno,
output [`DATA_WIDTH - 1 : 0]	dbg_write_data,
input 				dbg_read_data_valid,
input [`DATA_WIDTH - 1 : 0]	dbg_read_data

);


//wires declaration
wire [`DM_REG_WIDTH - 1 : 0]	command;
wire [`DM_REG_WIDTH - 1 : 0]	data0;
wire 				cmd_update;
wire				cmd_finished;
wire [`DATA_WIDTH - 1 : 0]	cmd_read_data;

wire [`DM_REG_WIDTH - 1 : 0]	sbaddress0;
wire        			sbaddress0_update;
wire [`DM_REG_WIDTH - 1 : 0]	sbdata0;
wire        			sbdata0_update;
wire        			sbdata0_rd;
wire [`DM_REG_WIDTH - 1 : 0]	system_bus_read_data;
wire 				system_bus_read_data_valid;
wire 				sbbusy;
wire        			sbreadonaddr;
wire [2:0]			sbaccess;
wire        			sbreadondata;
wire [2:0]			sberror;
wire [2:0]			sberror_w1;
wire  				sbbusyerror;
wire				sbbusyerror_w1;


//sub-modules
dm_regs u_dm_regs (
.sys_clk		(sys_clk	),
.sys_rstn		(sys_rstn	),
.resumereq_w1		(resumereq_w1	),
.data0			(data0		),
.command		(command	),
.cmd_update		(cmd_update	),
.cmd_finished		(cmd_finished		),
.sbaddress0		(sbaddress0		),
.sbaddress0_update	(sbaddress0_update	),
.sbdata0		(sbdata0		),
.sbdata0_update		(sbdata0_update		),
.sbdata0_rd		(sbdata0_rd		),
.system_bus_read_data	(system_bus_read_data	),
.system_bus_read_data_valid	(system_bus_read_data_valid	),
.sbbusy			(sbbusy			),
.sbreadonaddr		(sbreadonaddr		),
.sbaccess		(sbaccess		),
.sbreadondata		(sbreadondata		),
.sberror		(sberror		),
.sberror_w1		(sberror_w1		),
.sbbusyerror		(sbbusyerror		),
.sbbusyerror_w1		(sbbusyerror_w1		),
.cmd_read_data_valid	(dbg_read_data_valid	),
.cmd_read_data		(cmd_read_data		),
.dtm_req_valid		(dtm_req_valid	),
.dtm_req_ready		(dtm_req_ready	),
.dtm_req_bits		(dtm_req_bits	),
.dm_resp_valid		(dm_resp_valid	),
.dm_resp_ready		(dm_resp_ready	),
.dm_resp_bits		(dm_resp_bits	)
);

//abs_cmd
abs_cmd u_abs_cmd(
.sys_clk		(sys_clk		),
.sys_rstn		(sys_rstn		),
.data0			(data0	),
.command		(command		),
.cmd_update		(cmd_update		),
.cmd_finished		(cmd_finished		),
.cmd_read_data		(cmd_read_data		),
.valid_reg_access	(dbg_reg_access		),
.wr1_rd0		(dbg_wr1_rd0		),
.regno			(dbg_regno		),
.write_data		(dbg_write_data		),
.read_data_valid	(dbg_read_data_valid	),
.read_data		(dbg_read_data		)
);

//system_bus_access

system_bus_access u_system_bus_access (
.ACLK			(ACLK			),
.ARESETn		(ARESETn		),					
.AWVALID		(AWVALID		),
.AWREADY		(AWREADY		),
.AWADDR			(AWADDR			),
.AWPROT			(AWPROT			),
.WVALID			(WVALID			),
.WREADY			(WREADY			),
.WDATA			(WDATA			),
.WSTRB			(WSTRB			),
.BVALID			(BVALID			),
.BREADY			(BREADY			),
.BRESP			(BRESP			),
.ARVALID		(ARVALID		),			
.ARREADY		(ARREADY		),
.ARADDR			(ARADDR			),
.ARPROT			(ARPROT			),
.RVALID			(RVALID			),
.RREADY			(RREADY			),
.RDATA			(RDATA			),
.RRESP			(RRESP			),
.sys_clk		(sys_clk		),
.sys_rstn		(sys_rstn		),
.sbaddress0		(sbaddress0		),
.sbaddress0_update	(sbaddress0_update	),
.sbdata0		(sbdata0		),
.sbdata0_update		(sbdata0_update		),
.sbdata0_rd		(sbdata0_rd		),
.system_bus_read_data	(system_bus_read_data	),
.system_bus_read_data_valid	(system_bus_read_data_valid	),
.sbbusy			(sbbusy			),
.sbreadonaddr		(sbreadonaddr		),
.sbaccess		(sbaccess		),
.sbreadondata		(sbreadondata		),
.sberror		(sberror		),
.sberror_w1		(sberror_w1		),
.sbbusyerror		(sbbusyerror		),
.sbbusyerror_w1		(sbbusyerror_w1		)

);

endmodule
