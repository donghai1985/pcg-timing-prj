//~ `New testbench
`timescale  1ns / 1ps

module tb_acc_demo_flag_trim;

// acc_demo_flag_trim Parameters
parameter PERIOD = 10 ;
parameter TCQ  = 0.1;

// acc_demo_flag_trim Inputs
reg   clk_i                                = 0 ;
reg   rst_i                                = 0 ;
reg   pmt_scan_en_i                        = 0 ;
reg   acc_demo_flag_i                      = 0 ;
reg   [16-1:0]  acc_demo_trim_time_pose_i  = 1 ;
reg   [16-1:0]  acc_demo_trim_time_nege_i  = 20 ;

// acc_demo_flag_trim Outputs
wire  [32-1:0]  acc_flag_phase_cnt_o       ;
wire  acc_demo_trim_ctrl_o                 ;
wire  acc_demo_trim_flag_o                 ;


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

acc_demo_flag_trim #(
    .TCQ ( TCQ ))
 u_acc_demo_flag_trim (
    .clk_i                      ( clk_i                               ),
    .rst_i                      ( rst_i                               ),
    .pmt_scan_en_i              ( pmt_scan_en_i                       ),
    .acc_demo_flag_i            ( acc_demo_flag_i                     ),
    .acc_demo_trim_time_pose_i  ( acc_demo_trim_time_pose_i  [16-1:0] ),
    .acc_demo_trim_time_nege_i  ( acc_demo_trim_time_nege_i  [16-1:0] ),

    .acc_flag_phase_cnt_o       ( acc_flag_phase_cnt_o       [32-1:0] ),
    .acc_demo_trim_ctrl_o       ( acc_demo_trim_ctrl_o                ),
    .acc_demo_trim_flag_o       ( acc_demo_trim_flag_o                )
);

initial
begin
    wait(~rst_i);
    pmt_scan_en_i = 1;
    #1000;
    acc_demo_flag_i = 1;
    #1000;
    acc_demo_flag_i = 0;
    #1000;
    $finish;
end

endmodule