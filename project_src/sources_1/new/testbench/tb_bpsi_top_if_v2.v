//~ `New testbench
`timescale  1ns / 1ps

module tb_bpsi_top_if_v2;

// bpsi_top_if_v2 Parameters
parameter PERIOD  = 10;


// bpsi_top_if_v2 Inputs
reg   clk_100m                            = 0 ;
reg   clk_300m                            = 0 ;
reg   rst                                 = 1 ;
// bpsi_top_if_v2 Outputs
wire                slave_tx_ack         ;
wire                slave_tx_byte_en     ;
wire    [ 7:0]      slave_tx_byte        ;
wire                slave_tx_byte_num_en ;
wire    [15:0]      slave_tx_byte_num    ;
wire                slave_rx_data_vld    ;
wire    [ 7:0]      slave_rx_data        ;

wire                bpsi_bg_data_acq_en             ;
wire    [2:0]       bpsi_data_acq_en                ;
wire    [24:0]      bpsi_position_aim               ;
wire    [26-1:0]    bpsi_kp                         ;
wire    [26-1:0]    bpsi_ki                         ;
wire    [26-1:0]    bpsi_kd                         ;
wire    [3:0]       bpsi_motor_freq                 ;
wire                bpsi_position_en                ;
wire    [11-1:0]    sensor_ds_rate                  ;
wire    [2-1:0]     sensor_mode_sel                 ;
wire                fbc_bias_vol_en                 ;
wire    [15:0]      fbc_bias_voltage                ;
wire    [15:0]      fbc_cali_uop_set                ;

wire    [24:0]      position_pid_thr                ;
wire    [24:0]      fbc_pose_err_thr                ;
wire                fbc_close_state                 ;
wire    [24:0]      fbc_ratio_max_thr               ;
wire    [24:0]      fbc_ratio_min_thr               ;
wire                fbc_close_state_err             ;
wire                fbc_ratio_err                   ;
wire    [3-1:0]     scan_state                      ;
wire    [25-1:0]    err_position_latch              ;
wire    [22-1:0]    err_intensity_latch             ;

wire                motor_data_in_en                ;
wire    [15:0]      motor_Ufeed_latch               ;
wire    [15:0]      motor_data_in                   ;
wire                motor_rd_en                     ;
wire                motor_data_out_en               ;
wire    [15:0]      motor_data_out                  ;
wire    [32-1:0]    delta_position                  ;

wire    [2-1:0]     dbg_mem_state                   ;
wire                dbg_mem_rd_en                   ;
wire    [32*5-1:0]  dbg_mem_rd_data                 ;
    // calibrate voltage. dark current * R
wire                FBCi_cali_en              ;
wire    [23:0]      FBCi_cali_a               ;
wire    [23:0]      FBCi_cali_b               ;
wire                FBCr1_cali_en             ;
wire    [23:0]      FBCr1_cali_a              ;
wire    [23:0]      FBCr1_cali_b              ;
wire                FBCr2_cali_en             ;
wire    [23:0]      FBCr2_cali_a              ;
wire    [23:0]      FBCr2_cali_b              ;
    // actual voltage
wire                FBCi_out_en               ;
wire    [23:0]      FBCi_out_a                ;
wire    [23:0]      FBCi_out_b                ;
wire                FBCr1_out_en              ;
wire    [23:0]      FBCr1_out_a               ;
wire    [23:0]      FBCr1_out_b               ;
wire                FBCr2_out_en              ;
wire    [23:0]      FBCr2_out_a               ;
wire    [23:0]      FBCr2_out_b               ;
    // background voltage. dark current * R
wire                FBCi_bg_en                ;
wire    [23:0]      FBCi_bg_a                 ;
wire    [23:0]      FBCi_bg_b                 ;
wire                FBCr1_bg_en               ;
wire    [23:0]      FBCr1_bg_a                ;
wire    [23:0]      FBCr1_bg_b                ;
wire                FBCr2_bg_en               ;
wire    [23:0]      FBCr2_bg_a                ;
wire    [23:0]      FBCr2_bg_b                ;

wire    [32-1:0]    laser_tx_data       ;
wire                laser_tx_vld        ;
wire    [7:0]       laser_rx_data       ;
wire                laser_rx_vld        ;
wire                laser_rx_last       ;

reg	        FPGA_TO_SFPGA_RESERVE0  = 0;
wire        FPGA_TO_SFPGA_RESERVE1;
wire        FPGA_TO_SFPGA_RESERVE2;
wire        FPGA_TO_SFPGA_RESERVE3;
wire        FPGA_TO_SFPGA_RESERVE4;


reg motor_data_out_en_sim = 'd0;
reg [16-1:0] motor_data_out_sim = 'd0;
reg [16-1:0] ufeed_cnt = 'd0;



initial
begin
    forever #(PERIOD/2)  clk_100m=~clk_100m;
end

initial
begin
    forever #(3.33/2)  clk_300m=~clk_300m;
end

initial
begin
    forever #(20/2)  FPGA_TO_SFPGA_RESERVE0=~FPGA_TO_SFPGA_RESERVE0;
end

initial
begin
    #(20*2) rst  =  0;
end

// motor adc simulate
reg_delay #(
    .DATA_WIDTH                     ( 17                                    ),
    .DELAY_NUM                      ( 32                                    )
)reg_delay_inst(
    .clk_i                          ( clk_100m                              ),
    .src_data_i                     ( {motor_rd_en,motor_data_in}      ),
    .delay_data_o                   ( {motor_data_out_en,motor_data_out}    )
);

bpsi_top_if_v2 bpsi_top_if_v2_inst(
    .clk_sys_i                      ( clk_100m                      ),
    .clk_h_i                        ( clk_300m                      ),
    .rst_i                          ( rst                           ),
                
    .data_acq_en_i                  ( bpsi_data_acq_en              ), // motor enable signal
    .bg_data_acq_en_i               ( bpsi_bg_data_acq_en           ), // background sample
    .position_cali_en_i             ( bpsi_position_en              ), // test
    .sensor_mode_sel_i              ( sensor_mode_sel               ),
    .sensor_ds_rate_i               ( sensor_ds_rate                ),
    .position_aim_i                 ( bpsi_position_aim             ), // aim position
    .kp_i                           ( bpsi_kp                       ), // PID controller kp parameter
    .ki_i                           ( bpsi_ki                       ), // PID controller ki parameter
    .kd_i                           ( bpsi_kd                       ), // PID controller kd parameter
    .motor_freq_i                   ( bpsi_motor_freq               ), // motor response frequency. 0:100Hz 1:200Hz 2:300Hz
    .motor_bias_vol_en_i            ( fbc_bias_vol_en               ),
    .fbc_bias_voltage_i             ( fbc_bias_voltage              ),
    .fbc_cali_uop_set_i             ( fbc_cali_uop_set              ),

    .position_pid_thr_i             ( position_pid_thr              ),
    .fbc_pose_err_thr_i             ( fbc_pose_err_thr              ),
    .fbc_close_state_o              ( fbc_close_state               ),
    .fbc_ratio_max_thr_i            ( fbc_ratio_max_thr             ),
    .fbc_ratio_min_thr_i            ( fbc_ratio_min_thr             ),
    .fbc_close_state_err_o          ( fbc_close_state_err           ),
    .err_position_latch_o           ( err_position_latch            ),
    .fbc_ratio_err_o                ( fbc_ratio_err                 ),
    .err_intensity_latch_o          ( err_intensity_latch           ),

    .motor_rd_en_o                  ( motor_rd_en                   ), // read Ufeed en  
    .motor_data_out_en_i            ( motor_data_out_en             ), // Ufeed en
    .motor_data_out_i               ( motor_data_out                ), // Ufeed
    .motor_data_in_en_o             ( motor_data_in_en              ), // Uop en
    .motor_Ufeed_latch_o            ( motor_Ufeed_latch             ),
    .motor_data_in_o                ( motor_data_in                 ), // Uop to motor
    .delta_position_o               ( delta_position                ),

    .dbg_mem_rd_en_i                ( dbg_mem_rd_en                 ),
    .dbg_mem_start_i                ( dbg_mem_start                 ),
    .dbg_mem_state_o                ( dbg_mem_state                 ),
    .dbg_mem_rd_data_o              ( dbg_mem_rd_data               ),
    // calibrate voltage. dark current * R
    .FBCi_cali_en_o                 ( FBCi_cali_en                  ),
    .FBCi_cali_a_o                  ( FBCi_cali_a                   ),
    .FBCi_cali_b_o                  ( FBCi_cali_b                   ),
    .FBCr1_cali_en_o                ( FBCr1_cali_en                 ),
    .FBCr1_cali_a_o                 ( FBCr1_cali_a                  ),
    .FBCr1_cali_b_o                 ( FBCr1_cali_b                  ),
    .FBCr2_cali_en_o                ( FBCr2_cali_en                 ),
    .FBCr2_cali_a_o                 ( FBCr2_cali_a                  ),
    .FBCr2_cali_b_o                 ( FBCr2_cali_b                  ),
    // actual voltage
    .FBCi_out_en_o                  ( FBCi_out_en                   ),
    .FBCi_out_a_o                   ( FBCi_out_a                    ),
    .FBCi_out_b_o                   ( FBCi_out_b                    ),
    .FBCr1_out_en_o                 ( FBCr1_out_en                  ),
    .FBCr1_out_a_o                  ( FBCr1_out_a                   ),
    .FBCr1_out_b_o                  ( FBCr1_out_b                   ),
    .FBCr2_out_en_o                 ( FBCr2_out_en                  ),
    .FBCr2_out_a_o                  ( FBCr2_out_a                   ),
    .FBCr2_out_b_o                  ( FBCr2_out_b                   ),
    // background voltage. dark current * R
    .FBCi_bg_en_o                   ( FBCi_bg_en                    ),
    .FBCi_bg_a_o                    ( FBCi_bg_a                     ),
    .FBCi_bg_b_o                    ( FBCi_bg_b                     ),
    .FBCr1_bg_en_o                  ( FBCr1_bg_en                   ),
    .FBCr1_bg_a_o                   ( FBCr1_bg_a                    ),
    .FBCr1_bg_b_o                   ( FBCr1_bg_b                    ),
    .FBCr2_bg_en_o                  ( FBCr2_bg_en                   ),
    .FBCr2_bg_a_o                   ( FBCr2_bg_a                    ),
    .FBCr2_bg_b_o                   ( FBCr2_bg_b                    ),
    // spi info
    .FBCi_MCLK                      ( BPSi_MCLK                     ),
    .FBCi_MOSI                      ( BPSi_MOSI                     ),
    .FBCi_SCLK                      ( BPSi_SCLK                     ),
    .FBCi_MISO                      ( BPSi_MISO                     ),
    .FBCr1_MCLK                     ( BPSr1_MCLK                    ),
    .FBCr1_MOSI                     ( BPSr1_MOSI                    ),
    .FBCr1_SCLK                     ( BPSr1_SCLK                    ),
    .FBCr1_MISO                     ( BPSr1_MISO                    ),
    .FBCr2_MCLK                     ( BPSr2_MCLK                    ),
    .FBCr2_MOSI                     ( BPSr2_MOSI                    ),
    .FBCr2_SCLK                     ( BPSr2_SCLK                    ),
    .FBCr2_MISO                     ( BPSr2_MISO                    )
);

`ifdef SIMULATE
always @(posedge clk_100m) begin
    if(ufeed_cnt == 'd4800-1)begin
        motor_data_out_en_sim <= 'd1;
        motor_data_out_sim <= motor_data_out_sim + 1;
        ufeed_cnt <= ufeed_cnt + 1;
    end
    else if(ufeed_cnt == 'd4800)begin
        if(motor_rd_en)
            ufeed_cnt <= 'd0;
        motor_data_out_en_sim <= 'd0;
    end
    else begin
        ufeed_cnt <= ufeed_cnt + 1;
    end
end
`endif //SIMULATE

reg [32-1:0] fbc_out_cnt = 'd0;
wire   [31:0]      real_precise_encode_w     = fbc_out_cnt;
wire   [31:0]      real_precise_encode_x     = fbc_out_cnt;



always @(posedge clk_100m) begin
    if(rst)
        fbc_out_cnt <= 'd0;
    else 
        fbc_out_cnt <= fbc_out_cnt + 4;
end


// mfpga to mainPC message arbitrate 
arbitrate_bpsi arbitrate_bpsi_inst(
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst                           ),
    .FBC_out_fifo_rst_i             ( rst                           ),
    
    // calibrate voltage. dark current * R
    .FBCi_cali_en_i                 ( FBCi_cali_en                  ),
    .FBCi_cali_a_i                  ( FBCi_cali_a                   ),
    .FBCi_cali_b_i                  ( FBCi_cali_b                   ),
    .FBCr1_cali_en_i                ( FBCr1_cali_en                 ),
    .FBCr1_cali_a_i                 ( FBCr1_cali_a                  ),
    .FBCr1_cali_b_i                 ( FBCr1_cali_b                  ),
    .FBCr2_cali_en_i                ( FBCr2_cali_en                 ),
    .FBCr2_cali_a_i                 ( FBCr2_cali_a                  ),
    .FBCr2_cali_b_i                 ( FBCr2_cali_b                  ),
    // actual voltage
    .FBCi_out_en_i                  ( FBCi_out_en                   ),
    .FBCi_out_a_i                   ( FBCi_out_a                    ),
    .FBCi_out_b_i                   ( FBCi_out_b                    ),
    .FBCr1_out_en_i                 ( FBCr1_out_en                  ),
    .FBCr1_out_a_i                  ( FBCr1_out_a                   ),
    .FBCr1_out_b_i                  ( FBCr1_out_b                   ),
    .FBCr2_out_en_i                 ( FBCr2_out_en                  ),
    .FBCr2_out_a_i                  ( FBCr2_out_a                   ),
    .FBCr2_out_b_i                  ( FBCr2_out_b                   ),
    // Enocde
    .encode_w_i                     ( real_precise_encode_w                 ),
    .encode_x_i                     ( {4'd0,real_precise_encode_x[31:4]}    ),
    // background voltage. dark current * R
    .FBCi_bg_en_i                   ( FBCi_bg_en                    ),
    .FBCi_bg_a_i                    ( FBCi_bg_a                     ),
    .FBCi_bg_b_i                    ( FBCi_bg_b                     ),
    .FBCr1_bg_en_i                  ( FBCr1_bg_en                   ),
    .FBCr1_bg_a_i                   ( FBCr1_bg_a                    ),
    .FBCr1_bg_b_i                   ( FBCr1_bg_b                    ),
    .FBCr2_bg_en_i                  ( FBCr2_bg_en                   ),
    .FBCr2_bg_a_i                   ( FBCr2_bg_a                    ),
    .FBCr2_bg_b_i                   ( FBCr2_bg_b                    ),
    
    .motor_data_in_en_i             ( motor_data_in_en              ), // Uop en
    .motor_data_out_i               ( motor_Ufeed_latch             ), // Ufeed
    .motor_data_in_i                ( motor_data_in                 ), // Uop to motor

    .laser_rx_data_i                ( laser_rx_data                 ), // laser uart
    .laser_rx_vld_i                 ( laser_rx_vld                  ), // laser uart
    .laser_rx_last_i                ( laser_rx_last                 ), // laser uart

    .slave_tx_ack_i                 ( slave_tx_ack                  ),
    .slave_tx_byte_en_o             ( slave_tx_byte_en              ),
    .slave_tx_byte_o                ( slave_tx_byte                 ),
    .slave_tx_byte_num_en_o         ( slave_tx_byte_num_en          ),
    .slave_tx_byte_num_o            ( slave_tx_byte_num             )

);

slave_comm slave_comm_inst(
    // clk & rst
    .clk_sys_i                      ( clk_100m                      ),
    .rst_i                          ( rst                           ),
    // salve tx info
    .slave_tx_en_i                  ( slave_tx_byte_en              ),
    .slave_tx_data_i                ( slave_tx_byte                 ),
    .slave_tx_byte_num_en_i         ( slave_tx_byte_num_en          ),
    .slave_tx_byte_num_i            ( slave_tx_byte_num             ),
    .slave_tx_ack_o                 ( slave_tx_ack                  ),
    // slave rx info
    .rd_data_vld_o                  ( slave_rx_data_vld             ),
    .rd_data_o                      ( slave_rx_data                 ),
    // info
    .SLAVE_MSG_CLK                  ( FPGA_TO_SFPGA_RESERVE0        ),
    .SLAVE_MSG_TX_FSX               ( FPGA_TO_SFPGA_RESERVE3        ),
    .SLAVE_MSG_TX                   ( FPGA_TO_SFPGA_RESERVE4        ),
    .SLAVE_MSG_RX_FSX               ( FPGA_TO_SFPGA_RESERVE1        ),
    .SLAVE_MSG_RX                   ( FPGA_TO_SFPGA_RESERVE2        )
);

command_map command_map_inst(
    .clk_sys_i                      ( clk_100m                      ),
    .rst_i                          ( rst                           ),
    .slave_rx_data_vld_i            ( slave_rx_data_vld             ),
    .slave_rx_data_i                ( slave_rx_data                 ),
    
    .data_acq_en_o                  ( bpsi_data_acq_en              ),
    .bg_data_acq_en_o               ( bpsi_bg_data_acq_en           ),
    .position_arm_o                 ( bpsi_position_aim             ),
    .kp_o                           ( bpsi_kp                       ),
    .ki_o                           ( bpsi_ki                       ),
    .kd_o                           ( bpsi_kd                       ),
    .motor_freq_o                   ( bpsi_motor_freq               ),
    .bpsi_position_en_o             ( bpsi_position_en              ),
    .sensor_ds_rate_o               ( sensor_ds_rate                ),
    .sensor_mode_sel_o              ( sensor_mode_sel               ),
    .fbc_bias_vol_en_o              ( fbc_bias_vol_en               ),
    .fbc_bias_voltage_o             ( fbc_bias_voltage              ),
    .fbc_cali_uop_set_o             ( fbc_cali_uop_set              ),
    .eds_power_en_o                 ( eds_power_en                  ),
    .eds_frame_en_o                 ( eds_frame_en                  ),
    .laser_uart_data_o              ( laser_tx_data                 ),
    .laser_uart_vld_o               ( laser_tx_vld                  ),
    .dbg_mem_rd_en_o                ( dbg_mem_rd_en                 ),
    .dbg_mem_start_o                ( dbg_mem_start                 ),
    .dbg_mem_state_i                ( dbg_mem_state                 ),
    .dbg_mem_rd_data_i              ( dbg_mem_rd_data               ),

    .debug_info                     (                      )   
);


laser_comm_ctrl laser_comm_ctrl_inst(
    // clk & rst
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst                           ),
    
    .laser_tx_data_i                ( laser_tx_data                 ),
    .laser_tx_vld_i                 ( laser_tx_vld                  ),
    .laser_rx_data_o                ( laser_rx_data                 ),
    .laser_rx_vld_o                 ( laser_rx_vld                  ),
    .laser_rx_last_o                ( laser_rx_last                 ),

    // interface    
    .LASER_UART_RXD                 ( UART_RX                       ),
    .LASER_UART_TXD                 ( UART_TX                       )
);
message_comm_rx message_comm_rx_inst(
    .clk                 ( FPGA_TO_SFPGA_RESERVE0 ),
    .rst_n               ( 0 ),
    .msg_rx_data_vld_o   ( ),
    .msg_rx_data_o       ( ),
    .MSG_CLK             ( FPGA_TO_SFPGA_RESERVE0 ),
    .MSG_RX_FSX          ( FPGA_TO_SFPGA_RESERVE3 ),
    .MSG_RX              ( FPGA_TO_SFPGA_RESERVE4 )
);

initial
begin
    #10000;
    $finish;
end

endmodule