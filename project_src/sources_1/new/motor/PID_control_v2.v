`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/10
// Design Name: songyuxin
// Module Name: PID_control_v2
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


module PID_control_v2 #(
    parameter                                               POSITION_DATA         = 24 , 
    parameter                                               EXTEND_BIT            = 20 , 
    parameter                                               MOTOR_VOL             = 16 , 
    parameter                                               PID_RESULT            = 16 , 
    parameter                                               PID_PARAMETER         = 6  
)(
    // clk & rst
    input   wire                                            clk_i                   ,
    input   wire                                            rst_i                   ,
    
    input   wire        [3-1:0]                             data_acq_en_i           , // motor control enable
    // input   wire                                            motor_trigger_i         ,
    input   wire        [PID_PARAMETER + EXTEND_BIT -1:0]   kp_i                    ,
    input   wire        [PID_PARAMETER + EXTEND_BIT -1:0]   ki_i                    ,
    input   wire        [PID_PARAMETER + EXTEND_BIT -1:0]   kd_i                    ,
    input   wire signed [POSITION_DATA:0]                   position_aim_i          ,
    input   wire        [MOTOR_VOL-1:0]                     fbc_bias_voltage_i      ,
    input   wire        [MOTOR_VOL-1:0]                     fbc_cali_uop_set_i      ,
    input   wire                                            actual_data_en_i        ,
    input   wire signed [POSITION_DATA-1:0]                 actual_data_a_i         ,
    input   wire signed [POSITION_DATA-1:0]                 actual_data_b_i         ,
    input   wire signed [POSITION_DATA-1:0]                 bg_data_a_i             ,
    input   wire signed [POSITION_DATA-1:0]                 bg_data_b_i             ,

    input   wire                                            motor_Ufeed_en_i        ,
    input   wire        [MOTOR_VOL-1:0]                     motor_Ufeed_i           ,
    output  wire                                            motor_data_in_en_o      ,
    // output  wire                                            motor_rd_en_o           ,
    output  wire        [MOTOR_VOL-1:0]                     motor_Ufeed_latch_o     ,
    output  wire        [MOTOR_VOL-1:0]                     motor_data_in_o         ,
    output  wire        [32-1:0]                            delta_position_o        ,
    output  wire        [32-1:0]                            actu_position_o         ,

    input   wire        [POSITION_DATA:0]                   position_pid_thr_i      ,
    input   wire        [POSITION_DATA:0]                   fbc_pose_err_thr_i      ,
    output  wire                                            fbc_close_state_o       ,
    input   wire        [POSITION_DATA:0]                   fbc_ratio_max_thr_i     ,
    input   wire        [POSITION_DATA:0]                   fbc_ratio_min_thr_i     ,
    output  wire                                            fbc_close_state_err_o   ,
    output  wire        [POSITION_DATA:0]                   err_position_latch_o    ,
    output  wire                                            fbc_ratio_err_o         ,
    output  wire        [22-1:0]                            err_intensity_latch_o   

);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

localparam                                  MULT_PID_RESULT   = PID_PARAMETER + EXTEND_BIT + POSITION_DATA + 2;
localparam                                  RESULT_EXTEND     = MULT_PID_RESULT + 2 + 15;
localparam                                  PID_RESULT_WID    = RESULT_EXTEND - (EXTEND_BIT * 2);

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// reg                                         motor_set_trigger           = 'd0;
// reg             [32-1:0]                    motor_set_trigger_cnt       = 'd0;

reg     signed  [POSITION_DATA-1 :0]        comp_data_a                 = 'd0;
reg     signed  [POSITION_DATA-1 :0]        comp_data_b                 = 'd0;

reg                                         divider_result_wait         = 'd0;
reg                                         divider_in_en               = 'd0;
reg     signed  [POSITION_DATA:0]           divisor_data                = 'd0;
reg     signed  [POSITION_DATA:0]           dividend_data               = 'd0;

reg             [MOTOR_VOL-1:0]             motor_ufeed_out             = 'd0;
reg             [MOTOR_VOL-1:0]             motor_ufeed_latch           = 'd0;
reg     signed  [POSITION_DATA  :0]         position_actual             = 'd0;
reg     signed  [POSITION_DATA  :0]         position_pre                = 'd0;
reg     signed  [POSITION_DATA  :0]         position_pre_p              = 'd0;
reg     signed  [POSITION_DATA+1:0]         delta_position              = 'd0;
reg     signed  [POSITION_DATA+1:0]         proportion_position         = 'd0;
reg     signed  [POSITION_DATA+1:0]         integral_position           = 'd0;
reg     signed  [POSITION_DATA+1:0]         differ_position             = 'd0;

(*use_dsp = "yes"*)reg     signed  [MULT_PID_RESULT -1:0]      mult_result_p        = 'd0;
(*use_dsp = "yes"*)reg     signed  [MULT_PID_RESULT -1:0]      mult_result_p_d0     = 'd0;
(*use_dsp = "yes"*)reg     signed  [MULT_PID_RESULT -1:0]      mult_result_p_d1     = 'd0;
(*use_dsp = "yes"*)reg     signed  [MULT_PID_RESULT -1:0]      mult_result_p_d2     = 'd0;

(*use_dsp = "yes"*)reg     signed  [MULT_PID_RESULT -1:0]      mult_result_i        = 'd0;
(*use_dsp = "yes"*)reg     signed  [MULT_PID_RESULT -1:0]      mult_result_i_d0     = 'd0;
(*use_dsp = "yes"*)reg     signed  [MULT_PID_RESULT -1:0]      mult_result_i_d1     = 'd0;
(*use_dsp = "yes"*)reg     signed  [MULT_PID_RESULT -1:0]      mult_result_i_d2     = 'd0;

(*use_dsp = "yes"*)reg     signed  [MULT_PID_RESULT -1:0]      mult_result_d        = 'd0;
(*use_dsp = "yes"*)reg     signed  [MULT_PID_RESULT -1:0]      mult_result_d_d0     = 'd0;
(*use_dsp = "yes"*)reg     signed  [MULT_PID_RESULT -1:0]      mult_result_d_d1     = 'd0;
(*use_dsp = "yes"*)reg     signed  [MULT_PID_RESULT -1:0]      mult_result_d_d2     = 'd0;

(*use_dsp = "yes"*)reg     signed  [MULT_PID_RESULT +1:0]      mult_result_sum      = 'd0;

reg     signed   [RESULT_EXTEND -1:0]       result_extend_r      = 'd0;
reg     signed   [RESULT_EXTEND -1:0]       result_extend_d0     = 'd0;
reg     signed   [RESULT_EXTEND -1:0]       result_extend_d1     = 'd0;
reg     signed   [RESULT_EXTEND -1:0]       result_extend_d2     = 'd0;
reg     signed   [RESULT_EXTEND -1:0]       result_extend_d3     = 'd0;

reg              [PID_RESULT_WID-1:0]       motor_pid_result            = 'd0;
reg                                         motor_data_in_vld           = 'd0;
reg              [MOTOR_VOL-1:0]            motor_data_in_pre           = 'd0;
reg              [MOTOR_VOL-1:0]            motor_data_in               = 'd0;

reg signed [PID_PARAMETER + EXTEND_BIT :0]   kp_r = 'd0;
reg signed [PID_PARAMETER + EXTEND_BIT :0]   ki_r = 'd0;
reg signed [PID_PARAMETER + EXTEND_BIT :0]   kd_r = 'd0;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                        divider_out_en      ;
wire            [47:0]                      divider_out_data    ;
// wire            [RESULT_EXTEND -1:0]        result_extend_r     ;
wire                                        mult_result_vld     ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// pid_mult_2 pid_mult_2_inst(
//     .CLK(clk_i), 
//     .A(mult_result_sum), 
//     .B(15'd16000), 
//     .P(result_extend_r)
// );  

bps_divider bps_divider_inst(
    .aclk(clk_i), 
    .aresetn(~rst_i), 
    .s_axis_divisor_tvalid(divider_in_en), 
    .s_axis_divisor_tdata(divisor_data), 
    .s_axis_dividend_tvalid(divider_in_en), 
    .s_axis_dividend_tdata(dividend_data), 
    .m_axis_dout_tvalid(divider_out_en), 
    .m_axis_dout_tdata(divider_out_data)
);

reg_delay #(
    .DATA_WIDTH         ( 1                                     ),
    .DELAY_NUM          ( 13                                    )
)mult_result_delay_inst(
    // clk & rst
    .clk_i              ( clk_i                                 ),
     
    .src_data_i         ( divider_out_en                        ),
    .delay_data_o       ( mult_result_vld                       )
);

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

always @(posedge clk_i) begin
    kp_r <= {1'b0,kp_i[PID_PARAMETER + EXTEND_BIT -1:0]};
    ki_r <= {1'b0,ki_i[PID_PARAMETER + EXTEND_BIT -1:0]};
    kd_r <= {1'b0,kd_i[PID_PARAMETER + EXTEND_BIT -1:0]};
end

// U1=(I1-Id1)*R     Id: dark current * R = background voltage
// U2=(I2-Id2)*R     Id: dark current * R = background voltage
always @(posedge clk_i)begin
    if(actual_data_en_i) begin
        comp_data_a  <= actual_data_a_i - bg_data_a_i;
        comp_data_b  <= actual_data_b_i - bg_data_b_i;
    end
end

// latch Ufeed data/motor data
always @(posedge clk_i) begin
    if(motor_Ufeed_en_i)
        motor_ufeed_out <= motor_Ufeed_i;
end

always @(posedge clk_i) begin
    if(motor_data_in_vld)begin
        motor_ufeed_latch <= motor_data_in;
        // motor_ufeed_latch <= 16'h7d00;
    end    
end
// always @(posedge clk_i) begin
//     if(motor_Ufeed_en_i)begin
//         motor_ufeed_latch <= motor_Ufeed_i;
//         // motor_ufeed_latch <= 16'h7d00;
//     end
// end

// close state enable
always @(posedge clk_i) begin
    divisor_data  <= {comp_data_a[POSITION_DATA-1],comp_data_a} + {comp_data_b[POSITION_DATA-1],comp_data_b};
    dividend_data <= {comp_data_a[POSITION_DATA-1],comp_data_a} - {comp_data_b[POSITION_DATA-1],comp_data_b};
end
always @(posedge clk_i) begin
    divider_in_en <= motor_Ufeed_en_i;
end
// always @(posedge clk_i) begin
//     if(data_acq_en_i=='d2)begin
//         if((~comp_data_a[POSITION_DATA-1]) && (~comp_data_b[POSITION_DATA-1])) begin
//             divider_in_en   <= motor_Ufeed_en_i;
//         end
//         else begin
//             divider_in_en   <=    1'b0;
//         end
//     end
//     else begin
//         divider_in_en <= motor_Ufeed_en_i;
//     end
// end

// position_actual = (U1-U2/U1+U2)*L/2   L=10
always @(posedge clk_i) begin
    position_actual <= {{(POSITION_DATA-'d22){divider_out_data[20]}},divider_out_data[20:0],2'd0} + {{(POSITION_DATA-'d20){divider_out_data[20]}},divider_out_data[20:0]};
end

// pre_posttion and pre_pid_result latch
always @(posedge clk_i) begin
    if(motor_data_in_vld)begin
        position_pre        <= position_actual;
        position_pre_p      <= position_pre;
        motor_data_in_pre   <= motor_data_in;
    end
end

// wait divider result enable
// always @(posedge clk_i) begin
//     if(divider_in_en)
//         divider_result_wait <= 'd1;
//     else if(divider_result_wait && divider_out_en)
//         divider_result_wait <= 'd0;
// end

// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> pid operation part
// reg pid_operation_str_d0 = 'd0;
// reg pid_operation_str_d1 = 'd0;
// always @(posedge clk_i) begin
//     pid_operation_str_d0 <= divider_result_wait && divider_out_en;
//     pid_operation_str_d1 <= pid_operation_str_d0;
// end
// proportional = position_pre - postion_actual 
// integral     = Paim - postion_actual
// derivative   = 2*position_pre - postion_actual - position_pre_pre
// delta_position delay 2 clk relative to divider_out
// ΔΔP clk == ΔP clk
always @(posedge clk_i) begin
    if(data_acq_en_i=='d2)begin
        proportion_position <= {position_pre[POSITION_DATA],position_pre} - {position_actual[POSITION_DATA],position_actual};
        integral_position   <= {position_aim_i[POSITION_DATA],position_aim_i} - {position_actual[POSITION_DATA],position_actual};
        differ_position     <= {position_pre,1'b0} - {position_actual[POSITION_DATA],position_actual} - {position_pre_p[POSITION_DATA],position_pre_p};
    end
    else begin
        proportion_position <= 'd0;
        integral_position   <= 'd0;
        differ_position     <= 'd0;
    end
end

always @(posedge clk_i) begin
    delta_position  <= {position_aim_i[POSITION_DATA],position_aim_i} - {position_actual[POSITION_DATA],position_actual};
end

// pid_sum delay 4 clk for multiplication
always @(posedge clk_i) begin
    mult_result_p_d0 <= proportion_position * kp_r;
    mult_result_p_d1 <= mult_result_p_d0;
    mult_result_p_d2 <= mult_result_p_d1;
    mult_result_p    <= mult_result_p_d2;

    mult_result_i_d0 <= integral_position * ki_r;
    mult_result_i_d1 <= mult_result_i_d0;
    mult_result_i_d2 <= mult_result_i_d1;
    mult_result_i    <= mult_result_i_d2;

    mult_result_d_d0 <= differ_position * kd_r;
    mult_result_d_d1 <= mult_result_d_d0;
    mult_result_d_d2 <= mult_result_d_d1;
    mult_result_d    <= mult_result_d_d2;
end

// mult_result_sum delay 1 clk for addition
always @(posedge clk_i) begin
    mult_result_sum <= {{'d2{mult_result_p[MULT_PID_RESULT -1]}},mult_result_p[MULT_PID_RESULT -1:0]} 
                     + {{'d2{mult_result_i[MULT_PID_RESULT -1]}},mult_result_i[MULT_PID_RESULT -1:0]}
                     + {{'d2{mult_result_d[MULT_PID_RESULT -1]}},mult_result_d[MULT_PID_RESULT -1:0]};
end

// (mult_result_p/2^40)/4.096V *(2^16) = (mult_result_p/2^40)*16000
// result_extend_r delay 5 clk for multiplication
wire signed [15-1:0] para_mult ;
assign para_mult = 15'd16000;

always @(posedge clk_i) begin
    result_extend_d0 <= mult_result_sum * para_mult;
    result_extend_d1 <= result_extend_d0;
    result_extend_d2 <= result_extend_d1;
    result_extend_d3 <= result_extend_d2;
    result_extend_r  <= result_extend_d3;
end

// result delay 1 clk . use Ufeed to control
always @(posedge clk_i) begin
    motor_pid_result <= result_extend_r[RESULT_EXTEND-1 : 40] + {{(RESULT_EXTEND-40-MOTOR_VOL){1'b0}},motor_ufeed_latch[MOTOR_VOL-1:0]};
end

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 

// mult_result_vld delay 13 clk relative to divider_out_en.
always @(posedge clk_i) begin
    if(data_acq_en_i=='d3)begin
            motor_data_in <= fbc_cali_uop_set_i;
    end
    else if(data_acq_en_i=='d2)begin
        if(mult_result_vld && motor_pid_result[PID_RESULT_WID-1])
            motor_data_in <= 'd0;
        else if(mult_result_vld && (|motor_pid_result[PID_RESULT_WID-2:MOTOR_VOL]))
            motor_data_in <= 'hffff;
        else if(mult_result_vld)
            motor_data_in <= motor_pid_result[MOTOR_VOL-1:0];
    end
    else begin
            motor_data_in <= fbc_bias_voltage_i;
    end
end

always @(posedge clk_i) begin
    if(data_acq_en_i=='d0)begin
        motor_data_in_vld <= 'd0;
    end 
    else begin
        motor_data_in_vld <= mult_result_vld;
    end
end

assign motor_data_in_en_o    = motor_data_in_vld;
// assign motor_rd_en_o         = motor_trigger_i;
assign motor_Ufeed_latch_o   = motor_ufeed_out;
assign motor_data_in_o       = motor_data_in;

assign delta_position_o      = {{(32-(POSITION_DATA+2)){delta_position[POSITION_DATA+1]}}, delta_position[POSITION_DATA+1:0]};
assign actu_position_o       = {{(32-POSITION_DATA-1){1'b0}},position_actual};
/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> result * 1.1035
(*use_dsp = "yes"*) reg [MOTOR_VOL+17 -1 : 0] motor_data_in_mult = 'd0;
(*use_dsp = "yes"*) reg [MOTOR_VOL+17 -1 : 0] motor_data_in_mult_d0 = 'd0;
(*use_dsp = "yes"*) reg [MOTOR_VOL+17 -1 : 0] motor_data_in_mult_d1 = 'd0;
(*use_dsp = "yes"*) reg [MOTOR_VOL+17 -1 : 0] motor_data_in_mult_d2 = 'd0;

always @(posedge clk_i) begin
    motor_data_in_mult_d0 <= motor_data_in * 17'd72318;
    motor_data_in_mult_d1 <= motor_data_in_mult_d0;
    motor_data_in_mult_d2 <= motor_data_in_mult_d1;
    motor_data_in_mult    <= motor_data_in_mult_d2;
end

reg motor_data_in_vld_d0 = 'd0;
reg motor_data_in_vld_d1 = 'd0;
reg motor_data_in_vld_d2 = 'd0;
reg motor_data_in_vld_d3 = 'd0;

always @(posedge clk_i) begin
    motor_data_in_vld_d0 <= motor_data_in_vld;
    motor_data_in_vld_d1 <= motor_data_in_vld_d0;
    motor_data_in_vld_d2 <= motor_data_in_vld_d1;
    motor_data_in_vld_d3 <= motor_data_in_vld_d2;
end

assign motor_data_in_en_o    = motor_data_in_vld_d3;
assign motor_rd_en_o         = motor_trigger_i;
assign motor_Ufeed_latch_o   = motor_ufeed_latch;
assign motor_data_in_o       = motor_data_in_mult[MOTOR_VOL+17 -1] ? 16'hffff : motor_data_in_mult[MOTOR_VOL+16 -1 :MOTOR_VOL];
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// check closed loop state
reg fbc_close_state = 'd0;
wire [POSITION_DATA:0] delta_position_abs;
assign delta_position_abs = delta_position[POSITION_DATA+1] ? (~delta_position[POSITION_DATA:0] + 1'd1) : delta_position[POSITION_DATA:0];
always @(posedge clk_i) begin
    if(data_acq_en_i=='d2)begin
        if(~fbc_close_state && motor_data_in_vld && (delta_position_abs <= position_pid_thr_i)) 
            fbc_close_state <= 'd1;
    end
    else begin
        fbc_close_state <= 'd0;
    end
end

assign fbc_close_state_o = fbc_close_state;

// overload check fbc voltage delta abs 
reg fbc_close_state_err = 'd0;
reg [POSITION_DATA:0] err_position_latch = 'd0;
always @(posedge clk_i) begin
    if(fbc_close_state)begin
        if(motor_data_in_vld && (delta_position_abs >= fbc_pose_err_thr_i)) begin
            fbc_close_state_err <= 'd1;
            err_position_latch <= delta_position_abs;
        end
    end
    else begin
        fbc_close_state_err <= 'd0;
    end
end

assign fbc_close_state_err_o = fbc_close_state_err;
assign err_position_latch_o = err_position_latch;

// overload check fbc voltage ratio 
reg fbc_ratio_err = 'd0;
wire [22-1:0]  vol_intensity_ratio;
reg [22-1:0] err_intensity_latch = 'd0;
assign vol_intensity_ratio = divisor_data[POSITION_DATA:3];
always @(posedge clk_i) begin
    if(fbc_close_state)begin
        if(divider_out_en)begin
            if((vol_intensity_ratio > fbc_ratio_max_thr_i) || (vol_intensity_ratio < fbc_ratio_min_thr_i))begin
                fbc_ratio_err   <= 'd1;
                err_intensity_latch <= vol_intensity_ratio;
            end
            else 
                fbc_ratio_err   <= 'd0;
        end
    end
    else begin
        fbc_ratio_err <= 'd0;
    end
end
assign fbc_ratio_err_o = fbc_ratio_err;
assign err_intensity_latch_o = err_intensity_latch;
endmodule
