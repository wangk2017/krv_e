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
// File Name: 		fetch.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		instruction fetch                 	|| 
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//                      2019/11/1 				||
//                      Add dynamic branch prediction 		||
//                      And return stack               		||
//===============================================================



`include "core_defines.vh"

module fetch (
//global signals
input wire cpu_clk,					// cpu clock
input wire cpu_rstn,					// cpu reset, active low
input wire [`ADDR_WIDTH - 1 : 0] boot_addr,		// boot address from SoC

//interface with dec
input wire jal_dec, 					// jal
input wire jalr_dec, 					// jalr
input wire jalr_ex, 					// jalr at EX stage
input wire [`RD_WIDTH - 1 : 0] rd_dec,			// rd
input wire ret_ex, 					// ret instr at EX stage
input wire fence_dec,					// fence
input wire flush_dec,					// flush DEC stage
output reg predict_taken_dec,				// propagate predict taken to DEC stage
output reg predict1_taken_dec,				// propagate predict taken by predictor1 to DEC stage
output reg predict3_taken_dec,				// propagate predict taken by predictor3 to DEC stage
output wire ret_stack_pre_rd,				// ret stack pre-read at EX stage
output reg ret_stack_ren_dec, 				// ret stack read at DEC stage
output reg[`ADDR_WIDTH - 1 : 0] ret_addr_dec,		// ret addr at DEC stage
output reg peek_ret_dec,				// propagate peek return to DEC stage
output reg is_loop_dec,					// propagate loop detection to DEC stage
output reg [`ADDR_WIDTH - 1 : 0] pc_dec,		// Program counter at DEC stage
output reg [`ADDR_WIDTH - 1 : 0] pc_plus4_dec,		// Program counter plus 4 at DEC stage
input wire dec_ready, 					// dec ready signal
output reg if_valid,					// indication of instruction valid
output reg [`INSTR_WIDTH - 1 : 0] instr_dec,		// instruction
input wire signed [`DATA_WIDTH - 1 : 0] src_data1_ex,	// source data 1 at EX stage
input wire signed [`DATA_WIDTH - 1 : 0] src_data2_ex,	// source data 1 at EX stage
input wire signed [`DATA_WIDTH - 1 : 0] imm_ex,		// immediate at ex stage
input wire signed [`DATA_WIDTH - 1 : 0] imm_dec,	// immediate at dec stage
input wire is_loop_ex,					// loop dectection at EX stage
input wire ret_stack_ren_ex,
input wire[`ADDR_WIDTH - 1 : 0] ret_addr_ex,		// ret addr at EX stage
input wire ret_stack_pre_rd_ex,				// ret stack pre-read at EX stage
input wire predict_taken_ex,				// predict taken at EX stage
input wire predict1_taken_ex,				// predict taken at EX stage
input wire predict3_taken_ex,				// predict taken at EX stage
input wire [`ADDR_WIDTH - 1 : 0] pc_ex,			// Program counter value at EX stage
input wire [`ADDR_WIDTH - 1 : 0] pc_plus4_ex,		// Program counter plus 4 at DEC stage
output wire mis_predict,				// mis predict of branch
output wire flush_ret_stack,				// flush return stack due to error
input wire branch_dec,
input wire branch_ex,
input wire branch_taken_ex,				// branch condition met

//interface with imem_ctrl
output reg [`ADDR_WIDTH - 1 : 0] pc,	
input wire instr_read_data_valid,			// instruction valid from imem		
input wire [`INSTR_WIDTH - 1 : 0] instr_read_data, 	// instruction from imem

//interface with trap_ctrl
input wire mret,					// mret
output wire pc_misaligned,				// pc misaligned condition found at IF stage
output wire [`ADDR_WIDTH - 1 : 0] fault_pc,		// the misaligned pc recorded at IF stage
input wire trap,					// trap (interrupt or exception) 
input wire  [`ADDR_WIDTH - 1 : 0] vector_addr,		// vector address
input wire [`ADDR_WIDTH - 1 : 0] mepc,			// epc for return from trap


`ifdef KRV_HAS_DBG
//interface with debug module
input wire ebreak,					// ebreak instruction
input wire breakpoint,					// breakpoint met
input wire dbg_mode,					// dbg_mode
input wire dret,					// dret
input wire single_step,					// single_step
input wire single_step_d2,				// single_step delay 1 cycle
input wire [`ADDR_WIDTH - 1 : 0] dpc			// dpc for return from debug
`endif

);




//--------------------------------------------------------------------------------------//
//add some buffer regs to hold the control state when ITCM disabled
//--------------------------------------------------------------------------------------//
wire if_bubble;

`ifndef KRV_HAS_ITCM
reg flush_if_r;
reg jal_dec_r;
reg jalr_ex_r;
reg branch_taken_ex_r;
reg predict_taken_ex_r;
reg [`DATA_WIDTH - 1 : 0] imm_dec_r;
reg mret_r;
reg fence_dec_r;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (~cpu_rstn)
	begin
		flush_if_r <= 1'b0;
		jal_dec_r <= 1'b0;
		jalr_ex_r <= 1'b0;
		branch_taken_ex_r <= 1'b0;
		mret_r <= 1'b0;
		fence_dec_r <= 1'b0;
		imm_dec_r <= {`DATA_WIDTH{1'b0}};
		predict_taken_ex_r <= 1'b0;
	end
	else
	begin
	if(instr_read_data_valid)
	begin
		flush_if_r <= 1'b0;
		jal_dec_r <= 1'b0;
		jalr_ex_r <= 1'b0;
		branch_taken_ex_r <= 1'b0;
		predict_taken_ex_r <= 1'b0;
		mret_r <= 1'b0;
		fence_dec_r <= 1'b0;
		imm_dec_r <= {`DATA_WIDTH{1'b0}};
	end
	else 
	begin
		if(flush_if)
		flush_if_r <= 1'b1;
		if(jal_dec)
		begin
			jal_dec_r <= 1'b1;
			imm_dec_r <= imm_dec;
		end
		if(jalr_ex)
		jalr_ex_r <= 1'b1;
		if(branch_taken_ex)
		branch_taken_ex_r <= 1'b1;
		if(predict_taken_ex)
		predict_taken_ex_r <= 1'b1;
		if(mret)
		mret_r <= 1'b1;
		if(fence_dec)
		fence_dec_r <= 1'b1;
	end
	end
end

reg if_bubble_r;
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (~cpu_rstn)
	begin
		if_bubble_r <= 1'b0;
	end
	else
	begin
		if_bubble_r <= if_bubble;
	end
end

wire [`DATA_WIDTH - 1 : 0] imm_dec_f = if_bubble_r ? imm_dec_r : imm_dec;

`else
wire flush_if_r = 1'b0;
wire jal_dec_r = 1'b0;
wire jalr_ex_r = 1'b0;
wire branch_taken_ex_r = 1'b0;
wire predict_taken_ex_r = 1'b0;
wire mret_r = 1'b0;
wire fence_dec_r = 1'b0;
wire [`DATA_WIDTH - 1 : 0] imm_dec_f = imm_dec;
`endif

wire predict_taken;
wire is_loop;
wire [`ADDR_WIDTH - 1 : 0] predict_target_pc;
wire[`ADDR_WIDTH - 1 : 0] branch_target_pc = pc_ex + imm_ex;
wire[`ADDR_WIDTH - 1 : 0] branch_pc_ex = pc_ex; 
wire jump = jal_dec || jalr_ex || ((jal_dec_r || jalr_ex_r) && !instr_read_data_valid);

wire stack_empty;
wire ret_stack_ren = !stack_empty && peek_ret && (!flush_if);
wire [`ADDR_WIDTH - 1 : 0] ret_addr;
//--------------------------------------------------------------------------------------//
// PC calculation
//--------------------------------------------------------------------------------------//
//JAL
//JALR
//Branch
//normal
//--------------------------------------------------------------------------------------//

wire[`ADDR_WIDTH - 1 : 0] jalr_target_pc = src_data1_ex + imm_ex;
wire[`ADDR_WIDTH - 1 : 0] jal_target_pc = pc_dec + imm_dec_f;
wire [`ADDR_WIDTH - 1 : 0] pc_plus4 = pc + 4;	

reg [`ADDR_WIDTH - 1 : 0] next_pc;

//branch predictor
branch_predict u_branch_predict(
.cpu_clk		(cpu_clk		),						
.cpu_rstn		(cpu_rstn		),						
.next_pc		(next_pc		),
.pc			(pc			),
.predict_taken		(predict_taken		),
.predict1_taken		(predict1_taken		),
.predict3_taken		(predict3_taken		),
.is_loop		(is_loop		),
.predict_target_pc	(predict_target_pc	),
.predict1_taken_ex	(predict1_taken_ex	),
.predict3_taken_ex	(predict3_taken_ex	),
.is_loop_ex		(is_loop_ex		),
.branch_ex		(branch_ex		),
.jal_dec		(jal_dec		),
.jalr_ex		(jalr_ex		),
.branch_pc_ex		(branch_pc_ex		),
.src_data1_ex		(src_data1_ex		),
.src_data2_ex		(src_data2_ex		),
.branch_target_pc	(branch_target_pc	),
.branch_taken_ex	(branch_taken_ex	)
);

wire mis_predict_taken 	   = (predict_taken_ex && !branch_taken_ex) || (predict_taken_ex_r && !branch_taken_ex_r && !instr_read_data_valid);
wire mis_predict_not_taken = (!predict_taken_ex && branch_taken_ex) || (!predict_taken_ex_r && branch_taken_ex_r && !instr_read_data_valid);
assign mis_predict = mis_predict_taken || mis_predict_not_taken;

//return stack

wire peek_ret = (instr_read_data == 32'h00008067 );

wire ret_stack_wen = (jal_dec || (!peek_ret_dec && jalr_dec)) && (rd_dec==5'h1) && (!flush_dec);

assign ret_stack_pre_rd =  peek_ret && branch_dec && (!predict_taken_dec);
wire ret_stack_mis_pre_rd = mis_predict_not_taken && ret_stack_pre_rd_ex;

wire peek_ret_err = ret_stack_ren_ex && (!ret_ex);
wire ret_addr_err = (ret_stack_ren_ex && ret_ex) && (ret_addr_ex != jalr_target_pc);
assign flush_ret_stack = ret_addr_err || peek_ret_err;

ret_stack u_ret_stack
(
.cpu_clk		(cpu_clk	),					
.cpu_rstn		(cpu_rstn	),		
.ret_stack_wen		(ret_stack_wen	),
.pc_dec			(pc_dec		),
.ret_stack_mis_pre_rd	(ret_stack_mis_pre_rd),
.ret_stack_ren		(ret_stack_ren	),
.stack_empty		(stack_empty	),
.flush_ret_stack	(flush_ret_stack),
.ret_addr		(ret_addr	)
);



//determine the next_pc
wire keep_pc = fence_dec || (fence_dec_r && !instr_read_data_valid) || !dec_ready || !instr_read_data_valid;

always @*
begin
`ifdef KRV_HAS_DBG
	if(dret || single_step)
	begin
		next_pc = dpc;
	end
	else if(dbg_mode)		//halt during dbg_mode
	begin
		next_pc = pc;
	end
	else
`endif 
	if(trap)
	begin
		next_pc = vector_addr;
	end
	else if(mis_predict_taken)
	begin
		next_pc = pc_plus4_ex;
	end
	else if(mis_predict_not_taken)
	begin
		next_pc = branch_target_pc;
	end
	else if(flush_ret_stack || jalr_ex || (jalr_ex_r && !instr_read_data_valid))
	begin
		next_pc = jalr_target_pc;
	end
	else if( jal_dec || (jal_dec_r && !instr_read_data_valid))
	begin
		next_pc = jal_target_pc;
	end
	else if(ret_stack_ren)
	begin
		next_pc = ret_addr;
	end	
	else if(mret || (mret_r))
	begin
		next_pc = mepc;
	end
	else if (keep_pc)
	begin
		next_pc = pc;
	end
	else if(predict_taken)
	begin
		next_pc = predict_target_pc;
	end
	else
	begin
		next_pc = pc_plus4;
	end
end


always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (~cpu_rstn)
	begin
		pc <= boot_addr;
	end
	else
	begin
		pc <= next_pc;
	end
end

//--------------------------------------------------------------------------------------//
//propagate from IF to DEC stage
//--------------------------------------------------------------------------------------//
`ifdef KRV_HAS_DBG
wire if_stall = dbg_mode && !single_step_d2;
`else
wire if_stall = 1'b0;
`endif

assign if_bubble = !instr_read_data_valid || if_stall;
wire flush_if = fence_dec || fence_dec_r || (jal_dec && dec_ready) || jal_dec_r || jalr_ex || jalr_ex_r || mis_predict || flush_ret_stack || trap | mret || mret_r
`ifdef KRV_HAS_DBG
|| ebreak || breakpoint
`endif
;


always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (~cpu_rstn)
	begin
		instr_dec <= {`INSTR_WIDTH{1'b0}};
		pc_dec <= boot_addr;
		pc_plus4_dec <= boot_addr;
		if_valid <= 1'b0;
		predict_taken_dec <= 1'b0;
		predict1_taken_dec <= 1'b0;
		predict3_taken_dec <= 1'b0;
		is_loop_dec <= 1'b0;
		peek_ret_dec <= 1'b0;
		ret_stack_ren_dec <= 1'b0;
		ret_addr_dec <= {`ADDR_WIDTH{1'b0}};
	end
	else
	begin
		if(flush_if || (flush_if_r && !instr_read_data_valid))
		begin
			instr_dec <= {`INSTR_WIDTH{1'b0}};
			if_valid <= 1'b0;
			predict_taken_dec <= 1'b0;
			predict1_taken_dec <= 1'b0;
			predict3_taken_dec <= 1'b0;
			is_loop_dec <= 1'b0;
			peek_ret_dec <= 1'b0;
			ret_stack_ren_dec <= 1'b0;
			ret_addr_dec <= {`ADDR_WIDTH{1'b0}};
		end
		else if(dec_ready)
		begin
			if_valid <= 1'b1;
			if(if_bubble || jump)
			begin
				instr_dec <= {`INSTR_WIDTH{1'b0}};
				predict_taken_dec <= 1'b0;
				predict1_taken_dec <= 1'b0;
				predict3_taken_dec <= 1'b0;
				is_loop_dec <= 1'b0;
				peek_ret_dec <= 1'b0;
				ret_stack_ren_dec <= 1'b0;
				ret_addr_dec <= {`ADDR_WIDTH{1'b0}};
			end
			else
			begin
				instr_dec <= instr_read_data;
				pc_dec <= pc;
				pc_plus4_dec <= pc_plus4;
				predict_taken_dec <= predict_taken;
				predict1_taken_dec <= predict1_taken;
				predict3_taken_dec <= predict3_taken;
				is_loop_dec <= is_loop;
				peek_ret_dec <= peek_ret;
				ret_addr_dec <= ret_addr;
				ret_stack_ren_dec <= ret_stack_ren;
			end
		end
	end
end

//--------------------------------------------------------------------------------------//
// check pc misaligned condition
//--------------------------------------------------------------------------------------//

assign pc_misaligned = (|pc[1:0]);
assign fault_pc = pc_misaligned ? pc : {`ADDR_WIDTH{1'b0}};

//performance counter
wire [31:0] mis_predict_taken_cnt;
en_cnt u_mis_predict_taken_cnt (.clk(cpu_clk), .rstn(cpu_rstn), .en(mis_predict_taken && dec_ready), .cnt (mis_predict_taken_cnt));

wire [31:0] mis_predict_not_taken_cnt;
en_cnt u_mis_predict_not_taken_cnt (.clk(cpu_clk), .rstn(cpu_rstn), .en(mis_predict_not_taken && dec_ready), .cnt (mis_predict_not_taken_cnt));

wire [31:0] jal_dec_cnt;
en_cnt u_jal_dec_cnt (.clk(cpu_clk), .rstn(cpu_rstn), .en(jal_dec), .cnt (jal_dec_cnt));

wire [31:0] jalr_ex_cnt;
en_cnt u_jalr_ex_cnt (.clk(cpu_clk), .rstn(cpu_rstn), .en(jalr_ex), .cnt (jalr_ex_cnt));


endmodule
