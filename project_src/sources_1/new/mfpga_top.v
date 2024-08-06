`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/23 17:00:14
// Design Name: 
// Module Name: mfpga_top
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
// `define SIMULATE

module mfpga_top(
		//sys io
		input	wire		FPGA_RESET, 
		input	wire		USER_SMA_CLOCK,
		input	wire		FPGA_MASTER_CLOCK_P,
		input	wire		FPGA_MASTER_CLOCK_N,
		//ssd1
		output	wire		FPGA_SSD1_DEVSLP, 
		output	wire		FPGA_SSD1_SMB_CLK, 
		inout	wire		FPGA_SSD1_SMB_DATA, 
		input	wire		FPGA_SSD1_ALERT_B, 
		output	wire		FPGA_SSD1_PERST_B, 
		input	wire		FPGA_SSD1_CLKREQ_B, 
		input	wire		FPGA_SSD1_PEWAKE_B, 
		//
		output	wire		HMC7044_SYNC,
		output	wire		HMC7044_RESET, 
		output	wire		HMC7044_SLEN, 
		output	wire		HMC7044_SCLK, 
		inout	wire		HMC7044_SDATA, 
		input	wire		HMC7044_GPIO1, 
		input	wire		HMC7044_GPIO2, 
		//dsp srio
		// input	wire		SRIO_MGT_REFCLK_C_P, 
		// input	wire		SRIO_MGT_REFCLK_C_N, 
		// output	wire [1:0]	DSP_FPGA_SRIO_RX_P, 
		// output	wire [1:0]	DSP_FPGA_SRIO_RX_N, 
		// input	wire [1:0]	DSP_FPGA_SRIO_TX_P, 
		// input	wire [1:0]	DSP_FPGA_SRIO_TX_N, 
		//ssd1 serdes
		// input	wire		FPGA_SSD1_PCIE_MGTREFCLK0_C_P, 
		// input	wire		FPGA_SSD1_PCIE_MGTREFCLK0_C_N, 
		// input	wire [3:0]	FPGA_SSD1_PCIE_RX_P,
		// input	wire [3:0]	FPGA_SSD1_PCIE_RX_N,
		// output	wire [3:0]	FPGA_SSD1_PCIE_TX_P,
		// output	wire [3:0]	FPGA_SSD1_PCIE_TX_N,
		//sfp serdes
		input	wire		SFP_MGT_REFCLK0_C_P, 
		input	wire		SFP_MGT_REFCLK0_C_N, 
		input	wire 		FPGA_SFP1_RX_P, 
		input	wire 		FPGA_SFP1_RX_N,  
		output	wire 		FPGA_SFP1_TX_P, 
		output	wire 		FPGA_SFP1_TX_N, 
		// input	wire 		FPGA_SFP4_RX_P, 
		// input	wire 		FPGA_SFP4_RX_N,  
		// output	wire 		FPGA_SFP4_TX_P, 
		// output	wire 		FPGA_SFP4_TX_N, 
		input	wire		SFP_MGT_REFCLK1_C_P, 
		input	wire		SFP_MGT_REFCLK1_C_N, 
		input	wire 		FPGA_SFP2_RX_P, 
		input	wire 		FPGA_SFP2_RX_N,  
		output	wire 		FPGA_SFP2_TX_P, 
		output	wire 		FPGA_SFP2_TX_N, 
		input	wire 		FPGA_SFP3_RX_P, 
		input	wire 		FPGA_SFP3_RX_N,  
		output	wire 		FPGA_SFP3_TX_P, 
		output	wire 		FPGA_SFP3_TX_N, 
		//sfp1 io
		input	wire		FPGA_SFP1_TX_FAULT, 
		output	wire		FPGA_SFP1_TX_DISABLE, 
		input	wire		FPGA_SFP1_MOD_DETECT, 
		input	wire		FPGA_SFP1_LOS, 
		output	wire		FPGA_SFP1_IIC_SCL, 
		inout	wire		FPGA_SFP1_IIC_SDA, 
		//sfp2 io
		input	wire		FPGA_SFP2_TX_FAULT, 
		output	wire		FPGA_SFP2_TX_DISABLE, 
		input	wire		FPGA_SFP2_MOD_DETECT, 
		input	wire		FPGA_SFP2_LOS, 
        output	wire		FPGA_SFP2_IIC_SCL,
		inout	wire		FPGA_SFP2_IIC_SDA, 
		//sfp3 io
		input	wire		FPGA_SFP3_TX_FAULT, 
		output	wire		FPGA_SFP3_TX_DISABLE, 
		input	wire		FPGA_SFP3_MOD_DETECT, 
		input	wire		FPGA_SFP3_LOS, 
		output	wire		FPGA_SFP3_IIC_SCL, 
		inout	wire		FPGA_SFP3_IIC_SDA, 
		//sfp4 io
		// input	wire		FPGA_SFP4_TX_FAULT, 
		// output	wire		FPGA_SFP4_TX_DISABLE, 
		// input	wire		FPGA_SFP4_MOD_DETECT, 
		// input	wire		FPGA_SFP4_LOS, 
        // output	wire		FPGA_SFP4_IIC_SCL,
		// inout	wire		FPGA_SFP4_IIC_SDA, 
		//EDS
		output	wire		EDS_CLK_P,
		output	wire		EDS_CLK_N,
		input	wire [3:0]	EDS_DATA_P,
		input	wire [3:0]	EDS_DATA_N,
		output	wire		EDS_TC_P,
		output	wire		EDS_TC_N,
		output	wire		EDS_TFG_P,
		output	wire		EDS_TFG_N,
		input	wire		EDS_CC1_P,
		input	wire		EDS_CC1_N,
		input	wire		EDS_CC2_P,
		input	wire		EDS_CC2_N,
		input	wire		EDS_CC3_P,
		input	wire		EDS_CC3_N,
		input	wire		EDS_CC4_P,
		input	wire		EDS_CC4_N,
		//BPSr1
		output	wire		BPSr1_CLK_P,
		output	wire		BPSr1_CLK_N, 
		output	wire		BPSr1_MCLK_P,
		output	wire		BPSr1_MCLK_N,
		output	wire		BPSr1_MOSI_P,
		output	wire		BPSr1_MOSI_N,
		input	wire		BPSr1_SCLK_P,
		input	wire		BPSr1_SCLK_N,
		input	wire		BPSr1_MISO_P,
		input	wire		BPSr1_MISO_N,
		//BPSr2
		output	wire		BPSr2_CLK_P,
		output	wire		BPSr2_CLK_N, 
		output	wire		BPSr2_MCLK_P,
		output	wire		BPSr2_MCLK_N,
		output	wire		BPSr2_MOSI_P,
		output	wire		BPSr2_MOSI_N,
		input	wire		BPSr2_SCLK_P,
		input	wire		BPSr2_SCLK_N,
		input	wire		BPSr2_MISO_P,
		input	wire		BPSr2_MISO_N,
		//BPSi
		output	wire		BPSi_CLK_P,
		output	wire		BPSi_CLK_N, 
		output	wire		BPSi_MCLK_P,
		output	wire		BPSi_MCLK_N,
		output	wire		BPSi_MOSI_P,
		output	wire		BPSi_MOSI_N,
		input	wire		BPSi_SCLK_P,
		input	wire		BPSi_SCLK_N,
		input	wire		BPSi_MISO_P,
		input	wire		BPSi_MISO_N,
		// PMT SPI 
        output  wire  [3:1] IO_ENCODE_SPI_MCLK_P,
        output  wire  [3:1] IO_ENCODE_SPI_MCLK_N,
        output  wire  [3:1] IO_ENCODE_SPI_MOSI_P,
        output  wire  [3:1] IO_ENCODE_SPI_MOSI_N,
        
        output  wire  [3:1] IO_PMT_SPI_MCLK_P,   // timing_pmt_spi
        output  wire  [3:1] IO_PMT_SPI_MCLK_N,   // timing_pmt_spi
        output  wire  [3:1] IO_PMT_SPI_MOSI_P,   // timing_pmt_spi
        output  wire  [3:1] IO_PMT_SPI_MOSI_N,   // timing_pmt_spi
        input   wire  [3:1] IO_PMT_SPI_SCLK_P,   // timing_pmt_spi
        input   wire  [3:1] IO_PMT_SPI_SCLK_N,   // timing_pmt_spi
        input   wire  [3:1] IO_PMT_SPI_MISO_P,   // timing_pmt_spi
        input   wire  [3:1] IO_PMT_SPI_MISO_N,   // timing_pmt_spi
        
        input   wire  [3:1] IO_ACC_SPI_SCLK_P,
        input   wire  [3:1] IO_ACC_SPI_SCLK_N,
        input   wire  [3:1] IO_ACC_SPI_MISO_P,
        input   wire  [3:1] IO_ACC_SPI_MISO_N,

        // output  wire        RF_Mod_in_variable_LS   ,
        output  wire        RF_Enable_LS            ,
        // output  wire        RF_fault_LS             ,
        // output  wire        RF_ready_LS             ,
        output  wire        RF_emission_LS          ,
        // output  wire        RF_SYNC_LS              ,
		output	wire		UART_TX,
		input	wire		UART_RX,
		//AD5445
		output	wire		AD5445_R_Wn,
		output	wire		AD5445_CSn,
		output	wire [11:0]	AD5445_DB,
		//MAX5216
		output	wire		MAX5216_CLK_LS,
		output	wire		MAX5216_DIN_LS,
		output	wire		MAX5216_CS_LS,
		output	wire		MAX5216_CLR_LS,
		//AD7680
		output	wire		AD7680_SCLK_LS,
		output	wire		AD7680_CS_LS,
		input	wire		AD7680_SDATA_LS,
		//LAN A
/*		output	wire		LAN_A_RESET_B,
		input	wire		LAN_A_TXCLK,
		output	wire		LAN_A_TXEN,
		output	wire [3:0]	LAN_A_TX
		input	wire		LAN_A_RXCLK,
		input	wire		LAN_A_RXDV,
		input	wire [3:0]	LAN_A_RX,
		input	wire		LAN_A_RXER,
		output	wire		LAN_A_MDC,
		inout	wire		LAN_A_MDIO,
		input	wire		LAN_A_CRS,
		input	wire		LAN_A_COL,
		//LAN B
		output	wire		LAN_B_RESET_B,
		input	wire		LAN_B_TXCLK,
		output	wire		LAN_B_TXEN,
		output	wire [3:0]	LAN_B_TX
		input	wire		LAN_B_RXCLK,
		input	wire		LAN_B_RXDV,
		input	wire [3:0]	LAN_B_RX,
		input	wire		LAN_B_RXER,
		output	wire		LAN_B_MDC,
		inout	wire		LAN_B_MDIO,
		input	wire		LAN_B_CRS,
		input	wire		LAN_B_COL,*/
		//X_Encoder
		input	wire		X_Encoder_A_IN_LS,
		input	wire		X_Encoder_B_IN_LS,
		input	wire		X_Encoder_Z_IN_LS,
		output	wire		X_Encoder_A_OUT,
		output	wire		X_Encoder_B_OUT,
		output	wire		X_Encoder_Z_OUT,
		//W_Encoder
		input	wire		W_Encoder_MA_IN_LS,
		input	wire		W_Encoder_SLO_IN_LS,
		output	wire		W_Encoder_MA_OUT,
		output	wire		W_Encoder_SLO_OUT,
		//Z_Encoder
		// input	wire		Z_Encoder_A_IN_LS,
		// input	wire		Z_Encoder_B_IN_LS,
		// input	wire		Z_Encoder_Z_IN_LS,
		// output	wire		Z_Encoder_A_OUT,
		// output	wire		Z_Encoder_B_OUT,
		// output	wire		Z_Encoder_Z_OUT,
		//Fast_Shutter
		output	wire		Fast_Shutter_in1,
		output	wire		Fast_Shutter_in2,
		output	wire		Fast_Shutter_in3,
		input	wire		Fast_Shutter_out1, 
		input	wire		Fast_Shutter_out2, 
		input	wire		Fast_Shutter_out3, 
		//ACS IO
		input 	wire		ACS_OUT1_LS,
		input	wire		ACS_OUT2_LS,
		output	wire		ACS_IN1,
		output	wire		ACS_IN2,
		//Safety PLC
		output	wire		Safety_in1,
		// output	wire		Safety_in2,
		output	wire		Safety_in3,
		// input	wire		Safety_out1, 
		// input	wire		Safety_out2, 
		// input	wire		Safety_out3, 
		//eeprom 
        // output   wire        EEPROM_CS_B    ,
        // input    wire        EEPROM_SO      ,
        // output   wire        EEPROM_SI      ,
        // output   wire        EEPROM_WP_B    ,
        // output   wire        EEPROM_SCK     ,
		//tmp75
        // inout   wire        TMP75_IIC_SDA   ,
        // output  wire        TMP75_IIC_SCL   ,
        // input   wire        TMP75_ALERT     ,
		//status io
		input	wire		DDR_POWER_GOOD, 
		input	wire		VCC9V_PG, 
		input	wire		VCC3V3_PG, 
		input	wire		MGTAVTT_PG, 
		input	wire		VCC1V5_MGT_PG, 
		input	wire		VCC3V6_PG, 
		input	wire		VCC3V3_C_PG,
		input	wire		VCC5V_PG, 
		input	wire		VCC__5V5_A_PG, 
		//power en
		output	wire		VCC3V3_DSP_SSD_EN,
		output	wire		VCC3V3_FPGA_SSD_EN,
		output	wire		VCC12V_FAN_EN, 
		//ddr3
		inout	wire [63:0]	DDR3_A_D, 
		inout	wire [7:0] 	DDR3_A_DQS_P,
		inout	wire [7:0] 	DDR3_A_DQS_N,
		output	wire [7:0]	DDR3_A_DM,
		output	wire [15:0]	DDR3_A_ADD, 
		output	wire [2:0]	DDR3_A_BA,
		output	wire		DDR3_A_CKE, 
		output	wire		DDR3_A_WE_B, 
		output	wire		DDR3_A_RAS_B, 
		output	wire		DDR3_A_CAS_B, 
		output	wire		DDR3_A_S0_B, 
		output	wire		DDR3_A_ODT, 
		output	wire		DDR3_A_RESET_B,   
		output	wire		DDR3_A_CLK0_P, 
		output	wire		DDR3_A_CLK0_N,
		//fan
		input	wire		FAN_FG, 
		//ad5592
		output	wire		AD5592_1_SPI_CS_B, 
		output	wire		AD5592_1_SPI_CLK, 
		output	wire		AD5592_1_SPI_MOSI, 
		input	wire		AD5592_1_SPI_MISO, 
		output	wire		AD5592_2_SPI_CS_B, 
		output	wire		AD5592_2_SPI_CLK, 
		output	wire		AD5592_2_SPI_MOSI, 
		input	wire		AD5592_2_SPI_MISO, 
		//dsp
		input	wire		DSP_SYSCLKOUT_FPGA, 
		output	wire		DSP_MCBSP0_SLCLK,
		input	wire		DSP_MCBSP0_TXCLK,
		input	wire		DSP_MCBSP0_FST,
		input	wire		DSP_MCBSP0_TX,
		output	wire		DSP_MCBSP0_RXCLK, 
		output	wire		DSP_MCBSP0_FSR, 
		output	wire		DSP_MCBSP0_RX, 
		output	wire		DSP_NMIZ, 
		input	wire		DSP_RESETSTAT_n, 
		output	wire		DSP_RSTFULL, 
		output	wire		DSP_RESETZ, 
		output	wire		DSP_SYS_NRESET, 
		//
		input	wire		FPGA_TO_SFPGA_RESERVE0, 	//clk
		input	wire		FPGA_TO_SFPGA_RESERVE1, 	//fsr
		input	wire		FPGA_TO_SFPGA_RESERVE2, 	//rx
		output	wire		FPGA_TO_SFPGA_RESERVE3,		//fsx	
		output	wire		FPGA_TO_SFPGA_RESERVE4, 	//tx
		output	wire		FPGA_TO_SFPGA_RESERVE5, 	//reserved
		input	wire		FPGA_TO_SFPGA_RESERVE6, 	//reserved 
		input	wire		FPGA_TO_SFPGA_RESERVE7, 	//reserved 
		input	wire		FPGA_TO_SFPGA_RESERVE8, 	//reserved 
		input	wire		FPGA_TO_SFPGA_RESERVE9, 	//reserved
		//test io
		output	wire		TP102,
		output	wire		TP103,
		output	wire		TP104,
		output	wire		TP105,
		output	wire		TP106,
		
		output	wire		TP110,
		output	wire		TP111,
		output	wire		TP112,
		output	wire		TP113,
		output	wire		TP114,
		output	wire		TP115,
		
		output	wire		TP117,
		output	wire		TP119,
		output	wire		TP121
);

genvar  i;
parameter   [8*20-1:0]      VERSION     = "PCG_TimingM_v1.7.0  "; // 新旧timing板为机台级更新，ZP6 alpha & ZP3 beta使用旧板子


wire                slave_tx_ack                    ;
wire                slave_tx_byte_en                ;
wire    [ 7:0]      slave_tx_byte                   ;
wire                slave_tx_byte_num_en            ;
wire    [15:0]      slave_tx_byte_num               ;
wire                slave_rx_data_vld               ;
wire    [ 7:0]      slave_rx_data                   ;

wire    [3-1:0]     pmt_scan_cmd_sel                ;
wire    [4-1:0]     pmt_scan_cmd                    ;
wire    [2:0]       pmt_start_en                    ;
wire    [2:0]       pmt_start_test_en               ;
wire    [2:0]       pcie_pmt_end_en                 ;
wire    [2:0]       aurora_fbc_end                  ;
wire    [2:0]       pmt_master_cmd_parser           ;
wire    [2:0]       rd_ack_timeout_rst              = 'd0;
wire    [32-1:0]    pmt_master_wr_data              ;
wire    [1:0]       pmt_master_wr_vld               ;
wire    [32-1:0]    pmt_master_spi_data             ;
wire                pmt_master_spi_vld              ;
wire    [32-1:0]    pmt_adc_start_data              ;
wire                pmt_adc_start_vld               ;
wire    [32-1:0]    pmt_adc_start_hold              ;
wire                spi_slave_ack_vld   [2:0]       ;
wire                spi_slave_ack_last  [2:0]       ;
wire    [32-1:0]    spi_slave_ack_data  [2:0]       ;

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
wire                clk_100m                        ;
wire                clk_200m                        ;
wire                clk_250m                        ;
wire                clk_50m                         ;
wire                clk_300m                        ;
wire                clk_80m                         ;
wire                clk_div_3                       ;
wire                clk_div_6                       ;
wire                eds_clk                         ;
wire                pll_locked                      ;
wire                pll_2_locked                    ;

wire    [2:0]       ACC_SPI_SCLK                    ;
wire    [2:0]       ACC_SPI_MISO                    ;
wire    [2:0]       acc_pmt_flag_sel                ;

wire    [2:0]       ENCODE_SPI_MCLK                 ;
wire    [2:0]       ENCODE_SPI_MOSI                 ;

wire    [2:0]       PMT_SPI_MCLK                    ;
wire    [2:0]       PMT_SPI_MOSI                    ;
wire    [2:0]       PMT_SPI_SCLK                    ;
wire    [2:0]       PMT_SPI_MISO                    ;

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

wire    [2:0]       ACC_SPI_SCLK_P                  ;
wire    [2:0]       ACC_SPI_SCLK_N                  ;
wire    [2:0]       ACC_SPI_MISO_P                  ;
wire    [2:0]       ACC_SPI_MISO_N                  ;

wire    [2:0]       ENCODE_SPI_MCLK_P               ;
wire    [2:0]       ENCODE_SPI_MCLK_N               ;
wire    [2:0]       ENCODE_SPI_MOSI_P               ;
wire    [2:0]       ENCODE_SPI_MOSI_N               ;

wire    [2:0]       PMT_SPI_MCLK_P                  ;
wire    [2:0]       PMT_SPI_MCLK_N                  ;
wire    [2:0]       PMT_SPI_MOSI_P                  ;
wire    [2:0]       PMT_SPI_MOSI_N                  ;
wire    [2:0]       PMT_SPI_SCLK_P                  ;
wire    [2:0]       PMT_SPI_SCLK_N                  ;
wire    [2:0]       PMT_SPI_MISO_P                  ;
wire    [2:0]       PMT_SPI_MISO_N                  ;
//     // calibrate voltage. dark current * R
// wire                FBCi_cali_en                    ;
// wire    [23:0]      FBCi_cali_a                     ;
// wire    [23:0]      FBCi_cali_b                     ;
// wire                FBCr1_cali_en                   ;
// wire    [23:0]      FBCr1_cali_a                    ;
// wire    [23:0]      FBCr1_cali_b                    ;
// wire                FBCr2_cali_en                   ;
// wire    [23:0]      FBCr2_cali_a                    ;
// wire    [23:0]      FBCr2_cali_b                    ;
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
wire                acc_encode_upload               ;
wire                acc_encode_latch_en             ;
wire    [64-1:0]    acc_encode_latch                ;
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
// wire    [2-1:0]     sensor_ds_rate                  ;
// wire    [2-1:0]     sensor_mode_sel                 ;
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

wire                aurora_log_clk_2                ;
wire                aurora_rst_2                    ;
wire                pcie_eds_frame_end_2            ;
// wire                CHANNEL_UP_DONE_2               ;

wire                aurora_log_clk_3                ;
wire                aurora_rst_3                    ;
wire                pcie_eds_frame_end_3            ;
// wire                CHANNEL_UP_DONE_3               ;
wire    [4-1:0]     aurora_empty_1                  ;
wire    [4-1:0]     aurora_empty_2                  ;
wire    [4-1:0]     aurora_empty_3                  ;
wire                aurora_soft_rd_1                ;
wire                aurora_soft_rd_2                ;
wire                aurora_soft_rd_3                ;
wire    [2-1:0]     cfg_acc_use                     ;
wire                cfg_fbc_rate                    ;
wire                cfg_spindle_width               ;
wire    [2-1:0]     cfg_FBC_bypass                  ;
wire                cfg_QPD_enable                  ;
wire                dbg_qpd_mode                    ;

wire                GT0_refclk1                     ;
wire                GT0_qpllclk_quad1               ;
wire                GT0_qpllrefclk_quad1            ;
wire                GT0_qpllrefclklost              ;
wire                GT0_qplllock                    ;

wire                aurora_log_clk_1                ;
wire                aurora_rst_1                    ;
wire                pcie_eds_frame_end_1            ;
// wire                CHANNEL_UP_DONE_1               ;

// wire                aurora_log_clk_4                ;
// wire                aurora_rst_4                    ;
// wire                pcie_eds_frame_end_4            ;
// wire                CHANNEL_UP_DONE_4               ;

wire                rst_100m                        ;
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
wire                aurora_fbc_almost_full_1        ;
wire                aurora_fbc_almost_full_2        ;
wire                aurora_fbc_almost_full_3        ;

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

// wire                overload_motor_en               ;  
// wire    [15:0]      overload_ufeed_thre             ;
// wire    [31:0]      overload_pid_result             ;

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

// wire                dbg_mem_rd_en                   ;
// wire                dbg_mem_start                   ;
// wire    [2-1:0]     dbg_mem_state                   ;
// wire    [32*5-1:0]  dbg_mem_rd_data                 ;

wire                scan_aurora_reset               ;
wire                aurora_scan_reset               ;
wire    [3-1:0]     aurora_tx_idle                  ;

wire    [32-1:0]    eds_pack_cnt_1                  ;
wire    [32-1:0]    encode_pack_cnt_1               ;
wire    [32-1:0]    eds_pack_cnt_2                  ;
wire    [32-1:0]    encode_pack_cnt_2               ;
wire    [32-1:0]    eds_pack_cnt_3                  ;
wire    [32-1:0]    encode_pack_cnt_3               ;

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
// // test debug code, for check PID fraq
// reg [7:0] delay_pid_trigger_cnt = 'd0;
// reg       delay_pid_trigger_en  = 'd0;
// always @(posedge clk_100m) begin
//     if(motor_rd_en)begin
//         delay_pid_trigger_en <= 'd1;
//     end
//     else if(delay_pid_trigger_cnt >= 'd100)begin
//         delay_pid_trigger_en <= 'd0;
//     end
// end

// always @(posedge clk_100m) begin
//     if(delay_pid_trigger_en)begin
//         delay_pid_trigger_cnt <= delay_pid_trigger_cnt + 1;
//     end
//     else begin
//         delay_pid_trigger_cnt <= 'd0;
//     end
// end

// FPGA ready signal (10Hz) to PLC 
reg [24-1:0]    unit_decis_cnt  = 'd0;
reg             ready_signal    = 'd0;
always @(posedge clk_100m) begin
    if(rst_100m)begin
        unit_decis_cnt  <= 'd0;
        ready_signal    <= 'd0;
    end
    else if(unit_decis_cnt == 'd4_999_999)begin  // 50ms
        unit_decis_cnt  <= 'd0;
        ready_signal    <= ~ready_signal;
    end
    else begin
        unit_decis_cnt  <= unit_decis_cnt + 1;
        ready_signal    <= ready_signal;
    end
end


assign      TP102               = 0;
assign      TP103               = 0;
assign      TP104               = aurora_log_clk_1;
assign      TP105               = aurora_log_clk_2;
assign      TP106               = aurora_log_clk_3;
assign      TP110               = clk_100m;
assign      TP111               = 0;
assign      TP112               = pll_locked;
assign      TP113               = 0;
assign      TP114               = 0;
assign      TP115               = 0;

assign      TP117               = PMT_SPI_SCLK[0];
assign      TP119               = PMT_SPI_SCLK[1];
assign      TP121               = PMT_SPI_SCLK[2];

assign		FPGA_SFP1_TX_DISABLE		=	1'b0; //FPGA_SFP1_MOD_DETECT ? 1'b1 : 1'b0;
assign		FPGA_SFP1_IIC_SCL			=	1'b1;
assign		FPGA_SFP2_TX_DISABLE		=	1'b0; //FPGA_SFP2_MOD_DETECT ? 1'b1 : 1'b0;
assign		FPGA_SFP2_IIC_SCL			=	1'b1;
assign		FPGA_SFP3_TX_DISABLE		=	1'b0; //FPGA_SFP3_MOD_DETECT ? 1'b1 : 1'b0;
assign		FPGA_SFP3_IIC_SCL			=	1'b1;
// assign		FPGA_SFP4_TX_DISABLE		=	FPGA_SFP4_MOD_DETECT ? 1'b1 : 1'b0;
// assign		FPGA_SFP4_IIC_SCL			=	1'b1;

assign		FPGA_SSD1_DEVSLP	=	1'b0;
assign		FPGA_SSD1_SMB_CLK	=	1'b0;
assign		FPGA_SSD1_PERST_B	=	1'b0;

assign		DSP_MCBSP0_SLCLK	=	1'b0;
assign		DSP_MCBSP0_RXCLK	=	1'b0;
assign		DSP_MCBSP0_FSR		=	1'b0;
assign		DSP_MCBSP0_RX		=	1'b0;
assign		DSP_NMIZ			=	1'b0;
assign		DSP_RSTFULL			=	1'b0;
assign		DSP_RESETZ			=	1'b0;
assign		DSP_SYS_NRESET		=	1'b0;

assign		VCC3V3_DSP_SSD_EN	=	1'b0;
assign		VCC3V3_FPGA_SSD_EN	=	1'b0;
assign		VCC12V_FAN_EN		=	1'b1;

assign      Safety_in3          =   ready_signal;
// assign      RF_Mod_in_variable_LS   = 1'b0;
// assign      RF_Enable_LS            = 1'b0;
// assign      RF_fault_LS             = 1'b0;
// assign      RF_ready_LS             = 1'b0;
// assign      RF_emission_LS          = 1'b0;
// assign      RF_SYNC_LS              = 1'b0;

// assign      IO_PMT_SPI_MCLK_P[0]   = PMT_SPI_MCLK_P[3];
// assign      IO_PMT_SPI_MCLK_N[0]   = PMT_SPI_MCLK_N[3];
// assign      IO_PMT_SPI_MOSI_P[0]   = PMT_SPI_MOSI_P[3];
// assign      IO_PMT_SPI_MOSI_N[0]   = PMT_SPI_MOSI_N[3];
// assign      PMT_SPI_SCLK_P[3]   = IO_PMT_SPI_SCLK_P[0];
// assign      PMT_SPI_SCLK_N[3]   = IO_PMT_SPI_SCLK_N[0];
// assign      PMT_SPI_MISO_P[3]   = IO_PMT_SPI_MISO_P[0];
// assign      PMT_SPI_MISO_N[3]   = IO_PMT_SPI_MISO_N[0];

assign      ACC_SPI_SCLK_P[1] = IO_ACC_SPI_SCLK_P[1];
assign      ACC_SPI_SCLK_N[1] = IO_ACC_SPI_SCLK_N[1];
assign      ACC_SPI_MISO_P[1] = IO_ACC_SPI_MISO_P[1];
assign      ACC_SPI_MISO_N[1] = IO_ACC_SPI_MISO_N[1];

assign      IO_ENCODE_SPI_MCLK_P[1]  = ENCODE_SPI_MCLK_P[1];
assign      IO_ENCODE_SPI_MCLK_N[1]  = ENCODE_SPI_MCLK_N[1];
assign      IO_ENCODE_SPI_MOSI_P[1]  = ENCODE_SPI_MOSI_P[1];
assign      IO_ENCODE_SPI_MOSI_N[1]  = ENCODE_SPI_MOSI_N[1];

assign      IO_PMT_SPI_MCLK_P[1]   = PMT_SPI_MCLK_P[1];
assign      IO_PMT_SPI_MCLK_N[1]   = PMT_SPI_MCLK_N[1];
assign      IO_PMT_SPI_MOSI_P[1]   = PMT_SPI_MOSI_P[1];
assign      IO_PMT_SPI_MOSI_N[1]   = PMT_SPI_MOSI_N[1];
assign      PMT_SPI_SCLK_P[1]   = IO_PMT_SPI_SCLK_P[1];
assign      PMT_SPI_SCLK_N[1]   = IO_PMT_SPI_SCLK_N[1];
assign      PMT_SPI_MISO_P[1]   = IO_PMT_SPI_MISO_P[1];
assign      PMT_SPI_MISO_N[1]   = IO_PMT_SPI_MISO_N[1];


assign      ACC_SPI_SCLK_P[0] = IO_ACC_SPI_SCLK_P[2];
assign      ACC_SPI_SCLK_N[0] = IO_ACC_SPI_SCLK_N[2];
assign      ACC_SPI_MISO_P[0] = IO_ACC_SPI_MISO_P[2];
assign      ACC_SPI_MISO_N[0] = IO_ACC_SPI_MISO_N[2];

assign      IO_ENCODE_SPI_MCLK_P[2]  = ENCODE_SPI_MCLK_P[0];
assign      IO_ENCODE_SPI_MCLK_N[2]  = ENCODE_SPI_MCLK_N[0];
assign      IO_ENCODE_SPI_MOSI_P[2]  = ENCODE_SPI_MOSI_P[0];
assign      IO_ENCODE_SPI_MOSI_N[2]  = ENCODE_SPI_MOSI_N[0];

assign      IO_PMT_SPI_MCLK_P[2]   = PMT_SPI_MCLK_P[0];
assign      IO_PMT_SPI_MCLK_N[2]   = PMT_SPI_MCLK_N[0];
assign      IO_PMT_SPI_MOSI_P[2]   = PMT_SPI_MOSI_P[0];
assign      IO_PMT_SPI_MOSI_N[2]   = PMT_SPI_MOSI_N[0];
assign      PMT_SPI_SCLK_P[0]   = IO_PMT_SPI_SCLK_P[2];
assign      PMT_SPI_SCLK_N[0]   = IO_PMT_SPI_SCLK_N[2];
assign      PMT_SPI_MISO_P[0]   = IO_PMT_SPI_MISO_P[2];
assign      PMT_SPI_MISO_N[0]   = IO_PMT_SPI_MISO_N[2];


assign      ACC_SPI_SCLK_P[2] = IO_ACC_SPI_SCLK_P[3];
assign      ACC_SPI_SCLK_N[2] = IO_ACC_SPI_SCLK_N[3];
assign      ACC_SPI_MISO_P[2] = IO_ACC_SPI_MISO_P[3];
assign      ACC_SPI_MISO_N[2] = IO_ACC_SPI_MISO_N[3];

assign      IO_ENCODE_SPI_MCLK_P[3]  = ENCODE_SPI_MCLK_P[2];
assign      IO_ENCODE_SPI_MCLK_N[3]  = ENCODE_SPI_MCLK_N[2];
assign      IO_ENCODE_SPI_MOSI_P[3]  = ENCODE_SPI_MOSI_P[2];
assign      IO_ENCODE_SPI_MOSI_N[3]  = ENCODE_SPI_MOSI_N[2];

assign      IO_PMT_SPI_MCLK_P[3]   = PMT_SPI_MCLK_P[2];
assign      IO_PMT_SPI_MCLK_N[3]   = PMT_SPI_MCLK_N[2];
assign      IO_PMT_SPI_MOSI_P[3]   = PMT_SPI_MOSI_P[2];
assign      IO_PMT_SPI_MOSI_N[3]   = PMT_SPI_MOSI_N[2];
assign      PMT_SPI_SCLK_P[2]   = IO_PMT_SPI_SCLK_P[3];
assign      PMT_SPI_SCLK_N[2]   = IO_PMT_SPI_SCLK_N[3];
assign      PMT_SPI_MISO_P[2]   = IO_PMT_SPI_MISO_P[3];
assign      PMT_SPI_MISO_N[2]   = IO_PMT_SPI_MISO_N[3];



IBUFDS #(
    .DIFF_TERM("TRUE"),       // Differential Termination
    .IBUF_LOW_PWR("FALSE"),     // Low power="TRUE", Highest performance="FALSE" 
    .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
 ) IBUFDS_inst (
    .O(FPGA_MASTER_CLOCK),  // Buffer output
    .I(FPGA_MASTER_CLOCK_P),  // Diff_p buffer input (connect directly to top-level port)
    .IB(FPGA_MASTER_CLOCK_N) // Diff_n buffer input (connect directly to top-level port)
 );

pll pll_inst(
    .clk_out1   ( clk_100m          ),  // output clk_out1
    .clk_out2   ( clk_200m          ),  // output clk_out2
    .clk_out3   ( clk_250m          ),  // output clk_out3
    .clk_out4   ( clk_50m           ),  // output clk_out4
    .reset      ( FPGA_RESET        ),  // input reset
    .locked     ( pll_locked        ),  // output locked
    .clk_in1    ( FPGA_MASTER_CLOCK )
);

pll_2 pll_2_inst(
    .clk_out1   ( clk_300m          ), 
    .clk_out2   ( clk_div_3         ),
    .clk_out3   ( clk_div_6         ),
    .clk_out4   ( clk_80m           ),
    .reset      ( ~pll_locked       ), 
    .locked     ( pll_2_locked      ), 
    .clk_in1    ( clk_100m          )
);

////////////////////////////////////////////
generate
    for(i=0;i<3;i=i+1)begin : TIMING_PMT_SPI_INFO

        OBUFDS #(
              .IOSTANDARD("DEFAULT"), 		// Specify the output I/O standard
              .SLEW("SLOW")           		// Specify the output slew rate
           ) TIMING_SPI_MCLK_inst(
              .O(PMT_SPI_MCLK_P[i]),		// Diff_p output (connect directly to top-level port)
              .OB(PMT_SPI_MCLK_N[i]), 		// Diff_n output (connect directly to top-level port)
              .I(PMT_SPI_MCLK[i])			// Buffer input
        );

        OBUFDS #(
              .IOSTANDARD("DEFAULT"), 		// Specify the output I/O standard
              .SLEW("SLOW")           		// Specify the output slew rate
           ) TIMING_SPI_MOSI_inst(
              .O(PMT_SPI_MOSI_P[i]),		// Diff_p output (connect directly to top-level port)
              .OB(PMT_SPI_MOSI_N[i]), 		// Diff_n output (connect directly to top-level port)
              .I(PMT_SPI_MOSI[i])			// Buffer input
        );

        IBUFDS #(
                .DIFF_TERM("TRUE"),  			// Differential Termination
                .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
                .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
           ) TIMING_SPI_SCLK_inst(
                .O(PMT_SPI_SCLK[i]),  		// Buffer output
                .I(PMT_SPI_SCLK_P[i]), 		// Diff_p buffer input (connect directly to top-level port)
                .IB(PMT_SPI_SCLK_N[i])		// Diff_n buffer input (connect directly to top-level port)
        );

        IBUFDS #(
                .DIFF_TERM("TRUE"),  			// Differential Termination
                .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
                .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
           ) TIMING_SPI_MISO_inst(
                .O(PMT_SPI_MISO[i]),  		// Buffer output
                .I(PMT_SPI_MISO_P[i]), 		// Diff_p buffer input (connect directly to top-level port)
                .IB(PMT_SPI_MISO_N[i])		// Diff_n buffer input (connect directly to top-level port)
        );

        OBUFDS #(
            .IOSTANDARD("DEFAULT"), 		// Specify the output I/O standard
            .SLEW("SLOW")           		// Specify the output slew rate
        ) ENCODE_MOSI_inst(
            .O(ENCODE_SPI_MOSI_P[i]),		// Diff_p output (connect directly to top-level port)
            .OB(ENCODE_SPI_MOSI_N[i]), 		// Diff_n output (connect directly to top-level port)
            .I(ENCODE_SPI_MOSI[i])			// Buffer input
        );

        OBUFDS #(
            .IOSTANDARD("DEFAULT"), 		// Specify the output I/O standard
            .SLEW("SLOW")           		// Specify the output slew rate
        ) ENCODE_MCLK_inst(
            .O(ENCODE_SPI_MCLK_P[i]),		// Diff_p output (connect directly to top-level port)
            .OB(ENCODE_SPI_MCLK_N[i]), 		// Diff_n output (connect directly to top-level port)
            .I(ENCODE_SPI_MCLK[i])			// Buffer input
        );

        IBUFDS #(
            .DIFF_TERM("TRUE"),             // Differential Termination
            .IBUF_LOW_PWR("FALSE"),         // Low power="TRUE", Highest performance="FALSE" 
            .IOSTANDARD("DEFAULT")          // Specify the input I/O standard
        ) ACC_SCLK_inst(
            .O(ACC_SPI_SCLK[i]),                // Buffer output
            .I(ACC_SPI_SCLK_P[i]),              // Diff_p buffer input (connect directly to top-level port)
            .IB(ACC_SPI_SCLK_N[i])              // Diff_n buffer input (connect directly to top-level port)
        );

        IBUFDS #(
            .DIFF_TERM("TRUE"),             // Differential Termination
            .IBUF_LOW_PWR("FALSE"),         // Low power="TRUE", Highest performance="FALSE" 
            .IOSTANDARD("DEFAULT")          // Specify the input I/O standard
        ) ACC_MISO_inst(
            .O(ACC_SPI_MISO[i]),                // Buffer output
            .I(ACC_SPI_MISO_P[i]),              // Diff_p buffer input (connect directly to top-level port)
            .IB(ACC_SPI_MISO_N[i])              // Diff_n buffer input (connect directly to top-level port)
        );

    end
endgenerate

//>>>>>>>>>>>>>>>>>>>>> ENCODE SERIAL

//////////////////////////////////////
OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) BPSi_CLK_inst (
		.O(BPSi_CLK_P),     // Diff_p output (connect directly to top-level port)
		.OB(BPSi_CLK_N),   // Diff_n output (connect directly to top-level port)
		.I(clk_100m)      // Buffer input
   );
  
OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) BPSi_DATA0_inst (
		.O(BPSi_MCLK_P),     // Diff_p output (connect directly to top-level port)
		.OB(BPSi_MCLK_N),   // Diff_n output (connect directly to top-level port)
		.I(BPSi_MCLK)      // Buffer input
   );

OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) BPSi_DATA1_inst (
		.O(BPSi_MOSI_P),     // Diff_p output (connect directly to top-level port)
		.OB(BPSi_MOSI_N),   // Diff_n output (connect directly to top-level port)
		.I(BPSi_MOSI)      // Buffer input
   );

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) BPSi_DATA2_inst(
		.O(BPSi_SCLK),  		// Buffer output
		.I(BPSi_SCLK_P), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(BPSi_SCLK_N)		// Diff_n buffer input (connect directly to top-level port)
);

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) BPSi_DATA3_inst(
		.O(BPSi_MISO),  		// Buffer output
		.I(BPSi_MISO_P), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(BPSi_MISO_N)		// Diff_n buffer input (connect directly to top-level port)
);

OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) BPSr1_CLK_inst (
		.O(BPSr1_CLK_P),     // Diff_p output (connect directly to top-level port)
		.OB(BPSr1_CLK_N),   // Diff_n output (connect directly to top-level port)
		.I(clk_100m)      // Buffer input
   );
  
OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) BPSr1_DATA0_inst (
		.O(BPSr1_MCLK_P),     // Diff_p output (connect directly to top-level port)
		.OB(BPSr1_MCLK_N),   // Diff_n output (connect directly to top-level port)
		.I(BPSr1_MCLK)      // Buffer input
   );

OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) BPSr1_DATA1_inst (
		.O(BPSr1_MOSI_P),     // Diff_p output (connect directly to top-level port)
		.OB(BPSr1_MOSI_N),   // Diff_n output (connect directly to top-level port)
		.I(BPSr1_MOSI)      // Buffer input
   );

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) BPSr1_DATA2_inst(
		.O(BPSr1_SCLK),  		// Buffer output
		.I(BPSr1_SCLK_P), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(BPSr1_SCLK_N)		// Diff_n buffer input (connect directly to top-level port)
);

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) BPSr1_DATA3_inst(
		.O(BPSr1_MISO),  		// Buffer output
		.I(BPSr1_MISO_P), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(BPSr1_MISO_N)		// Diff_n buffer input (connect directly to top-level port)
);


OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) BPSr2_CLK_inst (
		.O(BPSr2_CLK_P),     // Diff_p output (connect directly to top-level port)
		.OB(BPSr2_CLK_N),   // Diff_n output (connect directly to top-level port)
		.I(clk_100m)      // Buffer input
   );
  
OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) BPSr2_DATA0_inst (
		.O(BPSr2_MCLK_P),     // Diff_p output (connect directly to top-level port)
		.OB(BPSr2_MCLK_N),   // Diff_n output (connect directly to top-level port)
		.I(BPSr2_MCLK)      // Buffer input
   );

OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) BPSr2_DATA1_inst (
		.O(BPSr2_MOSI_P),     // Diff_p output (connect directly to top-level port)
		.OB(BPSr2_MOSI_N),   // Diff_n output (connect directly to top-level port)
		.I(BPSr2_MOSI)      // Buffer input
   );

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) BPSr2_DATA2_inst(
		.O(BPSr2_SCLK),  		// Buffer output
		.I(BPSr2_SCLK_P), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(BPSr2_SCLK_N)		// Diff_n buffer input (connect directly to top-level port)
);

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) BPSr2_DATA3_inst(
		.O(BPSr2_MISO),  		// Buffer output
		.I(BPSr2_MISO_P), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(BPSr2_MISO_N)		// Diff_n buffer input (connect directly to top-level port)
);

// overload overload_inst(
//     // clk & rst
//     .clk_i                          ( clk_i                         ),
//     .rst_i                          ( rst_i                         ),
    
//     .motor_state_i                  ( bpsi_data_acq_en              ), // motor state
//     .motor_Ufeed_en_i               ( motor_data_out_en             ), // Ufeed en
//     .motor_Ufeed_i                  ( motor_data_out                ), // Ufeed

//     .overload_motor_en_i            ( fbc_close_state && overload_motor_en),
//     .overload_ufeed_thre_i          ( overload_ufeed_thre           ),
//     .overload_pid_result_o          ( overload_pid_result           )
// );

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
    // .ascent_gradient_i              ( ascent_gradient               ),
    // .slow_ascent_period_i           ( slow_ascent_period            ),
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


    // // calibrate voltage. dark current * R
    // .FBCi_cali_en_o                 ( FBCi_cali_en                  ),
    // .FBCi_cali_a_o                  ( FBCi_cali_a                   ),
    // .FBCi_cali_b_o                  ( FBCi_cali_b                   ),
    // .FBCr2_cali_en_o                ( FBCr2_cali_en                 ),
    // .FBCr2_cali_a_o                 ( FBCr2_cali_a                  ),
    // .FBCr2_cali_b_o                 ( FBCr2_cali_b                  ),
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

fpga_heart_beat fpga_heart_beat_inst(
    // clk & rst
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),
    
    .fast_shutter_set_i             ( fast_shutter_set              ),
    .fast_shutter_en_i              ( fast_shutter_en               ),
    .fpga_message_up_data_o         ( fpga_message_up_data          ),
    .fpga_message_up_o              ( fpga_message_up               ),

    .scan_state_i                   ( scan_state                    ),
    .fast_shutter_state_i           ( fast_shutter_state            ),
    .pmt_scan_en_i                  ( pmt_scan_en                   ),
    .fbc_motor_state_i              ( bpsi_data_acq_en              ),
    .laser_control_i                ( RF_Enable_LS                  ),
    .laser_out_switch_i             ( RF_emission_LS                ),
    .laser_aom_voltage_i            ( laser_aom_voltage             ),
    .eds_power_en_i                 ( eds_power_en                  ),
    .eds_frame_en_i                 ( eds_frame_en                  ),
    .map_readback_cnt_i             ( map_readback_cnt              ),
    .main_scan_cnt_i                ( main_scan_cnt                 ),

    .heartbeat_data_o               ( heartbeat_data                ),
    .heartbeat_en_o                 ( heartbeat_en                  )
);

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
    .acc_encode_latch_i             ( acc_encode_latch              ),
    .acc_encode_latch_en_i          ( acc_encode_latch_en           ),
    // // calibrate voltage. dark current * R
    // .FBCi_cali_en_i                 ( FBCi_cali_en                  ),
    // .FBCi_cali_a_i                  ( FBCi_cali_a                   ),
    // .FBCi_cali_b_i                  ( FBCi_cali_b                   ),
    // .FBCr1_cali_en_i                ( FBCr1_cali_en                 ),
    // .FBCr1_cali_a_i                 ( FBCr1_cali_a                  ),
    // .FBCr1_cali_b_i                 ( FBCr1_cali_b                  ),
    // .FBCr2_cali_en_i                ( FBCr2_cali_en                 ),
    // .FBCr2_cali_a_i                 ( FBCr2_cali_a                  ),
    // .FBCr2_cali_b_i                 ( FBCr2_cali_b                  ),
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

    .spi_slave0_ack_rst_i           ( rd_ack_timeout_rst[0]         ),
    .spi_slave0_ack_vld_i           ( spi_slave_ack_vld[0]          ),
    .spi_slave0_ack_last_i          ( spi_slave_ack_last[0]         ),
    .spi_slave0_ack_data_i          ( spi_slave_ack_data[0]         ),
    .spi_slave1_ack_rst_i           ( rd_ack_timeout_rst[1]         ),
    .spi_slave1_ack_vld_i           ( spi_slave_ack_vld[1]          ),
    .spi_slave1_ack_last_i          ( spi_slave_ack_last[1]         ),
    .spi_slave1_ack_data_i          ( spi_slave_ack_data[1]         ),
    .spi_slave2_ack_rst_i           ( rd_ack_timeout_rst[2]         ),
    .spi_slave2_ack_vld_i           ( spi_slave_ack_vld[2]          ),
    .spi_slave2_ack_last_i          ( spi_slave_ack_last[2]         ),
    .spi_slave2_ack_data_i          ( spi_slave_ack_data[2]         ),

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
    .SLAVE_MSG_TX                   ( FPGA_TO_SFPGA_RESERVE4        ),
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
    // .ascent_gradient_o              ( ascent_gradient               ),
    // .slow_ascent_period_o           ( slow_ascent_period            ),
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

    .eds_pack_cnt_1_i               ( eds_pack_cnt_1                ),
    .encode_pack_cnt_1_i            ( encode_pack_cnt_1             ),
    .eds_pack_cnt_2_i               ( eds_pack_cnt_2                ),
    .encode_pack_cnt_2_i            ( encode_pack_cnt_2             ),
    .eds_pack_cnt_3_i               ( eds_pack_cnt_3                ),
    .encode_pack_cnt_3_i            ( encode_pack_cnt_3             ),

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
    // .acc_demo_xencode_offset_o      ( acc_demo_xencode_offset       ),
    .acc_demo_skip_cnt_i            ( acc_demo_skip_cnt             ),
    .acc_demo_addr_latch_i          ( acc_demo_addr_latch           ),
    .acc_skip_fifo_rd_o             ( acc_skip_fifo_rd              ),
    .acc_skip_fifo_ready_i          ( acc_skip_fifo_ready           ),
    .acc_skip_fifo_data_i           ( acc_skip_fifo_data            ),
    .timing_flag_supp_o             ( timing_flag_supp              ),
    .acc_trigger_num_i              ( acc_trigger_num               ),

    .eds_sensor_training_done_i     ( eds_sensor_training_done      ),
    .eds_sensor_training_result_i   ( eds_sensor_training_result    ),
    
    .aurora_empty_1_i               ( aurora_empty_1                ),
    .aurora_empty_2_i               ( aurora_empty_2                ),
    .aurora_empty_3_i               ( aurora_empty_3                ),
    .aurora_soft_rd_1_o             ( aurora_soft_rd_1              ),
    .aurora_soft_rd_2_o             ( aurora_soft_rd_2              ),
    .aurora_soft_rd_3_o             ( aurora_soft_rd_3              ),
    .cfg_acc_use_o                  ( cfg_acc_use                   ),
    .cfg_fbc_rate_o                 ( cfg_fbc_rate                  ),
    .cfg_spindle_width_o            ( cfg_spindle_width             ),
    .cfg_FBC_bypass_o               ( cfg_FBC_bypass                ),
    .cfg_QPD_enable_o               ( cfg_QPD_enable                ),
    .dbg_qpd_mode_o                 ( dbg_qpd_mode                  ),

    .encode_check_clean_o           ( encode_check_clean            ),
    .w_encode_err_lock_i            ( w_encode_err_lock             ),
    .w_encode_warn_lock_i           ( w_encode_warn_lock            ),
    .w_encode_continuity_max_i      ( w_encode_continuity_max       ),
    .w_encode_continuity_cnt_i      ( w_encode_continuity_cnt       ),
    // .w_src_encode_continuity_max_i  ( w_src_encode_continuity_max   ),
    // .w_src_encode_continuity_cnt_i  ( w_src_encode_continuity_cnt   ),
    // .w_eds_encode_continuity_max_i  ( w_eds_encode_continuity_max   ),
    // .w_eds_encode_continuity_cnt_i  ( w_eds_encode_continuity_cnt   ),

    .fbc_udp_rate_switch_o          ( fbc_udp_rate_switch           ),
    .map_readback_cnt_o             ( map_readback_cnt              ),
    .main_scan_cnt_o                ( main_scan_cnt                 ),
    .acc_encode_upload_o            ( acc_encode_upload             ),

    .debug_info                     (                               )
);

scan_state_ctrl scan_state_ctrl_inst(
    // clk & rst
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),
    
    .aurora_tx_idle_i               ( aurora_tx_idle                ),
    .aurora_scan_reset_o            ( aurora_scan_reset             ),
    .scan_soft_reset_i              ( scan_soft_reset               ),
    .scan_start_cmd_i               ( scan_start_cmd                ),
    .scan_start_sel_i               ( scan_start_sel                ),
    .fast_shutter_state_i           ( fast_shutter_state            ),
    .fbc_close_state_i              ( fbc_close_state               ),
    .fbc_close_state_err_i          ( fbc_close_state_err           ),
    .fbc_ratio_err_i                ( fbc_ratio_err                 ),
    .scan_fbc_switch_i              ( scan_fbc_switch               ),

    .x_encode_i                     ( real_precise_encode_x         ),
    .x_start_encode_i               ( x_start_encode                ),
    .fast_shutter_encode_i          ( fast_shutter_encode           ),
    .x_end_encode_i                 ( x_end_encode                  ),
    .plc_x_encode_i                 ( plc_x_encode                  ),
    .plc_x_encode_en_i              ( plc_x_encode_en               ),

    .fast_shutter_set_o             ( fast_shutter_set              ),
    .fast_shutter_en_o              ( fast_shutter_en               ),
    .fbc_close_loop_o               ( fbc_close_loop                ),
    .fbc_open_loop_o                ( fbc_open_loop                 ),
    .real_scan_start_o              ( real_scan_flag                ),
    .real_scan_sel_o                ( real_scan_sel                 ),
    .acc_force_on_o                 ( acc_force_on                  ),
    .start_encode_latch_o           ( start_encode_latch            ),
    .sfrst_encode_latch_o           ( sfrst_encode_latch            ),
    .scan_finish_comm_o             ( scan_finish_comm              ),
    .scan_finish_comm_ack_i         ( scan_finish_comm_ack          ),
    .scan_error_comm_o              ( scan_error_comm               ),
    .scan_error_comm_flag_o         ( scan_error_comm_flag          ),
    .scan_state_o                   ( scan_state                    ),
    
    .scan_encode_offset_i           ( scan_encode_offset            ),
    .autocal_encode_offset_i        ( autocal_encode_offset         ),
    .autocal_fbp_sel_i              ( autocal_fbp_sel               ),
    .fbp_encode_start_i             ( fbp_encode_start              ),
    .fbp_encode_end_i               ( fbp_encode_end                ),
    .autocal_pow_sel_i              ( autocal_pow_sel               ),
    .pow_encode_start_i             ( pow_encode_start              ),
    .pow_encode_end_i               ( pow_encode_end                ),
    .autocal_lpo_sel_i              ( autocal_lpo_sel               ),
    .lpo_encode_start_i             ( lpo_encode_start              ),
    .lpo_encode_end_i               ( lpo_encode_end                ),
    .precise_encode_offset_o        ( precise_encode_offset         ),
    .main_scan_start_o              ( main_scan_start               ),
    .autocal_process_o              ( autocal_process               ),
    // .autocal_fbp_scan_o             ( autocal_fbp_scan              ),
    // .autocal_pow_scan_o             ( autocal_pow_scan              ),
    // .autocal_lpo_scan_o             ( autocal_lpo_scan              ),
    // .aom_continuous_trig_err_i      ( aom_continuous_trig_err       ),
    // .aom_integral_trig_err_i        ( aom_integral_trig_err         ),

    .PLC_ACC_IN                     ( Safety_in1                    ),
    .ACS_IN1                        ( ACS_IN1                       ),
    .ACS_OUT1                       ( ACS_OUT1_LS                   )
);

scan_cmd_ctrl scan_cmd_ctrl_inst(
    // clk & rst
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),
    // scan control single
    .real_scan_flag_i               ( real_scan_flag                ),
    .real_scan_sel_i                ( real_scan_sel                 ),
    .pmt_adc_start_data_i           ( pmt_adc_start_data            ),
    .pmt_adc_start_vld_i            ( pmt_adc_start_vld             ),
    .pmt_adc_start_hold_i           ( pmt_adc_start_hold            ),

    .pmt_scan_cmd_sel_o             ( pmt_scan_cmd_sel              ),   // bit[0]:pmt1; bit[1]:pmt2; bit[2]:pmt3
    .pmt_scan_cmd_o                 ( pmt_scan_cmd                  )    // bit[0]:scan start; bit[1]:scan test
);

scan_flag_generate scan_flag_generate_inst(
    // clk & rst
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),
    
    .pmt_start_en_i                 ( pmt_start_en                  ),
    .pmt_end_en_i                   ( pcie_pmt_end_en               ),
    .pmt_scan_en_o                  ( pmt_scan_en                   ),

    .fbc_up_start_i                 ( fbc_up_start                  ),
    .fbc_up_end_i                   ( aurora_fbc_end                ),
    .fbc_up_en_o                    ( fbc_up_en                     )
);

fast_shutter_ctrl fast_shutter_ctrl_inst(
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),
    .fast_shutter_set_i             ( fast_shutter_set              ),
    .fast_shutter_en_i              ( fast_shutter_en               ),
    .soft_fast_shutter_set_i        ( soft_fast_shutter_set         ),
    .soft_fast_shutter_en_i         ( soft_fast_shutter_en          ),
    .fast_shutter_out1_o            ( Fast_Shutter_in1              ),
    .fast_shutter_out2_o            ( Fast_Shutter_in2              ),
    .fast_back_in1_i                ( Fast_Shutter_out1             ),
    .fast_back_in2_i                ( Fast_Shutter_out2             ),
    .fast_shutter_state_o           ( fast_shutter_state            ),
    .fast_shutter_act_time_o        ( fast_shutter_act_time         )
);

pmt_master_sel pmt_master_sel_inst(
    // clk & rst
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),
    .master_wr_data_i               ( pmt_master_spi_data           ),
    .master_wr_vld_i                ( pmt_master_spi_vld            ),
    .pmt_master_cmd_parser_i        ( pmt_master_cmd_parser         ),

    .pmt_master_wr_data_o           ( pmt_master_wr_data            ),
    .pmt_master_wr_vld_o            ( pmt_master_wr_vld             )
);

generate
    for(i=0;i<3;i=i+1)begin : PMT_SPI_MASTER
        serial_master_drv #(
            .DATA_WIDTH                     ( 32                            ),
            .ADDR_WIDTH                     ( 16                            ),
            .CMD_WIDTH                      ( 8                             ),
            .MASTER_SEL                     ( i                             ),
            .SERIAL_MODE                    ( 1                             )
        )serial_master_drv_inst(
            // clk & rst
            .clk_i                          ( clk_100m                      ),
            .rst_i                          ( rst_100m                      ),
            .clk_200m_i                     ( clk_200m                      ),
            .master_wr_data_i               ( pmt_master_wr_data            ),
            .master_wr_vld_i                ( pmt_master_wr_vld             ),
            .pmt_master_cmd_parser_o        ( pmt_master_cmd_parser[i]      ),

            .slave_ack_vld_o                ( spi_slave_ack_vld[i]          ),
            .slave_ack_last_o               ( spi_slave_ack_last[i]         ),
            .slave_ack_data_o               ( spi_slave_ack_data[i]         ),
            // spi info
            .SPI_MCLK                       ( PMT_SPI_MCLK[i]               ),
            .SPI_MOSI                       ( PMT_SPI_MOSI[i]               ),
            .SPI_SCLK                       ( PMT_SPI_SCLK[i]               ),
            .SPI_MISO                       ( PMT_SPI_MISO[i]               )
        );
    end
endgenerate

generate
    for(i=0;i<3;i=i+1)begin : PMT_ACC_SEL
        acc_ctrl_rx_drv acc_ctrl_rx_drv_inst(
            // clk & rst
            .clk_i                          ( clk_100m                      ),
            .rst_i                          ( rst_100m                      ),
            .clk_200m_i                     ( clk_200m                      ),

            .acc_aom_flag_o                 ( acc_pmt_flag_sel[i]           ),

            // spi info
            .SPI_SCLK                       ( ACC_SPI_SCLK[i]               ),
            .SPI_MISO                       ( ACC_SPI_MISO[i]               )
        );
    end
endgenerate

assign acc_pmt_flag =      ((cfg_acc_use == 'd0) && acc_pmt_flag_sel[0])
                        || ((cfg_acc_use == 'd1) && acc_pmt_flag_sel[1])
                        || ((cfg_acc_use == 'd2) && acc_pmt_flag_sel[2]);

acc_demo_ctrl acc_demo_ctrl_inst(
    // clk & rst
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),
    
    .acc_demo_mode_i                ( acc_demo_mode                 ),
    .acc_demo_wren_i                ( acc_demo_wren                 ),
    .acc_demo_addr_i                ( acc_demo_addr                 ),
    .acc_demo_Wencode_i             ( acc_demo_Wencode              ),
    .acc_demo_Xencode_i             ( acc_demo_Xencode              ),
    .acc_demo_particle_cnt_i        ( acc_demo_particle_cnt         ),

    .pmt_scan_en_i                  ( |pmt_scan_en                  ),
    .main_scan_start_i              ( main_scan_start               ),
    .real_precise_encode_en_i       ( acc_demo_encode_en            ),
    .real_precise_Wencode_i         ( acc_demo_encode_w[17:0]       ),
    .real_precise_Xencode_i         ( acc_demo_encode_x[21:4]       ),

    .acc_demo_skip_cnt_o            ( acc_demo_skip_cnt             ),
    .acc_demo_addr_latch_o          ( acc_demo_addr_latch           ),
    .skip_fifo_rd_i                 ( acc_skip_fifo_rd              ),
    .skip_fifo_ready_o              ( acc_skip_fifo_ready           ),
    .skip_fifo_data_o               ( acc_skip_fifo_data            ),
    .acc_demo_flag_o                ( acc_demo_flag                 )
);

acc_demo_flag_trim acc_demo_flag_trim_inst(
    // clk & rst
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),

    .acc_encode_upload_i            ( acc_encode_upload             ),
    .pmt_precise_encode_i           ( {pmt_precise_encode_w_temp,pmt_precise_encode_x_temp}),
    .acc_encode_latch_en_o          ( acc_encode_latch_en           ),
    .acc_encode_latch_o             ( acc_encode_latch              ),

    .pmt_scan_en_i                  ( |pmt_scan_en                  ),
    .acc_demo_flag_i                ( acc_pmt_flag || acc_demo_flag ),
    .acc_demo_trim_time_pose_i      ( acc_demo_trim_time_pose       ),
    .acc_demo_trim_time_nege_i      ( acc_demo_trim_time_nege       ),

    .acc_demo_trim_ctrl_o           ( acc_demo_trim_ctrl            ),
    .acc_demo_trim_flag_o           ( acc_demo_trim_flag            )
);

generate
    for(i=0;i<3;i=i+1)begin : PMT_SPI_ENCODE
        encode_tx_drv encode_tx_drv_inst(
            // clk & rst
            .clk_i              ( clk_100m                                  ),
            .rst_i              ( rst_100m                                  ),
            .clk_200m_i         ( clk_200m                                  ),

            .precise_encode_w_i ( real_precise_encode_w                     ),

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

laser_comm_ctrl laser_comm_ctrl_inst(
    // clk & rst
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),
    
    .laser_tx_data_i                ( laser_tx_data                 ),
    .laser_tx_vld_i                 ( laser_tx_vld                  ),
    .laser_rx_data_o                ( laser_rx_data                 ),
    .laser_rx_vld_o                 ( laser_rx_vld                  ),
    .laser_rx_last_o                ( laser_rx_last                 ),

    // interface    
    .LASER_UART_RXD                 ( UART_RX                       ),
    .LASER_UART_TXD                 ( UART_TX                       )
);

laser_aom_ctrl laser_aom_ctrl_inst(
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst_100m                      ),
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

    .acc_force_on_i                 ( acc_force_on                  ),
    .acc_job_control_i              ( acc_job_control               ),
    // .acc_job_init_switch_i          ( acc_job_init_switch           ),
    .acc_job_init_vol_trig_i        ( acc_job_init_vol_trig         ),
    .acc_job_init_vol_i             ( acc_job_init_vol              ),
    .acc_aom_flag_i                 ( acc_demo_trim_ctrl            ),  // aom ctrl
    // .acc_aom_class0_i               ( acc_aom_class0                ),
    .acc_aom_class1_i               ( acc_aom_class1                ),
    // .acc_aom_class2_i               ( acc_aom_class2                ),
    // .acc_aom_class3_i               ( acc_aom_class3                ),
    // .acc_aom_class4_i               ( acc_aom_class4                ),
    // .acc_aom_class5_i               ( acc_aom_class5                ),
    // .acc_aom_class6_i               ( acc_aom_class6                ),
    // .acc_aom_class7_i               ( acc_aom_class7                ),
    // .acc_aom_class_i                ( acc_aom_class                 ),

    // .aom_continuous_trig_err_i      ( aom_continuous_trig_err       ),
    // .aom_integral_trig_err_i        ( aom_integral_trig_err         ),

    .LASER_CONTROL                  ( RF_Enable_LS                  ),
    .LASER_OUT_SWITCH               ( RF_emission_LS                ),
    .laser_aom_en_o                 ( laser_aom_en                  ),
    .laser_aom_voltage_o            ( laser_aom_voltage             )
);

// acc_trigger_check acc_trigger_check_inst(
//     .clk_i                          ( clk_100m                      ),
//     .rst_i                          ( rst_100m                      ),

//     .laser_start_i                  ( |pmt_scan_en                  ),
//     .aom_ctrl_flag_i                ( acc_demo_trim_ctrl            ),
//     .encode_w_i                     ( align_src_encode_w[17:0]      ),
//     .encode_x_i                     ( align_src_encode_x[21:4]      ),

//     .trig_fifo_ready_o              ( trig_fifo_ready               ),
//     .trig_fifo_rd_i                 ( trig_fifo_rd                  ),
//     .trig_fifo_data_o               ( trig_fifo_data                ),
//     .acc_trigger_num_o              ( acc_trigger_num               )
// );


// aom_trig_overload aom_trig_overload_inst(
//     // clk & rst
//     .clk_i                          ( clk_100m                      ),
//     .rst_i                          ( rst_100m                      ),
    
//     // interface    
//     .laser_control_i                ( RF_Enable_LS                  ),
//     .laser_out_switch_i             ( RF_emission_LS                ),
//     .laser_aom_en_i                 ( laser_aom_en                  ),
//     .laser_aom_voltage_i            ( laser_aom_voltage             ),

//     .acc_job_control_i              ( acc_job_control               ),
//     .aom_trig_protect_i             ( aom_trig_protect              ),
//     .aom_continuous_trig_thre_i     ( aom_continuous_trig_thre      ),
//     .aom_integral_trig_thre_i       ( aom_integral_trig_thre        ),
//     .aom_trig_vol_thre_i            ( aom_trig_vol_thre             ),

//     .aom_continuous_trig_err_o      ( aom_continuous_trig_err       ),
//     .aom_integral_trig_err_o        ( aom_integral_trig_err         )

// );


ad5445_config ad5445_config_inst(
    .clk                            ( clk_100m                      ),  //100M
    .rst                            ( rst_100m                      ),
    .dac_out_en                     ( laser_aom_en                  ),
    .dac_out                        ( laser_aom_voltage             ),

    .rw_ctr                         ( AD5445_R_Wn                   ),
    .cs_n                           ( AD5445_CSn                    ),
    .d_bit                          ( AD5445_DB                     )
);

max5216_spi_if max5216_spi_if_inst(
    .clk                            ( clk_100m                      ), 
    .rst                            ( rst_100m                      ), 

    .data_in_en                     ( motor_data_in_en              ),
    .data_in                        ( motor_data_in                 ),

    .spi_csn                        ( MAX5216_CS_LS                 ),
    .spi_clk                        ( MAX5216_CLK_LS                ),  //max 50M
    .spi_mosi                       ( MAX5216_DIN_LS                ),
    .clr_n                          ( MAX5216_CLR_LS                ),

    .spi_ok                         (                               )
);

ad7680_spi_if ad7680_spi_if_inst(
    .clk                            ( clk_100m                      ),
    .rst                            ( rst_100m                      ),

    .adc_rd_en                      ( motor_rd_en                   ),

    .spi_csn                        ( AD7680_CS_LS                  ),
    .spi_clk                        ( AD7680_SCLK_LS                ),  //max 2.5M, min 250K
    .spi_miso                       ( AD7680_SDATA_LS               ),

    .data_out_en                    ( motor_data_out_en             ),
    .data_out                       ( motor_data_out                )

);

//////////////////////////////////////////////
OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) EDS_CLK_inst (
		.O(EDS_CLK_P),     // Diff_p output (connect directly to top-level port)
		.OB(EDS_CLK_N),   // Diff_n output (connect directly to top-level port)
		.I(clk_100m)      // Buffer input
   );
  
OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) EDS_TC_inst (
		.O(EDS_TC_P),     // Diff_p output (connect directly to top-level port)
		.OB(EDS_TC_N),   // Diff_n output (connect directly to top-level port)
		.I(EDS_TC)      // Buffer input
   );

OBUFDS #(
      .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
      .SLEW("SLOW")           // Specify the output slew rate
   ) EDS_TFG_inst (
		.O(EDS_TFG_P),     // Diff_p output (connect directly to top-level port)
		.OB(EDS_TFG_N),   // Diff_n output (connect directly to top-level port)
		.I(EDS_TFG)      // Buffer input
   );

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) EDS_DATA0_inst(
		.O(EDS_DATA[0]),  		// Buffer output
		.I(EDS_DATA_P[0]), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(EDS_DATA_N[0])		// Diff_n buffer input (connect directly to top-level port)
);

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) EDS_DATA1_inst(
		.O(EDS_DATA[1]),  		// Buffer output
		.I(EDS_DATA_P[1]), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(EDS_DATA_N[1])		// Diff_n buffer input (connect directly to top-level port)
);

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) EDS_DATA2_inst(
		.O(EDS_DATA[2]),  		// Buffer output
		.I(EDS_DATA_P[2]), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(EDS_DATA_N[2])		// Diff_n buffer input (connect directly to top-level port)
);

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) EDS_DATA3_inst(
		.O(EDS_DATA[3]),  		// Buffer output
		.I(EDS_DATA_P[3]), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(EDS_DATA_N[3])		// Diff_n buffer input (connect directly to top-level port)
);

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) EDS_CC1_inst(
		.O(EDS_CC1),  		// Buffer output
		.I(EDS_CC1_P), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(EDS_CC1_N)		// Diff_n buffer input (connect directly to top-level port)
);

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) EDS_CC2_inst(
		.O(EDS_CC2),  		// Buffer output
		.I(EDS_CC2_P), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(EDS_CC2_N)		// Diff_n buffer input (connect directly to top-level port)
);

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) EDS_CC3_inst(
		.O(EDS_CC3),  		// Buffer output
		.I(EDS_CC3_P), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(EDS_CC3_N)		// Diff_n buffer input (connect directly to top-level port)
);

IBUFDS #(
      .DIFF_TERM("TRUE"),  			// Differential Termination
      .IBUF_LOW_PWR("FALSE"),  		// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD("DEFAULT")  		// Specify the input I/O standard
   ) EDS_CC4_inst(
		.O(EDS_CC4),  		// Buffer output
		.I(EDS_CC4_P), 		// Diff_p buffer input (connect directly to top-level port)
		.IB(EDS_CC4_N)		// Diff_n buffer input (connect directly to top-level port)
);

reg eds_frame_end_en_d0;
always @(posedge clk_300m) begin
    eds_frame_end_en_d0 <= pcie_eds_frame_end_2 || pcie_eds_frame_end_1 || pcie_eds_frame_end_3;
end


eds_frame_ctrl eds_frame_ctrl_inst(
    // clk & rst
    .clk_i                      ( clk_100m                                  ),
    .rst_i                      ( rst_100m                                  ),
    // scan control single
    .eds_frame_en_i             ( eds_frame_cmd_en                          ),
    .eds_frame_sel_i            ( eds_frame_cmd_sel                         ),
    .eds_frame_hold_i           ( eds_frame_cmd_hold                        ),

    .eds_frame_sel_o            ( eds_frame_sel                             ),   // bit[0]:pmt1; bit[1]:pmt2; bit[2]:pmt3
    .eds_frame_en_o             ( eds_frame_en                              ) 
);


eds_top_if	eds_top_if_inst(
    .clk                        ( clk_80m                                   ),
    .clk_h                      ( clk_300m                                  ),
    .rst                        ( rst_80m                                   ),
    .clk_div_3                  ( clk_div_3                                 ),
    .clk_div_6                  ( clk_div_6                                 ),
    .spi_clk                    ( EDS_TC                                    ),
    .spi_mosi                   ( EDS_TFG                                   ),

    .eds_power_en               ( eds_power_en                              ),
    .eds_frame_en               ( eds_frame_en                              ),
    .eds_test_en                ( eds_test_en                               ),
    .texp_time                  ( texp_time                                 ),
    .frame_to_frame_time        ( frame_to_frame_time                       ),

    .pcie_eds_frame_end         ( eds_frame_end_en_d0                       ),

    .eds_sensor_training_done   ( eds_sensor_training_done                  ),
    .eds_sensor_training_result ( eds_sensor_training_result                ),

    .eds_data_in                ( {EDS_CC4,EDS_CC3,EDS_CC2,EDS_CC1,EDS_DATA}),

    // .eds_scan_en_o              ( eds_scan_en                               ),
    .eds_clk                    ( eds_clk                                   ),  //100M/6
    .eds_sensor_data_en         ( eds_sensor_data_en                        ),
    .eds_sensor_data            ( eds_sensor_data_temp                      )
	
);

assign	eds_sensor_data		=	{eds_sensor_data_temp[63:0],eds_sensor_data_temp[127:64]};

reset_generate reset_generate_inst(
    .nrst_i                     ( pll_2_locked                          ),

    .clk_100m                   ( clk_100m                              ),
    .rst_100m                   ( rst_100m                              ),
    
    .clk_80m                    ( clk_80m                               ),
    .rst_80m                    ( rst_80m                               ),

    .ddr_ui_clk                 ( ddr_ui_clk                            ),
    .ddr_rst                    ( ddr_rst                               ),

    .clk_50m                    ( clk_50m                               ),
    .gt_rst                     ( gt_rst                                ),

    .hmc7044_config_ok          ( hmc7044_config_ok                     ),

    .aurora_log_clk_1           ( aurora_log_clk_1                      ),
    .aurora_log_clk_2           ( aurora_log_clk_2                      ),
    .aurora_log_clk_3           ( aurora_log_clk_3                      ),
    // .aurora_log_clk_4           ( aurora_log_clk_4                      ),
    .aurora_rst_1               ( aurora_rst_1                          ),
    .aurora_rst_2               ( aurora_rst_2                          ),
    .aurora_rst_3               ( aurora_rst_3                          )
    // .aurora_rst_4               ( aurora_rst_4                          )
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
    .encode_w_i                     ( acc_demo_encode_w                     ),
    .encode_x_i                     ( {4'd0,acc_demo_encode_x[31:4]}        ),

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
    .aurora_fbc_almost_full_1_i     ( aurora_fbc_almost_full_1              ),
    .aurora_fbc_almost_full_2_i     ( aurora_fbc_almost_full_2              ),
    .aurora_fbc_almost_full_3_i     ( aurora_fbc_almost_full_3              )
);

ddr_top u_ddr_top(
    .clk_i                          ( clk_100m                          ),
    .rst_i                          ( rst_100m                          ),
    .clk_250m_i                     ( clk_250m                          ),
    .clk_200m_i                     ( clk_200m                          ),
    
    .fbc_scan_en_i                  ( fbc_scan_en                       ),
    .fbc_cache_vld_i                ( fbc_cache_vld                     ),
    .fbc_cache_data_i               ( fbc_cache_data                    ),

    .fbc_up_start_o                 ( fbc_up_start                      ),
    .fbc_vout_empty_o               ( fbc_vout_empty                    ),
    .fbc_vout_rd_seq_i              ( fbc_vout_rd_seq                   ),
    .fbc_vout_rd_vld_o              ( fbc_vout_rd_vld                   ),
    .fbc_vout_rd_data_o             ( fbc_vout_rd_data                  ),

    .init_calib_complete_o          ( ddr3_init_done                    ),
    .ddr3_addr                      ( DDR3_A_ADD                        ),
    .ddr3_ba                        ( DDR3_A_BA                         ),
    .ddr3_ras_n                     ( DDR3_A_RAS_B                      ),
    .ddr3_cas_n                     ( DDR3_A_CAS_B                      ),
    .ddr3_we_n                      ( DDR3_A_WE_B                       ),
    .ddr3_reset_n                   ( DDR3_A_RESET_B                    ),
    .ddr3_ck_p                      ( DDR3_A_CLK0_P                     ),
    .ddr3_ck_n                      ( DDR3_A_CLK0_N                     ),
    .ddr3_cke                       ( DDR3_A_CKE                        ),
    .ddr3_cs_n                      ( DDR3_A_S0_B                       ),
    .ddr3_dm                        ( DDR3_A_DM                         ),
    .ddr3_odt                       ( DDR3_A_ODT                        ),

    .ddr3_dq                        ( DDR3_A_D                          ),
    .ddr3_dqs_n                     ( DDR3_A_DQS_N                      ),
    .ddr3_dqs_p                     ( DDR3_A_DQS_P                      )
);

aurora_64b66b_0_exdes aurora_64b66b_exdes_inst_1(
    .aurora_log_clk_o               ( aurora_log_clk_1                  ),
    .aurora_empty_o                 ( aurora_empty_1                    ),
    .aurora_soft_rd_i               ( aurora_soft_rd_1                  ),
    // eds
    .eds_clk_i                      ( eds_clk                           ),  // eds clk -> 100m/6
    .clk_h_i                        ( clk_300m                          ),  // eds clk_h -> 300m
    .eds_sensor_vld_i               ( eds_sensor_data_en                ),
    .eds_sensor_data_i              ( eds_sensor_data                   ),
    .eds_frame_en_i                 ( eds_frame_en && eds_frame_sel[1]  ),
    .pcie_eds_end_o                 ( pcie_eds_frame_end_1              ),

    .precise_encode_en_i            ( align_src_encode_en               ),
    .precise_encode_w_data_i        ( align_src_encode_w                ),
    .precise_encode_x_data_i        ( align_src_encode_x                ),
    .dbg_eds_frame_en_o             ( dbg_eds_frame_en[1]               ),
    .dbg_eds_wencode_vld_o          ( dbg_eds_wencode_vld[1]            ),
    .dbg_eds_wencode_o              ( dbg_eds_wencode[1]                ),

    // pmt
    .pmt_clk_i                      ( clk_100m                          ),  // sys clk -> 100m
    .pmt_encode_vld_i               ( pmt_precise_encode_en_temp && pmt_scan_en[1]            ),
    .pmt_encode_data_i              ( {pmt_precise_encode_w_temp,pmt_precise_encode_x_temp}   ),
    .pmt_start_en_i                 ( pmt_start_en[1]                   ),
    .pcie_pmt_end_o                 ( pcie_pmt_end_en[1]                ),

    // fbc
    .fbc_clk_i                      ( clk_100m                          ),  // sys clk -> 100m
    .fbc_up_start_i                 ( fbc_up_start && fbc_up_en[1]      ),
    .aurora_fbc_end_o               ( aurora_fbc_end[1]                 ),
    .fbc_vld_i                      ( aurora_fbc_vout_vld && fbc_up_en[1]),
    .fbc_data_i                     ( aurora_fbc_vout_data              ),
    .aurora_fbc_almost_full_o       ( aurora_fbc_almost_full_1          ),

    .aurora_scan_reset_i            ( aurora_scan_reset || scan_aurora_reset),
    .aurora_tx_idle_o               ( aurora_tx_idle[1]                 ),
    .eds_pack_cnt_o                 ( eds_pack_cnt_1                    ),
    .encode_pack_cnt_o              ( encode_pack_cnt_1                 ),
    // Reset and clk
    .RESET                          ( aurora_rst_1                      ),
    .PMA_INIT                       ( gt_rst                            ),
    .INIT_CLK_P                     ( clk_50m                           ),
    .DRP_CLK_IN                     ( clk_50m                           ),

    // GTX Reference Clock Interface
    .GTXQ0_P                        ( SFP_MGT_REFCLK0_C_P               ),
    .GTXQ0_N                        ( SFP_MGT_REFCLK0_C_N               ),
    // GT clk to aurora_1_support
    .refclk1_o                      ( GT0_refclk1                       ),
    .gt_qpllclk_quad1_o             ( GT0_qpllclk_quad1                 ),
    .gt_qpllrefclk_quad1_o          ( GT0_qpllrefclk_quad1              ),
    .gt_qpllrefclklost_o            ( GT0_qpllrefclklost                ),
    .gt_qplllock_o                  ( GT0_qplllock                      ),

    // GTX Serial I/O
    .RXP                            ( FPGA_SFP1_RX_P                    ),
    .RXN                            ( FPGA_SFP1_RX_N                    ),
    .TXP                            ( FPGA_SFP1_TX_P                    ),
    .TXN                            ( FPGA_SFP1_TX_N                    )
);

aurora_64b66b_0_exdes aurora_64b66b_exdes_inst_2(
    .aurora_log_clk_o               ( aurora_log_clk_2                  ),
    .aurora_empty_o                 ( aurora_empty_2                    ),
    .aurora_soft_rd_i               ( aurora_soft_rd_2                  ),
    // eds
    .eds_clk_i                      ( eds_clk                           ),  // eds clk -> 100m/6
    .clk_h_i                        ( clk_300m                          ),  // eds clk_h -> 300m
    .eds_sensor_vld_i               ( eds_sensor_data_en                ),
    .eds_sensor_data_i              ( eds_sensor_data                   ),
    .eds_frame_en_i                 ( eds_frame_en && eds_frame_sel[0]  ),
    .pcie_eds_end_o                 ( pcie_eds_frame_end_2              ),

    .precise_encode_en_i            ( align_src_encode_en               ),
    .precise_encode_w_data_i        ( align_src_encode_w                ),
    .precise_encode_x_data_i        ( align_src_encode_x                ),
    .dbg_eds_frame_en_o             ( dbg_eds_frame_en[0]               ),
    .dbg_eds_wencode_vld_o          ( dbg_eds_wencode_vld[0]            ),
    .dbg_eds_wencode_o              ( dbg_eds_wencode[0]                ),

    // pmt
    .pmt_clk_i                      ( clk_100m                          ),  // sys clk -> 100m
    .pmt_encode_vld_i               ( pmt_precise_encode_en_temp && pmt_scan_en[0]            ),
    .pmt_encode_data_i              ( {pmt_precise_encode_w_temp,pmt_precise_encode_x_temp}   ),
    .pmt_start_en_i                 ( pmt_start_en[0]                   ),
    .pcie_pmt_end_o                 ( pcie_pmt_end_en[0]                ),

    // fbc
    .fbc_clk_i                      ( clk_100m                          ),  // sys clk -> 100m
    .fbc_up_start_i                 ( fbc_up_start && fbc_up_en[0]      ),
    .aurora_fbc_end_o               ( aurora_fbc_end[0]                 ),
    .fbc_vld_i                      ( aurora_fbc_vout_vld && fbc_up_en[0]),
    .fbc_data_i                     ( aurora_fbc_vout_data              ),
    .aurora_fbc_almost_full_o       ( aurora_fbc_almost_full_2          ),

    .aurora_scan_reset_i            ( aurora_scan_reset || scan_aurora_reset),
    .aurora_tx_idle_o               ( aurora_tx_idle[0]                 ),
    .eds_pack_cnt_o                 ( eds_pack_cnt_2                    ),
    .encode_pack_cnt_o              ( encode_pack_cnt_2                 ),
    // Reset and clk
    .RESET                          ( aurora_rst_2                      ),
    .PMA_INIT                       ( gt_rst                            ),
    .INIT_CLK_P                     ( clk_50m                           ),
    .DRP_CLK_IN                     ( clk_50m                           ),

    // GTX Reference Clock Interface
    .GTXQ0_P                        ( SFP_MGT_REFCLK1_C_P               ),
    .GTXQ0_N                        ( SFP_MGT_REFCLK1_C_N               ),
    // GT clk to aurora_1_support
    .refclk1_o                      ( GT1_refclk1                       ),
    .gt_qpllclk_quad1_o             ( GT1_qpllclk_quad1                 ),
    .gt_qpllrefclk_quad1_o          ( GT1_qpllrefclk_quad1              ),
    .gt_qpllrefclklost_o            ( GT1_qpllrefclklost                ),
    .gt_qplllock_o                  ( GT1_qplllock                      ),

    // GTX Serial I/O
    .RXP                            ( FPGA_SFP2_RX_P                    ),
    .RXN                            ( FPGA_SFP2_RX_N                    ),
    .TXP                            ( FPGA_SFP2_TX_P                    ),
    .TXN                            ( FPGA_SFP2_TX_N                    )
);

aurora_64b66b_1_exdes aurora_64b66b_exdes_inst_3(
    .aurora_log_clk_o               ( aurora_log_clk_3                  ),
    .aurora_empty_o                 ( aurora_empty_3                    ),
    .aurora_soft_rd_i               ( aurora_soft_rd_3                  ),
    // eds
    .eds_clk_i                      ( eds_clk                           ),  // eds clk -> 100m/6
    .clk_h_i                        ( clk_300m                          ),  // eds clk_h -> 300m
    .eds_sensor_vld_i               ( eds_sensor_data_en                ),
    .eds_sensor_data_i              ( eds_sensor_data                   ),
    .eds_frame_en_i                 ( eds_frame_en && eds_frame_sel[2]  ),
    .pcie_eds_end_o                 ( pcie_eds_frame_end_3              ),

    .precise_encode_en_i            ( align_src_encode_en               ),
    .precise_encode_w_data_i        ( align_src_encode_w                ),
    .precise_encode_x_data_i        ( align_src_encode_x                ),
    .dbg_eds_frame_en_o             ( dbg_eds_frame_en[2]               ),
    .dbg_eds_wencode_vld_o          ( dbg_eds_wencode_vld[2]            ),
    .dbg_eds_wencode_o              ( dbg_eds_wencode[2]                ),

    // pmt
    .pmt_clk_i                      ( clk_100m                          ),  // sys clk -> 100m
    .pmt_encode_vld_i               ( pmt_precise_encode_en_temp && pmt_scan_en[2]            ),
    .pmt_encode_data_i              ( {pmt_precise_encode_w_temp,pmt_precise_encode_x_temp}   ),
    .pmt_start_en_i                 ( pmt_start_en[2]                   ),
    .pcie_pmt_end_o                 ( pcie_pmt_end_en[2]                ),

    // fbc
    .fbc_clk_i                      ( clk_100m                          ),  // sys clk -> 100m
    .fbc_up_start_i                 ( fbc_up_start && fbc_up_en[2]      ),
    .aurora_fbc_end_o               ( aurora_fbc_end[2]                 ),
    .fbc_vld_i                      ( aurora_fbc_vout_vld && fbc_up_en[2]),
    .fbc_data_i                     ( aurora_fbc_vout_data              ),
    .aurora_fbc_almost_full_o       ( aurora_fbc_almost_full_3          ),

    .aurora_scan_reset_i            ( aurora_scan_reset || scan_aurora_reset),
    .aurora_tx_idle_o               ( aurora_tx_idle[2]                 ),
    .eds_pack_cnt_o                 ( eds_pack_cnt_3                    ),
    .encode_pack_cnt_o              ( encode_pack_cnt_3                 ),
    // Reset and clk
    .RESET                          ( aurora_rst_3                      ),
    .PMA_INIT                       ( gt_rst                            ),
    .INIT_CLK_P                     ( clk_50m                           ),
    .DRP_CLK_IN                     ( clk_50m                           ),

    // GTX Reference Clock Interface
    // input               GTXQ0_P                         ,
    // input               GTXQ0_N                         ,
    // GT clk from aurora_0_support
    .refclk1_i                      ( GT1_refclk1                       ),
    .gt_qpllclk_quad1_i             ( GT1_qpllclk_quad1                 ),
    .gt_qpllrefclk_quad1_i          ( GT1_qpllrefclk_quad1              ),
    .gt_qpllrefclklost_i            ( GT1_qpllrefclklost                ),
    .gt_qplllock_i                  ( GT1_qplllock                      ),

    // GTX Serial I/O
    .RXP                            ( FPGA_SFP3_RX_P                    ),
    .RXN                            ( FPGA_SFP3_RX_N                    ),
    .TXP                            ( FPGA_SFP3_TX_P                    ),
    .TXN                            ( FPGA_SFP3_TX_N                    )
);


motion_top_if motion_top_if_inst(
        .clk                        ( clk_100m                          ),
        .rst                        ( rst_100m                          ),

        // .motion_en                  ( 1'b1                              ),
        .cfg_spindle_width_i        ( cfg_spindle_width                 ),

        .x_encoder_a_in             ( X_Encoder_A_IN_LS                 ),
        .x_encoder_b_in             ( X_Encoder_B_IN_LS                 ),
        .x_encoder_z_in             ( X_Encoder_Z_IN_LS                 ),
        .x_encode_zero_calib_i      ( x_encode_zero_calib               ),
        .x_encoder_a_out            ( X_Encoder_A_OUT                   ),
        .x_encoder_b_out            ( X_Encoder_B_OUT                   ),
        .x_encoder_z_out            ( X_Encoder_Z_OUT                   ),

        .w_encoder_clk_out          ( W_Encoder_MA_OUT                  ),
        .w_encoder_data_in          ( W_Encoder_SLO_IN_LS               ),
        .w_encoder_clk_in           ( W_Encoder_MA_IN_LS                ),
        .w_encoder_data_out         ( W_Encoder_SLO_OUT                 ),

        .x_zero_flag                ( x_zero_flag                       ),
        .x_data_out_en              ( x_data_out_en                     ),
        .x_data_out                 ( x_data_out                        ),

        .w_data_out_en              ( w_data_out_en                     ),
        .w_data_out                 ( w_data_out                        ),
        .w_data_error               ( w_data_error                      ),
        .w_data_warn                ( w_data_warn                       )
);


// debug code
encode_continuity_check eds_encode_continuity_check_inst(
    // clk & rst
    .clk_i                      ( clk_100m                                  ),
    .rst_i                      ( rst_100m                                  ),

    .eds_scan_en_i              ( dbg_eds_frame_en[1]                       ),
    .encode_check_clean_i       ( encode_check_clean                        ),
    .src_encode_en_i            ( dbg_eds_wencode_vld[1]                    ),
    .src_encode_w_i             ( dbg_eds_wencode[1]                        ),
    .w_data_error_i             ( 1                                         ),
    .w_data_warn_i              ( 1                                         ),

    .w_encode_err_lock_o        ( w_encode_err_lock                         ),
    .w_encode_warn_lock_o       ( w_encode_warn_lock                        ),
    .w_encode_continuity_max_o  ( w_encode_continuity_max                   ),
    .w_encode_continuity_cnt_o  ( w_encode_continuity_cnt                   )

);

// <<<<<<<<<<<<<<<<<
encode_process_v2 #(
    .FIRST_DELTA_WENCODE        ( 0                                         ),  // 初始 W Encode 增量，用于 first Encode 前插值
    .FIRST_DELTA_XENCODE        ( 0                                         ),  // 初始 X Encode 增量，用于 first Encode 前插值
    .EXTEND_WIDTH               ( 24                                        ),  // 定点位宽
    .UNIT_INTER                 ( 6250                                      ),  // 插值数，= 100M / 16k 
    .DELTA_UPDATE_DOT           ( 2                                         ),  // 插值点倍率
    .DELTA_UPDATE_GAP           ( 2                                         ),  // 插值点倍率, precise_encode_en freq = 16k * UNIT_INTER / DELTA_UPDATE_GAP * DELTA_UPDATE_DOT
    .ENCODE_MASK_WID            ( 18                                        ),  // W Encode 有效位宽，W Encode 零点规定为有效位宽最大值
    .ENCODE_WID                 ( 32                                        )   // Encode 位宽
)pmt_encode_process_inst(
    // clk & rst
    .clk_i                      ( clk_100m                                  ),
    .rst_i                      ( rst_100m                                  ),
    
    .x_zero_flag_i              ( x_zero_flag                               ),
    .encode_update_i            ( w_data_out_en                             ),
    .encode_w_i                 ( w_data_out[31:0]                          ),  // W 无符号数
    .encode_x_i                 ( x_data_out[31:0]                          ),  // X 有符号数

    .precise_encode_en_o        ( precise_encode_en                         ),
    .precise_encode_w_o         ( precise_encode_w                          ),
    .precise_encode_x_o         ( precise_encode_x                          )
);

//
// real time x encode, control real scan start
//
encode_process #(
    .FIRST_DELTA_WENCODE        ( 0                                         ),  // 初始 W Encode 增量，用于 first Encode 前插值
    .FIRST_DELTA_XENCODE        ( 0                                         ),  // 初始 X Encode 增量，用于 first Encode 前插值
    .EXTEND_WIDTH               ( 24                                        ),  // 定点位宽
    .UNIT_INTER                 ( 6250                                      ),  // 插值数，= 100M / 16k 
    .DELTA_UPDATE_DOT           ( 2                                         ),  // 插值点倍率
    .DELTA_UPDATE_GAP           ( 2                                         ),  // 插值点倍率, precise_encode_en freq = 16k * UNIT_INTER / DELTA_UPDATE_GAP * DELTA_UPDATE_DOT
    .ENCODE_MASK_WID            ( 18                                        ),  // W Encode 有效位宽，W Encode 零点规定为有效位宽最大值
    .ENCODE_WID                 ( 32                                        )   // Encode 位宽
)pmt_real_encode_process_inst(
    // clk & rst
    .clk_i                      ( clk_100m                                  ),
    .rst_i                      ( rst_100m                                  ),
    
    .x_zero_flag_i              ( x_zero_flag                               ),
    .encode_update_i            ( w_data_out_en                             ),
    .encode_w_i                 ( w_data_out[31:0]                          ),  // W 无符号数
    .encode_x_i                 ( x_data_out[31:0]                          ),  // X 有符号数

    .precise_encode_en_o        ( real_precise_encode_en                    ),
    .precise_encode_w_o         ( real_precise_encode_w                     ),
    .precise_encode_x_o         ( real_precise_encode_x                     )
);

// acc demo real encode offset
assign acc_demo_encode_en = real_precise_encode_en;
assign acc_demo_encode_w = real_precise_encode_w;
assign acc_demo_encode_x = real_precise_encode_x - precise_encode_offset;

assign clpc_flag         = Safety_in1;
assign acc_flag          = acc_demo_trim_flag;
assign afs_flag          = 'd0;
assign autocal_flag      = autocal_process;
assign timing_flag       = {4'd0,clpc_flag,acc_flag,afs_flag[3:0],autocal_flag[3:0]};

assign align_src_encode_en = precise_encode_en;
assign align_src_encode_w  = precise_encode_w;
assign align_src_encode_x  = precise_encode_x - precise_encode_offset;

encode_align encode_align_inst(
    .clk_i                      ( clk_100m                                  ),
    .rst_i                      ( rst_100m                                  ),

    .encode_sim_en_i            ( encode_sim_en                             ),
    .precise_encode_en_i        ( align_src_encode_en                       ),
    .precise_encode_w_i         ( align_src_encode_w[17:0]                  ),
    .precise_encode_x_i         ( align_src_encode_x[21:4]                  ),

    .pmt_scan_en_i              ( |pmt_scan_en                              ),
    .pmt_Wencode_align_rst_i    ( pmt_Wencode_align_rst                     ),
    .pmt_Wencode_align_set_i    ( pmt_Wencode_align_set                     ),
    .pmt_encode_en_o            ( pmt_precise_encode_en                     ),
    .pmt_encode_w_o             ( pmt_precise_encode_w                      ),
    .pmt_encode_x_o             ( pmt_precise_encode_x                      ),

    // .eds_scan_en_i              ( eds_frame_en                              ),
    // .eds_encode_en_o            ( eds_precise_encode_en                     ),
    // .eds_encode_w_o             ( eds_precise_encode_w                      ),
    // .eds_encode_x_o             ( eds_precise_encode_x                      ),

    .timing_flag_supp_i         ( timing_flag_supp                          ),
    .timing_flag_i              ( timing_flag                               ),
    .align_timing_flag_o        ( align_timing_flag                         )
);

/*************************************
test_encode test_encode_inst(
    // clk & rst
    .clk_i                      ( clk_100m                                  ),
    .rst_i                      ( rst_100m                                  ),
    
    .pmt_encode_en_i            ( debug_encode_en_2                         ),
    .pmt_encode_x_i             ( debug_encode_x_2                          ),
    .pmt_encode_w_i             ( debug_encode_w_2                          ),
    
    .acs_encode_en_i            ( w_data_out_en                             ),
    .acs_encode_x_i             ( x_data_out[31:0]                          ),
    .acs_encode_w_i             ( w_data_out[31:0]                          ),

    .pmt_scan_en_i              ( |pmt_scan_en                              ),
    .test_encode_rst_i          ( encode_interval_rst                       ),
    .pmt_w_encode_thr_i         ( pmt_test_w_encode_thr                     ),
    .acs_w_encode_thr_i         ( acs_test_w_encode_thr                     ),

    .pmt_encode_w_diff_max_o    ( pmt_encode_w_diff_max                     )
    // .pmt_encode_rd_en_i         ( pmt_encode_rd_en                          ),
    // .pmt_x_encode_o             ( pmt_x_encode                              ),
    // .pmt_w_encode_o             ( pmt_w_encode                              ),
    // .pmt_fifo_state_o           ( pmt_fifo_state                            ),

    // .acs_encode_rd_en_i         ( acs_encode_rd_en                          ),
    // .acs_x_encode_o             ( acs_x_encode                              ),
    // .acs_w_encode_o             ( acs_w_encode                              ),
    // .acs_fifo_state_o           ( acs_fifo_state                            )
);
**************************************/
always @(posedge clk_100m) begin
    if(|pmt_start_test_en)begin
        if(|pmt_scan_en)begin
            pmt_precise_encode_w_temp <= pmt_precise_encode_w_temp + 1;
            pmt_precise_encode_x_temp <= pmt_precise_encode_x_temp + 1;
        end
        else begin
            pmt_precise_encode_w_temp <= 'd0;
            pmt_precise_encode_x_temp <= 'd0;
        end
    end
    else if(pmt_precise_encode_en)begin
        pmt_precise_encode_w_temp <= {align_timing_flag[13:0],pmt_precise_encode_w};
        pmt_precise_encode_x_temp <= {14'd0,pmt_precise_encode_x};
    end
    else begin
        pmt_precise_encode_w_temp <= pmt_precise_encode_w_temp;
        pmt_precise_encode_x_temp <= pmt_precise_encode_x_temp;
    end
end

// assign pmt_precise_encode_w_flag = {align_timing_flag[13:0],pmt_precise_encode_w_temp[17:0]};
// assign pmt_precise_encode_x_flag = {pmt_precise_encode_x_temp[31:0]};

always @(posedge clk_100m) begin
    if((|pmt_scan_en) && (|pmt_start_test_en)) 
        pmt_precise_encode_en_temp <= 'd1;
    else 
        pmt_precise_encode_en_temp <= pmt_precise_encode_en;
end

//低VCO频率范围：2150M~2880M
//高VCO频率范围：2650M~3550M
//保证频率范围：2400M~3200M

hmc7044_config #( 
   .CLKOUT0_DIV (12'd28), 
   .CLKOUT1_DIV (12'd28),
   .CLKOUT2_DIV (12'd28),
   .CLKOUT3_DIV (12'd28),
   .CLKOUT4_DIV (12'd28),
   .CLKOUT5_DIV (12'd28),
   .CLKOUT6_DIV (12'd28),
   .CLKOUT7_DIV (12'd28),
   .CLKOUT8_DIV (12'd28),
   .CLKOUT9_DIV (12'd28),
   .CLKOUT10_DIV(12'd28),
   .CLKOUT11_DIV(12'd28),
   .CLKOUT12_DIV(12'd28),
   .CLKOUT13_DIV(12'd28),
   .VCO_L_H(2'b01),		//2'b01:高VCO 2'b10:低VCO
   .CHANNEL_EN(8'b0011_0010),
   .PLL2_R2(12'd1),
   .PLL2_N2(12'd28),
   .CLKEN(14'b00111100001100)
) hmc7044_config_inst1(                                                                                    
		.clk(clk_100m),
		.rst(rst_100m),
		.sync_in(sync_in),
		.HMC7044_SEN(HMC7044_SLEN),
		.HMC7044_SCLK(HMC7044_SCLK),
		.HMC7044_SDATA(HMC7044_SDATA),
		
		.HMC7044_RESET(HMC7044_RESET),
		.HMC7044_SYNC(HMC7044_SYNC),

		.HMC7044_GPIO1(HMC7044_GPIO1),
		.HMC7044_GPIO2(HMC7044_GPIO2),
		.HMC7044_GPIO3(),
		.HMC7044_GPIO4(),
		
		.hmc7044_config_ok(hmc7044_config_ok)
);

ad5592_config #(
	.ADC_IO_REG	(16'b0010000011101111),		//ADC:IO0,IO1,IO2,IO3,IO5,IO6,IO7
	.DAC_IO_REG	(16'b0010100000010000)		//DAC:IO4
) ad5592_config_inst1(
		.clk(clk_100m),
		.rst(rst_100m),
		.dac_config_en(ad5592_1_dac_config_en),
		.dac_channel(ad5592_1_dac_channel),
		.dac_data(ad5592_1_dac_data),
		.adc_config_en(ad5592_1_adc_config_en),
		.adc_channel(ad5592_1_adc_channel),
		
		.spi_csn(AD5592_1_SPI_CS_B),
		.spi_clk(AD5592_1_SPI_CLK),
		.spi_mosi(AD5592_1_SPI_MOSI),
		.spi_miso(AD5592_1_SPI_MISO),
		.spi_conf_ok(ad5592_1_spi_conf_ok),
		.init(ad5592_1_init),
		.adc_data_en(ad5592_1_adc_data_en),
		.adc_data(ad5592_1_adc_data)	
);

ad5592_config #(
	.ADC_IO_REG	(16'b0010000000001111),		//ADC:IO0,IO1,IO2,IO3
	.DAC_IO_REG	(16'b0010100011110000)		//DAC:IO4,IO5,IO6,IO7
) ad5592_config_inst2(
		.clk(clk_100m),
		.rst(rst_100m),
		.dac_config_en(ad5592_2_dac_config_en),
		.dac_channel(ad5592_2_dac_channel),
		.dac_data(ad5592_2_dac_data),
		.adc_config_en(ad5592_2_adc_config_en),
		.adc_channel(ad5592_2_adc_channel),
		
		.spi_csn(AD5592_2_SPI_CS_B),
		.spi_clk(AD5592_2_SPI_CLK),
		.spi_mosi(AD5592_2_SPI_MOSI),
		.spi_miso(AD5592_2_SPI_MISO),
		.spi_conf_ok(ad5592_2_spi_conf_ok),
		.init(ad5592_2_init),
		.adc_data_en(ad5592_2_adc_data_en),
		.adc_data(ad5592_2_adc_data)	
);

// TMP75 TMP75_inst(
// 		.clk(clk_100m),
// 		.rst(rst_100m),
// 		.TEMP_SCL(TMP75_IIC_SCL),
// 		.TEMP_SDA(TMP75_IIC_SDA),
		
// 		.TEMP_RD_en(temp_rd_en),
		
// 		.TEMP_DATA(temp_data),
// 		.TEMP_DATA_en(temp_data_en)
// );

// eeprom eeprom_inst(
// 		.clk(clk_100m),
// 		.rst(rst_100m),
// 		.addr_data_w(eeprom_w_addr_data),
// 		.addr_data_w_en(eeprom_w_en),
// 		.addr_r(eeprom_r_addr),
// 		.addr_r_en(eeprom_r_addr_en),
// 		.data_r(eeprom_r_data),
// 		.data_r_en(eeprom_r_data_en),
						
// 		.spi_cs(EEPROM_CS_B),
// 		.spi_sck(EEPROM_SCK),
// 		.spi_dout(EEPROM_SI),
// 		.spi_din(EEPROM_SO),
// 		.eeprom_wp_n(EEPROM_WP_B),
// 		.eeprom_hold_n(),
// 		.spi_ok(eeprom_spi_ok)
// );


endmodule
