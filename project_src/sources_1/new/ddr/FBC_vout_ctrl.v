`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/08/25
// Design Name: PCG
// Module Name: FBC_vout_ctrl
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


module FBC_vout_ctrl #(
    parameter                               TCQ               = 0.1 ,  
    parameter                               ADDR_WIDTH        = 30  ,
    parameter                               DATA_WIDTH        = 32  ,
    parameter                               MEM_DATA_BITS     = 256 ,
    parameter                               BURST_LEN         = 128
)(
    // clk & rst 
    input                                   ddr_clk_i               ,
    input                                   ddr_rst_i               ,
    input                                   sys_clk_i               ,

    input                                   fbc_scan_en_i           ,
    output                                  fbc_start_o             ,
    input       [18-1:0]                    wr_burst_line_i         ,
    output      [18-1:0]                    rd_burst_line_o         ,

    output                                  fbc_vout_empty_o        ,
    input                                   fbc_vout_rd_seq_i       ,
    output                                  fbc_vout_rd_vld_o       ,
    output      [DATA_WIDTH-1:0]            fbc_vout_rd_data_o      ,
    // output                                  fbc_vout_end_o          ,

    output                                  rd_ddr_req_o            ,  
    output      [ 8-1:0]                    rd_ddr_len_o            ,
    output      [ADDR_WIDTH-1:0]            rd_ddr_addr_o           ,
    input                                   rd_ddr_data_valid_i     ,
    input       [MEM_DATA_BITS - 1:0]       rd_ddr_data_i           ,
    input                                   rd_ddr_finish_i          
    
);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                                 ddr_fifo_rd_en          = 'd0;
reg                                 fbc_vout_wr_en          = 'd0;
reg                                 fbc_vout_end            = 'd0;
reg                                 pmt_scan_en_d0          = 'd0;
reg                                 pmt_scan_en_d1          = 'd0;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                ddr_fifo_empty      ;
wire                                fbc_vout_prog_full  ;
wire                                fbc_vout_full       ;
wire    [DATA_WIDTH-1:0]            ddr_fifo_rd_data    ;
wire                                frame_burst_end     ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// xpm_async_fifo #(
//     .ECC_MODE                       ( "no_ecc"                      ),
//     .FIFO_MEMORY_TYPE               ( "block"                       ), // "auto" "block" "distributed"
//     .READ_MODE                      ( "std"                         ),
//     .FIFO_WRITE_DEPTH               ( 64                            ),
//     .WRITE_DATA_WIDTH               ( DATA_WIDTH                    ),
//     .PROG_FULL_THRESH               ( 64-8                          ),
//     .READ_DATA_WIDTH                ( DATA_WIDTH                    ),
//     .RELATED_CLOCKS                 ( 1                             ), // write clk same source of read clk
//     .USE_ADV_FEATURES               ( "1002"                        )
// )FBC_vout_buffer_fifo_inst ( 
//     .wr_clk_i                       ( ddr_clk_i                     ),
//     .rst_i                          ( ddr_rst_i                     ), // synchronous to wr_clk
//     .wr_en_i                        ( ddr_fifo_rd_vld               ),
//     .wr_data_i                      ( ddr_fifo_rd_data              ),
//     .fifo_full_o                    ( fbc_vout_full                 ),
//     .fifo_prog_full_o               ( fbc_vout_prog_full            ),

//     .rd_clk_i                       ( sys_clk_i                     ),
//     .rd_en_i                        ( fbc_vout_rd_seq_i             ),
//     .fifo_rd_vld_o                  ( fbc_vout_rd_vld_o             ),
//     .fifo_rd_data_o                 ( fbc_vout_rd_data_o            ),
//     .fifo_empty_o                   ( fbc_vout_empty_o              )
// );

FBC_vout_buffer_fifo FBC_vout_buffer_fifo_inst (
    .rst                            ( ddr_rst_i                     ),  // input wire rst
    .wr_clk                         ( ddr_clk_i                     ),  // input wire wr_clk
    .rd_clk                         ( sys_clk_i                     ),  // input wire rd_clk
    .din                            ( ddr_fifo_rd_data              ),  // input wire [63 : 0] din
    .wr_en                          ( ddr_fifo_rd_vld               ),  // input wire wr_en
    .rd_en                          ( fbc_vout_rd_seq_i             ),  // input wire rd_en
    .dout                           ( fbc_vout_rd_data_o            ),  // output wire [63 : 0] dout
    .full                           ( fbc_vout_full                 ),  // output wire full
    .empty                          ( fbc_vout_empty_o              ),  // output wire empty
    .valid                          ( fbc_vout_rd_vld_o             ),  // output wire valid
    .prog_full                      ( fbc_vout_prog_full            )   // output wire prog_full
);

mem_vout_buffer_ctrl #(
    .ADDR_WIDTH                     ( ADDR_WIDTH                    ),
    .DATA_WIDTH                     ( DATA_WIDTH                    ),
    .MEM_DATA_BITS                  ( MEM_DATA_BITS                 ),
    .BURST_LEN                      ( BURST_LEN                     )
)mem_vout_buffer_ctrl_inst(
    // clk & rst 
    .ddr_clk_i                      ( ddr_clk_i                     ),
    .ddr_rst_i                      ( ddr_rst_i                     ),

    .laser_start_i                  ( fbc_scan_en_i                 ),
    .fbc_start_o                    ( fbc_start                     ),
    .wr_burst_line_i                ( wr_burst_line_i               ),
    .rd_burst_line_o                ( rd_burst_line_o               ),

    .ddr_fifo_empty_o               ( ddr_fifo_empty                ),
    .ddr_fifo_rd_en_i               ( ddr_fifo_rd_en                ),
    .ddr_fifo_rd_vld_o              ( ddr_fifo_rd_vld               ),
    .ddr_fifo_rd_data_o             ( ddr_fifo_rd_data              ),

    .rd_ddr_req_o                   ( rd_ddr_req_o                  ),  
    .rd_ddr_len_o                   ( rd_ddr_len_o                  ),
    .rd_ddr_addr_o                  ( rd_ddr_addr_o                 ),
    .rd_ddr_data_valid_i            ( rd_ddr_data_valid_i           ),
    .rd_ddr_data_i                  ( rd_ddr_data_i                 ),
    .rd_ddr_finish_i                ( rd_ddr_finish_i               ) 
);

xpm_cdc_single #(
    .DEST_SYNC_FF                   ( 2                             ),  // DECIMAL; range: 2-10
    .INIT_SYNC_FF                   ( 0                             ),  // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK                 ( 0                             ),  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG                  ( 1                             )   // DECIMAL; 0=do not register input, 1=register input
 )
 xpm_cdc_single_inst (
    .dest_out                       ( fbc_start_o                   ),  // 1-bit output: src_in synchronized to the destination clock domain. This output is
                                                                        // registered.

    .dest_clk                       ( sys_clk_i                     ),  // 1-bit input: Clock signal for the destination clock domain.
    .src_clk                        ( ddr_clk_i                     ),  // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in                         ( fbc_start                     )   // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

always @(posedge ddr_clk_i) ddr_fifo_rd_en  <= #TCQ ~ddr_fifo_empty && ~fbc_vout_prog_full;
// always @(posedge ddr_clk_i) fbc_vout_wr_en  <= #TCQ ddr_fifo_rd_en;

// always @(posedge ddr_clk_i) begin
//     if(frame_last_flag_i && (|frame_burst_num_i))
//         fbc_vout_end <= #TCQ 'd0;
//     else if(frame_burst_end || (frame_last_flag_i && (frame_burst_num_i=='d0)))
//         fbc_vout_end <= #TCQ 'd1;
// end

// assign fbc_vout_end_o = fbc_vout_end;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
