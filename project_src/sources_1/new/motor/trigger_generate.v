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
    input   wire        [4-1:0]                             motor_freq_i            , // motor close freq  0:100Hz 1:200Hz 2:300Hz
    output  wire                                            motor_trigger_o         

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
            if(motor_set_trigger_cnt >= 'd999999) begin
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
            if(motor_set_trigger_cnt >= 'd499999) begin
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
        'd2: begin
            if(motor_set_trigger_cnt >= 'd333332) begin
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
        'd3: begin
            if(motor_set_trigger_cnt >= 'd250_000 - 1) begin
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
        'd4: begin
            if(motor_set_trigger_cnt >= 'd200_000 - 1) begin           // 500Hz
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
        'd5: begin
            if(motor_set_trigger_cnt >= 'd2000_000 - 1) begin         // 600Hz
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
        'd6: begin
            if(motor_set_trigger_cnt >= 'd166_666 - 1) begin
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
        'd7: begin
            if(motor_set_trigger_cnt >= 'd142_857 - 1) begin
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
        'd8: begin
            if(motor_set_trigger_cnt >= 'd125_000 - 1) begin
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
        'd9: begin
            if(motor_set_trigger_cnt >= 'd111_111 - 1) begin
                motor_set_trigger        <= #TCQ    1'b1;
                motor_set_trigger_cnt    <= #TCQ    'd0;
            end
            else begin
                motor_set_trigger        <= #TCQ    1'b0;
                motor_set_trigger_cnt    <= #TCQ    motor_set_trigger_cnt + 1'd1;
            end
        end
        default: begin
            if(motor_set_trigger_cnt >= 'd999999) begin
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
