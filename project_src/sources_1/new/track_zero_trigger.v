`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2024/8/22
// Design Name: PCG
// Module Name: track_zero_trigger
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module track_zero_trigger #(
    parameter                               TCQ             = 0.1   
)(
    // clk & rst
    input    wire                           clk_i                   ,
    input    wire                           rst_i                   ,

    input    wire                           pmt_start_en_i          ,
    input    wire   [32-1:0]                precise_encode_w_i      ,

    output   wire                           track_trigger_o         ,
    output   wire   [32-1:0]                track_index_o           

);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg     [32-1:0]                encode_zero_latch       = 'd0;
reg                             encode_zero_flag_d      = 'd0;
reg                             encode_less_flag_d      = 'd0;
reg                             encode_zero_flag        = 'd0;

reg     [4-1:0]                 scan_state_d            = 'd0;
reg     [32-1:0]                track_index             = 'd0;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire  encode_greater_flag   = precise_encode_w_i >= encode_zero_latch;
wire  encode_less_flag      = precise_encode_w_i <= encode_zero_latch;


always @(posedge clk_i) scan_state_d        <= #TCQ {scan_state_d[2:0],pmt_start_en_i};
always @(posedge clk_i) encode_less_flag_d  <= #TCQ encode_less_flag;
always @(posedge clk_i) encode_zero_flag    <= #TCQ encode_less_flag_d && encode_greater_flag;
always @(posedge clk_i) encode_zero_flag_d  <= #TCQ encode_zero_flag;

always @(posedge clk_i) begin
    if(~scan_state_d[0] && pmt_start_en_i)
        encode_zero_latch <= #TCQ precise_encode_w_i;
end

always @(posedge clk_i) begin
    if(~scan_state_d[0] && pmt_start_en_i)
        track_index <= #TCQ 'd0;
    else if(track_trigger_o)
        track_index <= #TCQ track_index + 1;
end

assign track_trigger_o  = encode_zero_flag && (~encode_zero_flag_d) && scan_state_d[3];
assign track_index_o    = track_index;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
