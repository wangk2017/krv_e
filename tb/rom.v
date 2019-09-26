//==============================================================||
// File Name: 		dmem.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		data memory                       	|| 
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//===============================================================
`include "top_defines.vh"
module flash_sim(
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
output [1:0]				RRESP
);

reg [`AHB_DATA_WIDTH - 1 : 0] mem [81919:0];
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


wire [19:2] HADDR_wr = ip_addr[19:2];


always @ (posedge ACLK)
begin
	if(valid_reg_write)
	begin
		if(ip_byte_strobe[3])
		 	mem[HADDR_wr][31:24] <= ip_write_data[31:24];
		if(ip_byte_strobe[2])
		 	mem[HADDR_wr][23:16] <= ip_write_data[23:16];
		if(ip_byte_strobe[1])
			mem[HADDR_wr][15:8] <= ip_write_data[15:8];
		if(ip_byte_strobe[0])
			mem[HADDR_wr][7:0] <= ip_write_data[7:0];
	end
end


wire [19:2] HADDR_rd = ip_addr[19:2];

assign ip_read_data = valid_reg_read ? mem[HADDR_rd] : 32'h0;
assign ip_read_data_valid = valid_reg_read;

endmodule
