`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/27 13:40:10
// Design Name: 
// Module Name: hmc7044_config
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

`timescale 1ns / 1ps

module hmc7044_config #( 
   parameter [11:0] CLKOUT0_DIV  =  12'd24   , 
                    CLKOUT1_DIV  =  12'd24   ,
                    CLKOUT2_DIV  =  12'd24   ,
                    CLKOUT3_DIV  =  12'd24   ,
                    CLKOUT4_DIV  =  12'd24   ,
                    CLKOUT5_DIV  =  12'd24   ,
                    CLKOUT6_DIV  =  12'd24   ,
                    CLKOUT7_DIV  =  12'd24   ,
                    CLKOUT8_DIV  =  12'd24   ,
                    CLKOUT9_DIV  =  12'd24   ,
                    CLKOUT10_DIV =  12'd24   ,
                    CLKOUT11_DIV =  12'd24   ,
                    CLKOUT12_DIV =  12'd24   ,
                    CLKOUT13_DIV =  12'd24   ,
   parameter [1:0] 	VCO_L_H		 =	2'b10	 ,
   parameter [7:0] 	CHANNEL_EN	 =  8'h7f	 ,
   parameter [11:0]	PLL2_R2		 =	12'd0	 ,
   parameter [11:0]	PLL2_N2		 =	12'd32	 ,
   parameter [13:0] CLKEN 		 =	14'b00_0000_0000_0000 
)(                                                                                    
		input                   clk	                  	 ,
		input                   rst                      ,
		input					sync_in					 ,
		output                  HMC7044_SEN              ,
		output                  HMC7044_SCLK             ,
		inout                   HMC7044_SDATA            ,
		
		output              	HMC7044_RESET		     ,                 
		output                  HMC7044_SYNC             ,         
	  
		input                   HMC7044_GPIO1            ,	//default ,pll2 locked  
		input                   HMC7044_GPIO2            ,	//default ,clk phase status     
		output                  HMC7044_GPIO3            ,	//default ,sleep mode   			//no use      
		input                   HMC7044_GPIO4            , 	//default ,pluse generator request  //no use
		
		output	reg				hmc7044_config_ok
);                                                                                                      

                                                                                                                                                                                                       
//--------------------------------------------------------                                                                               
/*
initial                                                                                             
	begin                                                                                               
        mem_reg1[0]  =    24'h009600;   
        mem_reg1[1]  =    24'h009700;                                                                                                    
        mem_reg1[2]  =    24'h009800;                          
        mem_reg1[3]  =    24'h009900;                          
        mem_reg1[4]  =    24'h009a00;                          
        mem_reg1[5]  =    24'h009baa;                          
        mem_reg1[6]  =    24'h009caa;                          
        mem_reg1[7]  =    24'h009daa;                     
        mem_reg1[8]  =    24'h009eaa;                     
        mem_reg1[9]  =    24'h009f4d;                     
        mem_reg1[10] =    24'h00a0df;                     
        mem_reg1[11] =    24'h00a197;   
        mem_reg1[12] =    24'h00a203;   
        mem_reg1[13] =    24'h00a300;                                                                                                    
        mem_reg1[14] =    24'h00a400;                          
        mem_reg1[15] =    24'h00a506;                          
        mem_reg1[16] =    24'h00a61c;                          
        mem_reg1[17] =    24'h00a700;                          
        mem_reg1[18] =    24'h00a806;                          
        mem_reg1[19] =    24'h00a900;                                         
        mem_reg1[20] =    24'h00ab00;                     
        mem_reg1[21] =    24'h00ac20;                     
        mem_reg1[22] =    24'h00ad00;
        mem_reg1[23] =    24'h00ae08;   
        mem_reg1[24] =    24'h00af50;                                                                                                    
        mem_reg1[25] =    24'h00b004;                          
        mem_reg1[26] =    24'h00b10d;                          
        mem_reg1[27] =    24'h00b200;                          
        mem_reg1[28] =    24'h00b300;                        
        mem_reg1[29] =    24'h00b400;                       
        mem_reg1[30] =    24'h00b500;                     
        mem_reg1[31] =    24'h00b600;                     
        mem_reg1[32] =    24'h00b700;                     
        mem_reg1[33] =    24'h00b800;     
        //global
        mem_reg1[34] =    24'h000000;
        mem_reg1[35] =    24'h000100;    
        mem_reg1[36] =    24'h000204;	//00????               
        mem_reg1[37] =    24'h00036e;	//pll1 disenable
        mem_reg1[38] =    24'h00047f;	//14 channel output enable   
        mem_reg1[39] =    24'h000540;	//clkin0/1/2/3 disenable
        mem_reg1[40] =    24'h000600;    
        mem_reg1[41] =    24'h000700;      
        mem_reg1[42] =    24'h000901;	//off SYNC at lock
        //pll2           
        mem_reg1[43] =    24'h003101;    
        mem_reg1[44] =    24'h003201;	//pll2 ref_div                                                                                                
        mem_reg1[45] =    24'h003301;	//pll2 R_div                      
        mem_reg1[46] =    24'h003400;	//pll2 R_div                      
        mem_reg1[47] =    24'h003520;	//pll2 N_div                      
        mem_reg1[48] =    24'h003600;	//pll2 N_div  
        mem_reg1[49] =    24'h003708;   //pll2 CP电流                                                                                                
        mem_reg1[50] =    24'h003818;	//1e????                   
        mem_reg1[51] =    24'h003900;   //                       
        mem_reg1[52] =    24'h003a30;   //                       
        mem_reg1[53] =    24'h003b30;   //             
        //pll1                    
        mem_reg1[54] =    24'h000a06;  //CLKIN0                        
        mem_reg1[55] =    24'h000b06;                     
        mem_reg1[56] =    24'h000c06;                     
        mem_reg1[57] =    24'h000d06;                     
        mem_reg1[58] =    24'h000e07;  //OSCIN
                            
        mem_reg1[59] =    24'h0014e4;	//
        mem_reg1[60] =    24'h001503;	//LOS VAL TIME   
        mem_reg1[61] =    24'h00160c;	//holdover exit control     0f????                                                                                               
        mem_reg1[62] =    24'h001700;                          
        mem_reg1[63] =    24'h001804;                          
        mem_reg1[64] =    24'h001900;                          
        mem_reg1[65] =    24'h001a08;                          
        mem_reg1[66] =    24'h001b18;	//PFD UP/DOWN ENABLE                          
        mem_reg1[67] =    24'h001c01;	//clkin0 prescaler:1                     
        mem_reg1[68] =    24'h001d01;	//clkin1 prescaler:1                     
        mem_reg1[69] =    24'h001e01;	//clkin2 prescaler:1                     
        mem_reg1[70] =    24'h001f01;	//clkin3 prescaler:1                     
        mem_reg1[71] =    24'h002001;	//oscclk prescaler:1
        mem_reg1[72] =    24'h002101;	//R1 LSB:1   
        mem_reg1[73] =    24'h002200;	//R1 MSB:0                                                                                                     
        mem_reg1[74] =    24'h002601;	//N1 LSB:1                           
        mem_reg1[75] =    24'h002700;	//N1 MSB:0                           
        mem_reg1[76] =    24'h00280f;	//LCM CYCLES                          
        mem_reg1[77] =    24'h00290D;	//Auto Switching                          
        mem_reg1[78] =    24'h002a00;	//HoldoffTimer   
        //sysref                      
        mem_reg1[79] =    24'h005a00;	//level control,pluse generator                     
        mem_reg1[80] =    24'h005b06; 	//SYNC CONTROL                    
        mem_reg1[81] =    24'h005c00;	//sysref timer control LSB  <= 4MHz                     
        mem_reg1[82] =    24'h005d08;	//sysref timer control MSB    08????
       
        mem_reg1[83] =    24'h004600;	//GPI1 setting                     
        mem_reg1[84] =    24'h004700;	//GPI2 setting                     
        mem_reg1[85] =    24'h004809;	//GPI3 setting                     
        mem_reg1[86] =    24'h004900;	//GPO4 setting 
        mem_reg1[87] =    24'h00502b;	//GPO1 setting               
        mem_reg1[88] =    24'h005133;	//GPO2 setting              
        mem_reg1[89] =    24'h005200;	//GPO3 setting                     
        mem_reg1[90] =    24'h005383;	//GPO4 setting
        mem_reg1[91] =    24'h005403;	//SDATA control
                             
        mem_reg1[92] =    24'h006400;	//pll2 external vco control                     
        mem_reg1[93] =    24'h006500;	//delay low power mode                     
        mem_reg1[94] =    24'h007000;	//PLL1 alarm mask
        mem_reg1[95] =    24'h007110;	//Alarm Mask Control                         
            
        //clock distribute
        mem_reg1[96]  =    {16'h00c8,4'hf,3'b001,CLKEN[0]};	//ch0 mode,channel enable   
        mem_reg1[97]  =    {16'h00c9,CLKOUT0_DIV[7:0]};//ch0  divider lsb [7:0]                                                                                                 
        mem_reg1[98]  =    {16'h00ca,4'h0,CLKOUT0_DIV[11:8]};//ch0  divider Msb [11:8]                               
        mem_reg1[99]  =    24'h00cb00;	//ch0 fine delay step,step size:25ps    
        mem_reg1[100] =    24'h00cc00;	//ch0 coarse digital delay                       
        mem_reg1[101] =    24'h00cd00;	//ch0 multislip digital delay,lsb [7:0]                               
        mem_reg1[102] =    24'h00ce00;	//ch0 multislip digital delay Msb [11:8]                              
        mem_reg1[103] =    24'h00cf00;	//ch0 divider output                          
        mem_reg1[104] =    24'h00d010;	//ch0 force mute,nomal,lvds mode                                       
        
        mem_reg1[105] =    {16'h00d2,4'hf,3'b001,CLKEN[1]};	//ch1 mode,channel enable                                      
        mem_reg1[106] =    {16'h00d3,CLKOUT1_DIV[7:0]};//ch1  divider lsb [7:0]                                             
        mem_reg1[107] =    {16'h00d4,4'h0,CLKOUT1_DIV[11:8]};//ch1  divider Msb [11:8]                    
        mem_reg1[108] =    24'h00d500;	//ch1 fine delay step,step size:25ps         
        mem_reg1[109] =    24'h00d600;	//ch1 coarse digital delay                                                                                                                    
        mem_reg1[110] =    24'h00d700;	//ch1 multislip digital delay,lsb [7:0]                             
        mem_reg1[111] =    24'h00d800;	//ch1 multislip digital delay Msb [11:8]                            
        mem_reg1[112] =    24'h00d900;	//ch1 divider output                                                
        mem_reg1[113] =    24'h00da10;	//ch1 force mute,nomal,lvds mode                                                           
        
        mem_reg1[114] =    {16'h00dc,4'hf,3'b001,CLKEN[2]};	//ch2 mode,channel enable                                     
        mem_reg1[115] =    {16'h00dd,CLKOUT2_DIV[7:0]};//ch2  divider lsb [7:0]                                             
        mem_reg1[116] =    {16'h00de,4'h0,CLKOUT2_DIV[11:8]};//ch2  divider Msb [11:8]                                     
        mem_reg1[117] =    24'h00df00;	//ch2 fine delay step,step size:25ps                          
        mem_reg1[118] =    24'h00e000;	//ch2 coarse digital delay               
        mem_reg1[119] =    24'h00e100;	//ch2 multislip digital delay,lsb [7:0]     
        mem_reg1[120] =    24'h00e200;	//ch2 multislip digital delay Msb [11:8]       
        mem_reg1[121] =    24'h00e300;	//ch2 divider output                                                                                                                     
        mem_reg1[122] =    24'h00e410;	//ch2 force mute,nomal,lvds mode                                                      
       
        mem_reg1[123] =    {16'h00e6,4'hf,3'b001,CLKEN[3]};	//ch3 mode,channel enable                                           
        mem_reg1[124] =    {16'h00e7,CLKOUT3_DIV[7:0]};//ch1  divider lsb [7:0]                                                  
        mem_reg1[125] =    {16'h00e8,4'h0,CLKOUT3_DIV[11:8]};//ch1  divider Msb [11:8]                                           
        mem_reg1[126] =    24'h00e900;	//ch3 fine delay step,step size:25ps                           
        mem_reg1[127] =    24'h00ea00;	//ch3 coarse digital delay                                     
        mem_reg1[128] =    24'h00eb00;	//ch3 multislip digital delay,lsb [7:0]                        
        mem_reg1[129] =    24'h00ec00;	//ch3 multislip digital delay Msb [11:8]        
        mem_reg1[130] =    24'h00ed00;	//ch3 divider output                      
        mem_reg1[131] =    24'h00ee10;	//ch3 force mute,nomal,lvds mode                                                                                                              
       
        mem_reg1[132] =    {16'h00f0,4'hf,3'b001,CLKEN[4]};	//ch4 mode,channel enable                                           
        mem_reg1[133] =    {16'h00f1,CLKOUT4_DIV[7:0]};//ch4  divider lsb [7:0]                                                 
        mem_reg1[134] =    {16'h00f2,4'h0,CLKOUT4_DIV[11:8]};//ch4  divider Msb [11:8]                                           
        mem_reg1[135] =    24'h00f300;	//ch4 fine delay step,step size:25ps                                
        mem_reg1[136] =    24'h00f400;	//ch4 coarse digital delay                                          
        mem_reg1[137] =    24'h00f500;	//ch4 multislip digital delay,lsb [7:0]                        
        mem_reg1[138] =    24'h00f600;	//ch4 multislip digital delay Msb [11:8]                       
        mem_reg1[139] =    24'h00f700;	//ch4 divider output                                           
        mem_reg1[140] =    24'h00f810;	//ch4 force mute,nomal,lvds mode                                        
        
        mem_reg1[141] =    {16'h00fa,4'hf,3'b001,CLKEN[5]};	//ch5 mode,channel enable                                           
        mem_reg1[142] =    {16'h00fb,CLKOUT5_DIV[7:0]};//ch5  divider lsb [7:0]                                                  
        mem_reg1[143] =    {16'h00fc,4'h0,CLKOUT5_DIV[11:8]};//ch5  divider Msb [11:8]                                           
        mem_reg1[144] =    24'h00fd00;	//ch5 fine delay step,step size:25ps                                
        mem_reg1[145] =    24'h00fe00;	//ch5 coarse digital delay                                     
        mem_reg1[146] =    24'h00ff00;	//ch5 multislip digital delay,lsb [7:0]                        
        mem_reg1[147] =    24'h010000;	//ch5 multislip digital delay Msb [11:8]                       
        mem_reg1[148] =    24'h010100;	//ch5 divider output                           
        mem_reg1[149] =    24'h010210;	//ch5 force mute,nomal,lvds mode                                                             
       
        mem_reg1[150] =    {16'h0104,4'hf,3'b001,CLKEN[6]};	//ch6 mode,channel enable                                           
        mem_reg1[151] =    {16'h0105,CLKOUT6_DIV[7:0]};//ch6  divider lsb [7:0]                                               
        mem_reg1[152] =    {16'h0106,4'h0,CLKOUT6_DIV[11:8]};//ch6  divider Msb [11:8]                                           
        mem_reg1[153] =    24'h010700;	//ch6 fine delay step,step size:25ps                           
        mem_reg1[154] =    24'h010800;	//ch6 coarse digital delay                                     
        mem_reg1[155] =    24'h010900;	//ch6 multislip digital delay,lsb [7:0]                        
        mem_reg1[156] =    24'h010a00;	//ch6 multislip digital delay Msb [11:8]       
        mem_reg1[157] =    24'h010b00;	//ch6 divider output                                                
        mem_reg1[158] =    24'h010c10;	//ch6 force mute,nomal,lvds mode                                                             
     
        mem_reg1[159] =    {16'h010e,4'hf,3'b001,CLKEN[7]};	//ch7 mode,channel enable                                           
        mem_reg1[160] =    {16'h010f,CLKOUT7_DIV[7:0]};//ch7  divider lsb [7:0]                                                  
        mem_reg1[161] =    {16'h0110,4'h0,CLKOUT7_DIV[11:8]};//ch7  divider Msb [11:8]                                      
        mem_reg1[162] =    24'h011100;	//ch7 fine delay step,step size:25ps                           
        mem_reg1[163] =    24'h011200;	//ch7 coarse digital delay                                     
        mem_reg1[164] =    24'h011300;	//ch7 multislip digital delay,lsb [7:0]    
        mem_reg1[165] =    24'h011400;	//ch7 multislip digital delay Msb [11:8]                            
        mem_reg1[166] =    24'h011500;	//ch7 divider output                                                
        mem_reg1[167] =    24'h011610;	//ch7 force mute,nomal,lvds mode                                                              
      
        mem_reg1[168] =    {16'h0118,4'hf,3'b001,CLKEN[8]};	//ch8 mode,channel enable                                           
        mem_reg1[169] =    {16'h0119,CLKOUT8_DIV[7:0]};//ch8  divider lsb [7:0]                                                   
        mem_reg1[170] =    {16'h011a,4'h0,CLKOUT8_DIV[11:8]};//ch8  divider Msb [11:8]                                      
        mem_reg1[171] =    24'h011b00;	//ch8 fine delay step,step size:25ps                           
        mem_reg1[172] =    24'h011c00;	//ch8 coarse digital delay                     
        mem_reg1[173] =    24'h011d00;	//ch8 multislip digital delay,lsb [7:0]                             
        mem_reg1[174] =    24'h011e00;	//ch8 multislip digital delay Msb [11:8]                            
        mem_reg1[175] =    24'h011f00;	//ch8 divider output                                                
        mem_reg1[176] =    24'h012010;	//ch8 force mute,nomal,lvds mode   
                                                                      
        mem_reg1[177] =    {16'h0122,4'hf,3'b001,CLKEN[9]};	//ch9 mode,channel enable                                      
        mem_reg1[178] =    {16'h0123,CLKOUT9_DIV[7:0]};//ch9  divider lsb [7:0]                                             
        mem_reg1[179] =    {16'h0124,4'h0,CLKOUT9_DIV[11:8]};//ch9  divider Msb [11:8]                                      
        mem_reg1[180] =    24'h012500;	//ch9 fine delay step,step size:25ps      
        mem_reg1[181] =    24'h012600;	//ch9 coarse digital delay                                     
        mem_reg1[182] =    24'h012700;	//ch9 multislip digital delay,lsb [7:0]                        
        mem_reg1[183] =    24'h012800;	//ch9 multislip digital delay Msb [11:8]                       
        mem_reg1[184] =    24'h012900;	//ch9 divider output                           
        mem_reg1[185] =    24'h012a10;	//ch9 force mute,nomal,lvds mode   
                                                                      
        mem_reg1[186] =    {16'h012c,4'hf,3'b001,CLKEN[10]};	//ch10 mode,channel enable                                           
        mem_reg1[187] =    {16'h012d,CLKOUT10_DIV[7:0]};//ch10  divider lsb [7:0]                                                 
        mem_reg1[188] =    {16'h012e,4'h0,CLKOUT10_DIV[11:8]};//ch10  divider Msb [11:8]                                          
        mem_reg1[189] =    24'h012f00;	//ch10 fine delay step,step size:25ps                           
        mem_reg1[190] =    24'h013000;	//ch10 coarse digital delay                                     
        mem_reg1[191] =    24'h013100;	//ch10 multislip digital delay,lsb [7:0]                        
        mem_reg1[192] =    24'h013200;	//ch10 multislip digital delay Msb [11:8]   
        mem_reg1[193] =    24'h013300;	//ch10 divider output                                                
        mem_reg1[194] =    24'h013410;	//ch10 force mute,nomal,lvds mode  
                                                                           
        mem_reg1[195] =    {16'h0136,4'hf,3'b001,CLKEN[11]};	//ch11 mode,channel enable                                           
        mem_reg1[196] =    {16'h0137,CLKOUT11_DIV[7:0]};//ch11  divider lsb [7:0]                                                  
        mem_reg1[197] =    {16'h0138,4'h0,CLKOUT11_DIV[11:8]};//ch11  divider Msb [11:8]                                      
        mem_reg1[198] =    24'h013900;	//ch11 fine delay step,step size:25ps                           
        mem_reg1[199] =    24'h013a00;	//ch11 coarse digital delay                                     
        mem_reg1[200] =    24'h013b00;	//ch11 multislip digital delay,lsb [7:0]        
        mem_reg1[201] =    24'h013c00;	//ch11 multislip digital delay Msb [11:8]                            
        mem_reg1[202] =    24'h013d00;	//ch11 divider output                                                
        mem_reg1[203] =    24'h013e10;	//ch11 force mute,nomal,lvds mode   
                                                                        
        mem_reg1[204] =    {16'h0140,4'hf,3'b001,CLKEN[12]};	//ch12 mode,channel enable                                           
        mem_reg1[205] =    {16'h0141,CLKOUT12_DIV[7:0]};//ch12  divider lsb [7:0]                                          
        mem_reg1[206] =    {16'h0142,4'h0,CLKOUT12_DIV[11:8]};//ch12  divider Msb [11:8]                                      
        mem_reg1[207] =    24'h014300;	//ch12 fine delay step,step size:25ps                           
        mem_reg1[208] =    24'h014400;	//ch12 coarse digital delay                
        mem_reg1[209] =    24'h014500;	//ch12 multislip digital delay,lsb [7:0]                        
        mem_reg1[210] =    24'h014600;	//ch12 multislip digital delay Msb [11:8]       
        mem_reg1[211] =    24'h014700;	//ch12 divider output                                                
        mem_reg1[212] =    24'h014810;	//ch12 force mute,nomal,lvds mode   
                                                                      
        mem_reg1[213] =    {16'h014a,4'hf,3'b001,CLKEN[13]};	//ch13 mode,channel enable                                           
        mem_reg1[214] =    {16'h014b,CLKOUT13_DIV[7:0]};//ch13  divider lsb [7:0]                                                  
        mem_reg1[215] =    {16'h014c,4'h0,CLKOUT13_DIV[11:8]};//ch13  divider Msb [11:8]                                      
        mem_reg1[216] =    24'h014d00;	//ch13 fine delay step,step size:25ps                           
        mem_reg1[217] =    24'h014e00;	//ch13 coarse digital delay                                     
        mem_reg1[218] =    24'h014f00;	//ch13 multislip digital delay,lsb [7:0]   
        mem_reg1[219] =    24'h015000;	//ch13 multislip digital delay Msb [11:8]                       
        mem_reg1[220] =    24'h015100;	//ch13 divider output                                           
        mem_reg1[221] =    24'h015210;	//ch13 force mute,nomal,lvds mode   
                                              
        mem_reg1[222] =    24'h000102;
        mem_reg1[223] =    24'h000000;
        mem_reg1[224] =    24'h000100;
		mem_reg1[225] =    24'h000180;
		mem_reg1[226] =    24'h000100;
	end                                                                                                 
*/
// config  hmc7044 from spi interface//                                                                    
wire             		spi_busy                ;                                                   
reg        [7:0] 		cfg_cnt  = 8'd0         ;                                                    
reg              		send_spi_vld = 1'b0     ;                                                    
// reg        [23:0]		mem_reg1[9:0]           ;                                                    
reg        [31:0]		cfg_delay = 32'd0       ; 

reg		   [31:0]		delay_cnt;

reg		   [4:0]		cfg_state;
wire	   [23:0]		hm7044_cfg_rom_data;
wire	   [23:0]		hm7044_cfg_rom_data_temp;

wire			  		rd_add_en;
wire       [12:0]		rd_add;
wire					rd_data_en;
wire       [7:0]		rd_data; 

assign		HMC7044_SYNC	=	1'b0;//sync_in;

assign		hm7044_cfg_rom_data_temp	=	(cfg_cnt == 'd37)	?	{16'h0003,3'b001,VCO_L_H,3'b110}	:
											(cfg_cnt == 'd38)	?	{16'h0004,CHANNEL_EN}				:
											(cfg_cnt == 'd45)	?	{16'h0033,PLL2_R2[7:0]}				:
											(cfg_cnt == 'd46)	?	{16'h0034,4'h0,PLL2_R2[11:8]}		:
											(cfg_cnt == 'd47)	?	{16'h0035,PLL2_N2[7:0]}				:
											(cfg_cnt == 'd48)	?	{16'h0036,4'h0,PLL2_N2[11:8]}		:
											(cfg_cnt == 'd96)	?	{16'h00c8,4'hf,3'b001,CLKEN[0]}		:
											(cfg_cnt == 'd97)	?	{16'h00c9,CLKOUT0_DIV[7:0]}			:
											(cfg_cnt == 'd98)	?	{16'h00ca,4'h0,CLKOUT0_DIV[11:8]}	:
											(cfg_cnt == 'd105)	?	{16'h00d2,4'hf,3'b001,CLKEN[1]}		:
											(cfg_cnt == 'd106)	?	{16'h00d3,CLKOUT1_DIV[7:0]}			:
											(cfg_cnt == 'd107)	?	{16'h00d4,4'h0,CLKOUT1_DIV[11:8]}	:
											(cfg_cnt == 'd114)	?	{16'h00dc,4'hf,3'b001,CLKEN[2]}		:
											(cfg_cnt == 'd115)	?	{16'h00dd,CLKOUT2_DIV[7:0]}			:
											(cfg_cnt == 'd115)	?	{16'h00de,4'h0,CLKOUT2_DIV[11:8]}	:
											(cfg_cnt == 'd123)	?	{16'h00e6,4'hf,3'b001,CLKEN[3]}		:
											(cfg_cnt == 'd124)	?	{16'h00e7,CLKOUT3_DIV[7:0]}			:
											(cfg_cnt == 'd125)	?	{16'h00e8,4'h0,CLKOUT3_DIV[11:8]}	:
											(cfg_cnt == 'd132)	?	{16'h00f0,4'hf,3'b001,CLKEN[4]}		:
											(cfg_cnt == 'd133)	?	{16'h00f1,CLKOUT4_DIV[7:0]}			:
											(cfg_cnt == 'd134)	?	{16'h00f2,4'h0,CLKOUT4_DIV[11:8]}	:
											(cfg_cnt == 'd141)	?	{16'h00fa,4'hf,3'b001,CLKEN[5]}		:
											(cfg_cnt == 'd142)	?	{16'h00fb,CLKOUT5_DIV[7:0]}			:
											(cfg_cnt == 'd143)	?	{16'h00fc,4'h0,CLKOUT5_DIV[11:8]}	:
											(cfg_cnt == 'd150)	?	{16'h0104,4'hf,3'b001,CLKEN[6]}		:
											(cfg_cnt == 'd151)	?	{16'h0105,CLKOUT6_DIV[7:0]}			:
											(cfg_cnt == 'd152)	?	{16'h0106,4'h0,CLKOUT6_DIV[11:8]}	:
											(cfg_cnt == 'd159)	?	{16'h010e,4'hf,3'b001,CLKEN[7]}		:
											(cfg_cnt == 'd160)	?	{16'h010f,CLKOUT7_DIV[7:0]}			:
											(cfg_cnt == 'd161)	?	{16'h0110,4'h0,CLKOUT7_DIV[11:8]}	:
											(cfg_cnt == 'd168)	?	{16'h0118,4'hf,3'b001,CLKEN[8]}		:
											(cfg_cnt == 'd169)	?	{16'h0119,CLKOUT8_DIV[7:0]}			:
											(cfg_cnt == 'd170)	?	{16'h011a,4'h0,CLKOUT8_DIV[11:8]}	:
											(cfg_cnt == 'd177)	?	{16'h0122,4'hf,3'b001,CLKEN[9]}		:
											(cfg_cnt == 'd178)	?	{16'h0123,CLKOUT9_DIV[7:0]}			:
											(cfg_cnt == 'd179)	?	{16'h0124,4'h0,CLKOUT9_DIV[11:8]}	:
											(cfg_cnt == 'd186)	?	{16'h012c,4'hf,3'b001,CLKEN[10]}	:
											(cfg_cnt == 'd187)	?	{16'h012d,CLKOUT10_DIV[7:0]}		:
											(cfg_cnt == 'd188)	?	{16'h012e,4'h0,CLKOUT10_DIV[11:8]}	:
											(cfg_cnt == 'd195)	?	{16'h0136,4'hf,3'b001,CLKEN[11]}	:
											(cfg_cnt == 'd196)	?	{16'h0137,CLKOUT11_DIV[7:0]}		:
											(cfg_cnt == 'd197)	?	{16'h0138,4'h0,CLKOUT11_DIV[11:8]}	:
											(cfg_cnt == 'd204)	?	{16'h0140,4'hf,3'b001,CLKEN[12]}	:
											(cfg_cnt == 'd205)	?	{16'h0141,CLKOUT12_DIV[7:0]}		:
											(cfg_cnt == 'd206)	?	{16'h0142,4'h0,CLKOUT12_DIV[11:8]}	:
											(cfg_cnt == 'd213)	?	{16'h014a,4'hf,3'b001,CLKEN[13]}	:
											(cfg_cnt == 'd214)	?	{16'h014b,CLKOUT13_DIV[7:0]}		:
											(cfg_cnt == 'd215)	?	{16'h014c,4'h0,CLKOUT13_DIV[11:8]}	:	hm7044_cfg_rom_data;

hmc7044_cfg_rom hmc7044_cfg_rom_inst(
	.clka(clk),
	.addra(cfg_cnt),
	.douta(hm7044_cfg_rom_data)
);

//----------------------------------------------                                                                                             
always@(posedge clk or posedge rst)                                                                                                  
begin                                                                                                                                    
    if(rst) begin                                                                                                                              
        cfg_delay 		<= 32'd0; 
	end
    else if(cfg_delay < 32'd1100000) begin                                                                                    
        cfg_delay <= cfg_delay + 'b1;   
	end
    else begin
		cfg_delay <= cfg_delay;
	end
end   

assign	HMC7044_RESET = (cfg_delay >= 32'd1000000) ? 1'b0 : 1'b1;	//reset 1ms                                  
                                                
always@(posedge clk or posedge rst)                                                                                                  
begin                                                                                                                                    
    if(rst) begin
		cfg_state	<=	'd0;
	end
	else if(cfg_delay < 32'd1100000) begin
		cfg_state	<=	'd0;
	end
	else begin
		case(cfg_state)
		5'd0: begin
			if(cfg_cnt	< 'd222) begin
				cfg_state	<=	'd1;
			end
			else begin
				cfg_state	<=	'd3;
			end
		end
		5'd1: begin
			if(spi_busy) begin
				cfg_state	<=	'd2;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd2: begin
			if(~spi_busy) begin
				cfg_state	<=	'd0;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		
		5'd3: begin
			if(delay_cnt == 'd2000000) begin
				cfg_state	<=	'd4;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd4: begin
			if(cfg_cnt	< 'd225) begin
				cfg_state	<=	'd5;
			end
			else begin
				cfg_state	<=	'd7;
			end
		end
		5'd5: begin
			if(spi_busy) begin
				cfg_state	<=	'd6;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd6: begin
			if(~spi_busy) begin
				cfg_state	<=	'd4;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd7: begin
			if(HMC7044_GPIO1) begin
				cfg_state	<=	'd8;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd8: begin
			if(cfg_cnt	< 'd227) begin
				cfg_state	<=	'd9;
			end
			else begin
				cfg_state	<=	'd11;
			end
		end
		5'd9: begin
			if(spi_busy) begin
				cfg_state	<=	'd10;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd10: begin
			if(~spi_busy) begin
				cfg_state	<=	'd8;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		
		
		5'd11: begin
			if(HMC7044_GPIO1 && HMC7044_GPIO2) begin
				cfg_state	<=	'd12;
			end
			else begin
				cfg_state	<=	cfg_state;
			end
		end
		5'd12: begin
			cfg_state	<=	cfg_state;
		end
		default: begin
			cfg_state	<=	'd0;
		end
		endcase
	end
end

always@(posedge clk or posedge rst)                                                                                                  
begin                                                                                                                                    
    if(rst) begin
		send_spi_vld		<= 'd0;
		cfg_cnt 			<= 8'd0;
		delay_cnt			<= 'd0;
		hmc7044_config_ok	<= 'd0;
	end
	else if(cfg_delay < 32'd1100000) begin
		send_spi_vld		<= 'd0;
		cfg_cnt 			<= 8'd0;
		delay_cnt			<= 'd0;
		hmc7044_config_ok	<= 'd0;
	end
	else begin
		case(cfg_state)
		5'd0: begin
			delay_cnt			<= 'd0;
			hmc7044_config_ok	<= 'd0;
			cfg_cnt 			<= cfg_cnt;
			if(cfg_cnt	< 'd222) begin
				send_spi_vld		<= 'd1;
			end
			else begin
				send_spi_vld		<= 'd0;
			end
		end
		5'd1: begin
			hmc7044_config_ok	<= 'd0;
			send_spi_vld		<= 'd0;
			cfg_cnt 			<= cfg_cnt;
			delay_cnt			<= 'd0;
		end
		5'd2: begin
			hmc7044_config_ok	<= 'd0;
			send_spi_vld		<= 'd0;
			delay_cnt			<= 'd0;
			if(~spi_busy) begin
				cfg_cnt 		<= cfg_cnt + 'd1;
			end
			else begin
				cfg_cnt 		<= cfg_cnt;
			end
		end
		5'd3: begin
			hmc7044_config_ok	<= 'd0;
			send_spi_vld		<= 'd0;
			cfg_cnt 			<= cfg_cnt;
			if(delay_cnt == 'd2000000) begin
				delay_cnt	<= 'd0;
			end
			else begin
				delay_cnt	<=	delay_cnt + 'd1;
			end
		end
		5'd4: begin
			delay_cnt			<= 'd0;
			hmc7044_config_ok	<= 'd0;
			cfg_cnt 			<= cfg_cnt;
			if(cfg_cnt	< 'd225) begin
				send_spi_vld		<= 'd1;
			end
			else begin
				send_spi_vld		<= 'd0;
			end
		end
		5'd5: begin
			hmc7044_config_ok	<= 'd0;
			send_spi_vld		<= 'd0;
			cfg_cnt 			<= cfg_cnt;
			delay_cnt			<= 'd0;
		end
		5'd6: begin
			hmc7044_config_ok	<= 'd0;
			send_spi_vld		<= 'd0;
			delay_cnt			<= 'd0;
			if(~spi_busy) begin
				cfg_cnt 		<= cfg_cnt + 'd1;
			end
			else begin
				cfg_cnt 		<= cfg_cnt;
			end
		end
		5'd7: begin
			hmc7044_config_ok	<= 'd0;
			send_spi_vld		<= 'd0;
			cfg_cnt 			<= cfg_cnt;
			delay_cnt			<= 'd0;
		end
		5'd8: begin
			delay_cnt			<= 'd0;
			hmc7044_config_ok	<= 'd0;
			cfg_cnt 			<= cfg_cnt;
			if(cfg_cnt	< 'd227) begin
				send_spi_vld		<= 'd1;
			end
			else begin
				send_spi_vld		<= 'd0;
			end
		end
		5'd9: begin
			hmc7044_config_ok	<= 'd0;
			send_spi_vld		<= 'd0;
			cfg_cnt 			<= cfg_cnt;
			delay_cnt			<= 'd0;
		end
		5'd10: begin
			hmc7044_config_ok	<= 'd0;
			send_spi_vld		<= 'd0;
			delay_cnt			<= 'd0;
			if(~spi_busy) begin
				cfg_cnt 		<= cfg_cnt + 'd1;
			end
			else begin
				cfg_cnt 		<= cfg_cnt;
			end
		end
		
		5'd11: begin
			hmc7044_config_ok	<= 'd0;
			send_spi_vld		<= 'd0;
			cfg_cnt 			<= 8'd0;
			delay_cnt			<= 'd0;
		end
		5'd12: begin	
			send_spi_vld		<= 'd0;
			cfg_cnt 			<= 8'd0;
			delay_cnt			<= 'd0;
			hmc7044_config_ok	<= 'd1;				
		end
		default: begin
			send_spi_vld		<= 'd0;
			cfg_cnt 			<= 8'd0;
			delay_cnt			<= 'd0;
			hmc7044_config_ok	<= 'd0;
		end
		endcase
	end
end
												                                                                                                                                          
                                                                                                      
//-----------------------------------------------------------       
hmc7044_spi_if hmc7044_spi_if_inst(
	.clk(clk),
	.rst_n(~rst),
	.wr_data_en(send_spi_vld),
	.wr_data(hm7044_cfg_rom_data_temp),
	.rd_add_en(rd_add_en),		//reserved
	.rd_add(rd_add),			//reserved
	.spi_csn(HMC7044_SEN),
	.spi_clk(HMC7044_SCLK),		//spi freq max 10MHz
    .spi_data(HMC7044_SDATA),
    .spi_busy(spi_busy),
	.rd_data_en(rd_data_en),
	.rd_data(rd_data)
);

// vio_2 vio_2_inst(
		// .clk(clk),           			// input wire clk
		// .probe_in0(rd_data),  		// input wire [7 : 0] probe_in0
		
		// .probe_out0(rd_add_en),// output wire [0 : 0] probe_out0
		// .probe_out1(rd_add),// output wire [12 : 0] probe_out1
		// .probe_out2(HMC7044_GPIO3)
// );	                                                                                                                                                                   
                                                                                                      
endmodule
