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
// File Name: 		system_bus_access.v			||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		system bus access 	                ||
// History:   		2019.06.18				||
//                      First version				||
//===============================================================
`include "top_defines.vh"

module system_bus_access(
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


//dm global clock
input				sys_clk,
input				sys_rstn,

//interface with dm_regs block
input [`DM_REG_WIDTH - 1 : 0]	sbaddress0,
input				sbaddress0_update,
input [`DM_REG_WIDTH - 1 : 0]	sbdata0,
input				sbdata0_update,
input				sbdata0_rd,
output [`DM_REG_WIDTH - 1 : 0]	system_bus_read_data,
output 				system_bus_read_data_valid,
output				sbbusy,
input				sbreadonaddr,
input[2:0]			sbaccess,
input				sbreadondata,
output reg [2:0]		sberror,
input[2:0]			sberror_w1,
output reg 			sbbusyerror,
input				sbbusyerror_w1

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


axi_master DAXI_M (
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


assign M_access = (sbdata0_rd || sbdata0_update || (sbaddress0_update && sbreadonaddr)) && !sbbusy;
assign M_write_strobe = 4'hf;
assign M_rd0_wr1 = sbdata0_update;
assign M_addr = sbaddress0;
assign M_write_data = sbdata0;

assign system_bus_read_data_valid = read_data_valid_M;
assign system_bus_read_data = read_data_M;


always @ (posedge sys_clk or negedge sys_rstn)
begin
	if(!sys_rstn)
	begin
		sbbusyerror <= 1'b0;
	end
	else 
	begin
		if(sbbusyerror_w1)
		begin
			sbbusyerror <= 1'b0;
		end
		else if(sbbusy && (sbdata0_update || (sbaddress0_update && sbreadonaddr)))
		begin
			sbbusyerror <= 1'b1;
		end
	end
end

integer i;
always @ (posedge sys_clk or negedge sys_rstn)
begin
	if(!sys_rstn)
	begin
		sberror <= 3'h0;
	end
	else 
	begin
		if(|sberror_w1)
		begin
			for(i=0; i<3; i=i+1)
			begin
			if(sberror_w1[i])
				sberror[i] <= 1'b0;
			end
		end
		else if(M_access)
		begin
			if(sbaccess > 3'b10)
				sberror <= 3'h4;
			else
				sberror <= 3'h0;
		end
	end
end


endmodule

