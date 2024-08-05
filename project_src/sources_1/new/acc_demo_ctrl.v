`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2024/03/14
// Design Name: pcg
// Module Name: acc_demo_ctrl
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

module acc_demo_ctrl #(
    parameter                       TCQ         = 0.1 

)(
    // clk & rst
    input                           clk_i                       ,
    input                           rst_i                       ,
    
    input                           acc_demo_mode_i             ,
    input                           acc_demo_wren_i             ,
    input       [16-1:0]            acc_demo_addr_i             ,
    input       [32-1:0]            acc_demo_Wencode_i          ,
    input       [32-1:0]            acc_demo_Xencode_i          ,
    input       [16-1:0]            acc_demo_particle_cnt_i     ,

    input                           pmt_scan_en_i               ,
    input                           main_scan_start_i           ,
    input                           real_precise_encode_en_i    ,
    input       [18-1:0]            real_precise_Wencode_i      ,
    input       [18-1:0]            real_precise_Xencode_i      ,

    output                          acc_demo_flag_o             ,

    output      [32-1:0]            acc_demo_skip_cnt_o         ,
    output      [32-1:0]            acc_demo_addr_latch_o       ,
    input                           skip_fifo_rd_i              ,
    output                          skip_fifo_ready_o           ,
    output      [64-1:0]            skip_fifo_data_o            
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                     align_rst                   = 'd1;
reg                     align_wr_en                 = 'd0;
reg     [18-1:0]        align_wr_wencode            = 'd0;
reg                     align_rd_en                 = 'd0;
reg                     align_valid                 = 'd0;

reg                                 real_scan_flag_latch        = 'd0;
reg                                 acc_demo_start_d            = 'd0;
reg     [16-1:0]                    particle_num                = 'd0;
reg     [18-1:0]                    acc_demo_start_Wencode      = 'd0;
reg     [18-1:0]                    acc_demo_end_Wencode        = 'd0;

reg     [18-1:0]                    acc_demo_start_Xencode      = 'd0;
reg     [18-1:0]                    acc_demo_end_Xencode        = 'd0;
reg                                 acc_demo_Wencode_over       = 'd0;
reg                                 acc_demo_Wencode_below      = 'd0;
reg                                 acc_demo_Wencode_over_d     = 'd0;
reg                                 acc_demo_Wencode_below_d    = 'd0;

reg                                 acc_demo_Wencode_flag       = 'd0;
reg                                 acc_demo_Xencode_flag       = 'd0;
// reg                                 acc_demo_flag               = 'd0;

reg                                 acc_demo_flag_d             = 'd0;
reg     [16-1:0]                    encode_mem_raddr            = 'd0;
reg                                 encode_mem_skip             = 'd0;
reg                                 acc_demo_Xencode_skip       = 'd0;
reg                                 acc_demo_Xencode_skip_d     = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                precise_encode_en           ;
wire    [18-1:0]                    precise_encode_w            ;
wire    [18-1:0]                    precise_encode_x            ;

wire    [18-1:0]                    align_dout                  ;
wire                                align_full                  ;
wire                                align_empty                 ;
wire    [12-1:0]                    align_data_count            ;

wire                                acc_demo_start              ;
wire    [64-1:0]                    encode_mem_dout             ;

wire    [14-1:0]                    acc_demo_mem_Wencode_extend ;
wire    [18-1:0]                    acc_demo_mem_Wencode        ;
wire    [14-1:0]                    acc_demo_mem_Xencode_extend ;
wire    [18-1:0]                    acc_demo_mem_Xencode        ;

wire                                acc_demo_flag               ;
wire                                encode_mem_ren              ;
// wire                                lose_encode_skip            ;

wire                                acc_demo_Xencode_skip_pose  ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
acc_demo_encode_mem acc_demo_encode_mem_inst (
    .clka                   ( clk_i                                     ),  // input wire clka
    .wea                    ( acc_demo_wren_i                           ),  // input wire [0 : 0] wea
    .addra                  ( acc_demo_addr_i                           ),  // input wire [11 : 0] addra
    .dina                   ( {acc_demo_Wencode_i,acc_demo_Xencode_i}   ),  // input wire [63 : 0] dina
    .clkb                   ( clk_i                                     ),  // input wire clkb
    .addrb                  ( encode_mem_raddr                          ),  // input wire [11 : 0] addrb
    .doutb                  ( encode_mem_dout                           )   // output wire [63 : 0] doutb
);

encode_x_align_fifo encode_x_align_fifo_inst (
  .clk                      ( clk_i                                     ),  // input wire clk
  .srst                     ( align_rst                                 ),  // input wire srst
  .din                      ( align_wr_wencode                          ),  // input wire [18 : 0] din
  .wr_en                    ( align_wr_en                               ),  // input wire wr_en
  .rd_en                    ( align_rd_en                               ),  // input wire rd_en
  .dout                     ( align_dout                                ),  // output wire [18 : 0] dout
  .full                     ( align_full                                ),  // output wire full
  .empty                    ( align_empty                               ),  // output wire empty
  .data_count               ( align_data_count                          )   // output wire [11 : 0] data_count
);

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// Xencode align 30us
always @(posedge clk_i) begin
    if(rst_i)
        align_rst <= #TCQ 'd1;
    else if(real_precise_encode_en_i)
        align_rst <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(align_rst)
        align_wr_en <= #TCQ 'd0;
    else 
        align_wr_en <= #TCQ real_precise_encode_en_i && (~align_full);
end

always @(posedge clk_i) begin
    align_wr_wencode    <= #TCQ real_precise_Xencode_i;
end

always @(posedge clk_i) begin
    if(align_data_count >= 'd2998) // 30us
        align_rd_en <= #TCQ align_wr_en;
    else 
        align_rd_en <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    align_valid <= #TCQ align_rd_en;
end

assign precise_encode_en = align_valid;
assign precise_encode_w  = real_precise_Wencode_i;
assign precise_encode_x  = align_dout;


always @(posedge clk_i) begin
    if(main_scan_start_i)
        real_scan_flag_latch <= #TCQ 'd1;
    else if(~pmt_scan_en_i)
        real_scan_flag_latch <= #TCQ 'd0;
end

assign acc_demo_start = real_scan_flag_latch && pmt_scan_en_i && acc_demo_mode_i;
always @(posedge clk_i) begin
    acc_demo_start_d <= #TCQ acc_demo_start;
end

always @(posedge clk_i) begin
    if(~acc_demo_start_d && acc_demo_start)
        particle_num <= #TCQ acc_demo_particle_cnt_i[16-1:0];
end

assign acc_demo_mem_Wencode_extend  = encode_mem_dout[50 +: 14];
assign acc_demo_mem_Wencode         = encode_mem_dout[32 +: 18];
assign acc_demo_mem_Xencode_extend  = encode_mem_dout[18 +: 14];
assign acc_demo_mem_Xencode         = encode_mem_dout[0 +: 18];

// `ifdef SIMULATE
// always @(posedge clk_i) begin
//     acc_demo_start_Wencode <= #TCQ acc_demo_mem_Wencode;
//     if((acc_demo_mem_Wencode + acc_demo_mem_Wencode_extend) > 'd511)
//         acc_demo_end_Wencode <= #TCQ acc_demo_mem_Wencode + acc_demo_mem_Wencode_extend - 'd511;
//     else 
//         acc_demo_end_Wencode <= #TCQ acc_demo_mem_Wencode + acc_demo_mem_Wencode_extend;
// end
// `else
always @(posedge clk_i) begin
    acc_demo_start_Wencode <= #TCQ acc_demo_mem_Wencode;
    if((acc_demo_mem_Wencode + acc_demo_mem_Wencode_extend) > 'h3ffff)
        acc_demo_end_Wencode <= #TCQ acc_demo_mem_Wencode + acc_demo_mem_Wencode_extend - 'h3ffff;
    else 
        acc_demo_end_Wencode <= #TCQ acc_demo_mem_Wencode + acc_demo_mem_Wencode_extend;
end
// `endif //SIMULATE

always @(posedge clk_i) begin
    acc_demo_start_Xencode  <= #TCQ acc_demo_mem_Xencode;
    acc_demo_end_Xencode    <= #TCQ acc_demo_mem_Xencode + acc_demo_mem_Xencode_extend;
end

always @(posedge clk_i) begin
    if(~acc_demo_start)
        acc_demo_Xencode_flag <= #TCQ 'd0;
    else 
        acc_demo_Xencode_flag <= #TCQ (precise_encode_x < acc_demo_end_Xencode) && (precise_encode_x >= acc_demo_start_Xencode);
end

always @(posedge clk_i) acc_demo_Wencode_over    <= #TCQ precise_encode_w >= acc_demo_start_Wencode;
always @(posedge clk_i) acc_demo_Wencode_below   <= #TCQ precise_encode_w < acc_demo_end_Wencode;
always @(posedge clk_i) acc_demo_Wencode_over_d  <= #TCQ acc_demo_Wencode_over;
always @(posedge clk_i) acc_demo_Wencode_below_d <= #TCQ acc_demo_Wencode_below;

always @(posedge clk_i) begin
    if(~acc_demo_start)
        acc_demo_Wencode_flag <= #TCQ 'd0;
    else if(acc_demo_mode_i)begin
        if(~acc_demo_Wencode_over_d && acc_demo_Wencode_over && acc_demo_Xencode_flag && (~acc_demo_Wencode_flag))
            acc_demo_Wencode_flag <= #TCQ 'd1;
        else if(((acc_demo_Wencode_below_d && (~acc_demo_Wencode_below)) || (~acc_demo_Xencode_flag)) && acc_demo_Wencode_flag)
            acc_demo_Wencode_flag <= #TCQ 'd0;
    end
    else begin
        acc_demo_Wencode_flag <= #TCQ 'd0;
    end
end

// always @(posedge clk_i) begin
//     if(acc_demo_mode_i)
//         acc_demo_flag <= #TCQ acc_demo_Wencode_flag;
//     else 
//         acc_demo_flag <= #TCQ 'd0;
// end
assign acc_demo_flag = acc_demo_Wencode_flag;
always @(posedge clk_i) acc_demo_flag_d <= #TCQ acc_demo_flag;
assign encode_mem_ren = (acc_demo_flag_d && (~acc_demo_flag)) || (encode_mem_skip && acc_demo_start);

reg encode_mem_ren_d0 = 'd0;
reg encode_mem_ren_d1 = 'd0;
reg encode_mem_ren_d2 = 'd0;
reg encode_mem_ren_d3 = 'd0;
reg encode_mem_ren_d4 = 'd0;
always @(posedge clk_i) begin
    encode_mem_ren_d0 <= #TCQ encode_mem_ren || (~acc_demo_start_d && acc_demo_start);  // 开始时等效读取第一个encode
    encode_mem_ren_d1 <= #TCQ encode_mem_ren_d0;
    encode_mem_ren_d2 <= #TCQ encode_mem_ren_d1;
    encode_mem_ren_d3 <= #TCQ encode_mem_ren_d2;
    encode_mem_ren_d4 <= #TCQ encode_mem_ren_d3;
end

always @(posedge clk_i) acc_demo_Xencode_skip   <= #TCQ precise_encode_x >= acc_demo_end_Xencode;
always @(posedge clk_i) acc_demo_Xencode_skip_d <= #TCQ acc_demo_Xencode_skip;
assign acc_demo_Xencode_skip_pose = ~acc_demo_Xencode_skip_d && acc_demo_Xencode_skip;

reg mem_skip_class = 'd0;
always @(posedge clk_i) begin
    if(encode_mem_ren_d3 && (precise_encode_x >= acc_demo_end_Xencode) && (encode_mem_raddr < particle_num))begin
        encode_mem_skip <= #TCQ 'd1;
        mem_skip_class  <= #TCQ 'd1;
    end
    else if(acc_demo_Xencode_skip_pose && (~acc_demo_Wencode_flag) && (encode_mem_raddr < particle_num))begin
        encode_mem_skip <= #TCQ 'd1;
        mem_skip_class  <= #TCQ 'd0;
    end
    else 
        encode_mem_skip <= #TCQ 'd0;
end
// reg encode_mem_skip_d = 'd0;
// always @(posedge clk_i ) begin
//     encode_mem_skip_d <= #TCQ encode_mem_skip;
// end
// assign lose_encode_skip = ~encode_mem_skip_d && encode_mem_skip;

always @(posedge clk_i) begin
    if(~acc_demo_start)
        encode_mem_raddr <= #TCQ 'd0;
    else if(encode_mem_ren)begin
        if(encode_mem_raddr == particle_num)
            encode_mem_raddr <= #TCQ encode_mem_raddr;
        else 
            encode_mem_raddr <= #TCQ encode_mem_raddr + 1;
    end
end

assign acc_demo_flag_o = acc_demo_flag;

// check register
reg [32-1:0] acc_demo_addr_latch = 'd0;
always @(posedge clk_i) begin
    if(acc_demo_start_d && (~acc_demo_start))begin
        acc_demo_addr_latch[31:16] <= #TCQ particle_num[15:0];
        acc_demo_addr_latch[15:0]  <= #TCQ encode_mem_raddr[15:0];
    end
end

assign acc_demo_addr_latch_o = acc_demo_addr_latch;

reg [32-1:0] acc_demo_skip_cnt = 'd0;
always @(posedge clk_i) begin
    if((~acc_demo_start_d) && acc_demo_start)
        acc_demo_skip_cnt <= #TCQ 'd0;
    else if(encode_mem_skip)
        acc_demo_skip_cnt <= #TCQ acc_demo_skip_cnt + 1;
end


wire            skip_fifo_rst ;
wire            skip_fifo_full ;
wire            skip_fifo_empty;
wire            skip_fifo_wr_en;
wire [64-1:0]   skip_fifo_wr_data ;

assign skip_fifo_rst     = (~acc_demo_start_d) && acc_demo_start;
assign skip_fifo_wr_en   = encode_mem_skip && acc_demo_start;
assign skip_fifo_wr_data = { 3'd0,encode_mem_skip
                            ,3'd0,mem_skip_class
                            ,encode_mem_raddr[16-1:0]
                            ,2'd0,precise_encode_x[18-1:0]
                            ,2'd0,precise_encode_w[18-1:0]};

xpm_sync_fifo #(
    .ECC_MODE                   ( "no_ecc"                      ),
    .FIFO_MEMORY_TYPE           ( "distributed"                 ), // "auto" "block" "distributed"
    .READ_MODE                  ( "std"                         ), // "std" "fwft"
    .FIFO_WRITE_DEPTH           ( 64                            ),
    .WRITE_DATA_WIDTH           ( 64                            ),
    .READ_DATA_WIDTH            ( 64                            ),
    .USE_ADV_FEATURES           ( "1808"                        )
)u_xpm_sync_fifo (
    .wr_clk_i                   ( clk_i                         ),
    .rst_i                      ( rst_i || skip_fifo_rst        ), // synchronous to wr_clk
    .wr_en_i                    ( skip_fifo_wr_en               ),
    .wr_data_i                  ( skip_fifo_wr_data             ),
    .fifo_full_o                ( skip_fifo_full                ),

    .rd_en_i                    ( skip_fifo_rd_i                ),
    .fifo_rd_data_o             ( skip_fifo_data_o              ),
    .fifo_empty_o               ( skip_fifo_empty               )
);

assign skip_fifo_ready_o   = ~skip_fifo_empty;
assign acc_demo_skip_cnt_o = acc_demo_skip_cnt;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
