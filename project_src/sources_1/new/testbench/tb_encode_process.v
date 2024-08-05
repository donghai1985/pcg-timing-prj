//~ `New testbench
`timescale  1ns / 1ps

module tb_encode_process;

// encode_process Parameters
parameter PERIOD      = 10 ;
parameter TCQ         = 0.1;
parameter ENCODE_WID  = 32 ;

// encode_process Inputs
reg   clk_i                                = 0 ;
reg   rst_i                                = 0 ;
reg   encode_update_i                      = 0 ;
// reg   [ENCODE_WID-1:0]  encode_w_i         = 255344 ;
reg   [ENCODE_WID-1:0]  encode_w_i         = 261754 ;
// reg   [ENCODE_WID-1:0]  encode_w_i         = 255342 ;
reg   [ENCODE_WID-1:0]  encode_x_i         = 100 ;
reg                     encode_update_i_125    = 0;
reg   [ENCODE_WID-1:0]  encode_w_i_125         = 0;
reg   [ENCODE_WID-1:0]  encode_x_i_125         = 0;
reg encode_update_d0 ;
reg encode_update_d1 ;

reg   [ENCODE_WID-1:0]  FIRST_DELTA_WENCODE = 956 ;
reg   [ENCODE_WID-1:0]  FIRST_DELTA_XENCODE = 500   ;

// encode_process Output
wire  wafer_zero_flag_o                    ;
wire  precise_encode_en_o                  ;
wire  [ENCODE_WID-1:0]  precise_encode_w_o ;
wire  [ENCODE_WID-1:0]  precise_encode_x_o ;
wire  [ENCODE_WID-1:0]  encode_x_temp;

wire  pmt_encode_en_o                      ;
wire  [32-1:0]  pmt_encode_w_o             ;
wire  [32-1:0]  pmt_encode_x_o             ;
wire  eds_encode_en_o                      ;
wire  [32-1:0]  eds_encode_w_o             ;
wire  [32-1:0]  eds_encode_x_o             ;

wire                real_precise_encode_en          ;
wire    [31:0]      real_precise_encode_w           ;
wire    [31:0]      real_precise_encode_x           ;

reg pmt_scan_en = 'd0;
reg eds_scan_en = 'd0;
reg pmt_start_test_en = 'd0;

reg                pmt_encode_align_rst         = 'd0;
reg    [32-1:0]    pmt_encode_align_set         = 'd6250;
reg                eds_encode_align_rst         = 'd0;
reg    [32-1:0]    eds_encode_align_set         = 'd6250;

reg     [32-1:0]    pmt_precise_encode_x_offset = 'd0;
reg                 pmt_precise_encode_en_temp  = 'd0;
reg     [32-1:0]    pmt_precise_encode_w_temp   = 'd0;
reg     [32-1:0]    pmt_precise_encode_x_temp   = 'd0;

wire                precise_encode_en               ;
wire    [31:0]      precise_encode_w                ;
wire    [31:0]      precise_encode_x                ;

wire                pmt_precise_encode_en           ;
wire    [31:0]      pmt_precise_encode_w            ;
wire    [31:0]      pmt_precise_encode_x            ;
wire                eds_precise_encode_en           ;
wire    [31:0]      eds_precise_encode_w            ;
wire    [31:0]      eds_precise_encode_x            ;
//TX Interface
wire    [63:0]          tx_tdata                ; 
wire                    tx_tvalid               ;
wire    [7:0]           tx_tkeep                ;  
wire                    tx_tlast                ;
wire                    tx_tready               ;

wire    [32-1:0]        eds_pack_cnt            ;
wire    [32-1:0]        encode_pack_cnt         ;

reg pmt_start_en_d = 'd0;
reg pmt_end_en_d0 = 'd0;
 reg real_scan_en = 'd0;


 wire                    encode_tx_en            ;
 wire    [64-1:0]        encode_tx_data          ;
 wire                    encode_tx_full          ;
 wire                    encode_tx_empty         ;
 wire                    encode_tx_almost_empty  ;
 wire                    encode_tx_almost_full   ;
 wire    [11-1:0]        encode_tx_count         ;
 wire                    encode_tx_wr_rst_busy   ;
 wire                    encode_tx_rd_rst_busy   ;
 wire                    clear_encode_buffer ;
 wire                    encode_fifo_rst     ;

 
reg user_clk = 0;
initial
begin
    forever #(PERIOD/2)  clk_i=~clk_i;
end

initial
begin
    forever #(3.2)  user_clk=~user_clk;
end

initial
begin
    rst_i  =  1;
    #(PERIOD*2);
    rst_i  =  0;
end

encode_process_v2 #(
    .TCQ                    ( TCQ                   ),
    .FIRST_DELTA_WENCODE    ( 0                     ),
    .FIRST_DELTA_XENCODE    ( 0                     ),
    .EXTEND_WIDTH           ( 24                    ),
    .UNIT_INTER             ( 6250                  ),
    .DELTA_UPDATE_DOT       ( 2                     ),
    .DELTA_UPDATE_GAP       ( 2                     ),
    .ENCODE_MASK_WID        ( 18                    ),
    .ENCODE_WID             ( 32                    ))
 u_encode_process (
    .clk_i                   ( clk_i                                ),
    .rst_i                   ( rst_i                                ),
    .encode_update_i         ( encode_update_i                      ),
    .encode_w_i              ( encode_w_i          [ENCODE_WID-1:0] ),
    .encode_x_i              ( encode_x_i          [ENCODE_WID-1:0] ),

    .precise_encode_en_o     ( precise_encode_en ),
    .precise_encode_w_o      ( precise_encode_w  ),
    .precise_encode_x_o      ( precise_encode_x  )
);

encode_process #(
    .FIRST_DELTA_WENCODE        ( 0                                 ),  // 初始 W Encode 增量，用于 first Encode 前插值
    .FIRST_DELTA_XENCODE        ( 0                                 ),  // 初始 X Encode 增量，用于 first Encode 前插值
    .EXTEND_WIDTH               ( 24                                ),  // 定点位宽
    .UNIT_INTER                 ( 6250                              ),  // 插值数，= 100M / 16k 
    .DELTA_UPDATE_DOT           ( 2                                 ),  // 插值点倍率
    .DELTA_UPDATE_GAP           ( 2                                 ),  // 插值点倍率, precise_encode_en freq = 16k * UNIT_INTER / DELTA_UPDATE_GAP * DELTA_UPDATE_DOT
    .ENCODE_MASK_WID            ( 18                                ),  // W Encode 有效位宽，W Encode 零点规定为有效位宽最大值
    .ENCODE_WID                 ( 32                                )   // Encode 位宽
)pmt_real_encode_process_inst(
    // clk & rst
    .clk_i                      ( clk_i                             ),
    .rst_i                      ( rst_i                             ),
    
    .x_zero_flag_i              ( x_zero_flag                       ),
    .encode_update_i            ( encode_update_i                   ),
    .encode_w_i                 ( encode_w_i                        ),  // W 无符号数
    .encode_x_i                 ( encode_x_i                        ),  // X 有符号数

    .precise_encode_en_o        ( real_precise_encode_en            ),
    .precise_encode_w_o         ( real_precise_encode_w             ),
    .precise_encode_x_o         ( real_precise_encode_x             )
);



reg [16-1:0] count_num = 'd6253;


reg [16-1:0] count = 'd0;
always @(posedge clk_i) begin
    if(count == count_num)
        count <= 'd0;
    else 
        count <= count + 1; 
end

// always @(posedge clk_i) begin
//     if(count == 'd6253)
//         count_num <= 'd6247;
//     else if(count == 'd6247)
//         count_num <= 'd6253; 
// end

reg add_flag = 'd1;
reg delta_wencode_flag = 'd0;
reg [1-1:0] delta_wencode_flag_cnt = 'd0;
reg [1-1:0] delta_wencode_flag_cnt2 = 'd0;
always @(posedge clk_i) begin
    if(count == count_num)begin
        if(~delta_wencode_flag)begin
            delta_wencode_flag_cnt  <= delta_wencode_flag_cnt + 1;
            if(&delta_wencode_flag_cnt)
                delta_wencode_flag  <= ~delta_wencode_flag;
        end
        else begin
            delta_wencode_flag_cnt2  <= delta_wencode_flag_cnt2 + 1;
            if(delta_wencode_flag_cnt2)
                delta_wencode_flag  <= ~delta_wencode_flag;
        end
    end
end

always @(posedge clk_i) begin
    if(count == count_num)begin
        FIRST_DELTA_WENCODE <= delta_wencode_flag ? (delta_wencode_flag_cnt2[0] ? FIRST_DELTA_WENCODE + 2 : FIRST_DELTA_WENCODE - 2): FIRST_DELTA_WENCODE + 0 ;
    end
end

always @(posedge clk_i) begin
    if(count == count_num)begin
        FIRST_DELTA_XENCODE <= delta_wencode_flag ? (delta_wencode_flag_cnt2[0] ? FIRST_DELTA_XENCODE + 2 : FIRST_DELTA_XENCODE - 2): FIRST_DELTA_XENCODE + 0 ;
    end
end

wire [ENCODE_WID-1:0] w_encode_sum = encode_w_i + FIRST_DELTA_WENCODE;

always @(posedge clk_i) begin
    if(count == count_num)begin
        encode_update_i <= 'd1;
        encode_w_i      <= (w_encode_sum > 18'h3ffff) ? {{(ENCODE_WID-18){1'b0}},w_encode_sum[18-1:0]} + 1 : w_encode_sum;
        encode_x_i      <= add_flag ? encode_x_i + FIRST_DELTA_XENCODE : encode_x_i - FIRST_DELTA_XENCODE;
    end
    else begin
        encode_update_i <= 'd0;
    end
end


// always @(posedge clk_125) begin
//     encode_update_d0 <= encode_update_i;
//     encode_update_d1 <= encode_update_d0;
//     encode_w_i_125 <= encode_w_i;
//     encode_x_i_125 <= encode_x_i;
// end

// initial
// begin

//     $finish;
// end

endmodule