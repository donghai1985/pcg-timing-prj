//~ `New testbench
`timescale  1ns / 1ps

module tb_mfpga_top;

// mfpga_top Parameters
parameter PERIOD  = 10;


// mfpga_top Inputs
reg   FPGA_RESET                           = 1 ;
reg   USER_SMA_CLOCK                       = 0 ;
reg   FPGA_MASTER_CLOCK_P                  = 1 ;
reg   FPGA_MASTER_CLOCK_N                  = 0 ;
reg   FPGA_SSD1_ALERT_B                    = 0 ;
reg   FPGA_SSD1_CLKREQ_B                   = 0 ;
reg   FPGA_SSD1_PEWAKE_B                   = 0 ;
reg   HMC7044_GPIO1                        = 0 ;
reg   HMC7044_GPIO2                        = 0 ;
reg   SFP_MGT_REFCLK1_C_P                  = 0 ;
reg   SFP_MGT_REFCLK1_C_N                  = 0 ;
reg   FPGA_SFP2_RX_P                       = 0 ;
reg   FPGA_SFP2_RX_N                       = 0 ;
reg   FPGA_SFP2_TX_FAULT                   = 0 ;
reg   FPGA_SFP2_MOD_DETECT                 = 0 ;
reg   FPGA_SFP2_LOS                        = 0 ;
reg   [3:0]  EDS_DATA_P                    = 0 ;
reg   [3:0]  EDS_DATA_N                    = 0 ;
reg   EDS_CC1_P                            = 0 ;
reg   EDS_CC1_N                            = 0 ;
reg   EDS_CC2_P                            = 0 ;
reg   EDS_CC2_N                            = 0 ;
reg   EDS_CC3_P                            = 0 ;
reg   EDS_CC3_N                            = 0 ;
reg   EDS_CC4_P                            = 0 ;
reg   EDS_CC4_N                            = 0 ;
reg   BPSi_DATA2_P                         = 0 ;
reg   BPSi_DATA2_N                         = 0 ;
reg   BPSi_DATA3_P                         = 0 ;
reg   BPSi_DATA3_N                         = 0 ;
reg   RF_FPS_TRIGGER_2_P                   = 0 ;
reg   RF_FPS_TRIGGER_2_N                   = 0 ;
reg   RF_MOD_IN_FIXED_2_P                  = 0 ;
reg   RF_MOD_IN_FIXED_2_N                  = 0 ;
reg   RF_MOD_IN_VARIABLE_2_P               = 0 ;
reg   RF_MOD_IN_VARIABLE_2_N               = 0 ;
reg   AD7680_SDATA_LS                      = 0 ;
reg   EEPROM_SO                            = 0 ;
reg   TMP75_ALERT                          = 0 ;
reg   DDR_POWER_GOOD                       = 0 ;
reg   VCC9V_PG                             = 0 ;
reg   VCC3V3_PG                            = 0 ;
reg   MGTAVTT_PG                           = 0 ;
reg   VCC1V5_MGT_PG                        = 0 ;
reg   VCC3V6_PG                            = 0 ;
reg   VCC3V3_C_PG                          = 0 ;
reg   VCC5V_PG                             = 0 ;
reg   VCC__5V5_A_PG                        = 0 ;
reg   FAN_FG                               = 0 ;
reg   AD5592_1_SPI_MISO                    = 0 ;
reg   AD5592_2_SPI_MISO                    = 0 ;
reg   DSP_SYSCLKOUT_FPGA                   = 0 ;
reg   DSP_MCBSP0_TXCLK                     = 0 ;
reg   DSP_MCBSP0_FST                       = 0 ;
reg   DSP_MCBSP0_TX                        = 0 ;
reg   DSP_RESETSTAT_n                      = 0 ;
reg   FPGA_TO_SFPGA_RESERVE0               = 0 ;
reg   FPGA_TO_SFPGA_RESERVE1               = 0 ;
reg   FPGA_TO_SFPGA_RESERVE2               = 0 ;
reg   FPGA_TO_SFPGA_RESERVE6               = 0 ;
reg   FPGA_TO_SFPGA_RESERVE7               = 0 ;
reg   FPGA_TO_SFPGA_RESERVE8               = 0 ;
reg   FPGA_TO_SFPGA_RESERVE9               = 0 ;

// mfpga_top Outputs
wire  FPGA_SSD1_DEVSLP                     ;
wire  FPGA_SSD1_SMB_CLK                    ;
wire  FPGA_SSD1_PERST_B                    ;
wire  HMC7044_SYNC                         ;
wire  HMC7044_RESET                        ;
wire  HMC7044_SLEN                         ;
wire  HMC7044_SCLK                         ;
wire  FPGA_SFP2_TX_P                       ;
wire  FPGA_SFP2_TX_N                       ;
wire  FPGA_SFP2_TX_DISABLE                 ;
wire  FPGA_SFP2_IIC_SCL                    ;
wire  EDS_CLK_P                            ;
wire  EDS_CLK_N                            ;
wire  EDS_TC_P                             ;
wire  EDS_TC_N                             ;
wire  EDS_TFG_P                            ;
wire  EDS_TFG_N                            ;
wire  BPSi_CLK_P                           ;
wire  BPSi_CLK_N                           ;
wire  BPSi_DATA0_P                         ;
wire  BPSi_DATA0_N                         ;
wire  BPSi_DATA1_P                         ;
wire  BPSi_DATA1_N                         ;
wire  TIMING_SPI_CLK_2_P                   ;
wire  TIMING_SPI_CLK_2_N                   ;
wire  TIMING_SPI_CSN_2_P                   ;
wire  TIMING_SPI_CSN_2_N                   ;
wire  TIMING_SPI_MOSI_2_P                  ;
wire  TIMING_SPI_MOSI_2_N                  ;
wire  MAX5216_CLK_LS                       ;
wire  MAX5216_DIN_LS                       ;
wire  MAX5216_CS_LS                        ;
wire  MAX5216_CLR_LS                       ;
wire  AD7680_SCLK_LS                       ;
wire  AD7680_CS_LS                         ;
wire  EEPROM_CS_B                          ;
wire  EEPROM_SI                            ;
wire  EEPROM_WP_B                          ;
wire  EEPROM_SCK                           ;
wire  TMP75_IIC_SCL                        ;
wire  VCC3V3_DSP_SSD_EN                    ;
wire  VCC3V3_FPGA_SSD_EN                   ;
wire  VCC12V_FAN_EN                        ;
wire  [7:0]  DDR3_A_DM                     ;
wire  [15:0]  DDR3_A_ADD                   ;
wire  [2:0]  DDR3_A_BA                     ;
wire  DDR3_A_CKE                           ;
wire  DDR3_A_WE_B                          ;
wire  DDR3_A_RAS_B                         ;
wire  DDR3_A_CAS_B                         ;
wire  DDR3_A_S0_B                          ;
wire  DDR3_A_ODT                           ;
wire  DDR3_A_RESET_B                       ;
wire  DDR3_A_CLK0_P                        ;
wire  DDR3_A_CLK0_N                        ;
wire  AD5592_1_SPI_CS_B                    ;
wire  AD5592_1_SPI_CLK                     ;
wire  AD5592_1_SPI_MOSI                    ;
wire  AD5592_2_SPI_CS_B                    ;
wire  AD5592_2_SPI_CLK                     ;
wire  AD5592_2_SPI_MOSI                    ;
wire  DSP_MCBSP0_SLCLK                     ;
wire  DSP_MCBSP0_RXCLK                     ;
wire  DSP_MCBSP0_FSR                       ;
wire  DSP_MCBSP0_RX                        ;
wire  DSP_NMIZ                             ;
wire  DSP_RSTFULL                          ;
wire  DSP_RESETZ                           ;
wire  DSP_SYS_NRESET                       ;
wire  FPGA_TO_SFPGA_RESERVE3               ;
wire  FPGA_TO_SFPGA_RESERVE4               ;
wire  FPGA_TO_SFPGA_RESERVE5               ;
wire  TP102                                ;
wire  TP103                                ;
wire  TP104                                ;
wire  TP105                                ;
wire  TP106                                ;
wire  TP110                                ;
wire  TP111                                ;
wire  TP112                                ;
wire  TP113                                ;
wire  TP114                                ;
wire  TP115                                ;
wire  TP117                                ;
wire  TP119                                ;
wire  TP121                                ;

// mfpga_top Bidirs
wire  FPGA_SSD1_SMB_DATA                   ;
wire  HMC7044_SDATA                        ;
wire  FPGA_SFP2_IIC_SDA                    ;
wire  TMP75_IIC_SDA                        ;
wire  [63:0]  DDR3_A_D                     ;
wire  [7:0]  DDR3_A_DQS_P                  ;
wire  [7:0]  DDR3_A_DQS_N                  ;


initial
begin
    forever #(PERIOD/2)  FPGA_MASTER_CLOCK_P=~FPGA_MASTER_CLOCK_P;
end
initial
begin
    forever #(PERIOD/2)  FPGA_MASTER_CLOCK_N=~FPGA_MASTER_CLOCK_N;
end

initial
begin
    #(PERIOD*2) FPGA_RESET  =  0;
end

mfpga_top  u_mfpga_top (
    .FPGA_RESET              ( FPGA_RESET                     ),
    .USER_SMA_CLOCK          ( USER_SMA_CLOCK                 ),
    .FPGA_MASTER_CLOCK_P     ( FPGA_MASTER_CLOCK_P            ),
    .FPGA_MASTER_CLOCK_N     ( FPGA_MASTER_CLOCK_N            ),
    .FPGA_SSD1_ALERT_B       ( FPGA_SSD1_ALERT_B              ),
    .FPGA_SSD1_CLKREQ_B      ( FPGA_SSD1_CLKREQ_B             ),
    .FPGA_SSD1_PEWAKE_B      ( FPGA_SSD1_PEWAKE_B             ),
    .HMC7044_GPIO1           ( HMC7044_GPIO1                  ),
    .HMC7044_GPIO2           ( HMC7044_GPIO2                  ),
    .SFP_MGT_REFCLK1_C_P     ( SFP_MGT_REFCLK1_C_P            ),
    .SFP_MGT_REFCLK1_C_N     ( SFP_MGT_REFCLK1_C_N            ),
    .FPGA_SFP2_RX_P          ( FPGA_SFP2_RX_P                 ),
    .FPGA_SFP2_RX_N          ( FPGA_SFP2_RX_N                 ),
    .FPGA_SFP2_TX_FAULT      ( FPGA_SFP2_TX_FAULT             ),
    .FPGA_SFP2_MOD_DETECT    ( FPGA_SFP2_MOD_DETECT           ),
    .FPGA_SFP2_LOS           ( FPGA_SFP2_LOS                  ),
    .EDS_DATA_P              ( EDS_DATA_P              [3:0]  ),
    .EDS_DATA_N              ( EDS_DATA_N              [3:0]  ),
    .EDS_CC1_P               ( EDS_CC1_P                      ),
    .EDS_CC1_N               ( EDS_CC1_N                      ),
    .EDS_CC2_P               ( EDS_CC2_P                      ),
    .EDS_CC2_N               ( EDS_CC2_N                      ),
    .EDS_CC3_P               ( EDS_CC3_P                      ),
    .EDS_CC3_N               ( EDS_CC3_N                      ),
    .EDS_CC4_P               ( EDS_CC4_P                      ),
    .EDS_CC4_N               ( EDS_CC4_N                      ),
    .BPSi_DATA2_P            ( BPSi_DATA2_P                   ),
    .BPSi_DATA2_N            ( BPSi_DATA2_N                   ),
    .BPSi_DATA3_P            ( BPSi_DATA3_P                   ),
    .BPSi_DATA3_N            ( BPSi_DATA3_N                   ),
    .RF_FPS_TRIGGER_2_P      ( RF_FPS_TRIGGER_2_P             ),
    .RF_FPS_TRIGGER_2_N      ( RF_FPS_TRIGGER_2_N             ),
    .RF_MOD_IN_FIXED_2_P     ( RF_MOD_IN_FIXED_2_P            ),
    .RF_MOD_IN_FIXED_2_N     ( RF_MOD_IN_FIXED_2_N            ),
    .RF_MOD_IN_VARIABLE_2_P  ( RF_MOD_IN_VARIABLE_2_P         ),
    .RF_MOD_IN_VARIABLE_2_N  ( RF_MOD_IN_VARIABLE_2_N         ),
    .AD7680_SDATA_LS         ( AD7680_SDATA_LS                ),
    .EEPROM_SO               ( EEPROM_SO                      ),
    .TMP75_ALERT             ( TMP75_ALERT                    ),
    .DDR_POWER_GOOD          ( DDR_POWER_GOOD                 ),
    .VCC9V_PG                ( VCC9V_PG                       ),
    .VCC3V3_PG               ( VCC3V3_PG                      ),
    .MGTAVTT_PG              ( MGTAVTT_PG                     ),
    .VCC1V5_MGT_PG           ( VCC1V5_MGT_PG                  ),
    .VCC3V6_PG               ( VCC3V6_PG                      ),
    .VCC3V3_C_PG             ( VCC3V3_C_PG                    ),
    .VCC5V_PG                ( VCC5V_PG                       ),
    .VCC__5V5_A_PG           ( VCC__5V5_A_PG                  ),
    .FAN_FG                  ( FAN_FG                         ),
    .AD5592_1_SPI_MISO       ( AD5592_1_SPI_MISO              ),
    .AD5592_2_SPI_MISO       ( AD5592_2_SPI_MISO              ),
    .DSP_SYSCLKOUT_FPGA      ( DSP_SYSCLKOUT_FPGA             ),
    .DSP_MCBSP0_TXCLK        ( DSP_MCBSP0_TXCLK               ),
    .DSP_MCBSP0_FST          ( DSP_MCBSP0_FST                 ),
    .DSP_MCBSP0_TX           ( DSP_MCBSP0_TX                  ),
    .DSP_RESETSTAT_n         ( DSP_RESETSTAT_n                ),
    .FPGA_TO_SFPGA_RESERVE0  ( FPGA_TO_SFPGA_RESERVE0         ),
    .FPGA_TO_SFPGA_RESERVE1  ( FPGA_TO_SFPGA_RESERVE1         ),
    .FPGA_TO_SFPGA_RESERVE2  ( FPGA_TO_SFPGA_RESERVE2         ),
    .FPGA_TO_SFPGA_RESERVE6  ( FPGA_TO_SFPGA_RESERVE6         ),
    .FPGA_TO_SFPGA_RESERVE7  ( FPGA_TO_SFPGA_RESERVE7         ),
    .FPGA_TO_SFPGA_RESERVE8  ( FPGA_TO_SFPGA_RESERVE8         ),
    .FPGA_TO_SFPGA_RESERVE9  ( FPGA_TO_SFPGA_RESERVE9         ),

    .FPGA_SSD1_DEVSLP        ( FPGA_SSD1_DEVSLP               ),
    .FPGA_SSD1_SMB_CLK       ( FPGA_SSD1_SMB_CLK              ),
    .FPGA_SSD1_PERST_B       ( FPGA_SSD1_PERST_B              ),
    .HMC7044_SYNC            ( HMC7044_SYNC                   ),
    .HMC7044_RESET           ( HMC7044_RESET                  ),
    .HMC7044_SLEN            ( HMC7044_SLEN                   ),
    .HMC7044_SCLK            ( HMC7044_SCLK                   ),
    .FPGA_SFP2_TX_P          ( FPGA_SFP2_TX_P                 ),
    .FPGA_SFP2_TX_N          ( FPGA_SFP2_TX_N                 ),
    .FPGA_SFP2_TX_DISABLE    ( FPGA_SFP2_TX_DISABLE           ),
    .FPGA_SFP2_IIC_SCL       ( FPGA_SFP2_IIC_SCL              ),
    .EDS_CLK_P               ( EDS_CLK_P                      ),
    .EDS_CLK_N               ( EDS_CLK_N                      ),
    .EDS_TC_P                ( EDS_TC_P                       ),
    .EDS_TC_N                ( EDS_TC_N                       ),
    .EDS_TFG_P               ( EDS_TFG_P                      ),
    .EDS_TFG_N               ( EDS_TFG_N                      ),
    .BPSi_CLK_P              ( BPSi_CLK_P                     ),
    .BPSi_CLK_N              ( BPSi_CLK_N                     ),
    .BPSi_DATA0_P            ( BPSi_DATA0_P                   ),
    .BPSi_DATA0_N            ( BPSi_DATA0_N                   ),
    .BPSi_DATA1_P            ( BPSi_DATA1_P                   ),
    .BPSi_DATA1_N            ( BPSi_DATA1_N                   ),
    .TIMING_SPI_CLK_2_P      ( TIMING_SPI_CLK_2_P             ),
    .TIMING_SPI_CLK_2_N      ( TIMING_SPI_CLK_2_N             ),
    .TIMING_SPI_CSN_2_P      ( TIMING_SPI_CSN_2_P             ),
    .TIMING_SPI_CSN_2_N      ( TIMING_SPI_CSN_2_N             ),
    .TIMING_SPI_MOSI_2_P     ( TIMING_SPI_MOSI_2_P            ),
    .TIMING_SPI_MOSI_2_N     ( TIMING_SPI_MOSI_2_N            ),
    .MAX5216_CLK_LS          ( MAX5216_CLK_LS                 ),
    .MAX5216_DIN_LS          ( MAX5216_DIN_LS                 ),
    .MAX5216_CS_LS           ( MAX5216_CS_LS                  ),
    .MAX5216_CLR_LS          ( MAX5216_CLR_LS                 ),
    .AD7680_SCLK_LS          ( AD7680_SCLK_LS                 ),
    .AD7680_CS_LS            ( AD7680_CS_LS                   ),
    .EEPROM_CS_B             ( EEPROM_CS_B                    ),
    .EEPROM_SI               ( EEPROM_SI                      ),
    .EEPROM_WP_B             ( EEPROM_WP_B                    ),
    .EEPROM_SCK              ( EEPROM_SCK                     ),
    .TMP75_IIC_SCL           ( TMP75_IIC_SCL                  ),
    .VCC3V3_DSP_SSD_EN       ( VCC3V3_DSP_SSD_EN              ),
    .VCC3V3_FPGA_SSD_EN      ( VCC3V3_FPGA_SSD_EN             ),
    .VCC12V_FAN_EN           ( VCC12V_FAN_EN                  ),
    .DDR3_A_DM               ( DDR3_A_DM               [7:0]  ),
    .DDR3_A_ADD              ( DDR3_A_ADD              [15:0] ),
    .DDR3_A_BA               ( DDR3_A_BA               [2:0]  ),
    .DDR3_A_CKE              ( DDR3_A_CKE                     ),
    .DDR3_A_WE_B             ( DDR3_A_WE_B                    ),
    .DDR3_A_RAS_B            ( DDR3_A_RAS_B                   ),
    .DDR3_A_CAS_B            ( DDR3_A_CAS_B                   ),
    .DDR3_A_S0_B             ( DDR3_A_S0_B                    ),
    .DDR3_A_ODT              ( DDR3_A_ODT                     ),
    .DDR3_A_RESET_B          ( DDR3_A_RESET_B                 ),
    .DDR3_A_CLK0_P           ( DDR3_A_CLK0_P                  ),
    .DDR3_A_CLK0_N           ( DDR3_A_CLK0_N                  ),
    .AD5592_1_SPI_CS_B       ( AD5592_1_SPI_CS_B              ),
    .AD5592_1_SPI_CLK        ( AD5592_1_SPI_CLK               ),
    .AD5592_1_SPI_MOSI       ( AD5592_1_SPI_MOSI              ),
    .AD5592_2_SPI_CS_B       ( AD5592_2_SPI_CS_B              ),
    .AD5592_2_SPI_CLK        ( AD5592_2_SPI_CLK               ),
    .AD5592_2_SPI_MOSI       ( AD5592_2_SPI_MOSI              ),
    .DSP_MCBSP0_SLCLK        ( DSP_MCBSP0_SLCLK               ),
    .DSP_MCBSP0_RXCLK        ( DSP_MCBSP0_RXCLK               ),
    .DSP_MCBSP0_FSR          ( DSP_MCBSP0_FSR                 ),
    .DSP_MCBSP0_RX           ( DSP_MCBSP0_RX                  ),
    .DSP_NMIZ                ( DSP_NMIZ                       ),
    .DSP_RSTFULL             ( DSP_RSTFULL                    ),
    .DSP_RESETZ              ( DSP_RESETZ                     ),
    .DSP_SYS_NRESET          ( DSP_SYS_NRESET                 ),
    .FPGA_TO_SFPGA_RESERVE3  ( FPGA_TO_SFPGA_RESERVE3         ),
    .FPGA_TO_SFPGA_RESERVE4  ( FPGA_TO_SFPGA_RESERVE4         ),
    .FPGA_TO_SFPGA_RESERVE5  ( FPGA_TO_SFPGA_RESERVE5         ),
    .TP102                   ( TP102                          ),
    .TP103                   ( TP103                          ),
    .TP104                   ( TP104                          ),
    .TP105                   ( TP105                          ),
    .TP106                   ( TP106                          ),
    .TP110                   ( TP110                          ),
    .TP111                   ( TP111                          ),
    .TP112                   ( TP112                          ),
    .TP113                   ( TP113                          ),
    .TP114                   ( TP114                          ),
    .TP115                   ( TP115                          ),
    .TP117                   ( TP117                          ),
    .TP119                   ( TP119                          ),
    .TP121                   ( TP121                          ),

    .FPGA_SSD1_SMB_DATA      ( FPGA_SSD1_SMB_DATA             ),
    .HMC7044_SDATA           ( HMC7044_SDATA                  ),
    .FPGA_SFP2_IIC_SDA       ( FPGA_SFP2_IIC_SDA              ),
    .TMP75_IIC_SDA           ( TMP75_IIC_SDA                  ),
    .DDR3_A_D                ( DDR3_A_D                [63:0] ),
    .DDR3_A_DQS_P            ( DDR3_A_DQS_P            [7:0]  ),
    .DDR3_A_DQS_N            ( DDR3_A_DQS_N            [7:0]  )
);





wire                    eth_rec_pkt_done_task        ;
wire                    eth_rec_en_task              ;
wire [7:0]              eth_rec_data_task            ;
wire                    eth_rec_byte_num_en_task     ;
wire [15:0]             eth_rec_byte_num_task        ;

// register_ctrl('h0125,'h0000_0005);
// register_ctrl('h0200,'h0000_0125);


task register_ctrl(
    input               clk_100m                    ,
    input   [16-1:0]    register_addr               ,
    input   [32-1:0]    register_data               ,
    output              eth_rec_en_task             ,
    output  [7:0]       eth_rec_data_task           ,
    output              eth_rec_byte_num_en_task    ,
    output  [15:0]      eth_rec_byte_num_task       
);


begin
    repeat(1) @(posedge clk_100m);
    eth_rec_en_task = 1;
    eth_rec_data_task = 'h00;
    repeat(1) @(posedge clk_100m);
    eth_rec_en_task = 1;
    eth_rec_data_task = 'h00;
    repeat(1) @(posedge clk_100m);
    eth_rec_en_task = 1;
    eth_rec_data_task = register_addr[15:8];
    repeat(1) @(posedge clk_100m);
    eth_rec_en_task = 1;
    eth_rec_data_task = register_addr[7:0];
    repeat(1) @(posedge clk_100m);
    eth_rec_en_task = 1;
    eth_rec_data_task = register_data[3*8 +: 8];
    repeat(1) @(posedge clk_100m);
    eth_rec_en_task = 1;
    eth_rec_data_task = register_data[2*8 +: 8];
    repeat(1) @(posedge clk_100m);
    eth_rec_en_task = 1;
    eth_rec_data_task = register_data[1*8 +: 8];
    repeat(1) @(posedge clk_100m);
    eth_rec_en_task = 1;
    eth_rec_data_task = register_data[0*8 +: 8];
    repeat(1) @(posedge clk_100m);
    eth_rec_en_task = 0;
    eth_rec_byte_num_en_task = 1;
    eth_rec_byte_num_task = 8;
    repeat(1) @(posedge clk_100m);
    eth_rec_byte_num_en_task = 0;
end

endtask



initial
begin

    $finish;
end

endmodule