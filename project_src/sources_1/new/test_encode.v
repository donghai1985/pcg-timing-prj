`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: test_encode
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


module test_encode #(
    parameter               TCQ = 0.1 

)(
    // clk & rst
    input                           clk_i                   ,
    input                           rst_i                   ,
    
    input                           pmt_encode_en_i        ,
    input           [32-1:0]        pmt_encode_x_i         ,
    input           [32-1:0]        pmt_encode_w_i         ,
    
    input                           acs_encode_en_i         ,
    input           [32-1:0]        acs_encode_x_i          ,
    input           [32-1:0]        acs_encode_w_i          ,

    input                           pmt_scan_en_i           ,
    input                           test_encode_rst_i       ,
    input           [32-1:0]        pmt_w_encode_thr_i      ,
    input   signed  [32-1:0]        acs_w_encode_thr_i      ,

    output          [32-1:0]        pmt_encode_w_diff_max_o 
//     input                           pmt_encode_rd_en_i      ,
//     output          [32-1:0]        pmt_x_encode_o          ,
//     output          [32-1:0]        pmt_w_encode_o          ,
//     output          [2-1:0]         pmt_fifo_state_o        ,

//     input                           acs_encode_rd_en_i      ,
//     output          [32-1:0]        acs_x_encode_o          ,
//     output          [32-1:0]        acs_w_encode_o          ,
//     output          [2-1:0]         acs_fifo_state_o        
);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                     pmt_encode_en_d0            = 'd0;
reg                     pmt_encode_en_d1            = 'd0;
reg         [32-1:0]    pmt_encode_w_d              = 'd0;
reg         [32-1:0]    pmt_encode_w_diff           = 'd0;
reg         [32-1:0]    pmt_encode_w_diff_max       = 'd0;
reg                     pmt_scan_en_d               = 'd0;
reg                     pmt_scan_en_pose            = 'd0;
reg                     pmt_encode_err              = 'd0;
reg                     pmt_fifo_wr_en              = 'd0;
reg         [8-1:0]     pmt_encode_err_cnt          = 'd0;


reg                     acs_encode_en_d0            = 'd0;
reg                     acs_encode_en_d1            = 'd0;
reg         [32-1:0]    acs_encode_w_d              = 'd0;
reg signed  [32-1:0]    acs_encode_w_diff           = 'd0;
reg signed  [32-1:0]    acs_encode_w_diff_d         = 'd0;
reg signed  [32-1:0]    acs_encode_speed_diff       = 'd0;
reg                     acs_encode_err              = 'd0;
reg                     acs_fifo_wr_en              = 'd0;
reg         [8-1:0]     acs_encode_err_cnt          = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

wire    [64-1:0]    pmt_fifo_dout ;
wire                pmt_fifo_full  ;
wire                pmt_fifo_empty ;
wire    [64-1:0]    acs_fifo_dout ;
wire                acs_fifo_full  ;
wire                acs_fifo_empty ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

// test_encode_fifo pmt_encode_fifo_inst (
//     .clk              ( clk_i                               ),  // input wire clk
//     .srst             ( rst_i || test_encode_rst_i          ),  // input wire srst
//     .din              ( {pmt_encode_x_i,pmt_encode_w_i}     ),  // input wire [63 : 0] din
//     .wr_en            ( pmt_fifo_wr_en && pmt_encode_en_i   ),  // input wire wr_en
//     .rd_en            ( pmt_encode_rd_en_i                  ),  // input wire rd_en
//     .dout             ( pmt_fifo_dout                       ),  // output wire [63 : 0] dout
//     .full             ( pmt_fifo_full                       ),  // output wire full
//     .empty            ( pmt_fifo_empty                      )   // output wire empty
//   );

// test_encode_fifo acs_encode_fifo_inst (
//     .clk              ( clk_i                               ),  // input wire clk
//     .srst             ( rst_i || test_encode_rst_i          ),  // input wire srst
//     .din              ( {acs_encode_x_i,acs_encode_w_i}     ),  // input wire [63 : 0] din
//     .wr_en            ( acs_fifo_wr_en && acs_encode_en_i   ),  // input wire wr_en
//     .rd_en            ( acs_encode_rd_en_i                  ),  // input wire rd_en
//     .dout             ( acs_fifo_dout                       ),  // output wire [63 : 0] dout
//     .full             ( acs_fifo_full                       ),  // output wire full
//     .empty            ( acs_fifo_empty                      )   // output wire empty
//   );
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) begin
    pmt_scan_en_d       <= #TCQ pmt_scan_en_i;
    pmt_scan_en_pose    <= #TCQ (~pmt_scan_en_d) && pmt_scan_en_i;
end

reg pmt_encode_first = 'd0;
// debug code - check w encode diff
always @(posedge clk_i) begin
    if(pmt_encode_en_i)
        pmt_encode_w_d <= #TCQ pmt_encode_w_i;
end

always @(posedge clk_i)begin
    if(pmt_encode_en_i)begin
        if(pmt_encode_w_d > pmt_encode_w_i)
            pmt_encode_w_diff <= #TCQ pmt_encode_w_i + {18{1'b1}} - pmt_encode_w_d;
        else
            pmt_encode_w_diff <= #TCQ pmt_encode_w_i - pmt_encode_w_d;
    end
end

always @(posedge clk_i)begin
    if(test_encode_rst_i)begin
        pmt_encode_w_diff_max <= #TCQ 'd0;
    end
    else if(pmt_scan_en_pose)begin
        pmt_encode_w_diff_max <= #TCQ 'd0;
    end
    else if(pmt_encode_first && pmt_encode_en_d1 && pmt_scan_en_d)begin
        if(pmt_encode_w_diff_max < pmt_encode_w_diff)
            pmt_encode_w_diff_max <= #TCQ pmt_encode_w_diff;
    end
end

always @(posedge clk_i) begin
    if(pmt_scan_en_pose)
        pmt_encode_first <= #TCQ 'd0;
    else if(pmt_encode_en_d1)
        pmt_encode_first <= #TCQ 'd1;
end

always @(posedge clk_i) begin
    pmt_encode_en_d0 <= #TCQ pmt_encode_en_i;
    pmt_encode_en_d1 <= #TCQ pmt_encode_en_d0;

    if(test_encode_rst_i)begin
        pmt_encode_err <= #TCQ 'd0;
    end
    else if(pmt_encode_first && pmt_encode_en_d1 && pmt_scan_en_d)begin
        if(pmt_encode_w_diff > pmt_w_encode_thr_i)
            pmt_encode_err <= #TCQ 'd1;
        else 
            pmt_encode_err <= #TCQ 'd0;
    end
end

// always @(posedge clk_i) begin
//     if(~pmt_encode_err)
//         pmt_encode_err_cnt <= #TCQ 'd0;
//     else if(pmt_encode_err_cnt < 'd100)
//         pmt_encode_err_cnt <= #TCQ pmt_encode_en_i ? pmt_encode_err_cnt + 1 : pmt_encode_err_cnt;
// end

// always @(posedge clk_i) begin
//     if(pmt_scan_en_pose)begin
//         pmt_fifo_wr_en <= #TCQ 'd1;
//     end
//     else if((~pmt_scan_en_d) || pmt_encode_err_cnt == 'd100)
//         pmt_fifo_wr_en <= #TCQ 'd0;
// end


assign pmt_encode_w_diff_max_o  = pmt_encode_w_diff_max;
// assign pmt_x_encode_o           = pmt_fifo_dout[63:32];
// assign pmt_w_encode_o           = pmt_fifo_dout[31:0];
// assign pmt_fifo_state_o         = {pmt_fifo_full,pmt_fifo_empty};


// acs 

always @(posedge clk_i) begin
    acs_encode_en_d0 <= #TCQ acs_encode_en_i;
    acs_encode_en_d1 <= #TCQ acs_encode_en_d0;
end

always @(posedge clk_i) begin
    if(acs_encode_en_i)
        acs_encode_w_d <= #TCQ acs_encode_w_i;
end

always @(posedge clk_i) begin
    if(acs_encode_en_i)begin
        if(acs_encode_w_d > acs_encode_w_i)
            acs_encode_w_diff <= #TCQ acs_encode_w_i + {18{1'b1}} - acs_encode_w_d;
        else
            acs_encode_w_diff <= #TCQ acs_encode_w_i - acs_encode_w_d;
    end
end

always @(posedge clk_i) begin
    if(acs_encode_en_d0)
        acs_encode_w_diff_d <= #TCQ acs_encode_w_diff;
end

always @(posedge clk_i) begin
    if(acs_encode_en_d0)begin
        acs_encode_speed_diff <= #TCQ acs_encode_w_diff - acs_encode_w_diff_d;
    end
end

reg acs_encode_first = 'd0;
always @(posedge clk_i) begin
    if(pmt_scan_en_pose)
        acs_encode_first <= #TCQ 'd0;
    else if(acs_encode_en_d1)
        acs_encode_first <= #TCQ 'd1;
end

always @(posedge clk_i) begin
    if(test_encode_rst_i)begin
        acs_encode_err <= #TCQ 'd0;
    end
    else if(acs_encode_first && acs_encode_en_d1 && pmt_scan_en_d)begin
        if(acs_encode_speed_diff > acs_w_encode_thr_i)
            acs_encode_err <= #TCQ 'd1;
        else 
            acs_encode_err <= #TCQ 'd0;
    end
end

// always @(posedge clk_i) begin
//     if(~acs_encode_err)
//         acs_encode_err_cnt <= #TCQ 'd0;
//     else if(acs_encode_err_cnt < 'd100)
//         acs_encode_err_cnt <= #TCQ acs_encode_en_i ? acs_encode_err_cnt + 1 : acs_encode_err_cnt;
// end

// always @(posedge clk_i) begin
//     if(pmt_scan_en_pose)begin
//         acs_fifo_wr_en <= #TCQ 'd1;
//     end
//     else if((~pmt_scan_en_d) || acs_encode_err_cnt == 'd100)
//         acs_fifo_wr_en <= #TCQ 'd0;
// end

// assign acs_x_encode_o           = acs_fifo_dout[63:32];
// assign acs_w_encode_o           = acs_fifo_dout[31:0];
// assign acs_fifo_state_o         = {acs_fifo_full,acs_fifo_empty};
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

endmodule
