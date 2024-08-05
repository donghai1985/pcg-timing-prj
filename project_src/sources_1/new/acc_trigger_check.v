`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2024/6/6
// Design Name: PCG
// Module Name: acc_trigger_check
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


module acc_trigger_check #(
    parameter                       TCQ               = 0.1 
)(
    // clk & rst 
    input                           clk_i                   ,
    input                           rst_i                   ,

    input                           laser_start_i           ,
    input                           aom_ctrl_flag_i         ,
    input   [18-1:0]                encode_w_i              ,
    input   [18-1:0]                encode_x_i              ,

    output                          trig_fifo_ready_o       ,
    input                           trig_fifo_rd_i          ,
    output  [64-1:0]                trig_fifo_data_o        ,
    output  [32-1:0]                acc_trigger_num_o       
);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                                 laser_start_d           = 'd0;
reg                                 aom_ctrl_flag_d         = 'd0;
reg         [32-1:0]                acc_trigger_num         = 'd0;


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                trig_fifo_rst               ;
wire                                trig_fifo_full              ;
wire                                trig_fifo_empty             ;
wire                                trig_fifo_wr_en             ;
wire        [38-1:0]                trig_fifo_wr_data           ;
wire        [38-1:0]                trig_fifo_rd_data           ;


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
xpm_sync_fifo #(
    .ECC_MODE                   ( "no_ecc"                      ),
    .FIFO_MEMORY_TYPE           ( "block"                       ), // "auto" "block" "distributed"
    .READ_MODE                  ( "std"                         ), // "std" "fwft"
    .FIFO_WRITE_DEPTH           ( 4096                          ),
    .WRITE_DATA_WIDTH           ( 64                            ),
    .READ_DATA_WIDTH            ( 64                            ),
    .USE_ADV_FEATURES           ( "1808"                        )
)acc_encode_log_inst (
    .wr_clk_i                   ( clk_i                         ),
    .rst_i                      ( rst_i                         ), // synchronous to wr_clk
    .wr_en_i                    ( trig_fifo_wr_en               ),
    .wr_data_i                  ( trig_fifo_wr_data             ),
    .fifo_full_o                ( trig_fifo_full                ),

    .rd_en_i                    ( trig_fifo_rd_i                ),
    .fifo_rd_data_o             ( trig_fifo_rd_data             ),
    .fifo_empty_o               ( trig_fifo_empty               )
);

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) begin
    laser_start_d   <= #TCQ laser_start_i;
    aom_ctrl_flag_d <= #TCQ aom_ctrl_flag_i;
end

assign aom_ctrl_pose = (~aom_ctrl_flag_d) && aom_ctrl_flag_i;

always @(posedge clk_i) begin
    if(~laser_start_d && laser_start_i)
        acc_trigger_num <= #TCQ 'd0;
    else if(aom_ctrl_pose)
        acc_trigger_num <= #TCQ acc_trigger_num + 1;
end



assign trig_fifo_rst     = ~laser_start_d && laser_start_i;
assign trig_fifo_wr_en   = aom_ctrl_pose && laser_start_d;
assign trig_fifo_wr_data = { encode_w_i[18-1:0],
                             encode_x_i[18-1:0]};
                             
assign trig_fifo_ready_o = ~trig_fifo_empty;
assign trig_fifo_data_o  = { 12'd0,
                             12'd0,
                             2'd0,trig_fifo_rd_data[35:18],
                             2'd0,trig_fifo_rd_data[17:0]};
assign acc_trigger_num_o = acc_trigger_num;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
