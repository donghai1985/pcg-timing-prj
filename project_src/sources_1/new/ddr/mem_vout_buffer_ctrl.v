`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/06/25
// Design Name: 
// Module Name: mem_vout_buffer_ctrl
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


module mem_vout_buffer_ctrl #(
    parameter                               TCQ               = 0.1 ,  
    parameter                               ADDR_WIDTH        = 30  ,
    parameter                               DATA_WIDTH        = 32  ,
    parameter                               MEM_DATA_BITS     = 256 ,
    parameter                               BURST_LEN         = 128
)(
    // clk & rst 
    input                                   ddr_clk_i               ,
    input                                   ddr_rst_i               ,

    input                                   laser_start_i           ,  // scan start
    output                                  fbc_start_o             ,  // fbc start
    input       [18-1:0]                    wr_burst_line_i         ,
    output      [18-1:0]                    rd_burst_line_o         ,
    output                                  ddr_fifo_empty_o        ,
    input                                   ddr_fifo_rd_en_i        ,
    output                                  ddr_fifo_rd_vld_o       ,
    output      [DATA_WIDTH-1:0]            ddr_fifo_rd_data_o      ,

    output                                  rd_ddr_req_o            ,  
    output      [ 8-1:0]                    rd_ddr_len_o            ,
    output      [ADDR_WIDTH-1:0]            rd_ddr_addr_o           ,
    input                                   rd_ddr_data_valid_i     ,
    input       [MEM_DATA_BITS - 1:0]       rd_ddr_data_i           ,
    input                                   rd_ddr_finish_i          
    
);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam                      BURST_IDLE              = 3'd0;
localparam                      BURST_FRAME_WAIT        = 3'd5;
localparam                      BURST_FRAME_START       = 3'd1;
localparam                      BURSTING                = 3'd2;
localparam                      BURST_END               = 3'd3;
localparam                      BURST_FRAME_END         = 3'd4;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg     [ 3-1:0]                burst_state             = BURST_IDLE;
reg     [ 3-1:0]                burst_state_next        = BURST_IDLE;

// reg                             mem_virtual_empty       = 'd1;
reg                             laser_start_d0          = 'd0;
reg                             laser_start_d1          = 'd0;
reg                             laser_start_d2          = 'd0;
reg                             fbc_start               = 'd0;
reg                             fbc_start_d             = 'd0;
reg                             pre_laser_done          = 'd0;
reg     [18-1:0]                wr_burst_line_fix       = 'd0;
reg     [18-1:0]                rd_burst_line           = 'd0;
reg                             fbc_start_temp          = 'd0;
reg     [25-1:0]                fbc_start_wait          = 'd0;

reg                             rd_ddr_req              = 'd0;  
reg     [ 8-1:0]                rd_ddr_len              = 'd0;  
reg     [ADDR_WIDTH-1:0]        rd_ddr_addr             = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                            ddr_fifo_full       ;
wire                            ddr_fifo_prog_full  ;
wire                            mem_virtual_empty   ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
xpm_sync_fifo #(
    .ECC_MODE                   ( "no_ecc"                      ),
    .FIFO_MEMORY_TYPE           ( "block"                       ),
    .READ_MODE                  ( "std"                         ),
    .FIFO_WRITE_DEPTH           ( 512                           ),
    .PROG_FULL_THRESH           ( 256                           ),
    .WRITE_DATA_WIDTH           ( MEM_DATA_BITS                 ),
    .READ_DATA_WIDTH            ( DATA_WIDTH                    ),
    .USE_ADV_FEATURES           ( "1C06"                        )
)mem_vout_buffer_fifo_inst (
    .wr_clk_i                   ( ddr_clk_i                     ),
    .rst_i                      ( ddr_rst_i                     ), // synchronous to wr_clk
    .wr_en_i                    ( rd_ddr_data_valid_i           ),
    .wr_data_i                  ( rd_ddr_data_i                 ),
    .fifo_full_o                ( ddr_fifo_full                 ),
    .fifo_prog_full_o           ( ddr_fifo_prog_full            ),

    .rd_en_i                    ( ddr_fifo_rd_en_i              ),
    .fifo_rd_vld_o              ( ddr_fifo_rd_vld_o             ),
    .fifo_rd_data_o             ( ddr_fifo_rd_data_o            ),
    .fifo_empty_o               ( ddr_fifo_empty_o              )
);

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge ddr_clk_i) begin
    laser_start_d0 <= #TCQ laser_start_i;
    laser_start_d1 <= #TCQ laser_start_d0;
end

always @(posedge ddr_clk_i) begin
    if((~laser_start_d0 && laser_start_d1) && (~mem_virtual_empty))  // scan 结束时检测DDR内是否有FBC数据
        fbc_start <= #TCQ 'd1;
    else if(fbc_start && mem_virtual_empty)  // fbc清空结束
        fbc_start <= #TCQ 'd0;
end

always @(posedge ddr_clk_i) begin
    fbc_start_d <= #TCQ fbc_start;
end

assign frame_start =  fbc_start && ~fbc_start_d;  // posedge, fsm statr
assign frame_end   = ~fbc_start &&  fbc_start_d;  // negedge, fsm end

// always @(posedge ddr_clk_i) begin
//     if(ddr_rst_i)
//         mem_virtual_empty <= #TCQ 'd1;
//     else if(mem_virtual_empty && wr_burst_line_i != rd_burst_line)
//         mem_virtual_empty <= #TCQ 'd0; 
//     else if(~mem_virtual_empty && (wr_burst_line_i==(rd_burst_line+1'd1)) && rd_ddr_finish_i)
//         mem_virtual_empty <= #TCQ 'd1; 
// end
always @(posedge ddr_clk_i) begin
    if(wr_burst_line_i == 'd0)
        wr_burst_line_fix <= #TCQ 'd1;
    else 
        wr_burst_line_fix <= #TCQ wr_burst_line_i;
end

assign mem_virtual_empty = (wr_burst_line_fix <= rd_burst_line);

always@(posedge ddr_clk_i)begin
    if(ddr_rst_i)
        burst_state <= #TCQ BURST_IDLE;
    else
        burst_state <= #TCQ burst_state_next;
end

always@(*)begin
    burst_state_next = burst_state;
    case(burst_state)
        BURST_IDLE:
            if(frame_start)  // fifo reset finish
                burst_state_next = BURST_FRAME_WAIT;
        BURST_FRAME_WAIT:
            if(fbc_start_wait[24])
                burst_state_next = BURST_FRAME_START;
        BURST_FRAME_START:
            if(~ddr_fifo_prog_full)
                burst_state_next = BURSTING;
        BURSTING:   // 完成一次突发读操作
            if(rd_ddr_finish_i)
                burst_state_next = BURST_END;
        BURST_END:
            if(pre_laser_done)
                burst_state_next = BURST_FRAME_END;
            else if((~ddr_fifo_prog_full) && (~mem_virtual_empty)) // 判断fifo空间
                burst_state_next = BURSTING;
        BURST_FRAME_END:
            if(ddr_fifo_empty_o)
                burst_state_next = BURST_IDLE;
        default:
            burst_state_next = BURST_IDLE;
    endcase
end

always@(posedge ddr_clk_i)begin
    rd_ddr_addr <= #TCQ {3'd0,rd_burst_line[17:0],10'd0};  // 通过burst line控制突发首地址
end

always @(posedge ddr_clk_i)begin
    if(burst_state == BURST_IDLE)begin
        rd_burst_line <= #TCQ 'd0;
    end
    else if(burst_state_next==BURST_END && burst_state==BURSTING)begin
        rd_burst_line <= #TCQ rd_burst_line + 1;
    end
end

always @(posedge ddr_clk_i) begin
    if(frame_end)
        pre_laser_done <= #TCQ 'd1;
    else if(burst_state == BURST_FRAME_END)
        pre_laser_done <= #TCQ 'd0;
end

always@(posedge ddr_clk_i)begin
    if(burst_state_next == BURSTING && burst_state != BURSTING)begin
        rd_ddr_len <= #TCQ BURST_LEN;
    end
end

always@(posedge ddr_clk_i)begin
    if(burst_state_next == BURSTING && burst_state != BURSTING)
        rd_ddr_req <= #TCQ 1'b1;
    else if(rd_ddr_finish_i || rd_ddr_data_valid_i || burst_state == BURST_IDLE)
        rd_ddr_req <= #TCQ 1'b0;
end

always @(posedge ddr_clk_i) begin
    if(burst_state==BURST_FRAME_WAIT)
        fbc_start_wait <= #TCQ fbc_start_wait + 1;
    else 
        fbc_start_wait <= #TCQ 'd0;
end

always @(posedge ddr_clk_i) begin
    if(burst_state_next == BURST_FRAME_START)
        fbc_start_temp <= #TCQ 'd1;
    else if((burst_state == BURST_FRAME_END) && (ddr_fifo_empty_o))
        fbc_start_temp <= #TCQ 'd0;
end

assign rd_burst_line_o          = rd_burst_line;
assign rd_ddr_req_o             = rd_ddr_req  ;
assign rd_ddr_len_o             = rd_ddr_len  ;
assign rd_ddr_addr_o            = rd_ddr_addr ;
assign fbc_start_o              = fbc_start_temp ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
