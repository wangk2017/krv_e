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
// File Name: 		axi.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		axi bus			        	|| 
// History:   							||
//                      2019/9/16				||
//                      First version				||
//===============================================================

`include "axi_defines.vh"
module axi (
//AXI4-lite global signal
input ACLK,						//AXI clock
input ARESETn,						//AXI reset, active low

//AXI4-lite master0 
input 					M0_AWVALID,	
output  				M0_AWREADY,	
input [`AXI_ADDR_WIDTH - 1 : 0] 	M0_AWADDR,
input [2:0]				M0_AWPROT,

input 					M0_WVALID,
output  				M0_WREADY,
input [`AXI_DATA_WIDTH - 1 : 0] 	M0_WDATA,
input [`AXI_STRB_WIDTH - 1 : 0]		M0_WSTRB,

output					M0_BVALID,
input 					M0_BREADY,
output [1:0]				M0_BRESP,

input 					M0_ARVALID,			
output					M0_ARREADY,
input [`AXI_ADDR_WIDTH - 1 : 0]		M0_ARADDR,
input [2:0]				M0_ARPROT,

output 					M0_RVALID,
input					M0_RREADY,
output [`AXI_DATA_WIDTH - 1 : 0]	M0_RDATA,
output [1:0]				M0_RRESP,

//AXI4-lite master1 
input 					M1_AWVALID,	
output  				M1_AWREADY,	
input [`AXI_ADDR_WIDTH - 1 : 0] 	M1_AWADDR,
input [2:0]				M1_AWPROT,

input 					M1_WVALID,
output  				M1_WREADY,
input [`AXI_DATA_WIDTH - 1 : 0] 	M1_WDATA,
input [`AXI_STRB_WIDTH - 1 : 0]		M1_WSTRB,

output					M1_BVALID,
input 					M1_BREADY,
output [1:0]				M1_BRESP,

input 					M1_ARVALID,			
output					M1_ARREADY,
input [`AXI_ADDR_WIDTH - 1 : 0]		M1_ARADDR,
input [2:0]				M1_ARPROT,

output 					M1_RVALID,
input					M1_RREADY,
output [`AXI_DATA_WIDTH - 1 : 0]	M1_RDATA,
output [1:0]				M1_RRESP,

//AXI4-lite master2 
input 					M2_AWVALID,	
output  				M2_AWREADY,	
input [`AXI_ADDR_WIDTH - 1 : 0] 	M2_AWADDR,
input [2:0]				M2_AWPROT,

input 					M2_WVALID,
output  				M2_WREADY,
input [`AXI_DATA_WIDTH - 1 : 0] 	M2_WDATA,
input [`AXI_STRB_WIDTH - 1 : 0]		M2_WSTRB,

output					M2_BVALID,
input 					M2_BREADY,
output [1:0]				M2_BRESP,

input 					M2_ARVALID,			
output					M2_ARREADY,
input [`AXI_ADDR_WIDTH - 1 : 0]		M2_ARADDR,
input [2:0]				M2_ARPROT,

output 					M2_RVALID,
input					M2_RREADY,
output [`AXI_DATA_WIDTH - 1 : 0]	M2_RDATA,
output [1:0]				M2_RRESP,


//AXI4-lite slave0 
output 					S0_AWVALID,	
input  					S0_AWREADY,	
output [`AXI_ADDR_WIDTH - 1 : 0] 	S0_AWADDR,
output [2:0]				S0_AWPROT,

output 					S0_WVALID,
input  					S0_WREADY,
output [`AXI_DATA_WIDTH - 1 : 0] 	S0_WDATA,
output [`AXI_STRB_WIDTH - 1 : 0]	S0_WSTRB,

input					S0_BVALID,
output 					S0_BREADY,
input [1:0]				S0_BRESP,

output 					S0_ARVALID,			
input					S0_ARREADY,
output [`AXI_ADDR_WIDTH - 1 : 0]	S0_ARADDR,
output [2:0]				S0_ARPROT,

input 					S0_RVALID,
output					S0_RREADY,
input [`AXI_DATA_WIDTH - 1 : 0]		S0_RDATA,
input [1:0]				S0_RRESP,

//AXI4-lite slave1 
output 					S1_AWVALID,	
input  					S1_AWREADY,	
output [`AXI_ADDR_WIDTH - 1 : 0] 	S1_AWADDR,
output [2:0]				S1_AWPROT,

output 					S1_WVALID,
input  					S1_WREADY,
output [`AXI_DATA_WIDTH - 1 : 0] 	S1_WDATA,
output [`AXI_STRB_WIDTH - 1 : 0]	S1_WSTRB,

input					S1_BVALID,
output 					S1_BREADY,
input [1:0]				S1_BRESP,

output 					S1_ARVALID,			
input					S1_ARREADY,
output [`AXI_ADDR_WIDTH - 1 : 0]	S1_ARADDR,
output [2:0]				S1_ARPROT,

input 					S1_RVALID,
output					S1_RREADY,
input [`AXI_DATA_WIDTH - 1 : 0]		S1_RDATA,
input [1:0]				S1_RRESP,

//AXI4-lite slave2 
output 					S2_AWVALID,	
input  					S2_AWREADY,	
output [`AXI_ADDR_WIDTH - 1 : 0] 	S2_AWADDR,
output [2:0]				S2_AWPROT,

output 					S2_WVALID,
input  					S2_WREADY,
output [`AXI_DATA_WIDTH - 1 : 0] 	S2_WDATA,
output [`AXI_STRB_WIDTH - 1 : 0]	S2_WSTRB,

input					S2_BVALID,
output 					S2_BREADY,
input [1:0]				S2_BRESP,

output 					S2_ARVALID,			
input					S2_ARREADY,
output [`AXI_ADDR_WIDTH - 1 : 0]	S2_ARADDR,
output [2:0]				S2_ARPROT,

input 					S2_RVALID,
output					S2_RREADY,
input [`AXI_DATA_WIDTH - 1 : 0]		S2_RDATA,
input [1:0]				S2_RRESP,

//AXI4-lite slave3 
output 					S3_AWVALID,	
input  					S3_AWREADY,	
output [`AXI_ADDR_WIDTH - 1 : 0] 	S3_AWADDR,
output [2:0]				S3_AWPROT,

output 					S3_WVALID,
input  					S3_WREADY,
output [`AXI_DATA_WIDTH - 1 : 0] 	S3_WDATA,
output [`AXI_STRB_WIDTH - 1 : 0]	S3_WSTRB,

input					S3_BVALID,
output 					S3_BREADY,
input [1:0]				S3_BRESP,

output 					S3_ARVALID,			
input					S3_ARREADY,
output [`AXI_ADDR_WIDTH - 1 : 0]	S3_ARADDR,
output [2:0]				S3_ARPROT,

input 					S3_RVALID,
output					S3_RREADY,
input [`AXI_DATA_WIDTH - 1 : 0]		S3_RDATA,
input [1:0]				S3_RRESP,

//AXI4-lite slave4 
output 					S4_AWVALID,	
input  					S4_AWREADY,	
output [`AXI_ADDR_WIDTH - 1 : 0] 	S4_AWADDR,
output [2:0]				S4_AWPROT,

output 					S4_WVALID,
input  					S4_WREADY,
output [`AXI_DATA_WIDTH - 1 : 0] 	S4_WDATA,
output [`AXI_STRB_WIDTH - 1 : 0]	S4_WSTRB,

input					S4_BVALID,
output 					S4_BREADY,
input [1:0]				S4_BRESP,

output 					S4_ARVALID,			
input					S4_ARREADY,
output [`AXI_ADDR_WIDTH - 1 : 0]	S4_ARADDR,
output [2:0]				S4_ARPROT,

input 					S4_RVALID,
output					S4_RREADY,
input [`AXI_DATA_WIDTH - 1 : 0]		S4_RDATA,
input [1:0]				S4_RRESP,

//AXI4-lite slave5 
output 					S5_AWVALID,	
input  					S5_AWREADY,	
output [`AXI_ADDR_WIDTH - 1 : 0] 	S5_AWADDR,
output [2:0]				S5_AWPROT,

output 					S5_WVALID,
input  					S5_WREADY,
output [`AXI_DATA_WIDTH - 1 : 0] 	S5_WDATA,
output [`AXI_STRB_WIDTH - 1 : 0]	S5_WSTRB,

input					S5_BVALID,
output 					S5_BREADY,
input [1:0]				S5_BRESP,

output 					S5_ARVALID,			
input					S5_ARREADY,
output [`AXI_ADDR_WIDTH - 1 : 0]	S5_ARADDR,
output [2:0]				S5_ARPROT,

input 					S5_RVALID,
output					S5_RREADY,
input [`AXI_DATA_WIDTH - 1 : 0]		S5_RDATA,
input [1:0]				S5_RRESP,


);

//AXI4-lite bus write state control
localparam WR_IDLE  = 2'b00;
localparam WR_AWVLD = 2'b01;
localparam WR_WVLD  = 2'b10;
localparam WR_BRDY  = 2'b11;

reg [1:0] wr_state, wr_next_state;

always @(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		wr_state <= IDLE;
	end
	else
	begin
		wr_state <= wr_next_state;
	end
end

always @ *
begin
	case (wr_state)
	WR_IDLE:  begin
			if(|aw_grant)
			begin
				if(aw_ready)
				wr_next_state = WR_WVLD;
				else
				wr_next_state = WR_AWVLD;
			end
			else
				wr_next_state = WR_IDLE;
	end
	WR_AWVLD: begin
		if(aw_ready)
		wr_next_state = WR_WVLD;
		else
		wr_next_state = WR_AWVLD;
	end
	WR_WVLD: begin
		if(w_ready)
		wr_next_state = WR_BRDY;
		else
		wr_next_state = WR_WVLD;
	end
	WR_BRDY: begin
		if(w_bvalid)
		wr_next_state = WR_IDLE;
		else
		wr_next_state = WR_BRDY;
	end
	default: begin
		wr_next_state = WR_IDLE;
	end
	endcase
end



//AXI4-lite arbiter for write address channel
wire aw_req_M0 = M0_AWVALID;
wire aw_req_M1 = M1_AWVALID;
wire aw_req_M2 = M2_AWVALID;

wire [2:0] aw_req = {M2_AWVALID, M1_AWVALID, M0_AWVALID};
reg  [2:0] aw_grant;
reg  [2:0] aw_grant_r;

always @ *
begin
	if(wr_state == WR_IDLE)
	begin
		casex(aw_req)
		3'b?01: begin
			aw_grant = 3'b001;
		end
		3'b?1?: begin
			aw_grant = 3'b010;
		end
		3'b100: begin
			aw_grant = 3'b100;
		end
		default: begin
			aw_grant = 3'h0;
		end
		endcase
	end
	else
	begin
		aw_grant = aw_grant_r;
	end
end

always @(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		aw_grant_r <= 3'h0;
	end
	else
	begin
		aw_grant_r <= aw_grant;
	end
end

//TODO
//write decoder

//AXI4-lite bus read state control
localparam RD_IDLE  = 2'b00;
localparam RD_ARVLD = 2'b01;
localparam RD_RRDY  = 2'b10;


wire ar_req_M0 = M0_AWVALID;
wire ar_req_M1 = M1_AWVALID;
wire ar_req_M2 = M2_AWVALID;
reg ar_grant_M0;
reg ar_grant_M1;
reg ar_grant_M2;

endmodule
