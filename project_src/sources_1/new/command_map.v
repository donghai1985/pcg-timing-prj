`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/30
// Design Name: 
// Module Name: command_map
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
// `define FBC_OFF


module command_map #(
    parameter                   TCQ           = 0.1,
    parameter                   COMMAND_WIDTH = 16,
    parameter                   COMMAND_LENG  = 16

)(
    // clk & rst
    input   wire                clk_sys_i               ,
    input   wire                rst_i                   ,
    // ethernet interface for message data
    input   wire                slave_rx_data_vld_i     ,
    input   wire    [7:0]       slave_rx_data_i         ,
    // comm info
    output  wire    [2:0]       data_acq_en_o           ,
    output  wire                bg_data_acq_en_o        ,
    output  wire    [24:0]      position_arm_o          ,
    output  wire    [26-1:0]    kp_o                    ,
    output  wire    [26-1:0]    ki_o                    ,
    output  wire    [26-1:0]    kd_o                    ,
    output  wire    [3:0]       motor_freq_o            ,
    // output  wire                bpsi_position_en_o      ,
    // output  wire    [2-1:0]     sensor_mode_sel_o       ,
    // output  wire    [11-1:0]    sensor_ds_rate_o        ,
    output  wire                fbc_bias_vol_en_o       ,
    output  wire    [15:0]      fbc_bias_voltage_o      ,
    output  wire    [15:0]      fbc_cali_uop_set_o      ,
    // output  wire    [15:0]      ascent_gradient_o       ,
    // output  wire    [15:0]      slow_ascent_period_o    ,
    output  wire                quad_sensor_bg_en_o     ,
    output  wire                sensor_config_en_o      ,
    output  wire    [16-1:0]    sensor_config_cmd_o     ,
    output  wire                sensor_config_test_o    ,

    input   wire    [15:0]      motor_Ufeed_latch_i     ,
    input   wire    [15:0]      motor_data_in_i         ,
    input   wire    [32-1:0]    delta_position_i        ,

    output  wire                eds_power_en_o          ,
    output  wire                eds_frame_en_o          ,
    output  wire    [3-1:0]     eds_frame_sel_o         ,
    output  wire                eds_test_en_o           ,
    output  wire    [32-1:0]    eds_frame_hold_o        ,
    input   wire                eds_frame_en_back_i     ,
    output  wire    [32-1:0]    eds_texp_time_o         ,
    output  wire    [32-1:0]    eds_frame_to_frame_time_o,
    output  wire    [32-1:0]    laser_uart_data_o       ,
    output  wire                laser_uart_vld_o        ,

    output  wire                encode_sim_en_o         ,
    input   wire    [32-1:0]    start_encode_latch_i    ,
    input   wire    [32-1:0]    sfrst_encode_latch_i    ,
    input   wire                scan_finish_comm_i      ,
    output  wire                scan_finish_comm_ack_o  ,
    input   wire                scan_error_comm_i       ,
    input   wire    [4-1:0]     scan_error_comm_flag_i  ,
    output  wire                scan_soft_reset_o       ,
    output  wire                real_scan_start_o       ,
    output  wire    [3-1:0]     real_scan_sel_o         ,
    output  wire    [32-1:0]    x_start_encode_o        ,
    output  wire    [32-1:0]    fast_shutter_encode_o   ,
    output  wire    [32-1:0]    x_end_encode_o          ,
    output  wire    [32-1:0]    plc_x_encode_o          ,
    output  wire                plc_x_encode_en_o       ,
    input   wire                fbc_close_loop_i        ,
    input   wire                fbc_open_loop_i         ,
    output  wire                scan_fbc_switch_o       ,

    // timing to pmt communication
    output  wire    [32-1:0]    pmt_master_spi_data_o   ,
    output  wire                pmt_master_spi_vld_o    ,
    // PMT adc start
    output  wire    [32-1:0]    pmt_adc_start_data_o    ,
    output  wire                pmt_adc_start_vld_o     ,
    output  wire    [32-1:0]    pmt_adc_start_hold_o    ,

    // mfpga version read
    output  wire                rd_mfpga_version_o      ,

    output  wire                soft_fast_shutter_set_o ,
    output  wire                soft_fast_shutter_en_o  ,
    input   wire                laser_fast_shutter_i    ,
    input   wire    [32-1:0]    fast_shutter_act_time_i ,
    output  wire                FBC_fifo_rst_o          ,

    output  wire    [64-1:0]    readback_data_o         ,
    output  wire                readback_vld_o          ,

    // overload register
    output  wire                scan_aurora_reset_o     ,
    // output  wire    [15:0]      overload_ufeed_thre_o   ,
    // input   wire    [31:0]      overload_pid_result_i   ,
    output  wire    [25-1:0]    position_pid_thr_o      ,
    output  wire    [25-1:0]    fbc_pose_err_thr_o      ,
    output  wire    [25-1:0]    fbc_ratio_max_thr_o     ,
    output  wire    [25-1:0]    fbc_ratio_min_thr_o     ,
    input   wire                fbc_ratio_err_i         ,
    input   wire                fbc_close_state_err_i   ,
    input   wire    [25-1:0]    err_position_latch_i    ,
    input   wire    [22-1:0]    err_intensity_latch_i   ,

    output  wire                pmt_Wencode_align_rst_o ,
    output  wire    [32-1:0]    pmt_Wencode_align_set_o ,
    output  wire                pmt_Xencode_align_rst_o ,
    output  wire    [32-1:0]    pmt_Xencode_align_set_o ,
    output  wire                eds_Wencode_align_rst_o ,
    output  wire    [32-1:0]    eds_Wencode_align_set_o ,
    output  wire                eds_Xencode_align_rst_o ,
    output  wire    [32-1:0]    eds_Xencode_align_set_o ,

    output  wire                x_encode_zero_calib_o   ,
    input   wire    [31:0]      pmt_encode_w_i          ,
    input   wire    [31:0]      pmt_encode_x_i          ,
    output  wire    [31:0]      scan_encode_offset_o    ,
    output  wire    [32-1:0]    autocal_encode_offset_o ,
    output  wire    [3-1:0]     autocal_fbp_sel_o       ,
    output  wire    [32-1:0]    fbp_encode_start_o      ,
    output  wire    [32-1:0]    fbp_encode_end_o        ,
    output  wire    [3-1:0]     autocal_pow_sel_o       ,
    output  wire    [32-1:0]    pow_encode_start_o      ,
    output  wire    [32-1:0]    pow_encode_end_o        ,
    output  wire    [3-1:0]     autocal_lpo_sel_o       ,
    output  wire    [32-1:0]    lpo_encode_start_o      ,
    output  wire    [32-1:0]    lpo_encode_end_o        ,
    input   wire    [4-1:0]     scan_state_i            ,

    input   wire    [32-1:0]    eds_pack_cnt_1_i        ,
    input   wire    [32-1:0]    encode_pack_cnt_1_i     ,
    input   wire    [32-1:0]    eds_pack_cnt_2_i        ,
    input   wire    [32-1:0]    encode_pack_cnt_2_i     ,
    input   wire    [32-1:0]    eds_pack_cnt_3_i        ,
    input   wire    [32-1:0]    encode_pack_cnt_3_i     ,

    output  wire                laser_control_o         ,
    output  wire                laser_out_switch_o      ,
    output  wire    [12-1:0]    laser_analog_max_o      ,
    output  wire    [12-1:0]    laser_analog_min_o      ,
    output  wire    [32-1:0]    laser_analog_pwm_o      ,
    output  wire    [32-1:0]    laser_analog_cycle_o    ,
    output  wire    [12-1:0]    laser_analog_uplimit_o  ,
    output  wire    [12-1:0]    laser_analog_lowlimit_o ,
    output  wire                laser_analog_mode_sel_o ,
    output  wire                laser_analog_trigger_o  ,

    output  wire                acc_job_control_o       ,
    // output  wire                acc_job_init_switch_o   ,
    output  wire                acc_job_init_vol_trig_o ,
    output  wire    [12-1:0]    acc_job_init_vol_o      ,
    output  wire    [12-1:0]    acc_aom_class0_o        ,
    output  wire    [12-1:0]    acc_aom_class1_o        ,
    output  wire    [12-1:0]    acc_aom_class2_o        ,
    output  wire    [12-1:0]    acc_aom_class3_o        ,
    output  wire    [12-1:0]    acc_aom_class4_o        ,
    output  wire    [12-1:0]    acc_aom_class5_o        ,
    output  wire    [12-1:0]    acc_aom_class6_o        ,
    output  wire    [12-1:0]    acc_aom_class7_o        ,

    output  wire                aom_trig_protect_o          ,
    output  wire    [32-1:0]    aom_continuous_trig_thre_o  ,
    output  wire    [32-1:0]    aom_integral_trig_thre_o    ,
    output  wire    [12-1:0]    aom_trig_vol_thre_o         ,

    output  wire                acc_demo_mode_o             ,
    output  wire                acc_demo_wren_o             ,
    output  wire    [16-1:0]    acc_demo_addr_o             ,
    output  wire    [32-1:0]    acc_demo_Wencode_o          ,
    output  wire    [32-1:0]    acc_demo_Xencode_o          ,
    output  wire    [16-1:0]    acc_demo_particle_cnt_o     ,
    output  wire    [16-1:0]    acc_demo_trim_time_pose_o   ,
    output  wire    [16-1:0]    acc_demo_trim_time_nege_o   ,
    output  wire    [32-1:0]    acc_demo_xencode_offset_o   ,
    input   wire    [32-1:0]    acc_demo_skip_cnt_i         ,
    input   wire    [32-1:0]    acc_demo_addr_latch_i       ,
    // input   wire    [32-1:0]    acc_flag_phase_cnt_i        ,
    output  wire                acc_skip_fifo_rd_o          ,
    input   wire                acc_skip_fifo_ready_i       ,
    input   wire    [64-1:0]    acc_skip_fifo_data_i        ,
    output  wire    [32-1:0]    timing_flag_supp_o          ,

    // input                       trig_fifo_ready_i           ,
    // output                      trig_fifo_rd_o              ,
    // input  [64-1:0]             trig_fifo_data_i            ,
    input  [32-1:0]             acc_trigger_num_i           ,

    input   wire                eds_sensor_training_done_i  ,
    input   wire                eds_sensor_training_result_i,
    input   wire    [3-1:0]     aurora_empty_1_i            ,
    input   wire    [3-1:0]     aurora_empty_2_i            ,
    input   wire    [3-1:0]     aurora_empty_3_i            ,
    output  wire                aurora_soft_rd_1_o          ,
    output  wire                aurora_soft_rd_2_o          ,
    output  wire                aurora_soft_rd_3_o          ,
    output  wire    [2-1:0]     cfg_acc_use_o               ,
    output  wire                cfg_fbc_rate_o              ,
    output  wire                cfg_spindle_width_o         ,
    output  wire                cfg_FBC_bypass_o            ,
    output  wire                cfg_QPD_enable_o            ,
    output  wire                dbg_qpd_mode_o              ,

    output  wire                encode_check_clean_o        ,
    input   wire                w_encode_err_lock_i         ,
    input   wire                w_encode_warn_lock_i        ,
    input   wire    [18-1:0]    w_encode_continuity_max_i   ,
    input   wire    [18-1:0]    w_encode_continuity_cnt_i   ,
    // input   wire    [18-1:0]    w_src_encode_continuity_max_i,
    // input   wire    [18-1:0]    w_src_encode_continuity_cnt_i,
    // input   wire    [18-1:0]    w_eds_encode_continuity_max_i,
    // input   wire    [18-1:0]    w_eds_encode_continuity_cnt_i,
    // output  wire                dbg_mem_rd_en_o             ,
    // output  wire                dbg_mem_start_o             ,
    // input   wire    [2-1:0]     dbg_mem_state_i             ,
    // input   wire    [32*5-1:0]  dbg_mem_rd_data_i           ,
    output  wire                fbc_udp_rate_switch_o       ,
    output  wire    [4-1:0]     map_readback_cnt_o          ,
    output  wire    [4-1:0]     main_scan_cnt_o             ,
    output  wire                heartbeat_bypass_o          ,
    
    output  wire                ad5592_1_dac_config_en_o    ,
    output  wire    [3-1:0]     ad5592_1_dac_channel_o      ,
    output  wire    [12-1:0]    ad5592_1_dac_data_o         ,
    output  wire                ad5592_1_adc_config_en_o    ,
    output  wire    [8-1:0]     ad5592_1_adc_channel_o      ,
    input   wire                ad5592_1_spi_conf_ok_i      ,
    input   wire                ad5592_1_init_i             ,
    input   wire                ad5592_1_adc_data_en_i      ,
    input   wire    [12-1:0]    ad5592_1_adc_data_i         ,

    // readback ddr
    output  wire    [32-1:0]    ddr_rd_addr_o               ,
    output  wire                ddr_rd_en_o                 ,

    input   wire    [32-1:0]    eds_error_cnt_i             ,

    output  wire                debug_info
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>






//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg     [16-1:0]                command_sel                 = 'd0;
reg                             command_state               = 'd0;
reg     [COMMAND_LENG-1:0]      command_addr                = 'd0;
reg     [32-1:0]                command_data                = 'd0;
reg                             slave_rx_data_vld_d         = 'd0;

reg     [3-1:0]                 data_acq_en                 = 'd0;
reg                             bg_data_acq_en              = 'd0;
reg     [24:0]                  position_arm                = 'd0;
reg     [26-1:0]                kp                          = 'h10_0000;
reg     [26-1:0]                ki                          = 'h0000;
reg     [26-1:0]                kd                          = 'h0000;
reg     [3:0]                   motor_freq                  = 'd0;
// reg                             bpsi_position_en            = 'd0;
// reg     [2-1:0]                 sensor_mode_sel             = 'b11;
// reg                             sensor_ds_rate_en           = 'd0;
// reg     [2-1:0]                 sensor_ds_rate              = 'd3;
reg                             fbc_bias_vol_en             = 'd0;
reg     [15:0]                  fbc_bias_voltage            = 'd13107;       // default = 13107/65535*4.096 = 0.8192V
// reg     [15:0]                  fbc_cali_uop_set            = 'd0;       // default = 13107/65535*4.096 = 0.8192V
// reg     [15:0]                  ascent_gradient             = 'd100;
// reg     [15:0]                  slow_ascent_period          = 'd3125;
reg                             quad_sensor_bg_en           = 'd0;
reg                             sensor_config_en            = 'd0;
reg     [16-1:0]                sensor_config_cmd           = 'd0;
reg                             sensor_config_test          = 'd0;

reg     [32-1:0]                laser_uart_data             = 'd0;
reg                             laser_uart_vld              = 'd0;
reg     [32-1:0]                pmt_master_spi_data         = 'd0;
reg                             pmt_master_spi_vld          = 'd0;
reg     [32-1:0]                pmt_adc_start_data          = 'd0;
reg                             pmt_adc_start_vld           = 'd0;
reg     [32-1:0]                pmt_adc_start_hold          = 'd60000;
reg                             rd_mfpga_version            = 'd0;
reg                             FBC_fifo_rst                = 'd0;
reg                             eds_power_en                = 'd0;
reg     [32-1:0]                eds_frame_cmd               = 'd0;
reg     [3-1:0]                 eds_frame_sel               = 'd0;
reg                             eds_frame_en                = 'd0;
reg     [32-1:0]                eds_frame_hold              = 'd2000;
reg                             eds_test_en                 = 'd0;
reg                             scan_soft_reset             = 'd0;
reg                             scan_soft_reset_d           = 'd0;
reg                             scan_soft_reset_pose        = 'd0;
reg     [32-1:0]                real_scan_command           = 'd0;
reg     [32-1:0]                real_scan_command_d         = 'd0;
reg     [3-1:0]                 real_scan_sel               = 'd0;
reg                             real_scan_start             = 'd0;
reg     [32-1:0]                x_start_encode              = 'd0;
reg     [32-1:0]                fast_shutter_encode         = 'd0;
reg     [32-1:0]                x_end_encode                = 'hff;
reg                             fast_shutter_set            = 'd0;
reg                             fast_shutter_en             = 'd0;
reg     [32-1:0]                eds_texp_time               = 'd0;
reg     [32-1:0]                eds_frame_to_frame_time     = 'd0;
reg                             scan_fbc_switch             = 'd0;

reg                             pmt_Wencode_align_rst       = 'd0;
reg     [32-1:0]                pmt_Wencode_align_set       = 'd0;
reg                             pmt_Xencode_align_rst       = 'd0;
reg     [32-1:0]                pmt_Xencode_align_set       = 'd0;
reg                             eds_Wencode_align_rst       = 'd0;
reg     [32-1:0]                eds_Wencode_align_set       = 'd0;
reg                             eds_Xencode_align_rst       = 'd0;
reg     [32-1:0]                eds_Xencode_align_set       = 'd0;

reg                             encode_sim_en               = 'd0;
reg                             encode_interval_rst         = 'd0;
reg                             pmt_encode_rd_en            = 'd0;
reg                             acs_encode_rd_en            = 'd0;
reg     [32-1:0]                pmt_w_encode_thr            = 'd100;
reg     [32-1:0]                acs_w_encode_thr            = 'd100;
reg                             scan_finish_comm_ack        = 'd0;
reg     [32-1:0]                plc_x_encode                = 'd0;
reg                             plc_x_encode_en             = 'd0;
reg                             x_encode_zero_calib         = 'd0;

reg     [32-1:0]                scan_encode_offset          = 'h300000;
reg     [32-1:0]                autocal_encode_offset       = 'd0;
reg     [3-1:0]                 autocal_fbp_sel             = 'd0;
reg     [32-1:0]                fbp_encode_start            = 'd0;
reg     [32-1:0]                fbp_encode_end              = 'd0;
reg     [3-1:0]                 autocal_pow_sel             = 'd0;
reg     [32-1:0]                pow_encode_start            = 'd0;
reg     [32-1:0]                pow_encode_end              = 'd0;
reg     [3-1:0]                 autocal_lpo_sel             = 'd0;
reg     [32-1:0]                lpo_encode_start            = 'd0;
reg     [32-1:0]                lpo_encode_end              = 'd0;

reg                             laser_control               = 'd0;      // 默认开光
reg                             laser_out_switch            = 'd0;      // 默认内控
reg     [12-1:0]                laser_analog_max            = 'd1638;   // 4095 = 5V
reg     [12-1:0]                laser_analog_min            = 'd0;
reg     [32-1:0]                laser_analog_pwm            = 'd100;    // 50% PWM
reg     [32-1:0]                laser_analog_cycle          = 'd200;    // 2000ns = 500kHz 
reg     [12-1:0]                laser_analog_uplimit        = 'd2866;   // 3.5V / 5 * 4095
reg     [12-1:0]                laser_analog_lowlimit       = 'd0;
reg                             laser_analog_mode_sel       = 'd0;      // 0: PWM  1: trigger
reg                             laser_analog_trigger        = 'd0;
reg                             acc_job_control             = 'd0;      // 1：屏蔽寄存器控制
reg                             acc_job_init_vol_trig       = 'd0;
reg     [12-1:0]                acc_job_init_vol            = 'd2457;   // 3V

reg     [12-1:0]                acc_aom_class0              = 'd0    ;  // 0    / 5 * 2**12 = 0
reg     [12-1:0]                acc_aom_class1              = 'd819  ;  // 1    / 5 * 2**12 = 819
reg     [12-1:0]                acc_aom_class2              = 'd1228 ;  // 1.5  / 5 * 2**12 = 1228
reg     [12-1:0]                acc_aom_class3              = 'd1638 ;  // 2    / 5 * 2**12 = 1638
reg     [12-1:0]                acc_aom_class4              = 'd2457 ;  // 3    / 5 * 2**12 = 2457
reg     [12-1:0]                acc_aom_class5              = 'd2866 ;  // 3.5  / 5 * 2**12 = 2866
reg     [12-1:0]                acc_aom_class6              = 'd3276 ;  // 4    / 5 * 2**12 = 3276
reg     [12-1:0]                acc_aom_class7              = 'd4095 ;  // 5    / 5 * 2**12 = 4095
// overload register
reg                             scan_aurora_reset           = 'd0;
// reg     [16-1:0]                overload_motor_set          = 'd13107;      // default = 13107/65535*4.096 = 0.8192V
reg     [25-1:0]                position_pid_thr            = 'd157286;     // ±150um = 157286/2**20
reg     [25-1:0]                fbc_pose_err_thr            = 'd314572;     // ±300um = 314572/2**20
reg     [25-1:0]                fbc_ratio_max_thr           = 'd1048576;    // 1048576/2**20 = 1
reg     [25-1:0]                fbc_ratio_min_thr           = 'd104857;     // 104857/2**20 = 0.1

reg                             aom_trig_protect            = 'd1       ;
reg     [32-1:0]                aom_continuous_trig_thre    = 'd100000  ;
reg     [32-1:0]                aom_integral_trig_thre      = 'd3300000 ;
reg     [12-1:0]                aom_trig_vol_thre           = 'd1228    ;   // 1.5  / 5 * 2**12 = 1228

reg                             acc_demo_mode               = 'd0;
reg                             acc_demo_wren               = 'd0;
reg     [16-1:0]                acc_demo_addr               = 'd0;
reg     [32-1:0]                acc_demo_Wencode            = 'd0;
reg     [32-1:0]                acc_demo_Xencode            = 'd0;
reg     [16-1:0]                acc_demo_particle_cnt       = 'd0;
reg     [16-1:0]                acc_demo_trim_time_pose     = 'd1; // 1320-330*2
reg     [16-1:0]                acc_demo_trim_time_nege     = 'd1; // 1440-330*2
reg     [32-1:0]                acc_demo_xencode_offset     = 'h443d32;
reg                             acc_skip_fifo_rd            = 'd0;
reg     [32-1:0]                timing_flag_supp            = 'd0;
// reg                             trig_fifo_rd                = 'd0;
// reg                             dbg_mem_rd_en               = 'd0;
// reg                             dbg_mem_start               = 'd0;
reg                             fbc_udp_rate_switch         = 'd0;
reg                             aurora_soft_rd_1            = 'd0;
reg                             aurora_soft_rd_2            = 'd0;
reg                             aurora_soft_rd_3            = 'd0;
reg                             encode_check_clean          = 'd0;
reg                             ad5592_1_dac_config_en      = 'd0;
reg     [3-1:0]                 ad5592_1_dac_channel        = 'd0;
reg     [12-1:0]                ad5592_1_dac_data           = 'd0;
reg                             ad5592_1_adc_config_en      = 'd0;
reg     [8-1:0]                 ad5592_1_adc_channel        = 'd0;
reg     [12-1:0]                ad5592_1_adc_data           = 'd0;
reg     [32-1:0]                ddr_rd_addr                 = 'd0;
reg                             ddr_rd_en                   = 'd0;
reg     [2-1:0]                 cfg_acc_use                 = 'd0;
reg                             cfg_fbc_rate                = 'd0;
reg                             cfg_spindle_width           = 'd0;
reg                             heartbeat_bypass            = 'd0;
reg                             cali_register_clear         = 'd0;

reg     [2-1:0]                 cfg_FBC_bypass              = 'd0;
reg                             cfg_QPD_enable              = 'd0;
reg                             dbg_qpd_mode                = 'd0;
reg     [32-1:0]                readback_reg                = 'd0;
reg                             readback_en                 = 'd0;
reg     [2-1:0]                 readback_cnt                = 'd2;
reg     [32-1:0]                register_data               = 'd0;
reg     [64-1:0]                readback_data               = 'd0;
reg                             readback_vld                = 'd0;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                            slave_rx_start  ;
wire                            command_en      ;
wire    [COMMAND_WIDTH-1:0]     command         ;
wire                            command_data_vld;


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// check command and command data 
always @(posedge clk_sys_i) command_data        <= #TCQ {command_data[23:0],slave_rx_data_i[7:0]};
always @(posedge clk_sys_i) slave_rx_data_vld_d <= #TCQ slave_rx_data_vld_i;

assign slave_rx_start = ~slave_rx_data_vld_d && slave_rx_data_vld_i;

always @(posedge clk_sys_i) begin
    if(slave_rx_start || command_en)begin
        command_addr <= #TCQ 'd0;
    end
    else if(slave_rx_data_vld_d)begin
        command_addr <= #TCQ command_addr + 1;
    end
end

assign command_en   = (command_addr=='d1) && slave_rx_data_vld_d && (~command_state);
assign command      = command_data[15:0];

always @(posedge clk_sys_i) begin
    if(slave_rx_data_vld_i)begin
        if(command_en) 
            command_state <= #TCQ 'd1;
    end
    else begin
        command_state <= #TCQ 'd0;
    end
end

assign command_data_vld = (command_addr[1:0]=='b11) && command_state;

always @(posedge clk_sys_i) begin
    if(command_en)begin
        command_sel <= #TCQ command[15:0];
    end
end

// write register
always @(posedge clk_sys_i) begin
    if(command_data_vld)begin
        case (command_sel)
            'h0100: rd_mfpga_version        <= #TCQ 'd1                 ;

            // FBC register
            // 'h010E: FBC_fifo_rst            <= #TCQ command_data[0]     ;
            // 'h0110: sensor_ds_rate          <= #TCQ command_data[9:0]   ;

            'h0116: bg_data_acq_en          <= #TCQ command_data[0]     ;
            'h0117: position_arm            <= #TCQ command_data[24:0]  ;
            'h0118: kp                      <= #TCQ command_data        ;
            'h0119: motor_freq              <= #TCQ command_data[3:0]   ;
            // 'h011a: bpsi_position_en        <= #TCQ command_data[0]     ;
            'h011b: fbc_bias_voltage        <= #TCQ command_data[15:0]  ;
            // 'h011c: fbc_cali_uop_set        <= #TCQ command_data[15:0]  ;
            'h011d: ki                      <= #TCQ command_data        ;
            'h011e: kd                      <= #TCQ command_data        ;
            // 'h011F: sensor_mode_sel         <= #TCQ command_data[1:0]   ;

            // scan register
            'h0120: eds_power_en            <= #TCQ command_data[0]     ;
            'h0121: eds_frame_cmd           <= #TCQ command_data        ;
            'h0125: pmt_adc_start_hold      <= #TCQ command_data        ;
            'h0126: eds_test_en             <= #TCQ command_data[0]     ;
            'h0127: scan_soft_reset         <= #TCQ command_data[0]     ;
            'h0128: real_scan_command       <= #TCQ command_data        ;
            'h0129: x_start_encode          <= #TCQ command_data        ;
            'h012a: x_end_encode            <= #TCQ command_data        ;
            'h012c: fast_shutter_set        <= #TCQ command_data[0]     ;

            // encode
            'h0130: x_encode_zero_calib     <= #TCQ command_data[0]     ;
            'h0131: scan_encode_offset      <= #TCQ command_data        ;
            'h0133: pmt_Wencode_align_set   <= #TCQ command_data        ;
            'h0134: pmt_Xencode_align_set   <= #TCQ command_data        ;
            'h0135: encode_sim_en           <= #TCQ command_data[0]     ;
            
            'h0137: scan_finish_comm_ack    <= #TCQ command_data[0]     ;
            'h0138: plc_x_encode            <= #TCQ command_data        ;
            'h0139: plc_x_encode_en         <= #TCQ command_data        ;

            'h013a: eds_Wencode_align_set   <= #TCQ command_data        ;
            'h013b: eds_Xencode_align_set   <= #TCQ command_data        ;
            'h013c: scan_fbc_switch         <= #TCQ command_data[0]     ;
            'h013d: eds_frame_hold          <= #TCQ command_data        ;
            'h013e: fast_shutter_encode     <= #TCQ command_data        ;

            'h0140: autocal_encode_offset   <= #TCQ command_data        ;
            'h0141: autocal_fbp_sel         <= #TCQ command_data[2:0]   ;
            'h0142: fbp_encode_start        <= #TCQ command_data        ;
            'h0143: fbp_encode_end          <= #TCQ command_data        ;
            'h0144: autocal_pow_sel         <= #TCQ command_data[2:0]   ;
            'h0145: pow_encode_start        <= #TCQ command_data        ;
            'h0146: pow_encode_end          <= #TCQ command_data        ;
            'h0147: autocal_lpo_sel         <= #TCQ command_data[2:0]   ;
            'h0148: lpo_encode_start        <= #TCQ command_data        ;
            'h0149: lpo_encode_end          <= #TCQ command_data        ;

            // overload register
            'h0201: scan_aurora_reset       <= #TCQ command_data[15:0]  ;
            // 'h0202: overload_motor_en       <= #TCQ command_data[0]     ;

            'h0204: position_pid_thr        <= #TCQ command_data[24:0]  ;
            'h0205: fbc_ratio_max_thr       <= #TCQ command_data[24:0]  ;
            'h0206: fbc_ratio_min_thr       <= #TCQ command_data[24:0]  ;
            'h0207: fbc_pose_err_thr        <= #TCQ command_data[24:0]  ;

            'h0301: laser_out_switch        <= #TCQ command_data        ;
            'h0302: laser_analog_max        <= #TCQ command_data        ;
            'h0303: laser_analog_min        <= #TCQ command_data        ;
            'h0304: laser_analog_pwm        <= #TCQ command_data        ;
            'h0305: laser_analog_cycle      <= #TCQ command_data        ;
            'h0306: laser_analog_uplimit    <= #TCQ command_data        ;
            'h0307: laser_analog_lowlimit   <= #TCQ command_data        ;
            'h0308: laser_analog_mode_sel   <= #TCQ command_data        ;
            'h0309: laser_analog_trigger    <= #TCQ command_data        ;
            'h030a: laser_control           <= #TCQ command_data        ;

            'h030b: acc_job_control         <= #TCQ command_data        ;
            // 'h030c: acc_job_init_vol_trig   <= #TCQ command_data        ;
            'h030d: acc_job_init_vol        <= #TCQ command_data        ;
            
            'h0310: acc_aom_class0          <= #TCQ command_data        ;
            'h0311: acc_aom_class1          <= #TCQ command_data        ;
            'h0312: acc_aom_class2          <= #TCQ command_data        ;
            'h0313: acc_aom_class3          <= #TCQ command_data        ;
            'h0314: acc_aom_class4          <= #TCQ command_data        ;
            'h0315: acc_aom_class5          <= #TCQ command_data        ;
            'h0316: acc_aom_class6          <= #TCQ command_data        ;
            'h0317: acc_aom_class7          <= #TCQ command_data        ;
            
            'h0320: aom_trig_protect        <= #TCQ command_data        ;
            'h0321: aom_continuous_trig_thre<= #TCQ command_data        ;
            'h0322: aom_integral_trig_thre  <= #TCQ command_data        ;
            'h0323: aom_trig_vol_thre       <= #TCQ command_data        ;

            'h0324: acc_demo_mode           <= #TCQ command_data        ;
            'h0326: acc_demo_trim_time_pose <= #TCQ command_data        ;
            // 'h0327: acc_demo_Xencode_extend <= #TCQ command_data        ;
            'h0328: acc_demo_trim_time_nege <= #TCQ command_data        ;
            // 'h032a: acc_demo_xencode_offset <= #TCQ command_data        ;

            'h032d: acc_skip_fifo_rd        <= #TCQ command_data        ;
            'h0330: timing_flag_supp        <= #TCQ command_data        ;
            'h0331: sensor_config_cmd       <= #TCQ command_data        ;
            'h0333: quad_sensor_bg_en       <= #TCQ command_data        ;
            'h0334: dbg_qpd_mode            <= #TCQ command_data        ;
            'h0335: sensor_config_test      <= #TCQ command_data        ;
            'h0336: fbc_udp_rate_switch     <= #TCQ command_data        ;
            // 'h0338: arbitrate use
            'h0339: cali_register_clear     <= #TCQ command_data        ;
            'h033a: heartbeat_bypass        <= #TCQ command_data        ;

            'h0351: cfg_acc_use             <= #TCQ command_data[1:0]   ;
            'h0352: cfg_fbc_rate            <= #TCQ command_data[0]     ;
            'h0353: cfg_spindle_width       <= #TCQ command_data[0]     ;
            'h0354: ad5592_1_dac_config_en  <= #TCQ command_data        ;
            'h0355: ad5592_1_dac_channel    <= #TCQ command_data        ;
            'h0356: ad5592_1_dac_data       <= #TCQ command_data        ;
            'h0357: ad5592_1_adc_config_en  <= #TCQ command_data        ;
            'h0358: ad5592_1_adc_channel    <= #TCQ command_data        ;

            'h035b: cfg_FBC_bypass          <= #TCQ command_data[1:0]   ;
            'h035c: cfg_QPD_enable          <= #TCQ command_data[0]     ;
            'h035d: ddr_rd_addr             <= #TCQ command_data        ;

            'h0409: aurora_soft_rd_1        <= #TCQ command_data[0]     ;
            'h040a: aurora_soft_rd_2        <= #TCQ command_data[0]     ;
            'h040b: aurora_soft_rd_3        <= #TCQ command_data[0]     ;
            'h040c: encode_check_clean      <= #TCQ command_data[0]     ;
            // 'h0337: trig_fifo_rd            <= #TCQ command_data        ;


            default: /*default*/;
        endcase
    end
    else if(cali_register_clear)begin
        cali_register_clear     <= #TCQ 'd0;
    end
    else begin
        rd_mfpga_version        <= #TCQ 'd0;
        bg_data_acq_en          <= #TCQ 'd0;
        quad_sensor_bg_en       <= #TCQ 'd0;
        // bpsi_position_en        <= #TCQ 'd0;
        // real_scan_start         <= #TCQ 'd0;
        scan_finish_comm_ack    <= #TCQ 'd0;
        // scan_soft_reset         <= #TCQ 'd0;
        // x_encode_zero_calib     <= #TCQ 'd0;
        // pmt_encode_rd_en        <= #TCQ 'd0;
        // acs_encode_rd_en        <= #TCQ 'd0;
        laser_analog_trigger    <= #TCQ 'd0;
        acc_skip_fifo_rd        <= #TCQ 'd0;
        eds_frame_cmd           <= #TCQ 'd0;
        encode_check_clean      <= #TCQ 'd0;
        cali_register_clear     <= #TCQ 'd0;
        ad5592_1_dac_config_en  <= #TCQ 'd0;
        ad5592_1_adc_config_en  <= #TCQ 'd0;
    end
end

// readback DDR cmmand
always @(posedge clk_sys_i) begin
    if(command_sel=='h035d && command_data_vld)
        ddr_rd_en   <= #TCQ 'd1;
    else
        ddr_rd_en   <= #TCQ 'd0;
end

always @(posedge clk_sys_i) begin
    if(command_sel=='h011b && command_data_vld)
        fbc_bias_vol_en <= #TCQ 'd1;
    else 
        fbc_bias_vol_en <= #TCQ 'd0;
end

always @(posedge clk_sys_i) begin
    if(command_sel=='h012c && command_data_vld)
        fast_shutter_en <= #TCQ 'd1;
    else 
        fast_shutter_en <= #TCQ 'd0;
end

always @(posedge clk_sys_i) begin
    real_scan_command_d <= #TCQ real_scan_command;
    real_scan_start     <= #TCQ (~real_scan_command_d[0]) && real_scan_command[0];
end

always @(posedge clk_sys_i) begin
    if((~real_scan_command_d[0]) && real_scan_command[0])begin
        if(real_scan_command[15:8]=='d0)
            real_scan_sel <= #TCQ 'd7;
        else 
            real_scan_sel <= #TCQ real_scan_command[10:8];
    end
end

always @(posedge clk_sys_i) begin
    eds_frame_en <= #TCQ eds_frame_cmd[0];
end

always @(posedge clk_sys_i) begin
    if(eds_frame_cmd[0])begin
        if(eds_frame_cmd[15:8]=='d0)
            eds_frame_sel <= #TCQ 'd7;
        else 
            eds_frame_sel <= #TCQ eds_frame_cmd[10:8];
    end
end

// motor parameter settings
always @(posedge clk_sys_i) begin
    if(command_sel=='h0115 && command_data_vld)begin
        data_acq_en       <= #TCQ command_data[2:0];
    end
    `ifdef FBC_OFF
    else if(fbc_ratio_err_i || fbc_close_state_err_i || scan_soft_reset_pose)begin 
        data_acq_en       <= #TCQ 'd1;
    end
    `else
    else if(real_scan_start || fbc_open_loop_i || fbc_ratio_err_i || fbc_close_state_err_i || scan_soft_reset_pose)begin 
        data_acq_en       <= #TCQ 'd1;
    end
    else if(fbc_close_loop_i)begin
        data_acq_en       <= #TCQ 'd2;
    end
    `endif // FBC_OFF
end

// timing card to laser uart
always @(posedge clk_sys_i) begin
    if(command_sel=='h0122 && command_data_vld)begin
        laser_uart_data <= #TCQ command_data;
        laser_uart_vld  <= #TCQ 'd1;
    end
    else begin
        laser_uart_vld  <= #TCQ 'd0;
    end
end

always @(posedge clk_sys_i) begin
    if(command_sel=='h0123 && command_data_vld)begin
        pmt_master_spi_data <= #TCQ command_data;
        pmt_master_spi_vld  <= #TCQ 'd1;
    end
    else begin
        pmt_master_spi_vld  <= #TCQ 'd0;
    end
end

// PMT adc start sel
always @(posedge clk_sys_i) begin
    if(command_sel=='h0124 && command_data_vld)begin
        pmt_adc_start_data <= #TCQ command_data;
        pmt_adc_start_vld  <= #TCQ |command_data[10:8];
    end
    else begin
        pmt_adc_start_vld  <= #TCQ 'd0;
    end
end

// readback register
always @(posedge clk_sys_i) begin
    if(command_sel=='h0200 && command_data_vld)begin
        readback_reg    <= #TCQ command_data;
        readback_en     <= #TCQ 'd1;
    end
    else begin
        readback_en  <= #TCQ 'd0;
    end
end

always @(posedge clk_sys_i) begin
    if(command_sel=='h0133 && command_data_vld)begin
        pmt_Wencode_align_rst <= #TCQ 'd1;
    end
    else begin
        pmt_Wencode_align_rst <= #TCQ 'd0;
    end
end

always @(posedge clk_sys_i) begin
    if(command_sel=='h0134 && command_data_vld)begin
        pmt_Xencode_align_rst <= #TCQ 'd1;
    end
    else begin
        pmt_Xencode_align_rst <= #TCQ 'd0;
    end
end

always @(posedge clk_sys_i) begin
    if(command_sel=='h013a && command_data_vld)begin
        eds_Wencode_align_rst <= #TCQ 'd1;
    end
    else begin
        eds_Wencode_align_rst <= #TCQ 'd0;
    end
end

always @(posedge clk_sys_i) begin
    if(command_sel=='h013b && command_data_vld)begin
        eds_Xencode_align_rst <= #TCQ 'd1;
    end
    else begin
        eds_Xencode_align_rst <= #TCQ 'd0;
    end
end

always @(posedge clk_sys_i) begin
    if(command_sel=='h030d && command_data_vld)begin
        acc_job_init_vol_trig <= #TCQ 'd1;
    end
    else begin
        acc_job_init_vol_trig <= #TCQ 'd0;
    end
end

always @(posedge clk_sys_i) begin
    if(command_sel=='h0325 && command_data_vld)begin
        case (command_data[31:30])
            2'b00: acc_demo_addr    <= #TCQ command_data[15:0];
            2'b01: acc_demo_Wencode <= #TCQ {2'd0,command_data[29:0]};
            2'b10: acc_demo_Xencode <= #TCQ {2'd0,command_data[29:0]};
            default: ;
        endcase
    end
end

always @(posedge clk_sys_i) begin
    if(command_sel=='h0325)
        acc_demo_particle_cnt <= #TCQ acc_demo_addr;
end

always @(posedge clk_sys_i) begin
    acc_demo_wren <= #TCQ (command_sel=='h0325) && command_data_vld && (command_data[31:30]=='b10);
end


// QSD sensor config enable
always @(posedge clk_sys_i) begin
    if(command_sel=='h0331 && command_data_vld)
        sensor_config_en <= #TCQ 'd1;
    else 
        sensor_config_en <= #TCQ 'd0;
end


always @(posedge clk_sys_i) begin
    if(readback_en)begin
        case (readback_reg)
            // 'h010E:  register_data <= #TCQ FBC_fifo_rst         ;
            // 'h0110:  register_data <= #TCQ sensor_ds_rate       ;
            'h0115:  register_data <= #TCQ data_acq_en          ;
            'h0117:  register_data <= #TCQ position_arm         ;
            'h0118:  register_data <= #TCQ kp                   ;
            'h0119:  register_data <= #TCQ motor_freq           ;
            'h011B:  register_data <= #TCQ fbc_bias_voltage     ;
            // 'h011C:  register_data <= #TCQ fbc_cali_uop_set     ;
            'h011D:  register_data <= #TCQ ki                   ;
            'h011E:  register_data <= #TCQ kd                   ;
            // 'h011F:  register_data <= #TCQ sensor_mode_sel      ;
            
            'h0120:  register_data <= #TCQ eds_power_en         ;
            'h0121:  register_data <= #TCQ eds_frame_en_back_i  ;
            'h0125:  register_data <= #TCQ pmt_adc_start_hold   ;
            'h0126:  register_data <= #TCQ eds_test_en          ;
            'h0127:  register_data <= #TCQ scan_soft_reset      ;
            'h0128:  register_data <= #TCQ real_scan_command    ;
            'h0129:  register_data <= #TCQ x_start_encode       ;
            'h012a:  register_data <= #TCQ x_end_encode         ;
            'h012c:  register_data <= #TCQ fast_shutter_set     ;
            'h012d:  register_data <= #TCQ laser_fast_shutter_i ;
            'h012e:  register_data <= #TCQ fast_shutter_act_time_i ;
            'h012f:  register_data <= #TCQ scan_state_i         ;

            'h0130:  register_data <= #TCQ x_encode_zero_calib  ;
            'h0131:  register_data <= #TCQ scan_encode_offset   ;
            'h0132:  register_data <= #TCQ pmt_encode_x_i       ;
            'h0133:  register_data <= #TCQ pmt_Wencode_align_set;
            'h0134:  register_data <= #TCQ pmt_Xencode_align_set;
            'h0135:  register_data <= #TCQ encode_sim_en        ;
            'h0136:  register_data <= #TCQ pmt_encode_w_i       ;
            'h0138:  register_data <= #TCQ plc_x_encode         ;
            'h0139:  register_data <= #TCQ plc_x_encode_en      ;
            'h013a:  register_data <= #TCQ eds_Wencode_align_set;
            'h013b:  register_data <= #TCQ eds_Xencode_align_set;
            'h013c:  register_data <= #TCQ {31'd0,scan_fbc_switch}      ;
            'h013d:  register_data <= #TCQ eds_frame_hold       ;
            'h013e:  register_data <= #TCQ fast_shutter_encode  ;
            'h013f:  register_data <= #TCQ start_encode_latch_i ;

            'h0140:  register_data <= #TCQ autocal_encode_offset        ;
            'h0141:  register_data <= #TCQ {29'd0,autocal_fbp_sel[2:0]} ;
            'h0142:  register_data <= #TCQ fbp_encode_start             ;
            'h0143:  register_data <= #TCQ fbp_encode_end               ;
            'h0144:  register_data <= #TCQ {29'd0,autocal_pow_sel[2:0]} ;
            'h0145:  register_data <= #TCQ pow_encode_start             ;
            'h0146:  register_data <= #TCQ pow_encode_end               ;
            'h0147:  register_data <= #TCQ {29'd0,autocal_lpo_sel[2:0]} ;
            'h0148:  register_data <= #TCQ lpo_encode_start             ;
            'h0149:  register_data <= #TCQ lpo_encode_end               ;
            'h014a:  register_data <= #TCQ sfrst_encode_latch_i         ;
            
            'h0201:  register_data <= #TCQ scan_aurora_reset    ;
            'h0202:  register_data <= #TCQ err_position_latch_i ;
            'h0203:  register_data <= #TCQ err_intensity_latch_i;
            'h0204:  register_data <= #TCQ position_pid_thr     ;
            'h0205:  register_data <= #TCQ fbc_ratio_max_thr    ;
            'h0206:  register_data <= #TCQ fbc_ratio_min_thr    ;
            'h0207:  register_data <= #TCQ fbc_pose_err_thr     ;

            'h0208:  register_data <= #TCQ motor_Ufeed_latch_i  ;
            'h0209:  register_data <= #TCQ motor_data_in_i      ;
            'h020a:  register_data <= #TCQ delta_position_i     ;

            'h0301:  register_data <= #TCQ laser_out_switch         ;
            'h0302:  register_data <= #TCQ laser_analog_max         ;
            'h0303:  register_data <= #TCQ laser_analog_min         ;
            'h0304:  register_data <= #TCQ laser_analog_pwm         ;
            'h0305:  register_data <= #TCQ laser_analog_cycle       ;
            'h0306:  register_data <= #TCQ laser_analog_uplimit     ;
            'h0307:  register_data <= #TCQ laser_analog_lowlimit    ;
            'h0308:  register_data <= #TCQ laser_analog_mode_sel    ;
            // 'h0309:  register_data <= #TCQ laser_analog_trigger     ;
            'h030a:  register_data <= #TCQ laser_control            ;

            'h030b:  register_data <= #TCQ acc_job_control          ;
            // 'h030c:  register_data <= #TCQ acc_job_init_vol_trig      ;
            'h030d:  register_data <= #TCQ acc_job_init_vol         ;

            'h0310:  register_data <= #TCQ acc_aom_class0           ;
            'h0311:  register_data <= #TCQ acc_aom_class1           ;
            'h0312:  register_data <= #TCQ acc_aom_class2           ;
            'h0313:  register_data <= #TCQ acc_aom_class3           ;
            'h0314:  register_data <= #TCQ acc_aom_class4           ;
            'h0315:  register_data <= #TCQ acc_aom_class5           ;
            'h0316:  register_data <= #TCQ acc_aom_class6           ;
            'h0317:  register_data <= #TCQ acc_aom_class7           ;

            'h0320:  register_data <= #TCQ aom_trig_protect         ;
            'h0321:  register_data <= #TCQ aom_continuous_trig_thre ;
            'h0322:  register_data <= #TCQ aom_integral_trig_thre   ;
            'h0323:  register_data <= #TCQ aom_trig_vol_thre        ;
            
            'h0324:  register_data <= #TCQ acc_demo_mode            ;
            'h0326:  register_data <= #TCQ acc_demo_trim_time_pose  ;
            'h0327:  register_data <= #TCQ acc_demo_addr_latch_i    ;
            'h0328:  register_data <= #TCQ acc_demo_trim_time_nege  ;
            'h0329:  register_data <= #TCQ acc_demo_skip_cnt_i      ;
            // 'h032a:  register_data <= #TCQ acc_demo_xencode_offset  ;
            // 'h032b:  register_data <= #TCQ acc_flag_phase_cnt_i     ;
            'h032c:  register_data <= #TCQ {eds_sensor_training_done_i,eds_sensor_training_result_i};
            'h032d:  register_data <= #TCQ acc_skip_fifo_ready_i;
            'h032e:  register_data <= #TCQ acc_skip_fifo_data_i[64-1:32];
            'h032f:  register_data <= #TCQ acc_skip_fifo_data_i[32-1:0];

            'h0330:  register_data <= #TCQ timing_flag_supp         ;
            'h0331:  register_data <= #TCQ sensor_config_cmd        ;
            'h0334:  register_data <= #TCQ dbg_qpd_mode             ;
            'h0335:  register_data <= #TCQ sensor_config_test       ;
            'h0336:  register_data <= #TCQ fbc_udp_rate_switch      ;
            // 'h0338: arbitrate use
            // 'h0339: register_data <= #TCQ cali_register_clear    ;
            'h033a:  register_data <= #TCQ {31'd0,heartbeat_bypass} ;

            'h0351:  register_data <= #TCQ {30'd0,cfg_acc_use}      ;
            'h0352:  register_data <= #TCQ {31'd0,cfg_fbc_rate}     ;
            'h0353:  register_data <= #TCQ {31'd0,cfg_spindle_width};
            // 'h0354:  register_data <= #TCQ ad5592_1_dac_config_en   ;
            'h0355:  register_data <= #TCQ ad5592_1_dac_channel     ;
            'h0356:  register_data <= #TCQ ad5592_1_dac_data        ;
            // 'h0357:  register_data <= #TCQ ad5592_1_adc_config_en   ;
            'h0358:  register_data <= #TCQ ad5592_1_adc_channel     ;
            'h0359:  register_data <= #TCQ {30'd0,ad5592_1_spi_conf_ok_i,ad5592_1_init_i};
            'h035a:  register_data <= #TCQ {24'd0,ad5592_1_adc_data};
            'h035b:  register_data <= #TCQ {30'd0,cfg_FBC_bypass}   ;
            'h035c:  register_data <= #TCQ {31'd0,cfg_QPD_enable}   ;
            'h035d:  register_data <= #TCQ ddr_rd_addr              ;
            'h035f:  register_data <= #TCQ acc_trigger_num_i        ;

            'h0361:  register_data <= #TCQ eds_error_cnt_i          ;

            'h0400:  register_data <= #TCQ eds_pack_cnt_2_i     ;
            'h0401:  register_data <= #TCQ encode_pack_cnt_2_i  ;
            'h0402:  register_data <= #TCQ eds_pack_cnt_1_i     ;
            'h0403:  register_data <= #TCQ encode_pack_cnt_1_i  ;
            'h0404:  register_data <= #TCQ eds_pack_cnt_3_i     ;
            'h0405:  register_data <= #TCQ encode_pack_cnt_3_i  ;
            'h0406:  register_data <= #TCQ aurora_empty_1_i     ;
            'h0407:  register_data <= #TCQ aurora_empty_2_i     ;
            'h0408:  register_data <= #TCQ aurora_empty_3_i     ;
            'h0409:  register_data <= #TCQ aurora_soft_rd_1     ;
            'h040a:  register_data <= #TCQ aurora_soft_rd_2     ;
            'h040b:  register_data <= #TCQ aurora_soft_rd_3     ;

            'h040d:  register_data <= #TCQ {30'd0,w_encode_err_lock_i,w_encode_warn_lock_i} ;
            'h040e:  register_data <= #TCQ {14'd0,w_encode_continuity_max_i}                ;
            'h040f:  register_data <= #TCQ {14'd0,w_encode_continuity_cnt_i}                ;
            // 'h0410:  register_data <= #TCQ {14'd0,w_src_encode_continuity_max_i}            ;
            // 'h0411:  register_data <= #TCQ {14'd0,w_src_encode_continuity_cnt_i}            ;
            // 'h0412:  register_data <= #TCQ {14'd0,w_eds_encode_continuity_max_i}            ;
            // 'h0413:  register_data <= #TCQ {14'd0,w_eds_encode_continuity_cnt_i}            ;

            // 'h0420:  register_data <= #TCQ dbg_mem_state_i;
            // 'h0421:  register_data <= #TCQ dbg_mem_rd_data_i[32*0 +: 32];
            // 'h0422:  register_data <= #TCQ dbg_mem_rd_data_i[32*1 +: 32];
            // 'h0423:  register_data <= #TCQ dbg_mem_rd_data_i[32*2 +: 32];
            // 'h0424:  register_data <= #TCQ dbg_mem_rd_data_i[32*3 +: 32];
            // 'h0425:  register_data <= #TCQ dbg_mem_rd_data_i[32*4 +: 32];
            default: register_data <= #TCQ 'h00_DEAD_00         ;
        endcase
    end
end


reg readback_en_d = 'd0;
always @(posedge clk_sys_i) readback_en_d <= #TCQ readback_en;
always @(posedge clk_sys_i) readback_vld  <= #TCQ readback_en_d || scan_finish_comm_i || scan_error_comm_i;
always @(posedge clk_sys_i) begin
    if(readback_en_d)
        readback_data <= #TCQ {readback_reg[31:0],register_data[31:0]};
    else if(scan_finish_comm_i)
        readback_data <= #TCQ {32'h0000_0300,32'h0};
    else if(scan_error_comm_i)
        readback_data <= #TCQ {32'h0000_0300,28'd0,scan_error_comm_flag_i[3:0]};
end

reg [4-1:0] map_readback_cnt = 'd0;
reg [4-1:0] main_scan_cnt = 'd0;
always @(posedge clk_sys_i) begin
    if(readback_en_d)
        map_readback_cnt <= #TCQ map_readback_cnt + 1;
end

always @(posedge clk_sys_i) begin
    if(real_scan_start)
        main_scan_cnt <= #TCQ main_scan_cnt + 1;
end

always @(posedge clk_sys_i) scan_soft_reset_d    <= #TCQ scan_soft_reset;
always @(posedge clk_sys_i) scan_soft_reset_pose <= #TCQ ~scan_soft_reset_d && scan_soft_reset;

assign readback_data_o          = readback_data                 ;
assign readback_vld_o           = readback_vld                  ;

assign data_acq_en_o            = data_acq_en                   ;
assign bg_data_acq_en_o         = bg_data_acq_en                ;
assign position_arm_o           = position_arm                  ;
assign kp_o                     = kp                            ;
assign ki_o                     = ki                            ;
assign kd_o                     = kd                            ;
assign motor_freq_o             = motor_freq                    ;
// assign bpsi_position_en_o       = bpsi_position_en              ;
// assign sensor_mode_sel_o        = sensor_mode_sel               ;
// assign sensor_ds_rate_o         = {sensor_ds_rate_en,sensor_ds_rate};
assign fbc_bias_vol_en_o        = fbc_bias_vol_en               ;
assign fbc_bias_voltage_o       = fbc_bias_voltage              ;
// assign fbc_cali_uop_set_o       = fbc_cali_uop_set              ;
// assign ascent_gradient_o        = ascent_gradient               ;
// assign slow_ascent_period_o     = slow_ascent_period            ;
assign quad_sensor_bg_en_o      = quad_sensor_bg_en             ;
assign sensor_config_en_o       = sensor_config_en              ; 
assign sensor_config_cmd_o      = sensor_config_cmd             ;
assign sensor_config_test_o     = sensor_config_test            ;
assign eds_power_en_o           = eds_power_en                  ;
assign eds_frame_en_o           = eds_frame_en                  ;
assign eds_frame_sel_o          = eds_frame_sel                 ;
assign eds_test_en_o            = eds_test_en                   ;
assign eds_frame_hold_o         = eds_frame_hold                ;
assign eds_texp_time_o          = eds_texp_time                 ;
assign eds_frame_to_frame_time_o= eds_frame_to_frame_time       ;
assign laser_uart_data_o        = laser_uart_data               ;
assign laser_uart_vld_o         = laser_uart_vld                ;
assign pmt_master_spi_data_o    = pmt_master_spi_data           ;
assign pmt_master_spi_vld_o     = pmt_master_spi_vld            ;
assign pmt_adc_start_data_o     = pmt_adc_start_data            ;
assign pmt_adc_start_vld_o      = pmt_adc_start_vld             ;
assign pmt_adc_start_hold_o     = pmt_adc_start_hold            ;
assign rd_mfpga_version_o       = rd_mfpga_version              ;
assign FBC_fifo_rst_o           = (data_acq_en=='d0)            ;
assign scan_soft_reset_o        = scan_soft_reset_pose          ; 
assign real_scan_start_o        = real_scan_start               ;
assign real_scan_sel_o          = real_scan_sel                 ;
assign x_start_encode_o         = x_start_encode                ; 
assign fast_shutter_encode_o    = fast_shutter_encode           ; 
assign x_end_encode_o           = x_end_encode                  ; 
assign soft_fast_shutter_set_o  = fast_shutter_set              ;
assign soft_fast_shutter_en_o   = fast_shutter_en               ;
assign scan_fbc_switch_o        = scan_fbc_switch               ;
assign pmt_Wencode_align_rst_o  = pmt_Wencode_align_rst         ;
assign pmt_Wencode_align_set_o  = pmt_Wencode_align_set         ;
assign pmt_Xencode_align_rst_o  = pmt_Xencode_align_rst         ;
assign pmt_Xencode_align_set_o  = pmt_Xencode_align_set         ;
assign eds_Wencode_align_rst_o  = eds_Wencode_align_rst         ;
assign eds_Wencode_align_set_o  = eds_Wencode_align_set         ;
assign eds_Xencode_align_rst_o  = eds_Xencode_align_rst         ;
assign eds_Xencode_align_set_o  = eds_Xencode_align_set         ;
assign encode_sim_en_o          = encode_sim_en                 ;
// assign encode_interval_rst_o    = encode_interval_rst           ;
assign scan_finish_comm_ack_o   = scan_finish_comm_ack          ;
assign plc_x_encode_o           = plc_x_encode                  ;
assign plc_x_encode_en_o        = plc_x_encode_en               ;
assign x_encode_zero_calib_o    = x_encode_zero_calib           ;
assign scan_encode_offset_o     = scan_encode_offset            ;
assign autocal_encode_offset_o  = autocal_encode_offset         ;
assign autocal_fbp_sel_o        = autocal_fbp_sel               ;
assign fbp_encode_start_o       = fbp_encode_start              ;
assign fbp_encode_end_o         = fbp_encode_end                ;
assign autocal_pow_sel_o        = autocal_pow_sel               ;
assign pow_encode_start_o       = pow_encode_start              ;
assign pow_encode_end_o         = pow_encode_end                ;
assign autocal_lpo_sel_o        = autocal_lpo_sel               ;
assign lpo_encode_start_o       = lpo_encode_start              ;
assign lpo_encode_end_o         = lpo_encode_end                ;

// overload register
assign scan_aurora_reset_o      = scan_aurora_reset             ;
// assign overload_ufeed_thre_o    = overload_motor_set            ;
assign position_pid_thr_o       = position_pid_thr              ;
assign fbc_pose_err_thr_o       = fbc_pose_err_thr              ;
assign fbc_ratio_max_thr_o      = fbc_ratio_max_thr             ;
assign fbc_ratio_min_thr_o      = fbc_ratio_min_thr             ;

assign laser_control_o          = laser_control                 ;
assign laser_out_switch_o       = laser_out_switch              ;
assign laser_analog_max_o       = laser_analog_max              ;
assign laser_analog_min_o       = laser_analog_min              ;
assign laser_analog_pwm_o       = laser_analog_pwm              ;
assign laser_analog_cycle_o     = laser_analog_cycle            ;
assign laser_analog_uplimit_o   = laser_analog_uplimit          ;
assign laser_analog_lowlimit_o  = laser_analog_lowlimit         ;
assign laser_analog_mode_sel_o  = laser_analog_mode_sel         ;
assign laser_analog_trigger_o   = laser_analog_trigger          ;
assign acc_job_control_o        = acc_job_control               ;
// assign acc_job_init_switch_o    = acc_job_init_switch           ;
assign acc_job_init_vol_trig_o  = acc_job_init_vol_trig         ;
assign acc_job_init_vol_o       = acc_job_init_vol              ;

assign acc_aom_class0_o         = acc_aom_class0                ;
assign acc_aom_class1_o         = acc_aom_class1                ;
assign acc_aom_class2_o         = acc_aom_class2                ;
assign acc_aom_class3_o         = acc_aom_class3                ;
assign acc_aom_class4_o         = acc_aom_class4                ;
assign acc_aom_class5_o         = acc_aom_class5                ;
assign acc_aom_class6_o         = acc_aom_class6                ;
assign acc_aom_class7_o         = acc_aom_class7                ; 

assign aom_trig_protect_o         = aom_trig_protect            ;
assign aom_continuous_trig_thre_o = aom_continuous_trig_thre    ;
assign aom_integral_trig_thre_o   = aom_integral_trig_thre      ;
assign aom_trig_vol_thre_o        = aom_trig_vol_thre           ;
assign acc_demo_mode_o            = acc_demo_mode               ;
assign acc_demo_wren_o            = acc_demo_wren               ;
assign acc_demo_addr_o            = acc_demo_addr               ;
assign acc_demo_Wencode_o         = acc_demo_Wencode            ;
assign acc_demo_Xencode_o         = acc_demo_Xencode            ;
assign acc_demo_particle_cnt_o    = acc_demo_particle_cnt       ;
assign acc_demo_trim_time_pose_o  = acc_demo_trim_time_pose     ;
assign acc_demo_trim_time_nege_o  = acc_demo_trim_time_nege     ;
assign acc_demo_xencode_offset_o  = acc_demo_xencode_offset     ;
assign acc_skip_fifo_rd_o         = acc_skip_fifo_rd            ;
assign timing_flag_supp_o         = timing_flag_supp            ;
// assign trig_fifo_rd_o             = trig_fifo_rd                ;
// assign dbg_mem_rd_en_o            = dbg_mem_rd_en               ;
// assign dbg_mem_start_o            = dbg_mem_start               ;
assign fbc_udp_rate_switch_o      = fbc_udp_rate_switch         ;
assign aurora_soft_rd_1_o         = aurora_soft_rd_1            ;
assign aurora_soft_rd_2_o         = aurora_soft_rd_2            ;
assign aurora_soft_rd_3_o         = aurora_soft_rd_3            ;
assign encode_check_clean_o       = encode_check_clean          ;

assign ad5592_1_dac_config_en_o     = ad5592_1_dac_config_en    ;
assign ad5592_1_dac_channel_o       = ad5592_1_dac_channel      ;
assign ad5592_1_dac_data_o          = ad5592_1_dac_data         ;
assign ad5592_1_adc_config_en_o     = ad5592_1_adc_config_en    ;
assign ad5592_1_adc_channel_o       = ad5592_1_adc_channel      ;
assign ddr_rd_addr_o                = ddr_rd_addr               ;
assign ddr_rd_en_o                  = ddr_rd_en                 ;
assign cfg_acc_use_o                = cfg_acc_use               ;
assign cfg_fbc_rate_o               = cfg_fbc_rate              ;
assign cfg_spindle_width_o          = cfg_spindle_width         ;
assign cfg_FBC_bypass_o             = cfg_FBC_bypass            ;
assign cfg_QPD_enable_o             = cfg_QPD_enable            ;
assign dbg_qpd_mode_o               = dbg_qpd_mode              ;
assign map_readback_cnt_o           = map_readback_cnt          ;
assign main_scan_cnt_o              = main_scan_cnt             ;
assign heartbeat_bypass_o           = heartbeat_bypass          ;
// // FBC sensor response test
// reg          fbc_response_flag  = 'd0;
// reg [22-1:0] fbc_response_test_cnt = 'd0;
// always @(posedge clk_sys_i) begin
//     if(command_sel=='h011b && command_data_vld)
//         fbc_response_test_cnt <= #TCQ 'd0;
//     else if(~(&fbc_response_test_cnt))
//         fbc_response_test_cnt <= #TCQ fbc_response_test_cnt + 1;
// end

// always @(posedge clk_sys_i) begin
//     if(command_sel=='h011b && command_data_vld)
//         fbc_response_flag <= #TCQ 'd1;
//     else if(&fbc_response_test_cnt)
//         fbc_response_flag <= #TCQ 'd0;
// end
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

endmodule
