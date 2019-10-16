
//Play a trick to let the simulation run faster

initial
begin
#5;
$display ("=========================================================================== \n");
$display ("Here is a trick to force the baud rate higher to make the simulation faster \n");
$display ("you can turn off the trick in tb/coremark_debug.v by comment the force \n");
$display ("=========================================================================== \n");
force DUT.u_uart.baud_val = 13'h4;
end



wire test_end1;
assign test_end1 = dec_pc == 32'h000007c;
//assign test_end1 = 0;
//assign test_end1 = (uart_tx_data==8'hff);

//performance
`include "perf.v"

integer fp_z;

initial
begin
	$display ("=========\n");
	$display ("=========\n");
	$display ("Coremark\n");
	$display ("=========\n");
	$display ("=========\n");
	fp_z =$fopen ("./out/uart_tx_data_coremark.txt","w");
@(posedge test_end1 || time_out)
begin
	#1;
	$fclose(fp_z);
	$display ("TEST_END\n");
	$display ("Print data is stored in out/uart_tx_data_coremark.txt\n");
	$stop;
end
end


always @(posedge cpu_clk)
begin
	if(uart_tx_wr)
		begin
			$display ("UART Transmitt");
			$display ("UART TX_DATA is %s \n",uart_tx_data);
			$fwrite(fp_z, "%s", uart_tx_data);
		end

end
parameter MAIN 			= 32'h00000084;
parameter INIT 			= 32'h00000874;
parameter GET_SEED_32 		= 32'h00001b88;
parameter START_TIME 		= 32'h0000080c;
parameter ITERATE 		= 32'h00001ae4;
parameter STOP_TIME 		= 32'h0000082c;
parameter MAINDONE		= 32'h0000007c;

wire [31:0] mret_addr = DUT.u_core.u_fetch.mepc;
wire [31:0] mret_instr = DUT.u_core.u_fetch.mret;

wire [31:0] mem_addr = DUT.u_core.u_dmem_ctrl.mem_addr_mem;
wire mem_st = DUT.u_core.u_dmem_ctrl.store_mem;
wire[31:0] st_data = DUT.u_core.u_dmem_ctrl.store_data_mem;
wire[31:0] ld_data = DUT.u_core.u_dmem_ctrl.mem_read_data;
wire ld_data_vld = DUT.u_core.u_dmem_ctrl.mem_wb_data_valid;

always @(posedge cpu_clk)
begin
	if((mem_addr==32'h4400bff8) && ld_data_vld)
	begin
		$display ("read time");
		$display ("@time %t  !",$time);
		$display ("read data = %h",ld_data);
		$display ("\n");
	end
end

wire div = DUT.u_core.u_dec.alu_div_dec;
wire [31:0] src1_data = DUT.u_core.u_dec.src_data1_dec;
wire [31:0] src2_data = DUT.u_core.u_dec.src_data2_dec;
always @(posedge cpu_clk)
begin
	if((src1_data==32'h19bfcc0) || (src2_data==32'h19bfcc0))
	begin
		$display ("HZ");
		$display ("@time %t  !",$time);
		$display ("src1 data = %h", src1_data);
		$display ("src2 data = %h", src2_data);
		$display ("\n");
	end
end

/*
always @(posedge cpu_clk)
begin
	if(div)
	begin
		$display ("met div");
		$display ("@time %t  !",$time);
		$display ("src1 data = %h", src1_data);
		$display ("src2 data = %h", src2_data);
		$display ("\n");
	end
end

*/
always @(posedge cpu_clk)
begin
	begin
		case (dec_pc)
		MAIN:	//main
		begin
			$display ("Main Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		INIT 		:	
		begin
			$display ("init Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		GET_SEED_32 	:	
		begin
			$display ("get seed32 Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		START_TIME 	:	
		begin
			$display ("start time Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		ITERATE 	:	
		begin
			$display ("iterate Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		STOP_TIME 	:	
		begin
			$display ("stop time Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end

		MAINDONE:	//main
		begin
			$display ("Main Done");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		endcase
	end
end


