//===============================================================||
// File Name: 		core_timer.v				 ||
// Author:    		Kitty Wang				 ||
// Description:   						 ||
//	      		KRV-m core timer			 ||
// History:   							 ||
//===============================================================||

`include "top_defines.vh"

module core_timer (
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


//core timer signals
output wire core_timer_int				//interrupt notification to core

);

//AXI4-lite slave interface
wire [`AXI_DATA_WIDTH - 1 : 0] 	ip_read_data;
wire 				ip_read_data_valid;
wire [`AXI_ADDR_WIDTH - 1 : 0] 	ip_addr;
wire [`AXI_DATA_WIDTH - 1 : 0] 	ip_write_data;
wire [3:0] 			ip_byte_strobe;
wire 				valid_reg_write;
wire 				valid_reg_read;

axi_slave axi_slave_kplic(
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



 core_timer_regs u_core_timer_regs(
.ACLK			(ACLK),
.ARESETn		(ARESETn),
.addr			(ip_addr[15:0]),
.valid_reg_write	(valid_reg_write	),
.valid_reg_read		(valid_reg_read		),
.write_data		(ip_write_data),
.read_data		(ip_read_data),
.read_data_valid	(ip_read_data_valid),
.timer_int		(core_timer_int)
);


endmodule
