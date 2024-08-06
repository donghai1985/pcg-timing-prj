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

wire                slave_tx_ack                    ;
wire                slave_tx_byte_en                ;
wire    [ 7:0]      slave_tx_byte                   ;
wire                slave_tx_byte_num_en            ;
wire    [15:0]      slave_tx_byte_num               ;
wire                slave_rx_data_vld               ;
wire    [ 7:0]      slave_rx_data                   ;

wire    [4-1:0]     pmt_scan_cmd_sel                ;
wire    [4-1:0]     pmt_scan_cmd                    ;
wire    [4-1:0]     pmt_start_en                    ;
wire    [4-1:0]     pmt_start_test_en               ;
wire    [2:0]       pcie_pmt_end_en                 ;
wire    [2:0]       aurora_fbc_end                  ;
wire    [4-1:0]     pmt_master_cmd_parser           ;
wire    [32-1:0]    pmt_master_wr_data              ;
wire    [1:0]       pmt_master_wr_vld               ;
wire    [32-1:0]    pmt_master_spi_data             ;
wire                pmt_master_spi_vld              ;
wire    [32-1:0]    pmt_adc_start_data              ;
wire                pmt_adc_start_vld               ;
wire    [32-1:0]    pmt_adc_start_hold              ;
wire                spi_slave_ack_vld   [3:0]       ;
wire                spi_slave_ack_last  [3:0]       ;
wire    [32-1:0]    spi_slave_ack_data  [3:0]       ;

wire                acc_job_control                 ;
// wire                acc_job_init_switch             ;
wire                acc_job_init_vol_trig           ;
wire    [12-1:0]    acc_job_init_vol                ;
wire    [12-1:0]    acc_aom_class0                  ;
wire    [12-1:0]    acc_aom_class1                  ;
wire    [12-1:0]    acc_aom_class2                  ;
wire    [12-1:0]    acc_aom_class3                  ;
wire    [12-1:0]    acc_aom_class4                  ;
wire    [12-1:0]    acc_aom_class5                  ;
wire    [12-1:0]    acc_aom_class6                  ;
wire    [12-1:0]    acc_aom_class7                  ;
wire                aom_trig_protect                ;
wire    [32-1:0]    aom_continuous_trig_thre        ;
wire    [32-1:0]    aom_integral_trig_thre          ;
wire    [12-1:0]    aom_trig_vol_thre               ;
wire                aom_continuous_trig_err         ;
wire                aom_integral_trig_err           ;
wire                acc_pmt_flag                    ;
wire    [12-1:0]    acc_aom_class                   ;
wire                acc_demo_flag                   ;
wire    [16-1:0]    acc_demo_trim_time_pose         ;
wire    [16-1:0]    acc_demo_trim_time_nege         ;
wire    [32-1:0]    acc_demo_xencode_offset         ;
wire                acc_demo_trim_ctrl              ;
wire                acc_demo_trim_flag              ; 
wire    [32-1:0]    acc_trigger_num                 ;

wire                acc_demo_mode                   ;
wire                acc_demo_wren                   ;
wire    [16-1:0]    acc_demo_addr                   ;
wire    [32-1:0]    acc_demo_Wencode                ;
wire    [32-1:0]    acc_demo_Xencode                ;
wire    [16-1:0]    acc_demo_particle_cnt           ;
wire    [32-1:0]    acc_demo_skip_cnt               ;
wire    [32-1:0]    acc_demo_addr_latch             ;
wire                acc_skip_fifo_rd                ;
wire                acc_skip_fifo_ready             ;
wire    [64-1:0]    acc_skip_fifo_data              ;

wire                FPGA_MASTER_CLOCK               ;
wire                clk_200m                        ;
wire                clk_250m                        ;
wire                clk_50m                         ;
wire                clk_80m                         ;
wire                clk_div_3                       ;
wire                clk_div_6                       ;
wire                eds_clk                         ;
wire                pll_locked                      ;
wire                pll_2_locked                    ;

wire    [4-1:0]     ACC_SPI_SCLK                    ;
wire    [4-1:0]     ACC_SPI_MISO                    ;
wire    [4-1:0]     acc_pmt_flag_sel                ;

wire    [4-1:0]     ENCODE_SPI_MCLK                 ;
wire    [4-1:0]     ENCODE_SPI_MOSI                 ;

wire    [4-1:0]     PMT_SPI_MCLK                    ;
wire    [4-1:0]     PMT_SPI_MOSI                    ;
wire    [4-1:0]     PMT_SPI_SCLK                    ;
wire    [4-1:0]     PMT_SPI_MISO                    ;

wire                BPSi_MCLK                       ;
wire                BPSi_MOSI                       ;
wire                BPSi_SCLK                       ;
wire                BPSi_MISO                       ;
wire                BPSr1_MCLK                      ;
wire                BPSr1_MOSI                      ;
wire                BPSr1_SCLK                      ;
wire                BPSr1_MISO                      ;
wire                BPSr2_MCLK                      ;
wire                BPSr2_MOSI                      ;
wire                BPSr2_SCLK                      ;
wire                BPSr2_MISO                      ;

wire                EDS_TC                          ;
wire                EDS_TFG                         ;
wire    [3:0]       EDS_DATA                        ;
wire                EDS_CC1                         ;
wire                EDS_CC2                         ;
wire                EDS_CC3                         ;
wire                EDS_CC4                         ;

wire                eds_frame_en                    ;
wire    [3-1:0]     eds_frame_sel                   ;
wire                eds_frame_cmd_en                ;
wire    [3-1:0]     eds_frame_cmd_sel               ;
wire    [32-1:0]    eds_frame_cmd_hold              ;
wire                eds_test_en                     ;
wire                eds_power_en                    ;
wire    [31:0]      texp_time                       ;
wire    [31:0]      frame_to_frame_time             ;

wire                eds_scan_en                     ;
wire                eds_scan_en_sync                ;
wire                eds_sensor_data_en              ;
wire    [127:0]     eds_sensor_data                 ;
wire    [127:0]     eds_sensor_data_temp            ;
wire                eds_sensor_training_done        ;
wire                eds_sensor_training_result      ;

wire    [4-1:0]     ACC_SPI_SCLK_P                  ;
wire    [4-1:0]     ACC_SPI_SCLK_N                  ;
wire    [4-1:0]     ACC_SPI_MISO_P                  ;
wire    [4-1:0]     ACC_SPI_MISO_N                  ;

wire    [4-1:0]     ENCODE_SPI_MCLK_P               ;
wire    [4-1:0]     ENCODE_SPI_MCLK_N               ;
wire    [4-1:0]     ENCODE_SPI_MOSI_P               ;
wire    [4-1:0]     ENCODE_SPI_MOSI_N               ;

wire    [4-1:0]     PMT_SPI_MCLK_P                  ;
wire    [4-1:0]     PMT_SPI_MCLK_N                  ;
wire    [4-1:0]     PMT_SPI_MOSI_P                  ;
wire    [4-1:0]     PMT_SPI_MOSI_N                  ;
wire    [4-1:0]     PMT_SPI_SCLK_P                  ;
wire    [4-1:0]     PMT_SPI_SCLK_N                  ;
wire    [4-1:0]     PMT_SPI_MISO_P                  ;
wire    [4-1:0]     PMT_SPI_MISO_N                  ;
    // actual voltage
wire                FBC_out_fifo_rst                ;
wire                fbc_udp_rate_switch             ;
wire                FBCi_out_en                     ;
wire    [23:0]      FBCi_out_a                      ;
wire    [23:0]      FBCi_out_b                      ;
wire                FBCr1_out_en                    ;
wire    [23:0]      FBCr1_out_a                     ;
wire    [23:0]      FBCr1_out_b                     ;
wire                FBCr2_out_en                    ;
wire    [23:0]      FBCr2_out_a                     ;
wire    [23:0]      FBCr2_out_b                     ;
    // background voltage. dark current * R
wire                FBCi_bg_en                      ;
wire    [23:0]      FBCi_bg_a                       ;
wire    [23:0]      FBCi_bg_b                       ;
wire                FBCr1_bg_en                     ;
wire    [23:0]      FBCr1_bg_a                      ;
wire    [23:0]      FBCr1_bg_b                      ;
wire                FBCr2_bg_en                     ;
wire    [23:0]      FBCr2_bg_a                      ;
wire    [23:0]      FBCr2_bg_b                      ;

// FBC cache data
wire                FBCi_cache_vld                  ;
wire    [48-1:0]    FBCi_cache_data                 ;
wire                FBCr1_cache_vld                 ;
wire    [48-1:0]    FBCr1_cache_data                ;
wire                FBCr2_cache_vld                 ;
wire    [48-1:0]    FBCr2_cache_data                ;

// QPD cache data
wire                quad_sensor_data_en             ;
wire    [96-1:0]    quad_sensor_data                ;
wire                quad_sensor_bg_data_en          ;
wire    [96-1:0]    quad_sensor_bg_data             ;
wire                quad_cache_vld                  ;
wire    [96-1:0]    quad_cache_data                 ;

wire    [4-1:0]     map_readback_cnt                ;
wire    [4-1:0]     main_scan_cnt                   ;
wire                rd_mfpga_version                ;
wire    [64-1:0]    heartbeat_data                  ;
wire                heartbeat_en                    ;
wire    [64-1:0]    fpga_message_up_data            ;
wire                fpga_message_up                 ;
wire    [64-1:0]    readback_data                   ;
wire                readback_vld                    ;
wire                bpsi_bg_data_acq_en             ;
wire    [2:0]       bpsi_data_acq_en                ;
wire    [24:0]      bpsi_position_aim               ;
wire    [26-1:0]    bpsi_kp                         ;
wire    [26-1:0]    bpsi_ki                         ;
wire    [26-1:0]    bpsi_kd                         ;
wire    [3:0]       bpsi_motor_freq                 ;
// wire                bpsi_position_en                ;
wire    [2-1:0]     sensor_ds_rate                  ;
wire    [2-1:0]     sensor_mode_sel                 ;
wire                fbc_bias_vol_en                 ;
wire    [15:0]      fbc_bias_voltage                ;
wire    [15:0]      fbc_cali_uop_set                ;
wire    [15:0]      ascent_gradient                 ;
wire    [15:0]      slow_ascent_period              ;
wire                quad_sensor_bg_en               ;
wire                sensor_config_en                ;
wire    [16-1:0]    sensor_config_cmd               ;
wire                sensor_config_test              ;

wire                motor_data_in_en                ;
wire    [15:0]      motor_Ufeed_latch               ;
wire    [15:0]      motor_data_in                   ;
wire                motor_rd_en                     ;
wire                motor_data_out_en               ;
wire    [15:0]      motor_data_out                  ;
wire    [32-1:0]    delta_position                  ;

wire                gt_rst                          ;

wire                GT1_refclk1                     ;
wire                GT1_qpllclk_quad1               ;
wire                GT1_qpllrefclk_quad1            ;
wire                GT1_qpllrefclklost              ;
wire                GT1_qplllock                    ;

wire    [2-1:0]     cfg_acc_use                     = 0;
wire                cfg_fbc_rate                    = 0;
wire                cfg_spindle_width               = 0;
wire    [2-1:0]     cfg_FBC_bypass                  = 0;
wire                cfg_QPD_enable                  = 1;
wire                dbg_qpd_mode                    = 0;

wire                GT0_refclk1                     ;
wire                GT0_qpllclk_quad1               ;
wire                GT0_qpllrefclk_quad1            ;
wire                GT0_qpllrefclklost              ;
wire                GT0_qplllock                    ;

wire    [4-1:0]     aurora_empty[0:2]               ;
wire    [3-1:0]     aurora_soft_rd                  ;
wire    [2:0]       aurora_log_clk                  ;
wire    [2:0]       aurora_rst                      ;
wire    [2:0]       pcie_eds_frame_end              ;


// wire                rst_100m                        ;
wire                ddr_ui_clk                      ;
wire                ddr_rst                         ;

// FBC to IMC
wire                ddr3_init_done                  ;
wire    [3-1:0]     pmt_scan_en                     ;

wire                fbc_cache_vld                   ;
wire    [256-1:0]   fbc_cache_data                  ;
wire                fbc_up_start                    ;
wire    [3-1:0]     fbc_up_en                       ;
wire                fbc_scan_en                     ;

wire                fbc_vout_empty                  ;
wire                fbc_vout_rd_seq                 ;
wire                fbc_vout_rd_vld                 ;
wire    [64-1:0]    fbc_vout_rd_data                ;
wire                fbc_vout_end                    ;
wire                aurora_fbc_vout_end             ;
wire                aurora_fbc_vout_vld             ;
wire    [64-1:0]    aurora_fbc_vout_data            ;
wire    [3-1:0]     aurora_fbc_almost_full          ;

wire                x_zero_flag                     ;
wire                x_data_out_en                   ;
wire                w_data_out_en                   ;
wire    [31:0]      x_data_out                      ;
wire    [31:0]      w_data_out                      ;

wire                precise_encode_en               ;
wire    [31:0]      precise_encode_w                ;
wire    [31:0]      precise_encode_x                ;
wire                align_src_encode_en             ;
wire    [32-1:0]    align_src_encode_w              ;
wire    [32-1:0]    align_src_encode_x              ;
wire                pmt_precise_encode_en           ;
wire    [18-1:0]    pmt_precise_encode_w            ;
wire    [18-1:0]    pmt_precise_encode_x            ;
wire                eds_precise_encode_en           ;
wire    [31:0]      eds_precise_encode_w            ;
wire    [31:0]      eds_precise_encode_x            ;

wire                real_precise_encode_en          ;
wire    [31:0]      real_precise_encode_w           ;
wire    [31:0]      real_precise_encode_x           ;
wire                acc_demo_encode_en              ;
wire    [32-1:0]    acc_demo_encode_w               ;
wire    [32-1:0]    acc_demo_encode_x               ;

reg                 pmt_precise_encode_en_temp  = 'd0;
reg     [32-1:0]    pmt_precise_encode_w_temp   = 'd0;
reg     [32-1:0]    pmt_precise_encode_x_temp   = 'd0;
// wire    [32-1:0]    pmt_precise_encode_w_flag       ;
// wire    [32-1:0]    pmt_precise_encode_x_flag       ;

wire                pmt_Wencode_align_rst           ;
wire    [32-1:0]    pmt_Wencode_align_set           ;
wire                pmt_Xencode_align_rst           ;
wire    [32-1:0]    pmt_Xencode_align_set           ;
wire                eds_Wencode_align_rst           ;
wire    [32-1:0]    eds_Wencode_align_set           ;
wire                eds_Xencode_align_rst           ;
wire    [32-1:0]    eds_Xencode_align_set           ;

wire    [32-1:0]    scan_encode_offset              ;
wire    [32-1:0]    autocal_encode_offset           ;
wire    [3-1:0]     autocal_fbp_sel                 ;
wire    [32-1:0]    fbp_encode_start                ;
wire    [32-1:0]    fbp_encode_end                  ;
wire    [3-1:0]     autocal_pow_sel                 ;
wire    [32-1:0]    pow_encode_start                ;
wire    [32-1:0]    pow_encode_end                  ;
wire    [3-1:0]     autocal_lpo_sel                 ;
wire    [32-1:0]    lpo_encode_start                ;
wire    [32-1:0]    lpo_encode_end                  ;
wire    [32-1:0]    precise_encode_offset           ;
wire                main_scan_start                 ;
wire    [4-1:0]     autocal_process                 ;
wire                autocal_fbp_scan                ;
wire                autocal_pow_scan                ;
wire                autocal_lpo_scan                ;

wire                src_rcv_1                       ;
wire                src_rcv_2                       ;
wire                src_rcv_3                       ;
reg                 dest_ack_1              = 'd0   ;
reg                 dest_ack_2              = 'd0   ;
reg                 dest_ack_3              = 'd0   ;

wire                w_data_error                    ;
wire                w_data_warn                     ;
wire                motion_en_vio                   ;


wire                ad5592_1_dac_config_en          ;
wire    [2:0]       ad5592_1_dac_channel            ;
wire    [11:0]      ad5592_1_dac_data               ;
wire                ad5592_1_adc_config_en          ;
wire    [7:0]       ad5592_1_adc_channel            ;
wire                ad5592_1_spi_conf_ok            ;
wire                ad5592_1_init                   ;
wire                ad5592_1_adc_data_en            ;
wire    [11:0]      ad5592_1_adc_data               ;

wire                ad5592_2_dac_config_en          ;
wire    [2:0]       ad5592_2_dac_channel            ;
wire    [11:0]      ad5592_2_dac_data               ;
wire                ad5592_2_adc_config_en          ;
wire    [7:0]       ad5592_2_adc_channel            ;
wire                ad5592_2_spi_conf_ok            ;
wire                ad5592_2_init                   ;
wire                ad5592_2_adc_data_en            ;
wire    [11:0]      ad5592_2_adc_data               ;

wire                temp_rd_en                      ;
wire                temp_data_en                    ;
wire    [11:0]      temp_data                       ;

wire                eeprom_w_en                     ;
wire    [31:0]      eeprom_w_addr_data              ;
wire                eeprom_r_addr_en                ;
wire    [15:0]      eeprom_r_addr                   ;
wire                eeprom_r_data_en                ;
wire    [7:0]       eeprom_r_data                   ;
wire                eeprom_spi_ok                   ;

wire    [32-1:0]    laser_tx_data                   ;
wire                laser_tx_vld                    ;
wire    [7:0]       laser_rx_data                   ;
wire                laser_rx_vld                    ;
wire                laser_rx_last                   ;

wire                x_encode_zero_calib             ;

wire                fast_shutter_set                ;
wire                fast_shutter_en                 ;
wire                soft_fast_shutter_set           ;
wire                soft_fast_shutter_en            ;
wire                fast_shutter_state              ;
wire    [32-1:0]    fast_shutter_act_time           ;
wire                scan_fbc_switch                 ;

wire                scan_soft_reset                 ;
wire                scan_start_cmd                  ;
wire    [3-1:0]     scan_start_sel                  ;
wire    [32-1:0]    x_start_encode                  ;
wire    [32-1:0]    fast_shutter_encode             ;
wire    [32-1:0]    x_end_encode                    ;
wire    [32-1:0]    plc_x_encode                    ;
wire                plc_x_encode_en                 ;
wire                fbc_close_loop                  ;
wire                fbc_open_loop                   ;
wire                real_scan_flag                  ;
wire    [3-1:0]     real_scan_sel                   ;
wire                acc_force_on                    ;
wire    [32-1:0]    start_encode_latch              ;
wire    [32-1:0]    sfrst_encode_latch              ;
wire                scan_finish_comm                ;
wire                scan_finish_comm_ack            ;
wire                scan_error_comm                 ;
wire    [4-1:0]     scan_error_comm_flag            ;
wire    [24:0]      position_pid_thr                ;
wire    [24:0]      fbc_pose_err_thr                ;
wire                fbc_close_state                 ;
wire    [24:0]      fbc_ratio_max_thr               ;
wire    [24:0]      fbc_ratio_min_thr               ;
wire                fbc_close_state_err             ;
wire                fbc_ratio_err                   ;
wire    [4-1:0]     scan_state                      ;
wire    [25-1:0]    err_position_latch              ;
wire    [22-1:0]    err_intensity_latch             ;


wire                scan_aurora_reset               ;
wire                aurora_scan_reset               ;
wire    [3-1:0]     aurora_tx_idle                  ;

wire    [32-1:0]    eds_pack_cnt        [0:2]       ;
wire    [32-1:0]    encode_pack_cnt     [0:2]       ;
wire                laser_control                   ;
wire                laser_out_switch                ;
wire    [12-1:0]    laser_analog_max                ;
wire    [12-1:0]    laser_analog_min                ;
wire    [32-1:0]    laser_analog_pwm                ;
wire    [32-1:0]    laser_analog_cycle              ;
wire    [12-1:0]    laser_analog_uplimit            ;
wire    [12-1:0]    laser_analog_lowlimit           ;
wire                laser_analog_mode_sel           ;
wire                laser_analog_trigger            ;
wire                laser_aom_en                    ;
wire    [12-1:0]    laser_aom_voltage               ;

wire                clpc_flag                       ;
wire                acc_flag                        ;
wire    [4-1:0]     afs_flag                        ;
wire    [4-1:0]     autocal_flag                    ;
wire    [14-1:0]    timing_flag                     ;
wire    [14-1:0]    align_timing_flag               ;
wire    [32-1:0]    timing_flag_supp                ;

wire                encode_check_clean              ;
wire                w_encode_err_lock               ;
wire                w_encode_warn_lock              ;
wire    [18-1:0]    w_encode_continuity_max         ;
wire    [18-1:0]    w_encode_continuity_cnt         ;
// wire    [18-1:0]    w_src_encode_continuity_max     ;
// wire    [18-1:0]    w_src_encode_continuity_cnt     ;
// wire    [18-1:0]    w_eds_encode_continuity_max     ;
// wire    [18-1:0]    w_eds_encode_continuity_cnt     ;
wire                dbg_eds_frame_en[0:2]           ;
wire                dbg_eds_wencode_vld[0:2]        ;
wire    [18-1:0]    dbg_eds_wencode[0:2]            ;

reg	        FPGA_TO_SFPGA_RESERVE0  = 0;
wire        FPGA_TO_SFPGA_RESERVE1;
wire        FPGA_TO_SFPGA_RESERVE2;
wire        FPGA_TO_SFPGA_RESERVE3;
wire        FPGA_TO_SFPGA_RESERVE4;
wire        FPGA_TO_SFPGA_RESERVE5;
wire        FPGA_TO_SFPGA_RESERVE6;
wire        FPGA_TO_SFPGA_RESERVE7;
wire        FPGA_TO_SFPGA_RESERVE8;
wire        FPGA_TO_SFPGA_RESERVE9;

reg motor_data_out_en_sim = 'd0;
reg [16-1:0] motor_data_out_sim = 'd0;
reg [16-1:0] ufeed_cnt = 'd0;


parameter   [8*20-1:0]      VERSION     = "PCG_TimingM_v2.3.1  "; // 新Timing板，机台级更新



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

reg rst_100m = 1;
initial
begin
    #(PERIOD);
    rst_100m = 0;
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

`define QUAD_SENSOR

bpsi_top_if_v2 bpsi_top_if_v2_inst(
    .clk_sys_i                      ( clk_100m                      ),
    .clk_h_i                        ( clk_300m                      ),
    .rst_i                          ( rst_100m                      ),
                
    .cfg_fbc_rate_i                 ( cfg_fbc_rate                  ),
    .cfg_FBC_bypass_i               ( cfg_FBC_bypass                ),
    .cfg_QPD_enable_i               ( cfg_QPD_enable                ),
    .dbg_qpd_mode_i                 ( dbg_qpd_mode                  ),
    .data_acq_en_i                  ( bpsi_data_acq_en              ), // motor enable signal
    .bg_data_acq_en_i               ( bpsi_bg_data_acq_en           ), // background sample
    // .sensor_mode_sel_i              ( sensor_mode_sel               ),
    // .sensor_ds_rate_i               ( sensor_ds_rate                ),
    .position_aim_i                 ( bpsi_position_aim             ), // aim position
    .kp_i                           ( bpsi_kp                       ), // PID controller kp parameter
    .ki_i                           ( bpsi_ki                       ), // PID controller ki parameter
    .kd_i                           ( bpsi_kd                       ), // PID controller kd parameter
    .motor_freq_i                   ( bpsi_motor_freq               ), // motor response frequency. 0:100Hz 1:200Hz 2:300Hz
    .motor_bias_vol_en_i            ( fbc_bias_vol_en               ),
    .fbc_bias_voltage_i             ( fbc_bias_voltage              ),
    // .fbc_cali_uop_set_i             ( fbc_cali_uop_set              ),
    .ascent_gradient_i              ( ascent_gradient               ),
    .slow_ascent_period_i           ( slow_ascent_period            ),
    .quad_sensor_bg_en_i            ( quad_sensor_bg_en             ),
    .sensor_config_en_i             ( sensor_config_en              ), 
    .sensor_config_cmd_i            ( sensor_config_cmd             ),
    .sensor_config_test_i           ( sensor_config_test            ),

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

    .FBCi_cache_vld_o               ( FBCi_cache_vld                ),
    .FBCi_cache_data_o              ( FBCi_cache_data               ),
    .FBCr1_cache_vld_o              ( FBCr1_cache_vld               ),
    .FBCr1_cache_data_o             ( FBCr1_cache_data              ),
    .FBCr2_cache_vld_o              ( FBCr2_cache_vld               ),
    .FBCr2_cache_data_o             ( FBCr2_cache_data              ),

    .quad_sensor_data_en_o          ( quad_sensor_data_en           ),
    .quad_sensor_data_o             ( quad_sensor_data              ),
    .quad_sensor_bg_data_en_o       ( quad_sensor_bg_data_en        ),
    .quad_sensor_bg_data_o          ( quad_sensor_bg_data           ),
    .quad_cache_vld_o               ( quad_cache_vld                ),
    .quad_cache_data_o              ( quad_cache_data               ),
    // spi info
    .FBCi_MCLK                      ( BPSi_MCLK_P                   ),
    .FBCi_MOSI                      ( BPSi_MOSI_P                   ),
    .FBCi_SCLK                      ( BPSi_SCLK                     ),
    .FBCi_MISO                      ( BPSi_MISO                     ),
    .FBCr1_MCLK                     ( BPSr1_MCLK_P                  ),
    .FBCr1_MOSI                     ( BPSr1_MOSI_P                  ),
    .FBCr1_SCLK                     ( BPSr1_SCLK                    ),
    .FBCr1_MISO                     ( BPSr1_MISO                    ),
    .FBCr2_MCLK                     ( BPSr2_MCLK_P                  ),
    .FBCr2_MOSI                     ( BPSr2_MOSI_P                  ),
    .FBCr2_SCLK                     ( BPSr2_SCLK                    ),
    .FBCr2_MISO                     ( BPSr2_MISO                    )
);

fbc_sensor_sim#(
    .SPI_DELAY                      ( 1000                          ),
    .SPI_CLK_DIVIDER                ( 6                             ), // SPI Clock Control / Divid
    .SPI_MASTER_WIDTH               ( 48                            ), // master spi data width
    .SPI_SLAVE_WIDTH                ( 64                            )  // slave spi data width
)fbci_sensor_sim_inst(
    .clk_h_i                        ( clk_300m                      ),
    .rst_i                          ( rst_100m                      ),
    
    // sensor spi info
    .MSPI_CLK                       ( BPSi_SCLK                     ),
    .MSPI_MOSI                      ( BPSi_MISO                     ),
    .SSPI_CLK                       ( BPSi_MCLK_P                   ),
    .SSPI_MISO                      ( BPSi_MOSI_P                   )
);

`ifdef QUAD_SENSOR
fbc_sensor_sim#(
    .SPI_DELAY                      ( 100                           ),
    .SPI_CLK_DIVIDER                ( 6                             ), // SPI Clock Control / Divid
    .SPI_MASTER_WIDTH               ( 96                            ), // master spi data width
    .SPI_SLAVE_WIDTH                ( 64                            )  // slave spi data width
)fbcr1_sensor_sim_inst(
    .clk_h_i                        ( clk_300m                      ),
    .rst_i                          ( rst_100m                      ),
    
    // sensor spi info
    .MSPI_CLK                       ( BPSr1_SCLK                     ),
    .MSPI_MOSI                      ( BPSr1_MISO                     ),
    .SSPI_CLK                       ( BPSr1_MCLK_P                   ),
    .SSPI_MISO                      ( BPSr1_MOSI_P                   )
);

`else
fbc_sensor_sim#(
    .SPI_DELAY                      ( 2000                          ),
    .SPI_CLK_DIVIDER                ( 6                             ), // SPI Clock Control / Divid
    .SPI_MASTER_WIDTH               ( 48                            ), // master spi data width
    .SPI_SLAVE_WIDTH                ( 64                            )  // slave spi data width
)fbcr1_sensor_sim_inst(
    .clk_h_i                        ( clk_300m                      ),
    .rst_i                          ( rst_100m                      ),
    
    // sensor spi info
    .MSPI_CLK                       ( BPSr1_SCLK                     ),
    .MSPI_MOSI                      ( BPSr1_MISO                     ),
    .SSPI_CLK                       ( BPSr1_MCLK_P                   ),
    .SSPI_MISO                      ( BPSr1_MOSI_P                   )
);
`endif // QUAD_SENSOR
fbc_sensor_sim#(
    .SPI_DELAY                      ( 500                           ),
    .SPI_CLK_DIVIDER                ( 6                             ), // SPI Clock Control / Divid
    .SPI_MASTER_WIDTH               ( 48                            ), // master spi data width
    .SPI_SLAVE_WIDTH                ( 64                            )  // slave spi data width
)fbcr2_sensor_sim_inst(
    .clk_h_i                        ( clk_300m                      ),
    .rst_i                          ( rst_100m                      ),
    
    // sensor spi info
    .MSPI_CLK                       ( BPSr2_SCLK                     ),
    .MSPI_MOSI                      ( BPSr2_MISO                     ),
    .SSPI_CLK                       ( BPSr2_MCLK_P                   ),
    .SSPI_MISO                      ( BPSr2_MOSI_P                   )
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
assign   real_precise_encode_w     = fbc_out_cnt;
assign   real_precise_encode_x     = fbc_out_cnt;



always @(posedge clk_100m) begin
    if(rst)
        fbc_out_cnt <= 'd0;
    else 
        fbc_out_cnt <= fbc_out_cnt + 4;
end


// mfpga to mainPC message arbitrate 
arbitrate_bpsi #(
    .MFPGA_VERSION                  ( VERSION                       )
) arbitrate_bpsi_inst(
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),
    
    .heartbeat_data_i               ( heartbeat_data                ),
    .heartbeat_en_i                 ( heartbeat_en                  ),
    .readback_data_i                ( readback_data                 ),
    .readback_vld_i                 ( readback_vld                  ),
    .fpga_message_up_data_i         ( fpga_message_up_data          ),
    .fpga_message_up_i              ( fpga_message_up               ),
    // actual voltage
    .FBC_out_fifo_rst_i             ( FBC_out_fifo_rst              ),
    .fbc_udp_rate_switch_i          ( fbc_udp_rate_switch           ),
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
    
    .quad_sensor_data_en_i          ( quad_sensor_data_en           ),
    .quad_sensor_data_i             ( quad_sensor_data              ),
    .quad_sensor_bg_data_en_i       ( quad_sensor_bg_data_en        ),
    .quad_sensor_bg_data_i          ( quad_sensor_bg_data           ),
    
    .motor_data_in_en_i             ( motor_data_in_en              ), // Uop en
    .motor_data_out_i               ( motor_Ufeed_latch             ), // Ufeed
    .motor_data_in_i                ( motor_data_in                 ), // Uop to motor

    .laser_rx_data_i                ( laser_rx_data                 ), // laser uart
    .laser_rx_vld_i                 ( laser_rx_vld                  ), // laser uart
    .laser_rx_last_i                ( laser_rx_last                 ), // laser uart

    .spi_slave0_ack_vld_i           ( spi_slave_ack_vld[0]          ),
    .spi_slave0_ack_last_i          ( spi_slave_ack_last[0]         ),
    .spi_slave0_ack_data_i          ( spi_slave_ack_data[0]         ),
    .spi_slave1_ack_vld_i           ( spi_slave_ack_vld[1]          ),
    .spi_slave1_ack_last_i          ( spi_slave_ack_last[1]         ),
    .spi_slave1_ack_data_i          ( spi_slave_ack_data[1]         ),
    .spi_slave2_ack_vld_i           ( spi_slave_ack_vld[2]          ),
    .spi_slave2_ack_last_i          ( spi_slave_ack_last[2]         ),
    .spi_slave2_ack_data_i          ( spi_slave_ack_data[2]         ),
    .spi_slave3_ack_vld_i           ( spi_slave_ack_vld[3]          ),
    .spi_slave3_ack_last_i          ( spi_slave_ack_last[3]         ),
    .spi_slave3_ack_data_i          ( spi_slave_ack_data[3]         ),

    .rd_mfpga_version_i             ( rd_mfpga_version              ),

    .slave_tx_ack_i                 ( slave_tx_ack                  ),
    .slave_tx_byte_en_o             ( slave_tx_byte_en              ),
    .slave_tx_byte_o                ( slave_tx_byte                 ),
    .slave_tx_byte_num_en_o         ( slave_tx_byte_num_en          ),
    .slave_tx_byte_num_o            ( slave_tx_byte_num             )

);

slave_comm slave_comm_inst(
    // clk & rst
    .clk_sys_i                      ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),
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
    .SLAVE_MSG_TX0                  ( FPGA_TO_SFPGA_RESERVE4        ),
    .SLAVE_MSG_TX1                  ( FPGA_TO_SFPGA_RESERVE5        ),
    .SLAVE_MSG_TX2                  ( FPGA_TO_SFPGA_RESERVE6        ),
    .SLAVE_MSG_TX3                  ( FPGA_TO_SFPGA_RESERVE7        ),
    .SLAVE_MSG_RX_FSX               ( FPGA_TO_SFPGA_RESERVE1        ),
    .SLAVE_MSG_RX                   ( FPGA_TO_SFPGA_RESERVE2        )
);

command_map command_map_inst(
    .clk_sys_i                      ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),
    .slave_rx_data_vld_i            ( slave_rx_data_vld             ),
    .slave_rx_data_i                ( slave_rx_data                 ),
    
    .data_acq_en_o                  ( bpsi_data_acq_en              ),
    .bg_data_acq_en_o               ( bpsi_bg_data_acq_en           ),
    .position_arm_o                 ( bpsi_position_aim             ),
    .kp_o                           ( bpsi_kp                       ),
    .ki_o                           ( bpsi_ki                       ),
    .kd_o                           ( bpsi_kd                       ),
    .motor_freq_o                   ( bpsi_motor_freq               ),
    // .bpsi_position_en_o             ( bpsi_position_en              ),
    // .sensor_ds_rate_o               ( sensor_ds_rate                ),
    // .sensor_mode_sel_o              ( sensor_mode_sel               ),
    .fbc_bias_vol_en_o              ( fbc_bias_vol_en               ),
    .fbc_bias_voltage_o             ( fbc_bias_voltage              ),
    // .fbc_cali_uop_set_o             ( fbc_cali_uop_set              ),
    .ascent_gradient_o              ( ascent_gradient               ),
    .slow_ascent_period_o           ( slow_ascent_period            ),
    .quad_sensor_bg_en_o            ( quad_sensor_bg_en             ),
    .sensor_config_en_o             ( sensor_config_en              ),
    .sensor_config_cmd_o            ( sensor_config_cmd             ),
    .sensor_config_test_o           ( sensor_config_test            ),
    .motor_Ufeed_latch_i            ( motor_Ufeed_latch             ),
    .motor_data_in_i                ( motor_data_in                 ), // Uop to motor
    .delta_position_i               ( delta_position                ),
    .eds_power_en_o                 ( eds_power_en                  ),
    .eds_frame_en_o                 ( eds_frame_cmd_en              ),
    .eds_frame_sel_o                ( eds_frame_cmd_sel             ),
    .eds_frame_hold_o               ( eds_frame_cmd_hold            ),
    .eds_frame_en_back_i            ( eds_frame_en                  ),
    .eds_test_en_o                  ( eds_test_en                   ),
    .eds_texp_time_o                ( texp_time                     ),
    .eds_frame_to_frame_time_o      ( frame_to_frame_time           ),
    .laser_uart_data_o              ( laser_tx_data                 ),
    .laser_uart_vld_o               ( laser_tx_vld                  ),
    .pmt_master_spi_data_o          ( pmt_master_spi_data           ),
    .pmt_master_spi_vld_o           ( pmt_master_spi_vld            ),
    .pmt_adc_start_data_o           ( pmt_adc_start_data            ),
    .pmt_adc_start_vld_o            ( pmt_adc_start_vld             ),
    .pmt_adc_start_hold_o           ( pmt_adc_start_hold            ),
    .rd_mfpga_version_o             ( rd_mfpga_version              ),
    .FBC_fifo_rst_o                 ( FBC_out_fifo_rst              ),
    .fast_shutter_set_i             ( fast_shutter_set              ),
    .fast_shutter_en_i              ( fast_shutter_en               ),
    .readback_data_o                ( readback_data                 ),
    .readback_vld_o                 ( readback_vld                  ),

    .encode_sim_en_o                ( encode_sim_en                 ),
    .start_encode_latch_i           ( start_encode_latch            ),
    .sfrst_encode_latch_i           ( sfrst_encode_latch            ),
    .scan_finish_comm_i             ( scan_finish_comm              ),
    .scan_finish_comm_ack_o         ( scan_finish_comm_ack          ),
    .scan_error_comm_i              ( scan_error_comm               ),
    .scan_error_comm_flag_i         ( scan_error_comm_flag          ),
    .scan_soft_reset_o              ( scan_soft_reset               ),
    .real_scan_start_o              ( scan_start_cmd                ),
    .real_scan_sel_o                ( scan_start_sel                ),
    .x_start_encode_o               ( x_start_encode                ),
    .fast_shutter_encode_o          ( fast_shutter_encode           ),
    .x_end_encode_o                 ( x_end_encode                  ),
    .plc_x_encode_o                 ( plc_x_encode                  ),
    .plc_x_encode_en_o              ( plc_x_encode_en               ),
    .fbc_close_loop_i               ( fbc_close_loop                ),
    .fbc_open_loop_i                ( fbc_open_loop                 ),
    .position_pid_thr_o             ( position_pid_thr              ),
    .fbc_pose_err_thr_o             ( fbc_pose_err_thr              ),
    .fbc_ratio_max_thr_o            ( fbc_ratio_max_thr             ),
    .fbc_ratio_min_thr_o            ( fbc_ratio_min_thr             ),
    .fbc_close_state_err_i          ( fbc_close_state_err           ),
    .fbc_ratio_err_i                ( fbc_ratio_err                 ),
    .err_position_latch_i           ( err_position_latch            ),
    .err_intensity_latch_i          ( err_intensity_latch           ),
    .laser_fast_shutter_i           ( fast_shutter_state            ),
    .fast_shutter_act_time_i        ( fast_shutter_act_time         ),
    .soft_fast_shutter_set_o        ( soft_fast_shutter_set         ),
    .soft_fast_shutter_en_o         ( soft_fast_shutter_en          ),
    .scan_fbc_switch_o              ( scan_fbc_switch               ),
    // overload register
    .scan_aurora_reset_o            ( scan_aurora_reset             ),
    // .overload_motor_en_o            ( overload_motor_en             ),
    // .overload_ufeed_thre_o          ( overload_ufeed_thre           ),
    // .overload_pid_result_i          ( overload_pid_result           ),
    .x_encode_zero_calib_o          ( x_encode_zero_calib           ),
    .pmt_Wencode_align_rst_o        ( pmt_Wencode_align_rst         ),
    .pmt_Wencode_align_set_o        ( pmt_Wencode_align_set         ),
    .pmt_Xencode_align_rst_o        ( pmt_Xencode_align_rst         ),
    .pmt_Xencode_align_set_o        ( pmt_Xencode_align_set         ),
    .eds_Wencode_align_rst_o        ( eds_Wencode_align_rst         ),
    .eds_Wencode_align_set_o        ( eds_Wencode_align_set         ),
    .eds_Xencode_align_rst_o        ( eds_Xencode_align_rst         ),
    .eds_Xencode_align_set_o        ( eds_Xencode_align_set         ),
    .pmt_encode_w_i                 ( w_data_out                    ),
    .pmt_encode_x_i                 ( x_data_out                    ),
    .scan_encode_offset_o           ( scan_encode_offset            ),
    .autocal_encode_offset_o        ( autocal_encode_offset         ),
    .autocal_fbp_sel_o              ( autocal_fbp_sel               ),
    .fbp_encode_start_o             ( fbp_encode_start              ),
    .fbp_encode_end_o               ( fbp_encode_end                ),
    .autocal_pow_sel_o              ( autocal_pow_sel               ),
    .pow_encode_start_o             ( pow_encode_start              ),
    .pow_encode_end_o               ( pow_encode_end                ),
    .autocal_lpo_sel_o              ( autocal_lpo_sel               ),
    .lpo_encode_start_o             ( lpo_encode_start              ),
    .lpo_encode_end_o               ( lpo_encode_end                ),
    .scan_state_i                   ( scan_state                    ),

    .eds_pack_cnt_1_i               ( eds_pack_cnt[0]                ),
    .encode_pack_cnt_1_i            ( encode_pack_cnt[0]             ),
    .eds_pack_cnt_2_i               ( eds_pack_cnt[1]                ),
    .encode_pack_cnt_2_i            ( encode_pack_cnt[1]             ),
    .eds_pack_cnt_3_i               ( eds_pack_cnt[2]                ),
    .encode_pack_cnt_3_i            ( encode_pack_cnt[2]             ),

    .laser_control_o                ( laser_control                 ),
    .laser_out_switch_o             ( laser_out_switch              ),
    .laser_analog_max_o             ( laser_analog_max              ),
    .laser_analog_min_o             ( laser_analog_min              ),
    .laser_analog_pwm_o             ( laser_analog_pwm              ),
    .laser_analog_cycle_o           ( laser_analog_cycle            ),
    .laser_analog_uplimit_o         ( laser_analog_uplimit          ),
    .laser_analog_lowlimit_o        ( laser_analog_lowlimit         ),
    .laser_analog_mode_sel_o        ( laser_analog_mode_sel         ),
    .laser_analog_trigger_o         ( laser_analog_trigger          ),
    .acc_job_control_o              ( acc_job_control               ),
    // .acc_job_init_switch_o          ( acc_job_init_switch           ),
    .acc_job_init_vol_trig_o        ( acc_job_init_vol_trig         ),
    .acc_job_init_vol_o             ( acc_job_init_vol              ),
    
    .acc_aom_class0_o               ( acc_aom_class0                ),
    .acc_aom_class1_o               ( acc_aom_class1                ),
    .acc_aom_class2_o               ( acc_aom_class2                ),
    .acc_aom_class3_o               ( acc_aom_class3                ),
    .acc_aom_class4_o               ( acc_aom_class4                ),
    .acc_aom_class5_o               ( acc_aom_class5                ),
    .acc_aom_class6_o               ( acc_aom_class6                ),
    .acc_aom_class7_o               ( acc_aom_class7                ),
    .aom_trig_protect_o             ( aom_trig_protect              ),
    .aom_continuous_trig_thre_o     ( aom_continuous_trig_thre      ),
    .aom_integral_trig_thre_o       ( aom_integral_trig_thre        ),
    .aom_trig_vol_thre_o            ( aom_trig_vol_thre             ),
    
    .acc_demo_mode_o                ( acc_demo_mode                 ),
    .acc_demo_wren_o                ( acc_demo_wren                 ),
    .acc_demo_addr_o                ( acc_demo_addr                 ),
    .acc_demo_Wencode_o             ( acc_demo_Wencode              ),
    .acc_demo_Xencode_o             ( acc_demo_Xencode              ),
    .acc_demo_particle_cnt_o        ( acc_demo_particle_cnt         ),
    .acc_demo_trim_time_pose_o      ( acc_demo_trim_time_pose       ),
    .acc_demo_trim_time_nege_o      ( acc_demo_trim_time_nege       ),
    .acc_demo_xencode_offset_o      ( acc_demo_xencode_offset       ),
    .acc_demo_skip_cnt_i            ( acc_demo_skip_cnt             ),
    .acc_demo_addr_latch_i          ( acc_demo_addr_latch           ),
    .acc_skip_fifo_rd_o             ( acc_skip_fifo_rd              ),
    .acc_skip_fifo_ready_i          ( acc_skip_fifo_ready           ),
    .acc_skip_fifo_data_i           ( acc_skip_fifo_data            ),
    .timing_flag_supp_o             ( timing_flag_supp              ),
    // .acc_trigger_num_i              ( acc_trigger_num               ),

    .eds_sensor_training_done_i     ( eds_sensor_training_done      ),
    .eds_sensor_training_result_i   ( eds_sensor_training_result    ),
    
    .aurora_empty_1_i               ( aurora_empty[0]               ),
    .aurora_empty_2_i               ( aurora_empty[1]               ),
    .aurora_empty_3_i               ( aurora_empty[2]               ),
    .aurora_soft_rd_1_o             ( aurora_soft_rd[0]             ),
    .aurora_soft_rd_2_o             ( aurora_soft_rd[1]             ),
    .aurora_soft_rd_3_o             ( aurora_soft_rd[2]             ),

    // .cfg_acc_use_o                  ( cfg_acc_use                   ),
    // .cfg_fbc_rate_o                 ( cfg_fbc_rate                  ),
    // .cfg_spindle_width_o            ( cfg_spindle_width             ),
    // .cfg_FBC_bypass_o               ( cfg_FBC_bypass                ),
    // .cfg_QPD_enable_o               ( cfg_QPD_enable                ),
    // .dbg_qpd_mode_o                 ( dbg_qpd_mode                  ),

    .encode_check_clean_o           ( encode_check_clean            ),
    .w_encode_err_lock_i            ( w_encode_err_lock             ),
    .w_encode_warn_lock_i           ( w_encode_warn_lock            ),
    .w_encode_continuity_max_i      ( w_encode_continuity_max       ),
    .w_encode_continuity_cnt_i      ( w_encode_continuity_cnt       ),
    // .w_src_encode_continuity_max_i  ( w_src_encode_continuity_max   ),
    // .w_src_encode_continuity_cnt_i  ( w_src_encode_continuity_cnt   ),
    // .w_eds_encode_continuity_max_i  ( w_eds_encode_continuity_max   ),
    // .w_eds_encode_continuity_cnt_i  ( w_eds_encode_continuity_cnt   ),
    .ad5592_1_dac_config_en_o       ( ad5592_1_dac_config_en        ),
    .ad5592_1_dac_channel_o         ( ad5592_1_dac_channel          ),
    .ad5592_1_dac_data_o            ( ad5592_1_dac_data             ),
    .ad5592_1_adc_config_en_o       ( ad5592_1_adc_config_en        ),
    .ad5592_1_adc_channel_o         ( ad5592_1_adc_channel          ),
    .ad5592_1_spi_conf_ok_i         ( ad5592_1_spi_conf_ok          ),
    .ad5592_1_init_i                ( ad5592_1_init                 ),
    .ad5592_1_adc_data_en_i         ( ad5592_1_adc_data_en          ),
    .ad5592_1_adc_data_i            ( ad5592_1_adc_data             ),
    .fbc_udp_rate_switch_o          ( fbc_udp_rate_switch           ),
    .map_readback_cnt_o             ( map_readback_cnt              ),
    .main_scan_cnt_o                ( main_scan_cnt                 ),

    .debug_info                     (                               )
);

FBC_cache FBC_cache_inst(
    // clk & rst
    .clk_i                          ( clk_100m                              ),
    .rst_i                          ( rst_100m                              ),
    .cfg_QPD_enable_i               ( cfg_QPD_enable                        ),
    // FBC actual voltage
    .FBCi_cache_vld_i               ( FBCi_cache_vld                        ),
    .FBCi_cache_data_i              ( FBCi_cache_data                       ),
    .FBCr1_cache_vld_i              ( FBCr1_cache_vld                       ),
    .FBCr1_cache_data_i             ( FBCr1_cache_data                      ),
    .FBCr2_cache_vld_i              ( FBCr2_cache_vld                       ),
    .FBCr2_cache_data_i             ( FBCr2_cache_data                      ),
    // QPD actual voltage
    .quad_cache_vld_i               ( quad_cache_vld                        ),
    .quad_cache_data_i              ( quad_cache_data                       ),
    // Enocde
    .encode_w_i                     ( real_precise_encode_w                     ),
    .encode_x_i                     ( {4'd0,real_precise_encode_x[31:4]}        ),

    .pmt_scan_en_i                  ( |pmt_scan_en                          ),
    .real_scan_flag_i               ( main_scan_start                       ),
    .fbc_scan_en_o                  ( fbc_scan_en                           ),
    .fbc_up_en_i                    ( fbc_up_en                             ),

    // ddr write
    .fbc_cache_vld_o                ( fbc_cache_vld                         ),
    .fbc_cache_data_o               ( fbc_cache_data                        ),

    .fbc_vout_empty_i               ( fbc_vout_empty                        ),
    .fbc_vout_rd_seq_o              ( fbc_vout_rd_seq                       ),
    .fbc_vout_rd_vld_i              ( fbc_vout_rd_vld                       ),
    .fbc_vout_rd_data_i             ( fbc_vout_rd_data                      ),
    
    .aurora_fbc_vout_vld_o          ( aurora_fbc_vout_vld                   ),
    .aurora_fbc_vout_data_o         ( aurora_fbc_vout_data                  ),
    .aurora_fbc_almost_full_i       ( aurora_fbc_almost_full                )
);

initial
begin
    #10000;
    $finish;
end

endmodule