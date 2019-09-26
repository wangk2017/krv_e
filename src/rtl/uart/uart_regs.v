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
// File Name: 		uart_regs.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		UART registers			    	|| 
// History:   		2019.04.25				||
//                      First version				||
//			2019.09.26				||
//			Use AXI4-lite to replace APB		||
//===============================================================

module uart_regs(
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

//registers 
output  	tx_data_reg_wr,
output [7:0] 	tx_data,
output [12:0] 	baud_val,
output  	data_bits,
output 		parity_en,
output 		parity_odd0_even1,
input  [7:0] 	rx_data,
input 		rx_ready,
input 		tx_ready,
input 		parity_err,
input 		overflow
);


//AXI4-lite slave interface
wire [`AHB_DATA_WIDTH - 1 : 0] 	ip_read_data;
wire 				ip_read_data_valid;
wire [`AHB_ADDR_WIDTH - 1 : 0] 	ip_addr;
wire [`AHB_DATA_WIDTH - 1 : 0] 	ip_write_data;
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


//------------------------------------------------------
//registers offset
//------------------------------------------------------
`define TX_DATA_REG_OFFSET 3'h0
`define RX_DATA_REG_OFFSET 3'h1
`define CONFIG1_REG_OFFSET 3'h2
`define CONFIG2_REG_OFFSET 3'h3
`define STATUS_REG_OFFSET 3'h4


//------------------------------------------------------
//signals 
//------------------------------------------------------

reg  [7:0] 	config1_reg;
reg  [7:0] 	config2_reg;

assign  tx_data = ip_write_data;
assign 	baud_val = {config2_reg[7:3],config1_reg};
assign 	data_bits = config2_reg[0];
assign  parity_en = config2_reg[1];
assign  parity_odd0_even1 = config2_reg[2];


//tx_data reg(fifo) is maintained in uart_tx block
wire tx_data_reg_sel = ip_addr[4:2] == `TX_DATA_REG_OFFSET;
assign tx_data_reg_wr = valid_reg_write && tx_data_reg_sel;
wire [7:0] tx_data_read_data = 8'h0;

//rx_data reg is maintained in uart_rx block
wire rx_data_reg_sel = ip_addr[4:2] == `RX_DATA_REG_OFFSET;
wire [7:0] rx_data_read_data = rx_data_reg_sel ? rx_data : 8'h0;

//config1_reg
wire config1_reg_sel = ip_addr[4:2] == `CONFIG1_REG_OFFSET;
wire config1_reg_wr = valid_reg_write && config1_reg_sel;
always@(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		config1_reg <= 8'h0;
	end
	else
	begin
		if(config1_reg_wr)
		begin
			config1_reg <= ip_write_data;
		end
		else
		begin
			config1_reg <= config1_reg;
		end
	end
end

wire [7:0] config1_read_data = config1_reg_sel ? config1_reg : 8'h0;

//config2_reg
wire config2_reg_sel = ip_addr[4:2] == `CONFIG2_REG_OFFSET;
wire config2_reg_wr = valid_reg_write && config2_reg_sel;
always@(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		config2_reg <= 8'h0;
	end
	else
	begin
		if(config2_reg_wr)
		begin
			config2_reg <= ip_write_data;
		end
		else
		begin
			config2_reg <= config2_reg;
		end
	end
end

wire [7:0] config2_read_data = config2_reg_sel ? config2_reg : 8'h0;

//status_reg
wire status_reg = {4'b0,overflow,parity_err,rx_ready,tx_ready};
wire status_reg_sel = ip_addr[4:2] == `STATUS_REG_OFFSET;
wire [7:0] status_read_data = status_reg_sel ? status_reg : 8'h0;


wire [7:0] Nxtip_read_data = {8{valid_reg_read}} & 
			(tx_data_read_data 	|
			 rx_data_read_data	|
			 config1_read_data	|
			 config2_read_data	|
			 status_read_data	
			);
reg [7:0] iip_read_data;
reg iip_read_data_valid;

always@(posedge ACLK or negedge ARESETn)
begin
	if(!ARESETn)
	begin
		iip_read_data <= 8'h0;
		iip_read_data_valid <= 1'b0;
	end
	else
	begin
		iip_read_data <= Nxtip_read_data;
		iip_read_data_valid <= valid_reg_read;
	end
end

assign ip_read_data = iip_read_data;
assign ip_read_data_valid = iip_read_data_valid;

endmodule


