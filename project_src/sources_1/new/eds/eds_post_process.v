`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2024/8/20
// Design Name: PCG
// Module Name: eds_cross_ctrl
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


module eds_post_process #(
    parameter                       TCQ               = 0.1 
)(
    // clk & rst 
    input                           clk_i                   ,
    input                           rst_i                   ,

    input                           eds_clk_i               ,
    input                           eds_frame_en_i          ,
    input                           eds_sensor_data_en_i    ,
    input   [128-1:0]               eds_sensor_data_i       ,

    output                          eds_post_vld_o          ,
    output  [64-1:0]                eds_post_data_o         ,
    output  [32-1:0]                eds_error_cnt_o         ,
    output                          eds_error_vld_o         ,  // negedge = last
    output  [16-1:0]                eds_error_data_o        
);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                                 eds_diag_vld            = 'd0;
reg         [16-1:0]                eds_diag_data           = 'd0;
reg                                 eds_diag_vld_d          = 'd0;
reg         [16-1:0]                eds_diag_data_d         = 'd0;
reg         [11-1:0]                eds_diag_addr           = 'd0;

reg         [11-1:0]                eds_error_mem_addr      = 'd0;

reg                                 eds_diag_ready          = 'd0;
reg                                 eds_diag_flag           = 'd0;
reg signed  [13-1:0]                eds_data_diff           = 'd0;
reg         [12-1:0]                eds_diff_abs_max        = 'd0;
reg         [12-1:0]                eds_diff_abs_max_d      = 'd0;
reg         [12-1:0]                eds_data_diff_abs_d     = 'd0;
reg                                 eds_abs_diff_vld        = 'd0;
reg         [11-1:0]                eds_diag_addr_d         = 'd0;
reg         [11-1:0]                eds_diff_max_addr       = 'd0;
reg                                 eds_error_rd_flag       = 'd0;
reg                                 eds_error_rd_flag_d     = 'd0;
reg                                 eds_error_mem_vld       = 'd0;

reg         [32-1:0]                eds_error_cnt           = 'd0;
reg                                 eds_frame_en_d          = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                eds_post_valid              ;
wire        [64-1:0]                eds_post_dout               ;
wire                                eds_post_full               ;
wire                                eds_post_empty              ;
wire                                eds_post_wr_rst_busy        ;
wire                                eds_post_rd_rst_busy        ;

wire        [16-1:0]                eds_error_mem_data          ;

wire                                eds_diag_full               ;
wire                                eds_diag_rd_vld             ;
wire        [16-1:0]                eds_diag_rd_data            ;
wire                                eds_diag_empty              ;
wire                                eds_diag_almost_empty       ;

wire signed [13-1:0]                eds_abs_diff                ;
wire                                eds_diag_first_flag         ;
wire        [12-1:0]                eds_data_diff_abs           ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

eds_post_fifo eds_post_fifo_inst (
    .rst                            ( rst_i                         ),  // input wire rst
    .wr_clk                         ( eds_clk_i                     ),  // input wire wr_clk
    .rd_clk                         ( clk_i                         ),  // input wire rd_clk
    .din                            ( eds_sensor_data_i             ),  // input wire [127 : 0] din
    .wr_en                          ( eds_sensor_data_en_i          ),  // input wire wr_en
    .rd_en                          ( ~eds_post_empty               ),  // input wire rd_en
    .dout                           ( eds_post_dout                 ),  // output wire [63 : 0] dout
    .full                           ( eds_post_full                 ),  // output wire full
    .empty                          ( eds_post_empty                ),  // output wire empty
    .valid                          ( eds_post_valid                ),  // output wire valid
    .wr_rst_busy                    ( eds_post_wr_rst_busy          ),  // output wire wr_rst_busy
    .rd_rst_busy                    ( eds_post_rd_rst_busy          )   // output wire rd_rst_busy
);


xpm_sync_fifo #(
    .ECC_MODE                       ( "no_ecc"                      ),
    .FIFO_MEMORY_TYPE               ( "block"                       ), // "auto" "block" "distributed"
    .READ_MODE                      ( "std"                         ),
    .FIFO_WRITE_DEPTH               ( 512                           ),
    .WRITE_DATA_WIDTH               ( 64                            ),
    .READ_DATA_WIDTH                ( 16                            ),
    .USE_ADV_FEATURES               ( "1808"                        )
)eds_diag_fifo_inst (
    .wr_clk_i                       ( clk_i                         ),
    .rst_i                          ( rst_i                         ), // synchronous to wr_clk
    .wr_en_i                        ( eds_post_valid                ),
    .wr_data_i                      ( eds_post_dout                 ),
    .fifo_full_o                    ( eds_diag_full                 ),

    .rd_en_i                        ( ~eds_diag_empty               ),
    .fifo_rd_vld_o                  ( eds_diag_rd_vld               ),
    .fifo_rd_data_o                 ( eds_diag_rd_data              ),
    .fifo_empty_o                   ( eds_diag_empty                ),
    .fifo_almost_empty_o            ( eds_diag_almost_empty         )
);


eds_error_mem eds_error_mem_inst (
    .clka                           ( clk_i                         ),  // input wire clka
    .wea                            ( eds_diag_vld && (~eds_error_rd_flag) ),  // input wire [0 : 0] wea
    .addra                          ( eds_diag_addr                 ),  // input wire [10 : 0] addra
    .dina                           ( eds_diag_data                 ),  // input wire [15 : 0] dina
    .clkb                           ( clk_i                         ),  // input wire clkb
    .addrb                          ( eds_error_mem_addr            ),  // input wire [10 : 0] addrb
    .doutb                          ( eds_error_mem_data            )   // output wire [15 : 0] doutb
);
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) begin
    eds_diag_vld    <= #TCQ eds_diag_rd_vld;
    eds_diag_data   <= #TCQ eds_diag_rd_data;
    eds_diag_vld_d  <= #TCQ eds_diag_vld;
    eds_diag_data_d <= #TCQ eds_diag_data;
end

assign eds_diag_first_flag = eds_diag_rd_vld && (eds_diag_rd_data[15:12]=='hF);

always @(posedge clk_i) begin
    if(eds_diag_first_flag)
        eds_diag_addr <= #TCQ 'd0;
    else if(eds_diag_vld)
        eds_diag_addr <= #TCQ eds_diag_addr + 1;
end

always @(posedge clk_i) begin
    if((~eds_frame_en_i) && eds_error_rd_flag)
        eds_diag_ready <= #TCQ 'd0;
    else if(eds_diag_first_flag)
        eds_diag_ready <= #TCQ 'd1;
end

always @(posedge clk_i) begin
    if(~eds_diag_ready)
        eds_diag_flag <= #TCQ 'd0;
    else if(eds_diag_first_flag)
        eds_diag_flag <= #TCQ 'd1;
end

always @(posedge clk_i) begin
    if(~eds_diag_flag)begin
        eds_data_diff <= #TCQ 'd0;
    end
    else if(eds_diag_vld)begin
        if(eds_diag_data[15:12] == 'hF)begin
            eds_data_diff <= #TCQ 'd0;
        end
        else begin
            eds_data_diff <= #TCQ eds_diag_data[11:0]  - eds_diag_data_d[11:0];
        end
    end
end

assign eds_data_diff_abs = eds_data_diff[12] ? (~eds_data_diff + 1) : eds_data_diff[11:0];
assign eds_abs_diff      = eds_data_diff_abs - eds_diff_abs_max;

always @(posedge clk_i) begin
    eds_abs_diff_vld <= #TCQ eds_diag_vld_d;
    eds_diag_addr_d  <= #TCQ eds_diag_addr;
end

always @(posedge clk_i) begin
    eds_data_diff_abs_d <= #TCQ eds_data_diff_abs;
end
always @(posedge clk_i) begin
    if(eds_diag_first_flag)
        eds_diff_abs_max <= #TCQ 'd0;
    else if(eds_diag_vld_d)
        eds_diff_abs_max <= #TCQ eds_abs_diff[12] ? eds_diff_abs_max : eds_data_diff_abs;
end

always @(posedge clk_i) begin
    if(eds_diag_vld_d && (~eds_abs_diff[12]))
        eds_diff_max_addr <= #TCQ eds_diag_addr_d;
end

always @(posedge clk_i) begin
    if(&eds_error_mem_addr)
        eds_error_rd_flag <= #TCQ 'd0;
    else if(eds_diag_flag && eds_diag_first_flag)begin
        if((eds_diff_max_addr < 'd100) || (eds_diff_max_addr > 'd1950))
            eds_error_rd_flag <= #TCQ 'd1;
    end
end

always @(posedge clk_i) begin
    if(~eds_error_rd_flag)
        eds_error_mem_addr <= #TCQ 'd0;
    else 
        eds_error_mem_addr <= #TCQ eds_error_mem_addr + 1;
end

always @(posedge clk_i) begin
    eds_error_rd_flag_d <= #TCQ eds_error_rd_flag;
    eds_error_mem_vld   <= #TCQ eds_error_rd_flag_d;
end

assign eds_post_vld_o    = eds_post_valid;
assign eds_post_data_o   = eds_post_dout ;
assign eds_error_vld_o   = eds_error_mem_vld;
assign eds_error_data_o  = eds_error_mem_data;

always @(posedge clk_i) begin
    eds_frame_en_d <= #TCQ eds_frame_en_i;
end
always @(posedge clk_i) begin
    if(~eds_frame_en_d && eds_frame_en_i)
        eds_error_cnt <= #TCQ 'd0;
    else if(~eds_error_mem_vld && eds_error_rd_flag_d)
        eds_error_cnt <= #TCQ eds_error_cnt + 1;
end

assign eds_error_cnt_o = eds_error_cnt;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

endmodule
