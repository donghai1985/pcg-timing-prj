`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/7/06
// Design Name: PCG
// Module Name: pmt_master_sel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pmt_master_sel #(
    parameter                               TCQ         = 0.1   
)(
    // clk & rst
    input    wire                           clk_i                       ,
    input    wire                           rst_i                       ,
    input    wire   [32-1:0]                master_wr_data_i            ,
    input    wire                           master_wr_vld_i             ,
    input    wire   [ 4-1:0]                pmt_master_cmd_parser_i     ,

    output   wire   [32-1:0]                pmt_master_wr_data_o        ,
    output   wire   [ 2-1:0]                pmt_master_wr_vld_o         
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam                                  UNIT_MS                     = 'd100000;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                                         pmt_master_cmd_parser_d0    = 'd0;
reg                                         pmt_master_cmd_parser_d1    = 'd0;
reg                                         pmt_master_wr_state         = 'd0;
reg     [32-1:0]                            pmt_master_wr_data          = 'd0; 
reg     [1:0]                               pmt_master_wr_vld           = 'd0;
reg                                         master_wr_vld_delay_fir     = 'd0;
reg     [16-1:0]                            timeout_cnt                 = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire    [32-1:0]                            master_wr_data_delay    ;
wire                                        master_wr_vld_delay     ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg_delay #(
    .DATA_WIDTH             ( 33                                            ),
    .DELAY_NUM              ( 2                                             )
)reg_delay_inst(    
    .clk_i                  ( clk_i                                         ),
    .src_data_i             ( {master_wr_vld_i,master_wr_data_i}            ),
    .delay_data_o           ( {master_wr_vld_delay,master_wr_data_delay}    )
);


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) begin
    if(pmt_master_wr_state)begin
        if(timeout_cnt[15])
            timeout_cnt <= #TCQ timeout_cnt;
        else 
            timeout_cnt <= #TCQ timeout_cnt + 1;
    end
    else 
        timeout_cnt <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    pmt_master_cmd_parser_d0 <= #TCQ |pmt_master_cmd_parser_i;
    pmt_master_cmd_parser_d1 <= #TCQ pmt_master_cmd_parser_d0;
end

assign master_wr_en     = master_wr_vld_i && ~pmt_master_cmd_parser_d1 && (|master_wr_data_i[11:8]);

always @(posedge clk_i) begin
    if(rst_i || timeout_cnt[15])
        pmt_master_wr_state <= #TCQ 'd0;
    else if(master_wr_en)
        pmt_master_wr_state <= #TCQ 'd1;
    else if(~pmt_master_cmd_parser_d0 && pmt_master_cmd_parser_d1)
        pmt_master_wr_state <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(pmt_master_wr_state)begin
        pmt_master_wr_data <= #TCQ master_wr_data_delay;     
        pmt_master_wr_vld  <= #TCQ {master_wr_vld_delay,master_wr_vld_delay_fir}  ;
    end
    else begin
        pmt_master_wr_vld  <= 'd0;
    end
end

always @(posedge clk_i) begin
    if(pmt_master_wr_state && master_wr_vld_delay)
        master_wr_vld_delay_fir <= #TCQ 'd0;
    else if(~pmt_master_wr_state)
        master_wr_vld_delay_fir <= #TCQ 'd1;
end

assign pmt_master_wr_data_o = pmt_master_wr_data;
assign pmt_master_wr_vld_o  = pmt_master_wr_vld;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
