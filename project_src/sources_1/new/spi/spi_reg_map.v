`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/06/19
// Design Name: PCG
// Module Name: spi_reg_map
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


module spi_reg_map #(
    parameter                               TCQ        = 0.1,
    parameter                               DATA_WIDTH = 32 ,
    parameter                               ADDR_WIDTH = 16 ,
    parameter       [32*5-1:0]              pmt_mfpga_version = "PCG1_PMTM_v1.0      "
)(
    // clk & rst
    input   wire                            clk_i               ,
    input   wire                            rst_i               ,

    input   wire                            slave_wr_en_i       ,
    input   wire    [ADDR_WIDTH-1:0]        slave_addr_i        ,
    input   wire    [DATA_WIDTH-1:0]        slave_wr_data_i     ,
    input   wire                            slave_rd_en_i       ,
    output  wire                            slave_rd_vld_o      ,
    output  wire    [DATA_WIDTH-1:0]        slave_rd_data_o     ,

    output  wire    [32-1:0]                first_reg_o         ,
    output  wire                            encode_update_o     ,
    output  wire    [16-1:0]                encode_w_o          ,
    output  wire    [16-1:0]                encode_x_o          ,
    output  wire    [1-1:0]                 laser_adc_start_o   ,
    output  wire    [1-1:0]                 laser_adc_stop_o    ,
    output  wire    [1-1:0]                 laser_adc_test_o    ,

    output  wire                            ad5592_1_dac_config_en_o    ,
    output  wire    [2:0]                   ad5592_1_dac_channel_o      ,
    output  wire    [11:0]                  ad5592_1_dac_data_o         ,
    output  wire                            ADC_offset_en_o             ,
    output  wire    [16-1:0]                ADC_offset_o                ,
    output  wire                            acc_defect_en_o             ,
    output  wire    [16-1:0]                acc_defect_thre_o           ,
    output                                  bst_vcc_en_o                ,

    output  wire                            debug_info
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>






//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                                 slave_rd_vld_r  = 'd0;
(*DONT_TOUCH = "yes"*)reg     [DATA_WIDTH-1:0]            slave_rd_data_r = 'd0;

// reg     [32*5-1:0]                  pmt_mfpga_version = "PCG1_PMTM_v1.1      ";

reg     [32-1:0]                    first_reg       = 'd0;
reg                                 encode_update   = 'd0;
reg     [32-1:0]                    encode_w        = 'd0;
reg     [32-1:0]                    encode_x        = 'd0;
reg     [8-1:0]                     laser_adc_start = 'd0;
reg     [8-1:0]                     laser_adc_stop  = 'd0;

reg                                 set_pmt_hv_en   = 'd0;
reg     [32-1:0]                    SetPMTHV        = 'd0;
reg                                 ADC_offset_en   = 'd0;
reg     [32-1:0]                    ADC_offset      = 'd0;
reg     [32-1:0]                    acc_defect_thre = 'd0;
reg                                 bst_vcc_en      = 'd1;


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// write register
always @(posedge clk_i) begin
    if(slave_wr_en_i)begin
        case (slave_addr_i)
            16'h0000: first_reg         <= #TCQ slave_wr_data_i;
            16'h0004: encode_w          <= #TCQ slave_wr_data_i;
            16'h0008: encode_x          <= #TCQ slave_wr_data_i;
            16'h000c: laser_adc_start   <= #TCQ slave_wr_data_i;
            // 16'h0010: laser_adc_stop    <= #TCQ slave_wr_data_i;
            16'h0014: acc_defect_thre   <= #TCQ slave_wr_data_i;
            16'h0018: ADC_offset        <= #TCQ slave_wr_data_i;
            16'h001c: SetPMTHV          <= #TCQ slave_wr_data_i;
            16'h0020: bst_vcc_en        <= #TCQ slave_wr_data_i[0];
            default: /*default*/;
        endcase
    end
end



// read register
always @(posedge clk_i) begin
    if(slave_rd_en_i)begin
        case (slave_addr_i)
            16'h0000: slave_rd_data_r <= #TCQ first_reg         ;
            16'h0004: slave_rd_data_r <= #TCQ encode_w          ;
            16'h0008: slave_rd_data_r <= #TCQ encode_x          ;
            16'h000c: slave_rd_data_r <= #TCQ laser_adc_start   ;
            // 16'h0010: slave_rd_data_r <= #TCQ laser_adc_stop    ;
            16'h0014: slave_rd_data_r <= #TCQ acc_defect_thre   ;
            16'h0018: slave_rd_data_r <= #TCQ ADC_offset        ;
            16'h001c: slave_rd_data_r <= #TCQ SetPMTHV          ;
            16'h0020: slave_rd_data_r <= #TCQ {31'd0,bst_vcc_en};

            
            16'h1000: slave_rd_data_r <= #TCQ pmt_mfpga_version[32*4 +: 32];
            16'h1004: slave_rd_data_r <= #TCQ pmt_mfpga_version[32*3 +: 32];
            16'h1008: slave_rd_data_r <= #TCQ pmt_mfpga_version[32*2 +: 32];
            16'h100c: slave_rd_data_r <= #TCQ pmt_mfpga_version[32*1 +: 32];
            16'h1010: slave_rd_data_r <= #TCQ pmt_mfpga_version[32*0 +: 32];
            
            default: slave_rd_data_r <= #TCQ 32'h00DEAD00;
        endcase
    end
end

// use valid control delay, ability to align register with fifo output.
always @(posedge clk_i) begin
    slave_rd_vld_r <= #TCQ slave_rd_en_i;
end

always @(posedge clk_i) begin
    encode_update <= slave_wr_en_i && slave_addr_i=='h0008;
end

always @(posedge clk_i) begin
    if(slave_wr_en_i && slave_addr_i=='h001c)
        set_pmt_hv_en <= #TCQ 'd1;
    else 
        set_pmt_hv_en <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(slave_wr_en_i && slave_addr_i=='h0018)
        ADC_offset_en <= #TCQ 'd1;
    else 
        ADC_offset_en <= #TCQ 'd0;
end

assign slave_rd_vld_o           = slave_rd_vld_r    ;
assign slave_rd_data_o          = slave_rd_data_r   ;

assign first_reg_o              = first_reg         ;
assign encode_update_o          = encode_update     ;
assign encode_w_o               = encode_w          ;
assign encode_x_o               = encode_x          ;
assign laser_adc_start_o        = laser_adc_start[0];
assign laser_adc_stop_o         = laser_adc_stop[0] ;
assign laser_adc_test_o         = laser_adc_start[1];
assign ad5592_1_dac_config_en_o = set_pmt_hv_en     ;
assign ad5592_1_dac_channel_o   = 3'd6              ;
assign ad5592_1_dac_data_o      = SetPMTHV[11:0]    ;
assign ADC_offset_en_o          = ADC_offset_en     ;
assign ADC_offset_o             = ADC_offset[15:0]  ;
assign acc_defect_en_o          = acc_defect_thre[24];  
assign acc_defect_thre_o        = acc_defect_thre[15:0];
assign bst_vcc_en_o             = bst_vcc_en;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

endmodule
