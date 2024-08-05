`timescale  1ns / 1ps

module tb_acc_demo_ctrl;

// acc_demo_ctrl Parameters
parameter PERIOD = 10 ;
parameter TCQ  = 0.1;

// acc_demo_ctrl Inputs
reg   clk_i                                = 0 ;
reg   rst_i                                = 0 ;
reg                 acc_demo_mode               = 'd1;
reg                 acc_demo_wren               = 'd0;
reg     [16-1:0]    acc_demo_addr               = 'd0;
reg     [32-1:0]    acc_demo_Wencode            = 'd0;
reg     [32-1:0]    acc_demo_Xencode            = 'd0;
reg     [16-1:0]    acc_demo_particle_cnt       = 'd0;


reg                 laser_control               = 'd0;      // 默认关光
reg                 laser_out_switch            = 'd1;      // 默认内控
reg     [12-1:0]    laser_analog_max            = 'd1638;   // 4095 = 5V
reg     [12-1:0]    laser_analog_min            = 'd0;
reg     [32-1:0]    laser_analog_pwm            = 'd100;    // 50% PWM
reg     [32-1:0]    laser_analog_cycle          = 'd200;    // 2000ns = 500kHz 
reg     [12-1:0]    laser_analog_uplimit        = 'd2866;   // 3.5V / 5 * 4095
reg     [12-1:0]    laser_analog_lowlimit       = 'd0;
reg                 laser_analog_mode_sel       = 'd0;      // 0: PWM  1: trigger
reg                 laser_analog_trigger        = 'd0;

reg                 acc_job_control                 = 'd1   ;
reg                 acc_job_init_switch             = 'd1   ;
reg                 acc_job_init_vol_trig           = 'd0   ;
reg     [12-1:0]    acc_job_init_vol                = 'd2457; 
reg     [12-1:0]    acc_aom_class0                  = 'd0   ;
reg     [12-1:0]    acc_aom_class1                  = 'd819 ;
reg     [12-1:0]    acc_aom_class2                  = 'd1228;
reg     [12-1:0]    acc_aom_class3                  = 'd1638;
reg     [12-1:0]    acc_aom_class4                  = 'd2457;
reg     [12-1:0]    acc_aom_class5                  = 'd2866;
reg     [12-1:0]    acc_aom_class6                  = 'd3276;
reg     [12-1:0]    acc_aom_class7                  = 'd4095;
reg                 aom_trig_protect                = 'd1       ;
reg     [32-1:0]    aom_continuous_trig_thre        = 'd100000  ;
reg     [32-1:0]    aom_integral_trig_thre          = 'd3300000 ;
reg     [12-1:0]    aom_trig_vol_thre               = 'd1228    ;

reg     [32-1:0]    real_precise_encode_w           = 'd0;
reg     [32-1:0]    real_precise_encode_x           = 'd0;
reg [18-1:0] wencode = 'd0;
reg [18-1:0] xencode = 'd0;
reg [14-1:0] wencode_extend = 'd0;
reg [14-1:0] xencode_extend = 'd0;
reg main_scan_start = 'd0;
reg pmt_scan_en = 'd0;
// acc_demo_ctrl Outputs
wire  acc_demo_flag                      ;

wire                aom_continuous_trig_err        ;
wire                aom_integral_trig_err          ;
wire            RF_Enable_LS     ;
wire            RF_emission_LS   ;
wire            laser_aom_en     ;
wire   [12-1:0] laser_aom_voltage;

reg clk_200m = 0;
initial
begin
    forever #(PERIOD/2)  clk_i=~clk_i;
end

initial
begin
    forever #(2.5)  clk_200m=~clk_200m;
end

initial
begin
    rst_i  =  1;
    #(PERIOD*2);
    rst_i  =  0;
end

acc_demo_ctrl acc_demo_ctrl_inst(
    // clk & rst
    .clk_i                          ( clk_i                         ),
    .rst_i                          ( rst_i                         ),
    
    .acc_demo_mode_i                ( acc_demo_mode                 ),
    .acc_demo_wren_i                ( acc_demo_wren                 ),
    .acc_demo_addr_i                ( acc_demo_addr                 ),
    .acc_demo_Wencode_i             ( {wencode_extend,wencode}      ),
    .acc_demo_Xencode_i             ( {xencode_extend,xencode}      ),
    .acc_demo_particle_cnt_i        ( acc_demo_particle_cnt         ),

    .pmt_scan_en_i                  ( pmt_scan_en                   ),
    .main_scan_start_i              ( main_scan_start               ),
    .real_precise_Wencode_i         ( real_precise_encode_w[17:0]   ),
    .real_precise_Xencode_i         ( real_precise_encode_x[21:4]   ),

    .acc_demo_skip_cnt_o            ( acc_demo_skip_cnt             ),
    .acc_demo_addr_latch_o          ( acc_demo_addr_latch           ),
    .skip_fifo_rd_i                 ( 0              ),
    .skip_fifo_ready_o              ( acc_skip_fifo_ready           ),
    .skip_fifo_data_o               ( acc_skip_fifo_data            ),
    .acc_demo_flag_o                ( acc_demo_flag                 )
);


laser_aom_ctrl laser_aom_ctrl_inst(
    .clk_i                          ( clk_i                         ),
    .rst_i                          ( rst_i                         ),
    .laser_control_i                ( laser_control                 ),
    .laser_out_switch_i             ( laser_out_switch              ),
    .laser_analog_max_i             ( laser_analog_max              ),
    .laser_analog_min_i             ( laser_analog_min              ),
    .laser_analog_pwm_i             ( laser_analog_pwm              ),
    .laser_analog_cycle_i           ( laser_analog_cycle            ),
    .laser_analog_uplimit_i         ( laser_analog_uplimit          ),
    .laser_analog_lowlimit_i        ( laser_analog_lowlimit         ),
    .laser_analog_mode_sel_i        ( laser_analog_mode_sel         ),
    .laser_analog_trigger_i         ( laser_analog_trigger          ),

    .acc_job_control_i              ( acc_job_control               ),
    .acc_job_init_vol_trig_i        ( acc_job_init_vol_trig         ),
    .acc_job_init_vol_i             ( acc_job_init_vol              ),
    .acc_aom_flag_i                 ( acc_demo_flag                 ),  // acc demo flag or pmt acc flag
    .acc_aom_class0_i               ( acc_aom_class0                ),
    .acc_aom_class1_i               ( acc_aom_class1                ),
    .acc_aom_class2_i               ( acc_aom_class2                ),
    .acc_aom_class3_i               ( acc_aom_class3                ),
    .acc_aom_class4_i               ( acc_aom_class4                ),
    .acc_aom_class5_i               ( acc_aom_class5                ),
    .acc_aom_class6_i               ( acc_aom_class6                ),
    .acc_aom_class7_i               ( acc_aom_class7                ),
    // .acc_aom_class_i                ( acc_aom_class[1]              ),

    .aom_continuous_trig_err_i      ( aom_continuous_trig_err       ),
    .aom_integral_trig_err_i        ( aom_integral_trig_err         ),

    .LASER_CONTROL                  ( RF_Enable_LS                  ),
    .LASER_OUT_SWITCH               ( RF_emission_LS                ),
    .laser_aom_en_o                 ( laser_aom_en                  ),
    .laser_aom_voltage_o            ( laser_aom_voltage             )
);


aom_trig_overload aom_trig_overload_inst(
    // clk & rst
    .clk_i                          ( clk_i                         ),
    .rst_i                          ( rst_i                         ),
    
    // interface    
    .laser_control_i                ( RF_Enable_LS                  ),
    .laser_out_switch_i             ( RF_emission_LS                ),
    .laser_aom_en_i                 ( laser_aom_en                  ),
    .laser_aom_voltage_i            ( laser_aom_voltage             ),

    .acc_job_control_i              ( acc_job_control               ),
    .aom_trig_protect_i             ( aom_trig_protect              ),
    .aom_continuous_trig_thre_i     ( aom_continuous_trig_thre      ),
    .aom_integral_trig_thre_i       ( aom_integral_trig_thre        ),
    .aom_trig_vol_thre_i            ( aom_trig_vol_thre             ),

    .aom_continuous_trig_err_o      ( aom_continuous_trig_err       ),
    .aom_integral_trig_err_o        ( aom_integral_trig_err         )

);
reg [16-1:0] acc_demo_trim_time_pose = 'd71;
reg [16-1:0] acc_demo_trim_time_nege = 'd81;
acc_demo_flag_trim acc_demo_flag_trim_inst(
    // clk & rst
    .clk_i                          ( clk_i                         ),
    .rst_i                          ( rst_i                         ),

    .acc_demo_flag_i                ( acc_demo_flag                 ),
    .acc_demo_trim_time_pose_i      ( acc_demo_trim_time_pose       ),
    .acc_demo_trim_time_nege_i      ( acc_demo_trim_time_nege       ),

    .acc_demo_trim_ctrl_o           ( acc_demo_trim_ctrl            ),
    .acc_demo_trim_flag_o           ( acc_demo_trim_flag            )
);

wire    [3-1:0]     pmt_scan_cmd_sel                ;
wire    [4-1:0]     pmt_scan_cmd                    ;
wire    [2:0]       pmt_start_en                    ;
wire    [2:0]       pmt_start_test_en               ;
wire    [2:0]       ENCODE_SPI_MCLK                 ;
wire    [2:0]       ENCODE_SPI_MOSI                 ;
genvar i;
generate
    for(i=0;i<3;i=i+1)begin : ACC_DEMO_FLAG_TX
        acc_demo_flag_tx_drv acc_demo_flag_tx_drv_inst(
            // clk & rst
            .clk_i              ( clk_i                                  ),
            .rst_i              ( rst_i                                  ),
            .clk_200m_i         ( clk_200m                                  ),

            .acc_demo_flag_i    ( acc_demo_trim_flag                        ),

            .pmt_scan_cmd_sel_i ( pmt_scan_cmd_sel[i]                       ),   // pmt sel
            .pmt_scan_cmd_i     ( pmt_scan_cmd                              ),   // bit[0]:scan start; bit[1]:scan test
            .pmt_start_en_o     ( pmt_start_en[i]                           ),
            .pmt_start_test_en_o( pmt_start_test_en[i]                      ),

            // spi info
            .SPI_MCLK           ( ENCODE_SPI_MCLK[i]                        ),
            .SPI_MOSI           ( ENCODE_SPI_MOSI[i]                        )
        );
    end
endgenerate

wire [3-1:0]pmt_acc_demo_flag;
wire [3-1:0]pmt_adc_start;
wire [3-1:0]pmt_adc_test;
generate
    for(i=0;i<3;i=i+1)begin : PMT_ACC_DEMO_FLAG_TX
        acc_demo_flag_rx_drv acc_demo_flag_rx_drv_inst(
            // clk & rst
            .clk_i                          ( clk_i                          ),
            .rst_i                          ( rst_i                          ),
            .clk_200m_i                     ( clk_200m                          ),

            .acc_demo_flag_o                ( pmt_acc_demo_flag[i]                     ),
            .scan_start_flag_o              ( pmt_adc_start[i]                         ),
            .scan_tset_flag_o               ( pmt_adc_test[i]                          ),

            // spi info
            .SPI_MCLK                       ( ENCODE_SPI_MCLK[i]              ),
            .SPI_MOSI                       ( ENCODE_SPI_MOSI[i]              )
        );
    end
endgenerate

always @(posedge clk_i) begin
    pmt_scan_en <= main_scan_start;
end
always @(posedge clk_i) begin
    if(pmt_scan_en)begin
        real_precise_encode_w <= (real_precise_encode_w == 'd4096) ? 'd0 : real_precise_encode_w + 1;
        real_precise_encode_x <= (real_precise_encode_w[9:0] == 'd1023) ? real_precise_encode_x + 16 : real_precise_encode_x;
    end
    else begin
        real_precise_encode_w <= 'd0;
        real_precise_encode_x <= 'd0;
    end

end

initial begin
    #1000;
    acc_demo_wren   = 1;
    acc_demo_addr   = 0;
    wencode         = 10;
    xencode         = 5;
    wencode_extend  = 200;
    xencode_extend  = 4;
    #(PERIOD);
    acc_demo_wren   = 1;
    acc_demo_addr   = 1;
    wencode         = 20;
    xencode         = 10;
    wencode_extend  = 125;
    xencode_extend  = 4;
    #(PERIOD);
    acc_demo_wren   = 1;
    acc_demo_addr   = 2;
    wencode         = 2000;
    xencode         = 10;
    wencode_extend  = 45;
    xencode_extend  = 4;
    #(PERIOD);
    acc_demo_wren   = 1;
    acc_demo_addr   = 3;
    wencode         = 3000;
    xencode         = 10;
    wencode_extend  = 400;
    xencode_extend  = 4;
    #(PERIOD);
    acc_demo_wren   = 1;
    acc_demo_addr   = 4;
    wencode         = 4000;
    xencode         = 10;
    wencode_extend  = 600;
    xencode_extend  = 4;
    #(PERIOD);
    acc_demo_wren   = 1;
    acc_demo_addr   = 5;
    wencode         = 459;
    xencode         = 25;
    wencode_extend  = 53;
    xencode_extend  = 4;
    #(PERIOD);
    acc_demo_wren   = 1;
    acc_demo_addr   = 6;
    wencode         = 480;
    xencode         = 22;
    wencode_extend  = 60;
    xencode_extend  = 4;
    #(PERIOD);
    acc_demo_wren   = 1;
    acc_demo_addr   = 7;
    wencode         = 459;
    xencode         = 30;
    wencode_extend  = 53;
    xencode_extend  = 5;
    #(PERIOD);
    acc_demo_wren   = 1;
    acc_demo_addr   = 8;
    wencode         = 120;
    xencode         = 38;
    wencode_extend  = 40;
    xencode_extend  = 4;
    #(PERIOD);
    acc_demo_wren   = 1;
    acc_demo_addr   = 9;
    wencode         = 459;
    xencode         = 30;
    wencode_extend  = 53;
    xencode_extend  = 5;
    #(PERIOD);
    acc_demo_wren   = 1;
    acc_demo_addr   = 10;
    acc_demo_particle_cnt = 10;
    wencode         = 200;
    xencode         = 60;
    wencode_extend  = 200;
    xencode_extend  = 4;
    #(PERIOD);
    acc_demo_wren   = 0;

    #1000;
    main_scan_start = 1;

end

endmodule