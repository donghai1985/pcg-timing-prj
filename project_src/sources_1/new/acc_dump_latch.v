`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2024/08/13
// Design Name: pcg
// Module Name: acc_dump_latch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
//
//
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module acc_dump_latch #(
    parameter                       TCQ         = 0.1 

)(
    // clk & rst
    input                           clk_i                       ,
    input                           rst_i                       ,

    input                           pmt_scan_en_i               ,
    input                           acc_flag_i                  ,
    input   [64-1:0]                pmt_precise_encode_i        ,

    output  [32-1:0]                acc_trigger_num_o           ,
    output                          acc_trigger_latch_en_o      ,
    output  [64*4-1:0]              acc_trigger_latch_o         
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                                 acc_flag_d              = 'd0;
reg                                 acc_trigger_latch_en    = 'd0;

reg         [32-1:0]                acc_trigger_num         = 'd0;
reg                                 pmt_scan_en_d           = 'd0;
reg         [32-1:0]                acc_trigger_time        = 'd0;
reg         [32-1:0]                acc_trigger_time_latch  = 'd0;
reg         [64-1:0]                acc_encode_start_latch  = 'd0;
reg         [64-1:0]                acc_encode_end_latch    = 'd0;
reg         [32-1:0]                acc_trigger_index       = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                acc_flag_pose               ;
wire                                acc_flag_nege               ;
wire        [64*4-1:0]              acc_trigger_latch_temp      ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) acc_flag_d <= #TCQ acc_flag_i;
assign acc_flag_pose = (~acc_flag_d) && acc_flag_i;
assign acc_flag_nege = acc_flag_d && (~acc_flag_i);

always @(posedge clk_i) begin
    if(acc_flag_i)
        acc_trigger_time <= #TCQ acc_trigger_time + 1;
    else
        acc_trigger_time <= #TCQ 'd0;
end


always @(posedge clk_i) begin
    if(acc_flag_pose)
        acc_encode_start_latch <= #TCQ pmt_precise_encode_i;
end

always @(posedge clk_i) begin
    if(acc_flag_nege)
        acc_trigger_time_latch <= #TCQ acc_trigger_time;
end

always @(posedge clk_i) begin
    if(acc_flag_nege)
        acc_encode_end_latch <= #TCQ pmt_precise_encode_i;
end

always @(posedge clk_i) begin
    if(pmt_scan_en_i)begin
        if(acc_flag_pose)
            acc_trigger_index <= #TCQ acc_trigger_index + 1;
    end
    else 
        acc_trigger_index <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    acc_trigger_latch_en <= #TCQ acc_flag_nege && pmt_scan_en_i;
end
assign acc_trigger_latch_en_o  = acc_trigger_latch_en;

assign acc_trigger_latch_temp     = {
                                     acc_trigger_index[32-1:0]
                                    ,acc_encode_start_latch[64-1:0]
                                    ,acc_trigger_time_latch[32-1:0]
                                    ,acc_encode_end_latch[64-1:0]
                                    ,64'd0
                                    };
// 适配 readback 模块内的 xpm fifo 256bit -> 64bit 小端输出方式，高8字节在高位读写
assign acc_trigger_latch_o     = {
                                     acc_trigger_latch_temp[64*1-1:0]
                                    ,acc_trigger_latch_temp[64*2-1:64*1]
                                    ,acc_trigger_latch_temp[64*3-1:64*2]
                                    ,acc_trigger_latch_temp[64*4-1:64*3]
                                    };

always @(posedge clk_i) begin
    pmt_scan_en_d <= #TCQ pmt_scan_en_i;
end
always @(posedge clk_i) begin
    if(~pmt_scan_en_i && pmt_scan_en_d)
        acc_trigger_num <= #TCQ acc_trigger_index;
end
assign acc_trigger_num_o = acc_trigger_num;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
