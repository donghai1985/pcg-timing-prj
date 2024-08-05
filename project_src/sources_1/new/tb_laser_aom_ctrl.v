//~ `New testbench
`timescale  1ns / 1ps

module tb_laser_aom_ctrl;

// laser_aom_ctrl Parameters
parameter PERIOD = 10 ;
parameter TCQ  = 0.1;

// laser_aom_ctrl Inputs
reg   clk_i                                = 0 ;
reg   rst_i                                = 0 ;       

reg                laser_control                  = 'd1;   
reg                laser_out_switch               = 'd0;   
reg    [12-1:0]    laser_analog_max               = 'd1638;
reg    [12-1:0]    laser_analog_min               = 'd0;
reg    [32-1:0]    laser_analog_pwm               = 'd100; 
reg    [32-1:0]    laser_analog_cycle             = 'd200; 
reg    [12-1:0]    laser_analog_uplimit           = 'd1638;
reg    [12-1:0]    laser_analog_lowlimit          = 'd0;
reg                laser_analog_mode_sel          = 'd0;   
reg                laser_analog_trigger           = 'd0;

// laser_aom_ctrl Outputs
wire                LASER_CONTROL                           ;
wire                LASER_OUT_SWITCH                        ;

wire                aom_continuous_trig_err                 ;
wire                aom_integral_trig_err                   ;

wire                laser_aom_en                            ;
wire    [12-1:0]    laser_aom_voltage                       ;

reg                 acc_job_control             = 'd0       ;
reg                 acc_job_init_switch         = 'd1       ;
reg                 acc_job_init_vol_trig       = 'd0       ;
reg     [12-1:0]    acc_job_init_vol            = 'd2457    ;

reg                 acc_aom_flag                = 'd0       ;
reg     [12-1:0]    acc_aom_class0              = 'd0       ;
reg     [12-1:0]    acc_aom_class1              = 'd819     ;
reg     [12-1:0]    acc_aom_class2              = 'd1228    ;
reg     [12-1:0]    acc_aom_class3              = 'd1638    ;
reg     [12-1:0]    acc_aom_class4              = 'd2457    ;
reg     [12-1:0]    acc_aom_class5              = 'd2866    ;
reg     [12-1:0]    acc_aom_class6              = 'd3276    ;
reg     [12-1:0]    acc_aom_class7              = 'd4095    ;

reg                 aom_trig_protect            = 'd1       ;
reg     [32-1:0]    aom_continuous_trig_thre    = 'd1000  ;
reg     [32-1:0]    aom_integral_trig_thre      = 'd3300 ;
reg     [12-1:0]    aom_trig_vol_thre           = 'd1228    ;


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

laser_aom_ctrl #(
    .TCQ ( TCQ ))
 u_laser_aom_ctrl (
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
    .acc_job_init_switch_i          ( acc_job_init_switch           ),
    .acc_job_init_vol_trig_i        ( acc_job_init_vol_trig         ),
    .acc_job_init_vol_i             ( acc_job_init_vol              ),
    .acc_aom_flag_i                 ( acc_aom_flag                  ),
    .acc_aom_class0_i               ( acc_aom_class0                ),
    .acc_aom_class1_i               ( acc_aom_class1                ),
    .acc_aom_class2_i               ( acc_aom_class2                ),
    .acc_aom_class3_i               ( acc_aom_class3                ),
    .acc_aom_class4_i               ( acc_aom_class4                ),
    .acc_aom_class5_i               ( acc_aom_class5                ),
    .acc_aom_class6_i               ( acc_aom_class6                ),
    .acc_aom_class7_i               ( acc_aom_class7                ),

    .aom_continuous_trig_err_i      ( aom_continuous_trig_err       ),
    .aom_integral_trig_err_i        ( aom_integral_trig_err         ),

    .LASER_CONTROL                  ( LASER_CONTROL                 ),
    .LASER_OUT_SWITCH               ( LASER_OUT_SWITCH              ),
    .laser_aom_en_o                 ( laser_aom_en                  ),
    .laser_aom_voltage_o            ( laser_aom_voltage             )
);

aom_trig_overload aom_trig_overload_inst(
    // clk & rst
    .clk_i                          ( clk_i                         ),
    .rst_i                          ( rst_i                         ),
    
    // interface    
    .laser_control_i                ( LASER_CONTROL                 ),
    .laser_out_switch_i             ( LASER_OUT_SWITCH              ),
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

ad5445_config ad5445_config_inst(
    .clk                            ( clk_i                         ),  //100M
    .rst                            ( rst_i                         ),
    .dac_out_en                     ( laser_aom_en                  ),
    .dac_out                        ( laser_aom_voltage             ),  //外部vio输入，范囿0~4095

    .rw_ctr                         ( AD5445_R_Wn                   ),
    .cs_n                           ( AD5445_CSn                    ),
    .d_bit                          ( AD5445_DB                     )
);

initial
begin
    // #1000;
    // laser_control   = 0;
    // #1000;
    // laser_out_switch = 1;
    // #10000;
    // laser_analog_mode_sel = 1;
    // #10000;
    // laser_analog_trigger = 1;
    // #10;
    // laser_analog_trigger = 0;
    // #10;

    // #1000;
    // laser_analog_trigger = 1;
    // #10;
    // laser_analog_trigger = 0;
    // #10;
    
    // #1000;
    // laser_analog_trigger = 1;
    // #10;
    // laser_analog_trigger = 0;
    // #10;
    // $finish;

    #1000;

    laser_control   = 0;
    acc_job_control = 1;

    #1000;
    acc_aom_flag = 1;
    #5000;
    acc_aom_flag = 0;
    #1000;
    acc_aom_flag = 1;
    #1000;
    acc_aom_flag = 0;
    #1000;
    acc_aom_flag = 1;
    #5000;
    acc_aom_flag = 0;
    #1000;
    acc_aom_flag = 1;
    #1000;
    acc_aom_flag = 0;
    #1000;

    acc_job_control = 0;

    acc_aom_flag = 1;
    #100000;
    $finish;
end

endmodule