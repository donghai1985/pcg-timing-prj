`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: iser2des_1_to_12
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
module iser2des_1_to_12 #(
   PARA_GROUP  =  "GROUP"
   )
(
   input            clk_rxio,// 100M
   input            rst_rx,// rst
   input            clk_rxg,// 100M/6
   input            clk_rxg_x2,
    
   input            idelay_ld,//delay load en
   input [4:0]      idelay_valuein,
   input            bitslip,//word align
   input            RST_iodelay,
   
   input            datain,
   output reg[11:0] dataout    
	);
	
wire	data_ddly;

(* IODELAY_GROUP =  PARA_GROUP *) IDELAYE2 #(
      .CINVCTRL_SEL				("FALSE"),
      .DELAY_SRC				("IDATAIN"), 
      .HIGH_PERFORMANCE_MODE	("FALSE"),
      .IDELAY_TYPE				("VAR_LOAD"),
      .IDELAY_VALUE				(0),
      .PIPE_SEL					("FALSE"),
      .REFCLK_FREQUENCY			(300.0),
      .SIGNAL_PATTERN			("DATA")
   )
   IDELAYE2_inst (
      .CNTVALUEOUT				(),
      .DATAOUT					(data_ddly),        
      .C						(clk_rxg),                    
      .CE						(1'b0),                  
      .CINVCTRL					(1'b0),      
      .CNTVALUEIN				(idelay_valuein),  
      .DATAIN					(1'b0),      
      .IDATAIN					(datain),     
      .INC						(1'b0),                
      .LD						(idelay_ld),                  
      .LDPIPEEN					(1'b0),      
      .REGRST					(RST_iodelay)        
 );
 
 reg bitslip_r;
 reg bitslip_q;
 reg bitslip_qq;
	
    
	always @(posedge clk_rxg_x2) begin
		if (rst_rx) begin
			bitslip_q	<= 1'b0;
			bitslip_qq	<= 1'b0;
			bitslip_r	<= 1'b0;
		end
		else begin
			bitslip_q	<= bitslip;
			bitslip_qq	<= bitslip_q;
			bitslip_r	<= 1'b0;
			
			if (bitslip_q == 1'b1 && bitslip_qq == 1'b0) begin
				bitslip_r	<= 1'b1;
			end
			
		end
	end
	
     // Instantiate the serdes primitive
     ////------------------------------  
	  wire	[5:0]	data_parallel;
	  wire	shift_1;
	  wire	shift_2;
     ISERDESE2
       # (
         .DATA_RATE         ("DDR"),
         .DATA_WIDTH        (6),
         .INTERFACE_TYPE    ("NETWORKING"), 
         .DYN_CLKDIV_INV_EN ("FALSE"),
         .DYN_CLK_INV_EN    ("FALSE"),
         .NUM_CE            (2),
         .OFB_USED          ("FALSE"),
         .IOBDELAY          ("IFD"),                                // Use input at DDLY to output the data on Q
         .SERDES_MODE       ("MASTER"))
       iserdese2_master (
         .Q1                (data_parallel[0]),
         .Q2                (data_parallel[1]),
         .Q3                (data_parallel[2]),
         .Q4                (data_parallel[3]),
         .Q5                (data_parallel[4]),
         .Q6                (data_parallel[5]),
         .Q7                (),
         .Q8                (),
         .SHIFTOUT1         (shift_1),
         .SHIFTOUT2         (shift_2),
         .BITSLIP           (bitslip_r),                             // 1-bit Invoke Bitslip. This can be used with any DATA_WIDTH, cascaded or not.
                                                                  // The amount of bitslip is fixed by the DATA_WIDTH selection.
         .CE1               (1'b1),                        // 1-bit Clock enable input
         .CE2               (1'b1),                        // 1-bit Clock enable input
         .CLK               (clk_rxio),                      // Fast source synchronous clock driven by BUFIO
         .CLKB              (~clk_rxio),                      // Locally inverted fast 
         .CLKDIV            (clk_rxg_x2),                             // Slow clock from BUFR.
         .CLKDIVP           (1'b0),
         .D                 (1'b0),                                // 1-bit Input signal from IOB
         .DDLY              (data_ddly),  // 1-bit Input from Input Delay component 
         .RST               (RST_iodelay),                            // 1-bit Asynchronous reset only.
         .SHIFTIN1          (1'b0),
         .SHIFTIN2          (1'b0),
    // unused connections
         .DYNCLKDIVSEL      (1'b0),
         .DYNCLKSEL         (1'b0),
         .OFB               (1'b0),
         .OCLK              (1'b0),
         .OCLKB             (1'b0),
         .O                 ()
		 );   
		 
	reg	rev_en	;
	reg [2:0]	cnt_bitslip	;
	always @(negedge clk_rxg_x2) begin
		if (rst_rx) begin
			cnt_bitslip		<= 3'b000;
			rev_en			<= 1'b0;
		end
		else begin
			rev_en			<= 1'b0;
			
			if (bitslip_r == 1'b1) begin
				if (cnt_bitslip == 3'd5) begin
					rev_en			<= 1'b1;
					cnt_bitslip		<= 3'd0;
				end
				else begin
					cnt_bitslip		<= cnt_bitslip + 3'd1;
				end
			end
		end
	end



    reg	[5:0]	data_t1	;
    reg	[5:0]	data_q1	;
    reg	[5:0]	data_q2	;
    reg	datain_even	;
	
    always @(posedge clk_rxg_x2)begin
    	if(rst_rx)begin
    		datain_even	<=	1'b1;
    		data_t1	<=	6'd0;
    		data_q1	<=	6'd0;
    		data_q2	<=	6'd0;
    	end
    	else begin
    		if (rev_en == 1'b1) begin
    			datain_even		<= datain_even;
    		end
    		else begin 
    			datain_even		<= ~ datain_even;
    		end
    			
    		if(datain_even == 1'b1)begin
    			data_t1			<= data_parallel;
    		end
    		else begin
    			data_q2			<= data_parallel;
    		end
    		data_q1		<=	data_t1	;
    	end
    end
    

    always @(posedge clk_rxg)begin
    	begin
    		dataout	<=	{data_q1,data_q2};
    	end
    end
	
endmodule
