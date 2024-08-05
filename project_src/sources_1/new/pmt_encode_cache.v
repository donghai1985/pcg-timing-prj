`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/10/10
// Design Name: PCG
// Module Name: pmt_encode_cache
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


module pmt_encode_cache #(
    parameter                               TCQ                 = 0.1   
)(
    // clk & rst
    input   wire                            clk_i                       ,
    input   wire                            rst_i                       ,

    // Enocde
    input   wire                            x_zero_flag_i               ,
    input   wire                            encode_update_i             ,
    input   wire    [32-1:0]                encode_w_i                  ,
    input   wire    [32-1:0]                encode_x_i                  ,

    input   wire                            pmt_scan_en_i               ,

    // aurora
    input   wire                            aurora_clk_1_i              ,
    input   wire                            aurora_fbc_en_1_i           ,
    output  wire    [64-1:0]                aurora_fbc_data_1_o         ,
    output  wire    [11-1:0]                aurora_fbc_count_1_o        ,
    output  reg                             aurora_fbc_end_1_o          ,
    output  wire                            aurora_fbc_empty_1_o        ,

    input   wire                            aurora_clk_2_i              ,
    input   wire                            aurora_fbc_en_2_i           ,
    output  wire    [64-1:0]                aurora_fbc_data_2_o         ,
    output  wire    [11-1:0]                aurora_fbc_count_2_o        ,
    output  reg                             aurora_fbc_end_2_o          ,
    output  wire                            aurora_fbc_empty_2_o        ,

    input   wire                            aurora_clk_3_i              ,
    input   wire                            aurora_fbc_en_3_i           ,
    output  wire    [64-1:0]                aurora_fbc_data_3_o         ,
    output  wire    [11-1:0]                aurora_fbc_count_3_o        ,
    output  reg                             aurora_fbc_end_3_o          ,
    output  wire                            aurora_fbc_empty_3_o        
);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
genvar i;



//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                     pmt_start_en_d      = 'd0;
reg                     pmt_end_en_d0       = 'd0;
reg                     pmt_end_en_d1       = 'd0;
reg                     pmt_end_en_d2       = 'd0;
reg                     pmt_scan_en         = 'd0;

reg                     rd_en               = 'd0;
reg                     rd_en_d             = 'd0;
reg     [1:0]           rd_en_cnt           = 'd0;
reg     [1:0]           rd_dout_cnt         = 'd0;
reg                     fbc_cache_vld       = 'd0; 
reg     [64-1:0]        fbc_cache_data      = 'd0;

(*async_reg="true"*)reg                     aurora_end_en_r1    = 'd0;
(*async_reg="true"*)reg                     aurora_end_en_r2    = 'd0;
(*async_reg="true"*)reg                     aurora_end_en_r3    = 'd0;
reg                     fbc_vout_rd_seq     = 'd0;
reg                     fbc_vout_rd_vld     = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire    [4-1:0]         cache_fifo_wr           ;
wire    [64-1:0]        cache_fifo_din[4-1:0]   ;
wire    [64-1:0]        cache_fifo_dout[4-1:0]  ;
wire    [4-1:0]         cache_fifo_rd           ;
wire    [4-1:0]         cache_fifo_full         ;
wire    [4-1:0]         cache_fifo_empty        ;

(*async_reg="true"*)wire                    pmt_start_en_pose       ;
(*async_reg="true"*)wire                    pmt_end_en_pose         ;

wire    [3-1:0]         cache_rd_start          ;

wire                    cache_rd_full_1         ;
wire                    cache_rd_full_2         ;
wire                    cache_rd_full_3         ;
wire                    cache_rd_almost_full_1  ;
wire                    cache_rd_almost_full_2  ;
wire                    cache_rd_almost_full_3  ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
encode_process #(
    .FIRST_DELTA_WENCODE        ( 0                                         ),  // 初始 W Encode 增量，用于 first Encode 前插值
    .FIRST_DELTA_XENCODE        ( 0                                         ),  // 初始 X Encode 增量，用于 first Encode 前插值
    .EXTEND_WIDTH               ( 20                                        ),  // 定点位宽
    .UNIT_INTER                 ( 6250                                      ),  // 插值数，= 100M / 16k 
    .DELTA_UPDATE_DOT           ( 2                                         ),  // 插值点倍率
    .DELTA_UPDATE_GAP           ( 2                                         ),  // 插值点倍率, precise_encode_en freq = 16k * UNIT_INTER / DELTA_UPDATE_GAP * DELTA_UPDATE_DOT
    .ENCODE_MASK_WID            ( 18                                        ),  // W Encode 有效位宽，W Encode 零点规定为有效位宽最大值
    .ENCODE_WID                 ( 32                                        )   // Encode 位宽
)encode_process_inst(
    // clk & rst
    .clk_i                      ( clk_100m                                  ),
    .rst_i                      ( rst_100m                                  ),

    .x_zero_flag_i              ( x_zero_flag_i                             ),
    .encode_update_i            ( encode_update_i                           ),
    .encode_w_i                 ( encode_w_i                                ),
    .encode_x_i                 ( encode_x_i                                ),

    .precise_encode_en_o        ( precise_encode_en                         ),
    .precise_encode_w_o         ( precise_encode_w                          ),
    .precise_encode_x_o         ( precise_encode_x                          )
);

cache_rd_fifo cache_rd_fifo_inst1(
    .rst            ( pmt_start_en_pose     ),
    .wr_clk         ( clk_i                 ),
    .rd_clk         ( aurora_clk_1_i        ),
    .din            ( fbc_vout_rd_data_i    ),
    .wr_en          ( fbc_vout_rd_seq       ),
    .rd_en          ( aurora_fbc_en_1_i     ),
    .dout           ( aurora_fbc_data_1_o   ),
    .full           ( cache_rd_full_1       ),
    .almost_empty   ( aurora_fbc_empty_1_o  ),  // flag indicating 1 word from empty
    .almost_full    ( cache_rd_almost_full_1),
    .empty          (                       ),
    .rd_data_count  ( aurora_fbc_count_1_o  ),
    .wr_rst_busy    (),
    .rd_rst_busy    ()
);

cache_rd_fifo cache_rd_fifo_inst2(
    .rst            ( pmt_start_en_pose     ),
    .wr_clk         ( clk_i                 ),
    .rd_clk         ( aurora_clk_2_i        ),
    .din            ( fbc_vout_rd_data_i    ),
    .wr_en          ( fbc_vout_rd_seq       ),
    .rd_en          ( aurora_fbc_en_2_i     ),
    .dout           ( aurora_fbc_data_2_o   ),
    .full           ( cache_rd_full_2       ),
    .almost_empty   ( aurora_fbc_empty_2_o  ),  // flag indicating 1 word from empty
    .almost_full    ( cache_rd_almost_full_2),
    .empty          (                       ),
    .rd_data_count  ( aurora_fbc_count_2_o  ),
    .wr_rst_busy    (),
    .rd_rst_busy    ()
);

cache_rd_fifo cache_rd_fifo_inst3(
    .rst            ( pmt_start_en_pose     ),
    .wr_clk         ( clk_i                 ),
    .rd_clk         ( aurora_clk_3_i        ),
    .din            ( fbc_vout_rd_data_i    ),
    .wr_en          ( fbc_vout_rd_seq       ),
    .rd_en          ( aurora_fbc_en_3_i     ),
    .dout           ( aurora_fbc_data_3_o   ),
    .full           ( cache_rd_full_3       ),
    .almost_empty   ( aurora_fbc_empty_3_o  ),  // flag indicating 1 word from empty
    .almost_full    ( cache_rd_almost_full_3),
    .empty          (                       ),
    .rd_data_count  ( aurora_fbc_count_3_o  ),
    .wr_rst_busy    (),
    .rd_rst_busy    ()
);
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
assign cache_fifo_din[0] = {1'b1,2'd0,encode_w_i[28:0],encode_x_i[31:0]};
assign cache_fifo_din[1] = {1'b1,2'd1,5'd0,FBCi_out_a_i[23:0],8'd0,FBCi_out_b_i[23:0]};
assign cache_fifo_din[2] = {1'b1,2'd2,5'd0,FBCr1_out_a_i[23:0],8'd0,FBCr1_out_b_i[23:0]};
assign cache_fifo_din[3] = {1'b1,2'd3,5'd0,FBCr2_out_a_i[23:0],8'd0,FBCr2_out_b_i[23:0]};

assign cache_fifo_wr[0]  = FBCi_out_en_i && pmt_scan_en;
assign cache_fifo_wr[1]  = FBCi_out_en_i && pmt_scan_en;
assign cache_fifo_wr[2]  = FBCr1_out_en_i && pmt_scan_en;
assign cache_fifo_wr[3]  = FBCr2_out_en_i && pmt_scan_en;

always @(posedge clk_i) pmt_start_en_d <= #TCQ |pmt_start_en_i;
always @(posedge clk_i) pmt_end_en_d0 <= #TCQ |pmt_end_en_i;
always @(posedge clk_i) pmt_end_en_d1 <= #TCQ pmt_end_en_d0;
always @(posedge clk_i) pmt_end_en_d2 <= #TCQ pmt_end_en_d1;

assign pmt_start_en_pose = ~pmt_start_en_d && |pmt_start_en_i;
assign pmt_end_en_pose = ~pmt_end_en_d2 && pmt_end_en_d1;

always @(posedge clk_i) begin
    if(pmt_start_en_pose)
        pmt_scan_en <= #TCQ 'd1;
    else if(pmt_end_en_pose)
        pmt_scan_en <= #TCQ 'd0;
end

wire cache_fifo_ready ;
assign cache_fifo_ready = cache_fifo_empty=='d0;

always @(posedge clk_i) begin
    if(cache_fifo_ready && ~fbc_cache_full_i)
        rd_en <= #TCQ 'd1;
    else if(rd_en_cnt=='d3)
        rd_en <= #TCQ 'd0;
end
always @(posedge clk_i) begin
    if(rd_en)
        rd_en_cnt <= #TCQ rd_en_cnt + 1;
end

assign cache_fifo_rd[0] = rd_en && rd_en_cnt=='d0;
assign cache_fifo_rd[1] = rd_en && rd_en_cnt=='d1;
assign cache_fifo_rd[2] = rd_en && rd_en_cnt=='d2;
assign cache_fifo_rd[3] = rd_en && rd_en_cnt=='d3;

always @(posedge clk_i) rd_dout_cnt <= #TCQ rd_en_cnt;
always @(posedge clk_i) begin
    case (rd_dout_cnt)
        'd0:  fbc_cache_data <= #TCQ cache_fifo_dout[0];
        'd1:  fbc_cache_data <= #TCQ cache_fifo_dout[1];
        'd2:  fbc_cache_data <= #TCQ cache_fifo_dout[2];
        'd3:  fbc_cache_data <= #TCQ cache_fifo_dout[3];
        default: /*default*/;
    endcase
end
always @(posedge clk_i) rd_en_d <= #TCQ rd_en;
always @(posedge clk_i) fbc_cache_vld <= #TCQ rd_en_d;

assign pmt_scan_en_o    = pmt_scan_en;
assign fbc_cache_vld_o  = fbc_cache_vld;
assign fbc_cache_data_o = fbc_cache_data;

// transfer to pcie board
(*async_reg="true"*)reg aurora_transfer_en = 'd0;
always @(posedge clk_i) begin
    if(pmt_end_en_pose)
        aurora_transfer_en <= #TCQ 'd1;
    else if(pmt_start_en_pose)
        aurora_transfer_en <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(~fbc_vout_empty_i && ~(cache_rd_almost_full_1 && cache_rd_almost_full_2 && cache_rd_almost_full_3) && aurora_transfer_en)
        fbc_vout_rd_seq <= #TCQ 'd1;
    else 
        fbc_vout_rd_seq <= #TCQ 'd0;
end

// always @(posedge clk_i) begin
//     fbc_vout_rd_vld <= #TCQ fbc_vout_rd_seq;
// end

always @(posedge aurora_clk_1_i) aurora_end_en_r1   <= #TCQ fbc_vout_end_i;
always @(posedge aurora_clk_1_i) aurora_fbc_end_1_o <= #TCQ aurora_end_en_r1;

always @(posedge aurora_clk_2_i) aurora_end_en_r2   <= #TCQ fbc_vout_end_i;
always @(posedge aurora_clk_2_i) aurora_fbc_end_2_o <= #TCQ aurora_end_en_r2;

always @(posedge aurora_clk_3_i) aurora_end_en_r3   <= #TCQ fbc_vout_end_i;
always @(posedge aurora_clk_3_i) aurora_fbc_end_3_o <= #TCQ aurora_end_en_r3;

assign fbc_vout_rd_seq_o = fbc_vout_rd_seq;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


// debug code
// reg [16-1:0] debug_data = 'd0;
// always @(posedge clk_i) begin
//     if(fbc_vout_rd_seq)
//         debug_data <= #TCQ fbc_vout_rd_data_i[16-1:0];
// end

// reg debug_flag = 'd0;
// always @(posedge clk_i) begin
//     if(pmt_start_en_pose)
//         debug_flag <= #TCQ 'd0;
//     else if(fbc_vout_rd_seq)
//         debug_flag <= #TCQ 'd1;
// end

// reg debug_result = 'd0;
// always @(posedge clk_i) begin
//     if(pmt_start_en_pose)begin
//         debug_result <= #TCQ 'd0;
//     end
//     else if(debug_flag && fbc_vout_rd_seq)begin
//         if((debug_data + 1) != fbc_vout_rd_data_i[16-1:0])begin
//             debug_result <= #TCQ 'd1;
//         end
//     end
// end

endmodule
