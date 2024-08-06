`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: songyuxin
// 
// Create Date: 2023/8/1
// Design Name: 
// Module Name: fbc_sensor_sim
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

module fbc_sensor_sim#(
    parameter                               TCQ                = 0.1,
    parameter                               SPI_DELAY          = 10 ,
    parameter                               SPI_CLK_DIVIDER    = 6  , // SPI Clock Control / Divid
    parameter                               SPI_MASTER_WIDTH   = 48 , // master spi data width
    parameter                               SPI_SLAVE_WIDTH    = 64   // slave spi data width
)(
    input   wire                            clk_h_i                     ,
    input   wire                            rst_i                       ,
    
    // sensor spi info
    output  wire                            MSPI_CLK                    ,
    output  wire                            MSPI_MOSI                   ,
    input   wire                            SSPI_CLK                    ,
    input   wire                            SSPI_MISO                   
);


reg sim_wr_en_h = 'd0;
reg [SPI_MASTER_WIDTH-1:0] sim_wr_data_h = 'd0;

bspi_ctrl #(
    .SPI_CLK_DIVIDER        ( SPI_CLK_DIVIDER                       ), // SPI Clock Control / Divid
    .SPI_MASTER_WIDTH       ( SPI_MASTER_WIDTH                      ), // master spi data width
    .SPI_SLAVE_WIDTH        ( SPI_SLAVE_WIDTH                       )  // slave spi data width

)bspi_ctrl_inst(
    // clk & rst
    .clk_i                  ( clk_h_i                               ),
    .rst_i                  ( rst_i                                 ),
    
    .mspi_wr_en_i           ( sim_wr_en_h                           ),
    .mspi_wr_data_i         ( sim_wr_data_h                         ),
    // .sspi_rd_vld_o          ( sspi_rd_vld                           ),
    // .sspi_rd_data_o         ( sspi_rd_data                          ),
    // bspi info
    .MSPI_CLK               ( MSPI_CLK                              ),
    .MSPI_MOSI              ( MSPI_MOSI                             ),
    .SSPI_CLK               ( SSPI_CLK                              ),
    .SSPI_MISO              ( SSPI_MISO                             )
);




reg [16-1:0] unit_time_cnt = SPI_DELAY;
wire  unit_time_tick ;
always @(posedge clk_h_i) begin
    if(unit_time_tick)
        unit_time_cnt <= #TCQ 'd0;
    else
        unit_time_cnt <= #TCQ unit_time_cnt + 1;
end

assign unit_time_tick = unit_time_cnt == 'd2344;

always @(posedge clk_h_i) begin
    if(unit_time_tick)begin
        sim_wr_en_h     <= #TCQ 'd1;
        sim_wr_data_h   <= #TCQ sim_wr_data_h + 1;
    end
    else begin
        sim_wr_en_h     <= #TCQ 'd0;
        sim_wr_data_h   <= #TCQ sim_wr_data_h;
    end
end



endmodule