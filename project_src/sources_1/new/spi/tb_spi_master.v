//~ `New testbench
`timescale  1ns / 1ps

module tb_spi_master;

// spi_master Parameters
parameter PERIOD      = 10 ;
parameter PERIOD5      = 5 ;
parameter TCQ         = 0.1;
parameter DUMMY_NUM   = 12 ;
parameter DATA_WIDTH  = 32 ;
parameter ADDR_WIDTH  = 16 ;
parameter CMD_WIDTH   = 8  ;
parameter SERIAL_MODE    = 1  ;
genvar i;
// spi_master Inputs
reg   clk_i                                = 0 ;
reg   clk_200m_i                           = 0 ;
reg   rst_i                                = 0 ;
reg   spi_en_i                             = 0 ;
reg   [CMD_WIDTH-1:0]  spi_cmd_i           = 0 ;
reg   [ADDR_WIDTH-1:0]  spi_addr_i         = 0 ;
reg   [DATA_WIDTH-1:0]  spi_wr_data_i      = 0 ;

// spi_master Outputs
wire  spi_wr_seq_o                         ;
wire  spi_rd_vld_o                         ;
wire  spi_busy_o                           ;
wire                           SPI_MCLK    ;
wire   [SERIAL_MODE-1:0]       SPI_MOSI    ;
wire                           SPI_SCLK    ;
wire   [SERIAL_MODE-1:0]       SPI_MISO    ;

wire    [2:0]       PMT_SPI_SENABLE      ;
wire    [2:0]       PMT_SPI_MENABLE      ;
wire    [2:0]       PMT_SPI_MCLK         ;
wire    [2:0]       PMT_SPI_MOSI         ;
wire    [2:0]       PMT_SPI_SCLK         ;
wire    [2:0]       PMT_SPI_MISO         ;
// spi_slave_drv Outputs
wire                    slave_rd_vld       ;
wire  [DATA_WIDTH-1:0]  slave_rd_data      ;
wire                    slave_wr_en        ;
wire  [ADDR_WIDTH-1:0]  slave_addr         ;
wire  [DATA_WIDTH-1:0]  slave_wr_data      ;
wire                    slave_rd_en        ;
wire  [ADDR_WIDTH-1:0]  slave_rd_addr      ;

wire                slave_tx_ack            ;
wire                slave_tx_byte_en        ;
wire    [ 7:0]      slave_tx_byte           ;
wire                slave_tx_byte_num_en    ;
wire    [15:0]      slave_tx_byte_num       ;
wire                slave_rx_data_vld       ;
wire    [ 7:0]      slave_rx_data           ;
reg   [32-1:0]     pmt_master_spi_data    = 0 ;
reg                pmt_master_spi_vld     = 0 ;
wire   [32-1:0]     pmt_master_wr_data      ;
wire    [ 1:0]      pmt_master_wr_vld       ;
reg   [32-1:0]     pmt_adc_start_data    = 'd0   ;
reg                pmt_adc_start_vld     = 'd0   ;
reg   [32-1:0]     pmt_adc_start_hold    = 'd1   ;
wire   [2:0]             rd_ack_timeout_rst  = 'd0;
wire   [2:0]             spi_slave_ack_vld   ;
wire   [2:0]             spi_slave_ack_last  ;
wire   [32-1:0]     spi_slave_ack_data  [2:0];
wire    [2:0]       pmt_master_cmd_parser  ;
initial
begin
    forever #(PERIOD/2)  clk_i=~clk_i;
end
initial
begin
    forever #(2.5)  clk_200m_i=~clk_200m_i;
end


initial
begin
    #(PERIOD*2) rst_i  =  1;
    #(PERIOD*2) rst_i  =  0;
end

// mfpga to mainPC message arbitrate 
arbitrate_bpsi arbitrate_bpsi_inst(
    .clk_i                          ( clk_i                         ),
    .rst_i                          ( rst_i                         ),

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

    .slave_tx_ack_i                 ( slave_tx_ack                  ),
    .slave_tx_byte_en_o             ( slave_tx_byte_en              ),
    .slave_tx_byte_o                ( slave_tx_byte                 ),
    .slave_tx_byte_num_en_o         ( slave_tx_byte_num_en          ),
    .slave_tx_byte_num_o            ( slave_tx_byte_num             )
);

slave_comm slave_comm_inst(
    // clk & rst
    .clk_sys_i                      ( clk_i                         ),
    .rst_i                          ( rst_i                         ),
    // salve tx info
    .slave_tx_en_i                  ( slave_tx_byte_en              ),
    .slave_tx_data_i                ( slave_tx_byte                 ),
    .slave_tx_byte_num_en_i         ( slave_tx_byte_num_en          ),
    .slave_tx_byte_num_i            ( slave_tx_byte_num             ),
    .slave_tx_ack_o                 ( slave_tx_ack                  ),
    // slave rx info
    .rd_data_vld_o                  (        ),
    .rd_data_o                      (        ),
    // info
    .SLAVE_MSG_CLK                  (        ),
    .SLAVE_MSG_TX_FSX               (        ),
    .SLAVE_MSG_TX                   (        ),
    .SLAVE_MSG_RX_FSX               (        ),
    .SLAVE_MSG_RX                   (        )
);

pmt_master_sel pmt_master_sel_inst(
    // clk & rst
    .clk_i                          ( clk_i                         ),
    .rst_i                          ( rst_i                         ),
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
            .clk_i                          ( clk_i                         ),
            .rst_i                          ( rst_i                         ),
            .clk_200m_i                     ( clk_200m_i                    ),
            .master_wr_data_i               ( pmt_master_wr_data            ),
            .master_wr_vld_i                ( pmt_master_wr_vld             ),
            .pmt_master_cmd_parser_o        ( pmt_master_cmd_parser[i]      ),
        
            // .rd_ack_timeout_rst_o           ( rd_ack_timeout_rst[i]         ),
            .slave_ack_vld_o                ( spi_slave_ack_vld[i]          ),
            .slave_ack_last_o               ( spi_slave_ack_last[i]         ),
            .slave_ack_data_o               ( spi_slave_ack_data[i]         ),
            // spi info
            // .PMT_SPI_SENABLE                ( PMT_SPI_SENABLE[i]            ),
            // .PMT_SPI_MENABLE                ( PMT_SPI_MENABLE[i]            ),
            .SPI_MCLK                       ( PMT_SPI_MCLK[i]               ),
            .SPI_MOSI                       ( PMT_SPI_MOSI[i]               ),
            .SPI_SCLK                       ( PMT_SPI_SCLK[i]               ),
            .SPI_MISO                       ( PMT_SPI_MISO[i]               )
        );
    end
endgenerate

reg                 encode_en_i         = 'd0;
reg     [32-1:0]    encode_w_data_i     = 'd0;
reg                 pmt_scan_en         = 'd0;
wire    [2:0]       ENCODE_SPI_MCLK       ;
wire    [2:0]       ENCODE_SPI_MOSI       ;

wire    [3-1:0]     pmt_scan_cmd_sel                ;
wire    [4-1:0]     pmt_scan_cmd                    ;
wire    [2:0]       pmt_start_en                    ;
wire    [2:0]       pmt_start_test_en               ;

scan_cmd_ctrl scan_cmd_ctrl_inst(
    // clk & rst
    .clk_i                          ( clk_i                         ),
    .rst_i                          ( rst_i                         ),
    // scan control single
    .real_scan_flag_i               ( pmt_scan_en                   ),
    .real_scan_sel_i                ( 'd7                           ),
    .pmt_adc_start_data_i           ( pmt_adc_start_data            ),
    .pmt_adc_start_vld_i            ( pmt_adc_start_vld             ),
    .pmt_adc_start_hold_i           ( pmt_adc_start_hold            ),

    .pmt_scan_cmd_sel_o             ( pmt_scan_cmd_sel              ),   // bit[0]:pmt1; bit[1]:pmt2; bit[2]:pmt3
    .pmt_scan_cmd_o                 ( pmt_scan_cmd                  )    // bit[0]:scan start; bit[1]:scan test
);

generate
    for(i=0;i<3;i=i+1)begin : PMT_SPI_ENCODE
        encode_tx_drv encode_tx_drv_inst(
            // clk & rst
            .clk_i              ( clk_i                                 ),
            .rst_i              ( rst_i                                 ),
            .clk_200m_i         ( clk_200m_i                            ),

            .precise_encode_w_i ( encode_w_data_i                       ),

            .pmt_scan_cmd_sel_i ( pmt_scan_cmd_sel[i]                   ),   // pmt sel
            .pmt_scan_cmd_i     ( pmt_scan_cmd                          ),   // bit[0]:scan start; bit[1]:scan test
            .pmt_start_en_o     ( pmt_start_en[i]                       ),
            .pmt_start_test_en_o( pmt_start_test_en[i]                  ),

            // spi info
            .SPI_MCLK           ( ENCODE_SPI_MCLK[i]                    ),
            .SPI_MOSI           ( ENCODE_SPI_MOSI[i]                    )
        );
    end
endgenerate

always @(posedge clk_i) begin
    if(rst_i)
        pmt_scan_en <= 'd0;
    else 
        pmt_scan_en <= #1000 'd1;
end

reg [3-1:0] encode_w_cnt = 'd0;
always @(posedge clk_i) begin
    encode_w_cnt <= encode_w_cnt + 1;
end

always @(posedge clk_i) begin
    if(encode_w_data_i == 'd1250)
        encode_w_data_i <= 'd0;
    else if(&encode_w_cnt)
        encode_w_data_i <= encode_w_data_i + 1;
end

encode_rx_drv encode_rx_drv_inst(
    // clk & rst
    .clk_i                   ( clk_i                            ),
    .rst_i                   ( rst_i                            ),
    .clk_200m_i              ( clk_200m_i                       ),

    .encode_zero_flag_o      (                                  ),

    // spi info
    .SPI_MCLK                ( ENCODE_SPI_MCLK[0]                  ),
    .SPI_MOSI                ( ENCODE_SPI_MOSI[0]                  )
);

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> simulate slave
serial_slave_drv #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .ADDR_WIDTH ( ADDR_WIDTH ),
    .CMD_WIDTH  ( CMD_WIDTH  ),
    .SERIAL_MODE   ( SERIAL_MODE   ))
 u_spi_slave_drv (
    .clk_i                   ( clk_i                             ),
    .rst_i                   ( rst_i                             ),
    .clk_200m_i              ( clk_200m_i                        ),
    .slave_rd_vld_i          ( slave_rd_vld                      ),
    .slave_rd_data_i         ( slave_rd_data    [DATA_WIDTH-1:0] ),

    .slave_wr_en_o           ( slave_wr_en                       ),
    .slave_addr_o            ( slave_addr       [ADDR_WIDTH-1:0] ),
    .slave_wr_data_o         ( slave_wr_data    [DATA_WIDTH-1:0] ),
    .slave_rd_en_o           ( slave_rd_en                       ),
    // .SPI_SENABLE             ( PMT_SPI_SENABLE[2]                ),
    // .SPI_MENABLE             ( PMT_SPI_MENABLE[2]                ),
    .SPI_MCLK                ( PMT_SPI_MCLK[2]                   ),
    .SPI_MOSI                ( PMT_SPI_MOSI[2]                   ),
    .SPI_SCLK                ( PMT_SPI_SCLK[2]                   ),
    .SPI_MISO                ( PMT_SPI_MISO[2]                   )
);

spi_reg_map #(
    .DATA_WIDTH             ( DATA_WIDTH                        ),
    .ADDR_WIDTH             ( ADDR_WIDTH                        )
)spi_reg_map_inst(
    // clk & rst
    .clk_i                  ( clk_i                             ),
    .rst_i                  ( rst_i                             ),

    .slave_wr_en_i          ( slave_wr_en                       ), 
    .slave_addr_i           ( slave_addr                        ),
    .slave_wr_data_i        ( slave_wr_data                     ),
    .slave_rd_en_i          ( slave_rd_en                       ),
    .slave_rd_vld_o         ( slave_rd_vld                      ),
    .slave_rd_data_o        ( slave_rd_data                     ),

    .debug_info             (                                   )
);


initial
begin
    wait(pmt_start_en);
    #10000;
    pmt_master_spi_vld = 1;
    pmt_master_spi_data = 'h0000_04_00;
    #10;
    pmt_master_spi_vld = 0;
    #100;
    pmt_master_spi_vld = 1;
    pmt_master_spi_data = 'h0000_A7_4b;
    // #10;
    // pmt_master_spi_data = 'h0000_0004;
    // #10;
    // pmt_master_spi_data = 'h0000_0001;
    // #10;
    // pmt_master_spi_data = 'h0000_0002;
    // #10;
    // pmt_master_spi_data = 'h0000_0003;
    #10;
    pmt_master_spi_vld = 0;
    #5000;
    pmt_master_spi_vld = 1;
    pmt_master_spi_data = 'h0000_04_80;
    #10;
    pmt_master_spi_vld = 0;
    #10000;
    pmt_master_spi_vld = 1;
    pmt_master_spi_data = 'h0000_04_00;
    #10;
    pmt_master_spi_data = 'h0000_76c8;
    #10;
    pmt_master_spi_vld = 0;
    #5000;
    pmt_master_spi_vld = 1;
    pmt_master_spi_data = 'h0000_04_80;
    #10;
    pmt_master_spi_vld = 0;

    
    #5000;
    pmt_adc_start_data = 'h0000_04_03;
    pmt_adc_start_vld  = 'd1;
    #10;
    pmt_adc_start_vld  = 'd0;

    #10000;
    $finish;
end

endmodule