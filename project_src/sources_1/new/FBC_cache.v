`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/05/18
// Design Name: PCG
// Module Name: message_comm_tx
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


module FBC_cache #(
    parameter                               TCQ                 = 0.1   
)(
    // clk & rst
    input   wire                            clk_i                       ,
    input   wire                            rst_i                       ,

    input   wire                            cfg_QPD_enable_i            ,
    // FBC actual voltage
    input   wire                            FBCi_cache_vld_i            ,
    input   wire    [48-1:0]                FBCi_cache_data_i           ,
    input   wire                            FBCr1_cache_vld_i           ,
    input   wire    [48-1:0]                FBCr1_cache_data_i          ,
    input   wire                            FBCr2_cache_vld_i           ,
    input   wire    [48-1:0]                FBCr2_cache_data_i          ,

    input   wire                            quad_cache_vld_i            ,
    input   wire    [96-1:0]                quad_cache_data_i           ,

    // Enocde
    input   wire    [32-1:0]                encode_w_i                  ,
    input   wire    [32-1:0]                encode_x_i                  ,

    input   wire                            real_scan_flag_i            ,
    input   wire                            pmt_scan_en_i               ,
    output  wire                            fbc_scan_en_o               ,
    input   wire    [3-1:0]                 fbc_up_en_i                 ,

    // ddr
    output  wire                            fbc_cache_vld_o             ,
    output  wire    [256-1:0]               fbc_cache_data_o            ,

    input   wire                            fbc_vout_empty_i            ,
    output  wire                            fbc_vout_rd_seq_o           ,
    input   wire                            fbc_vout_rd_vld_i           ,
    input   wire    [64-1:0]                fbc_vout_rd_data_i          ,
    // aurora
    output  wire                            aurora_fbc_vout_vld_o       ,
    output  wire    [64-1:0]                aurora_fbc_vout_data_o      ,
    input   wire                            aurora_fbc_almost_full_1_i  ,
    input   wire                            aurora_fbc_almost_full_2_i  ,
    input   wire                            aurora_fbc_almost_full_3_i  

);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
genvar i;
localparam              CACHE_NUM           = 4;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                     pmt_scan_en_d       = 'd0;
reg                     real_scan_flag_d    = 'd0;
reg                     real_scan_flag_latch= 'd0;

reg                     rd_en               = 'd0;
reg                     rd_en_d             = 'd0;
reg     [1:0]           rd_en_cnt           = 'd0;
reg     [1:0]           rd_dout_cnt         = 'd0;
reg                     fbc_cache_vld       = 'd0; 
reg     [256-1:0]       fbc_cache_data      = 'd0;

// reg                     aurora_end_en_r1    = 'd0;
// reg                     aurora_end_en_r2    = 'd0;
// reg                     aurora_end_en_r3    = 'd0;
reg                     fbc_vout_rd_seq     = 'd0;
reg                     fbc_vout_rd_vld     = 'd0;

reg     [18-1:0]        Wencode_sync            = 'd0;
reg     [18-1:0]        Xencode_sync            = 'd0;
reg     [48-1:0]        FBCi_cache_data_sync    = 'd0;
reg     [48-1:0]        FBCr1_cache_data_sync   = 'd0;
reg     [48-1:0]        FBCr2_cache_data_sync   = 'd0;
reg     [96-1:0]        quad_cache_data_sync    = 'd0;

reg                     FBCi_cache_ready        = 'd0;
reg                     FBCr1_cache_ready       = 'd0;
reg                     FBCr2_cache_ready       = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire    [CACHE_NUM-1:0] cache_fifo_wr           ;
wire    [64-1:0]        cache_fifo_din[CACHE_NUM-1:0]   ;
wire    [64-1:0]        cache_fifo_dout[CACHE_NUM-1:0]  ;
wire    [CACHE_NUM-1:0] cache_fifo_rd           ;
wire    [CACHE_NUM-1:0] cache_fifo_full         ;
wire    [CACHE_NUM-1:0] cache_fifo_empty        ;
wire    [CACHE_NUM-1:0] cache_fifo_almost_empty ;

wire                    fbc_up_start_pose       ;
wire                    fbc_up_start_nege       ;

wire                    cache_write_en          ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
generate
    for(i=0;i<CACHE_NUM;i=i+1)begin : FBC_CACHE
        fbc_cache_fifo fbc_cache_fifo_inst(
            .clk            ( clk_i                 ),
            .srst           ( rst_i                 ),
            .din            ( cache_fifo_din[i]     ),
            .wr_en          ( cache_fifo_wr[i]      ),
            .rd_en          ( rd_en || (~real_scan_flag_latch) ),
            .dout           ( cache_fifo_dout[i]    ),
            .full           ( cache_fifo_full[i]    ),
            .empty          ( cache_fifo_empty[i]   ),
            .almost_empty   ( cache_fifo_almost_empty[i])
        );    
    end
endgenerate

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) pmt_scan_en_d <= #TCQ pmt_scan_en_i;
always @(posedge clk_i) real_scan_flag_d <= #TCQ real_scan_flag_i;


always @(posedge clk_i) begin
    if(cfg_QPD_enable_i)begin
        if(quad_cache_vld_i)    Wencode_sync            <= #TCQ encode_w_i[17:0];
        if(quad_cache_vld_i)    Xencode_sync            <= #TCQ encode_x_i[17:0];
    end
    else begin
        if(FBCr2_cache_vld_i)    Wencode_sync            <= #TCQ encode_w_i[17:0];
        if(FBCr2_cache_vld_i)    Xencode_sync            <= #TCQ encode_x_i[17:0];
    end
end

always @(posedge clk_i) begin
    if(FBCi_cache_vld_i)    FBCi_cache_data_sync    <= #TCQ FBCi_cache_data_i;
    if(FBCr1_cache_vld_i)   FBCr1_cache_data_sync   <= #TCQ FBCr1_cache_data_i;
    if(FBCr2_cache_vld_i)   FBCr2_cache_data_sync   <= #TCQ FBCr2_cache_data_i;
    if(quad_cache_vld_i)    quad_cache_data_sync    <= #TCQ quad_cache_data_i;
end


always @(posedge clk_i) begin
    if(FBCi_cache_vld_i && real_scan_flag_d)
        FBCi_cache_ready <= #TCQ 'd1;
    else if(cache_write_en)
        FBCi_cache_ready <= #TCQ 'd0;

    if(FBCr2_cache_vld_i && real_scan_flag_d)
        FBCr2_cache_ready <= #TCQ 'd1;
    else if(cache_write_en)
        FBCr2_cache_ready <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(cfg_QPD_enable_i)begin
        if(quad_cache_vld_i && real_scan_flag_d)
            FBCr1_cache_ready <= #TCQ 'd1;
        else if(cache_write_en)
            FBCr1_cache_ready <= #TCQ 'd0;
    end
    else begin
        if(FBCr1_cache_vld_i && real_scan_flag_d)
            FBCr1_cache_ready <= #TCQ 'd1;
        else if(cache_write_en)
            FBCr1_cache_ready <= #TCQ 'd0;
    end
end


assign cache_write_en = (FBCi_cache_ready && FBCr1_cache_ready && FBCr2_cache_ready) ;


assign cache_fifo_din[0] = cfg_QPD_enable_i ?  {8'hff,6'd0,Wencode_sync[17:0],14'd0,Xencode_sync[17:0]}     : {1'b1,2'd0,11'd0,Wencode_sync[17:0],14'd0,Xencode_sync[17:0]};
assign cache_fifo_din[1] = cfg_QPD_enable_i ?  {FBCi_cache_data_sync[47:0],FBCr2_cache_data_sync[47:32]}    : {1'b1,2'd1,5'd0,FBCi_cache_data_sync[47:24],8'd0,FBCi_cache_data_sync[23:0]};
assign cache_fifo_din[2] = cfg_QPD_enable_i ?  {FBCr2_cache_data_sync[31:0],quad_cache_data_sync[95:64]}    : {1'b1,2'd2,5'd0,FBCr1_cache_data_sync[47:24],8'd0,FBCr1_cache_data_sync[23:0]};
assign cache_fifo_din[3] = cfg_QPD_enable_i ?  {quad_cache_data_sync[63:0]}                                 : {1'b1,2'd3,5'd0,FBCr2_cache_data_sync[47:24],8'd0,FBCr2_cache_data_sync[23:0]};

assign cache_fifo_wr[0]  = cache_write_en;
assign cache_fifo_wr[1]  = cache_write_en;
assign cache_fifo_wr[2]  = cache_write_en;
assign cache_fifo_wr[3]  = cache_write_en;

always @(posedge clk_i) begin
    if(real_scan_flag_i)
        real_scan_flag_latch <= #TCQ 'd1;
    else if(~pmt_scan_en_d)
        real_scan_flag_latch <= #TCQ 'd0;
end

wire cache_fifo_ready ;
assign cache_fifo_ready = cache_fifo_empty=='d0;

always @(posedge clk_i) begin
    if(real_scan_flag_latch)begin
        if(cache_fifo_ready && (~rd_en))
            rd_en <= #TCQ 'd1;
        else if(cache_fifo_almost_empty && rd_en)
            rd_en <= #TCQ 'd0;
    end
    else begin
        rd_en <= #TCQ 'd0;
    end
end

always @(posedge clk_i) rd_en_d <= #TCQ rd_en;
always @(posedge clk_i) fbc_cache_vld <= #TCQ rd_en_d;
always @(posedge clk_i) fbc_cache_data <= #TCQ { 
                                                 cache_fifo_dout[3],
                                                 cache_fifo_dout[2],
                                                 cache_fifo_dout[1],
                                                 cache_fifo_dout[0]
                                                };

assign fbc_scan_en_o    = pmt_scan_en_d && real_scan_flag_latch;
assign fbc_cache_vld_o  = fbc_cache_vld;
assign fbc_cache_data_o = fbc_cache_data;

always @(posedge clk_i) begin
    if(~fbc_vout_empty_i && ~(aurora_fbc_almost_full_1_i && aurora_fbc_almost_full_2_i && aurora_fbc_almost_full_3_i))
        fbc_vout_rd_seq <= #TCQ 'd1;
    else 
        fbc_vout_rd_seq <= #TCQ 'd0;
end

assign fbc_vout_rd_seq_o        = fbc_vout_rd_seq;
assign aurora_fbc_vout_vld_o    = fbc_vout_rd_vld_i;
assign aurora_fbc_vout_data_o   = fbc_vout_rd_data_i;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
