//~ `New testbench
`timescale  1ns / 1ps

module tb_fbc_motor;

// fbc_motor Parameters
parameter PERIOD = 10 ;
parameter TCQ  = 0.1;

// fbc_motor Inputs
reg   clk_i                                = 0 ;
reg   rst_i                                = 0 ;
reg   [2:0]  motor_state_i                 = 0 ;
reg   motor_Ufeed_en_i                     = 0 ;
reg   [15:0]  motor_Ufeed_i                = 0 ;
reg   overload_motor_en_i                  = 0 ;
reg   [15:0]  overload_ufeed_thre_i        = 13107 ;

// fbc_motor Outputs
wire  [32:0]  overload_pid_result_o        ;


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

fbc_motor #(
    .TCQ ( TCQ ))
 u_fbc_motor (
    .clk_i                   ( clk_i                         ),
    .rst_i                   ( rst_i                         ),
    .motor_state_i           ( motor_state_i          [2:0]  ),
    .motor_Ufeed_en_i        ( motor_Ufeed_en_i              ),
    .motor_Ufeed_i           ( motor_Ufeed_i          [15:0] ),
    .overload_motor_en_i     ( overload_motor_en_i           ),
    .overload_ufeed_thre_i   ( overload_ufeed_thre_i  [15:0] ),

    .overload_pid_result_o   ( overload_pid_result_o  [32:0] )
);

reg [8-1:0] time_cnt = 'd0;
always @(posedge clk_i) begin
    if(time_cnt=='d100)
        time_cnt <= 'd0;
    else 
        time_cnt <= time_cnt + 1;
end

always @(posedge clk_i) begin
    if(time_cnt=='d100)begin
        motor_Ufeed_en_i <= 'd1;
        motor_Ufeed_i <= motor_Ufeed_i + 1;
    end
    else 
        motor_Ufeed_en_i <= 'd0;
end
endmodule