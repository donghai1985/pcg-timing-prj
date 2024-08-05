`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/18
// Design Name: songyuxin
// Module Name: laser_comm_ctrl
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


module laser_comm_ctrl #(
    parameter                       TCQ         = 0.1 

)(
    // clk & rst
    input   wire                    clk_i               ,
    input   wire                    rst_i               ,
    
    input   wire    [32-1:0]        laser_tx_data_i     ,
    input   wire                    laser_tx_vld_i      ,
    output  wire    [8-1:0]         laser_rx_data_o     ,
    output  wire                    laser_rx_vld_o      ,
    output  wire                    laser_rx_last_o     ,

    // interface    
    input   wire                    LASER_UART_RXD      ,
    output  wire                    LASER_UART_TXD      
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam          [16-1:0]        UART_BAUD_SET   = 16'd108;  // clk_i / (baud * 8)
localparam                          DATA_WIDTH      = 'd8;


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                                 s_axis_tvalid       = 'd0;
reg                                 laser_tx_last       = 'd0;




//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                tx_busy             ;
wire                                rx_busy             ;
wire                                rx_overrun_error    ;
wire                                rx_frame_error      ;

wire                                laser_uart_fifo_rd   ;
wire    [ DATA_WIDTH-1:0]           laser_uart_fifo_dout ;
wire                                laser_uart_fifo_full ;
wire                                laser_uart_fifo_empty;

wire                                s_axis_tready   ;
wire    [ DATA_WIDTH-1:0]           m_axis_tdata    ;
wire                                m_axis_tvalid   ;
wire                                m_axis_tready   ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<





//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

laser_uart_fifo laser_uart_fifo_inst(
    .clk                ( clk_i                     ),
    .srst               ( rst_i                     ),
    .din                ( laser_tx_data_i           ),
    .wr_en              ( laser_tx_vld_i            ),
    .rd_en              ( laser_uart_fifo_rd || laser_tx_last ),
    .dout               ( laser_uart_fifo_dout      ),
    .full               ( laser_uart_fifo_full      ),
    .empty              ( laser_uart_fifo_empty     )
);

uart #(
    .DATA_WIDTH         ( DATA_WIDTH                )
)uart_inst(
    .clk                ( clk_i                     ),
    .rst                ( rst_i                     ),

    .s_axis_tdata       ( laser_uart_fifo_dout      ),
    .s_axis_tvalid      ( s_axis_tvalid             ),
    .s_axis_tready      ( s_axis_tready             ),
    .m_axis_tdata       ( m_axis_tdata              ),
    .m_axis_tvalid      ( m_axis_tvalid             ),
    .m_axis_tready      ( m_axis_tready             ),

    .rxd                ( LASER_UART_RXD            ),
    .txd                ( LASER_UART_TXD            ),

    .tx_busy            ( tx_busy                   ),
    .rx_busy            ( rx_busy                   ),
    .rx_overrun_error   ( rx_overrun_error          ),
    .rx_frame_error     ( rx_frame_error            ),

    .prescale           ( UART_BAUD_SET             )

);
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
assign laser_uart_fifo_rd = (~laser_uart_fifo_empty) && s_axis_tready && (~s_axis_tvalid);
assign m_axis_tready = 1'b1;

always @(posedge clk_i) begin
    s_axis_tvalid <= #TCQ laser_uart_fifo_rd;
end

// read surplus data, from 4byte align.
always @(posedge clk_i) begin
    if(s_axis_tvalid && laser_uart_fifo_dout=='hff)
        laser_tx_last <= 'd1;
    else if(laser_uart_fifo_empty)
        laser_tx_last <= 'd0;
end

assign laser_rx_data_o = m_axis_tdata;
assign laser_rx_vld_o  = m_axis_tvalid;
assign laser_rx_last_o = m_axis_tvalid && (m_axis_tdata=='hFF);
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
