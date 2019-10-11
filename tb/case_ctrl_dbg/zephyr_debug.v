
//Play a trick to let the simulation run faster

initial
begin
#5;
$display ("=========================================================================== \n");
$display ("Here is a trick to force the baud rate higher to make the simulation faster \n");
$display ("you can turn off the trick in tb/zephyr_debug.v by comment the force \n");
$display ("=========================================================================== \n");
force DUT.u_uart.baud_val = 13'h4;
end



wire test_end1;
assign test_end1 = dec_pc == 32'h00000d00;

//performance
wire [31:0] valid_branch_num = DUT.u_core.u_dec.branch_cnt;
wire [31:0] mis_predict_num = DUT.u_core.u_dec.mis_predict_cnt;
wire [31:0] div_stall = DUT.u_core.u_alu.ex_stall_cnt;
integer fp_z;


integer fp_tx;
integer fp_rx;



initial
begin
	$display ("=============================================\n");
	$display ("running Zephyr OS application hello world\n");
	$display ("=============================================\n");

	fp_tx =$fopen ("./out/uart_tx_data.txt","w");
	fp_rx =$fopen ("./out/uart_rx_data.txt","w");
	fp_z = $fopen ("./out/zephyr_perf.txt","w");

@(posedge test_end1)
@(posedge DUT.cpu_clk);
begin
	$fclose(fp_tx);
	$display ("=============================================\n");
	$display ("TEST_END\n");
	$display ("The application Print data is stored in \n");
	$display ("out/uart_tx_data.txt\n");
	$display ("=============================================\n");
	$display ("Performance analysis is stored in out/zephyr_perf.txt \n");
	$fwrite(fp_z, "Total Valid Branch number is %d", valid_branch_num);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "Mis predict branch number is %d", mis_predict_num);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "=========================================\n");
	$fwrite(fp_z, "Stall cycle number is %d due to div", div_stall);
	$fwrite(fp_z, "                                         \n");
	$fwrite(fp_z, "=========================================\n");
	#1;
	$fclose(fp_z);
	repeat (6000)	//wait for UART done
	begin
	@(posedge DUT.cpu_clk);
	end	
	$fclose(fp_rx);
	$display ("================================================================\n");
	$display ("The application Print data is received by UART RX and stored in \n");
	$display ("out/uart_rx_data.txt\n");
	$display ("================================================================\n");

	$stop;
end
end

always @(posedge DUT.cpu_clk)
begin
	if(uart_tx_wr)
	begin
		$fwrite(fp_tx, "%s", uart_tx_data);
		$display ("UART Transmitt DATA is %s ",uart_tx_data);
		$display ("\n");
	end

end

always @(posedge DUT.cpu_clk)
begin
	if(rx_data_read_valid)
	begin
		$fwrite(fp_rx, "%s", rx_data);
	end

end


parameter MAIN 			= 32'h000003c8;
parameter SWAP			= 32'h00000228;
parameter BG_THREAD_MAIN	= 32'h000013a8;

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
	endcase
end

wire [31:0] mem_addr = DUT.u_core.u_dmem_ctrl.mem_addr_mem;
wire [31:0] mem_wr_data = DUT.u_core.u_dmem_ctrl.store_data_mem;
wire mem_wr = DUT.u_core.u_dmem_ctrl.store_mem;
always @(posedge DUT.cpu_clk)
begin
	if(mem_wr && (mem_addr == 32'h40014))
		begin
			$display ("write 40014");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
end
