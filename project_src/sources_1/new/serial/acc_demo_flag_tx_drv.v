`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2024/3/15
// Design Name: PCG
// Module Name: acc_demo_flag_tx_drv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module acc_demo_flag_tx_drv #(
    parameter                               TCQ             = 0.1   ,
    parameter                               DATA_WIDTH      = 16    ,
    parameter                               SERIAL_MODE     = 1     
)(
    // clk & rst
    input    wire                           clk_i                   ,
    input    wire                           rst_i                   ,
    input    wire                           clk_200m_i              ,

    input    wire                           acc_demo_flag_i         ,

    input    wire                           pmt_scan_cmd_sel_i      ,
    input    wire   [4-1:0]                 pmt_scan_cmd_i          ,
    output   wire                           pmt_start_en_o          ,
    output   wire                           pmt_start_test_en_o     ,

    // spi info
    output   wire                           SPI_MCLK                ,
    output   wire   [SERIAL_MODE-1:0]       SPI_MOSI                
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam  [DATA_WIDTH-1:0]        SYNC_ACC_FLAG_HIGH      = 'hACC1    ;
localparam  [DATA_WIDTH-1:0]        SYNC_ACC_FLAG_LOW       = 'hACC0    ;
localparam  [DATA_WIDTH-1:0]        SYNC_WORD_SCAN_BEGIN    = 'h5A51    ;
localparam  [DATA_WIDTH-1:0]        SYNC_WORD_SCAN_TEST     = 'h5A53    ;
localparam  [DATA_WIDTH-1:0]        SYNC_WORD_SCAN_END      = 'h5A50    ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                             tx_valid                = 'd0;
reg     [DATA_WIDTH-1:0]        tx_data                 = 'd0;

reg                             scan_state              = 'd0;
reg     [4-1:0]                 scan_state_d            = 'd0;
reg                             acc_demo_flag_d         = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                            tx_ready      ;
wire                            acc_demo_flag_pose;
wire                            acc_demo_flag_nege;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
serial_tx #(
    .DATA_WIDTH                 ( DATA_WIDTH                ),
    .SERIAL_MODE                ( SERIAL_MODE               )  // =1\2\4\8
)serial_tx_inst(
    // clk & rst
    .clk_i                      ( clk_i                     ),
    .rst_i                      ( rst_i                     ),
    .clk_200m_i                 ( clk_200m_i                ),

    .tx_valid_i                 ( tx_valid                  ),
    .tx_ready_o                 ( tx_ready                  ),
    .tx_data_i                  ( tx_data                   ),

    .TX_CLK                     ( SPI_MCLK                  ),
    .TX_DOUT                    ( SPI_MOSI                  )
);
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) begin
    if(rst_i)
        scan_state <= #TCQ 'd0;
    else if(pmt_scan_cmd_sel_i && pmt_scan_cmd_i[0])
        scan_state <= #TCQ 'd1;
    else if(pmt_scan_cmd_sel_i && (~pmt_scan_cmd_i[0]))
        scan_state <= #TCQ 'd0;
end

always @(posedge clk_i) scan_state_d        <= #TCQ {scan_state_d[2:0],scan_state};
always @(posedge clk_i) acc_demo_flag_d     <= #TCQ acc_demo_flag_i;

assign acc_demo_flag_pose = ~acc_demo_flag_d && acc_demo_flag_i;
assign acc_demo_flag_nege = acc_demo_flag_d && (~acc_demo_flag_i);

always @(posedge clk_i) begin
    if(~scan_state_d[0] && scan_state)begin
        if(pmt_scan_cmd_i[1])begin
            tx_valid <= #TCQ 'd1;
            tx_data  <= #TCQ SYNC_WORD_SCAN_TEST;
        end
        else begin
            tx_valid <= #TCQ 'd1;
            tx_data  <= #TCQ SYNC_WORD_SCAN_BEGIN;
        end
    end
    else if(scan_state_d[0] && (~scan_state))begin
            tx_valid <= #TCQ 'd1;
            tx_data  <= #TCQ SYNC_WORD_SCAN_END;
    end
    else if(acc_demo_flag_pose)begin
        tx_valid <= #TCQ 'd1;
        tx_data  <= #TCQ SYNC_ACC_FLAG_HIGH;
    end
    else if(acc_demo_flag_nege)begin
        tx_valid <= #TCQ 'd1;
        tx_data  <= #TCQ SYNC_ACC_FLAG_LOW;
    end
    else if(tx_ready && tx_valid)
        tx_valid <= #TCQ 'd0;
end

assign pmt_start_en_o      = scan_state_d[0]     ;
assign pmt_start_test_en_o = scan_state_d[0] & pmt_scan_cmd_i[1];
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
