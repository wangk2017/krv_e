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
// File Name: 		uart.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		UART 				    	|| 
// History:   		2019.04.25				||
//                      First version				||
//===============================================================

`include "top_defines.vh"

// uart
module uart(
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


// UART signals
input        RX,
output       TX,
output       UART_INT
);
//--------------------------------------------------------------------
// wires
//--------------------------------------------------------------------
wire 		tx_data_reg_wr;
wire [7:0] 	tx_data;
wire [7:0] 	rx_data;
wire [12:0] 	baud_val;
wire  		data_bits;
wire 		parity_en;
wire 		parity_odd0_even1;
wire 		rx_ready;
wire 		tx_ready;
wire 		parity_err;
wire 		overflow;
wire 		tx_baud_pulse;	
wire 		rx_sample_pulse;	


//UART registers
uart_regs u_uart_regs (
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
.tx_data_reg_wr			(tx_data_reg_wr		),
.tx_data			(tx_data		),
.rx_data			(rx_data		),
.baud_val			(baud_val		),
.data_bits			(data_bits		),
.parity_en			(parity_en		),
.parity_odd0_even1		(parity_odd0_even1	),
.rx_ready			(rx_ready		),
.tx_ready			(tx_ready		),
.parity_err			(parity_err		),
.overflow			(overflow		)
);


//UART baud clock generator
baud_clk_gen u_baud_clk_gen (
.ACLK				(ACLK		),
.ARESETn			(ARESETn	),
.baud_val			(baud_val	),
.tx_baud_pulse			(tx_baud_pulse	),
.rx_sample_pulse		(rx_sample_pulse)
);

//UART transmit control block
uart_tx u_uart_tx (
.ACLK				(ACLK		),
.ARESETn			(ARESETn	),
.tx_baud_pulse			(tx_baud_pulse	),
.tx_data_reg_wr			(tx_data_reg_wr		),
.tx_data			(tx_data		),
.data_bits			(data_bits		),
.parity_en			(parity_en		),
.parity_odd0_even1		(parity_odd0_even1	),
.UART_TX			(TX			),
.tx_ready			(tx_ready		)
);

//UART receive control block
uart_rx u_uart_rx (
);

endmodule
