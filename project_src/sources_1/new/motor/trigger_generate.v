`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/11/06
// Design Name: ZPC
// Module Name: trigger_generate
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


module trigger_generate #(
    parameter                                               TCQ         = 0.1 
)(
    // clk & rst
    input   wire                                            clk_i                   ,
    input   wire                                            rst_i                   ,
    
    input   wire                                            motor_bias_vol_en_i     ,
    input   wire        [4-1:0]                             motor_freq_i            , // motor close freq  0:128Hz 1:256Hz 2:512Hz 3:1024Hz
    output  wire                                            motor_trigger_o         

);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam      [32-1:0]                    PID_FREQ_128Hz              = 'd781250 - 1;
localparam      [32-1:0]                    PID_FREQ_256Hz              = 'd390625 - 1;
localparam      [32-1:0]                    PID_FREQ_512Hz              = 'd195312 - 1;
localparam      [32-1:0]                    PID_FREQ_1024Hz             = 'd97656 - 1;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                                         motor_set_trigger           = 'd0;
reg             [32-1:0]                    motor_set_trigger_cnt       = 'd0;

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
// generate pid_trigger
always @(posedge clk_i)begin
    if(motor_bias_vol_en_i == 'd1)begin
        motor_set_trigger        <= #TCQ    1'b1;
        motor_set_trigger_cnt    <= #TCQ    'd0;
    end
    else begin
        case(motor_freq_i)
`ifdef SIMULATE
        'd0: begin
            if(motor_set_trigger_cnt >= 'd10_000 -1) begin // simulate 100us
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
`else
        'd0: begin
            if(motor_set_trigger_cnt >= PID_FREQ_128Hz) begin
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
`endif //SIMULATE
        'd1: begin
            if(motor_set_trigger_cnt >= PID_FREQ_256Hz) begin
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
        'd2: begin
            if(motor_set_trigger_cnt >= PID_FREQ_512Hz) begin
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
        'd3: begin
            if(motor_set_trigger_cnt >= PID_FREQ_1024Hz) begin
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
        default: begin
            if(motor_set_trigger_cnt >= PID_FREQ_128Hz) begin
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
        endcase
    end
end

assign motor_trigger_o = motor_set_trigger;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
endmodule
