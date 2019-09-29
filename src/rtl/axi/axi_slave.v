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
// File Name: 		axi_slave.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		axi slave 		        	|| 
// History:   							||
//                      2019/9/11				||
//                      First version				||
//===============================================================

`include "axi_defines.vh"
module axi_slave (

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


//slave IP interface
input wire [`AXI_DATA_WIDTH - 1 : 0] 	ip_read_data,
input wire 				ip_read_data_valid,
output reg [`AXI_ADDR_WIDTH - 1 : 0] 	ip_addr,
output wire [`AXI_DATA_WIDTH - 1 : 0] 	ip_write_data,
output wire [3:0] 			ip_byte_strobe,
output wire 				valid_reg_write,
output reg 				valid_reg_read

);

assign AWREADY = 1'b1;
assign WREADY  = 1'b1;
assign ARREADY = 1'b1;
assign RVALID  = ip_read_data_valid;
assign RDATA   = ip_read_data;
assign RRESP   = `OKAY;
assign BRESP   = `OKAY;

reg bvalid_r;
always @(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		bvalid_r <= 1'b0;
	end
	else
	begin
		if(WVALID)
		begin
			bvalid_r <= 1'b1;
		end
		else if(BREADY)
		begin
			bvalid_r <= 1'b0;
		end
	end
end
assign BVALID = bvalid_r;

always @(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		ip_addr <= {`AXI_ADDR_WIDTH{1'b0}};
		valid_reg_read <= 1'b0;
	end
	else
	begin
		if(AWVALID)
		begin
			ip_addr <= AWADDR;
			valid_reg_read <= 1'b0;
		end
		else if(ARVALID)
		begin
			ip_addr <= ARADDR;
			valid_reg_read <= 1'b1;
		end
		else
		begin
			ip_addr <= {`AXI_ADDR_WIDTH{1'b0}};
			valid_reg_read <= 1'b0;
		end
	end
end

assign valid_reg_write = WVALID;
assign ip_write_data = WVALID ? WDATA : {`AXI_DATA_WIDTH{1'b0}};
assign ip_byte_strobe = WVALID ? WSTRB : {`AXI_STRB_WIDTH{1'b0}};

endmodule

