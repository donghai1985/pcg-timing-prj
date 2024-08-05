`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: songyuxin
// 
// Create Date: 2023/06/01
// Design Name: 
// Module Name: bspi_ctrl
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


module bspi_ctrl #(
    parameter                               TCQ                = 0.1,
    parameter                               SPI_CLK_DIVIDER    = 6  , // SPI Clock Control / Divid
    parameter                               SPI_MASTER_WIDTH   = 64 , // master spi data width
    parameter                               SPI_SLAVE_WIDTH    = 48   // slave spi data width

)(
    // clk & rst
    input   wire                            clk_i                   ,
    input   wire                            rst_i                   ,
    
    // input   wire [11-1:0]                   sensor_ds_rate_i        ,
    input   wire                            mspi_wr_en_i            ,
    input   wire [SPI_MASTER_WIDTH-1:0]     mspi_wr_data_i          ,
    output  wire                            sspi_rd_vld_o           ,
    output  wire [SPI_SLAVE_WIDTH-1:0]      sspi_rd_data_o          ,
    // output  wire                            sspi_rd_avg_vld_o       ,
    // output  wire [SPI_SLAVE_WIDTH-1:0]      sspi_rd_avg_data_o      ,
    // output  wire                            sspi_rd_ds_vld_o        ,
    // output  wire [SPI_SLAVE_WIDTH-1:0]      sspi_rd_ds_data_o       , 
    // bspi info
    output  wire                            MSPI_CLK                ,
    output  wire                            MSPI_MOSI               ,
    input   wire                            SSPI_CLK                ,
    input   wire                            SSPI_MISO               
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam       [ 3-1:0]                   WR_IDLE             = 'd0;
localparam       [ 3-1:0]                   WR_TX               = 'd1;
// localparam       [ 3-1:0]                   WR_FINISH           = 'd2;
 
localparam       [ 3-1:0]                   RD_IDLE             = 3'b001;
localparam       [ 3-1:0]                   RD_RX               = 3'b010;
localparam       [ 3-1:0]                   RD_FINISH           = 3'b100;

localparam                                  MSPI_CLK_DIV        = SPI_CLK_DIVIDER/2 -1;
localparam                                  WR_CNT_WIDTH        = $clog2(SPI_MASTER_WIDTH);
localparam                                  RD_CNT_WIDTH        = $clog2(SPI_SLAVE_WIDTH);
localparam       [16-1:0]                   RD_TIMEOUT_LEN      = 'd300; // > 300M/50M * 48

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg              [ 3-1:0]                   wr_state            = WR_IDLE;
reg              [ 3-1:0]                   rd_state            = RD_IDLE;
reg                                         mspi_clk_r          = 'd0;
reg              [ 3-1:0]                   mspi_clk_cnt        = 'd0;
reg                                         mspi_clk_d          = 'd0;

reg              [WR_CNT_WIDTH-1:0]         mspi_wr_cnt         = 'd0;
reg              [SPI_MASTER_WIDTH-1:0]     mspi_wr_data_r      = 'd0;

reg                                         sspi_clk_d0         = 'd0;
reg                                         sspi_clk_d1         = 'd0;
reg              [RD_CNT_WIDTH-1:0]         sspi_rd_cnt         = 'd0;
reg              [SPI_SLAVE_WIDTH-1:0]      rd_rx_data_temp     = 'd0;
reg              [16-1:0]                   rd_timeout_cnt      = 'd0;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                        mspi_csn         ;
wire                                        mspi_clk_pose    ;
wire                                        mspi_clk_nege    ;
wire                                        wr_tx_done       ;
wire                                        sspi_rd_start    ;
wire                                        rd_rx_done       ;
wire                                        sspi_clk_pose    ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// generate master clk 
always @(posedge clk_i) begin
    if(mspi_csn)
        mspi_clk_cnt <= #TCQ 'd0;
    else if(mspi_clk_cnt==MSPI_CLK_DIV)
        mspi_clk_cnt <= #TCQ 'd0;
    else 
        mspi_clk_cnt <= #TCQ mspi_clk_cnt + 1;
end

always @(posedge clk_i) begin
    if(mspi_csn)
        mspi_clk_r <= #TCQ 'd0;
    else if(mspi_clk_cnt == MSPI_CLK_DIV)
        mspi_clk_r <= #TCQ ~mspi_clk_r;
end

always @(posedge clk_i) mspi_clk_d <= #TCQ mspi_clk_r;
assign mspi_clk_pose = ~mspi_clk_d &&  mspi_clk_r;
assign mspi_clk_nege =  mspi_clk_d && ~mspi_clk_r;

// bspi write logic
assign mspi_csn = wr_state == WR_IDLE;

always @(posedge clk_i) begin
    if(rst_i)begin
        wr_state <= #TCQ WR_IDLE;
    end
    else begin
        case (wr_state)
            WR_IDLE :begin
                if(mspi_wr_en_i)
                    wr_state <= #TCQ WR_TX;
                else 
                    wr_state <= #TCQ WR_IDLE; 
            end 
            WR_TX :begin
                if(wr_tx_done)
                    wr_state <= #TCQ WR_IDLE; 
                else
                    wr_state <= #TCQ WR_TX;
            end
            default:wr_state <= #TCQ WR_IDLE;
        endcase
    end
end


always @(posedge clk_i) begin
    if(mspi_wr_en_i && mspi_csn)
        mspi_wr_data_r <= #TCQ mspi_wr_data_i;
    else if(mspi_clk_nege)
        mspi_wr_data_r <= #TCQ {mspi_wr_data_r[SPI_MASTER_WIDTH-2:0],1'b0};
end

always @(posedge clk_i) begin
    if(mspi_wr_en_i && mspi_csn)
        mspi_wr_cnt <= #TCQ 'd0;
    else if(mspi_clk_nege)
        mspi_wr_cnt <= #TCQ mspi_wr_cnt + 1;
end

assign wr_tx_done = (wr_state==WR_TX) && (mspi_wr_cnt==SPI_MASTER_WIDTH-1) && mspi_clk_nege;
assign MSPI_MOSI = mspi_wr_data_r[SPI_MASTER_WIDTH-1];
assign MSPI_CLK = mspi_clk_r;


// bspi read logic
always @(posedge clk_i) begin
    sspi_clk_d0 <= #TCQ SSPI_CLK;
    sspi_clk_d1 <= #TCQ sspi_clk_d0;
end

assign sspi_clk_pose = ~sspi_clk_d1 && sspi_clk_d0;

assign sspi_rd_start = sspi_clk_pose && rd_state==RD_IDLE;

always @(posedge clk_i) begin
    if(rst_i)begin
        rd_state <= #TCQ RD_IDLE;
    end
    else begin
        case (rd_state)
            RD_IDLE :begin
                if(sspi_rd_start)
                    rd_state <= #TCQ RD_RX;
                else 
                    rd_state <= #TCQ RD_IDLE; 
            end 
            RD_RX :begin
                if(rd_timeout_cnt==RD_TIMEOUT_LEN)
                    rd_state <= #TCQ RD_IDLE;
                else if(rd_rx_done)
                    rd_state <= #TCQ RD_FINISH; 
                else
                    rd_state <= #TCQ RD_RX;
            end
            RD_FINISH:
                    rd_state <= #TCQ RD_IDLE;
            default:rd_state <= #TCQ RD_IDLE;
        endcase
    end
end

always @(posedge clk_i) begin
    if(sspi_clk_pose)
        rd_rx_data_temp <= #TCQ {rd_rx_data_temp[SPI_SLAVE_WIDTH-2:0],SSPI_MISO};
end

always @(posedge clk_i) begin
    if(rd_state==RD_IDLE)
        sspi_rd_cnt <= #TCQ 'd0;
    else if(sspi_clk_pose && rd_state==RD_RX)
        sspi_rd_cnt <= #TCQ sspi_rd_cnt + 1;
end

always @(posedge clk_i) begin
    if(rd_state==RD_RX)begin
        rd_timeout_cnt <= #TCQ rd_timeout_cnt + 1;
    end
    else 
        rd_timeout_cnt <= #TCQ 'd0;
end

assign rd_rx_done = sspi_rd_cnt==SPI_SLAVE_WIDTH-1 && rd_state==RD_RX;

reg                            rd_rx_vld      = 'd0;
reg [SPI_SLAVE_WIDTH-1:0]      rd_rx_data     = 'd0;

always @(posedge clk_i) begin
    rd_rx_vld <= #TCQ rd_state==RD_FINISH  ;  
end

always @(posedge clk_i) begin
    if(rd_state==RD_FINISH)
        rd_rx_data <= #TCQ rd_rx_data_temp;
end
assign sspi_rd_vld_o  = rd_rx_vld ;
assign sspi_rd_data_o = rd_rx_data;

// // sliding filtering x128
// localparam    SF_RATE = 7;
// reg [SPI_SLAVE_WIDTH-1:0] filter_mem [0:127];
// reg [SF_RATE-1:0] filter_cnt = 'd0;
// always @(posedge clk_i) begin
//     if(rst_i)
//         filter_cnt <= #TCQ 'd0;
//     else if(rd_rx_vld)
//         filter_cnt <= #TCQ filter_cnt + 1;
// end

// always @(posedge clk_i) begin
//     if(rd_rx_vld)
//         filter_mem[filter_cnt] <= #TCQ rd_rx_data;
// end

// reg filter_sum_flag = 'd0;
// always @(posedge clk_i) begin
//     if(rst_i)
//         filter_sum_flag <= #TCQ 'd0;
//     else if(rd_rx_vld && (&filter_cnt))
//         filter_sum_flag <= #TCQ 'd1;
// end

// reg [24+SF_RATE-1:0] rd_rx_data_a_sum = 'd0;
// reg [24+SF_RATE-1:0] rd_rx_data_b_sum = 'd0;
// always @(posedge clk_i) begin
//     if(rd_rx_vld)begin
//         if(filter_sum_flag)begin
//             rd_rx_data_a_sum <= #TCQ rd_rx_data_a_sum + rd_rx_data[48-1:24] - filter_mem[filter_cnt][48-1:24];
//             rd_rx_data_b_sum <= #TCQ rd_rx_data_b_sum + rd_rx_data[24-1:0] - filter_mem[filter_cnt][24-1:0];
//         end
//         else begin
//             rd_rx_data_a_sum <= #TCQ rd_rx_data_a_sum + rd_rx_data[48-1:24];
//             rd_rx_data_b_sum <= #TCQ rd_rx_data_b_sum + rd_rx_data[24-1:0];
//         end
//     end 
// end

// reg [SPI_SLAVE_WIDTH-1:0] rd_rx_avg_data = 'd0;
// reg                       rd_rx_avg_vld  = 'd0;
// always @(posedge clk_i) begin
//     rd_rx_avg_vld  <= #TCQ rd_rx_vld && filter_sum_flag;
//     rd_rx_avg_data <= #TCQ {rd_rx_data_a_sum[24+SF_RATE-1 : SF_RATE],rd_rx_data_b_sum[24+SF_RATE-1 : SF_RATE]};
// end

// assign sspi_rd_avg_vld_o  = rd_rx_avg_vld ;
// assign sspi_rd_avg_data_o = rd_rx_avg_data;

// down sample x16
// reg [10-1:0] down_sample_cnt = 'd0;
// wire sensor_ds_rate_en = sensor_ds_rate_i[10];
// always @(posedge clk_i) begin
//     if(rst_i)
//         down_sample_cnt <= #TCQ 'd0;
//     else if(sensor_ds_rate_en || (down_sample_cnt==sensor_ds_rate_i[9:0]))
//         down_sample_cnt <= #TCQ 'd0;
//     else if(rd_rx_vld)
//         down_sample_cnt <= #TCQ down_sample_cnt + 1;
// end

// assign sspi_rd_ds_vld_o  = rd_rx_vld && (&down_sample_cnt);
// assign sspi_rd_ds_data_o = rd_rx_data;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

endmodule
