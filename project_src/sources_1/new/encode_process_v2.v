`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/06/19
// Design Name: PCG
// Module Name: encode_process_v2
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


module encode_process_v2 #(
    parameter                               TCQ                 = 0.1   ,
    parameter                               FIRST_DELTA_WENCODE = 0     , // 初始 W Encode 增量，用于 first Encode 前插值
    parameter                               FIRST_DELTA_XENCODE = 0     , // 初始 X Encode 增量，用于 first Encode 前插值
    parameter                               EXTEND_WIDTH        = 20    , // 定点位宽
    parameter                               UNIT_INTER          = 4000  , // 插值数，= 100M/25k 
    parameter                               DELTA_UPDATE_DOT    = 4     , // 插值点倍率（每5个点插4个值）
    parameter                               DELTA_UPDATE_GAP    = 5     , 
    parameter                               ENCODE_MASK_WID     = 32    , // W Encode 有效位宽，W Encode 零点规定为有效位宽最大值
    parameter                               ENCODE_WID          = 32      // Encode 位宽
)(
    // clk & rst
    input   wire                            clk_i               ,
    input   wire                            rst_i               ,

    input   wire                            x_zero_flag_i       ,
    input   wire                            encode_update_i     ,
    input   wire        [ENCODE_WID-1:0]    encode_w_i          ,
    input   wire signed [ENCODE_WID-1:0]    encode_x_i          ,

    output  wire                            precise_encode_en_o ,
    output  wire    [ENCODE_WID-1:0]        precise_encode_w_o  ,
    output  wire    [ENCODE_WID-1:0]        precise_encode_x_o  
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam signed   [EXTEND_WIDTH-1:0]      MULT_FACTOR             = {EXTEND_WIDTH{1'b1}} / UNIT_INTER;
localparam                                  ENCODE_MULT_WIDTH       = ENCODE_WID + EXTEND_WIDTH;
localparam                                  UPDATE_CNT_WIDTH        = $clog2(DELTA_UPDATE_GAP);

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                                     first_encode            = 'd1;
reg         [ENCODE_WID-1:0]            encode_w_d0             = 'd0;
reg         [ENCODE_WID-1:0]            encode_w_d1             = 'd0;
reg         [ENCODE_WID-1:0]            encode_w_d2             = 'd0;
reg         [ENCODE_WID-1:0]            delta_w_encode          = 'd0;
reg         [ENCODE_WID-1:0]            inter_w_err             = 'd0;

reg signed  [ENCODE_WID-1:0]            encode_x_d0             = 'd0;
reg signed  [ENCODE_WID-1:0]            encode_x_d1             = 'd0;
reg signed  [ENCODE_WID-1:0]            encode_x_d2             = 'd0;
reg signed  [ENCODE_WID-1:0]            delta_x_encode          = 'd0;
reg signed  [ENCODE_WID-1:0]            inter_x_err             = 'd0;

reg                                     encode_update_d0        = 'd0;
reg                                     encode_update_d1        = 'd0;
reg                                     encode_update_d2        = 'd0;
reg                                     encode_update_d3        = 'd0;
reg                                     encode_update_d4        = 'd0;
(*use_dsp = "yes"*)reg         [ENCODE_MULT_WIDTH-1:0]         mult_w_encode           = 'd0;
(*use_dsp = "yes"*)reg signed  [ENCODE_MULT_WIDTH-1:0]         mult_x_encode           = 'd0;
reg         [ENCODE_MULT_WIDTH-1:0]         precise_w_encode        = 'd0;
reg signed  [ENCODE_MULT_WIDTH-1:0]         precise_x_encode        = 'd0;

reg                                     check_wafer_zero_flag   = 'd0;
reg                                     wafer_zero_flag         = 'd0;
(*dont_touch = "true"*)reg                                     precise_encode_en       = 'd0;

reg     [UPDATE_CNT_WIDTH :0]           precise_update_cnt      = 'd0;
reg                                     first_encode_d0         = 'd0;
reg                                     first_encode_d1         = 'd0;
reg                                     first_encode_d2         = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                    wafer_zero_flag_pre;
// wire                                    w_encode_reduce_flag;


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) begin
    if(rst_i || x_zero_flag_i)
        first_encode <= #TCQ 'd1;
    else if(encode_update_i)
        first_encode <= #TCQ 'd0; 
end

always @(posedge clk_i) begin
    encode_update_d0 <= #TCQ encode_update_i;
    encode_update_d1 <= #TCQ encode_update_d0;
    encode_update_d2 <= #TCQ encode_update_d1;
    encode_update_d3 <= #TCQ encode_update_d2;
    encode_update_d4 <= #TCQ encode_update_d3;
end

always @(posedge clk_i) begin
    if(encode_update_i)begin
        encode_w_d0 <= #TCQ encode_w_i;
        encode_x_d0 <= #TCQ encode_x_i;
    end
end

always @(posedge clk_i) begin
    encode_w_d1 <= #TCQ encode_w_d0;
    encode_x_d1 <= #TCQ encode_x_d0;
    encode_w_d2 <= #TCQ encode_w_d1;
    encode_x_d2 <= #TCQ encode_x_d1;
end

// compensating interpolation errors
wire [ENCODE_WID-1:0] encode_w_err;
wire [ENCODE_WID-1:0] encode_w_err_abs;
assign encode_w_err = (encode_w_d0 - precise_encode_w_o);
assign encode_w_err_abs = encode_w_err[ENCODE_WID-1] ? (~encode_w_err + 1) : encode_w_err;
always @(posedge clk_i) begin
    if(first_encode)begin
        inter_w_err <= #TCQ 'd0;
    end
    else if(encode_update_i)begin
        if(encode_w_err_abs > {(ENCODE_MASK_WID-1){1'b1}})
            inter_w_err <= #TCQ 'd0;
        else 
            inter_w_err <= #TCQ encode_w_err;
    end
end

// generate absolute difference of continuous w encode
wire [ENCODE_WID-1:0] encode_w_delta;
wire [ENCODE_WID-1:0] encode_w_delta_abs;
assign encode_w_delta = (encode_w_i - encode_w_d0);
assign encode_w_delta_abs = encode_w_delta[ENCODE_WID-1] ? (~encode_w_delta + 1) : encode_w_delta;

always @(posedge clk_i) begin
    if(first_encode)begin
        delta_w_encode <= #TCQ FIRST_DELTA_WENCODE;
    end
    else if(encode_update_i)begin
        case({encode_w_d0[ENCODE_MASK_WID-1],encode_w_i[ENCODE_MASK_WID-1]})
            2'b00: begin
                if(encode_w_i >= encode_w_d0)
                    delta_w_encode <= #TCQ encode_w_delta;
                else 
                    delta_w_encode <= #TCQ 'd0;
            end
            2'b01: begin
                if(encode_w_delta_abs > {(ENCODE_MASK_WID-1){1'b1}})
                    delta_w_encode <= #TCQ 'd0;
                else
                    delta_w_encode <= #TCQ encode_w_delta;
            end
            2'b10: begin
                if(encode_w_delta_abs > {(ENCODE_MASK_WID-1){1'b1}})
                    delta_w_encode <= #TCQ encode_w_i + {ENCODE_MASK_WID{1'b1}} - encode_w_d0;
                else
                    delta_w_encode <= #TCQ 'd0;
            end
            2'b11: begin
                if(encode_w_i >= encode_w_d0)
                    delta_w_encode <= #TCQ encode_w_delta;
                else 
                    delta_w_encode <= #TCQ 'd0;
            end
            default:/**/;
        endcase
    end
end

// generate difference of continuous x encode
always @(posedge clk_i) begin
    if(first_encode)begin
        delta_x_encode <= #TCQ FIRST_DELTA_XENCODE;
    end
    else if(encode_update_i)
        delta_x_encode <= #TCQ encode_x_i - encode_x_d0;
end

wire [ENCODE_WID-1:0]            delta_w_encode_sum;
wire [ENCODE_WID-1:0]            delta_w_encode_temp;

assign delta_w_encode_sum = delta_w_encode + inter_w_err;
assign delta_w_encode_temp = (delta_w_encode_sum[ENCODE_WID-1]) ? 'd0 : delta_w_encode_sum;
// generate multi encode result
always @(posedge clk_i) begin
    mult_w_encode    <= #TCQ delta_w_encode_temp * MULT_FACTOR;
    mult_x_encode    <= #TCQ delta_x_encode * MULT_FACTOR;
end

// assign w_encode_reduce_flag = encode_update_i && (encode_w_i[ENCODE_MASK_WID-1 : 7] < encode_w_d0[ENCODE_MASK_WID-1 : 7]); // w encode exceed zero

always @(posedge clk_i) begin
    if(encode_update_d1)begin
        precise_x_encode <= #TCQ {encode_x_d2[ENCODE_WID-1:0],{EXTEND_WIDTH{1'b0}}};
    end 
    else begin
        precise_x_encode <= #TCQ precise_x_encode + mult_x_encode;
    end
end

always @(posedge clk_i) begin
    if(first_encode)
        precise_w_encode <= #TCQ {encode_w_i[ENCODE_WID-1:0],{EXTEND_WIDTH{1'b0}}};
    else if(precise_encode_w_o == encode_w_d0[ENCODE_WID-1:0])begin
        precise_w_encode <= #TCQ {encode_w_d0[ENCODE_WID-1:0],1'b1,{(EXTEND_WIDTH-1){1'b0}}};
    end 
    else if(wafer_zero_flag_pre)begin
        precise_w_encode <= #TCQ 'd0;
    end
    else begin
        precise_w_encode <= #TCQ precise_w_encode + mult_w_encode;
    end
end


always @(posedge clk_i) begin
    if(wafer_zero_flag_pre)
        check_wafer_zero_flag <= #TCQ 'd1;
    else if(encode_update_d0 && check_wafer_zero_flag)
        check_wafer_zero_flag <= #TCQ 'd0; 
end

assign wafer_zero_flag_pre = (
                                (&precise_w_encode[EXTEND_WIDTH+ENCODE_MASK_WID-1 : EXTEND_WIDTH-1]) ||       // 0x3ffff1
                                (|precise_w_encode[ENCODE_MULT_WIDTH-1 : EXTEND_WIDTH+ENCODE_MASK_WID])       // >0x3ffff
                             );  
                        //   || (~first_encode && ~check_wafer_zero_flag && encode_update_i && w_encode_reduce_flag);      // W encode减小时强制零点

// always @(posedge clk_i) begin
//     wafer_zero_flag <= #TCQ wafer_zero_flag_pre;
// end

// enable generate
always @(posedge clk_i) first_encode_d0 <= #TCQ first_encode;
always @(posedge clk_i) first_encode_d1 <= #TCQ first_encode_d0;
always @(posedge clk_i) first_encode_d2 <= #TCQ first_encode_d1;
always @(posedge clk_i) begin
    if(first_encode_d2)
        precise_update_cnt <= #TCQ 'd0;
    else if(precise_update_cnt == DELTA_UPDATE_GAP-1)
        precise_update_cnt <= #TCQ 'd0;
    else 
        precise_update_cnt <= #TCQ precise_update_cnt + 'd1;
end

always @(posedge clk_i) begin
    if(first_encode_d2)begin
        precise_encode_en <= #TCQ 'd0;
    end
    else if(precise_update_cnt <= DELTA_UPDATE_DOT-1)begin
        precise_encode_en <= #TCQ 'd1;
    end
    else begin
        precise_encode_en <= #TCQ 'd0;
    end
end

// assign wafer_zero_flag_o   = wafer_zero_flag;
assign precise_encode_en_o = precise_encode_en;
assign precise_encode_w_o  = (|precise_w_encode[ENCODE_MULT_WIDTH-1 : EXTEND_WIDTH+ENCODE_MASK_WID])
                            ? {{(ENCODE_WID-ENCODE_MASK_WID){1'b0}},{ENCODE_MASK_WID{1'b1}}} // w encode max = 'h3ffff
                            : {precise_w_encode[ENCODE_MULT_WIDTH-1:EXTEND_WIDTH]};          // 

assign precise_encode_x_o  = precise_x_encode[ENCODE_MULT_WIDTH-1] ? 'd0 : precise_x_encode[ENCODE_MULT_WIDTH-1:EXTEND_WIDTH];
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// simulate debug logic
`ifdef SIMULATE
reg [ENCODE_MASK_WID-1:0]  encode_w_diff = 'd0;
reg [ENCODE_MASK_WID-1:0]  precise_encode_w_o_d = 'd0;
always @(posedge clk_i) begin
    precise_encode_w_o_d[ENCODE_MASK_WID-1:0] <= #TCQ precise_encode_w_o[ENCODE_MASK_WID-1:0];
    encode_w_diff <= #TCQ precise_encode_w_o[ENCODE_MASK_WID-1:0] - precise_encode_w_o_d[ENCODE_MASK_WID-1:0];
end

`endif // SIMULATE

endmodule
