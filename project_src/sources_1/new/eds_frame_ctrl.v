`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2024/5/20
// Design Name: PCG
// Module Name: eds_frame_ctrl
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


module eds_frame_ctrl #(
    parameter                               TCQ         = 0.1   
)(
    // clk & rst
    input    wire                           clk_i                       ,
    input    wire                           rst_i                       ,
    // scan control single
    input    wire                           eds_frame_en_i              ,
    input    wire   [3-1:0]                 eds_frame_sel_i             ,
    input    wire   [32-1:0]                eds_frame_hold_i            ,

    output   wire   [3-1:0]                 eds_frame_sel_o             ,   // bit[0]:pmt1; bit[1]:pmt2; bit[2]:pmt3
    output   wire                           eds_frame_en_o                  // bit[0]:scan start;
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam                                  UNIT_MS                     = 'd100000;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg     [3-1:0]                             eds_frame_sel               = 'd0;

reg                                         eds_frame_en                = 'd0;
reg                                         eds_frame_en_d              = 'd0;
reg     [32-1:0]                            eds_frame_hold_cnt          = 'd0;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                        eds_frame_pose;
wire                                        eds_frame_nege;
wire                                        real_scan_pose;
wire                                        real_scan_nege;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> wait definite time pull down start
always @(posedge clk_i) begin
    if(eds_frame_en_i && (|eds_frame_sel_i) && (~eds_frame_en))begin
        eds_frame_en <= #TCQ 'd1;
    end
    else if(eds_frame_hold_cnt == eds_frame_hold_i)begin
        eds_frame_en <= #TCQ 'd0;
    end
end

reg [17-1:0] unit_time_cnt = 'd0;
reg          unit_time_trig = 'd0;
always @(posedge clk_i) begin
    if(eds_frame_en)begin
        if(unit_time_cnt == UNIT_MS - 1)begin
            unit_time_cnt  <= #TCQ 'd0;
            unit_time_trig <= #TCQ 'd1;
        end
        else begin
            unit_time_cnt  <= unit_time_cnt + 1;
            unit_time_trig <= #TCQ 'd0;
        end
    end
    else begin
        unit_time_cnt  <= #TCQ 'd0;
        unit_time_trig <= #TCQ 'd0;
    end
end

always @(posedge clk_i) begin
    if(eds_frame_en)begin
        if(unit_time_trig)
            eds_frame_hold_cnt <= #TCQ eds_frame_hold_cnt + 1;
    end
    else begin 
        eds_frame_hold_cnt <= #TCQ 'd0;
    end
end

always @(posedge clk_i) begin
    eds_frame_en_d <= #TCQ eds_frame_en;
end

assign eds_frame_pose = eds_frame_en    && (~eds_frame_en_d);
assign eds_frame_nege = (~eds_frame_en) && eds_frame_en_d;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

always @(posedge clk_i) begin
    if(eds_frame_en_i && (|eds_frame_sel_i) && (~eds_frame_en))begin
        eds_frame_sel <= #TCQ eds_frame_sel_i;
    end
end

assign eds_frame_sel_o = eds_frame_sel;
assign eds_frame_en_o  = eds_frame_en;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
