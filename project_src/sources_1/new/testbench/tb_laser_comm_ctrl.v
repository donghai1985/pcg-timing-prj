//~ `New testbench
`timescale  1ns / 1ps

module tb_laser_comm_ctrl;

// laser_comm_ctrl Parameters
parameter PERIOD = 10 ;
parameter TCQ  = 0.1;

// laser_comm_ctrl Inputs
reg   clk_100m                             = 0 ;
reg   clk_50m                              = 0 ;
reg   clk_eth                              = 0 ;
reg   rst                                  = 1 ;

reg                         rec_pkt_done_i      = 'd0;
reg                         rec_en_i            = 'd0;
reg    [7:0]                rec_data_i          = 'd0;
reg                         rec_byte_num_en_i   = 'd0;
reg    [15:0]               rec_byte_num_i      = 'd0;
reg                         s_axis_tvalid       = 'd0;
reg    [ 8-1:0]             s_axis_tdata        = 'd0;

// laser_comm_ctrl Outputs
wire    [32-1:0]    laser_tx_data       ;
wire                laser_tx_vld        ;
wire    [7:0]       laser_rx_data       ;
wire                laser_rx_vld        ;
wire                laser_rx_last       ;
wire                slave_tx_ack         ;
wire                slave_tx_byte_en     ;
wire    [ 7:0]      slave_tx_byte        ;
wire                slave_tx_byte_num_en ;
wire    [15:0]      slave_tx_byte_num    ;
wire                slave_rx_data_vld    ;
wire    [ 7:0]      slave_rx_data        ;
wire                UART_TX ;
wire                UART_RX ;
wire		FPGA_TO_SFPGA_RESERVE0;
wire		FPGA_TO_SFPGA_RESERVE1;
wire		FPGA_TO_SFPGA_RESERVE2;
wire		FPGA_TO_SFPGA_RESERVE3;
wire		FPGA_TO_SFPGA_RESERVE4;
wire                         s_axis_tready;



initial
begin
    forever #(PERIOD/2)  clk_100m=~clk_100m;
end

initial
begin
    forever #(20/2)  clk_50m=~clk_50m;
end
initial
begin
    forever #(8/2)  clk_eth=~clk_eth;
end

initial
begin
    #(PERIOD*2) rst  =  0;
end


// mfpga to mainPC message arbitrate 
arbitrate_bpsi arbitrate_bpsi_inst(
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst                           ),
    
    .laser_rx_data_i                ( laser_rx_data                 ), // laser uart
    .laser_rx_vld_i                 ( laser_rx_vld                  ), // laser uart
    .laser_rx_last_i                ( laser_rx_last                 ), // laser uart

    .slave_tx_ack_i                 ( slave_tx_ack                  ),
    .slave_tx_byte_en_o             ( slave_tx_byte_en              ),
    .slave_tx_byte_o                ( slave_tx_byte                 ),
    .slave_tx_byte_num_en_o         ( slave_tx_byte_num_en          ),
    .slave_tx_byte_num_o            ( slave_tx_byte_num             )

);

slave_comm slave_comm_inst(
    // clk & rst
    .clk_sys_i                      ( clk_100m                      ),
    .rst_i                          ( rst                           ),
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
    .rst_i                          ( rst                           ),
    .slave_rx_data_vld_i            ( slave_rx_data_vld             ),
    .slave_rx_data_i                ( slave_rx_data                 ),
    
    
    .laser_uart_data_o              ( laser_tx_data                 ),
    .laser_uart_vld_o               ( laser_tx_vld                  ),

    .debug_info                     (                      )   
);


laser_comm_ctrl laser_comm_ctrl_inst(
    // clk & rst
    .clk_i                          ( clk_100m                      ),
    .rst_i                          ( rst                           ),
    
    .laser_tx_data_i                ( laser_tx_data                 ),
    .laser_tx_vld_i                 ( laser_tx_vld                  ),
    .laser_rx_data_o                ( laser_rx_data                 ),
    .laser_rx_vld_o                 ( laser_rx_vld                  ),
    .laser_rx_last_o                ( laser_rx_last                 ),

    // interface    
    .LASER_UART_RXD                 ( UART_RX                       ),
    .LASER_UART_TXD                 ( UART_TX                       )
);

message_comm_tx message_comm_tx_inst(
    .phy_rx_clk          ( clk_eth              ),
    .clk                 ( clk_50m              ),
    .rst_n               ( ~rst                 ),
    .rec_en_i            ( rec_en_i             ),
    .rec_data_i          ( rec_data_i           ),
    .rec_byte_num_en_i   ( rec_byte_num_en_i    ),
    .rec_byte_num_i      ( rec_byte_num_i       ),
    .comm_ack_o          ( comm_ack_o           ),

    .MSG_CLK             ( FPGA_TO_SFPGA_RESERVE0               ),
    .MSG_TX_FSX          ( FPGA_TO_SFPGA_RESERVE1               ),
    .MSG_TX              ( FPGA_TO_SFPGA_RESERVE2               )
);

uart_tx #(
    .DATA_WIDTH(8)
)
uart_tx_inst (
    .clk(clk_100m),
    .rst(rst),
    // axi input
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    // output
    .txd(UART_RX),
    // status
    .busy(tx_busy),
    // configuration
    .prescale(16'd1302)
);

reg [7:0] ram_sim[0:17];
initial
begin
    $readmemh ("D:/work/project/FPGA/timing_mfpga_prj/project_1/project_1.srcs/sources_1/new/testbench/sim_test.txt", ram_sim);
end
reg laser_uart_en= 'd0;
reg [5-1:0] rec_tx_cnt = 'd0;
always @(posedge clk_eth) begin
    if(laser_uart_en)
        rec_tx_cnt <= rec_tx_cnt + 1;
    else 
        rec_tx_cnt <= 'd0; 
end

always @(posedge clk_eth) begin
    rec_data_i <= ram_sim[rec_tx_cnt];
    rec_en_i <= laser_uart_en;
end

reg laser_uart_enrx= 'd0;
reg [5-1:0] rec_rx_cnt = 'd2;
always @(posedge clk_100m) begin
    if(laser_uart_enrx)begin
        if(s_axis_tready && ~s_axis_tvalid && rec_rx_cnt<'d18)begin
            s_axis_tvalid <= 'd1;
            s_axis_tdata <= ram_sim[rec_rx_cnt];
            rec_rx_cnt <= rec_rx_cnt + 1;
        end
        else begin
            s_axis_tvalid <= 'd0;
        end
    end 
    else begin
        rec_rx_cnt <= 'd2;
        s_axis_tvalid <= 'd0;
    end
end



initial
begin

    #1000;
    laser_uart_en = 1;
    rec_byte_num_en_i = 1;
    rec_byte_num_i = 'd18;
    #8;
    rec_byte_num_en_i = 0;
    #(8*17);
    laser_uart_en = 0;

    #(8*17);

    $finish;
    #1000;
    laser_uart_enrx = 1;

    $finish;
end


reg sim_fifo_wr_en = 'd0;
reg [4-1:0] sim_fifo_cnt = 'd0;
reg laser_uart_en_d = 'd0;
always @(posedge clk_100m) begin
    laser_uart_en_d <= laser_uart_en;
    if(~laser_uart_en_d && laser_uart_en)begin
        sim_fifo_wr_en <= 'd1;
    end
end
always @(posedge clk_100m) begin
    if(sim_fifo_wr_en)begin
        sim_fifo_cnt <= sim_fifo_cnt + 1;
    end
end
reg sim_fifo_rd_en = 'd0;
always @(posedge clk_100m) begin
    sim_fifo_rd_en <= sim_fifo_wr_en;
end

test_sim_fifo test_sim_fifo_inst (
    .clk    ( clk_100m),
    .srst   ( rst),
    .din    ( ram_sim[sim_fifo_cnt]),
    .wr_en  ( sim_fifo_wr_en),
    .rd_en  ( sim_fifo_rd_en),
    .dout   ( ),
    .full   ( ),
    .empty  ( )
);

endmodule