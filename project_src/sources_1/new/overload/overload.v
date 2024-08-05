`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/09/14
// Design Name: PCG
// Module Name: overload
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


module overload (
    // clk & rst
    input   wire                    clk_i               ,
    input   wire                    rst_i               ,
    
    input   wire    [2:0]           motor_state_i           , // motor state
    input   wire                    motor_Ufeed_en_i        , // Ufeed en
    input   wire    [15:0]          motor_Ufeed_i           , // Ufeed

    input   wire                    overload_motor_en_i     ,
    input   wire    [15:0]          overload_ufeed_thre_i   ,
    output  wire    [31:0]          overload_pid_result_o   
);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
fbc_motor fbc_motor_inst(
    // clk & rst
    .clk_i                          ( clk_i                             ),
    .rst_i                          ( rst_i                             ),
    
    .motor_state_i                  ( motor_state_i                     ), // motor state
    .motor_Ufeed_en_i               ( motor_Ufeed_en_i                  ), // Ufeed en
    .motor_Ufeed_i                  ( motor_Ufeed_i                     ), // Ufeed

    .overload_motor_en_i            ( overload_motor_en_i               ),
    .overload_ufeed_thre_i          ( overload_ufeed_thre_i             ),
    .overload_pid_result_o          ( overload_pid_result_o             )
);


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
