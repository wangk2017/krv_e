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
// File Name: 		krv_e.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		top of krv-e			     	|| 
// History:   							||
//===============================================================

`include "top_defines.vh"
module krv_e (
//global interface
input clk_in,		//clock in
input porn,		//power on reset, active low

//GPIO 
input [7:0] GPIO_IN,
output [7:0] GPIO_OUT,

//UART
input UART_RX,
output UART_TX

`ifdef KRV_HAS_DBG
,
input				TDI,
output				TDO,
input				TCK,
input				TMS,
input				TRST
`endif

);

//Wires
//PLL
wire cpu_clk;
wire cpu_rstn;
wire ACLK;
wire ARESETn;
wire kplic_clk;
wire kplic_rstn;

wire dma_dtcm_access = 1'b0;			
wire dma_dtcm_ready;
wire dma_dtcm_rd0_wr1 = 1'b0;
wire [`ADDR_WIDTH - 1 : 0] dma_dtcm_addr = 32'h0;
wire [`DATA_WIDTH - 1 : 0] dma_dtcm_wdata = 32'h0;
wire [`DATA_WIDTH - 1 : 0] dma_dtcm_rdata;
wire dma_dtcm_rdata_valid;	

	wire cpu_clk_g;
	wire kplic_int;
	wire core_timer_int;

	wire DAXI_access;	
	wire DAXI_rd0_wr1;		
	wire [3:0] DAXI_byte_strobe;
	wire [`DATA_WIDTH - 1 : 0] DAXI_write_data;
	wire [`ADDR_WIDTH - 1 : 0] DAXI_addr;
	wire DAXI_trans_buffer_full;
	wire [`DATA_WIDTH - 1 : 0] DAXI_read_data;
	wire DAXI_read_data_valid;

	wire instr_itcm_access;
	wire [`ADDR_WIDTH - 1 : 0] instr_itcm_addr;
	wire [`DATA_WIDTH - 1 : 0] instr_itcm_read_data;
	wire instr_itcm_read_data_valid;

/*
	wire instr_dtcm_access;
	wire [`ADDR_WIDTH - 1 : 0] instr_dtcm_addr;
	wire [`DATA_WIDTH - 1 : 0] instr_dtcm_read_data;
	wire instr_dtcm_read_data_valid;
*/

	wire IAXI_ready;
	wire itcm_auto_load;
	wire itcm_access_AXI;
	wire [`ADDR_WIDTH - 1 : 0 ] itcm_auto_load_addr;

	wire data_itcm_access;
	wire data_itcm_ready;
	wire data_itcm_rd0_wr1;	
	wire [3:0] data_itcm_byte_strobe;
	wire [`DATA_WIDTH - 1 : 0] data_itcm_write_data;
	wire [`ADDR_WIDTH - 1 : 0] data_itcm_addr;
	wire [`DATA_WIDTH - 1 : 0] data_itcm_read_data;
	wire data_itcm_read_data_valid;
	  
	wire data_dtcm_access;
	wire data_dtcm_ready;
	wire data_dtcm_rd0_wr1;	
	wire [3:0] data_dtcm_byte_strobe;
	wire [`DATA_WIDTH - 1 : 0]  data_dtcm_write_data;
	wire [`ADDR_WIDTH - 1 : 0] data_dtcm_addr;
	wire [`DATA_WIDTH - 1 : 0] data_dtcm_read_data;
	wire data_dtcm_read_data_valid;
	  
	wire IAXI_access;	
	wire [`ADDR_WIDTH - 1 : 0] IAXI_addr;
	wire [`DATA_WIDTH - 1 : 0] IAXI_read_data;
	wire IAXI_read_data_valid;

	wire wfi;
	wire mother_sleep;
	wire daughter_sleep;
	wire isolation_on;
	wire pg_resetn;
	wire save;
	wire restore;

	wire timer_int;

	wire  [`INT_NUM - 1 : 0] external_int = {31'h0, timer_int};

`ifdef KRV_HAS_DBG
wire 				resumereq_w1;
wire				dbg_reg_access;
wire 				dbg_wr1_rd0;
wire[`CMD_REGNO_SIZE - 1 : 0]	dbg_regno;
wire [`DATA_WIDTH - 1 : 0]	dbg_write_data;
wire                     	dbg_read_data_valid;
wire[`DATA_WIDTH - 1 : 0]	dbg_read_data;
`endif

//AXI bus signals declaration
//IAXI
wire 					IAXI_AWVALID;	
wire 					IAXI_AWREADY;	
wire [`AXI_ADDR_WIDTH - 1 : 0] 		IAXI_AWADDR;
wire [2:0]				IAXI_AWPROT;
wire 					IAXI_WVALID;
wire 					IAXI_WREADY;
wire [`AXI_DATA_WIDTH - 1 : 0] 		IAXI_WDATA;
wire [`AXI_STRB_WIDTH - 1 : 0]		IAXI_WSTRB;
wire  					IAXI_BVALID;
wire 					IAXI_BREADY;
wire[1:0]				IAXI_BRESP;
wire 					IAXI_ARVALID;			
wire  					IAXI_ARREADY;
wire [`AXI_ADDR_WIDTH - 1 : 0]		IAXI_ARADDR;
wire [2:0]				IAXI_ARPROT;
wire					IAXI_RVALID;
wire					IAXI_RREADY;
wire[`AXI_DATA_WIDTH - 1 : 0]		IAXI_RDATA;
wire[1:0]				IAXI_RRESP;

//DAXI
wire 					DAXI_AWVALID;	
wire 					DAXI_AWREADY;	
wire [`AXI_ADDR_WIDTH - 1 : 0] 		DAXI_AWADDR;
wire [2:0]				DAXI_AWPROT;
wire 					DAXI_WVALID;
wire 					DAXI_WREADY;
wire [`AXI_DATA_WIDTH - 1 : 0] 		DAXI_WDATA;
wire [`AXI_STRB_WIDTH - 1 : 0]		DAXI_WSTRB;
wire  					DAXI_BVALID;
wire 					DAXI_BREADY;
wire[1:0]				DAXI_BRESP;
wire 					DAXI_ARVALID;			
wire  					DAXI_ARREADY;
wire [`AXI_ADDR_WIDTH - 1 : 0]		DAXI_ARADDR;
wire [2:0]				DAXI_ARPROT;
wire					DAXI_RVALID;
wire					DAXI_RREADY;
wire[`AXI_DATA_WIDTH - 1 : 0]		DAXI_RDATA;
wire[1:0]				DAXI_RRESP;
	
`ifdef KRV_HAS_DBG
//system bus
wire 					sb_AWVALID;	
wire 					sb_AWREADY;	
wire [`AXI_ADDR_WIDTH - 1 : 0] 		sb_AWADDR;
wire [2:0]				sb_AWPROT;
wire 					sb_WVALID;
wire 					sb_WREADY;
wire [`AXI_DATA_WIDTH - 1 : 0] 		sb_WDATA;
wire [`AXI_STRB_WIDTH - 1 : 0]		sb_WSTRB;
wire  					sb_BVALID;
wire 					sb_BREADY;
wire[1:0]				sb_BRESP;
wire 					sb_ARVALID;			
wire  					sb_ARREADY;
wire [`AXI_ADDR_WIDTH - 1 : 0]		sb_ARADDR;
wire [2:0]				sb_ARPROT;
wire					sb_RVALID;
wire					sb_RREADY;
wire[`AXI_DATA_WIDTH - 1 : 0]		sb_RDATA;
wire[1:0]				sb_RRESP;

`else 
wire 					sb_AWVALID = 1'b0;	
wire 					sb_AWREADY;	
wire [`AXI_ADDR_WIDTH - 1 : 0] 		sb_AWADDR  = {`AXI_ADDR_WIDTH{1'b0}};
wire [2:0]				sb_AWPROT  = 3'h0;
wire 					sb_WVALID  = 1'b0;
wire 					sb_WREADY;
wire [`AXI_DATA_WIDTH - 1 : 0] 		sb_WDATA   = {`AXI_DATA_WIDTH{1'b0}};
wire [`AXI_STRB_WIDTH - 1 : 0]		sb_WSTRB   = {`AXI_STRB_WIDTH{1'b0}};
wire  					sb_BVALID;
wire 					sb_BREADY  = 1'b0;
wire[1:0]				sb_BRESP;
wire 					sb_ARVALID = 1'b0;			
wire  					sb_ARREADY;
wire [`AXI_ADDR_WIDTH - 1 : 0]		sb_ARADDR   = {`AXI_ADDR_WIDTH{1'b0}};
wire [2:0]				sb_ARPROT   = 3'h0;
wire					sb_RVALID   = 1'b1;
wire					sb_RREADY   = 1'b0;
wire[`AXI_DATA_WIDTH - 1 : 0]		sb_RDATA;
wire[1:0]				sb_RRESP;
`endif
//flash
wire 					AWVALID_S0;	
wire 					WVALID_S0;	
wire 					ARVALID_S0;	
wire[`AXI_DATA_WIDTH - 1 : 0]		RDATA_S0;
wire					RVALID_S0;
wire  					BVALID_S0;
wire 					AWVALID_flash;	
wire 					AWREADY_flash;	
wire [`AXI_ADDR_WIDTH - 1 : 0] 		AWADDR_flash;
wire [2:0]				AWPROT_flash;
wire 					WVALID_flash;
wire 					WREADY_flash;
wire [`AXI_DATA_WIDTH - 1 : 0] 		WDATA_flash;
wire [`AXI_STRB_WIDTH - 1 : 0]		WSTRB_flash;
wire  					BVALID_flash;
wire 					BREADY_flash;
wire[1:0]				BRESP_flash;
wire 					ARVALID_flash;			
wire  					ARREADY_flash;
wire [`AXI_ADDR_WIDTH - 1 : 0]		ARADDR_flash;
wire [2:0]				ARPROT_flash;
wire					RVALID_flash;
wire					RREADY_flash;
wire[`AXI_DATA_WIDTH - 1 : 0]		RDATA_flash;
wire[1:0]				RRESP_flash;
//kplic
wire 					AWVALID_kplic;	
wire 					AWREADY_kplic;	
wire [`AXI_ADDR_WIDTH - 1 : 0] 		AWADDR_kplic;
wire [2:0]				AWPROT_kplic;
wire 					WVALID_kplic;
wire 					WREADY_kplic;
wire [`AXI_DATA_WIDTH - 1 : 0] 		WDATA_kplic;
wire [`AXI_STRB_WIDTH - 1 : 0]		WSTRB_kplic;
wire  					BVALID_kplic;
wire 					BREADY_kplic;
wire[1:0]				BRESP_kplic;
wire 					ARVALID_kplic;			
wire  					ARREADY_kplic;
wire [`AXI_ADDR_WIDTH - 1 : 0]		ARADDR_kplic;
wire [2:0]				ARPROT_kplic;
wire					RVALID_kplic;
wire					RREADY_kplic;
wire[`AXI_DATA_WIDTH - 1 : 0]		RDATA_kplic;
wire[1:0]				RRESP_kplic;

//ctimer
wire 					AWVALID_ctimer;	
wire 					AWREADY_ctimer;	
wire [`AXI_ADDR_WIDTH - 1 : 0] 		AWADDR_ctimer;
wire [2:0]				AWPROT_ctimer;
wire 					WVALID_ctimer;
wire 					WREADY_ctimer;
wire [`AXI_DATA_WIDTH - 1 : 0] 		WDATA_ctimer;
wire [`AXI_STRB_WIDTH - 1 : 0]		WSTRB_ctimer;
wire  					BVALID_ctimer;
wire 					BREADY_ctimer;
wire[1:0]				BRESP_ctimer;
wire 					ARVALID_ctimer;			
wire  					ARREADY_ctimer;
wire [`AXI_ADDR_WIDTH - 1 : 0]		ARADDR_ctimer;
wire [2:0]				ARPROT_ctimer;
wire					RVALID_ctimer;
wire					RREADY_ctimer;
wire[`AXI_DATA_WIDTH - 1 : 0]		RDATA_ctimer;
wire[1:0]				RRESP_ctimer;

//uart
wire 					AWVALID_uart;	
wire 					AWREADY_uart;	
wire [`AXI_ADDR_WIDTH - 1 : 0] 		AWADDR_uart;
wire [2:0]				AWPROT_uart;
wire 					WVALID_uart;
wire 					WREADY_uart;
wire [`AXI_DATA_WIDTH - 1 : 0] 		WDATA_uart;
wire [`AXI_STRB_WIDTH - 1 : 0]		WSTRB_uart;
wire  					BVALID_uart;
wire 					BREADY_uart;
wire[1:0]				BRESP_uart;
wire 					ARVALID_uart;			
wire  					ARREADY_uart;
wire [`AXI_ADDR_WIDTH - 1 : 0]		ARADDR_uart;
wire [2:0]				ARPROT_uart;
wire					RVALID_uart;
wire					RREADY_uart;
wire[`AXI_DATA_WIDTH - 1 : 0]		RDATA_uart;
wire[1:0]				RRESP_uart;

//reserved1
wire 					AWREADY_reserved1 = 1'b1;	
wire 					WREADY_reserved1  = 1'b1;
wire  					BVALID_reserved1  = 1'b1;
wire[1:0]				BRESP_reserved1   = 2'h0;
wire  					ARREADY_reserved1 = 1'b1;
wire					RVALID_reserved1  = 1'b1;
wire[`AXI_DATA_WIDTH - 1 : 0]		RDATA_reserved1   = 32'h0;
wire[1:0]				RRESP_reserved1   = 2'h0;
wire 					AWVALID_reserved1;	
wire [`AXI_ADDR_WIDTH - 1 : 0] 		AWADDR_reserved1;
wire [2:0]				AWPROT_reserved1;
wire 					WVALID_reserved1;
wire [`AXI_DATA_WIDTH - 1 : 0] 		WDATA_reserved1;
wire [`AXI_STRB_WIDTH - 1 : 0]		WSTRB_reserved1;
wire 					BREADY_reserved1;
wire 					ARVALID_reserved1;			
wire [`AXI_ADDR_WIDTH - 1 : 0]		ARADDR_reserved1;
wire [2:0]				ARPROT_reserved1;
wire					RREADY_reserved1;
//reserved2
wire 					AWREADY_reserved2 = 1'b1;	
wire 					WREADY_reserved2  = 1'b1;
wire  					BVALID_reserved2  = 1'b1;
wire[1:0]				BRESP_reserved2   = 2'h0;
wire  					ARREADY_reserved2 = 1'b1;
wire					RVALID_reserved2  = 1'b1;
wire[`AXI_DATA_WIDTH - 1 : 0]		RDATA_reserved2   = 32'h0;
wire[1:0]				RRESP_reserved2   = 2'h0;
wire 					AWVALID_reserved2;	
wire [`AXI_ADDR_WIDTH - 1 : 0] 		AWADDR_reserved2;
wire [2:0]				AWPROT_reserved2;
wire 					WVALID_reserved2;
wire [`AXI_DATA_WIDTH - 1 : 0] 		WDATA_reserved2;
wire [`AXI_STRB_WIDTH - 1 : 0]		WSTRB_reserved2;
wire 					BREADY_reserved2;
wire 					ARVALID_reserved2;			
wire [`AXI_ADDR_WIDTH - 1 : 0]		ARADDR_reserved2;
wire [2:0]				ARPROT_reserved2;
wire					RREADY_reserved2;





//-----------------------------------------------------//
//PLL
//-----------------------------------------------------//
`ifdef ASIC 
/*
//instance of PLL
PLL_nn u_pll (
...
.clk_in		(clk_in),
.clk_out_0	(cpu_clk),
.clk_out_1	(ACLK),
.clk_out_2	(kplic_clk),
)
*/
`else
assign cpu_clk 	= clk_in;
assign ACLK 	= clk_in;
assign kplic_clk 	= clk_in;
`endif

//-----------------------------------------------------//
//Reset sync
//-----------------------------------------------------//
rst_sync u_rst_sync_cpu (
.clk		(cpu_clk),
.in_rstn	(porn),
.out_rstn	(cpu_rstn)
);

rst_sync u_rst_sync_AXI (
.clk		(ACLK),
.in_rstn	(porn),
.out_rstn	(ARESETn)
);

rst_sync u_rst_sync_kplic (
.clk		(kplic_clk),
.in_rstn	(porn),
.out_rstn	(kplic_rstn)
);

//-----------------------------------------------------//
//pg_ctrl
//-----------------------------------------------------//
`ifdef KRV_HAS_PG
pg_ctrl u_pg_ctrl(
	.cpu_clk		(cpu_clk),
	.cpu_rstn		(cpu_rstn),
	.wfi			(wfi),
	.kplic_int		(kplic_int),
	.cpu_clk_g		(cpu_clk_g),
	.mother_sleep		(mother_sleep),
	.daughter_sleep		(daughter_sleep),
	.isolation_on		(isolation_on),
	.pg_resetn		(pg_resetn),
	.save			(save),
	.restore		(restore)
);
`else
assign cpu_clk_g = cpu_clk;
assign pg_resetn = 1'b1;
`endif
	
//-----------------------------------------------------//
//krv core
//-----------------------------------------------------//
core u_core (
	.cpu_clk				(cpu_clk_g),
	.cpu_rstn				(cpu_rstn),
	.pg_resetn				(pg_resetn),
	.boot_addr				(`BOOT_ADDR),
	.kplic_int				(kplic_int),	
	.core_timer_int				(core_timer_int),	
	.wfi					(wfi),

	.instr_itcm_addr			(instr_itcm_addr),
	.instr_itcm_access			(instr_itcm_access),
	.instr_itcm_read_data			(instr_itcm_read_data),
	.instr_itcm_read_data_valid		(instr_itcm_read_data_valid),
	.itcm_auto_load				(itcm_auto_load),

	.data_dtcm_rd0_wr1			(data_dtcm_rd0_wr1),
	.data_dtcm_byte_strobe			(data_dtcm_byte_strobe),
	.data_dtcm_access			(data_dtcm_access),
	.data_dtcm_ready			(data_dtcm_ready),
	.data_dtcm_addr				(data_dtcm_addr),
	.data_dtcm_write_data			(data_dtcm_write_data),
	.data_dtcm_read_data			(data_dtcm_read_data),
	.data_dtcm_read_data_valid		(data_dtcm_read_data_valid),

	.IAXI_access				(IAXI_access),	
	.IAXI_addr				(IAXI_addr),
	.IAXI_read_data				(IAXI_read_data),
	.IAXI_read_data_valid			(IAXI_read_data_valid),

	.DAXI_access				(DAXI_access),	
	.DAXI_rd0_wr1				(DAXI_rd0_wr1),
	.DAXI_byte_strobe			(DAXI_byte_strobe),
	.DAXI_write_data			(DAXI_write_data),
	.DAXI_addr				(DAXI_addr),
	.DAXI_trans_buffer_full			(DAXI_trans_buffer_full),
	.DAXI_read_data				(DAXI_read_data),
	.DAXI_read_data_valid			(DAXI_read_data_valid)
`ifdef KRV_HAS_DBG
//debug interface
,
.resumereq_w1		(resumereq_w1	),
.dbg_reg_access		(dbg_reg_access	),
.dbg_wr1_rd0		(dbg_wr1_rd0	),
.dbg_regno		(dbg_regno	),
.dbg_write_data		(dbg_write_data	),
.dbg_read_data_valid	(dbg_read_data_valid),
.dbg_read_data		(dbg_read_data	)
`endif

);

//-----------------------------------------------------//
//itcm
//-----------------------------------------------------//
wire AXI_itcm_access;
wire AXI_dtcm_access;
wire [`AXI_ADDR_WIDTH - 1 : 0] AXI_tcm_addr;
wire AXI_tcm_rd0_wr1;
wire [3:0] AXI_tcm_byte_strobe;
wire [`DATA_WIDTH - 1 : 0] AXI_tcm_write_data;
wire [`DATA_WIDTH - 1 : 0] AXI_itcm_read_data;
wire [`DATA_WIDTH - 1 : 0] AXI_dtcm_read_data;
wire  AXI_dtcm_read_data_valid;
wire  AXI_itcm_read_data_valid;

tcm_decoder u_tcm_decoder (
	.ACLK			(ACLK			),						
	.ARESETn		(ARESETn		),						
	.AWVALID		(AWVALID_S0		),	
	.AWREADY		(AWREADY_flash		),	
	.AWADDR			(AWADDR_flash		),
	.AWPROT			(AWPROT_flash		),
	.WVALID			(WVALID_S0		),
	.WREADY			(WREADY_flash		),
	.WDATA			(WDATA_flash		),
	.WSTRB			(WSTRB_flash		),
	.BVALID			(BVALID_S0		),
	.BREADY			(BREADY_flash		),
	.BRESP			(BRESP_flash		),
	.ARVALID		(ARVALID_S0		),			
	.ARREADY		(ARREADY_flash		),
	.ARADDR			(ARADDR_flash		),
	.ARPROT			(ARPROT_flash		),
	.RVALID			(RVALID_S0		),
	.RREADY			(RREADY_flash		),
	.RDATA			(RDATA_S0		),
	.RRESP			(RRESP_flash		),

	.BVALID_flash			(BVALID_flash		),
	.RVALID_flash			(RVALID_flash		),
	.RDATA_flash			(RDATA_flash),
	.AWVALID_flash			(AWVALID_flash),
	.ARVALID_flash			(ARVALID_flash),
	.WVALID_flash			(WVALID_flash),
	.itcm_auto_load			(itcm_auto_load),
	.AXI_itcm_access		(AXI_itcm_access   ),
	.AXI_dtcm_access		(AXI_dtcm_access   ),
	.AXI_tcm_addr			(AXI_tcm_addr	   ),
	.AXI_tcm_byte_strobe		(AXI_tcm_byte_strobe	   ),
	.AXI_tcm_rd0_wr1		(AXI_tcm_rd0_wr1   ),
	.AXI_tcm_write_data		(AXI_tcm_write_data),
	.AXI_itcm_read_data		(AXI_itcm_read_data),
	.AXI_itcm_read_data_valid	(AXI_itcm_read_data_valid),
	.AXI_dtcm_read_data		(AXI_dtcm_read_data),
	.AXI_dtcm_read_data_valid	(AXI_dtcm_read_data_valid)
);

`ifdef KRV_HAS_ITCM
itcm u_itcm(
	.clk		(cpu_clk_g),
	.rstn		(cpu_rstn),
	.instr_itcm_addr		(instr_itcm_addr),
	.instr_itcm_access		(instr_itcm_access),
	.instr_itcm_read_data		(instr_itcm_read_data),
	.instr_itcm_read_data_valid	(instr_itcm_read_data_valid),

.AXI_itcm_access		(AXI_itcm_access   ),
.AXI_tcm_addr			(AXI_tcm_addr	   ),
.AXI_tcm_byte_strobe		(AXI_tcm_byte_strobe	   ),
.AXI_tcm_rd0_wr1		(AXI_tcm_rd0_wr1   ),
.AXI_tcm_write_data		(AXI_tcm_write_data),
.AXI_itcm_read_data		(AXI_itcm_read_data),
.AXI_itcm_read_data_valid	(AXI_itcm_read_data_valid),


	.IAXI_ready	(IAXI_ready),
	.IAXI_read_data	(IAXI_read_data),
	.IAXI_read_data_valid	(IAXI_read_data_valid),
	.itcm_auto_load	(itcm_auto_load),
	.itcm_access_AXI		(itcm_access_AXI),
	.itcm_auto_load_addr	(itcm_auto_load_addr)

);
`else 
assign instr_itcm_read_data_valid = 1'b0;
assign instr_itcm_read_data = {`DATA_WIDTH {1'b0}};
assign AXI_itcm_read_data = {`DATA_WIDTH {1'b0}};
assign itcm_auto_load = 1'b0;
assign itcm_auto_load_addr = {`ADDR_WIDTH {1'b0}};
`endif

//-----------------------------------------------------//
//dtcm
//-----------------------------------------------------//
`ifdef KRV_HAS_DTCM
dtcm u_dtcm (
	.clk			(cpu_clk_g),
	.rstn			(cpu_rstn),
	.data_dtcm_access	(data_dtcm_access),
	.data_dtcm_ready	(data_dtcm_ready),
	.data_dtcm_rd0_wr1	(data_dtcm_rd0_wr1),
	.data_dtcm_byte_strobe	(data_dtcm_byte_strobe),
	.data_dtcm_addr		(data_dtcm_addr),
	.data_dtcm_wdata	(data_dtcm_write_data),
	.data_dtcm_rdata	(data_dtcm_read_data),
	.data_dtcm_rdata_valid	(data_dtcm_read_data_valid),
	.AXI_dtcm_access	(AXI_dtcm_access   ),
	.AXI_tcm_addr		(AXI_tcm_addr	   ),
	.AXI_tcm_byte_strobe	(AXI_tcm_byte_strobe	   ),
	.AXI_tcm_rd0_wr1	(AXI_tcm_rd0_wr1   ),
	.AXI_tcm_wdata		(AXI_tcm_write_data),
	.AXI_dtcm_rdata		(AXI_dtcm_read_data),
	.AXI_dtcm_rdata_valid	(AXI_dtcm_read_data_valid),

	.dma_dtcm_access	(dma_dtcm_access),
	.dma_dtcm_ready		(dma_dtcm_ready),
	.dma_dtcm_rd0_wr1	(dma_dtcm_rd0_wr1),
	.dma_dtcm_addr		(dma_dtcm_addr),
	.dma_dtcm_wdata		(dma_dtcm_wdata),
	.dma_dtcm_rdata		(dma_dtcm_rdata),
	.dma_dtcm_rdata_valid	(dma_dtcm_rdata_valid)

);
`else
assign AXI_dtcm_read_data = {`DATA_WIDTH {1'b0}};
assign data_dtcm_read_data_valid = 1'b0;
assign data_dtcm_read_data = {`DATA_WIDTH {1'b0}};
assign dma_dtcm_read_data_valid = 1'b0;
assign dma_dtcm_read_data = {`DATA_WIDTH {1'b0}};
`endif

//-----------------------------------------------------//
//core Instruction AXI interface
//-----------------------------------------------------//
IAXI u_IAXI_master(
	.ACLK		(ACLK),
	.ARESETn	(ARESETn),
	.AWVALID	(IAXI_AWVALID		),
	.AWREADY	(IAXI_AWREADY		),
	.AWADDR		(IAXI_AWADDR		),
	.AWPROT		(IAXI_AWPROT		),
	.WVALID		(IAXI_WVALID		),
	.WREADY		(IAXI_WREADY		),
	.WDATA		(IAXI_WDATA		),
	.WSTRB		(IAXI_WSTRB		),
	.BVALID		(IAXI_BVALID		),
	.BREADY		(IAXI_BREADY		),
	.BRESP		(IAXI_BRESP		),
	.ARVALID	(IAXI_ARVALID		),			
	.ARREADY	(IAXI_ARREADY		),
	.ARADDR		(IAXI_ARADDR		),
	.ARPROT		(IAXI_ARPROT		),
	.RVALID		(IAXI_RVALID		),
	.RREADY		(IAXI_RREADY		),
	.RDATA		(IAXI_RDATA		),
	.RRESP		(IAXI_RRESP		),

	.cpu_clk	(cpu_clk_g),
	.cpu_resetn	(cpu_rstn),
	.itcm_access_AXI		(itcm_access_AXI),
	.itcm_auto_load_addr	(itcm_auto_load_addr),
	.IAXI_access	(IAXI_access),	
	.IAXI_addr	(IAXI_addr),
	.IAXI_ready	(IAXI_ready),
	.IAXI_read_data	(IAXI_read_data),
	.IAXI_read_data_valid	(IAXI_read_data_valid)
);

//-----------------------------------------------------//
//core DATA AXI interface
//-----------------------------------------------------//
DAXI u_DAXI_master(
	.ACLK		(ACLK),
	.ARESETn	(ARESETn),
	.AWVALID	(DAXI_AWVALID		),
	.AWREADY	(DAXI_AWREADY		),
	.AWADDR		(DAXI_AWADDR		),
	.AWPROT		(DAXI_AWPROT		),
	.WVALID		(DAXI_WVALID		),
	.WREADY		(DAXI_WREADY		),
	.WDATA		(DAXI_WDATA		),
	.WSTRB		(DAXI_WSTRB		),
	.BVALID		(DAXI_BVALID		),
	.BREADY		(DAXI_BREADY		),
	.BRESP		(DAXI_BRESP		),
	.ARVALID	(DAXI_ARVALID		),			
	.ARREADY	(DAXI_ARREADY		),
	.ARADDR		(DAXI_ARADDR		),
	.ARPROT		(DAXI_ARPROT		),
	.RVALID		(DAXI_RVALID		),
	.RREADY		(DAXI_RREADY		),
	.RDATA		(DAXI_RDATA		),
	.RRESP		(DAXI_RRESP		),

	.cpu_clk	(cpu_clk_g),
	.cpu_resetn	(cpu_rstn),
	.DAXI_access	(DAXI_access),	
	.DAXI_byte_strobe	(DAXI_byte_strobe),
	.DAXI_rd0_wr1	(DAXI_rd0_wr1),		
	.DAXI_write_data	(DAXI_write_data),
	.DAXI_addr	(DAXI_addr),
	.DAXI_trans_buffer_full	(DAXI_trans_buffer_full),
	.DAXI_read_data	(DAXI_read_data),
	.DAXI_read_data_valid	(DAXI_read_data_valid)
);

//-----------------------------------------------------//
//axi4-lite bus
//-----------------------------------------------------//
axi4_lite u_axi4_lite (
.ACLK			(ACLK),
.ARESETn		(ARESETn),
//AXI4-lite master0 
	.M0_AWVALID		(IAXI_AWVALID		),
	.M0_AWREADY		(IAXI_AWREADY		),
	.M0_AWADDR		(IAXI_AWADDR		),
	.M0_AWPROT		(IAXI_AWPROT		),
	.M0_WVALID		(IAXI_WVALID		),
	.M0_WREADY		(IAXI_WREADY		),
	.M0_WDATA		(IAXI_WDATA		),
	.M0_WSTRB		(IAXI_WSTRB		),
	.M0_BVALID		(IAXI_BVALID		),
	.M0_BREADY		(IAXI_BREADY		),
	.M0_BRESP		(IAXI_BRESP		),
	.M0_ARVALID		(IAXI_ARVALID		),			
	.M0_ARREADY		(IAXI_ARREADY		),
	.M0_ARADDR		(IAXI_ARADDR		),
	.M0_ARPROT		(IAXI_ARPROT		),
	.M0_RVALID		(IAXI_RVALID		),
	.M0_RREADY		(IAXI_RREADY		),
	.M0_RDATA		(IAXI_RDATA		),
	.M0_RRESP		(IAXI_RRESP		),

//AXI4-lite master1 
	.M1_AWVALID		(DAXI_AWVALID		),
	.M1_AWREADY		(DAXI_AWREADY		),
	.M1_AWADDR		(DAXI_AWADDR		),
	.M1_AWPROT		(DAXI_AWPROT		),
	.M1_WVALID		(DAXI_WVALID		),
	.M1_WREADY		(DAXI_WREADY		),
	.M1_WDATA		(DAXI_WDATA		),
	.M1_WSTRB		(DAXI_WSTRB		),
	.M1_BVALID		(DAXI_BVALID		),
	.M1_BREADY		(DAXI_BREADY		),
	.M1_BRESP		(DAXI_BRESP		),
	.M1_ARVALID		(DAXI_ARVALID		),			
	.M1_ARREADY		(DAXI_ARREADY		),
	.M1_ARADDR		(DAXI_ARADDR		),
	.M1_ARPROT		(DAXI_ARPROT		),
	.M1_RVALID		(DAXI_RVALID		),
	.M1_RREADY		(DAXI_RREADY		),
	.M1_RDATA		(DAXI_RDATA		),
	.M1_RRESP		(DAXI_RRESP		),

//AXI4-lite master2 
	.M2_AWVALID		(sb_AWVALID		),
	.M2_AWREADY		(sb_AWREADY		),
	.M2_AWADDR		(sb_AWADDR		),
	.M2_AWPROT		(sb_AWPROT		),
	.M2_WVALID		(sb_WVALID		),
	.M2_WREADY		(sb_WREADY		),
	.M2_WDATA		(sb_WDATA		),
	.M2_WSTRB		(sb_WSTRB		),
	.M2_BVALID		(sb_BVALID		),
	.M2_BREADY		(sb_BREADY		),
	.M2_BRESP		(sb_BRESP		),
	.M2_ARVALID		(sb_ARVALID		),			
	.M2_ARREADY		(sb_ARREADY		),
	.M2_ARADDR		(sb_ARADDR		),
	.M2_ARPROT		(sb_ARPROT		),
	.M2_RVALID		(sb_RVALID		),
	.M2_RREADY		(sb_RREADY		),
	.M2_RDATA		(sb_RDATA		),
	.M2_RRESP		(sb_RRESP		),
//AXI4-lite slave0
	.S0_AWVALID		(AWVALID_S0		),	
	.S0_AWREADY		(AWREADY_flash		),	
	.S0_AWADDR		(AWADDR_flash		),
	.S0_AWPROT		(AWPROT_flash		),
	.S0_WVALID		(WVALID_S0		),
	.S0_WREADY		(WREADY_flash		),
	.S0_WDATA		(WDATA_flash		),
	.S0_WSTRB		(WSTRB_flash		),
	.S0_BVALID		(BVALID_S0		),
	.S0_BREADY		(BREADY_flash		),
	.S0_BRESP		(BRESP_flash		),
	.S0_ARVALID		(ARVALID_S0		),			
	.S0_ARREADY		(ARREADY_flash		),
	.S0_ARADDR		(ARADDR_flash		),
	.S0_ARPROT		(ARPROT_flash		),
	.S0_RVALID		(RVALID_S0		),
	.S0_RREADY		(RREADY_flash		),
	.S0_RDATA		(RDATA_S0		),
	.S0_RRESP		(RRESP_flash		),
//AXI4-lite slave1
	.S1_AWVALID		(AWVALID_kplic		),	
	.S1_AWREADY		(AWREADY_kplic		),	
	.S1_AWADDR		(AWADDR_kplic		),
	.S1_AWPROT		(AWPROT_kplic		),
	.S1_WVALID		(WVALID_kplic		),
	.S1_WREADY		(WREADY_kplic		),
	.S1_WDATA		(WDATA_kplic		),
	.S1_WSTRB		(WSTRB_kplic		),
	.S1_BVALID		(BVALID_kplic		),
	.S1_BREADY		(BREADY_kplic		),
	.S1_BRESP		(BRESP_kplic		),
	.S1_ARVALID		(ARVALID_kplic		),			
	.S1_ARREADY		(ARREADY_kplic		),
	.S1_ARADDR		(ARADDR_kplic		),
	.S1_ARPROT		(ARPROT_kplic		),
	.S1_RVALID		(RVALID_kplic		),
	.S1_RREADY		(RREADY_kplic		),
	.S1_RDATA		(RDATA_kplic		),
	.S1_RRESP		(RRESP_kplic		),
//AXI4-lite slave2
	.S2_AWVALID		(AWVALID_ctimer		),	
	.S2_AWREADY		(AWREADY_ctimer		),	
	.S2_AWADDR		(AWADDR_ctimer		),
	.S2_AWPROT		(AWPROT_ctimer		),
	.S2_WVALID		(WVALID_ctimer		),
	.S2_WREADY		(WREADY_ctimer		),
	.S2_WDATA		(WDATA_ctimer		),
	.S2_WSTRB		(WSTRB_ctimer		),
	.S2_BVALID		(BVALID_ctimer		),
	.S2_BREADY		(BREADY_ctimer		),
	.S2_BRESP		(BRESP_ctimer		),
	.S2_ARVALID		(ARVALID_ctimer		),			
	.S2_ARREADY		(ARREADY_ctimer		),
	.S2_ARADDR		(ARADDR_ctimer		),
	.S2_ARPROT		(ARPROT_ctimer		),
	.S2_RVALID		(RVALID_ctimer		),
	.S2_RREADY		(RREADY_ctimer		),
	.S2_RDATA		(RDATA_ctimer		),
	.S2_RRESP		(RRESP_ctimer		),
//AXI4-lite slave3
	.S3_AWVALID		(AWVALID_reserved1		),	
	.S3_AWREADY		(AWREADY_reserved1		),	
	.S3_AWADDR		(AWADDR_reserved1		),
	.S3_AWPROT		(AWPROT_reserved1		),
	.S3_WVALID		(WVALID_reserved1		),
	.S3_WREADY		(WREADY_reserved1		),
	.S3_WDATA		(WDATA_reserved1		),
	.S3_WSTRB		(WSTRB_reserved1		),
	.S3_BVALID		(BVALID_reserved1		),
	.S3_BREADY		(BREADY_reserved1		),
	.S3_BRESP		(BRESP_reserved1		),
	.S3_ARVALID		(ARVALID_reserved1		),			
	.S3_ARREADY		(ARREADY_reserved1		),
	.S3_ARADDR		(ARADDR_reserved1		),
	.S3_ARPROT		(ARPROT_reserved1		),
	.S3_RVALID		(RVALID_reserved1		),
	.S3_RREADY		(RREADY_reserved1		),
	.S3_RDATA		(RDATA_reserved1		),
	.S3_RRESP		(RRESP_reserved1		),
//AXI4-lite slave4
	.S4_AWVALID		(AWVALID_uart		),	
	.S4_AWREADY		(AWREADY_uart		),	
	.S4_AWADDR		(AWADDR_uart		),
	.S4_AWPROT		(AWPROT_uart		),
	.S4_WVALID		(WVALID_uart		),
	.S4_WREADY		(WREADY_uart		),
	.S4_WDATA		(WDATA_uart		),
	.S4_WSTRB		(WSTRB_uart		),
	.S4_BVALID		(BVALID_uart		),
	.S4_BREADY		(BREADY_uart		),
	.S4_BRESP		(BRESP_uart		),
	.S4_ARVALID		(ARVALID_uart		),			
	.S4_ARREADY		(ARREADY_uart		),
	.S4_ARADDR		(ARADDR_uart		),
	.S4_ARPROT		(ARPROT_uart		),
	.S4_RVALID		(RVALID_uart		),
	.S4_RREADY		(RREADY_uart		),
	.S4_RDATA		(RDATA_uart		),
	.S4_RRESP		(RRESP_uart		),
//AXI4-lite slave5
	.S5_AWVALID		(AWVALID_reserved2		),	
	.S5_AWREADY		(AWREADY_reserved2		),	
	.S5_AWADDR		(AWADDR_reserved2		),
	.S5_AWPROT		(AWPROT_reserved2		),
	.S5_WVALID		(WVALID_reserved2		),
	.S5_WREADY		(WREADY_reserved2		),
	.S5_WDATA		(WDATA_reserved2		),
	.S5_WSTRB		(WSTRB_reserved2		),
	.S5_BVALID		(BVALID_reserved2		),
	.S5_BREADY		(BREADY_reserved2		),
	.S5_BRESP		(BRESP_reserved2		),
	.S5_ARVALID		(ARVALID_reserved2		),			
	.S5_ARREADY		(ARREADY_reserved2		),
	.S5_ARADDR		(ARADDR_reserved2		),
	.S5_ARPROT		(ARPROT_reserved2		),
	.S5_RVALID		(RVALID_reserved2		),
	.S5_RREADY		(RREADY_reserved2		),
	.S5_RDATA		(RDATA_reserved2		),
	.S5_RRESP		(RRESP_reserved2		)
);

`ifdef ASIC
/*
flash_ss u_flash_ss(
);
ASIC flash
*/
`else
flash_sim u_flash_ss(
	.ACLK	(ACLK),
	.ARESETn(ARESETn),
	.AWVALID		(AWVALID_flash		),	
	.AWREADY		(AWREADY_flash		),	
	.AWADDR		(AWADDR_flash		),
	.AWPROT		(AWPROT_flash		),
	.WVALID		(WVALID_flash		),
	.WREADY		(WREADY_flash		),
	.WDATA		(WDATA_flash		),
	.WSTRB		(WSTRB_flash		),
	.BVALID		(BVALID_flash		),
	.BREADY		(BREADY_flash		),
	.BRESP		(BRESP_flash		),
	.ARVALID		(ARVALID_flash		),			
	.ARREADY		(ARREADY_flash		),
	.ARADDR		(ARADDR_flash		),
	.ARPROT		(ARPROT_flash		),
	.RVALID		(RVALID_flash		),
	.RREADY		(RREADY_flash		),
	.RDATA		(RDATA_flash		),
	.RRESP		(RRESP_flash		)

);

`endif

//-----------------------------------------------------//
//uart
//-----------------------------------------------------//
uart u_uart (
.ACLK			(ACLK			),						
.ARESETn		(ARESETn		),						
.AWVALID		(AWVALID_uart		),	
.AWREADY		(AWREADY_uart		),	
.AWADDR			(AWADDR_uart		),
.AWPROT			(AWPROT_uart		),
.WVALID			(WVALID_uart		),
.WREADY			(WREADY_uart		),
.WDATA			(WDATA_uart		),
.WSTRB			(WSTRB_uart		),
.BVALID			(BVALID_uart		),
.BREADY			(BREADY_uart		),
.BRESP			(BRESP_uart		),
.ARVALID		(ARVALID_uart		),			
.ARREADY		(ARREADY_uart		),
.ARADDR			(ARADDR_uart		),
.ARPROT			(ARPROT_uart		),
.RVALID			(RVALID_uart		),
.RREADY			(RREADY_uart		),
.RDATA			(RDATA_uart		),
.RRESP			(RRESP_uart		),

.RX			(UART_RX		),
.TX			(UART_TX		),
.UART_INT		(UART_INT		)
);
//-----------------------------------------------------//
//kplic
//-----------------------------------------------------//
`ifdef KRV_HAS_PLIC
kplic u_kplic (
.ACLK			(ACLK			),						
.ARESETn		(ARESETn		),						
.AWVALID		(AWVALID_kplic		),	
.AWREADY		(AWREADY_kplic		),	
.AWADDR			(AWADDR_kplic		),
.AWPROT			(AWPROT_kplic		),
.WVALID			(WVALID_kplic		),
.WREADY			(WREADY_kplic		),
.WDATA			(WDATA_kplic		),
.WSTRB			(WSTRB_kplic		),
.BVALID			(BVALID_kplic		),
.BREADY			(BREADY_kplic		),
.BRESP			(BRESP_kplic		),
.ARVALID		(ARVALID_kplic		),			
.ARREADY		(ARREADY_kplic		),
.ARADDR			(ARADDR_kplic		),
.ARPROT			(ARPROT_kplic		),
.RVALID			(RVALID_kplic		),
.RREADY			(RREADY_kplic		),
.RDATA			(RDATA_kplic		),
.RRESP			(RRESP_kplic		),

.kplic_clk		(kplic_clk),
.kplic_rstn		(kplic_rstn),
.external_int		(external_int),
.kplic_int		(kplic_int)
);
`else
assign	AWREADY_kplic = 1'b1;	
assign	WREADY_kplic  = 1'b1;
assign	BVALID_kplic  = 1'b1;
assign	BRESP_kplic   = 2'h0;
assign	ARREADY_kplic = 1'b1;
assign	RVALID_kplic  = 1'b1;
assign	RDATA_kplic   = 32'h0;
assign	RRESP_kplic   = 2'h0;
`endif

//-----------------------------------------------------//
//machine timer
//-----------------------------------------------------//
`ifdef KRV_HAS_MTIMER
core_timer u_core_timer (
.ACLK			(ACLK			),						
.ARESETn		(ARESETn		),						
.AWVALID		(AWVALID_ctimer		),	
.AWREADY		(AWREADY_ctimer		),	
.AWADDR			(AWADDR_ctimer		),
.AWPROT			(AWPROT_ctimer		),
.WVALID			(WVALID_ctimer		),
.WREADY			(WREADY_ctimer		),
.WDATA			(WDATA_ctimer		),
.WSTRB			(WSTRB_ctimer		),
.BVALID			(BVALID_ctimer		),
.BREADY			(BREADY_ctimer		),
.BRESP			(BRESP_ctimer		),
.ARVALID		(ARVALID_ctimer		),			
.ARREADY		(ARREADY_ctimer		),
.ARADDR			(ARADDR_ctimer		),
.ARPROT			(ARPROT_ctimer		),
.RVALID			(RVALID_ctimer		),
.RREADY			(RREADY_ctimer		),
.RDATA			(RDATA_ctimer		),
.RRESP			(RRESP_ctimer		),

.core_timer_int		(core_timer_int)
);
`else
assign	AWREADY_ctimer = 1'b1;	
assign	WREADY_ctimer  = 1'b1;
assign	BVALID_ctimer  = 1'b1;
assign	BRESP_ctimer   = 2'h0;
assign	ARREADY_ctimer = 1'b1;
assign	RVALID_ctimer  = 1'b1;
assign	RDATA_ctimer   = 32'h0;
assign	RRESP_ctimer   = 2'h0;
assign  core_timer_int = 1'b0;
`endif

`ifdef KRV_HAS_DBG
//-----------------------------------------------------//
//dtm
//-----------------------------------------------------//
wire dtm_req_valid;
wire dtm_req_ready;
wire [`DBUS_M_WIDTH - 1 : 0]	dtm_req_bits;
wire dm_resp_valid;
wire dm_resp_ready;
wire [`DBUS_S_WIDTH - 1 : 0]	dm_resp_bits;

dtm u_dtm (
.TDI			(TDI		),
.TDO			(TDO		),
.TCK			(TCK		),
.TMS			(TMS		),
.TRST			(TRST		),
.sys_clk		(cpu_clk	),
.sys_rstn		(cpu_rstn	),
.dtm_req_valid		(dtm_req_valid	),
.dtm_req_ready		(dtm_req_ready	),
.dtm_req_bits		(dtm_req_bits	),
.dm_resp_valid		(dm_resp_valid	),
.dm_resp_ready		(dm_resp_ready	),
.dm_resp_bits		(dm_resp_bits	)
);

//-----------------------------------------------------//
//dm
//-----------------------------------------------------//
dm u_dm(
	.ACLK		(ACLK),
	.ARESETn	(ARESETn),
	.AWVALID	(sb_AWVALID		),
	.AWREADY	(sb_AWREADY		),
	.AWADDR		(sb_AWADDR		),
	.AWPROT		(sb_AWPROT		),
	.WVALID		(sb_WVALID		),
	.WREADY		(sb_WREADY		),
	.WDATA		(sb_WDATA		),
	.WSTRB		(sb_WSTRB		),
	.BVALID		(sb_BVALID		),
	.BREADY		(sb_BREADY		),
	.BRESP		(sb_BRESP		),
	.ARVALID	(sb_ARVALID		),			
	.ARREADY	(sb_ARREADY		),
	.ARADDR		(sb_ARADDR		),
	.ARPROT		(sb_ARPROT		),
	.RVALID		(sb_RVALID		),
	.RREADY		(sb_RREADY		),
	.RDATA		(sb_RDATA		),
	.RRESP		(sb_RRESP		),


.sys_clk		(cpu_clk	),
.sys_rstn		(cpu_rstn	),
.dtm_req_valid		(dtm_req_valid	),
.dtm_req_ready		(dtm_req_ready	),
.dtm_req_bits		(dtm_req_bits	),
.dm_resp_valid		(dm_resp_valid	),
.dm_resp_ready		(dm_resp_ready	),
.dm_resp_bits		(dm_resp_bits	),
.resumereq_w1		(resumereq_w1	),
.dbg_reg_access		(dbg_reg_access	),
.dbg_wr1_rd0		(dbg_wr1_rd0	),
.dbg_regno		(dbg_regno	),
.dbg_write_data		(dbg_write_data	),
.dbg_read_data_valid	(dbg_read_data_valid),
.dbg_read_data		(dbg_read_data	)
);


`endif

endmodule
