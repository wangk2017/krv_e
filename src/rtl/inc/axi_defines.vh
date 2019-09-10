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

//Global defines

`define AXI_ADDR_WIDTH 32
`define AXI_DATA_WIDTH 32
`define AXI_STRB_WIDTH `AXI_DATA_WIDTH/8

//BRESP/PRESP
`define OKAY	2'b00
`define EXOKAY	2'b01
`define SLVERR	2'b10
`define DECERR	2'b11

