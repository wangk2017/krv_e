//Obtain performance counter
wire [31:0] valid_branch_num = DUT.u_core.u_dec.branch_cnt;
wire [31:0] mis_predict_taken_num = DUT.u_core.u_fetch.mis_predict_taken_cnt;
wire [31:0] mis_predict_not_taken_num = DUT.u_core.u_fetch.mis_predict_not_taken_cnt;
wire [31:0] mis_predict_num = mis_predict_taken_num + mis_predict_not_taken_num;
wire [31:0] correct_predict_num = valid_branch_num - mis_predict_num;

wire [31:0] div_stall = DUT.u_core.u_alu.ex_stall_cnt;
wire [31:0] jal_flush = DUT.u_core.u_fetch.jal_dec_cnt;
wire [31:0] jalr_flush = DUT.u_core.u_fetch.jalr_ex_cnt;
wire [31:0] load_hazard_stall = DUT.u_core.u_dec.load_hazard_stall_cnt;
wire [31:0] load_stall = DUT.u_core.u_dmem_ctrl.load_stall_cnt;
wire [31:0] store_stall = DUT.u_core.u_dmem_ctrl.store_stall_cnt;


//check recount
wire branch = DUT.u_core.u_dec.branch;
wire mis_predict = DUT.u_core.u_dec.valid_mis_predict;

reg branch_d1;
reg mis_predict_d1;
reg[31:0] dec_pc_d1;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		branch_d1 <= 1'b0;
		mis_predict_d1 <= 1'b0;
		dec_pc_d1 <= 32'h0;
	end
	else
	begin
		branch_d1 <= branch;
		mis_predict_d1 <= mis_predict;
		dec_pc_d1 <= dec_pc;
	end
end

wire same_dec_pc = (dec_pc == dec_pc_d1);
wire recnt_branch = branch && branch_d1 && same_dec_pc;
wire recnt_mis_predict = mis_predict && mis_predict_d1  && same_dec_pc;

integer i;
//print performance result to file
initial 
begin
	@(posedge test_end1)
	begin
		$fwrite(fp_z, "                                         \n");
		$fwrite(fp_z, "=========================================\n");
		$fwrite(fp_z, "                                         \n");
		$fwrite(fp_z, "Performance Data Details                 \n");
		$fwrite(fp_z, "=========================================\n");
		$fwrite(fp_z, "Total Valid Branch number is %d", valid_branch_num);
		$fwrite(fp_z, "                                         \n");
		$fwrite(fp_z, "Mis predict taken number is %d", mis_predict_taken_num);
		$fwrite(fp_z, "                                         \n");
		$fwrite(fp_z, "Mis predict not taken number is %d", mis_predict_not_taken_num);
		$fwrite(fp_z, "                                         \n");
		$fwrite(fp_z, "Correct predict branch number is %d", correct_predict_num);
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
		for (i=0; i<256; i=i+1)
		begin
		$fwrite(fp_z, "predict1_credit[%d] = %d", i, DUT.u_core.u_fetch.u_branch_predict.predict1_credit[i]);
		$fwrite(fp_z, "=========================================\n");
		$fwrite(fp_z, "predict3_credit[%d] = %d", i, DUT.u_core.u_fetch.u_branch_predict.predict3_credit[i]);
		$fwrite(fp_z, "=========================================\n");
		end
	end
end
