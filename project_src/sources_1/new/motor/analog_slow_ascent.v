`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/11
// Design Name: songyuxin
// Module Name: analog_slow_ascent
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


module analog_slow_ascent #(
    parameter                                               TCQ                 = 0.1   ,
    parameter                                               MOTOR_VOL           = 16 
)(
    // clk & rst
    input   wire                                            clk_i                   ,
    input   wire                                            rst_i                   ,
    
    input   wire        [16-1:0]                            ascent_gradient_i       ,
    input   wire        [16-1:0]                            slow_ascent_period_i    ,
    
    input   wire                                            motor_data_in_en_i      ,
    input   wire        [MOTOR_VOL-1:0]                     motor_data_in_i         ,
    output  wire                                            motor_slow_ascent_en_o  ,
    output  wire        [MOTOR_VOL-1:0]                     motor_slow_ascent_o     

);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam                                  SLOW_ASCENT_PERIOD          = 12207; // 100_000_000/8192

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                                         motor_slow_ascent_en        = 'd0;
reg             [MOTOR_VOL-1:0]             motor_slow_ascent           = 'd0;

reg             [16-1:0]                    slow_ascent_cnt             = 'd0;
reg             [MOTOR_VOL-1:0]             aim_motor_vol               = 'd0;
// reg                                         slow_ascent_enable          = 'd0;
reg             [MOTOR_VOL:0]               delta_motor_vol             = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                        slow_ascent_trigger     ;
wire            [MOTOR_VOL:0]               delta_motor_vol_abs     ;

wire                                        slow_ascent_enable      ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

always @(posedge clk_i) begin
    if(rst_i)
        slow_ascent_cnt <= #TCQ 'd0;
    // else if(slow_ascent_cnt == SLOW_ASCENT_PERIOD-1)
    else if(slow_ascent_cnt == slow_ascent_period_i-1)
        slow_ascent_cnt <= #TCQ 'd0;
    else 
        slow_ascent_cnt <= #TCQ slow_ascent_cnt + 1;
end

// assign slow_ascent_trigger = slow_ascent_cnt == SLOW_ASCENT_PERIOD-1;
assign slow_ascent_trigger = slow_ascent_cnt == slow_ascent_period_i-1;

always @(posedge clk_i) begin
    if(motor_data_in_en_i)
        aim_motor_vol <= #TCQ motor_data_in_i;
end

always @(posedge clk_i ) begin
    delta_motor_vol <= #TCQ aim_motor_vol - motor_slow_ascent;
end

assign delta_motor_vol_abs = delta_motor_vol[MOTOR_VOL] ? (~delta_motor_vol + 1) : delta_motor_vol;

// always @(posedge clk_i ) begin
//     slow_ascent_enable <= #TCQ delta_motor_vol_abs > ascent_gradient_i;
// end
assign slow_ascent_enable = delta_motor_vol_abs > ascent_gradient_i;

always @(posedge clk_i) begin
    if(slow_ascent_trigger)begin
        if(slow_ascent_enable && delta_motor_vol[MOTOR_VOL])
            motor_slow_ascent <= #TCQ motor_slow_ascent - ascent_gradient_i;
        else if(slow_ascent_enable)
            motor_slow_ascent <= #TCQ motor_slow_ascent + ascent_gradient_i;
        else 
            motor_slow_ascent <= #TCQ aim_motor_vol;
    end
end

always @(posedge clk_i) begin
    motor_slow_ascent_en <= #TCQ slow_ascent_trigger;
end

assign motor_slow_ascent_en_o = motor_slow_ascent_en;
assign motor_slow_ascent_o = motor_slow_ascent;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

endmodule
