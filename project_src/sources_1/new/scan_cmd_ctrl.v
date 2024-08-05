`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2024/1/10
// Design Name: PCG
// Module Name: scan_cmd_ctrl
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


module scan_cmd_ctrl #(
    parameter                               TCQ         = 0.1   
)(
    // clk & rst
    input    wire                           clk_i                       ,
    input    wire                           rst_i                       ,
    // scan control single
    input    wire                           real_scan_flag_i            ,
    input    wire   [3-1:0]                 real_scan_sel_i             ,
    input    wire   [32-1:0]                pmt_adc_start_data_i        ,
    input    wire                           pmt_adc_start_vld_i         ,
    input    wire   [32-1:0]                pmt_adc_start_hold_i        ,

    output   wire   [3-1:0]                 pmt_scan_cmd_sel_o          ,   // bit[0]:pmt1; bit[1]:pmt2; bit[2]:pmt3
    output   wire   [4-1:0]                 pmt_scan_cmd_o                  // bit[0]:scan start; bit[1]:scan test
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam                                  UNIT_MS                     = 'd100000;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg     [3-1:0]                             pmt_scan_cmd_sel            = 'd0;
reg     [4-1:0]                             pmt_scan_cmd                = 'd0;

reg                                         pmt_adc_start_en            = 'd0;
reg                                         pmt_adc_start_en_d          = 'd0;
reg     [32-1:0]                            pmt_adc_start_cnt           = 'd0;

reg                                         real_scan_flag_d0           = 'd0;
reg                                         real_scan_flag_d1           = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                        time_scan_pose;
wire                                        time_scan_nege;
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
    if(pmt_adc_start_vld_i && (~pmt_scan_cmd[0]) && pmt_adc_start_data_i[0])begin
        pmt_adc_start_en <= #TCQ 'd1;
    end
    else if((pmt_adc_start_cnt == pmt_adc_start_hold_i) || (pmt_adc_start_vld_i && (~pmt_adc_start_data_i[0])))begin
        pmt_adc_start_en <= #TCQ 'd0;
    end
end

reg [17-1:0] unit_time_cnt = 'd0;
reg          unit_time_trig = 'd0;
always @(posedge clk_i) begin
    if(pmt_adc_start_en)begin
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
    if(pmt_adc_start_en)begin
        if(unit_time_trig)
            pmt_adc_start_cnt <= #TCQ pmt_adc_start_cnt + 1;
    end
    else begin 
        pmt_adc_start_cnt <= #TCQ 'd0;
    end
end

always @(posedge clk_i) begin
    pmt_adc_start_en_d <= #TCQ pmt_adc_start_en;
end

assign time_scan_pose = pmt_adc_start_en    && (~pmt_adc_start_en_d);
assign time_scan_nege = (~pmt_adc_start_en) && pmt_adc_start_en_d;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

always @(posedge clk_i) begin
    real_scan_flag_d0 <= #TCQ real_scan_flag_i;
    real_scan_flag_d1 <= #TCQ real_scan_flag_d0;
end

assign real_scan_pose  = ~real_scan_flag_d1 && real_scan_flag_d0;
assign real_scan_nege  = ~real_scan_flag_d0 && real_scan_flag_d1;

always @(posedge clk_i) begin
    if(time_scan_pose)begin
        pmt_scan_cmd_sel <= #TCQ pmt_adc_start_data_i[10:8];
        pmt_scan_cmd     <= #TCQ pmt_adc_start_data_i[3:0];
    end
    else if(time_scan_nege)begin
        pmt_scan_cmd_sel <= #TCQ pmt_adc_start_data_i[10:8];
        pmt_scan_cmd     <= #TCQ 'd0;
    end
    else if(real_scan_pose)begin
        pmt_scan_cmd_sel <= #TCQ real_scan_sel_i;
        pmt_scan_cmd     <= #TCQ 4'b0001;
    end
    else if(real_scan_nege)begin
        pmt_scan_cmd_sel <= #TCQ real_scan_sel_i;
        pmt_scan_cmd     <= #TCQ 'd0;
    end
    else begin
        pmt_scan_cmd_sel <= #TCQ 'd0;
        pmt_scan_cmd     <= #TCQ pmt_scan_cmd;
    end
end

assign pmt_scan_cmd_sel_o = pmt_scan_cmd_sel;
assign pmt_scan_cmd_o     = pmt_scan_cmd    ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
