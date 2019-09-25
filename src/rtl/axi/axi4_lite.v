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
// File Name: 		axi4_lite.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		axi4 lite bus 			    	|| 
// History:   							||
//                      2019/9/16				||
//                      First version				||
//			2019/9/25				||
//			rename the module to axi4_lite		||
//===============================================================

`include "axi_defines.vh"
module axi4_lite (
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
output  				S1_AWVALID,	
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

//------------------------------------------------//
//separate read/write buses are provided
//------------------------------------------------//
//---------------------------------//
//AXI4-lite bus write
//---------------------------------//
//signals declaration

wire awvalid;
wire aw_ready;
wire wvalid;
wire w_ready;
wire bready;
wire b_valid;
wire[1:0] b_resp;
reg  [1:0] aw_grant_i;
reg  [1:0] aw_grant_r;
wire wr_idle;

//--------------------------------------------------------------------//
//add a wr_timeout counter to avoid bus lock 
//--------------------------------------------------------------------//
parameter TIMEOUT = 15;
reg[3:0] wr_timeout_cnt;
wire wr_timeout = (wr_timeout_cnt == TIMEOUT);

always @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		wr_timeout_cnt <= 4'h0;
	end
	else
	begin
		if(wr_timeout)
		begin
			wr_timeout_cnt <= 4'h0;
		end
		else if(!wr_idle)
		begin
			wr_timeout_cnt <= wr_timeout_cnt + 4'h1
		end
		else 
		begin
			wr_timeout_cnt <= 4'h0;
		end
	end
end


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
		wr_state <= WR_IDLE;
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
		if(wr_timeout)
		wr_next_state = WR_IDLE;
		else if(aw_ready && awvalid)
		wr_next_state = WR_WVLD;
		else
		wr_next_state = WR_AWVLD;
	end
	WR_WVLD: begin
		if(wr_timeout)
		wr_next_state = WR_IDLE;
		else if(w_ready && wvalid)
		wr_next_state = WR_BRDY;
		else
		wr_next_state = WR_WVLD;
	end
	WR_BRDY: begin
		if(wr_timeout)
		wr_next_state = WR_IDLE;
		else if(w_bvalid && bready)
		wr_next_state = WR_IDLE;
		else
		wr_next_state = WR_BRDY;
	end
	default: begin
		wr_next_state = WR_IDLE;
	end
	endcase
end

assign wr_idle = (wr_state == WR_IDLE);

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

//Obtain the granted master write valid
wire  m_awvalid[2:0];
assign m_awvalid[2] = M2_AWVALID;
assign m_awvalid[1] = M1_AWVALID;
assign m_awvalid[0] = M0_AWVALID;
assign awvalid = m_awvalid[aw_grant];

//Obtain the granted master write address
wire [`AXI_ADDR_WIDTH - 1 : 0] m_awaddr[2:0];
assign m_awaddr[2] = M2_AWADDR;
assign m_awaddr[1] = M1_AWADDR;
assign m_awaddr[0] = M0_AWADDR;
wire [`AXI_ADDR_WIDTH - 1 : 0] 	awaddr = m_awaddr[aw_grant];

//Obtain the granted master write valid
wire  m_wvalid[2:0];
assign m_wvalid[2] = M2_WVALID;
assign m_wvalid[1] = M1_WVALID;
assign m_wvalid[0] = M0_WVALID;
assign wvalid = m_wvalid[aw_grant];

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
wire m_bready[2:0];
assign m_bready[2] = M2_BREADY;
assign m_bready[1] = M1_BREADY;
assign m_bready[0] = M0_BREADY;
assign bready = m_bready[aw_grant];


//assign the selected slave signals to the granted master
reg m_awready [2:0];
reg m_wready [2:0];
reg m_bvalid [2:0];
reg [1:0] m_bresp [2:0];

integer k;

always @ *
begin
	for (k=0; k<3; k=k+1)
	begin
		if(k==aw_grant)
		begin
			m_awready[k] = aw_ready;
			m_wready[k]  = w_ready;
			m_bvalid[k]  = b_valid;
			m_bresp[k]   = b_resp;
		end //if(k==aw_grant)
		else
		begin
			m_awready[k] = 1'b0;
			m_wready[k]  = 1'b0;
			m_bvalid[k]  = 1'b0;
			m_bresp[k]   = 2'b00;
		end //else
	end //for
end



//AWREADY
assign M0_AWREADY = m_awready[0];
assign M1_AWREADY = m_awready[1];
assign M2_AWREADY = m_awready[2];

//WREADY
assign M0_WREADY = m_wready[0];
assign M1_WREADY = m_wready[1];
assign M2_WREADY = m_wready[2];

//BVALID
assign M0_BVALID = m_bvalid[0];
assign M1_BVALID = m_bvalid[1];
assign M2_BVALID = m_bvalid[2];

//BRESP
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

//Assign the granted master signals to selected slave
reg  s_awvalid[5:0];
reg [`AXI_ADDR_WIDTH - 1 : 0] s_awaddr[5:0];
reg  s_wvalid[5:0];
reg [`AXI_DATA_WIDTH - 1 : 0] s_wdata[5:0];
reg [`AXI_STRB_WIDTH - 1 : 0] s_wstrb[5:0];
reg  s_bready[5:0];

integer i;

always @*
begin
	for (i=0; i<6; i=i+1)
	begin
		if(i==wr_slave_no)
		begin
			s_awvalid[i] = awvalid;
			s_awaddr[i]  = awaddr;
			s_wvalid[i]  = wvalid;
			s_wdata[i]   = wdata;
			s_wstrb[i]   = wstrb;
			s_bready[i]  = bready;
		end
		else
		begin
			s_awvalid[i] = 1'b0;
			s_awaddr[i]  = {`AXI_ADDR_WIDTH{1'b0}};
			s_wvalid[i]  = 1'b0;
			s_wdata[i]   = {`AXI_DATA_WIDTH{1'b0}};
			s_wstrb[i]   = {`AXI_STRB_WIDTH{1'b0}};
			s_bready[i]  = 1'b0;
		end
	end
end

//AWVALID
assign S0_AWVALID = s_awvalid[0];
assign S1_AWVALID = s_awvalid[1];
assign S2_AWVALID = s_awvalid[2];
assign S3_AWVALID = s_awvalid[3];
assign S4_AWVALID = s_awvalid[4];
assign S5_AWVALID = s_awvalid[5];


//AWADDR
assign S0_AWADDR = s_awaddr[0];
assign S1_AWADDR = s_awaddr[1];
assign S2_AWADDR = s_awaddr[2];
assign S3_AWADDR = s_awaddr[3];
assign S4_AWADDR = s_awaddr[4];
assign S5_AWADDR = s_awaddr[5];

//WVALID
assign S0_WVALID = s_wvalid[0];
assign S1_WVALID = s_wvalid[1];
assign S2_WVALID = s_wvalid[2];
assign S3_WVALID = s_wvalid[3];
assign S4_WVALID = s_wvalid[4];
assign S5_WVALID = s_wvalid[5];

//WDATA
assign S0_WDATA = s_wdata[0];
assign S1_WDATA = s_wdata[1];
assign S2_WDATA = s_wdata[2];
assign S3_WDATA = s_wdata[3];
assign S4_WDATA = s_wdata[4];
assign S5_WDATA = s_wdata[5];

//WSTRB
assign S0_WSTRB = s_wstrb[0];
assign S1_WSTRB = s_wstrb[1];
assign S2_WSTRB = s_wstrb[2];
assign S3_WSTRB = s_wstrb[3];
assign S4_WSTRB = s_wstrb[4];
assign S5_WSTRB = s_wstrb[5];

//BREADY
assign S0_BREADY = s_bready[0];
assign S1_BREADY = s_bready[1];
assign S2_BREADY = s_bready[2];
assign S3_BREADY = s_bready[3];
assign S4_BREADY = s_bready[4];
assign S5_BREADY = s_bready[5];


//---------------------------------//
//AXI4-lite read bus
//---------------------------------//
//Signals declaration
wire arvalid;
wire ar_ready;
wire rready;
wire r_valid;
wire[`AXI_DATA_WIDTH - 1 : 0] r_data;
wire[1:0] r_resp;

reg  [1:0] ar_grant_i;
reg  [1:0] ar_grant_r;
wire rd_idle;

//--------------------------------------------------------------------//
//add a rd_timeout counter to avoid bus lock 
//--------------------------------------------------------------------//
parameter TIMEOUT = 15;
reg[3:0] rd_timeout_cnt;
wire rd_timeout = (rd_timeout_cnt == TIMEOUT);

always @ (posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		rd_timeout_cnt <= 4'h0;
	end
	else
	begin
		if(rd_timeout)
		begin
			rd_timeout_cnt <= 4'h0;
		end
		else if(!rd_idle)
		begin
			rd_timeout_cnt <= rd_timeout_cnt + 4'h1
		end
		else 
		begin
			rd_timeout_cnt <= 4'h0;
		end
	end
end


localparam RD_IDLE  = 2'b00;
localparam RD_ARVLD = 2'b01;
localparam RD_RRDY  = 2'b10;


reg [1:0] rd_state, rd_next_state;

always @(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		rd_state <= RD_IDLE;
	end
	else
	begin
		rd_state <= rd_next_state;
	end
end

always @ *
begin
	case (rd_state)
	RD_IDLE:  begin
			if(|ar_grant_i)
			begin
				if(ar_ready)
				rd_next_state = RD_RRDY;
				else
				rd_next_state = RD_ARVLD;
			end
			else
				rd_next_state = RD_IDLE;
	end
	RD_ARVLD: begin
		if(rd_timeout)
		rd_next_state = RD_IDLE;
		else if(ar_ready && arvalid)
		rd_next_state = RD_RRDY;
		else
		rd_next_state = RD_ARVLD;
	end
	RD_RRDY: begin
		if(rd_timeout)
		rd_next_state = RD_IDLE;
		else if(r_valid && rready)
		rd_next_state = RD_IDLE;
		else
		rd_next_state = RD_RRDY;
	end
	default: begin
		rd_next_state = RD_IDLE;
	end
	endcase
end

assign rd_idle = (rd_state == RD_IDLE);


wire [2:0] ar_req = {M2_ARVALID, M1_ARVALID, M0_ARVALID};

always @ *
begin
	if(rd_idle)
	begin
		casex(ar_req)
		3'b?01: begin
			ar_grant_i = 2'b00;
		end
		3'b?1?: begin
			ar_grant_i = 2'b01;
		end
		3'b100: begin
			ar_grant_i = 2'b10;
		end
		default: begin
			ar_grant_i = 2'b11;
		end
		endcase
	end
	else
	begin
		ar_grant_i = ar_grant_r;
	end
end

always @(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		ar_grant_r <= 2'b11;
	end
	else
	begin
		ar_grant_r <= ar_grant_i;
	end
end

wire [1:0] ar_grant = rd_idle ? ar_grant_i : ar_grant_r;

//Obtain the granted master read valid
wire  m_arvalid[2:0];
assign m_arvalid[2] = M2_ARVALID;
assign m_arvalid[1] = M1_ARVALID;
assign m_arvalid[0] = M0_ARVALID;
assign arvalid = m_arvalid[ar_grant];

//Obtain the granted master read address
wire [`AXI_ADDR_WIDTH - 1 : 0] m_araddr[2:0];
assign m_araddr[2] = M2_ARADDR;
assign m_araddr[1] = M1_ARADDR;
assign m_araddr[0] = M0_ARADDR;
wire [`AXI_ADDR_WIDTH - 1 : 0] 	araddr = m_araddr[ar_grant];

//Obtain the granted master rready
wire m_rready[2:0];
assign m_rready[2] = M2_RREADY;
assign m_rready[1] = M1_RREADY;
assign m_rready[0] = M0_RREADY;
assign rready = m_rready[ar_grant];



//assign the selected slave signals to the granted master
reg m_arready [2:0];
reg m_rvalid [2:0];
reg [`AXI_DATA_WIDTH - 1 : 0] m_rdata [2:0];
reg [1 : 0] m_rresp [2:0];

integer j;

always @ *
begin
	for (j=0; j<3; j=j+1)
	begin
		if(j==ar_grant)
		begin
			m_arready[j] = ar_ready;
			m_rvalid[j]  = r_valid;
			m_rdata[j]   = r_data;
			m_rresp[j]   = r_resp;
		end //if(j==ar_grant)
		else
		begin
			m_arready[j] = 1'b0;
			m_rvalid[j]  = 1'b0;
			m_rdata[j]   = {`AXI_DATA_WIDTH{1'b0}};
			m_rdata[j]   = 2'b00;
		end //else
	end //for
end



//ARREADY
assign M0_ARREADY = m_arready[0];
assign M1_ARREADY = m_arready[1];
assign M2_ARREADY = m_arready[2];

//RVALID
assign M0_RVALID = m_rvalid[0];
assign M1_RVALID = m_rvalid[1];
assign M2_RVALID = m_rvalid[2];

//RDATA
assign M0_RDATA = m_rdata[0];
assign M1_RDATA = m_rdata[1];
assign M2_RDATA = m_rdata[2];

//RRESP
assign M0_RRESP = m_rresp[0];
assign M1_RRESP = m_rresp[1];
assign M2_RRESP = m_rresp[2];




wire [2:0] rd_slave_no;

//read address decoder
axi_decoder rdaddr_dec(
.addr		(araddr),
.slave_no	(rd_slave_no)
);

//Obtain the slave arready for master read
wire s_arready [5:0];
assign s_arready[5] = S5_ARREADY;
assign s_arready[4] = S4_ARREADY;
assign s_arready[3] = S3_ARREADY;
assign s_arready[2] = S2_ARREADY;
assign s_arready[1] = S1_ARREADY;
assign s_arready[0] = S0_ARREADY;

assign ar_ready = s_arready[rd_slave_no];


//Obtain the slave rvalid for master read
wire s_rvalid [5:0];
assign s_rvalid[5] = S5_RVALID;
assign s_rvalid[4] = S4_RVALID;
assign s_rvalid[3] = S3_RVALID;
assign s_rvalid[2] = S2_RVALID;
assign s_rvalid[1] = S1_RVALID;
assign s_rvalid[0] = S0_RVALID;

assign r_valid = s_rvalid[rd_slave_no];

//Obtain the slave rdata for master read
wire[`AXI_DATA_WIDTH - 1 : 0] s_rdata [5:0];
assign s_rdata[5] = S5_RDATA;
assign s_rdata[4] = S4_RDATA;
assign s_rdata[3] = S3_RDATA;
assign s_rdata[2] = S2_RDATA;
assign s_rdata[1] = S1_RDATA;
assign s_rdata[0] = S0_RDATA;

assign r_data = s_rdata[rd_slave_no];

//Assign the granted master signals to selected slave
reg  s_arvalid[5:0];
reg [`AXI_ADDR_WIDTH - 1 : 0] s_araddr[5:0];
reg  s_rready[5:0];

always @*
begin
	for (i=0; i<6; i=i+1)
	begin
		if(i==rd_slave_no)
		begin
			s_arvalid[i] = arvalid;
			s_araddr[i]  = araddr;
			s_rready[i]  = rready;
		end
		else
		begin
			s_arvalid[i] = 1'b0;
			s_araddr[i]  = {`AXI_ADDR_WIDTH{1'b0}};
			s_rready[i]  = 1'b0;
		end
	end
end

//ARVALID
assign S0_ARVALID = s_arvalid[0];
assign S1_ARVALID = s_arvalid[1];
assign S2_ARVALID = s_arvalid[2];
assign S3_ARVALID = s_arvalid[3];
assign S4_ARVALID = s_arvalid[4];
assign S5_ARVALID = s_arvalid[5];


//ARADDR
assign S0_ARADDR = s_araddr[0];
assign S1_ARADDR = s_araddr[1];
assign S2_ARADDR = s_araddr[2];
assign S3_ARADDR = s_araddr[3];
assign S4_ARADDR = s_araddr[4];
assign S5_ARADDR = s_araddr[5];

//RREADY
assign S0_RREADY = s_rready[0];
assign S1_RREADY = s_rready[1];
assign S2_RREADY = s_rready[2];
assign S3_RREADY = s_rready[3];
assign S4_RREADY = s_rready[4];
assign S5_RREADY = s_rready[5];



endmodule
