//~ `New testbench
`timescale  1ns / 1ps

module tb_slave_comm;

// mfpga_top Parameters
parameter PERIOD  = 10;

reg rst = 'd1;
reg clk_100m = 'd0;



reg   FPGA_TO_SFPGA_RESERVE0               = 0 ;
reg   FPGA_TO_SFPGA_RESERVE1               = 0 ;
reg   FPGA_TO_SFPGA_RESERVE2               = 0 ;
reg   FPGA_TO_SFPGA_RESERVE6               = 0 ;
reg   FPGA_TO_SFPGA_RESERVE7               = 0 ;
reg   FPGA_TO_SFPGA_RESERVE8               = 0 ;
reg   FPGA_TO_SFPGA_RESERVE9               = 0 ;



wire  FPGA_TO_SFPGA_RESERVE3               ;
wire  FPGA_TO_SFPGA_RESERVE4               ;
wire  FPGA_TO_SFPGA_RESERVE5               ;

wire                slave_tx_ack         ;
wire                slave_tx_byte_en     ;
wire    [ 7:0]      slave_tx_byte        ;
wire                slave_tx_byte_num_en ;
wire    [15:0]      slave_tx_byte_num    ;
wire                slave_rx_data_vld    ;
wire    [ 7:0]      slave_rx_data        ;

`ifdef SIMULATE
reg [32-1:0] sim_cnt = 'd0;
always @(posedge clk_100m) begin
    if(sim_cnt <= 'd60_000 - 1)
        sim_cnt <= sim_cnt + 1;
    else 
        sim_cnt <= 'd0;
end

reg               bpsi_data_0_en_sim = 'd0;
reg   [23:0]      bpsi_data_0_a_sim  = 'd0;
reg   [23:0]      bpsi_data_0_b_sim  = 'd0;
reg               bpsi_data_1_en_sim = 'd0;
reg   [23:0]      bpsi_data_1_a_sim  = 'd0;
reg   [23:0]      bpsi_data_1_b_sim  = 'd0;
reg               bpsi_data_2_en_sim = 'd0;
reg   [23:0]      bpsi_data_2_a_sim  = 'd0;
reg   [23:0]      bpsi_data_2_b_sim  = 'd0;
always @(posedge clk_100m) begin
    if(sim_cnt == 'd60_000)begin
        bpsi_data_0_en_sim <= 'd1;
        bpsi_data_0_a_sim <= 'h010203;
        bpsi_data_0_b_sim <= 'h111213;
        bpsi_data_1_en_sim <= 'd1;
        bpsi_data_1_a_sim <= 'h040506;
        bpsi_data_1_b_sim <= 'h141516;
        bpsi_data_2_en_sim <= 'd1;
        bpsi_data_2_a_sim <= 'h070809;
        bpsi_data_2_b_sim <= 'h171819;
    end
    else begin
        
        bpsi_data_0_en_sim <= 'd0;
        bpsi_data_1_en_sim <= 'd0;
        bpsi_data_2_en_sim <= 'd0;
    end
end

`endif //SIMULATE


arbitrate_bpsi arbitrate_bpsi_inst(
    .clk_i                       ( clk_100m                     ),
    .rst_i                       ( rst                          ),
`ifdef SIMULATE
    .bpsi_0_data_en_i            ( bpsi_data_0_en_sim           ),
    .bpsi_0_data_a_i             ( bpsi_data_0_a_sim            ),
    .bpsi_0_data_b_i             ( bpsi_data_0_b_sim            ),
    .bpsi_1_data_en_i            ( bpsi_data_1_en_sim           ),
    .bpsi_1_data_a_i             ( bpsi_data_1_a_sim            ),
    .bpsi_1_data_b_i             ( bpsi_data_1_b_sim            ),
    .bpsi_2_data_en_i            ( bpsi_data_2_en_sim           ),
    .bpsi_2_data_a_i             ( bpsi_data_2_a_sim            ),
    .bpsi_2_data_b_i             ( bpsi_data_2_b_sim            ),
`else
    .bpsi_0_data_en_i            ( bpsi_data_en                 ),
    .bpsi_0_data_a_i             ( bpsi_data_a                  ),
    .bpsi_0_data_b_i             ( bpsi_data_b                  ),
    .bpsi_1_data_en_i            ( 'd0                          ),
    .bpsi_1_data_a_i             ( 'd0                          ),
    .bpsi_1_data_b_i             ( 'd0                          ),
    .bpsi_2_data_en_i            ( 'd0                          ),
    .bpsi_2_data_a_i             ( 'd0                          ),
    .bpsi_2_data_b_i             ( 'd0                          ),
`endif //SIMULATE
    .slave_tx_ack_i              ( slave_tx_ack                 ),
    .slave_tx_byte_en_o          ( slave_tx_byte_en             ),
    .slave_tx_byte_o             ( slave_tx_byte                ),
    .slave_tx_byte_num_en_o      ( slave_tx_byte_num_en         ),
    .slave_tx_byte_num_o         ( slave_tx_byte_num            )

);

slave_comm slave_comm_inst(
    // clk & rst
    .clk_sys_i                  ( clk_100m                      ),
    .rst_i                      ( rst                           ),
    // salve tx info
    .slave_tx_en_i              ( slave_tx_byte_en              ),
    .slave_tx_data_i            ( slave_tx_byte                 ),
    .slave_tx_byte_num_en_i     ( slave_tx_byte_num_en          ),
    .slave_tx_byte_num_i        ( slave_tx_byte_num             ),
    .slave_tx_ack_o             ( slave_tx_ack                  ),
    // slave rx info
    .rd_data_vld_o              ( slave_rx_data_vld             ),
    .rd_data_o                  ( slave_rx_data                 ),
    // info
    .SLAVE_MSG_CLK              ( FPGA_TO_SFPGA_RESERVE0        ),
    .SLAVE_MSG_TX_FSX           ( FPGA_TO_SFPGA_RESERVE3        ),
    .SLAVE_MSG_TX               ( FPGA_TO_SFPGA_RESERVE4        ),
    .SLAVE_MSG_RX_FSX           ( FPGA_TO_SFPGA_RESERVE1        ),
    .SLAVE_MSG_RX               ( FPGA_TO_SFPGA_RESERVE2        )
);

initial
begin
    forever #(PERIOD/2)  clk_100m=~clk_100m;
end

initial
begin
    forever #(20/2)  FPGA_TO_SFPGA_RESERVE0=~FPGA_TO_SFPGA_RESERVE0;
end

initial
begin
    #(PERIOD*2) rst  =  0;
end


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

    $finish;
end

endmodule