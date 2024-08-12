`timescale 1 ns / 1 ps

(* core_generation_info = "aurora_64b66b_1,aurora_64b66b_v12_0_6,{c_aurora_lanes=1,c_column_used=left,c_gt_clock_1=GTXQ1,c_gt_clock_2=None,c_gt_loc_1=X,c_gt_loc_10=X,c_gt_loc_11=X,c_gt_loc_12=X,c_gt_loc_13=X,c_gt_loc_14=X,c_gt_loc_15=X,c_gt_loc_16=X,c_gt_loc_17=X,c_gt_loc_18=X,c_gt_loc_19=X,c_gt_loc_2=X,c_gt_loc_20=X,c_gt_loc_21=X,c_gt_loc_22=X,c_gt_loc_23=X,c_gt_loc_24=X,c_gt_loc_25=X,c_gt_loc_26=X,c_gt_loc_27=X,c_gt_loc_28=X,c_gt_loc_29=X,c_gt_loc_3=X,c_gt_loc_30=X,c_gt_loc_31=X,c_gt_loc_32=X,c_gt_loc_33=X,c_gt_loc_34=X,c_gt_loc_35=X,c_gt_loc_36=X,c_gt_loc_37=X,c_gt_loc_38=X,c_gt_loc_39=X,c_gt_loc_4=X,c_gt_loc_40=X,c_gt_loc_41=X,c_gt_loc_42=X,c_gt_loc_43=X,c_gt_loc_44=X,c_gt_loc_45=X,c_gt_loc_46=X,c_gt_loc_47=X,c_gt_loc_48=X,c_gt_loc_5=1,c_gt_loc_6=X,c_gt_loc_7=X,c_gt_loc_8=X,c_gt_loc_9=X,c_lane_width=4,c_line_rate=10.0,c_gt_type=gtx,c_qpll=true,c_nfc=false,c_nfc_mode=IMM,c_refclk_frequency=100.0,c_simplex=false,c_simplex_mode=TX,c_stream=false,c_ufc=false,c_user_k=false,flow_mode=None,interface_mode=Framing,dataflow_config=Duplex}" *)
(* DowngradeIPIdentifiedWarnings="yes" *)
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/10/10
// Design Name: PCG
// Module Name: aurora_64b66b_1_exdes
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

module aurora_64b66b_1_exdes #(
    parameter           TCQ                = 0.1
)(
    output              aurora_log_clk_o                ,
    output  [4-1:0]     aurora_empty_o                  ,
    input               aurora_soft_rd_i                ,
    // eds
    input               eds_clk_i                       ,  // eds clk -> 100m/6
    input               clk_h_i                         ,  // eds clk_h -> 300m
    input               eds_sensor_vld_i                ,
    input   [128-1:0]   eds_sensor_data_i               ,
    input               eds_frame_en_i                  ,
    output              pcie_eds_end_o                  ,

    input               precise_encode_en_i             ,
    input   [32-1:0]    precise_encode_w_data_i         ,
    input   [32-1:0]    precise_encode_x_data_i         ,

    output              dbg_eds_frame_en_o              ,
    output              dbg_eds_wencode_vld_o           ,
    output  [18-1:0]    dbg_eds_wencode_o               ,

    // pmt
    input               pmt_clk_i                       ,  // sys clk -> 100m
    input               pmt_encode_vld_i                ,
    input   [64-1:0]    pmt_encode_data_i               ,
    input               pmt_start_en_i                  ,
    output              pcie_pmt_end_o                  ,

    // fbc
    input               fbc_clk_i                       ,  // sys clk -> 100m
    input               fbc_up_start_i                  ,
    output              aurora_fbc_end_o                ,
    input               fbc_vld_i                       ,
    input   [64-1:0]    fbc_data_i                      ,
    output              aurora_fbc_almost_full_o        ,

    input               aurora_scan_reset_i             ,
    output              aurora_tx_idle_o                ,
    output  [32-1:0]    eds_pack_cnt_o                  ,
    output  [32-1:0]    encode_pack_cnt_o               ,
    output  [32-1:0]    fbc_pack_cnt_o                  ,

    // Reset and clk
    input               RESET                           ,
    input               PMA_INIT                        ,
    input               INIT_CLK_P                      ,
    input               DRP_CLK_IN                      ,

    // Status
    output reg          LANE_UP                         ,
    output reg          CHANNEL_UP                      ,
    output reg          HARD_ERR                        ,
    output reg          SOFT_ERR                        ,

    // GTX Reference Clock Interface
    // input               GTXQ0_P                         ,
    // input               GTXQ0_N                         ,
    // GT clk from aurora_0_support
    input               refclk1_i                       ,
    input               gt_qpllclk_quad1_i              ,
    input               gt_qpllrefclk_quad1_i           ,
    input               gt_qpllrefclklost_i             ,
    input               gt_qplllock_i                   ,

    // GTX Serial I/O
    input               RXP                             ,
    input               RXN                             ,
    output              TXP                             ,
    output              TXN                             
);
//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg     [127:0]         pma_init_stage              = {128{1'b1}};
reg     [23:0]          pma_init_pulse_width_cnt    = 24'h0;
reg                     pma_init_assertion          = 1'b0;
reg                     gt_reset_delayed_r1;
reg                     gt_reset_delayed_r2;

reg                     aurora_end_en_d0            = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
//TX Interface
wire    [63:0]          tx_tdata                ; 
wire                    tx_tvalid               ;
wire    [7:0]           tx_tkeep                ;  
wire                    tx_tlast                ;
wire                    tx_tready               ;
//RX Interface
wire    [63:0]          rx_tdata                ;  
wire                    rx_tvalid               ;
wire    [7:0]           rx_tkeep                ;  
wire                    rx_tlast                ;


//Error Detection Interface
wire                    hard_err                ;
wire                    soft_err                ;

//Status
wire                    channel_up              ;
wire                    lane_up                 ;

//System Interface      
wire                    aurora_rst              ;
wire                    gt_reset_tmp            ;
wire                    gt_rxcdrovrden          ;
wire                    gt_reset_delayed        ;
wire                    gt_reset_eff            ;
wire                    gt_reset                ;
wire                    link_reset              ;
wire                    system_reset            ;
wire                    pll_not_locked          ;

wire                    power_down              ;
wire    [2:0]           loopback                ;
wire                    gt_pll_lock             ;
wire                    tx_out_clk              ;

// clock
wire                    user_clk                ;
wire                    sync_clk                ;
wire                    init_clk                ; // synthesis syn_keep = 1
wire                    drp_clk                 ;

wire    [8:0]           drpaddr_in              ;
wire    [15:0]          drpdi_in                ;
wire    [15:0]          drpdo_out               ;
wire                    drprdy_out              ;
wire                    drpen_in                ;
wire                    drpwe_in                ;
wire    [7:0]           qpll_drpaddr_in         ;
wire    [15:0]          qpll_drpdi_in           ;
wire    [15:0]          qpll_drpdo_out          ;
wire                    qpll_drprdy_out         ;
wire                    qpll_drpen_in           ;
wire                    qpll_drpwe_in           ;

wire                    aurora_scan_reset       ;
wire                    aurora_tx_idle          ;
wire                    aurora_eds_end          ;
wire                    aurora_scan_end         ;
wire                    aurora_fbc_end          ;

wire                    eds_tx_en               ;
wire    [63:0]          eds_tx_data             ;
wire                    eds_tx_full             ;
wire                    eds_tx_empty            ;
wire                    eds_tx_prog_empty       ;
// wire                    eds_wr_rst_busy         ;
// wire                    eds_rd_rst_busy         ;

wire                    aurora_fbc_en           ;
wire    [64-1:0]        aurora_fbc_data         ;
wire                    aurora_fbc_full         ;
wire                    aurora_fbc_empty        ;
wire                    aurora_fbc_almost_full  ;
wire                    aurora_fbc_prog_empty   ;
// wire                    aurora_fbc_wr_rst_busy  ;
// wire                    aurora_fbc_rd_rst_busy  ;

wire                    encode_tx_en            ;
wire    [64-1:0]        encode_tx_data          ;
wire                    encode_tx_full          ;
wire                    encode_tx_empty         ;
wire                    encode_tx_almost_empty  ;
wire                    encode_tx_almost_full   ;
wire                    encode_tx_prog_empty    ;
// wire                    encode_tx_wr_rst_busy   ;
// wire                    encode_tx_rd_rst_busy   ;

wire                    eds_precise_encode_wr_en;
wire                    eds_encode_rd_en        ;
wire                    eds_encode_full         ;
wire                    eds_encode_empty        ;
wire    [32-1:0]        precise_encode_w_data   ;
wire    [32-1:0]        precise_encode_x_data   ;

wire                    eds_data_wr_en          ;
wire                    eds_frame_en_sync       ;
wire                    pmt_start_en_sync       ;

wire                    eds_fifo_rst            ;
wire                    eds_fifo_wrst           ;
wire                    encode_fifo_rst         ;
wire    [32-1:0]        eds_pack_cnt            ;
wire    [32-1:0]        encode_pack_cnt         ;
wire    [32-1:0]        fbc_pack_cnt            ;

wire                    aurora_soft_rd          ;
wire                    eds_encode_inter_flag   ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
assign  eds_fifo_rst = aurora_rst || aurora_eds_end;
xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
 )
 eds_fifo_wrst_inst (
    .dest_out(eds_fifo_wrst), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                         // registered.

    .dest_clk(eds_clk_i), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk(user_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in(eds_fifo_rst)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );
eds_to_aurora_fifo eds_to_aurora_fifo_inst(
    .rst                        ( eds_fifo_wrst                 ),
    .wr_clk                     ( eds_clk_i                     ),
    .rd_clk                     ( user_clk                      ),
    .din                        ( eds_sensor_data_i             ),
    .wr_en                      ( eds_sensor_vld_i && eds_data_wr_en),
    .rd_en                      ( eds_tx_en || aurora_soft_rd   ),
    .dout                       ( eds_tx_data                   ),
    .full                       ( eds_tx_full                   ),
    .empty                      ( eds_tx_empty                  ),
    .prog_empty                 ( eds_tx_prog_empty             ),
    .wr_rst_busy                ( eds_wr_rst_busy               ),  // output wire wr_rst_busy
    .rd_rst_busy                ( eds_rd_rst_busy               )   // output wire rd_rst_busy
);
// xpm_async_fifo #(
//     .ECC_MODE                   ( "no_ecc"                              ),
//     .FIFO_MEMORY_TYPE           ( "block"                               ), // "auto" "block" "distributed"
//     .READ_MODE                  ( "fwft"                                ),
//     .FIFO_WRITE_DEPTH           ( 8192                                  ),
//     .PROG_EMPTY_THRESH          ( 1020                                  ),
//     .WRITE_DATA_WIDTH           ( 128                                   ),
//     .READ_DATA_WIDTH            ( 64                                    ),
//     .RELATED_CLOCKS             ( 1                                     ), // write clk same source of read clk
//     .USE_ADV_FEATURES           ( "0200"                                )
// )eds_to_aurora_fifo_inst (
//     .wr_clk_i                   ( eds_clk_i                             ),
//     .rst_i                      ( eds_fifo_wrst                         ), // synchronous to wr_clk
//     .wr_en_i                    ( eds_sensor_vld_i && eds_data_wr_en    ),
//     .wr_data_i                  ( eds_sensor_data_i                     ),
//     .fifo_full_o                ( eds_tx_full                           ),

//     .rd_clk_i                   ( user_clk                              ),
//     .rd_en_i                    ( eds_tx_en                             ),
//     .fifo_rd_data_o             ( eds_tx_data                           ),
//     .fifo_empty_o               ( eds_tx_empty                          ),
//     .fifo_prog_empty_o          ( eds_tx_prog_empty                     )
// );

// 100m -> 48k  100000/48 = 2083.3
localparam [12-1:0] EDS_ENCODE_INTE0 = 'd2082;
localparam [12-1:0] EDS_ENCODE_INTE1 = 'd2082;
localparam [12-1:0] EDS_ENCODE_INTE2 = 'd2083;
reg [3-1:0]  eds_encdeo_inter_sel = 'd1;
reg [12-1:0] eds_encode_cnt = 'd0;

assign eds_encode_inter_flag = ((eds_encode_cnt == EDS_ENCODE_INTE0) && eds_encdeo_inter_sel[0])
                                || ((eds_encode_cnt == EDS_ENCODE_INTE1) && eds_encdeo_inter_sel[1])
                                || ((eds_encode_cnt == EDS_ENCODE_INTE2) && eds_encdeo_inter_sel[2]);

always @(posedge pmt_clk_i) begin
    if(~eds_frame_en_i)
        eds_encdeo_inter_sel <= #TCQ 'd1;
    else if(eds_encode_inter_flag)
        eds_encdeo_inter_sel <= #TCQ {eds_encdeo_inter_sel[1:0],eds_encdeo_inter_sel[2]};
end

always @(posedge pmt_clk_i) begin
    if(~eds_frame_en_i)begin
        eds_encode_cnt <= #TCQ 'd0;
    end
    else if(precise_encode_en_i)begin
        if(eds_encode_inter_flag)
            eds_encode_cnt <= #TCQ 'd0;
        else 
            eds_encode_cnt <= #TCQ eds_encode_cnt + 1;
    end 
end 

assign eds_precise_encode_wr_en = eds_encode_inter_flag && precise_encode_en_i;

reg [14-1:0] eds_encode_index = 'd0;
always @(posedge pmt_clk_i) begin
    if(~eds_frame_en_i)
        eds_encode_index <= #TCQ 'd0;
    else if(eds_precise_encode_wr_en)
        eds_encode_index <= #TCQ eds_encode_index + 1;
end
// debug code
assign dbg_eds_frame_en_o    = eds_frame_en_i;
assign dbg_eds_wencode_vld_o = eds_precise_encode_wr_en;
assign dbg_eds_wencode_o     = precise_encode_w_data_i[18-1:0];

wire eds_encode_fifo_wrst;
xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
 )
 eds_encode_fifo_wrst_inst (
    .dest_out(eds_encode_fifo_wrst), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                         // registered.

    .dest_clk(pmt_clk_i), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk(user_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in(eds_fifo_rst)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );
sync_eds_encode_fifo sync_eds_encode_fifo_inst (
    .rst                        ( eds_encode_fifo_wrst                              ),  // input wire rst
    .wr_clk                     ( pmt_clk_i                                         ),  // input wire wr_clk
    .rd_clk                     ( user_clk                                          ),  // input wire rd_clk
    .din                        ( {{eds_encode_index[14-1:0],precise_encode_w_data_i[18-1:0]},precise_encode_x_data_i} ),  // input wire [63 : 0] din
    .wr_en                      ( eds_precise_encode_wr_en                          ),  // input wire wr_en
    .rd_en                      ( eds_encode_rd_en || aurora_soft_rd                ),  // input wire rd_en
    .dout                       ( {precise_encode_w_data,precise_encode_x_data}     ),  // output wire [63 : 0] dout
    .full                       ( eds_encode_full                                   ),  // output wire full
    .empty                      ( eds_encode_empty                                  )   // output wire empty
);

assign encode_fifo_rst = aurora_rst || aurora_scan_end;
wire encode_fifo_wrst;
xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
 )
 encode_fifo_wrst_inst (
    .dest_out(encode_fifo_wrst), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                         // registered.

    .dest_clk(pmt_clk_i), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk(user_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in(encode_fifo_rst)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );
cache_rd_fifo encode_to_aurora_fifo_inst(
    .rst                        ( encode_fifo_wrst              ),
    .wr_clk                     ( pmt_clk_i                     ),
    .rd_clk                     ( user_clk                      ),
    .din                        ( pmt_encode_data_i             ),
    .wr_en                      ( pmt_encode_vld_i              ),
    .rd_en                      ( encode_tx_en || aurora_soft_rd),
    .dout                       ( encode_tx_data                ),
    .full                       ( encode_tx_full                ),
    .empty                      ( encode_tx_empty               ),
    .almost_empty               ( encode_tx_almost_empty        ),  // flag indicating 1 word from empty
    .almost_full                ( encode_tx_almost_full         ),
    .prog_empty                 ( encode_tx_prog_empty          ),
    .wr_rst_busy                ( encode_tx_wr_rst_busy         ),  // output wire wr_rst_busy
    .rd_rst_busy                ( encode_tx_rd_rst_busy         )   // output wire rd_rst_busy
);
// xpm_async_fifo #(
//     .ECC_MODE                   ( "no_ecc"                              ),
//     .FIFO_MEMORY_TYPE           ( "block"                               ), // "auto" "block" "distributed"
//     .READ_MODE                  ( "fwft"                                ),
//     .FIFO_WRITE_DEPTH           ( 2048                                  ),
//     .PROG_EMPTY_THRESH          ( 1020                                  ),
//     .WRITE_DATA_WIDTH           ( 64                                    ),
//     .READ_DATA_WIDTH            ( 64                                    ),
//     .RELATED_CLOCKS             ( 1                                     ), // write clk same source of read clk
//     .USE_ADV_FEATURES           ( "0A08"                                )
// )encode_to_aurora_fifo_inst (
//     .wr_clk_i                   ( pmt_clk_i                             ),
//     .rst_i                      ( encode_fifo_wrst                      ), // synchronous to wr_clk
//     .wr_en_i                    ( pmt_encode_vld_i                      ),
//     .wr_data_i                  ( pmt_encode_data_i                     ),
//     .fifo_full_o                ( encode_tx_full                        ),
//     .fifo_almost_full_o         ( encode_tx_almost_full                 ),

//     .rd_clk_i                   ( user_clk                              ),
//     .rd_en_i                    ( encode_tx_en                          ),
//     .fifo_rd_data_o             ( encode_tx_data                        ),
//     .fifo_empty_o               ( encode_tx_empty                       ),
//     .fifo_almost_empty_o        ( encode_tx_almost_empty                ),
//     .fifo_prog_empty_o          ( encode_tx_prog_empty                  )
// );
wire fbc_fifo_wrst;
widen_enable #(
    .WIDEN_TYPE                 ( 1                             ),  // 1 = posedge lock
    .WIDEN_NUM                  ( 15                            )
)fbc_fifo_rst_inst(
    .clk_i                      ( fbc_clk_i                     ),
    .rst_i                      ( 0                             ),

    .src_signal_i               ( pmt_start_en_i                ),
    .dest_signal_o              ( fbc_fifo_wrst                 ) 
);

cache_rd_fifo fbc_to_aurora_fifo_inst(
    .rst                        ( fbc_fifo_wrst || aurora_fbc_end_o),
    .wr_clk                     ( fbc_clk_i                     ),
    .rd_clk                     ( user_clk                      ),
    .din                        ( fbc_data_i                    ),
    .wr_en                      ( fbc_vld_i                     ),
    .rd_en                      ( aurora_fbc_en                 ),
    .dout                       ( aurora_fbc_data               ),
    .full                       ( aurora_fbc_full               ),
    .empty                      ( aurora_fbc_empty              ),
    // .almost_empty               ( aurora_fbc_almost_empty       ),  // flag indicating 1 word from empty
    .almost_full                ( aurora_fbc_almost_full        ),
    .prog_empty                 ( aurora_fbc_prog_empty         ),
    .wr_rst_busy                ( aurora_fbc_wr_rst_busy        ),  // output wire wr_rst_busy
    .rd_rst_busy                ( aurora_fbc_rd_rst_busy        )   // output wire rd_rst_busy
);
// xpm_async_fifo #(
//     .ECC_MODE                   ( "no_ecc"                              ),
//     .FIFO_MEMORY_TYPE           ( "block"                               ), // "auto" "block" "distributed"
//     .READ_MODE                  ( "fwft"                                ),
//     .FIFO_WRITE_DEPTH           ( 2048                                  ),
//     .PROG_EMPTY_THRESH          ( 1020                                  ),
//     .WRITE_DATA_WIDTH           ( 64                                    ),
//     .READ_DATA_WIDTH            ( 64                                    ),
//     .RELATED_CLOCKS             ( 1                                     ), // write clk same source of read clk
//     .USE_ADV_FEATURES           ( "0A08"                                )
// )fbc_to_aurora_fifo_inst (
//     .wr_clk_i                   ( fbc_clk_i                             ),
//     .rst_i                      ( fbc_fifo_wrst                         ), // synchronous to wr_clk
//     .wr_en_i                    ( fbc_vld_i                             ),
//     .wr_data_i                  ( fbc_data_i                            ),
//     .fifo_full_o                ( aurora_fbc_full                       ),
//     .fifo_almost_full_o         ( aurora_fbc_almost_full                ),

//     .rd_clk_i                   ( user_clk                              ),
//     .rd_en_i                    ( aurora_fbc_en                         ),
//     .fifo_rd_data_o             ( aurora_fbc_data                       ),
//     .fifo_empty_o               ( aurora_fbc_empty                      ),
//     .fifo_almost_empty_o        ( aurora_fbc_almost_empty               ),
//     .fifo_prog_empty_o          ( aurora_fbc_prog_empty                 )
// );

aurora_64b66b_tx aurora_64b66b_tx_inst(
    // eds
    .eds_frame_en_i             ( eds_frame_en_sync             ),
    .aurora_eds_end_o           ( aurora_eds_end                ),
    .eds_tx_en_o                ( eds_tx_en                     ),
    .eds_tx_data_i              ( eds_tx_data                   ),
    .eds_tx_prog_empty_i        ( eds_tx_prog_empty             ),

    .eds_encode_empty_i         ( eds_encode_empty              ),
    .eds_encode_en_o            ( eds_encode_rd_en              ),
    .precise_encode_w_data_i    ( precise_encode_w_data         ),
    .precise_encode_x_data_i    ( precise_encode_x_data         ),

    // pmt encode
    .pmt_start_en_i             ( pmt_start_en_sync             ),
    .aurora_scan_end_o          ( aurora_scan_end               ),
    .encode_tx_en_o             ( encode_tx_en                  ),
    .encode_tx_data_i           ( encode_tx_data                ),
    .encode_tx_prog_empty_i     ( encode_tx_prog_empty          ),

    // FBC 
    .fbc_up_start_i             ( fbc_up_start_i                ),
    .aurora_fbc_end_o           ( aurora_fbc_end                ),
    .aurora_fbc_en_o            ( aurora_fbc_en                 ),
    .aurora_fbc_data_i          ( aurora_fbc_data               ),
    .aurora_fbc_prog_empty_i    ( aurora_fbc_prog_empty         ),
    .aurora_fbc_empty_i         ( aurora_fbc_empty              ),

    .aurora_scan_reset_i        ( aurora_scan_reset             ),
    .aurora_tx_idle_o           ( aurora_tx_idle                ),
    .eds_pack_cnt_o             ( eds_pack_cnt                  ),
    .encode_pack_cnt_o          ( encode_pack_cnt               ),
    .fbc_pack_cnt_o             ( fbc_pack_cnt                  ),
    
    // System Interface
    .USER_CLK                   ( user_clk                      ),
    .RESET                      ( aurora_rst                    ),
    .CHANNEL_UP                 ( 'd1                           ),
    
    .tx_tvalid_o                ( tx_tvalid                     ),
    .tx_tdata_o                 ( tx_tdata                      ),
    .tx_tkeep_o                 ( tx_tkeep                      ),
    .tx_tlast_o                 ( tx_tlast                      ),
    .tx_tready_i                ( tx_tready                     )
);

// aurora_64b66b_rx aurora_64b66b_rx_inst(
//     .pcie_eds_end_o             ( pcie_eds_end                  ),
//     .pcie_pmt_end_o             ( pcie_pmt_end                  ),
    
//     // System Interface
//     .USER_CLK                   ( user_clk                      ),      
//     .RESET                      ( aurora_rst                    ),
//     .CHANNEL_UP                 ( 'd1                           ),

//     .rx_tvalid_i                ( rx_tvalid                     ),
//     .rx_tdata_i                 ( rx_tdata                      ),
//     .rx_tkeep_i                 ( rx_tkeep                      ),
//     .rx_tlast_i                 ( rx_tlast                      )
// );

BUFG drpclk_bufg_i(
    .I  (DRP_CLK_IN),
    .O  (drp_clk)
);


// this is non shared mode, the clock, GT common are part of example design.
aurora_64b66b_1_support aurora_64b66b_0_block_i(
    // TX AXI4-S Interface
    .s_axi_tx_tdata             ( tx_tdata                      ),
    .s_axi_tx_tlast             ( tx_tlast                      ),
    .s_axi_tx_tkeep             ( tx_tkeep                      ),
    .s_axi_tx_tvalid            ( tx_tvalid                     ),
    .s_axi_tx_tready            ( tx_tready                     ),

    // RX AXI4-S Interface
    .m_axi_rx_tdata             ( rx_tdata                      ),
    .m_axi_rx_tlast             ( rx_tlast                      ),
    .m_axi_rx_tkeep             ( rx_tkeep                      ),
    .m_axi_rx_tvalid            ( rx_tvalid                     ),

    // GT Serial I/O
    .rxp                        ( RXP                           ),
    .rxn                        ( RXN                           ),

    .txp                        ( TXP                           ),
    .txn                        ( TXN                           ),

    //GT Reference Clock Interface
    // .gt_refclk1_p               ( GTXQ0_P                       ),
    // .gt_refclk1_n               ( GTXQ0_N                       ),
    // GT clk from aurora_0_support
    .refclk1_i                  ( refclk1_i                     ),
    .gt_qpllclk_quad1_i         ( gt_qpllclk_quad1_i            ),
    .gt_qpllrefclk_quad1_i      ( gt_qpllrefclk_quad1_i         ),
    .gt_qpllrefclklost_i        ( gt_qpllrefclklost_i           ),
    .gt_qplllock_i              ( gt_qplllock_i                 ),
    // Error Detection Interface
    .hard_err                   ( hard_err                      ),
    .soft_err                   ( soft_err                      ),

    // Status
    .channel_up                 ( channel_up                    ),
    .lane_up                    ( lane_up                       ),

    // System Interface
    .init_clk_out               ( init_clk                      ),
    .user_clk_out               ( user_clk                      ),

    .sync_clk_out               ( sync_clk                      ),
    .reset_pb                   ( aurora_rst                    ),
    .gt_rxcdrovrden_in          ( gt_rxcdrovrden                ),
    .power_down                 ( power_down                    ),
    .loopback                   ( loopback                      ),
    .pma_init                   ( gt_reset                      ),
    .gt_pll_lock                ( gt_pll_lock                   ),
    .drp_clk_in                 ( drp_clk                       ),
    //---------------------- GT DRP Ports ----------------------
    .drpaddr_in                 ( drpaddr_in                    ),
    .drpdi_in                   ( drpdi_in                      ),
    .drpdo_out                  ( drpdo_out                     ),
    .drprdy_out                 ( drprdy_out                    ),
    .drpen_in                   ( drpen_in                      ),
    .drpwe_in                   ( drpwe_in                      ),


    //---------------------- GTXE2 COMMON DRP Ports ----------------------
    .qpll_drpaddr_in            ( qpll_drpaddr_in               ),
    .qpll_drpdi_in              ( qpll_drpdi_in                 ),
    .qpll_drpdo_out             ( qpll_drpdo_out                ),
    .qpll_drprdy_out            ( qpll_drprdy_out               ),
    .qpll_drpen_in              ( qpll_drpen_in                 ),
    .qpll_drpwe_in              ( qpll_drpwe_in                 ),
    .init_clk_p                 ( INIT_CLK_P                    ),
    // .init_clk_n                 ( INIT_CLK_N                    ),
    .link_reset_out             ( link_reset                    ),
    .mmcm_not_locked_out        ( pll_not_locked                ),

    .sys_reset_out              ( system_reset                  ),
    .tx_out_clk                 ( tx_out_clk                    )
);

xpm_cdc_pulse #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .REG_OUTPUT(0),     // DECIMAL; 0=disable registered output, 1=enable registered output
    .RST_USED(0),       // DECIMAL; 0=no reset, 1=implement reset
    .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
 )
 aurora_scan_reset_inst (
    .dest_pulse(aurora_scan_reset), // 1-bit output: Outputs a pulse the size of one dest_clk period when a pulse
                             // transfer is correctly initiated on src_pulse input. This output is
                             // combinatorial unless REG_OUTPUT is set to 1.

    .dest_clk(user_clk),     // 1-bit input: Destination clock.
    .dest_rst('d0),     // 1-bit input: optional; required when RST_USED = 1
    .src_clk(pmt_clk_i),       // 1-bit input: Source clock.
    .src_pulse(aurora_scan_reset_i),   // 1-bit input: Rising edge of this signal initiates a pulse transfer to the
                             // destination clock domain. The minimum gap between each pulse transfer must be
                             // at the minimum 2*(larger(src_clk period, dest_clk period)). This is measured
                             // between the falling edge of a src_pulse to the rising edge of the next
                             // src_pulse. This minimum gap will guarantee that each rising edge of src_pulse
                             // will generate a pulse the size of one dest_clk period in the destination
                             // clock domain. When RST_USED = 1, pulse transfers will not be guaranteed while
                             // src_rst and/or dest_rst are asserted.

    .src_rst('d0)        // 1-bit input: optional; required when RST_USED = 1
 );

 xpm_cdc_pulse #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .REG_OUTPUT(0),     // DECIMAL; 0=disable registered output, 1=enable registered output
    .RST_USED(0),       // DECIMAL; 0=no reset, 1=implement reset
    .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
 )
 aurora_fbc_end_inst (
    .dest_pulse(aurora_fbc_end_o), // 1-bit output: Outputs a pulse the size of one dest_clk period when a pulse
                             // transfer is correctly initiated on src_pulse input. This output is
                             // combinatorial unless REG_OUTPUT is set to 1.

    .dest_clk(fbc_clk_i),     // 1-bit input: Destination clock.
    .dest_rst('d0),     // 1-bit input: optional; required when RST_USED = 1
    .src_clk(user_clk),       // 1-bit input: Source clock.
    .src_pulse(aurora_fbc_end),   // 1-bit input: Rising edge of this signal initiates a pulse transfer to the
                             // destination clock domain. The minimum gap between each pulse transfer must be
                             // at the minimum 2*(larger(src_clk period, dest_clk period)). This is measured
                             // between the falling edge of a src_pulse to the rising edge of the next
                             // src_pulse. This minimum gap will guarantee that each rising edge of src_pulse
                             // will generate a pulse the size of one dest_clk period in the destination
                             // clock domain. When RST_USED = 1, pulse transfers will not be guaranteed while
                             // src_rst and/or dest_rst are asserted.

    .src_rst('d0)        // 1-bit input: optional; required when RST_USED = 1
 );

xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
 )
 aurora_tx_idle_inst (
    .dest_out(aurora_tx_idle_o), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                         // registered.

    .dest_clk(pmt_clk_i), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk(user_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in(aurora_tx_idle)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );
 
xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
 )
 pcie_eds_end_inst (
    .dest_out(pcie_eds_end_o), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                         // registered.

    .dest_clk(clk_h_i), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk(user_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in(aurora_eds_end)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );

 xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
 )
 pcie_pmt_end_inst (
    .dest_out(pcie_pmt_end_o), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                         // registered.

    .dest_clk(pmt_clk_i), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk(user_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in(aurora_scan_end)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );

 xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
 )
 eds_frame_en_inst (
    .dest_out(eds_frame_en_sync), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                         // registered.

    .dest_clk(user_clk), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk(pmt_clk_i),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in(eds_frame_en_i)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );

 xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
 )
 eds_data_wr_en_inst (
    .dest_out(eds_data_wr_en), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                         // registered.

    .dest_clk(eds_clk_i), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk(pmt_clk_i),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in(eds_frame_en_i)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );

 xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
 )
 xpm_cdc_single_inst (
    .dest_out(pmt_start_en_sync), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                         // registered.

    .dest_clk(user_clk), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk(pmt_clk_i),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in(pmt_start_en_i)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );

 xpm_cdc_gray #(
    .DEST_SYNC_FF(2),          // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),          // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .REG_OUTPUT(1),            // DECIMAL; 0=disable registered output, 1=enable registered output
    .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SIM_LOSSLESS_GRAY_CHK(0), // DECIMAL; 0=disable lossless check, 1=enable lossless check
    .WIDTH(32)                  // DECIMAL; range: 2-32
 )
 xpm_cdc_eds_pack_inst (
    .dest_out_bin(eds_pack_cnt_o), // WIDTH-bit output: Binary input bus (src_in_bin) synchronized to
                                 // destination clock domain. This output is combinatorial unless REG_OUTPUT
                                 // is set to 1.

    .dest_clk(pmt_clk_i),         // 1-bit input: Destination clock.
    .src_clk(user_clk),           // 1-bit input: Source clock.
    .src_in_bin(eds_pack_cnt)      // WIDTH-bit input: Binary input bus that will be synchronized to the
                                 // destination clock domain.

 );

 xpm_cdc_gray #(
    .DEST_SYNC_FF(2),          // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),          // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .REG_OUTPUT(1),            // DECIMAL; 0=disable registered output, 1=enable registered output
    .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SIM_LOSSLESS_GRAY_CHK(0), // DECIMAL; 0=disable lossless check, 1=enable lossless check
    .WIDTH(32)                  // DECIMAL; range: 2-32
 )
 xpm_cdc_encode_pack_inst (
    .dest_out_bin(encode_pack_cnt_o), // WIDTH-bit output: Binary input bus (src_in_bin) synchronized to
                                 // destination clock domain. This output is combinatorial unless REG_OUTPUT
                                 // is set to 1.

    .dest_clk(pmt_clk_i),         // 1-bit input: Destination clock.
    .src_clk(user_clk),           // 1-bit input: Source clock.
    .src_in_bin(encode_pack_cnt)      // WIDTH-bit input: Binary input bus that will be synchronized to the
                                 // destination clock domain.

 );

  xpm_cdc_gray #(
    .DEST_SYNC_FF(2),          // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),          // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .REG_OUTPUT(1),            // DECIMAL; 0=disable registered output, 1=enable registered output
    .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SIM_LOSSLESS_GRAY_CHK(0), // DECIMAL; 0=disable lossless check, 1=enable lossless check
    .WIDTH(32)                  // DECIMAL; range: 2-32
 )
 xpm_cdc_fbc_pack_inst (
    .dest_out_bin(fbc_pack_cnt_o), // WIDTH-bit output: Binary input bus (src_in_bin) synchronized to
                                 // destination clock domain. This output is combinatorial unless REG_OUTPUT
                                 // is set to 1.

    .dest_clk(pmt_clk_i),         // 1-bit input: Destination clock.
    .src_clk(user_clk),           // 1-bit input: Source clock.
    .src_in_bin(fbc_pack_cnt)      // WIDTH-bit input: Binary input bus that will be synchronized to the
                                 // destination clock domain.

 );

 xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
 )
 aurora_soft_cdc_inst (
    .dest_out(aurora_soft_rd), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                         // registered.

    .dest_clk(user_clk), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk(pmt_clk_i),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in(aurora_soft_rd_i)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );
 
 xpm_cdc_gray #(
    .DEST_SYNC_FF(2),          // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),          // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .REG_OUTPUT(1),            // DECIMAL; 0=disable registered output, 1=enable registered output
    .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SIM_LOSSLESS_GRAY_CHK(0), // DECIMAL; 0=disable lossless check, 1=enable lossless check
    .WIDTH(4)                  // DECIMAL; range: 2-32
 )
 empty_gray_inst (
    .dest_out_bin(aurora_empty_o), // WIDTH-bit output: Binary input bus (src_in_bin) synchronized to
                                 // destination clock domain. This output is combinatorial unless REG_OUTPUT
                                 // is set to 1.

    .dest_clk(pmt_clk_i),         // 1-bit input: Destination clock.
    .src_clk(user_clk),           // 1-bit input: Source clock.
    .src_in_bin({aurora_fbc_empty,eds_tx_empty,eds_encode_empty,encode_tx_empty})      // WIDTH-bit input: Binary input bus that will be synchronized to the
                                 // destination clock domain.

 );
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

// System Interface
assign  power_down_i        = 1'b0;
// Native DRP Interface
assign  drpaddr_in          = 'h0;
assign  drpdi_in            = 16'h0;
assign  drpen_in            = 1'b0;
assign  drpwe_in            = 1'b0;

assign  qpll_drpaddr_in     =  8'h0;
assign  qpll_drpdi_in       =  16'h0;
assign  qpll_drpen_in       =  1'b0;
assign  qpll_drpwe_in       =  1'b0;

// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  gt_reset timming
//  <- 128clk cycle -> <------------24bit------------> 
//                      ______________________________
//  ___________________|                              |______________________
//
// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
always @(posedge init_clk)begin
    pma_init_stage[127:0] <= {pma_init_stage[126:0], gt_reset_tmp};
end

assign gt_reset_delayed = pma_init_stage[127];

always @(posedge init_clk)begin
    gt_reset_delayed_r1   <= #TCQ gt_reset_delayed;
    gt_reset_delayed_r2   <= #TCQ gt_reset_delayed_r1;
end
always @(posedge init_clk) begin
    if(~gt_reset_delayed_r2 & gt_reset_delayed_r1 & ~pma_init_assertion & (pma_init_pulse_width_cnt != 24'hFFFFFF))
        pma_init_assertion <= 1'b1;
    else if (pma_init_assertion & pma_init_pulse_width_cnt == 24'hFFFFFF)
        pma_init_assertion <= 1'b0;

    if(pma_init_assertion)
        pma_init_pulse_width_cnt <= pma_init_pulse_width_cnt + 24'h1;
end

assign  gt_reset_tmp      = PMA_INIT;
assign  aurora_rst        = RESET;
assign  gt_reset_eff      = pma_init_assertion ? 1'b1 : gt_reset_delayed;
assign  gt_reset          = gt_reset_eff;
assign  gt_rxcdrovrden    = 1'b0;
assign  loopback          = 3'b000;

// Register User Outputs from core.
always @(posedge user_clk)begin
    HARD_ERR    <= #TCQ hard_err;
    SOFT_ERR    <= #TCQ soft_err;
    LANE_UP     <= #TCQ lane_up;
    CHANNEL_UP  <= #TCQ channel_up;
end

assign aurora_log_clk_o         = user_clk;
assign aurora_fbc_almost_full_o = aurora_fbc_almost_full;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
endmodule
 
