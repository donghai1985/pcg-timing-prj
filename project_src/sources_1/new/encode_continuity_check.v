`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2024/7/2
// Design Name: PCG
// Module Name: encode_continuity_check
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


module encode_continuity_check #(
    parameter                   TCQ             = 0.1   
)(
    // clk & rst
    input                       clk_i                       ,
    input                       rst_i                       ,

    input                       eds_scan_en_i               ,
    input                       encode_check_clean_i        ,
    input                       src_encode_en_i             ,
    input       [18-1:0]        src_encode_w_i              ,
    input                       w_data_error_i              ,
    input                       w_data_warn_i               ,

    output                      w_encode_err_lock_o         ,
    output                      w_encode_warn_lock_o        ,
    output      [18-1:0]        w_encode_continuity_max_o   ,
    output      [18-1:0]        w_encode_continuity_cnt_o   

);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                             w_encode_err_lock       = 'd0;
reg                             w_encode_warn_lock      = 'd0;

reg     [18-1:0]                w_encode_d0             = 'd0;
reg     [18-1:0]                w_encode_d1             = 'd0;

reg                             first_delta_en          = 'd0;
reg                             second_delta_en         = 'd0;
reg                             src_encode_en_d0        = 'd0;
reg                             src_encode_en_d1        = 'd0;
reg                             src_encode_en_d2        = 'd0;

reg     [18-1:0]                w_encode_delta_abs      = 'd0;
reg     [18-1:0]                w_encode_continuity_max = 'd0;
reg     [18-1:0]                w_encode_continuity_cnt = 'd0;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>





//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) begin
    if(encode_check_clean_i)
        w_encode_err_lock   <= #TCQ 'd0;
    else if(src_encode_en_i && (~w_data_error_i))
        w_encode_err_lock   <= #TCQ 'd1;
end

always @(posedge clk_i) begin
    if(encode_check_clean_i)
        w_encode_warn_lock  <= #TCQ 'd0;
    else if(src_encode_en_i && (~w_data_warn_i))
        w_encode_warn_lock  <= #TCQ 'd1;
end

always @(posedge clk_i) begin
    if(src_encode_en_i)begin
        w_encode_d0 <= #TCQ src_encode_w_i;
        w_encode_d1 <= #TCQ w_encode_d0;
    end
end

always @(posedge clk_i) begin
    if(~first_delta_en)
        w_encode_delta_abs <= #TCQ 'd0;
    else if(src_encode_en_d0)begin
        if((w_encode_d0 >= w_encode_d1))
            w_encode_delta_abs <= #TCQ w_encode_d0 - w_encode_d1;
        else
            w_encode_delta_abs <= #TCQ w_encode_d0 - w_encode_d1 + 18'h3ffff;
    end
end

always @(posedge clk_i) begin
    src_encode_en_d0 <= #TCQ src_encode_en_i;
    src_encode_en_d1 <= #TCQ src_encode_en_d0;
end

always @(posedge clk_i) begin
    if(encode_check_clean_i || (~second_delta_en))
        first_delta_en <= #TCQ 'd0;
    else if(src_encode_en_d0)
        first_delta_en <= #TCQ 'd1;
end

always @(posedge clk_i) begin
    if(encode_check_clean_i || (~eds_scan_en_i))
        second_delta_en <= #TCQ 'd0;
    else if(src_encode_en_d0)
        second_delta_en <= #TCQ 'd1;
end

always @(posedge clk_i) begin
    if(encode_check_clean_i)
        w_encode_continuity_max  <= #TCQ 'd0;
    else if(eds_scan_en_i && src_encode_en_d0 && first_delta_en)begin
        if(w_encode_continuity_max < w_encode_delta_abs)
            w_encode_continuity_max <= #TCQ w_encode_delta_abs;
    end
end

always @(posedge clk_i) begin
    if(encode_check_clean_i)
        w_encode_continuity_cnt  <= #TCQ 'd0;
    else if(eds_scan_en_i && src_encode_en_d0 && first_delta_en)begin
        if(w_encode_delta_abs > 'd100)
            w_encode_continuity_cnt <= #TCQ w_encode_continuity_cnt + 1;
    end
end



assign w_encode_err_lock_o       = w_encode_err_lock ; 
assign w_encode_warn_lock_o      = w_encode_warn_lock;
assign w_encode_continuity_max_o = w_encode_continuity_max;
assign w_encode_continuity_cnt_o = w_encode_continuity_cnt;


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




endmodule
