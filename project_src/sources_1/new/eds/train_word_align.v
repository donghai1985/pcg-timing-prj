`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/17 09:22:52
// Design Name: 
// Module Name: train_word_align
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
module train_word_align #(
   PARA_GROUP  =  "GROUP"
   ) 
(// clock & reset 
	input            clk_rxg,
	input            clk_rxg_x2,
	input            clk_rxio,
	input            rst_rx,
	  
	input            cmd_start_training,
	input [11:0]     training_word, 
	 
	//data 
	input            datain,
	output[11:0]     dataout_glb,
	// train result
	output reg       data_valid,
	output reg		 training_done,
	output reg[4:0]	 loc_eye_start,
	output reg[4:0]	 loc_eye_mid,
	output reg[4:0]	 loc_eye_end,
	output reg[2:0]  cnt_timeout2,
	output reg[3:0]  loc_word,
	output reg 		 loc_ok
	);
	 
	
//suggest that there r up to 12 LVDS channel 
reg 	    idelay_ld;
reg 	    bitslip ;
reg [4 :0]	idelay_valuein ;
reg     	iodelay2_rst;
//aligment controller
(*async_reg="true"*)reg [5:0]       cmd_start_training_q;  
reg [11:0]	data_curr;  
wire[11:0]	dataout; 
reg [11:0]	cnt_static;
reg [15:0]	cnt_static_err;
  

 localparam          s_FIND_EDGE_1      = 2'd0,
                     s_FIND_EDGE_1_1    = 2'd1,
                     s_FIND_EDGE_2      = 2'd2,    
                     s_FIND_EDGE_3      = 2'd3;    
reg [1:0]         fsm_eye_state=s_FIND_EDGE_1;

localparam	s_IDLE 			=	4'd0,
			s_Reset_1 		=	4'd1,
			s_EYE_DELAY 	=	4'd2,
			s_EYE_SAMPLE 	=	4'd3,
			s_EYE_CHECK		=	4'd4,
			s_EYE_CAL 		=	4'd5,
			s_Reset_2		=	4'd6,
			s_EYE_CENTER 	=	4'd7,
			s_WORD_ALIGN 	=	4'd8,
			s_STATIC		=	4'd9;
(*dont_touch="true"*)reg [3:0]	fsm_align = s_IDLE;
			


/**** Instantiate iser2des_1_to_12 module ****/
		iser2des_1_to_12#(
				.PARA_GROUP	(PARA_GROUP)
			) receiver_lvds1(
			.clk_rxg			(clk_rxg), 
			.clk_rxio			(clk_rxio), 
			.clk_rxg_x2			(clk_rxg_x2), 
			.rst_rx			    (rst_rx), 
			.idelay_ld			(idelay_ld), 
			.idelay_valuein		(idelay_valuein), 
			.bitslip	        (bitslip), 	
			.RST_iodelay	 	(iodelay2_rst), 
			.datain				(datain), 
			.dataout			(dataout)
		); 
		

reg	[7:0]	cnt_delay;

always @(posedge clk_rxg ) 
begin
	if (rst_rx) begin
		cnt_delay	<=	'd0;
		data_valid	<=	1'b0;
	end
	else if(cnt_delay == 'd8) begin
		cnt_delay	<=	cnt_delay;
		data_valid	<=	1'b1;
	end
	else begin
		cnt_delay	<=	cnt_delay + 'd1;
		data_valid	<=	1'b0;
	end
end
		
assign		dataout_glb		=	dataout;
		
		 
/****	BIT & WORD ALIGNMENT ****/ 
//Runs the training algorithm on 1th channel
//(first bit alignment , second word alignment )
//
//Bit alignment:
//	Continuously sample data (data_curr)	and compare the previous data (data_prev)for "n" times
//	if data_curr is the same as data_prev for several times , considering got stable data .
//	Then increase the delay tap and find the edge where data is unstable (data_curr != data_prev)
//	Record the TAPS and calculate the appropriate sample tap 

//Word alignment :
//	Compare the data we get with training word(TP) 
//  the bitslip module of the ISERDES is asserted until the
//  data output matches the training word.

reg [11:0]	dataout_q; 
reg [11:0]	data_prev; 


reg [5:0]	cnt_align;
reg [7:0]	cnt_stable;
reg [7:0]	cnt_samples;
reg [3:0]	cnt_word_step;
reg [11:0]	training_word_in;

(*dont_touch = "yes"*)reg 		data_stable;     
(*dont_touch="true"*)reg[4:0]	cnt_bit_steps;      
(*dont_touch="true"*)reg[4:0]	cnt_bit_stable;

localparam	   stable_real  = 5'd10;		//IDELAYE2原语的时钟发生变化时，该参数也需要进行修改    

always @(posedge clk_rxg ) begin
	if (rst_rx) begin
		fsm_align 		           <= s_IDLE 	;
        fsm_eye_state              <= s_FIND_EDGE_1; 
		iodelay2_rst	           <= 1'b1;
		bitslip 		           <= 1'b0;
		idelay_ld		           <= 1'b0;    
		idelay_valuein             <= 5'd0;		 
		cmd_start_training_q       <= 6'd0; 
		training_done 	           <= 1'b0;
		training_word_in           <= 12'd0;
	end
	else  begin
		iodelay2_rst	           <= 1'b0;
		bitslip 		           <= 1'b0; 
		data_curr		           <= dataout_q;
		dataout_q		           <= dataout_glb;
		cmd_start_training_q[5:1]  <= cmd_start_training_q[4:0]; 
		cmd_start_training_q[0]	   <= cmd_start_training;    		 
		training_word_in 			<= training_word;
		
		case(fsm_align)
			s_IDLE :			begin
									if((cmd_start_training_q[1] == 1'b1)&&(cmd_start_training_q[2] == 1'b0))begin
										loc_eye_start			<= 5'd0;
										loc_eye_mid				<= 5'd0; 
										loc_eye_end				<= 5'd0;
										loc_word 				<= 4'd0;
										cnt_timeout2 			<= 3'd0;
										loc_ok 					<= 1'b0;
										cnt_stable				<= 8'd0;
                                        cnt_bit_stable          <= 5'd0;
                                        cnt_bit_steps           <= 5'd0;  
										cnt_align 				<= 6'b111111; //32 clk wait time 
										cnt_static		        <= 12'd0;
										cnt_static_err			<= 16'd0;
		                                training_done 	        <=	1'b0;
										fsm_align				<= s_Reset_1;
									end
								end
			s_Reset_1 :		begin
									//RESET the IODELAY	
									if(cnt_align == 6'b111111)begin
										iodelay2_rst 		<= 1'b1;
										idelay_valuein  	<= 5'd0	;
									end
									if (cnt_align == 6'b000000) begin
										fsm_align				<= s_EYE_SAMPLE;
                                        fsm_eye_state           <= s_FIND_EDGE_1;
										cnt_stable				<= 8'd0;
										cnt_samples				<= 8'b11111111;//sample times 
										idelay_ld            	<= 1'b1	;
										cnt_align				<= 6'b111110;//one LD clk 
										data_prev	            <= data_curr;
									end
									else begin
										cnt_align				<= cnt_align - 6'd1;
									end
								end
			s_EYE_DELAY	:	begin
									idelay_ld     <=	1'b0	;
									if(cnt_align == 6'b111111)	begin
										idelay_ld     <= 1'b1 ;
										data_prev	  <= data_curr;
									end
			
									if(cnt_align == 6'b000000)	begin
										cnt_align	 <= 6'b111111;
										fsm_align	 <=	s_EYE_SAMPLE	;
									end
									else begin
										cnt_align	 <=	cnt_align	-	6'd1 	;
									end
								end
			s_EYE_SAMPLE :	begin // make "n" samples to check if data is stable
									idelay_ld 	    <=	1'b0;
									
									if (data_curr == data_prev) begin//deglitch
										cnt_stable			<=	cnt_stable	+	8'd1 	;
									end
			
									if(cnt_stable	>	8'd254 )begin// filter 
										data_stable				<=	1'b1 	;
									end
									else begin
										data_stable				<= 1'b0;
									end
									if (cnt_samples == 8'b00000000) begin
										fsm_align				<= s_EYE_CHECK;
										cnt_align				<= 6'b111111;
										cnt_samples				<= 8'b11111111;//sample times 
									end
									else begin
										cnt_samples				<= cnt_samples - 8'd1;
									end
								end
			s_EYE_CHECK	:	begin
									if(cnt_bit_steps ==	5'd31 )begin
										fsm_align	         <= s_EYE_CAL;
                                        loc_eye_end          <= cnt_bit_steps;
									end
									else begin
										fsm_align	    <= s_EYE_DELAY;
										cnt_align	    <= 6'b111111;	
										cnt_stable	    <= 8'd0;
										idelay_valuein  <= idelay_valuein + 5'd1;//delay tap + 1
										cnt_bit_steps   <= cnt_bit_steps + 5'd1;
										case (fsm_eye_state)
                                                s_FIND_EDGE_1:        begin
                                                                            if (data_stable == 1'b0) begin
                                                                                fsm_eye_state        <= s_FIND_EDGE_1_1;
                                                                            end
                                                                            else begin
                                                                                if (cnt_bit_stable == stable_real - 5'd1) begin
                                                                                    fsm_eye_state        <= s_FIND_EDGE_3;
                                                                                    cnt_bit_stable       <= cnt_bit_stable + 5'd1; 
                                                                                    loc_eye_start        <= 5'd0;
                                                                                    loc_eye_end          <= stable_real[4:0];
                                                                                end
                                                                                else cnt_bit_stable       <= cnt_bit_stable + 5'd1;
                                                                            end
                                                                        end
                                                s_FIND_EDGE_1_1:    begin
                                                                            if (data_stable == 1'b1) begin
                                                                                fsm_eye_state        <= s_FIND_EDGE_2;
                                                                                loc_eye_start        <= cnt_bit_steps;
                                                                            end
                                                                            else begin
                                                                                cnt_bit_stable       <= 5'd0;
                                                                            end
                                                                        end
                                                s_FIND_EDGE_2:        begin
                                                                            if (data_stable == 1'b1) begin
                                                                                cnt_bit_stable       <= cnt_bit_stable + 5'd1;
                                                                                loc_eye_end          <= cnt_bit_steps;
                                                                            end
                                                                            else begin
                                                                                fsm_eye_state        <= s_FIND_EDGE_1_1;
                                                                                cnt_bit_stable       <= 5'd0;
                                                                            end
                                                                            
                                                                            if (cnt_bit_stable == stable_real - 5'd1) begin
                                                                                fsm_eye_state        <= s_FIND_EDGE_3;
                                                                            end
                                                                        end
                                                 s_FIND_EDGE_3:    begin
                                                                            if (data_stable == 1'b1) begin
                                                                                cnt_bit_stable       <= cnt_bit_stable + 5'd1;
                                                                                loc_eye_end          <= cnt_bit_steps;
                                                                            end
                                                                            else begin
                                                                                fsm_align            <= s_EYE_CAL;
                                                                                loc_eye_end          <= cnt_bit_steps;
                                                                            end
                                                                     end
                                            endcase

									end
								end
			s_EYE_CAL	:	begin
									loc_eye_mid		<= {1'b0,loc_eye_start[4:1]} + {1'b0,loc_eye_end[4:1]} + (loc_eye_start[0]&loc_eye_end[0]); 
									cnt_bit_stable  <= 5'd0;
									cnt_bit_steps   <= 5'd0;  
									fsm_align		<= s_Reset_2 	;
									cnt_align		<= 6'b111111	;
  							    end
			s_Reset_2	:	begin//RESET the IODELAY	
									iodelay2_rst 		<= 1'b0;
									if(cnt_align == 6'b111111)begin
										iodelay2_rst 		<= 1'b1;
									end
									if (cnt_align == 6'b000000) begin
										cnt_align			<= 6'b111111;
										fsm_align			<= s_EYE_CENTER ;
										
										idelay_ld 	        <=	1'b1	;
										idelay_valuein   	<= loc_eye_mid;
									end
									else begin
										cnt_align				<= cnt_align - 6'd1;
									end
								end
			s_EYE_CENTER:	begin		// Go to the center of a bit data
									idelay_ld 	       <= 1'b0	;
									cnt_word_step	   <= 4'd0;
			
									fsm_align		   <= s_WORD_ALIGN;
								end
			s_WORD_ALIGN:	begin// match training word  , iserdes needs two clk to finish  bitslip operation
									if (cnt_align == 6'b000000) begin
										if (data_curr != training_word_in) begin
											bitslip 		<= 1'b1;
											cnt_align		<= 6'b111111;
											cnt_word_step	<= cnt_word_step + 4'd1;
										end
										else begin
											fsm_align		<= s_STATIC;
											loc_word		<= cnt_word_step;
											cnt_align		<= 6'b111111;
											loc_ok			<= 1'b1;
											cnt_static		<= 12'd0;
											
										end
										if (cnt_word_step == 4'd13) begin
											fsm_align		<= s_STATIC;
											loc_word		<= cnt_word_step;
											cnt_word_step	<= 4'd0;
											cnt_align		<= 6'b111111;
											loc_ok			<= 1'b0;
											cnt_static		<= 12'd0;
										end
									end
									else begin
										cnt_align		<=	cnt_align - 6'd1 ;
									end
								end
			s_STATIC:	begin
									if (cnt_static == 12'd4095) begin 
										if (cnt_static_err == 16'd0) begin
											fsm_align		    <= s_IDLE;
											training_done		<= 1'b1;
											loc_word			<= cnt_word_step;
											cnt_word_step		<= 4'd0;
											cnt_align		    <= 6'b111111;
											loc_ok			    <= 1'b1;
											cnt_static			<= 12'd0;
										end
										else begin
											if (cnt_timeout2 == 3'b111) begin
												fsm_align		<= s_IDLE;
												training_done	<= 1'b1;
												loc_word		<= cnt_word_step;
												cnt_word_step	<= 4'd0;
												cnt_align		<= 6'b111111;
												loc_ok			<= 1'b0;
												cnt_static		<= 12'd0;
												cnt_static_err  <= 16'd0;
											end
											else begin
												cnt_timeout2			<= cnt_timeout2 + 3'd1;
												loc_eye_start			<= 5'd0;
												loc_eye_mid				<= 5'd0; 
												loc_eye_end				<= 5'd0;
												loc_word 				<= 4'd0;
												loc_ok 					<= 1'b0;
												fsm_align				<= s_Reset_1;
												cnt_align 				<= 6'b111111; 
												cnt_static		        <= 12'd0;
												cnt_static_err          <= 16'd0;
											end
										end
									end
									else begin
										cnt_static		<= cnt_static + 12'd1;
									end
									
									if (data_curr != training_word_in) begin
										cnt_static_err		<= cnt_static_err + 16'd1;
									end
								end
			default:    	fsm_align				<= s_IDLE;
		endcase	
	end
end

   
	
endmodule
