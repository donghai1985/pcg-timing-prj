`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: training
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
module training#( 
	parameter lvds_pairs                = 8 
)(   
    input                               clk_rxg, 		 
    input                               clk_rxg_x2, 	 
    input                               clk_ddr, 		 
    input                               rst_rx, 		    
    input [lvds_pairs-1:0]		        sensor_data,
    input [11:0]		                training_word,
    input			                    cmd_start_training, 
    output [lvds_pairs*12-1:0]	        data_par_trained, 
    output[lvds_pairs-1:0]              data_valid, 
    output reg		                    training_done,
	output reg							training_result
);
	
	wire[11:0]				data_par_2D[lvds_pairs-1:0];
	wire[4:0]				loc_eye_start[lvds_pairs-1:0];  
	wire[4:0]				loc_eye_mid[lvds_pairs-1:0];  
	wire[4:0]				loc_eye_end[lvds_pairs-1:0]; 
	wire[2:0]				cnt_timeout2[lvds_pairs-1:0];	
	wire[3:0]				loc_word[lvds_pairs-1:0];
	wire[lvds_pairs-1:0]	loc_ok;
	wire[lvds_pairs-1:0]	training_done_pre;

	
	localparam			s_WR_IDLE		= 4'd0,
						s_WAIT_TIME		= 4'd1,
						s_CHAN_NUM		= 4'd2;
	reg[3:0]			fsm_wr_result	= s_WR_IDLE;
							
	reg[31:0]			cnt_wait_time;
	
	(*async_reg="true"*)reg[5:0]			cmd_start_training_q;
	
	always@(posedge clk_rxg)begin
		if(rst_rx)begin
			fsm_wr_result			 <= s_WR_IDLE;
			cmd_start_training_q	 <= 6'd0; 
			cnt_wait_time			 <= 'd0;
			training_done            <= 1'b0;
			training_result			 <=	1'b0;
		end
		else begin
			cmd_start_training_q[5:1]<= cmd_start_training_q[4:0]; 
			cmd_start_training_q[0]	 <= cmd_start_training;   
			
			case(fsm_wr_result)
				s_WR_IDLE:		begin
									if((cmd_start_training_q[4] == 1'b1)&&(cmd_start_training_q[5] == 1'b0))begin
										cnt_wait_time		<= 'd0;
										training_done       <= 1'b0;
										training_result		<= 1'b0;
										fsm_wr_result		<= s_WAIT_TIME;
									end
								end
				s_WAIT_TIME:	begin
									if(training_done_pre == 8'b1111_1111)begin
										cnt_wait_time	<= 'd0;
										if(cnt_timeout2[0] == 3'b111)begin
											fsm_wr_result		<= s_WR_IDLE;
											training_done       <= 1'b1;
											training_result		<= 1'b0;
										end
										else begin
											fsm_wr_result		<= s_CHAN_NUM;
											training_done       <= 1'b0;
											training_result		<= 1'b0;
										end
									end
									else begin
										cnt_wait_time		<= cnt_wait_time + 'd1;
									end
								end
				s_CHAN_NUM:		begin
									cnt_wait_time		<= 'd0;
									fsm_wr_result		<= s_WR_IDLE;
									training_done       <= 1'b1;
									training_result		<= 1'b1;
								end
				default:        fsm_wr_result		<= s_WR_IDLE;
			endcase
		end
	end
 
// ila_eds ila_eds_inst(
	// .clk(clk_rxg),
	// .probe0(data_par_2D[0]),
	// .probe1(training_done_pre),
	// .probe2({cnt_timeout2[0],fsm_wr_result,loc_ok}),
	// .probe3(cnt_wait_time)
// ); 
 
//train_word_align模块修改为12bit版本，要支持8bit，需要修改该模块   

	genvar			i;    
 	generate
        for (i = 0; i < lvds_pairs; i = i+1) begin:loop
            train_word_align#(
				.PARA_GROUP	("GROUP")
			)   train_word_align ( 
                .clk_rxg				(clk_rxg),	
				.clk_rxg_x2			 	(clk_rxg_x2),
                .clk_rxio				(clk_ddr),	
                .rst_rx				    (rst_rx),	  
				.cmd_start_training		(cmd_start_training),	
				.training_word			(training_word), 
                .datain    				(sensor_data[i]),  
			    .data_valid			    (data_valid[i]), 
                .dataout_glb        	(data_par_2D[i]),
				.training_done			(training_done_pre[i]),              
				.loc_eye_start          (loc_eye_start[i]),                                                     
				.loc_eye_mid			(loc_eye_mid[i]),                                                      
				.loc_eye_end			(loc_eye_end[i]),                  
				.cnt_timeout2			(cnt_timeout2[i]),                   
				.loc_word				(loc_word[i]),   
				.loc_ok					(loc_ok[i]) 				
			);           
			
		    assign	data_par_trained [(i+1)*12-1:i*12]	=  data_par_2D[i]; 
        end
    endgenerate  	    
  		  
			 
endmodule
