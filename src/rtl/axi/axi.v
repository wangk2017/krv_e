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
output  reg				M0_AWREADY,	
input [`AXI_ADDR_WIDTH - 1 : 0] 	M0_AWADDR,
input [2:0]				M0_AWPROT,

input 					M0_WVALID,
output  reg				M0_WREADY,
input [`AXI_DATA_WIDTH - 1 : 0] 	M0_WDATA,
input [`AXI_STRB_WIDTH - 1 : 0]		M0_WSTRB,

output					M0_BVALID,
input 					M0_BREADY,
output [1:0]				M0_BRESP,

input 					M0_ARVALID,			
output	reg				M0_ARREADY,
input [`AXI_ADDR_WIDTH - 1 : 0]		M0_ARADDR,
input [2:0]				M0_ARPROT,

output 					M0_RVALID,
input					M0_RREADY,
output [`AXI_DATA_WIDTH - 1 : 0]	M0_RDATA,
output [1:0]				M0_RRESP,

//AXI4-lite master1 
input 					M1_AWVALID,	
output  reg				M1_AWREADY,	
input [`AXI_ADDR_WIDTH - 1 : 0] 	M1_AWADDR,
input [2:0]				M1_AWPROT,

input 					M1_WVALID,
output  reg				M1_WREADY,
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
output  reg				M2_AWREADY,	
input [`AXI_ADDR_WIDTH - 1 : 0] 	M2_AWADDR,
input [2:0]				M2_AWPROT,

input 					M2_WVALID,
output  reg				M2_WREADY,
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
output reg				S0_AWVALID,	
input  					S0_AWREADY,	
output reg[`AXI_ADDR_WIDTH - 1 : 0] 	S0_AWADDR,
output reg[2:0]				S0_AWPROT,

output reg				S0_WVALID,
input  					S0_WREADY,
output reg[`AXI_DATA_WIDTH - 1 : 0] 	S0_WDATA,
output reg[`AXI_STRB_WIDTH - 1 : 0]	S0_WSTRB,

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
output reg 				S1_AWVALID,	
input  					S1_AWREADY,	
output reg[`AXI_ADDR_WIDTH - 1 : 0] 	S1_AWADDR,
output reg[2:0]				S1_AWPROT,

output reg				S1_WVALID,
input  					S1_WREADY,
output reg[`AXI_DATA_WIDTH - 1 : 0] 	S1_WDATA,
output reg[`AXI_STRB_WIDTH - 1 : 0]	S1_WSTRB,

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
output reg				S2_AWVALID,	
input  					S2_AWREADY,	
output reg[`AXI_ADDR_WIDTH - 1 : 0] 	S2_AWADDR,
output reg[2:0]				S2_AWPROT,

output reg				S2_WVALID,
input  					S2_WREADY,
output reg[`AXI_DATA_WIDTH - 1 : 0] 	S2_WDATA,
output reg[`AXI_STRB_WIDTH - 1 : 0]	S2_WSTRB,

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


//internal signals declaration

reg aw_ready;
reg w_ready;
reg b_valid;
reg[1:0] b_resp;
reg  [1:0] aw_grant_i;
reg  [1:0] aw_grant_r;

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
			if(|aw_grant_i)
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

wire wr_idle = (wr_state == WR_IDLE);

//AXI4-lite arbiter for write address channel
wire aw_req_M0 = M0_AWVALID;
wire aw_req_M1 = M1_AWVALID;
wire aw_req_M2 = M2_AWVALID;

wire [2:0] aw_req = {M2_AWVALID, M1_AWVALID, M0_AWVALID};

always @ *
begin
	if(wr_idle)
	begin
		casex(aw_req)
		3'b?01: begin
			aw_grant_i = 2'b00;
		end
		3'b?1?: begin
			aw_grant_i = 2'b01;
		end
		3'b100: begin
			aw_grant_i = 2'b10;
		end
		default: begin
			aw_grant_i = 2'b11;
		end
		endcase
	end
	else
	begin
		aw_grant_i = aw_grant_r;
	end
end

always @(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		aw_grant_r <= 2'b11;
	end
	else
	begin
		aw_grant_r <= aw_grant_i;
	end
end

wire [1:0] aw_grant = wr_idle ? aw_grant_i : aw_grant_r;

//Obtain the granted master write address
wire [`AXI_ADDR_WIDTH - 1 : 0] m_awaddr[2:0];
assign m_awaddr[2] = M2_AWADDR;
assign m_awaddr[1] = M1_AWADDR;
assign m_awaddr[0] = M0_AWADDR;
wire [`AXI_ADDR_WIDTH - 1 : 0] 	awaddr = m_awaddr[aw_grant];

//Obtain the granted master write data
wire [`AXI_DATA_WIDTH - 1 : 0] 	m_wdata[2:0];
assign m_wdata[2] = M2_WDATA;
assign m_wdata[1] = M1_WDATA;
assign m_wdata[0] = M0_WDATA;
wire [`AXI_DATA_WIDTH - 1 : 0] 	wdata = m_wdata[aw_grant];


//Obtain the granted master write strobe
wire [`AXI_STRB_WIDTH - 1 : 0]	m_wstrb[2:0];
assign m_wstrb[2] = M2_WSTRB;
assign m_wstrb[1] = M1_WSTRB;
assign m_wstrb[0] = M0_WSTRB;
wire [`AXI_STRB_WIDTH - 1 : 0]	wstrb = m_wstrb[aw_grant];

//Obtain the granted master bready
wire [`AXI_STRB_WIDTH - 1 : 0]	m_bready[2:0];
assign m_bready[2] = M2_BREADY;
assign m_bready[1] = M1_BREADY;
assign m_bready[0] = M0_BREADY;
wire [`AXI_STRB_WIDTH - 1 : 0]	bready = m_bready[aw_grant];


//assign the awready to the granted master
wire m_awready [2:0];
assign m_awready[aw_grant] = aw_ready;
assign M0_AWREADY = m_awready[0];
assign M1_AWREADY = m_awready[1];
assign M2_AWREADY = m_awready[2];

//assign the wready to the granted master
wire m_wready [2:0];
assign m_wready[aw_grant] = w_ready;
assign M0_WREADY = m_wready[0];
assign M1_WREADY = m_wready[1];
assign M2_WREADY = m_wready[2];

//assign the bvalid to the granted master
wire m_bvalid [2:0];
assign m_bvalid[aw_grant] = b_valid;
assign M0_BVALID = m_bvalid[0];
assign M1_BVALID = m_bvalid[1];
assign M2_BVALID = m_bvalid[2];

//assign the bresp to the granted master
wire m_bresp [2:0];
assign m_bresp[aw_grant] = b_resp;
assign M0_BRESP = m_bresp[0];
assign M1_BRESP = m_bresp[1];
assign M2_BRESP = m_bresp[2];



wire [2:0] wr_slave_no;

//write address decoder
axi_decoder wraddr_dec(
.addr		(awaddr),
.slave_no	(wr_slave_no)
);

//Obtain the slave awready for master write
wire s_awready [5:0];
assign s_awready[5] = S5_AWREADY;
assign s_awready[4] = S4_AWREADY;
assign s_awready[3] = S3_AWREADY;
assign s_awready[2] = S2_AWREADY;
assign s_awready[1] = S1_AWREADY;
assign s_awready[0] = S0_AWREADY;

assign aw_ready = s_awready[wr_slave_no];

//Obtain the slave wready for master write
wire s_wready [5:0];
assign s_wready[5] = S5_WREADY;
assign s_wready[4] = S4_WREADY;
assign s_wready[3] = S3_WREADY;
assign s_wready[2] = S2_WREADY;
assign s_wready[1] = S1_WREADY;
assign s_wready[0] = S0_WREADY;

assign w_ready = s_wready[wr_slave_no];

//Obtain the slave bvalid for master write
wire s_bvalid [5:0];
assign s_bvalid[5] = S5_BVALID;
assign s_bvalid[4] = S4_BVALID;
assign s_bvalid[3] = S3_BVALID;
assign s_bvalid[2] = S2_BVALID;
assign s_bvalid[1] = S1_BVALID;
assign s_bvalid[0] = S0_BVALID;

assign b_valid = s_bvalid[wr_slave_no];

//Obtain the slave bresp for master write
wire[1:0] s_bresp [5:0];
assign s_bresp[5] = S5_BRESP;
assign s_bresp[4] = S4_BRESP;
assign s_bresp[3] = S3_BRESP;
assign s_bresp[2] = S2_BRESP;
assign s_bresp[1] = S1_BRESP;
assign s_bresp[0] = S0_BRESP;

assign b_resp = s_bresp[wr_slave_no];

//Assign the granted master awaddr to selected slave
wire [`AXI_ADDR_WIDTH - 1 : 0] s_awaddr[5:0];
assign s_awaddr[wr_slave_no] = awaddr;
assign S0_AWADDR = s_awaddr[0];
assign S1_AWADDR = s_awaddr[1];
assign S2_AWADDR = s_awaddr[2];
assign S3_AWADDR = s_awaddr[3];
assign S4_AWADDR = s_awaddr[4];
assign S5_AWADDR = s_awaddr[5];


//Assign the granted master wdata to selected slave
wire [`AXI_ADDR_WIDTH - 1 : 0] s_wdata[5:0];
assign s_wdata[wr_slave_no] = wdata;
assign S0_WDATA = s_wdata[0];
assign S1_WDATA = s_wdata[1];
assign S2_WDATA = s_wdata[2];
assign S3_WDATA = s_wdata[3];
assign S4_WDATA = s_wdata[4];
assign S5_WDATA = s_wdata[5];


//Assign the granted master wstrb to selected slave
wire [`AXI_ADDR_WIDTH - 1 : 0] s_wstrb[5:0];
assign s_wstrb[wr_slave_no] = wstrb;
assign S0_WSTRB = s_wstrb[0];
assign S1_WSTRB = s_wstrb[1];
assign S2_WSTRB = s_wstrb[2];
assign S3_WSTRB = s_wstrb[3];
assign S4_WSTRB = s_wstrb[4];
assign S5_WSTRB = s_wstrb[5];


//Assign the granted master bready to selected slave
wire [`AXI_ADDR_WIDTH - 1 : 0] s_bready[5:0];
assign s_bready[wr_slave_no] = bready;
assign S0_BREADY = s_bready[0];
assign S1_BREADY = s_bready[1];
assign S2_BREADY = s_bready[2];
assign S3_BREADY = s_bready[3];
assign S4_BREADY = s_bready[4];
assign S5_BREADY = s_bready[5];



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
