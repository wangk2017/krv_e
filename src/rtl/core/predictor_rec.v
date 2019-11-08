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
// File Name: 		predictor_rec.v 			||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		record predictor			|| 
// History:   							||
//===============================================================

`include "core_defines.vh"

module predictor_rec #
(
parameter entry_num = 256,
parameter addr_width = $clog2(entry_num),
parameter rec_num = 8
)
(
input cpu_clk,					
input cpu_rstn,		
input wire [addr_width - 1 : 0] predictor_raddr,
input wire [addr_width - 1 : 0] predictor_waddr,
input wire predictor_wen,
input wire branch_taken_ex,

output reg rec_entry_valid,
output wire predictor_rd_data
);

reg[3:0] rec_cnt[entry_num - 1 : 0];
reg entry_valid[entry_num - 1 : 0];

integer j;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	for(j=0; j<entry_num; j=j+1)
	begin
		if(!cpu_rstn)
		begin
			entry_valid[j] <= 1'b0;
		end
		else
		begin
			if(rec_cnt[j] == (rec_num - 1))
			begin
				entry_valid[j] <= 1'b1;
			end
		end
	end
end

reg [3:0] select_rec;
integer k;
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		select_rec <= 4'h0;
		for(k=0; k<entry_num; k=k+1)
		rec_cnt[k] <= 4'h0;
	end
	else
	begin
		select_rec <= rec_cnt[predictor_raddr];
		if(predictor_wen)
		begin
			if(rec_cnt[predictor_waddr] == (rec_num - 1))
			rec_cnt[predictor_waddr] <= 4'h0;
			else
			rec_cnt[predictor_waddr] <= rec_cnt[predictor_waddr] + 4'h1;
		end
	end
end

reg[rec_num - 1 : 0] rec_rd_data;
reg[rec_num - 1 : 0] rec[entry_num - 1 : 0];

//test 
wire [rec_num - 1 : 0] rec_f5 = rec[245];

integer i;

wire [rec_num - 1 : 0] rec_wloc_rec = rec[predictor_waddr];
wire [3:0] wr_rec = rec_cnt[predictor_waddr];

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		rec_rd_data <= {rec_num{1'b0}};
		rec_entry_valid <= 1'b0;
		for(i=0; i<entry_num; i=i+1)
		rec[i] <= {rec_num{1'b0}};	
	end
	else
	begin
		rec_entry_valid <= entry_valid[predictor_raddr];
		rec_rd_data <= rec[predictor_raddr];	
		if(predictor_wen)
		begin
			rec[predictor_waddr][wr_rec] <= branch_taken_ex;
			
		end
	end
end


assign predictor_rd_data = rec_rd_data[select_rec];


endmodule
