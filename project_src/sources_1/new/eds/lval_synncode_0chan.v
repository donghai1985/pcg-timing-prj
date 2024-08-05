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
module lval_synncode_0chan 
(	
	input				clk_rxg,
	input				rst_rx,    
    input 	            data_valid,
 	input [11:0]		data_in,   
    output reg 	        Sync_Valid,
 	output reg [11:0]	Sync_Data
    ); 

	
	localparam		SYNC_CODE_1st		= 12'hFFF;
	localparam		SYNC_CODE_2nd		= 12'h000;
	localparam		SYNC_CODE_3rd		= 12'h000;
	localparam		SYNC_CODE_4th_SOL	= 12'hAB0;
	localparam		SYNC_CODE_4th_EOL	= 12'hB60;
	localparam		LVAL_LENGTH			= 16'd256; 	// 2048/8 = 256
	 
	reg[2:0]	FlagSyncCode;
	reg			FlagSyncCodeID;
	reg[2:0]	PrevSyncCodes;
	reg			FlagSyncCode_SOL; 
	reg			data_valid_q;
	always @(posedge clk_rxg)begin
		if(rst_rx)begin 
			PrevSyncCodes		<= 3'd0;
			FlagSyncCodeID		<= 1'b0;
			FlagSyncCode_SOL    <= 1'b0; 
			data_valid_q        <= 1'b0;  
		end			
		else begin
		    data_valid_q        <= data_valid;
 			if(data_valid_q == 1'b1) begin
				PrevSyncCodes[0]    <= FlagSyncCode[0];                      	
				PrevSyncCodes[1]    <= FlagSyncCode[1] & PrevSyncCodes[0]; 	
				PrevSyncCodes[2]    <= FlagSyncCode[2] & PrevSyncCodes[1]; 		
				FlagSyncCode_SOL    <= PrevSyncCodes[2] & FlagSyncCodeID;		 						
			end		

            if(data_valid ==1'b1)begin
                if(data_in == SYNC_CODE_1st)       FlagSyncCode[0]   <= 1'b1;
				else                               FlagSyncCode[0]   <= 1'b0;
                if(data_in == SYNC_CODE_2nd)       FlagSyncCode[1]   <= 1'b1;
				else                               FlagSyncCode[1]   <= 1'b0;
                if(data_in == SYNC_CODE_3rd)       FlagSyncCode[2]   <= 1'b1;
				else                               FlagSyncCode[2]   <= 1'b0;
                if(data_in == SYNC_CODE_4th_SOL)   FlagSyncCodeID 	 <= 1'b1;
				else                               FlagSyncCodeID 	 <= 1'b0;			
			end		 
		end			
	end			
  
	  
	reg			Fsm_Valid_Gen;	
	reg	[11:0]	data_in_q;		
	reg	[11:0]	CntPixelPerLine;	
	always @(posedge clk_rxg ) begin
		if (rst_rx) begin  
			Fsm_Valid_Gen			<= 1'b0;		 		
			Sync_Valid				<= 1'b0;
			data_in_q				<= 12'd0;
			Sync_Data				<= 12'd0;
			CntPixelPerLine			<= 12'd0;
		end
		else begin 
		    data_in_q  				<= data_in; 
		    Sync_Data  				<= data_in_q;  
			case(Fsm_Valid_Gen)
				1'b0:	begin
							if(data_valid_q == 1'b1) begin
								if(FlagSyncCode_SOL == 1'b1) begin
									Sync_Valid			<= 1'b1;
									Fsm_Valid_Gen		<= 1'b1;
								end
								else begin
									Sync_Valid			<= 1'b0;
									Fsm_Valid_Gen		<= 1'b0;
								end
							end
							CntPixelPerLine		<= 12'd0;
						end
				1'b1:	begin
							if(data_valid_q == 1'b1) begin
								if(CntPixelPerLine	== LVAL_LENGTH - 1'b1) begin										
									Fsm_Valid_Gen			<= 1'b0;
									Sync_Valid				<= 1'b0;
									CntPixelPerLine			<= 12'd0;
								end
								else begin
									CntPixelPerLine			<= CntPixelPerLine + 1'b1;
									Sync_Valid				<= 1'b1;
								end		 					
							end
							else begin
								Sync_Valid				<= 1'b0;
							end	 
						end
			endcase
		end
	end			 
	
endmodule
