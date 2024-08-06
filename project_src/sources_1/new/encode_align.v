`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/10/23
// Design Name: PCG
// Module Name: encode_align
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


module encode_align #(
    parameter                   TCQ             = 0.1   
)(
    // clk & rst
    input                       clk_i                   ,
    input                       rst_i                   ,

    input                       encode_sim_en_i         ,
    input                       precise_encode_en_i     ,
    input       [18-1:0]        precise_encode_w_i      ,
    input       [18-1:0]        precise_encode_x_i      ,

    input                       pmt_scan_en_i           ,
    input                       pmt_Wencode_align_rst_i ,
    input       [32-1:0]        pmt_Wencode_align_set_i ,
    output                      pmt_encode_en_o         ,
    output      [18-1:0]        pmt_encode_w_o          ,
    output      [18-1:0]        pmt_encode_x_o          ,

    // input                       eds_scan_en_i           ,
    // output                      eds_encode_en_o         ,
    // output      [32-1:0]        eds_encode_w_o          ,
    // output      [32-1:0]        eds_encode_x_o          ,

    input       [32-1:0]        timing_flag_supp_i      ,
    input       [14-1:0]        timing_flag_i           ,
    output      [14-1:0]        align_timing_flag_o     
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                     align_rst                   = 'd1;

reg     [32-1:0]        encode_sim_w                = 'd0;
reg     [32-1:0]        encode_sim_x                = 'd0;

reg                     align_wr_en                 = 'd0;
reg     [18-1:0]        align_wr_wencode            = 'd0;
reg                     align_rd_en                 = 'd0;
reg                     align_valid                 = 'd0;

reg     [32-1:0]        timing_flag_delay           = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                    precise_encode_en               ;
wire    [18-1:0]        precise_encode_w                ;
wire    [18-1:0]        precise_encode_x                ;

wire    [18-1:0]        align_dout                      ;
wire                    align_full                      ;
wire                    align_empty                     ;
wire    [12-1:0]        align_data_count                ;

wire                    align_encode_en                 ;
wire    [36-1:0]        align_encode_data               ;
// wire                    pmt_encode_w_en                 ;
// wire                    pmt_encode_x_en                 ;
// wire                    eds_encode_w_en                 ;
// wire                    eds_encode_x_en                 ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
encode_x_align_fifo encode_x_align_fifo_inst (
  .clk                          ( clk_i                     ),  // input wire clk
  .srst                         ( align_rst                 ),  // input wire srst
  .din                          ( align_wr_wencode          ),  // input wire [18 : 0] din
  .wr_en                        ( align_wr_en               ),  // input wire wr_en
  .rd_en                        ( align_rd_en               ),  // input wire rd_en
  .dout                         ( align_dout                ),  // output wire [18 : 0] dout
  .full                         ( align_full                ),  // output wire full
  .empty                        ( align_empty               ),  // output wire empty
  .data_count                   ( align_data_count          )   // output wire [11 : 0] data_count
);

encode_align_unit #(
    .ENCODE_WIDTH               ( 36                        )
) pmt_Wencode_align_unit_inst(
    // clk & rst
    .clk_i                      ( clk_i                     ),
    .rst_i                      ( align_rst                 ),

    .encode_sim_en_i            ( encode_sim_en_i           ),
    .encode_sim_i               ( {encode_sim_w[17:0],encode_sim_x[21:4]}              ),
    .precise_encode_en_i        ( precise_encode_en         ),
    .precise_encode_i           ( {precise_encode_w[17:0],precise_encode_x[17:0]}   ),

    .scan_en_i                  ( pmt_scan_en_i             ),
    .align_rst_i                ( pmt_Wencode_align_rst_i   ),
    .align_set_i                ( pmt_Wencode_align_set_i   ),
    .encode_en_o                ( align_encode_en           ),
    .encode_o                   ( align_encode_data         )
);


align_unit #(
    .ALIGN_WIDTH                ( 14                        )
)align_unit_inst(
    // clk & rst
    .clk_i                      ( clk_i                     ),
    .rst_i                      ( align_rst                 ),

    .data_sim_en_i              ( 'd0                       ),
    .data_sim_i                 ( 'd0                       ),
    .data_en_i                  ( 'd1                       ),
    .data_i                     ( timing_flag_i             ),

    .align_start_en_i           ( pmt_scan_en_i             ),
    .align_rst_i                ( pmt_Wencode_align_rst_i   ),
    .align_set_i                ( timing_flag_delay         ),
    .align_data_o               ( align_timing_flag_o       )
);
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) begin
    timing_flag_delay <= #TCQ ~pmt_Wencode_align_set_i + 1 + timing_flag_supp_i;
end

always @(posedge clk_i) begin
    if(encode_sim_en_i)begin
        encode_sim_w <= #TCQ encode_sim_w + 1;
        encode_sim_x <= #TCQ encode_sim_x + 1;
    end
    else begin
        encode_sim_w <= #TCQ 'd0;
        encode_sim_x <= #TCQ 'd0;
    end
end

always @(posedge clk_i) begin
    if(rst_i)
        align_rst <= #TCQ 'd1;
    else if(precise_encode_en_i || encode_sim_en_i)
        align_rst <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(align_rst)
        align_wr_en <= #TCQ 'd0;
    else 
        align_wr_en <= #TCQ precise_encode_en_i && (~align_full);
end

always @(posedge clk_i) begin
    align_wr_wencode    <= #TCQ precise_encode_x_i;
end

always @(posedge clk_i) begin
    if(align_data_count >= 'd2998) // 30us
        align_rd_en <= #TCQ align_wr_en;
    else 
        align_rd_en <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    align_valid <= #TCQ align_rd_en;
end

assign precise_encode_en = align_valid;
assign precise_encode_w  = precise_encode_w_i;
assign precise_encode_x  = align_dout;


// out enable
assign pmt_encode_en_o = align_encode_en && pmt_scan_en_i;
assign pmt_encode_w_o  = align_encode_data[36-1:18];
assign pmt_encode_x_o  = align_encode_data[17:0];
// assign eds_encode_en_o = align_encode_en && eds_scan_en_i;
// assign eds_encode_w_o  = {14'd0,align_encode_data[36-1:18]};
// assign eds_encode_x_o  = {14'd0,align_encode_data[17:0]};
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




endmodule
