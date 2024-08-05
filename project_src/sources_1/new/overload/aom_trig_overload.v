`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2024/03/13
// Design Name: 
// Module Name: aom_trig_overload
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


module aom_trig_overload #(
    parameter                       TCQ         = 0.1 

)(
    // clk & rst
    input                           clk_i                       ,
    input                           rst_i                       ,
    
    // interface    
    input                           laser_control_i             ,
    input                           laser_out_switch_i          ,
    input                           laser_aom_en_i              ,
    input       [12-1:0]            laser_aom_voltage_i         ,

    input                           acc_job_control_i           ,
    input                           aom_trig_protect_i          ,
    input       [32-1:0]            aom_continuous_trig_thre_i  ,
    input       [32-1:0]            aom_integral_trig_thre_i    ,
    input       [12-1:0]            aom_trig_vol_thre_i         ,

    output                          aom_continuous_trig_err_o   ,
    output                          aom_integral_trig_err_o     

);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam      [32-1:0]            AOM_INTEGRAL_LENGTH     = 100_000_000;  // 1s

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                                 aom_trig_vld                = 'd0;
reg                                 aom_trig_diag               = 'd0;
reg             [32-1:0]            aom_trig_diag_cnt           = 'd0;

reg             [32-1:0]            aom_integral_cnt            = 'd0;
reg                                 aom_integral_trig_err       = 'd0;
reg             [32-1:0]            aom_continuous_cnt          = 'd0;
reg                                 aom_continuous_trig_err     = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                aom_trig_diag_done   ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// function safety, aom trig overload
always @(posedge clk_i) begin
    if(laser_aom_en_i)begin
        if(laser_aom_voltage_i<aom_trig_vol_thre_i)
            aom_trig_vld <= #TCQ 'd1;
        else
            aom_trig_vld <= #TCQ 'd0;
    end 
end

always @(posedge clk_i) begin
    if(aom_trig_protect_i && acc_job_control_i)begin
        if(aom_trig_vld && (~aom_trig_diag))
            aom_trig_diag <= #TCQ 'd1;
        else if(aom_trig_diag && aom_trig_diag_done)
            aom_trig_diag <= #TCQ 'd0;
    end
    else begin
        aom_trig_diag <= #TCQ 'd0;        
    end
end

assign aom_trig_diag_done = aom_trig_diag_cnt == AOM_INTEGRAL_LENGTH;
always @(posedge clk_i) begin
    if(~aom_trig_diag)
        aom_trig_diag_cnt <= #TCQ 'd0;
    else if(~aom_trig_diag_done)
        aom_trig_diag_cnt <= #TCQ aom_trig_diag_cnt + 1;
end

always @(posedge clk_i) begin
    if(aom_trig_diag)begin
        if(aom_trig_vld)
            aom_integral_cnt <= #TCQ aom_integral_cnt + 1;
    end
    else begin
        aom_integral_cnt <= #TCQ 'd0;
    end
end

always @(posedge clk_i) begin
    aom_integral_trig_err <= #TCQ (~laser_control_i) && laser_out_switch_i && (aom_integral_cnt >= aom_integral_trig_thre_i);  // 出光 & 外控 & 超阈值
end

always @(posedge clk_i) begin
    if(aom_trig_protect_i && acc_job_control_i && aom_trig_vld)
        aom_continuous_cnt <= #TCQ aom_continuous_cnt + 1;
    else 
        aom_continuous_cnt <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    aom_continuous_trig_err <= #TCQ (~laser_control_i) && laser_out_switch_i && (aom_continuous_cnt >= aom_continuous_trig_thre_i);  // 出光 & 外控 & 超阈值
end

assign aom_continuous_trig_err_o = aom_continuous_trig_err;
assign aom_integral_trig_err_o   = aom_integral_trig_err;  
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
