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

//===============================================================||
// File Name: 		tcm_decoder.v				 ||
// Author:    		Kitty Wang				 ||
// Description:   						 ||
//	      		decoder of tcm to be accessed by AXI     ||
// History:   							 ||
//===============================================================||

`include "top_defines.vh"

module tcm_decoder (
//AXI4-lite slave memory interface
//AXI4-lite global signal
input ACLK,						
input ARESETn,						

//AXI4-lite Write Address Channel
input 					AWVALID,	
output  				AWREADY,	
input [`AXI_ADDR_WIDTH - 1 : 0] 	AWADDR,
input [2:0]				AWPROT,

//AXI4-lite Write Data Channel
input 					WVALID,
output  				WREADY,
input [`AXI_DATA_WIDTH - 1 : 0] 	WDATA,
input [`AXI_STRB_WIDTH - 1 : 0]		WSTRB,

//AXI4-lite Write Response Channel
output					BVALID,
input 					BREADY,
output [1:0]				BRESP,

//AXI4-lite Read Address Channel
input 					ARVALID,			
output					ARREADY,
input [`AXI_ADDR_WIDTH - 1 : 0]		ARADDR,
input [2:0]				ARPROT,

//AXI4-lite Read Data Channel
output 					RVALID,
input					RREADY,
output [`AXI_DATA_WIDTH - 1 : 0]	RDATA,
output [1:0]				RRESP,

//tcm interface
input wire itcm_auto_load,
output wire AXI_itcm_access,
output wire AXI_dtcm_access,
output wire [`AXI_ADDR_WIDTH - 1 : 0] AXI_tcm_addr,
output wire [3:0] AXI_tcm_byte_strobe,
output wire AXI_tcm_rd0_wr1,
output wire [`DATA_WIDTH - 1 : 0] AXI_tcm_write_data,
input wire [`DATA_WIDTH - 1 : 0] AXI_itcm_read_data,
input wire AXI_itcm_read_data_valid,
input wire [`DATA_WIDTH - 1 : 0] AXI_dtcm_read_data,
input wire AXI_dtcm_read_data_valid,
output wire AWVALID_flash,
output wire WVALID_flash,
output wire ARVALID_flash,
input wire [`DATA_WIDTH - 1 : 0] RDATA_flash

);


//AXI4-lite slave interface
wire [`AXI_DATA_WIDTH - 1 : 0] 	ip_read_data;
wire 				ip_read_data_valid;
wire [`AXI_ADDR_WIDTH - 1 : 0] 	ip_addr;
wire [`AXI_DATA_WIDTH - 1 : 0] 	ip_write_data;
wire [3:0] 			ip_byte_strobe;
wire 				valid_reg_write;
wire 				valid_reg_read;

axi_slave axi_slave_uart(
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
.ip_read_data		(ip_read_data		),
.ip_read_data_valid	(ip_read_data_valid	),
.ip_addr		(ip_addr		),
.ip_write_data		(ip_write_data		),
.ip_byte_strobe		(ip_byte_strobe		),
.valid_reg_write	(valid_reg_write	),
.valid_reg_read		(valid_reg_read		)
);



wire valid_reg_access = valid_reg_read || valid_reg_write;
assign AXI_tcm_addr  =  ip_addr;

`ifdef KRV_HAS_ITCM
assign AXI_itcm_access = (!itcm_auto_load) && valid_reg_access && (AXI_tcm_addr >= `ITCM_START_ADDR) && (AXI_tcm_addr < `ITCM_START_ADDR + `ITCM_SIZE); 
wire ip_addr_itcm_range = (!itcm_auto_load) && (ip_addr >= `ITCM_START_ADDR) && (ip_addr < `ITCM_START_ADDR + `ITCM_SIZE);
`else
assign AXI_itcm_access = 1'b0;
wire ip_addr_itcm_range = 1'b0;
`endif


`ifdef KRV_HAS_DTCM
assign AXI_dtcm_access = valid_reg_access &&  (AXI_tcm_addr >= `DTCM_START_ADDR) && (AXI_tcm_addr < `DTCM_START_ADDR + `DTCM_SIZE); 
wire ip_addr_dtcm_range = (ip_addr >= `DTCM_START_ADDR) && (ip_addr < `DTCM_START_ADDR + `DTCM_SIZE);
`else
assign AXI_dtcm_access = 1'b0;
wire ip_addr_dtcm_range = 1'b0;
`endif

reg AXI_dtcm_access_r;
reg AXI_itcm_access_r;

always @(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		AXI_dtcm_access_r <= 1'b0;
		AXI_itcm_access_r <= 1'b0;
	end
	else
	begin
		AXI_dtcm_access_r <= AXI_dtcm_access;
		AXI_itcm_access_r <= AXI_itcm_access;
	end
end

assign ip_read_data = AXI_dtcm_access_r ? AXI_dtcm_read_data : (AXI_itcm_access_r ? AXI_itcm_read_data : RDATA_flash);
assign ip_read_data_valid = (AXI_dtcm_access || AXI_dtcm_access_r ) ? AXI_dtcm_read_data_valid : ((AXI_itcm_access || AXI_itcm_access_r)? AXI_itcm_read_data_valid : valid_reg_access);

assign AWVALID_flash = AWVALID && (!(ip_addr_itcm_range || ip_addr_dtcm_range));
assign WVALID_flash = WVALID && (!(ip_addr_itcm_range || ip_addr_dtcm_range));
assign ARVALID_flash = ARVALID && (!(ip_addr_itcm_range || ip_addr_dtcm_range));

endmodule
