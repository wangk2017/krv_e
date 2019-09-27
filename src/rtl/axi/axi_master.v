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
// File Name: 		axi_master.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		axi master		        	|| 
// History:   							||
//                      2019/9/9 				||
//                      First version				||
//===============================================================

`include "axi_defines.vh"
module axi_master (
//AXI4-lite master memory interface
//AXI4-lite global signal
input ACLK,						//AXI clock
input ARESETn,						//AXI reset, active low

//AXI4-lite Write Address Channel
output 					AWVALID,	//write address valid
input  					AWREADY,	//
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

//master side interface
input 				cpu_clk,		//cpu clock
input 				cpu_resetn,		//cpu reset, active low
input 				M_access,		//master access signal
output				ready_M,		//ready to master
input [3:0] 			M_write_strobe,		//master write strobe
input 				M_rd0_wr1,		//master access cmd, read: 0; write: 1
input [`ADDR_WIDTH - 1 : 0]	M_addr,			//master address
input [`DATA_WIDTH - 1 : 0]	M_write_data, 		//master write data
output [`DATA_WIDTH - 1 : 0]	read_data_M, 		//master read data
output				read_data_valid_M,	//signal to master for read data valid
output [1:0]			resp_M			//response to master


);

//AXI4-lite Master FSM
localparam IDLE  = 3'b000;
localparam AWVLD = 3'b001;
localparam WVLD  = 3'b010;
localparam BRDY  = 3'b011;
localparam ARVLD = 3'b100;
localparam RRDY  = 3'b101;

reg [2:0] state, next_state;

always @(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		state <= IDLE;
	end
	else
	begin
		state <= next_state;
	end
end

always @ *
begin
	case (state)
	IDLE:  begin
		if(M_access && M_rd0_wr1)
		next_state = AWVLD;
		else if(M_access && !M_rd0_wr1)
		next_state = ARVLD;
		else
		next_state = IDLE;
	end
	AWVLD: begin
		if(AWREADY)
		next_state = WVLD;
		else
		next_state = AWVLD;
	end
	WVLD:  begin
		if(WREADY)
		next_state = BRDY;
		else
		next_state = WVLD;
	end
	BRDY:  begin
		if(BVALID)
		next_state = IDLE;
		else
		next_state = BRDY;
	end
	ARVLD: begin
		if(ARREADY)
		next_state = RRDY;
		else
		next_state = ARVLD;
	end
	RRDY:  begin
		if(RVALID)
		next_state = IDLE;
		else
		next_state = RRDY;
	end
	default: begin
	next_state = IDLE;
	end
	endcase
end

reg 					awvalid_r;
reg  [`AXI_ADDR_WIDTH - 1 : 0] 		awaddr_r;
//AWPROT is not supported
wire  [2:0]				awprot_r = 3'h0;

reg  					wvalid_r;
reg  [`AXI_DATA_WIDTH - 1 : 0] 		wdata_r;
reg  [`AXI_STRB_WIDTH - 1 : 0]		wstrb_r;

reg  					bready_r;

reg  					arvalid_r;	
reg  [`AXI_ADDR_WIDTH - 1 : 0]		araddr_r;
//AWPROT is not supported
wire  [2:0]				arprot_r = 3'h0;

reg 					rready_r;

always @(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		awvalid_r <= 1'b0;
		awaddr_r  <= {`AXI_ADDR_WIDTH{1'b0}};
		wvalid_r  <= 1'b0;
		wdata_r	  <= {`AXI_DATA_WIDTH{1'b0}};
		wstrb_r   <= {`AXI_STRB_WIDTH{1'b0}};
		bready_r  <= 1'b1;
		arvalid_r <= 1'b0;
		araddr_r  <= {`AXI_ADDR_WIDTH{1'b0}};
		rready_r  <= 1'b1;
	end
	else
	begin
		case(next_state)
		IDLE:begin
			awvalid_r <= 1'b0;
			awaddr_r  <= {`AXI_ADDR_WIDTH{1'b0}};
			wvalid_r  <= 1'b0;
			wdata_r	  <= {`AXI_DATA_WIDTH{1'b0}};
			wstrb_r   <= {`AXI_STRB_WIDTH{1'b0}};
			bready_r  <= 1'b1;
			arvalid_r <= 1'b0;
			araddr_r  <= {`AXI_ADDR_WIDTH{1'b0}};
			rready_r  <= 1'b1;
		end
		AWVLD: begin
			awvalid_r <= 1'b1;
			awaddr_r  <= M_addr;
		end
		WVLD:  begin
			awvalid_r <= 1'b0;
			wvalid_r  <= 1'b1;
			wdata_r   <= M_write_data;
			wstrb_r   <= M_write_strobe;
		end
		BRDY:  begin
			wvalid_r  <= 1'b0;
			bready_r  <= 1'b1;
		end
		ARVLD: begin
			arvalid_r <= 1'b1;
			araddr_r  <= M_addr;
		end
		RRDY:  begin
			arvalid_r <= 1'b0;
			rready_r  <= 1'b1;
		end
		default: begin
			awvalid_r <= 1'b0;
			awaddr_r  <= {`AXI_ADDR_WIDTH{1'b0}};
			wvalid_r  <= 1'b0;
			wdata_r	  <= {`AXI_DATA_WIDTH{1'b0}};
			wstrb_r   <= {`AXI_STRB_WIDTH{1'b0}};
			bready_r  <= 1'b1;
			arvalid_r <= 1'b0;
			araddr_r  <= {`AXI_ADDR_WIDTH{1'b0}};
			rready_r  <= 1'b1;
		end
		endcase
	end
end

assign AWVALID 	= awvalid_r;
assign AWADDR	= awaddr_r;
assign AWPROT	= awprot_r;
assign WVALID	= wvalid_r;
assign WDATA	= wdata_r;
assign WSTRB	= wstrb_r;
assign BREADY	= bready_r;
assign ARVALID	= arvalid_r;			
assign ARADDR	= araddr_r;
assign ARPROT	= arprot_r;
assign RREADY	= rready_r;

assign ready_M = (next_state == IDLE);
assign resp_M = ((state == RRDY) && RVALID) ? RRESP : (((state == BRDY) && BVALID) ? BRESP: 2'h0);
assign read_data_M = (state == RRDY) && RVALID ? RDATA : {`AXI_DATA_WIDTH{1'b0}};
assign read_data_valid_M = (state == RRDY) && RVALID;



endmodule
