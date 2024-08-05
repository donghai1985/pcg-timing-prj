`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/30
// Design Name: 
// Module Name: PID_control
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


module PID_control #(
    parameter                               DATA_WIDTH          = 24  // actual and backgroud data width

)(
    // clk & rst
    input   wire                            clk_i                   ,
    input   wire                            rst_i                   ,
    
    input   wire        [2-1:0]             data_acq_en_i           , // motor control enable
    input   wire        [2-1:0]             motor_freq_i            , // motor close freq  0:100Hz 1:200Hz 2:300Hz
    input   wire        [22:0]              kp_i                    ,
    input   wire        [22:0]              ki_i                    ,
    input   wire signed [24:0]              position_aim_i          ,
    input   wire        [15:0]              fbc_bias_voltage_i      ,
    input   wire        [15:0]              fbc_cali_uop_set_i      ,
    input   wire                            actual_data_en_i        ,
    input   wire signed [DATA_WIDTH-1:0]    actual_data_a_i         ,
    input   wire signed [DATA_WIDTH-1:0]    actual_data_b_i         ,
    input   wire signed [DATA_WIDTH-1:0]    bg_data_a_i             ,
    input   wire signed [DATA_WIDTH-1:0]    bg_data_b_i             ,

    // input   wire                            position_cali_en_i      ,
    // input   wire                            pose_position_en_i      ,
    // output  wire                            position_actual_avg_en_o,
    // output  wire        [24:0]              position_actual_avg_o   ,

    input   wire                            motor_Ufeed_en_i        ,
    input   wire        [15:0]              motor_Ufeed_i           ,
    output  wire                            motor_data_in_en_o      ,
    output  wire                            motor_rd_en_o           ,
    output  wire        [15:0]              motor_Ufeed_latch_o     ,
    output  wire        [15:0]              motor_data_in_o         
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>






//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                                         motor_set_trigger           = 'd0;
reg             [32-1:0]                    motor_set_trigger_cnt       = 'd0;

reg     signed  [DATA_WIDTH-1 :0]           comp_data_a                 = 'd0;
reg     signed  [DATA_WIDTH-1 :0]           comp_data_b                 = 'd0;

reg                                         divider_result_wait         = 'd0;
reg                                         divider_in_en               = 'd0;
reg     signed  [DATA_WIDTH:0]              divisor_data                = 'd0;
reg     signed  [DATA_WIDTH:0]              dividend_data               = 'd0;

reg             [16-1:0]                    motor_ufeed_latch           = 'd0;
reg     signed  [DATA_WIDTH-1:0]            position_actual             = 'd0;
reg     signed  [DATA_WIDTH-1:0]            position_pre                = 'd0;
(* use_dsp = "yes"*)reg     signed  [DATA_WIDTH  :0]            delta_position              = 'd0;
(* use_dsp = "yes"*)reg     signed  [DATA_WIDTH  :0]            delta_delta_position        = 'd0;
reg                                         mult_result_vld_d           = 'd0;
reg                                         motor_data_in_vld           = 'd0;
reg              [16-1:0]            motor_data_in               = 'd0;
reg              [16-1:0]            motor_data_in_pre               = 'd0;
(* use_dsp = "yes"*)reg     signed  [49-1:0]                    mult_result_sum = 'd0;

reg                                         pose_position_en_ctrl       = 'd0;
reg                                         pose_position_en_pose       = 'd0;
// reg             [25-1:0]                    position_actual_avg         = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                        divider_out_en      ;
wire    [47:0]                              divider_out_data    ;

wire                                        mult_result_vld     ;
wire	[47:0]	                            mult_result_p         ;
wire	[47:0]	                            mult_result_i         ;
wire	[64:0]	                            mult_result_2       ;
wire [24:0]                                 motor_pid_result    ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
pid_mult pid_mult_p_inst(
    .CLK(clk_i), 
    .A(delta_position), 
    .B(kp_i), 
    .P(mult_result_p)
);  

pid_mult pid_mult_i_inst(
    .CLK(clk_i), 
    .A(delta_delta_position), 
    .B(ki_i), 
    .P(mult_result_i)
); 

pid_mult_2 pid_mult_2_inst(
    .CLK(clk_i), 
    .A(mult_result_sum), 
    .B(16'd16000), 
    .P(mult_result_2)
);    

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
    .DELAY_NUM          ( 12                                    )
)mult_result_delay_inst(
    // clk & rst
    .clk_i              ( clk_i                                 ),
     
    .src_data_i         ( divider_result_wait && divider_out_en ),
    .delay_data_o       ( mult_result_vld                       )
);

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// generate motor set trigger
always @(posedge clk_i)begin
    // if(data_acq_en_i == 'd1)begin
        case(motor_freq_i)
        2'd0: begin
        `ifdef SIMULATE
            if(motor_set_trigger_cnt == 'd10_000 -1) begin // simulate 100us
        `else
            if(motor_set_trigger_cnt == 'd999999) begin
        `endif //SIMULATE
                motor_set_trigger        <=    1'b1;
                motor_set_trigger_cnt    <=    'd0;
            end
            else begin
                motor_set_trigger        <=    1'b0;
                motor_set_trigger_cnt    <=    motor_set_trigger_cnt + 1'd1;
            end
        end
        2'd1: begin
            if(motor_set_trigger_cnt == 'd499999) begin
                motor_set_trigger        <=    1'b1;
                motor_set_trigger_cnt    <=    'd0;
            end
            else begin
                motor_set_trigger        <=    1'b0;
                motor_set_trigger_cnt    <=    motor_set_trigger_cnt + 1'd1;
            end
        end
        2'd2: begin
            if(motor_set_trigger_cnt == 'd333332) begin
                motor_set_trigger        <=    1'b1;
                motor_set_trigger_cnt    <=    'd0;
            end
            else begin
                motor_set_trigger        <=    1'b0;
                motor_set_trigger_cnt    <=    motor_set_trigger_cnt + 1'd1;
            end
        end
        default: begin
            motor_set_trigger        <=    1'b0;
            motor_set_trigger_cnt    <=    'd0;
        end
        endcase
    // end
    // else begin
    //     motor_set_trigger        <=    1'b0;
    //     motor_set_trigger_cnt    <=    'd0;
    // end
end

// U1=(I1-Id1)*R     Id: dark current * R = background voltage
// U2=(I2-Id2)*R     Id: dark current * R = background voltage
always @(posedge clk_i)begin
    if(actual_data_en_i) begin
        comp_data_a  <= actual_data_a_i - bg_data_a_i;
        comp_data_b  <= actual_data_b_i - bg_data_b_i;
    end
end

// latch Ufeed data
always @(posedge clk_i) begin
    if(motor_Ufeed_en_i)begin
        motor_ufeed_latch <= motor_Ufeed_i;
    end
end

// P/L*2 = (U1-U2/U1+U2)   L:10
// close state enable
always @(posedge clk_i) begin
    divisor_data  <= {comp_data_a[DATA_WIDTH-1],comp_data_a} + {comp_data_b[DATA_WIDTH-1],comp_data_b};
    dividend_data <= {comp_data_a[DATA_WIDTH-1],comp_data_a} - {comp_data_b[DATA_WIDTH-1],comp_data_b};
end
always @(posedge clk_i) begin
    if(data_acq_en_i=='d2)begin
        if((~comp_data_a[DATA_WIDTH-1]) && (~comp_data_b[DATA_WIDTH-1])) begin
            divider_in_en   <= motor_Ufeed_en_i;
        end
        else begin
            divider_in_en   <=    1'b0;
        end
    end
    else begin
        divider_in_en <= motor_Ufeed_en_i;
    end
end

// pre_posttion and pre_pid_result latch
always @(posedge clk_i) begin
    if(motor_data_in_vld)begin
        position_pre        <= position_actual;
        motor_data_in_pre   <= motor_data_in;
    end
end

// wait divider result enable
always @(posedge clk_i) begin
    if(divider_in_en)
        divider_result_wait <= 'd1;
    else if(divider_result_wait && divider_out_en)
        divider_result_wait <= 'd0;
end

// delta_position delay 2 clk relative to divider_out_en
always @(posedge clk_i) begin
    position_actual      <= {divider_out_data[20],divider_out_data[20:0],2'd0} + {{'d3{divider_out_data[20]}},divider_out_data[20:0]};
end

// ΔP = Paim -  Pac
// ΔPP = position_actual - position_pre
// ΔPP clk == ΔP clk
always @(posedge clk_i) begin
    delta_position       <= position_aim_i - {position_actual[DATA_WIDTH-1],position_actual};
    delta_delta_position <= {position_actual[DATA_WIDTH-1],position_actual} - {position_pre[DATA_WIDTH-1],position_pre};
end

// pid sum
always @(posedge clk_i) begin
    mult_result_sum <= {mult_result_p[47],mult_result_p[47:0]} + {mult_result_i[47],mult_result_i[47:0]};
end

// (mult_result_p/2^40)/4.096V *(2^16) = (mult_result_p/2^40)*16000
// mult_result_2 delay 10 clk relative to delta_position.
// mult_result_vld delay 11 clk relative to divider_out_en.
always @(posedge clk_i) begin
    if(data_acq_en_i=='d3)begin
        motor_data_in <= fbc_cali_uop_set_i;
    end
    else if(data_acq_en_i=='d1 || data_acq_en_i=='d4)begin
        motor_data_in <= fbc_bias_voltage_i;
    end
    else begin
        if(mult_result_vld_d && motor_pid_result[24])
            motor_data_in <= 'd0;
        else if(mult_result_vld_d && motor_pid_result[23:16])
            motor_data_in <= 'hffff;
        else if(mult_result_vld_d)
            motor_data_in <= motor_pid_result[15:0];
    end
end

always @(posedge clk_i) begin
    mult_result_vld_d <= mult_result_vld;
end

always @(posedge clk_i) begin
    if(data_acq_en_i=='d0)begin
        motor_data_in_vld <= 'd0;
    end 
    else begin
        motor_data_in_vld <= mult_result_vld_d;
    end
end

assign motor_pid_result = mult_result_2[64:40] + {9'd0,motor_data_in_pre[15:0]};



assign motor_data_in_en_o    = motor_data_in_vld;
assign motor_rd_en_o         = motor_set_trigger;
assign motor_Ufeed_latch_o   = motor_ufeed_latch;
assign motor_data_in_o       = motor_data_in;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

endmodule
