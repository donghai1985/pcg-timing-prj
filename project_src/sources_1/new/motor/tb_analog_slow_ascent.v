//~ `New testbench
`timescale  1ns / 1ps

module tb_analog_slow_ascent;

// analog_slow_ascent Parameters
parameter PERIOD     = 10 ;
parameter TCQ        = 0.1;
parameter MOTOR_VOL  = 16 ;

// analog_slow_ascent Inputs
reg   clk_i                                = 0 ;
reg   rst_i                                = 0 ;
reg   [16-1:0]  ascent_gradient_i          = 1500 ;
reg   [16-1:0]  slow_ascent_period_i       = 12207 ;
reg   motor_data_in_en_i                   = 0 ;
reg   [MOTOR_VOL-1:0]  motor_data_in_i     = 0 ;

// analog_slow_ascent Outputs
wire  motor_slow_ascent_en_o               ;
wire  [MOTOR_VOL-1:0]  motor_slow_ascent_o ;


initial
begin
    forever #(PERIOD/2)  clk_i=~clk_i;
end

initial
begin
    rst_i  =  1;
    #(PERIOD*2);
    rst_i  =  0;
end

analog_slow_ascent #(
    .TCQ       ( TCQ       ),
    .MOTOR_VOL ( MOTOR_VOL ))
 u_analog_slow_ascent (
    .clk_i                   ( clk_i                                   ),
    .rst_i                   ( rst_i                                   ),
    .ascent_gradient_i       ( ascent_gradient_i       [16-1:0]        ),
    .slow_ascent_period_i    ( slow_ascent_period_i    [16-1:0]        ),
    .motor_data_in_en_i      ( motor_data_in_en_i                      ),
    .motor_data_in_i         ( motor_data_in_i         [MOTOR_VOL-1:0] ),

    .motor_slow_ascent_en_o  ( motor_slow_ascent_en_o                  ),
    .motor_slow_ascent_o     ( motor_slow_ascent_o     [MOTOR_VOL-1:0] )
);
reg test_enable = 0;
reg [32-1:0] period_cnt = 'd0;
always @(posedge clk_i) begin
    if(test_enable)
        if(period_cnt == 100000)
            period_cnt <= 'd0;
        else 
            period_cnt <= period_cnt + 1;
    else 
        period_cnt <= 'd0;
end

reg signed [16-1:0] rand_data ;
always @(negedge clk_i) begin
    rand_data <= $random % 20;
end

always @(posedge clk_i) begin
    motor_data_in_en_i <= period_cnt == 100000;
    if(period_cnt == 100000)
        motor_data_in_i <= {rand_data,6'd0};
end

initial
begin
    wait(~rst_i)

    test_enable = 1;

    #10_000_000;

    $finish;
end

endmodule