//===============================================================||
// File Name: 		core_timer_regs.v			 ||
// Author:    		Kitty Wang				 ||
// Description:   						 ||
//	      		core_timer registers                     ||
// History:   							 ||
//                      2017/10/18 				 ||
//                      First version				 ||
//===============================================================||

`include "top_defines.vh"
module core_timer_regs (
//global signals
input wire ACLK,						//AXI clock
input wire ARESETn,						//AXI reset, active low

input wire valid_reg_write,					//valid reg write
input wire valid_reg_read,					//valid reg read
input wire [15:0] addr,						//reg access address
input wire [`AXI_DATA_WIDTH - 1 : 0] write_data,		//reg write data
output wire [`AXI_DATA_WIDTH - 1 : 0] read_data,		//reg read data
output wire read_data_valid,					//reg read data valid

output reg timer_int

);


//-------------------------------------------------------------------//
//1: Register address decode
//-------------------------------------------------------------------//
reg [64:0] mtime;
wire [31:0] mtime_l = mtime[31:0];
wire [31:0] mtime_h = mtime[63:32];
reg [31:0] mtimecmp_l;
reg [31:0] mtimecmp_h;
wire mtime_l_sel;
wire mtimecmp_l_sel;
wire mtime_h_sel;
wire mtimecmp_h_sel;
assign mtime_l_sel = (addr == `MTIME_ADDR);
assign mtimecmp_l_sel = (addr == `MTIMECMP_ADDR);
assign mtime_h_sel = (addr == `MTIME_ADDR + 4);
assign mtimecmp_h_sel = (addr == `MTIMECMP_ADDR + 4);

//-------------------------------------------------------------------//
//2: reg read / write
//-------------------------------------------------------------------//

always @ (posedge ACLK or negedge ARESETn)
begin
	if (!ARESETn)
	begin
		mtime <= 64'h0;
	end
	else
	begin
		mtime <= mtime + 64'h1;
	end
end

wire [`AXI_DATA_WIDTH - 1 : 0] mtime_l_read_data;
assign mtime_l_read_data = mtime_l_sel ? mtime_l : {`AXI_DATA_WIDTH{1'b0}};

wire [`AXI_DATA_WIDTH - 1 : 0] mtime_h_read_data;
assign mtime_h_read_data = mtime_h_sel ? mtime_h : {`AXI_DATA_WIDTH{1'b0}};

always @ (posedge ACLK or negedge ARESETn)
begin
	if (!ARESETn)
	begin
		mtimecmp_l <= 32'hffffffff;
	end
	else
	begin
		if (mtimecmp_l_sel && valid_reg_write)
		begin
			mtimecmp_l <= write_data;
		end
		else
		begin
			mtimecmp_l <= mtimecmp_l;
		end
	end
end
wire [`AXI_DATA_WIDTH - 1 : 0] mtimecmp_l_read_data;
assign mtimecmp_l_read_data = mtimecmp_l_sel ? mtimecmp_l : {`AXI_DATA_WIDTH{1'b0}};

always @ (posedge ACLK or negedge ARESETn)
begin
	if (!ARESETn)
	begin
		mtimecmp_h <= 32'hffffffff;
	end
	else
	begin
		if (mtimecmp_h_sel && valid_reg_write)
		begin
			mtimecmp_h <= write_data;
		end
		else
		begin
			mtimecmp_h <= mtimecmp_h;
		end
	end
end
wire [`AXI_DATA_WIDTH - 1 : 0] mtimecmp_h_read_data;
assign mtimecmp_h_read_data = mtimecmp_h_sel ? mtimecmp_h : {`AXI_DATA_WIDTH{1'b0}};



//read data
assign read_data = {32{valid_reg_read}} &
		       (mtime_l_read_data 		|
		       mtime_h_read_data 		|
		       mtimecmp_l_read_data 		|
		       mtimecmp_h_read_data 		
);

assign read_data_valid = valid_reg_read;

always @ (posedge ACLK or negedge ARESETn)
begin
	if (!ARESETn)
	begin
		timer_int <= 1'b0;
	end
	else 
	begin
		if((mtimecmp_l_sel || mtimecmp_h_sel) && valid_reg_write)
		begin
			timer_int <= 1'b0;
		end
		else if({mtime_h, mtime_l} > {mtimecmp_h, mtimecmp_l})
		begin
			timer_int <= 1'b1;
		end
	end
end

endmodule
