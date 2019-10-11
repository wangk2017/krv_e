
//Play a trick to let the simulation run faster

initial
begin
#5;
$display ("=========================================================================== \n");
$display ("Here is a trick to force the baud rate higher to make the simulation faster \n");
$display ("you can turn off the trick in tb/zephyr_phil_debug.v by comment the force \n");
$display ("=========================================================================== \n");
force DUT.u_uart.baud_val = 13'h4;
end



wire test_end1;
assign test_end1 = dec_pc == 32'h00001ae4;

//performance
wire [31:0] valid_branch_num = DUT.u_core.u_dec.branch_cnt;
wire [31:0] mis_predict_num = DUT.u_core.u_dec.mis_predict_cnt;
wire [31:0] correct_predict_num = valid_branch_num - mis_predict_num;

wire [31:0] div_stall = DUT.u_core.u_alu.ex_stall_cnt;

integer fp_z;

initial
begin
	$display ("=============================================\n");
	$display ("running Zephyr OS application philosopher\n");
	$display ("=============================================\n");

	fp_z =$fopen ("./out/uart_tx_data_phil.txt","w");
@(posedge test_end1 || time_out)
begin
@(posedge DUT.cpu_clk);
	$display ("=============================================\n");
	$display ("TEST_END\n");
	$display ("The application Print data is stored in \n");
	$display ("out/uart_tx_data_phil.txt\n");
	$display ("=============================================\n");
	$fwrite(fp_z, "=========================================\n");
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "Performance Data:                        \n");
	$fwrite(fp_z, "Total Valid Branch number is %d", valid_branch_num);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "Mis predict branch number is %d", mis_predict_num);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "Correct predict branch number is %d", correct_predict_num);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "=========================================\n");
	$fwrite(fp_z, "Stall cycle number is %d due to div", div_stall);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "=========================================\n");
	#1;
	$fclose(fp_z);


	$stop;
end
end

always @(posedge DUT.cpu_clk)
begin
	if(uart_tx_wr)
		begin
			$fwrite(fp_z, "%s", uart_tx_data);
			$display ("UART Transmitt DATA is %s ",uart_tx_data);
			$display ("\n");
		end

end
parameter MAIN 			= 32'h00000604;
parameter SWAP			= 32'h00000228;
parameter BG_THREAD_MAIN	= 32'h000021c0;
parameter PHIL			= 32'h000003c8;


//application process trace during simulation
always @(posedge DUT.cpu_clk)
begin
		case (dec_pc)
		MAIN:	//main
		begin
			$display ("Main Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		SWAP:// <__swap>
		begin
			$display ("swap Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		BG_THREAD_MAIN: //<bg_thread_main>
		begin
			$display ("bg_thread_main Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		PHIL:
		begin
			$display ("phil Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end

	endcase
end

wire [31:0] mem_addr = DUT.u_core.u_dmem_ctrl.mem_addr_mem;
wire [31:0] mem_wr_data = DUT.u_core.u_dmem_ctrl.store_data_mem;
wire mem_wr = DUT.u_core.u_dmem_ctrl.store_mem;
always @(posedge DUT.cpu_clk)
begin
	if(mem_wr && (mem_addr == 32'h412fc))
		begin
			$display ("write 412fc");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
end

always @(posedge DUT.cpu_clk)
begin
	if(mem_wr && (mem_addr == 32'h4131c))
		begin
			$display ("write 4131c");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
end


