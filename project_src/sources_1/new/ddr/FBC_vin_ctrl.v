`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/08/25
// Design Name: PCG
// Module Name: FBC_vin_ctrl
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


module FBC_vin_ctrl #(
    parameter                               TCQ               = 0.1 ,
    parameter                               ADDR_WIDTH        = 30  ,
    parameter                               DATA_WIDTH        = 32  ,
    parameter                               MEM_DATA_BITS     = 256 ,
    parameter                               BURST_LEN         = 128 
)(
    // clk & rst
    input                                   clk_i                   ,
    input                                   rst_i                   ,
    input                                   ddr_clk_i               ,
    input                                   ddr_rst_i               ,

    input                                   fbc_scan_en_i           ,
    // output                                  fbc_cache_full_o        ,
    input                                   fbc_cache_vld_i         ,
    input       [256-1:0]                   fbc_cache_data_i        ,
    
    output      [18-1:0]                    wr_burst_line_o         ,
    input       [18-1:0]                    rd_burst_line_i         ,

    output                                  wr_ddr_req_o            ,
    output      [ 8-1:0]                    wr_ddr_len_o            ,
    output      [ADDR_WIDTH-1:0]            wr_ddr_addr_o           ,
     
    input                                   ddr_fifo_rd_req_i       ,
    output      [MEM_DATA_BITS - 1:0]       wr_ddr_data_o           ,
    input                                   wr_ddr_finish_i          
);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// reg                         pmt_scan_en_d0          = 'd0;
// reg                         pmt_scan_en_d1          = 'd0;
// reg                         pmt_scan_en_d2          = 'd0;
// reg                         pmt_scan_en_d3          = 'd0;
// reg                         pmt_scan_en_d4          = 'd0;
// reg                         fbc_cache_data_vld      = 'd0;
// reg     [10-1:0]            fbc_data_cnt            = 'd0;  // laser data count, 1024 (=BURST_LEN*MEM_DATA_BITS/DATA_WIDTH) for once burst operate
// reg                         frame_last              = 'd0;
// reg     [10-1:0]            last_burst_data_num     = 'd0;  // last burst operate data number, burst number = brust data number/8 + 1
// reg                         frame_supplement_flag   = 'd0;
// reg     [3-1:0]             frame_supplement_cnt    = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// wire                        pmt_scan_nege           ;
// wire                        pmt_scan_pose           ;
wire                        fbc_cache_full          ;
wire                        fbc_cache_empty         ;
wire                        ddr_fifo_almost_full    ;

wire                        fbc_cache_rd_en         ;
wire                        fbc_cache_vld           ;
wire    [256-1:0]           fbc_cache_dout          ;
// wire    [4-1:0]             frame_supplement_sum    ;
// wire    [DATA_WIDTH-1:0]    fbc_cache_data          ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// xpm_async_fifo #(
//     .ECC_MODE               ( "no_ecc"                      ),
//     .FIFO_MEMORY_TYPE       ( "block"                       ), // "auto" "block" "distributed"
//     .READ_MODE              ( "std"                         ),
//     .FIFO_WRITE_DEPTH       ( 32                            ),
//     .WRITE_DATA_WIDTH       ( DATA_WIDTH                    ),
//     .READ_DATA_WIDTH        ( DATA_WIDTH                    ),
//     .RELATED_CLOCKS         ( 1                             ), // write clk same source of read clk
//     .USE_ADV_FEATURES       ( "1808"                        )
// )FBC_vin_buffer_fifo_inst (
//     .wr_clk_i               ( clk_i                         ),
//     .rst_i                  ( rst_i                         ), // synchronous to wr_clk
//     .wr_en_i                ( fbc_cache_vld_i               ),
//     .wr_data_i              ( fbc_cache_data_i              ),
//     .fifo_full_o            ( fbc_cache_full                ),

//     .rd_clk_i               ( ddr_clk_i                     ),
//     .rd_en_i                ( fbc_cache_rd_en               ),
//     .fifo_rd_vld_o          ( fbc_cache_vld                 ),
//     .fifo_rd_data_o         ( fbc_cache_dout                ),
//     .fifo_empty_o           ( fbc_cache_empty               )
// );
FBC_vin_buffer_fifo FBC_vin_buffer_fifo_inst (
    .rst                    ( rst_i                         ),  // input wire rst
    .wr_clk                 ( clk_i                         ),  // input wire wr_clk
    .rd_clk                 ( ddr_clk_i                     ),  // input wire rd_clk
    .din                    ( fbc_cache_data_i              ),  // input wire [255 : 0] din
    .wr_en                  ( fbc_cache_vld_i               ),  // input wire wr_en
    .rd_en                  ( fbc_cache_rd_en               ),  // input wire rd_en
    .dout                   ( fbc_cache_dout                ),  // output wire [255 : 0] dout
    .full                   ( fbc_cache_full                ),  // output wire full
    .empty                  ( fbc_cache_empty               ),  // output wire empty
    .valid                  ( fbc_cache_vld                 )   // output wire valid
);

mem_vin_buffer_ctrl #(
    .TCQ                    ( TCQ                           ),  
    .ADDR_WIDTH             ( ADDR_WIDTH                    ),
    .DATA_WIDTH             ( DATA_WIDTH                    ),
    .MEM_DATA_BITS          ( MEM_DATA_BITS                 ),
    .BURST_LEN              ( BURST_LEN                     )
)mem_vin_buffer_ctrl_inst(
    // clk & rst
    .ddr_clk_i              ( ddr_clk_i                     ),
    .ddr_rst_i              ( ddr_rst_i                     ),

    .laser_start_i          ( fbc_scan_en_i                 ),
    .laser_vld_i            ( fbc_cache_vld                 ),
    .laser_data_i           ( fbc_cache_dout                ),
    // .ddr_fifo_full_o        ( fbc_cache_full_o              ),
    .wr_burst_line_o        ( wr_burst_line_o               ),
    .rd_burst_line_i        ( rd_burst_line_i               ),

    .wr_ddr_req_o           ( wr_ddr_req_o                  ), // 存储器接口：写请求 在写的过程中持续为1  
    .wr_ddr_len_o           ( wr_ddr_len_o                  ), // 存储器接口：写长度
    .wr_ddr_addr_o          ( wr_ddr_addr_o                 ), // 存储器接口：写首地址 
     
    .ddr_fifo_rd_req_i      ( ddr_fifo_rd_req_i             ), // 存储器接口：写数据数据读指示 ddr FIFO读使能
    .wr_ddr_data_o          ( wr_ddr_data_o                 ), // 存储器接口：写数据
    .wr_ddr_finish_i        ( wr_ddr_finish_i               )  // 存储器接口：本次写完成 
);
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// always @(posedge clk_i) pmt_scan_en_d0 <= #TCQ fbc_scan_en_i;
// always @(posedge clk_i) pmt_scan_en_d1 <= #TCQ pmt_scan_en_d0;
// always @(posedge clk_i) pmt_scan_en_d2 <= #TCQ pmt_scan_en_d1;
// always @(posedge clk_i) pmt_scan_en_d3 <= #TCQ pmt_scan_en_d2;
// always @(posedge clk_i) pmt_scan_en_d4 <= #TCQ pmt_scan_en_d3;
// assign pmt_scan_nege  = pmt_scan_en_d4 && ~pmt_scan_en_d3;
// assign pmt_scan_pose  = ~pmt_scan_en_d0 && fbc_scan_en_i;

assign fbc_cache_rd_en = ~fbc_cache_empty;
// assign fbc_cache_data  = fbc_cache_dout ;
// assign fbc_cache_data  = fbc_cache_data_vld ? fbc_cache_dout : 'd0;
// always @(posedge clk_i) begin
//     fbc_cache_data_vld <= #TCQ fbc_cache_rd_en;
// end

// always @(posedge clk_i) begin
//     if(fbc_scan_en_i || pmt_scan_en_d4)begin
//         if(fbc_cache_vld_i && ~fbc_cache_full_o)
//             fbc_data_cnt <= #TCQ fbc_data_cnt + 1;
//     end
//     else begin
//         fbc_data_cnt <= #TCQ 'd0;
//     end
// end

// // generate last burst data num
// always @(posedge clk_i) begin
//     if(pmt_scan_nege)begin
//         last_burst_data_num <= #TCQ fbc_data_cnt;
//     end
// end

// // control 
// assign frame_supplement_sum[3:0] = {1'b0,last_burst_data_num[2:0]} + {1'b0,frame_supplement_cnt[2:0]};
// always @(posedge clk_i) begin
//     if(pmt_scan_nege)begin
//         frame_last <= #TCQ 'd1;
//     end
//     else if((frame_supplement_sum[2:0] == 'd0) && frame_last && fbc_cache_empty)begin
//         frame_last <= #TCQ 'd0;
//     end
// end

// // supplement last burst operate data 
// // frame_supplement_sum == 8 ready 512it write data
// always @(posedge clk_i) begin
//     if(frame_last && fbc_cache_empty)begin
//         if(frame_supplement_sum[2:0] != 'd0)begin
//             frame_supplement_flag <= #TCQ 'd1;
//             frame_supplement_cnt  <= #TCQ frame_supplement_cnt + 1;
//         end 
//         else begin
//             frame_supplement_flag <= #TCQ 'd0;
//         end
//     end
//     else begin
//         frame_supplement_flag <= #TCQ 'd0;
//         frame_supplement_cnt  <= #TCQ 'd0;
//     end
// end

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
