`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/12/09
// Design Name: PCG
// Module Name: encode_align_unit
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


module encode_align_unit #(
    parameter                           TCQ             = 0.1   ,
    parameter                           ENCODE_WIDTH    = 32    
)(
    // clk & rst
    input                               clk_i               ,
    input                               rst_i               ,

    input                               encode_sim_en_i     ,
    input       [ENCODE_WIDTH-1:0]      encode_sim_i        ,
    input                               precise_encode_en_i ,
    input       [ENCODE_WIDTH-1:0]      precise_encode_i    ,

    input                               scan_en_i           ,
    input                               align_rst_i         ,
    input       [32-1:0]                align_set_i         ,
    output                              encode_en_o         ,
    output      [ENCODE_WIDTH-1:0]      encode_o            
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg     [ENCODE_WIDTH-1:0]  precise_encode              = 'd0;

reg                         scan_en_d                   = 'd0;
reg                         scan_align                  = 'd0;
reg     [14-1:0]            align_set_abs               = 'd0;
reg                         align_wait                  = 'd0;
reg     [14-1:0]            wait_cnt                    = 'd0;
reg                         align_wr_en                 = 'd0;
reg                         align_full_d                = 'd0;
reg                         align_rd_en                 = 'd0;
reg                         align_valid                 = 'd0;


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire    [ENCODE_WIDTH-1:0]  align_dout          ;
wire                        align_full          ;
wire                        align_empty         ;
wire    [14-1:0]            align_data_count    ;
wire                        align_sbiterr       ;
wire                        align_dbiterr       ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
encode_align_fifo encode_align_fifo_inst (
    .clk                ( clk_i                     ),  // input wire clk
    .rst                ( rst_i || align_rst_i      ),  // input wire srst
    .din                ( precise_encode            ),  // input wire [ENCODE_WIDTH-1 : 0] din
    .wr_en              ( align_wr_en               ),  // input wire wr_en
    .rd_en              ( align_rd_en               ),  // input wire rd_en
    .dout               ( align_dout                ),  // output wire [ENCODE_WIDTH-1 : 0] dout
    .full               ( align_full                ),  // output wire full
    .empty              ( align_empty               ),  // output wire empty
    .data_count         ( align_data_count          ),  // output wire [13 : 0] data_count
    .sbiterr            ( align_sbiterr             ),  // output wire sbiterr
    .dbiterr            ( align_dbiterr             )   // output wire dbiterr
);

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) begin
    precise_encode <= #TCQ encode_sim_en_i ? encode_sim_i : precise_encode_i;
end

always @(posedge clk_i) begin
    align_full_d <= #TCQ align_full;
end

always @(posedge clk_i) begin
    if(rst_i || align_rst_i)
        align_wait <= #TCQ 'd1;
    else if((~align_full) && align_full_d)
        align_wait <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(align_set_i[31])
        align_set_abs <= #TCQ ~align_set_i[31:0] + 1;
end

always @(posedge clk_i) begin
    if(align_wait)begin
        scan_align  <= #TCQ 'd0;
        wait_cnt    <= #TCQ 'd0;
    end
    else begin
        if(align_set_i[31])begin
            scan_align  <= #TCQ scan_en_i;
        end
        else begin
            if(scan_en_i)begin
                if(wait_cnt == align_set_i[14-1:0])begin
                    scan_align  <= #TCQ 'd1;
                    wait_cnt    <= #TCQ wait_cnt;
                end
                else begin
                    scan_align  <= #TCQ 'd0;
                    wait_cnt    <= #TCQ wait_cnt + 1;
                end
            end
            else begin
                scan_align  <= #TCQ 'd0;
                wait_cnt    <= #TCQ 'd0;
            end
        end
    end
end

always @(posedge clk_i) begin
    if(align_wait)
        align_wr_en <= #TCQ 'd0;
    else if(align_set_i[31])
        align_wr_en <= #TCQ (precise_encode_en_i || encode_sim_en_i) && (~align_full);
    else 
        align_wr_en <= #TCQ (precise_encode_en_i || encode_sim_en_i) && (~align_full) && scan_align;
end

always @(posedge clk_i) begin
    if(align_wait)
        align_rd_en <= #TCQ 'd0;
    else if(align_set_i[31])begin
        if(align_data_count >= align_set_abs)
            align_rd_en <= #TCQ align_wr_en;
    end
    else begin
        align_rd_en <= #TCQ ~align_empty;
    end
end

always @(posedge clk_i) begin
    align_valid <= #TCQ align_rd_en && scan_align;
end

assign encode_en_o = align_valid;
assign encode_o    = align_dout;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




endmodule
