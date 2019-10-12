
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
wire [31:0] valid_branch_num = DUT.u_core.u_dec.branch_cnt;
wire [31:0] mis_predict_num = DUT.u_core.u_dec.mis_predict_cnt;
wire [31:0] correct_predict_num = valid_branch_num - mis_predict_num;

wire [31:0] div_stall = DUT.u_core.u_alu.ex_stall_cnt;
wire [31:0] jal_flush = DUT.u_core.u_fetch.jal_dec_cnt;
wire [31:0] jalr_flush = DUT.u_core.u_fetch.jalr_ex_cnt;
wire [31:0] load_hazard_stall = DUT.u_core.u_dec.load_hazard_stall_cnt;
wire [31:0] load_stall = DUT.u_core.u_dmem_ctrl.load_stall_cnt;
wire [31:0] store_stall = DUT.u_core.u_dmem_ctrl.store_stall_cnt;

integer fp_z;

initial
begin
	$display ("=========\n");
	$display ("=========\n");
	$display ("Coremark\n");
	$display ("=========\n");
	$display ("=========\n");
	fp_z =$fopen ("./out/uart_tx_data_coremark.txt","w");
@(posedge test_end1)
begin
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "=========================================\n");
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "Performance Data Details                 \n");
	$fwrite(fp_z, "=========================================\n");
	$fwrite(fp_z, "Total Valid Branch number is %d", valid_branch_num);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "Mis predict branch number is %d", mis_predict_num);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "Correct predict branch number is %d", correct_predict_num);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "=========================================\n");
	$fwrite(fp_z, "Div stall cycle number is %d due to div", div_stall);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "=========================================\n");
	$fwrite(fp_z, "Jal flush cycle number is %d due to jal", jal_flush);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "=========================================\n");
	$fwrite(fp_z, "Jalr flush cycle number is %d due to jalr", jalr_flush);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "=========================================\n");
	$fwrite(fp_z, "load_hazard_stall cycle number is %d due to load hazard", load_hazard_stall);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "=========================================\n");
	$fwrite(fp_z, "load_stall cycle number is %d due to load", load_stall);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "=========================================\n");
	$fwrite(fp_z, "store_stall cycle number is %d due to store", store_stall);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "=========================================\n");
	#1;
	$fclose(fp_z);
	$display ("TEST_END\n");
	$display ("Print data is stored in out/uart_tx_data_coremark.txt\n");
	$stop;
end
end

wire cpu_clk = DUT.cpu_clk;

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


