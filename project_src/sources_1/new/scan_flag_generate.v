`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2024/1/10
// Design Name: PCG
// Module Name: scan_cmd_ctrl
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


module scan_flag_generate #(
    parameter                               TCQ         = 0.1   
)(
    // clk & rst
    input   wire                            clk_i                       ,
    input   wire                            rst_i                       ,
    
    input   wire    [3-1:0]                 pmt_start_en_i              ,
    input   wire    [3-1:0]                 pmt_end_en_i                ,
    output  wire    [3-1:0]                 pmt_scan_en_o               ,

    input   wire                            fbc_up_start_i              ,
    input   wire    [3-1:0]                 fbc_up_end_i                ,
    output  wire    [3-1:0]                 fbc_up_en_o                 
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
genvar i;


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg     [3-1:0]         pmt_start_en_d0     = 'd0;
reg     [3-1:0]         pmt_start_en_d1     = 'd0;
reg     [3-1:0]         pmt_end_en_d0       = 'd0;
reg     [3-1:0]         pmt_end_en_d1       = 'd0;
reg     [3-1:0]         pmt_scan_en         = 'd0;

reg     [3-1:0]         fbc_up_en           = 'd0;
reg     [3-1:0]         main_scan_latch     = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire    [3-1:0]         pmt_start_en_pose   ;
wire    [3-1:0]         pmt_end_en_pose     ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) pmt_start_en_d0 <= #TCQ pmt_start_en_i;
always @(posedge clk_i) pmt_start_en_d1 <= #TCQ pmt_start_en_d0;

always @(posedge clk_i) pmt_end_en_d0 <= #TCQ pmt_end_en_i;
always @(posedge clk_i) pmt_end_en_d1 <= #TCQ pmt_end_en_d0;

generate
    for(i=0;i<3;i=i+1)begin
        assign pmt_start_en_pose[i] = ~pmt_start_en_d1[i] && pmt_start_en_d0[i];
        assign pmt_end_en_pose[i] = ~pmt_end_en_d1[i] && pmt_end_en_d0[i];

        always @(posedge clk_i) begin
            if(pmt_start_en_pose[i])
                pmt_scan_en[i] <= #TCQ 'd1;
            else if(pmt_end_en_pose[i])
                pmt_scan_en[i] <= #TCQ 'd0;
        end
    end
endgenerate

assign pmt_scan_en_o = pmt_scan_en;

always @(posedge clk_i) begin
    if(|pmt_start_en_pose)
        main_scan_latch <= #TCQ pmt_start_en_i;
end

generate
    for(i=0;i<3;i=i+1)begin: FBC_CHANNEL
        always @(posedge clk_i) begin
            if(fbc_up_start_i)
                fbc_up_en[i] <= #TCQ main_scan_latch[i];
            else if(fbc_up_end_i[i])
                fbc_up_en[i] <= #TCQ 'd0;
        end
    end
endgenerate

assign fbc_up_en_o = fbc_up_en;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
