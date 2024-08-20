`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: songyuxin
// 
// Create Date: 2023/6/1 
// Design Name:  
// Module Name: bpsi_top_if_v2
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

module bpsi_top_if_v2#(
    parameter                   TCQ             = 0.1       ,
    parameter                   DBG_MEM_WIDTH   = 32*5      ,
    parameter                   DBG_MEM_DEPTH   = 4096      
)(
    input   wire                clk_sys_i                   ,
    input   wire                clk_h_i                     ,
    input   wire                rst_i                       ,
                
    input   wire                cfg_fbc_rate_i              ,
    input   wire    [2-1:0]     cfg_FBC_bypass_i            ,
    input   wire                cfg_QPD_enable_i            ,
    input   wire                dbg_qpd_mode_i              ,
    input   wire    [2:0]       data_acq_en_i               , // motor enable signal
    input   wire                bg_data_acq_en_i            ,
    // input   wire                position_cali_en_i          , // test
    // input   wire    [1:0]       sensor_mode_sel_i           ,
    // input   wire    [2-1:0]     sensor_ds_rate_i            ,
    input   wire    [24:0]      position_aim_i              , // aim position
    input   wire    [26-1:0]    kp_i                        , // PID controller kp parameter
    input   wire    [26-1:0]    ki_i                        , // PID controller ki parameter
    input   wire    [26-1:0]    kd_i                        , // PID controller kd parameter
    input   wire    [3:0]       motor_freq_i                , // motor response frequency. 0:100Hz 1:200Hz 2:300Hz
    input   wire                motor_bias_vol_en_i         ,
    input   wire    [15:0]      fbc_bias_voltage_i          , // 
    // input   wire    [15:0]      fbc_cali_uop_set_i          , // Uop set
    input   wire    [16-1:0]    ascent_gradient_i           ,
    input   wire    [16-1:0]    slow_ascent_period_i        ,

    input   wire                quad_sensor_bg_en_i         ,
    input   wire                sensor_config_en_i          ,
    input   wire    [16-1:0]    sensor_config_cmd_i         ,
    input   wire                sensor_config_test_i        ,
        
    output  wire                motor_rd_en_o               , // read Ufeed en
    input   wire                motor_data_out_en_i         , // Ufeed en
    input   wire    [15:0]      motor_data_out_i            , // Ufeed
    output  wire                motor_data_in_en_o          , // Uop en
    output  wire    [15:0]      motor_Ufeed_latch_o         , // Ufeed from motor
    output  wire    [15:0]      motor_data_in_o             , // Uop to motor
    output  wire    [32-1:0]    delta_position_o            ,

    input   wire    [24:0]      position_pid_thr_i          ,
    input   wire    [24:0]      fbc_pose_err_thr_i          ,
    output  wire                fbc_close_state_o           ,
    input   wire    [24:0]      fbc_ratio_max_thr_i         ,
    input   wire    [24:0]      fbc_ratio_min_thr_i         ,
    output  wire                fbc_close_state_err_o       ,
    output  wire    [24:0]      err_position_latch_o        ,
    output  wire                fbc_ratio_err_o             ,
    output  wire    [22-1:0]    err_intensity_latch_o       ,
    // // calibrate voltage. dark current * R
    // output  wire                FBCi_cali_en_o              ,
    // output  wire    [23:0]      FBCi_cali_a_o               ,
    // output  wire    [23:0]      FBCi_cali_b_o               ,
    // output  wire                FBCr2_cali_en_o             ,
    // output  wire    [23:0]      FBCr2_cali_a_o              ,
    // output  wire    [23:0]      FBCr2_cali_b_o              ,
    
    // actual voltage
    output  wire                FBC_out_vld_o               ,
    // output  wire                FBCi_out_en_o               ,
    output  wire    [23:0]      FBCi_out_a_o                ,
    output  wire    [23:0]      FBCi_out_b_o                ,
    // output  wire                FBCr1_out_en_o              ,
    output  wire    [23:0]      FBCr1_out_a_o               ,
    output  wire    [23:0]      FBCr1_out_b_o               ,
    // output  wire                FBCr2_out_en_o              ,
    output  wire    [23:0]      FBCr2_out_a_o               ,
    output  wire    [23:0]      FBCr2_out_b_o               ,

    // background voltage. dark current * R
    output  wire                FBCi_bg_en_o                ,
    output  wire    [23:0]      FBCi_bg_a_o                 ,
    output  wire    [23:0]      FBCi_bg_b_o                 ,
    output  wire                FBCr1_bg_en_o               ,
    output  wire    [23:0]      FBCr1_bg_a_o                ,
    output  wire    [23:0]      FBCr1_bg_b_o                ,
    output  wire                FBCr2_bg_en_o               ,
    output  wire    [23:0]      FBCr2_bg_a_o                ,
    output  wire    [23:0]      FBCr2_bg_b_o                ,

    // FBC cache data, 128k
    output  wire                FBCi_cache_vld_o            ,
    output  wire    [48-1:0]    FBCi_cache_data_o           ,
    output  wire                FBCr1_cache_vld_o           ,
    output  wire    [48-1:0]    FBCr1_cache_data_o          ,
    output  wire                FBCr2_cache_vld_o           ,
    output  wire    [48-1:0]    FBCr2_cache_data_o          ,

    // QBD sensor data
    output  wire                quad_sensor_data_en_o       ,
    output  wire    [96-1:0]    quad_sensor_data_o          ,
    output  wire                quad_sensor_bg_data_en_o    ,
    output  wire    [96-1:0]    quad_sensor_bg_data_o       ,
    output  wire                quad_cache_vld_o            ,
    output  wire    [96-1:0]    quad_cache_data_o           ,

    // spi info
    output  wire                FBCi_MCLK                   ,
    output  wire                FBCi_MOSI                   ,
    input   wire                FBCi_SCLK                   ,
    input   wire                FBCi_MISO                   ,
    output  wire                FBCr1_MCLK                  ,
    output  wire                FBCr1_MOSI                  ,
    input   wire                FBCr1_SCLK                  ,
    input   wire                FBCr1_MISO                  ,
    output  wire                FBCr2_MCLK                  ,
    output  wire                FBCr2_MOSI                  ,
    input   wire                FBCr2_SCLK                  ,
    input   wire                FBCr2_MISO                  
);
//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

reg                                 data_acq_en_d0          = 'd0;
reg                                 data_acq_en_d1          = 'd0;
reg                                 set_data_acq_en         = 'd0;
reg                                 fbc_sensor_enable       = 'd0;
reg                                 FBC_out_vld             = 'd0;
reg         [24-1:0]                FBCi_out_a              = 'd0;
reg         [24-1:0]                FBCi_out_b              = 'd0;
reg         [24-1:0]                FBCr1_out_a             = 'd0;
reg         [24-1:0]                FBCr1_out_b             = 'd0;
reg         [24-1:0]                FBCr2_out_a             = 'd0;
reg         [24-1:0]                FBCr2_out_b             = 'd0;

reg                                 FBC_first_wait          = 'd0;
reg         [16-1:0]                FBC_time_tick_cnt       = 'd0;
reg         [24-1:0]                FBC_vld_tick_cnt        = 'd0;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

wire                                pid_postion_vld         ;
wire        [48-1:0]                pid_postion_data        ;

wire                                FBCr1_MCLK_qpd          ;
wire                                FBCr1_MOSI_qpd          ;
wire                                FBCr1_SCLK_qpd          ;
wire                                FBCr1_MISO_qpd          ;

wire                                FBCr1_MCLK_fbc          ;
wire                                FBCr1_MOSI_fbc          ;
wire                                FBCr1_SCLK_fbc          ;
wire                                FBCr1_MISO_fbc          ;


wire                                FBCi_out_en             ;
wire                                FBCr1_out_en            ;
wire                                FBCr2_out_en            ;

wire                                FBCi_bg_en              ;
wire                                FBCr1_bg_en             ;
wire                                FBCr2_bg_en             ;

wire                                FBCi_cache_vld          ;
wire                                FBCr1_cache_vld         ;
wire                                FBCr2_cache_vld         ;

wire                                quad_sensor_data_en     ;
wire                                quad_sensor_bg_data_en  ;
wire                                quad_cache_vld          ;
// wire                                dbg_mem_full            ;
// wire                                dbg_mem_empty           ;
// wire                                dbg_mem_vld             ; 
// wire        [DBG_MEM_WIDTH-1:0]     dbg_mem_data            ;
// wire        [32-1:0]                actu_position           ;
wire                                FBC_out_enable          ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
trigger_generate trigger_generate_inst(
    // clk & rst
    .clk_i                          ( clk_sys_i                     ),
    .rst_i                          ( rst_i                         ),

    .motor_bias_vol_en_i            ( motor_bias_vol_en_i           ),
    .motor_freq_i                   ( motor_freq_i                  ), // motor close freq  0:100Hz 1:200Hz 2:300Hz
    .motor_trigger_o                ( motor_rd_en_o                 )

);

fbc_sensor_process fbci_sensor_process_inst(
    .clk_sys_i                      ( clk_sys_i                     ),
    .clk_h_i                        ( clk_h_i                       ),
    .rst_i                          ( rst_i                         ),

    .cfg_fbc_rate_i                 ( cfg_fbc_rate_i                ),
    .dbg_qpd_mode_i                 ( dbg_qpd_mode_i                ),
    .data_acq_en_i                  ( data_acq_en_i                 ), // motor enable signal
    .bg_data_acq_en_i               ( bg_data_acq_en_i              ), // background sample. pulse
    // .position_cali_en_i             ( position_cali_en_i            ), // test
    // .sensor_mode_sel_i              ( sensor_mode_sel_i             ),
    // .sensor_ds_rate_i               ( sensor_ds_rate_i              ),

    // .cali_data_en_o                 ( FBCi_cali_en_o                ),
    // .cali_data_a_o                  ( FBCi_cali_a_o                 ),
    // .cali_data_b_o                  ( FBCi_cali_b_o                 ),

    .data_out_en_o                  ( FBCi_out_en                   ),
    .data_out_a_o                   ( FBCi_out_a_o                  ),
    .data_out_b_o                   ( FBCi_out_b_o                  ),

    .bg_data_en_o                   ( FBCi_bg_en                    ),
    .bg_data_a_o                    ( FBCi_bg_a_o                   ),
    .bg_data_b_o                    ( FBCi_bg_b_o                   ),

    .pid_postion_vld_o              ( pid_postion_vld               ),
    .pid_postion_data_o             ( pid_postion_data              ),
    .fbc_cache_vld_o                ( FBCi_cache_vld                ),
    .fbc_cache_data_o               ( FBCi_cache_data_o             ),

    .MSPI_CLK                       ( FBCi_MCLK                     ),
    .MSPI_MOSI                      ( FBCi_MOSI                     ),
    .SSPI_CLK                       ( FBCi_SCLK                     ),
    .SSPI_MISO                      ( FBCi_MISO                     )
);

fbc_sensor_process fbcr1_sensor_process_inst(
    .clk_sys_i                      ( clk_sys_i                     ),
    .clk_h_i                        ( clk_h_i                       ),
    .rst_i                          ( rst_i                         ),

    .cfg_fbc_rate_i                 ( cfg_fbc_rate_i                ),
    .dbg_qpd_mode_i                 ( dbg_qpd_mode_i                ),
    .data_acq_en_i                  ( data_acq_en_i                 ), // motor enable signal
    .bg_data_acq_en_i               ( bg_data_acq_en_i              ), // background sample. pulse
    // .position_cali_en_i             ( position_cali_en_i            ), // test
    // .sensor_mode_sel_i              ( sensor_mode_sel_i             ),
    // .sensor_ds_rate_i               ( sensor_ds_rate_i              ),

    // .cali_data_en_o                 ( FBCr1_cali_en_o               ),
    // .cali_data_a_o                  ( FBCr1_cali_a_o                ),
    // .cali_data_b_o                  ( FBCr1_cali_b_o                ),

    .data_out_en_o                  ( FBCr1_out_en                  ),
    .data_out_a_o                   ( FBCr1_out_a_o                 ),
    .data_out_b_o                   ( FBCr1_out_b_o                 ),

    .bg_data_en_o                   ( FBCr1_bg_en                   ),
    .bg_data_a_o                    ( FBCr1_bg_a_o                  ),
    .bg_data_b_o                    ( FBCr1_bg_b_o                  ),

    .fbc_cache_vld_o                ( FBCr1_cache_vld               ),
    .fbc_cache_data_o               ( FBCr1_cache_data_o            ),

    .MSPI_CLK                       ( FBCr1_MCLK_fbc                ),
    .MSPI_MOSI                      ( FBCr1_MOSI_fbc                ),
    .SSPI_CLK                       ( FBCr1_SCLK_fbc                ),
    .SSPI_MISO                      ( FBCr1_MISO_fbc                )
);


fbc_sensor_process fbcr2_sensor_process_inst(
    .clk_sys_i                      ( clk_sys_i                     ),
    .clk_h_i                        ( clk_h_i                       ),
    .rst_i                          ( rst_i                         ),

    .cfg_fbc_rate_i                 ( cfg_fbc_rate_i                ),
    .dbg_qpd_mode_i                 ( dbg_qpd_mode_i                ),
    .data_acq_en_i                  ( data_acq_en_i                 ), // motor enable signal
    .bg_data_acq_en_i               ( bg_data_acq_en_i              ), // background sample. pulse
    // .position_cali_en_i             ( position_cali_en_i            ), // test
    // .sensor_mode_sel_i              ( sensor_mode_sel_i             ),
    // .sensor_ds_rate_i               ( sensor_ds_rate_i              ),

    // .cali_data_en_o                 ( FBCr2_cali_en_o               ),
    // .cali_data_a_o                  ( FBCr2_cali_a_o                ),
    // .cali_data_b_o                  ( FBCr2_cali_b_o                ),

    .data_out_en_o                  ( FBCr2_out_en                  ),
    .data_out_a_o                   ( FBCr2_out_a_o                 ),
    .data_out_b_o                   ( FBCr2_out_b_o                 ),

    .bg_data_en_o                   ( FBCr2_bg_en                   ),
    .bg_data_a_o                    ( FBCr2_bg_a_o                  ),
    .bg_data_b_o                    ( FBCr2_bg_b_o                  ),

    .fbc_cache_vld_o                ( FBCr2_cache_vld               ),
    .fbc_cache_data_o               ( FBCr2_cache_data_o            ),

    .MSPI_CLK                       ( FBCr2_MCLK                    ),
    .MSPI_MOSI                      ( FBCr2_MOSI                    ),
    .SSPI_CLK                       ( FBCr2_SCLK                    ),
    .SSPI_MISO                      ( FBCr2_MISO                    )
);

PID_control_v2 #(
    .POSITION_DATA                  ( 24                            ), 
    .EXTEND_BIT                     ( 20                            ), 
    .MOTOR_VOL                      ( 16                            ), 
    .PID_RESULT                     ( 16                            ), 
    .PID_PARAMETER                  ( 6                             )
)PID_control_inst(
    // clk & rst
    .clk_i                          ( clk_sys_i                     ),
    .rst_i                          ( rst_i                         ),

    .data_acq_en_i                  ( data_acq_en_i                 ), // motor control enable
    // .motor_trigger_i                ( motor_trigger                 ),
    .kp_i                           ( kp_i                          ), // parameter kp
    .ki_i                           ( ki_i                          ), // parameter ki
    .kd_i                           ( kd_i                          ), // parameter kd
    .position_aim_i                 ( position_aim_i                ), // aim position
    .fbc_bias_voltage_i             ( fbc_bias_voltage_i            ), // bais voltage
    // .fbc_cali_uop_set_i             ( fbc_cali_uop_set_i            ), // cali voltage
    .actual_data_en_i               ( pid_postion_vld               ),
    .actual_data_a_i                ( pid_postion_data[48-1:24]     ),
    .actual_data_b_i                ( pid_postion_data[24-1:0]      ),
    .bg_data_a_i                    ( FBCi_bg_a_o                   ),
    .bg_data_b_i                    ( FBCi_bg_b_o                   ),

    .motor_Ufeed_en_i               ( motor_data_out_en_i           ),
    .motor_Ufeed_i                  ( motor_data_out_i              ),
    .motor_data_in_en_o             ( motor_data_in_en_o            ),
    // .motor_rd_en_o                  ( motor_rd_en_o                 ),
    .motor_Ufeed_latch_o            ( motor_Ufeed_latch_o           ),
    .motor_data_in_o                ( motor_data_in_o               ),
    .delta_position_o               ( delta_position_o              ),
    // .actu_position_o                ( actu_position                 ),

    .position_pid_thr_i             ( position_pid_thr_i            ),
    .fbc_pose_err_thr_i             ( fbc_pose_err_thr_i            ),
    .fbc_close_state_o              ( fbc_close_state_o             ),
    .fbc_ratio_max_thr_i            ( fbc_ratio_max_thr_i           ),
    .fbc_ratio_min_thr_i            ( fbc_ratio_min_thr_i           ),
    .fbc_close_state_err_o          ( fbc_close_state_err_o         ),
    .err_position_latch_o           ( err_position_latch_o          ),
    .fbc_ratio_err_o                ( fbc_ratio_err_o               ),
    .err_intensity_latch_o          ( err_intensity_latch_o         )
);


quad_sensor_process quad_sensor_process_inst(
    .clk_sys_i                      ( clk_sys_i                     ),
    .clk_h_i                        ( clk_h_i                       ),
    .rst_i                          ( rst_i                         ),

    // control command
    .cfg_quad_rate_i                ( cfg_fbc_rate_i                ),
    .dbg_qpd_mode_i                 ( dbg_qpd_mode_i                ),
    .data_acq_en_i                  ( data_acq_en_i                 ), // motor enable signal
    .quad_sensor_bg_en_i            ( quad_sensor_bg_en_i           ), // background sample. pulse
    .quad_sensor_config_en_i        ( sensor_config_en_i            ),
    .quad_sensor_config_cmd_i       ( sensor_config_cmd_i           ),
    .quad_sensor_config_test_i      ( sensor_config_test_i          ),
    
    // actual voltage
    .data_out_en_o                  ( quad_sensor_data_en           ),
    .data_out_o                     ( quad_sensor_data_o            ),

    // background voltage. dark current * R
    .bg_data_en_o                   ( quad_sensor_bg_data_en        ),
    .bg_data_o                      ( quad_sensor_bg_data_o         ),

    .quad_cache_vld_o               ( quad_cache_vld                ),
    .quad_cache_data_o              ( quad_cache_data_o             ),

    // sensor spi info
    .MSPI_CLK                       ( FBCr1_MCLK_qpd                ),
    .MSPI_MOSI                      ( FBCr1_MOSI_qpd                ),
    .SSPI_CLK                       ( FBCr1_SCLK_qpd                ),
    .SSPI_MISO                      ( FBCr1_MISO_qpd                )
);
// analog_slow_ascent analog_slow_ascent_inst(
//     // clk & rst
//     .clk_i                          ( clk_sys_i                     ),
//     .rst_i                          ( rst_i                         ),
    
//     .ascent_gradient_i              ( ascent_gradient_i             ),
//     .slow_ascent_period_i           ( slow_ascent_period_i          ),
    
//     .motor_data_in_en_i             ( motor_data_in_en              ),
//     .motor_data_in_i                ( motor_data_in                 ),
//     .motor_slow_ascent_en_o         ( motor_data_in_en_o            ),
//     .motor_slow_ascent_o            ( motor_data_in_o               )

// );
// xpm_sync_fifo #(
//     .ECC_MODE                       ( "no_ecc"                      ),
//     .FIFO_MEMORY_TYPE               ( "block"                       ), // "auto" "block" "distributed"
//     .READ_MODE                      ( "std"                         ), // "std" "fwft"
//     .FIFO_WRITE_DEPTH               ( DBG_MEM_DEPTH                 ),
//     .WRITE_DATA_WIDTH               ( DBG_MEM_WIDTH                 ),
//     .READ_DATA_WIDTH                ( DBG_MEM_WIDTH                 ),
//     .USE_ADV_FEATURES               ( "1808"                        )
// )dbg_mem_fifo (
//     .wr_clk_i                       ( clk_sys_i                     ),
//     .rst_i                          ( rst_i                         ), // synchronous to wr_clk
//     .wr_en_i                        ( dbg_mem_vld                   ),
//     .wr_data_i                      ( dbg_mem_data                  ),
//     .fifo_full_o                    ( dbg_mem_full                  ),

//     .rd_en_i                        ( dbg_mem_rd_en_i               ),
//     .fifo_empty_o                   ( dbg_mem_empty                 ),
//     .fifo_rd_data_o                 ( dbg_mem_rd_data_o             )
// );

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
assign FBCr1_MCLK       = cfg_QPD_enable_i ? FBCr1_MCLK_qpd : FBCr1_MCLK_fbc;
assign FBCr1_MOSI       = cfg_QPD_enable_i ? FBCr1_MOSI_qpd : FBCr1_MOSI_fbc;
assign FBCr1_SCLK_qpd   = cfg_QPD_enable_i ? FBCr1_SCLK : 'd0;
assign FBCr1_MISO_qpd   = cfg_QPD_enable_i ? FBCr1_MISO : 'd0;
assign FBCr1_SCLK_fbc   = cfg_QPD_enable_i ? 'd0 : FBCr1_SCLK;
assign FBCr1_MISO_fbc   = cfg_QPD_enable_i ? 'd0 : FBCr1_MISO;

// assign FBCi_out_en_o            = FBCi_out_en;
// assign FBCr1_out_en_o           = (cfg_FBC_bypass_i[1] || cfg_QPD_enable_i) ? FBCi_out_en : FBCr1_out_en;
// assign FBCr2_out_en_o           = cfg_FBC_bypass_i[0] ? FBCi_out_en : FBCr2_out_en;

assign FBCi_bg_en_o             = FBCi_bg_en; 
assign FBCr1_bg_en_o            = (cfg_FBC_bypass_i[1] || cfg_QPD_enable_i) ? FBCi_bg_en : FBCr1_bg_en; 
assign FBCr2_bg_en_o            = cfg_FBC_bypass_i[0] ? FBCi_bg_en : FBCr2_bg_en; 

assign FBCi_cache_vld_o         = FBCi_cache_vld; 
assign FBCr1_cache_vld_o        = (cfg_FBC_bypass_i[1] || cfg_QPD_enable_i) ? FBCi_cache_vld : FBCr1_cache_vld; 
assign FBCr2_cache_vld_o        = cfg_FBC_bypass_i[0] ? FBCi_cache_vld : FBCr2_cache_vld; 

assign quad_sensor_data_en_o    = cfg_QPD_enable_i ? quad_sensor_data_en : 'd0; 
assign quad_sensor_bg_data_en_o = cfg_QPD_enable_i ? quad_sensor_bg_data_en : 'd0; 
assign quad_cache_vld_o         = cfg_QPD_enable_i ? quad_cache_vld : 'd0; 


always @(posedge clk_sys_i)begin
    data_acq_en_d0  <= #TCQ (|data_acq_en_i)     ;
    data_acq_en_d1  <= #TCQ data_acq_en_d0       ;
end

always @(posedge clk_sys_i)begin
    set_data_acq_en <= #TCQ data_acq_en_d1 ^ data_acq_en_d0;
end

always @(posedge clk_sys_i) begin
    if(set_data_acq_en)
        fbc_sensor_enable <= #TCQ data_acq_en_d1;
end

always @(posedge clk_sys_i) begin
    if(~fbc_sensor_enable)
        FBC_first_wait <= #TCQ 'd0;
    else if(FBC_time_tick_cnt >= 'd49_999)
        FBC_first_wait <= #TCQ 'd0;
    else if(FBCi_out_en || FBCr1_out_en || FBCr2_out_en)
        FBC_first_wait <= #TCQ 'd1;
end

always @(posedge clk_sys_i) begin
    if(~fbc_sensor_enable)
        FBC_time_tick_cnt <= #TCQ 'd0;
    else if(FBC_first_wait)
        FBC_time_tick_cnt <= #TCQ FBC_time_tick_cnt + 1;
    else 
        FBC_time_tick_cnt <= #TCQ FBC_time_tick_cnt;
end

assign FBC_out_enable = FBC_time_tick_cnt >= 'd49_999; // 500us

always @(posedge clk_sys_i) begin
    if(FBC_out_enable)begin
        if(FBC_vld_tick_cnt >= 'd99_999)  // 1ms
            FBC_vld_tick_cnt <= #TCQ 'd0;
        else 
            FBC_vld_tick_cnt <= #TCQ FBC_vld_tick_cnt + 1;
    end
    else
            FBC_vld_tick_cnt <= #TCQ 'd0;
end

always @(posedge clk_sys_i) begin
    FBC_out_vld <= #TCQ FBC_vld_tick_cnt=='d0 && FBC_out_enable;
end

assign FBC_out_vld_o = FBC_out_vld;
// assign FBCi_cache_vld_o   = FBCi_out_en_o;
// assign FBCi_cache_data_o  = {FBCi_out_a_o,FBCi_out_b_o};
// assign FBCr1_cache_vld_o  = FBCr1_out_en_o;
// assign FBCr1_cache_data_o = {FBCr1_out_a_o,FBCr1_out_b_o};
// assign FBCr2_cache_vld_o  = FBCr2_out_en_o;
// assign FBCr2_cache_data_o = {FBCr2_out_a_o,FBCr2_out_b_o};

// reg          dbg_write_en       = 'd0;
// always @(posedge clk_sys_i) begin
//     if(dbg_mem_start_i)
//         dbg_write_en <= #TCQ 'd1;
//     else if(FBCi_out_en_o && dbg_mem_full)
//         dbg_write_en <= #TCQ 'd0;
// end

// assign dbg_mem_vld      = FBCi_out_en_o && dbg_write_en;
// assign dbg_mem_state_o  = {dbg_mem_full,dbg_mem_empty};
// assign dbg_mem_data     = { 
//                             5'd0,
//                             data_acq_en_i[2:0],
//                             FBCi_out_a_o[24-1:0],
//                             FBCi_out_b_o[24-1:0],
//                             motor_Ufeed_latch_o[16-1:0],
//                             motor_data_in_o[16-1:0],
//                             position_aim_i[24-1:0],
//                             fbc_bias_voltage_i[16-1:0],
//                             actu_position[32-1:0]
//                         };

// // debug
// wire [24-1:0] debug_FBCi_cache_data_a;
// wire [24-1:0] debug_FBCi_cache_data_b;
// assign debug_FBCi_cache_data_a = pid_postion_data[48-1:24];
// assign debug_FBCi_cache_data_b = pid_postion_data[24-1:0];
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




endmodule