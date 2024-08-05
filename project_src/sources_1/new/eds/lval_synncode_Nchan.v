`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/20 13:58:40
// Design Name: 
// Module Name: lval_synncode
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module lval_synncode_Nchan#(
	parameter integer lvds_pairs  = 8   
)
(	
	input				           clk_rxg,
	input				           rst_rx,    
	input [lvds_pairs-1:0]	       data_valid,
 	input[lvds_pairs*12-1:0]       data_in,   
 	output reg		               lval_out, 
	output reg[lvds_pairs*12-1:0]  data_out 
    );

 	wire [lvds_pairs-1:0]          Sync_Valid;  
	wire[lvds_pairs*12-1:0]	   	   Sync_Data;   
 
	genvar			i;    
 	generate
        for (i = 0; i < lvds_pairs; i = i+1) begin:loop
			lval_synncode_0chan  inst_lval_synncode_0chan(
				.clk_rxg 		    (clk_rxg), 	 
				.rst_rx 		    (rst_rx),        
				.data_valid			(data_valid[i]), 
				.data_in			(data_in[12*i+11:12*i]), 
				.Sync_Valid			(Sync_Valid[i]),  
				.Sync_Data		    (Sync_Data[12*i+11:12*i])
			);   
	    end
    endgenerate  	 
	
	always @(posedge clk_rxg)begin
		if(rst_rx)begin 
		    data_out            <= {lvds_pairs*12{1'b0}}; 
			lval_out       		<= 1'b0;
		end
		else begin		  
		    data_out       		<= Sync_Data;
		    lval_out       		<= Sync_Valid[0];
 		end
	end
			
endmodule
