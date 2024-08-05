//~ `New testbench
`timescale  1ns / 1ps

module tb_FBC_cache;

// FBC_cache Parameters
parameter PERIOD = 10 ;
parameter TCQ  = 0.1;

// FBC_cache Inputs
reg   clk_i                                = 0 ;
reg   rst_i                                = 0 ;
reg   FBCi_cache_vld_i                     = 0 ;
reg   [48-1:0]  FBCi_cache_data_i          = 0 ;
reg   FBCr1_cache_vld_i                    = 0 ;
reg   [48-1:0]  FBCr1_cache_data_i         = 0 ;
reg   FBCr2_cache_vld_i                    = 0 ;
reg   [48-1:0]  FBCr2_cache_data_i         = 0 ;
reg   [32-1:0]  encode_w_i                 = 'h1000 ;
reg   [32-1:0]  encode_x_i                 = 'h123 ;
reg   real_scan_flag_i                     = 0 ;
reg   pmt_scan_en_i                        = 0 ;
reg   [3-1:0]  fbc_up_en_i                 = 0 ;
reg   fbc_vout_empty_i                     = 0 ;
reg   fbc_vout_rd_vld_i                    = 0 ;
reg   [64-1:0]  fbc_vout_rd_data_i         = 0 ;
reg   aurora_fbc_almost_full_1_i           = 0 ;
reg   aurora_fbc_almost_full_2_i           = 0 ;
reg   aurora_fbc_almost_full_3_i           = 0 ;

// FBC_cache Outputs
wire  fbc_scan_en_o                        ;
wire  fbc_cache_vld_o                      ;
wire  [256-1:0]  fbc_cache_data_o          ;
wire  fbc_vout_rd_seq_o                    ;
wire  aurora_fbc_vout_vld_o                ;
wire  [64-1:0]  aurora_fbc_vout_data_o     ;


initial
begin
    forever #(PERIOD/2)  clk_i=~clk_i;
end

initial
begin
    rst_i  =  1;
    #(PERIOD*2);
    rst_i  =  0;
end

FBC_cache #(
    .TCQ ( TCQ ))
 u_FBC_cache (
    .clk_i                       ( clk_i                                 ),
    .rst_i                       ( rst_i                                 ),
    .FBCi_cache_vld_i            ( FBCi_cache_vld_i                      ),
    .FBCi_cache_data_i           ( FBCi_cache_data_i           [48-1:0]  ),
    .FBCr1_cache_vld_i           ( FBCr1_cache_vld_i                     ),
    .FBCr1_cache_data_i          ( FBCr1_cache_data_i          [48-1:0]  ),
    .FBCr2_cache_vld_i           ( FBCr2_cache_vld_i                     ),
    .FBCr2_cache_data_i          ( FBCr2_cache_data_i          [48-1:0]  ),
    .encode_w_i                  ( encode_w_i                  [32-1:0]  ),
    .encode_x_i                  ( encode_x_i                  [32-1:0]  ),
    .real_scan_flag_i            ( real_scan_flag_i                      ),
    .pmt_scan_en_i               ( pmt_scan_en_i                         ),
    .fbc_up_en_i                 ( fbc_up_en_i                 [3-1:0]   ),
    .fbc_vout_empty_i            ( fbc_vout_empty_i                      ),
    .fbc_vout_rd_vld_i           ( fbc_vout_rd_vld_i                     ),
    .fbc_vout_rd_data_i          ( fbc_vout_rd_data_i          [64-1:0]  ),
    .aurora_fbc_almost_full_1_i  ( aurora_fbc_almost_full_1_i            ),
    .aurora_fbc_almost_full_2_i  ( aurora_fbc_almost_full_2_i            ),
    .aurora_fbc_almost_full_3_i  ( aurora_fbc_almost_full_3_i            ),

    .fbc_scan_en_o               ( fbc_scan_en_o                         ),
    .fbc_cache_vld_o             ( fbc_cache_vld_o                       ),
    .fbc_cache_data_o            ( fbc_cache_data_o            [256-1:0] ),
    .fbc_vout_rd_seq_o           ( fbc_vout_rd_seq_o                     ),
    .aurora_fbc_vout_vld_o       ( aurora_fbc_vout_vld_o                 ),
    .aurora_fbc_vout_data_o      ( aurora_fbc_vout_data_o      [64-1:0]  )
);


always @(posedge clk_i) begin
    if(FBCi_cache_vld_i)
        FBCi_cache_data_i <= #TCQ FBCi_cache_data_i + 1;
end

always @(posedge clk_i) begin
    if(FBCr1_cache_vld_i)
        FBCr1_cache_data_i <= #TCQ FBCr1_cache_data_i + 1;
end

always @(posedge clk_i) begin
    if(FBCr2_cache_vld_i)
        FBCr2_cache_data_i <= #TCQ FBCr2_cache_data_i + 1;
end

reg start_flag = 0;
reg [10-1:0] FBCi_cache_cnt = 'd0;
always @(posedge clk_i) begin
    if(start_flag)
        FBCi_cache_cnt <= #TCQ FBCi_cache_cnt + 1;
end

always @(posedge clk_i) begin
    FBCi_cache_vld_i    <= #TCQ FBCi_cache_cnt == 'd10;
    FBCr1_cache_vld_i   <= #TCQ FBCi_cache_cnt == 'd20;
    FBCr2_cache_vld_i   <= #TCQ FBCi_cache_cnt == 'd30;
end

initial
begin
    #100;
    real_scan_flag_i = 1;
    #100;
    pmt_scan_en_i = 1;
    start_flag = 1;
    $finish;
end

endmodule