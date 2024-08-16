`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/20
// Design Name: songyuxin
// Module Name: ddr_top
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


module ddr_top (
    // clk & rst
    input                           clk_i                   , // sys clk
    input                           rst_i                   ,
    input                           clk_250m_i              , // ddr System clk input
    input                           clk_200m_i              , // ddr Reference clk input
    // input                           laser_rst_i             , // ddr init_calib_compiete and aurora_channel_up_done

    // laser write control
    input                           fbc_scan_en_i           ,
    // output                          fbc_cache_full_o        ,
    input                           fbc_cache_vld_i         ,
    input       [256-1:0]           fbc_cache_data_i        ,

    // laser read control
    output                          fbc_up_start_o          ,
    output                          fbc_vout_empty_o        ,
    input                           fbc_vout_rd_seq_i       ,
    output                          fbc_vout_rd_vld_o       ,
    output      [64-1:0]            fbc_vout_rd_data_o      ,
    // output                          fbc_vout_end_o          ,

    input                           pmt_scan_en_i           ,
    input                           acc_trigger_latch_en_i  ,
    input       [256-1:0]           acc_trigger_latch_i     ,

    // readback ddr
    input       [32-1:0]            ddr_rd_addr_i           ,
    input                           ddr_rd_en_i             ,
    output                          ddr_readback_vld_o      ,
    output                          ddr_readback_last_o     ,
    output      [64-1:0]            ddr_readback_data_o     ,

    // ddr complete reset
    output                          init_calib_complete_o   ,
    // ddr interface
    inout       [63:0]              ddr3_dq                 ,
    inout       [7:0]               ddr3_dqs_n              ,
    inout       [7:0]               ddr3_dqs_p              ,
    output      [15:0]              ddr3_addr               ,
    output      [2:0]               ddr3_ba                 ,
    output                          ddr3_ras_n              ,
    output                          ddr3_cas_n              ,
    output                          ddr3_we_n               ,
    output                          ddr3_reset_n            ,
    output                          ddr3_ck_p               ,
    output                          ddr3_ck_n               ,
    output                          ddr3_cke                ,
    output                          ddr3_cs_n               ,
    output      [7:0]               ddr3_dm                 ,
    output                          ddr3_odt                
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam                          DQ_WIDTH          = 64  ;
localparam                          DQS_WIDTH         = 8   ;  //DQ_WIDTH/8  ;
localparam                          ADDR_WIDTH        = 30  ;
localparam                          DATA_WIDTH        = 64  ;
localparam                          MEM_DATA_BITS     = 512 ;
localparam                          BURST_LEN         = 128 ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                ddr_log_rst             ;

wire                                ch0_wr_ddr_req          ;
wire    [8-1:0]                     ch0_wr_ddr_len          ;
wire    [ADDR_WIDTH-1:0]            ch0_wr_ddr_addr         ;
wire                                ch0_wr_ddr_data_req     ;
wire    [MEM_DATA_BITS - 1:0]       ch0_wr_ddr_data         ;
wire                                ch0_wr_ddr_finish       ;

wire                                ch0_rd_ddr_req          ;
wire    [8-1:0]                     ch0_rd_ddr_len          ;
wire    [ADDR_WIDTH-1:0]            ch0_rd_ddr_addr         ;
wire                                ch0_rd_ddr_data_valid   ;
wire    [MEM_DATA_BITS - 1:0]       ch0_rd_ddr_data         ;
wire                                ch0_rd_ddr_finish       ;

wire                                ch1_rd_ddr_req          ;
wire    [8-1:0]                     ch1_rd_ddr_len          ;
wire    [ADDR_WIDTH-1:0]            ch1_rd_ddr_addr         ;
wire                                ch1_rd_ddr_data_valid   ;
wire    [MEM_DATA_BITS - 1:0]       ch1_rd_ddr_data         ;
wire                                ch1_rd_ddr_finish       ;

// wire                                frame_last_flag         ; // write end 
// wire    [5-1:0]                     frame_addr              ; // control frame polling
// wire    [10-1:0]                    frame_last_burst_num    ; // control read frame length
// wire    [15-1:0]                    frame_burst_num         ; // control read frame length, = burst_num * BURST_LEN + last_burst_num
wire    [18-1:0]                    wr_burst_line           ;
wire    [18-1:0]                    rd_burst_line           ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FBC_vin_ctrl #(
    .ADDR_WIDTH                     ( ADDR_WIDTH                ),
    .DATA_WIDTH                     ( DATA_WIDTH                ),
    .MEM_DATA_BITS                  ( MEM_DATA_BITS             ),
    .BURST_LEN                      ( BURST_LEN                 )
)FBC_vin_ctrl_inst(
    // clk & rst
    .clk_i                          ( clk_i                     ),
    .rst_i                          ( rst_i                     ),
    .ddr_clk_i                      ( ui_clk                    ),
    .ddr_rst_i                      ( ddr_log_rst               ),

    .fbc_scan_en_i                  ( fbc_scan_en_i             ),
    // .fbc_cache_full_o               ( fbc_cache_full_o          ),
    .fbc_cache_vld_i                ( fbc_cache_vld_i           ),
    .fbc_cache_data_i               ( fbc_cache_data_i          ),

    .wr_burst_line_o                ( wr_burst_line             ),
    .rd_burst_line_i                ( rd_burst_line             ),

    .wr_ddr_req_o                   ( ch0_wr_ddr_req            ),
    .wr_ddr_len_o                   ( ch0_wr_ddr_len            ),
    .wr_ddr_addr_o                  ( ch0_wr_ddr_addr           ),
    .ddr_fifo_rd_req_i              ( ch0_wr_ddr_data_req       ),
    .wr_ddr_data_o                  ( ch0_wr_ddr_data           ),
    .wr_ddr_finish_i                ( ch0_wr_ddr_finish         ) 
);

FBC_vout_ctrl #(
    .ADDR_WIDTH                     ( ADDR_WIDTH                ),
    .DATA_WIDTH                     ( DATA_WIDTH                ),
    .MEM_DATA_BITS                  ( MEM_DATA_BITS             ),
    .BURST_LEN                      ( BURST_LEN                 )
)FBC_vout_ctrl_inst(
    // clk & rst 
    .sys_clk_i                      ( clk_i                     ),
    .ddr_clk_i                      ( ui_clk                    ),
    .ddr_rst_i                      ( ddr_log_rst               ),
      
    .fbc_scan_en_i                  ( fbc_scan_en_i             ),
    .fbc_start_o                    ( fbc_up_start_o            ),
    .wr_burst_line_i                ( wr_burst_line             ),
    .rd_burst_line_o                ( rd_burst_line             ),

    .fbc_vout_empty_o               ( fbc_vout_empty_o          ),
    .fbc_vout_rd_seq_i              ( fbc_vout_rd_seq_i         ),
    .fbc_vout_rd_vld_o              ( fbc_vout_rd_vld_o         ),
    .fbc_vout_rd_data_o             ( fbc_vout_rd_data_o        ),

    .rd_ddr_req_o                   ( ch0_rd_ddr_req            ),  
    .rd_ddr_len_o                   ( ch0_rd_ddr_len            ),
    .rd_ddr_addr_o                  ( ch0_rd_ddr_addr           ),
    .rd_ddr_data_valid_i            ( ch0_rd_ddr_data_valid     ),
    .rd_ddr_data_i                  ( ch0_rd_ddr_data           ),
    .rd_ddr_finish_i                ( ch0_rd_ddr_finish         ) 
    
);

acc_dump_vin_ctrl #(
    .ADDR_WIDTH                     ( ADDR_WIDTH                ),
    .DATA_WIDTH                     ( DATA_WIDTH                ),
    .MEM_DATA_BITS                  ( MEM_DATA_BITS             ),
    .BURST_LEN                      ( 16                        )    // 512*16/8=1024  512*16/64=128(2**7)
)acc_dump_vin_ctrl_inst(
    // clk & rst
    .clk_i                          ( clk_i                     ),
    .rst_i                          ( rst_i                     ),
    .ddr_clk_i                      ( ui_clk                    ),
    .ddr_rst_i                      ( ddr_log_rst               ),

    .pmt_scan_en_i                  ( pmt_scan_en_i             ),
    .acc_trigger_latch_en_i         ( acc_trigger_latch_en_i    ),
    .acc_trigger_latch_i            ( acc_trigger_latch_i       ),

    .wr_ddr_req_o                   ( ch1_wr_ddr_req            ),
    .wr_ddr_len_o                   ( ch1_wr_ddr_len            ),
    .wr_ddr_addr_o                  ( ch1_wr_ddr_addr           ),
    .ddr_fifo_rd_req_i              ( ch1_wr_ddr_data_req       ),
    .wr_ddr_data_o                  ( ch1_wr_ddr_data           ),
    .wr_ddr_finish_i                ( ch1_wr_ddr_finish         ) 
);

readback_vout_buffer #(
    .ADDR_WIDTH                     ( ADDR_WIDTH                ),
    .DATA_WIDTH                     ( DATA_WIDTH                ),
    .MEM_DATA_BITS                  ( MEM_DATA_BITS             ),
    .BURST_LEN                      ( 16                        )  // 512*16/8=1024  512*16/64=128(2**7)
)readback_vout_buffer_inst(
    // clk & rst 
    .ddr_clk_i                      ( ui_clk                    ),
    .ddr_rst_i                      ( ddr_log_rst               ),
    .sys_clk_i                      ( clk_i                     ),

    // readback ddr
    .ddr_rd_addr_i                  ( ddr_rd_addr_i             ),
    .ddr_rd_en_i                    ( ddr_rd_en_i               ),
    .readback_vld_o                 ( ddr_readback_vld_o        ),
    .readback_last_o                ( ddr_readback_last_o       ),
    .readback_data_o                ( ddr_readback_data_o       ),

    .rd_ddr_req_o                   ( ch1_rd_ddr_req            ),  
    .rd_ddr_len_o                   ( ch1_rd_ddr_len            ),
    .rd_ddr_addr_o                  ( ch1_rd_ddr_addr           ),
    .rd_ddr_data_valid_i            ( ch1_rd_ddr_data_valid     ),
    .rd_ddr_data_i                  ( ch1_rd_ddr_data           ),
    .rd_ddr_finish_i                ( ch1_rd_ddr_finish         ) 
);

mem_ctrl#(
    .DQ_WIDTH                       ( DQ_WIDTH                  ),
    .DQS_WIDTH                      ( DQS_WIDTH                 ),
    .MEM_DATA_BITS                  ( MEM_DATA_BITS             ),
    .ADDR_WIDTH                     ( ADDR_WIDTH                )
)mem_ctrl_inst(
    // clk & rst
    .clk_i                          ( clk_i                     ), // sys clk
    .rst_i                          ( rst_i                     ),
    .clk_250m_i                     ( clk_250m_i                ), // ddr System clk input
    .clk_200m_i                     ( clk_200m_i                ), // ddr Reference clk input
    .ui_clk                         ( ui_clk                    ), // ddr PHY to memory controller clk.    312.5/4MHz
    // .laser_rst_i                    ( laser_rst_i               ),
    .ddr_log_rst_o                  ( ddr_log_rst               ),

    // write channel interface 
    .ch0_wr_ddr_req                 ( ch0_wr_ddr_req            ),
    .ch0_wr_ddr_len                 ( ch0_wr_ddr_len            ),
    .ch0_wr_ddr_addr                ( ch0_wr_ddr_addr           ),
    .ch0_wr_ddr_data_req            ( ch0_wr_ddr_data_req       ),
    .ch0_wr_ddr_data                ( ch0_wr_ddr_data           ),
    .ch0_wr_ddr_finish              ( ch0_wr_ddr_finish         ),
    
    .ch1_wr_ddr_req                 ( ch1_wr_ddr_req            ),
    .ch1_wr_ddr_len                 ( ch1_wr_ddr_len            ),
    .ch1_wr_ddr_addr                ( ch1_wr_ddr_addr           ),
    .ch1_wr_ddr_data_req            ( ch1_wr_ddr_data_req       ),
    .ch1_wr_ddr_data                ( ch1_wr_ddr_data           ),
    .ch1_wr_ddr_finish              ( ch1_wr_ddr_finish         ),
    
    // read channel interface 
    .ch0_rd_ddr_req                 ( ch0_rd_ddr_req            ),
    .ch0_rd_ddr_len                 ( ch0_rd_ddr_len            ),
    .ch0_rd_ddr_addr                ( ch0_rd_ddr_addr           ),
    .ch0_rd_ddr_data_valid          ( ch0_rd_ddr_data_valid     ),
    .ch0_rd_ddr_data                ( ch0_rd_ddr_data           ),
    .ch0_rd_ddr_finish              ( ch0_rd_ddr_finish         ),
    
    .ch1_rd_ddr_req                 ( ch1_rd_ddr_req            ),
    .ch1_rd_ddr_len                 ( ch1_rd_ddr_len            ),
    .ch1_rd_ddr_addr                ( ch1_rd_ddr_addr           ),
    .ch1_rd_ddr_data_valid          ( ch1_rd_ddr_data_valid     ),
    .ch1_rd_ddr_data                ( ch1_rd_ddr_data           ),
    .ch1_rd_ddr_finish              ( ch1_rd_ddr_finish         ),
            
    // DDR interface 
    .init_calib_complete_o          ( init_calib_complete_o     ),
    .ddr3_dq                        ( ddr3_dq                   ),
    .ddr3_dqs_n                     ( ddr3_dqs_n                ),
    .ddr3_dqs_p                     ( ddr3_dqs_p                ),
    .ddr3_addr                      ( ddr3_addr                 ),
    .ddr3_ba                        ( ddr3_ba                   ),
    .ddr3_ras_n                     ( ddr3_ras_n                ),
    .ddr3_cas_n                     ( ddr3_cas_n                ),
    .ddr3_we_n                      ( ddr3_we_n                 ),
    .ddr3_reset_n                   ( ddr3_reset_n              ),
    .ddr3_ck_p                      ( ddr3_ck_p                 ),
    .ddr3_ck_n                      ( ddr3_ck_n                 ),
    .ddr3_cke                       ( ddr3_cke                  ),
    .ddr3_cs_n                      ( ddr3_cs_n                 ),
    .ddr3_dm                        ( ddr3_dm                   ),
    .ddr3_odt                       ( ddr3_odt                  )
);

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
