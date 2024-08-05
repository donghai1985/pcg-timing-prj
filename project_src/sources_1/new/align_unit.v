`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2024/04/12
// Design Name: PCG
// Module Name: align_unit
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


module align_unit #(
    parameter                           TCQ             = 0.1   ,
    parameter                           ALIGN_WIDTH     = 32    
)(
    // clk & rst
    input                               clk_i               ,
    input                               rst_i               ,

    input                               data_sim_en_i       ,
    input       [ALIGN_WIDTH-1:0]       data_sim_i          ,
    input                               data_en_i           ,
    input       [ALIGN_WIDTH-1:0]       data_i              ,

    input                               align_start_en_i    ,
    input                               align_rst_i         ,
    input       [32-1:0]                align_set_i         ,
    output                              align_data_en_o     ,
    output      [ALIGN_WIDTH-1:0]       align_data_o        
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg     [ALIGN_WIDTH-1:0]   align_wr_data                    = 'd0;

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
wire    [ALIGN_WIDTH-1:0]   align_dout          ;
wire                        align_full          ;
wire                        align_empty         ;
wire    [14-1:0]            align_data_count    ;
wire                        align_sbiterr       ;
wire                        align_dbiterr       ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
xpm_sync_fifo #(
    .ECC_MODE                   ( "no_ecc"                      ),
    .FIFO_MEMORY_TYPE           ( "block"                       ), // "auto" "block" "distributed"
    .READ_MODE                  ( "std"                         ),
    .FIFO_WRITE_DEPTH           ( 16384                         ),
    .WRITE_DATA_WIDTH           ( ALIGN_WIDTH                   ),
    .READ_DATA_WIDTH            ( ALIGN_WIDTH                   ),
    .USE_ADV_FEATURES           ( "0400"                        )
)align_sync_fifo_inst (
    .wr_clk_i                   ( clk_i                         ),
    .rst_i                      ( rst_i || align_rst_i          ), // synchronous to wr_clk
    .wr_en_i                    ( align_wr_en                   ),
    .wr_data_i                  ( align_wr_data                 ),
    .fifo_full_o                ( align_full                    ),

    .rd_en_i                    ( align_rd_en                   ),
    .fifo_rd_data_o             ( align_dout                    ),
    .fifo_empty_o               ( align_empty                   ),
    .rd_data_count_o            ( align_data_count              )
);
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) begin
    align_wr_data <= #TCQ data_sim_en_i ? data_sim_i : data_i;
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
            scan_align  <= #TCQ align_start_en_i;
        end
        else begin
            if(align_start_en_i)begin
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
        align_wr_en <= #TCQ (data_en_i || data_sim_en_i) && (~align_full);
    else 
        align_wr_en <= #TCQ (data_en_i || data_sim_en_i) && (~align_full) && scan_align;
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

assign align_data_en_o = align_valid;
assign align_data_o    = align_dout;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




endmodule
