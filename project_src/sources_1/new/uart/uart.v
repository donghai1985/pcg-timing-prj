`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/17
// Design Name: 
// Module Name: uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//
//  Module
//
//     uart     : Wrapper for complete UART
//     uart_rx  : UART receiver implementation
//     uart_tx  : UART transmitter implementation
//
//  AXI Stream Interface Example
//               __     __    __    __    __    __    __    __    __
//     clk    __/  \__ /  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__
//                     _____ _________________
//     tdata  XXXXXXXXX_D0__X_D1______________XXXXXXXXXXXXXXXXXXXXXXXX
//                     _______________________
//     tvalid ________/                       \_______________________
//            ______________             _____             ___________
//     tready               \___________/     \___________/
//
//  prescale for set Baud, so it should be set to Fclk / (baud * 8).
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
/*
 * AXI4-Stream UART
 */
module uart #
(
    parameter DATA_WIDTH = 8
)
(
    input  wire                   clk,
    input  wire                   rst,

    /*
     * AXI input
     */
    input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire                   s_axis_tvalid,
    output wire                   s_axis_tready,

    /*
     * AXI output
     */
    output wire [DATA_WIDTH-1:0]  m_axis_tdata,
    output wire                   m_axis_tvalid,
    input  wire                   m_axis_tready,

    /*
     * UART interface
     */
    input  wire                   rxd,
    output wire                   txd,

    /*
     * Status
     */
    output wire                   tx_busy,
    output wire                   rx_busy,
    output wire                   rx_overrun_error,
    output wire                   rx_frame_error,

    /*
     * Configuration
     */
    input  wire [15:0]            prescale

);

uart_tx #(
    .DATA_WIDTH(DATA_WIDTH)
)
uart_tx_inst (
    .clk(clk),
    .rst(rst),
    // axi input
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    // output
    .txd(txd),
    // status
    .busy(tx_busy),
    // configuration
    .prescale(prescale)
);

uart_rx #(
    .DATA_WIDTH(DATA_WIDTH)
)
uart_rx_inst (
    .clk(clk),
    .rst(rst),
    // axi output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    // input
    .rxd(rxd),
    // status
    .busy(rx_busy),
    .overrun_error(rx_overrun_error),
    .frame_error(rx_frame_error),
    // configuration
    .prescale(prescale)
);

endmodule
