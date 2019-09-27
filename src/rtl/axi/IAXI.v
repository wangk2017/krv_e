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
// File Name: 		IAXI.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		instruction AXI IF                	|| 
// History:   							||
//                      2019/9/25 				||
//                      First version				||
//===============================================================

`include "top_defines.vh"
module IAXI (
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


//with core interface
input 				cpu_clk,		
input 				cpu_resetn,		
input  				itcm_access_AXI,
input   [`ADDR_WIDTH - 1 : 0 ] 	itcm_auto_load_addr,
input  				IAXI_access,		
input   [`ADDR_WIDTH - 1 : 0] 	IAXI_addr,
output  			IAXI_ready,
output  [`DATA_WIDTH - 1 : 0] 	IAXI_read_data,
output  			IAXI_read_data_valid

);

wire				M_access;		
wire				ready_M;		
wire[3:0] 			M_write_strobe;		
wire				M_rd0_wr1;		
wire[`ADDR_WIDTH - 1 : 0]	M_addr;			
wire[`DATA_WIDTH - 1 : 0]	M_write_data; 		
wire [`DATA_WIDTH - 1 : 0]	read_data_M; 		
wire				read_data_valid_M;	
wire [1:0]			resp_M;			


axi_master IAXI_M (
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
.cpu_clk		(cpu_clk		),		
.cpu_resetn		(cpu_resetn		),		
.M_access		(M_access		),		
.ready_M		(ready_M		),		
.M_write_strobe		(M_write_strobe		),		
.M_rd0_wr1		(M_rd0_wr1		),		
.M_addr			(M_addr			),			
.M_write_data		(M_write_data		), 		
.read_data_M		(read_data_M		), 		
.read_data_valid_M	(read_data_valid_M	),	
.resp_M			(resp_M			)			
);


assign M_access = itcm_access_AXI || IAXI_access;
assign M_write_strobe = {`AXI_STRB_WIDTH{1'b0}};
assign M_rd0_wr1 = 1'b0;
assign M_addr = itcm_access_AXI ? itcm_auto_load_addr : IAXI_addr ;
assign M_write_data = {`AXI_DATA_WIDTH{1'b0}};
assign IAXI_ready = ready_M;
assign IAXI_read_data_valid = read_data_valid_M;
assign IAXI_read_data = read_data_M;



endmodule
