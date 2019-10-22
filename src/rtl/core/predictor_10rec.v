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
// File Name: 		predictor_10rec.v 			||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		ten record rec_10			|| 
// History:   							||
//===============================================================

`include "core_defines.vh"

module predictor_10rec #
(
parameter entry_num = 256,
parameter addr_width = $clog2(entry_num)
)
(
input cpu_clk,					
input cpu_rstn,		
input wire [addr_width - 1 : 0] predictor_raddr,
input wire [addr_width - 1 : 0] predictor_waddr,
input wire predictor_wen,
input wire branch_taken_ex,

output wire predictor_rd_data
);

reg[3:0] rec_cnt[entry_num - 1 : 0];
integer j;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		for(j=0; j<entry_num; j=j+1)
		rec_cnt[j] <= 4'h0;
	end
	else
	begin
		for(j=0; j<entry_num; j=j+1)
		begin
			if(rec_cnt[j] == 4'ha)
			begin
				rec_cnt[j] <= 4'ha;
			end
			else if(predictor_wen && (predictor_waddr == j))
			begin
				rec_cnt[j] <= rec_cnt[j] + 4'h1;
			end
		end
	end
end


reg[9:0] rec_10_rd_data;
reg[9:0] rec_10[entry_num - 1 : 0];

integer i;

wire [9:0] rec_10_wloc_rec = rec_10[predictor_waddr];

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		for(i=0; i<entry_num; i=i+1)
		rec_10[i] <= 10'h0;	
	end
	else
	begin
		rec_10_rd_data <= rec_10[predictor_raddr];	
		if(predictor_wen && (rec_cnt[predictor_waddr] != 4'ha))
		begin
			rec_10[predictor_waddr] <= {rec_10_wloc_rec[8:0],branch_taken_ex};
			
		end
	end
end

integer k;
reg[3:0] rec_use_cnt[entry_num-1];
reg [3:0] select_rec;
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		select_rec <= 4'h0;
		for(k=0; k<entry_num; k=k+1)
		rec_use_cnt[k] <= 4'h0;
	end
	else
	begin
		if(rec_cnt[predictor_raddr] == 4'ha)
			select_rec <= rec_use_cnt[predictor_raddr];
		if(rec_cnt[predictor_waddr] == 4'ha)
		begin
			if(predictor_wen)
			begin
				if(rec_use_cnt[predictor_waddr] == 4'ha)
				rec_use_cnt[predictor_waddr] <= 4'h0;
				else
				rec_use_cnt[predictor_waddr] <= rec_use_cnt[predictor_waddr] + 4'h1;
			end
		end
	end
end


assign predictor_rd_data = rec_10_rd_data[select_rec];


endmodule
