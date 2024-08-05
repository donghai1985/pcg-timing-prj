// (c) Copyright 2008 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//

//
//  FRAME GEN
//
//
//
//  Description: This module is a pattern generator to test the Aurora
//               designs in hardware. It generates data and passes it
//               through the Aurora channel. If connected to a framing
//               interface, it generates frames of varying size and
//               separation. LFSR is used to generate the pseudo-random
//               data and lower bits of LFSR are connected to REM bus

`timescale 1 ns / 1 ps
`define DLY #1

module aurora_8b10b_0_FRAME_GEN
(
    // User Interface
    input               eds_frame_en_i                  ,
    output              eds_to_aurora_txen_o            ,
    input   [31:0]      eds_to_aurora_txdata_i          ,
    input   [14:0]      eds_to_aurora_rd_data_count_i   ,
    input               pcie_eds_frame_end_i            ,
    output              clear_eds_buffer_o              ,

    input               pmt_start_en_i                  ,
    input               pcie_pmt_end_i                  ,
    input               encode_w_data_out_en_i          ,
    input   [32-1:0]    encode_w_data_out_i             ,
    input   [32-1:0]    encode_x_data_out_i             ,

    // FBC 
    output              aurora_fbc_en_o                 ,
    input   [32-1:0]    aurora_fbc_data_i               ,
    input   [11-1:0]    aurora_fbc_count_i              ,
    input               aurora_fbc_end_i                ,
    input               aurora_fbc_empty_i              ,
    
    // System Interface
    input               USER_CLK                        ,
    input               RESET                           ,
    input               CHANNEL_UP                      ,
    
    output  reg         tx_tvalid                       ,
    output  reg [31:0]  tx_data                         ,
    output  wire [3:0]  tx_tkeep                        ,
    output  reg         tx_tlast                        ,
    input               tx_tready                       
);


//***************************Internal Register/Wire Declarations***************************
parameter                       TCQ                 = 0.1       ;
localparam                      EDS_PACKAGE_LENG    = 'd1027    ;
localparam                      TX_IDLE             = 'd0       ;
localparam                      TX_EDS_START        = 'd1       ;
localparam                      TX_EDS_DATA         = 'd2       ;
localparam                      TX_EDS_END          = 'd3       ;
localparam                      TX_PCIE_WITE        = 'd4       ;
localparam                      TX_EDS_WITE         = 'd5       ;
localparam                      TX_ENCODE_WITE      = 'd6       ;
localparam                      TX_ENCODE           = 'd7       ;
localparam                      TX_FBC_WITE         = 'd8       ;
localparam                      TX_FBC              = 'd9       ;
localparam                      TX_FBC_START        = 'd10      ;
localparam                      TX_FBC_START_DELAY  = 'd11      ;
localparam                      TX_FBC_END_DELAY    = 'd12      ;
localparam                      TX_FBC_END          = 'd13      ;

// localparam                      CHECK_FBC_TIMEOUT   = 'd2500000 ; // 10ms

wire                            reset_c                         ;
wire                            dly_data_xfer                   ;
wire                            eds_frame_pose                  ;
wire                            pmt_start_pose                  ;
wire                            wait_fbc_timeout                ;

reg     [4-1:0]                 tx_state            = TX_IDLE   ;
reg     [4-1:0]                 tx_state_next       = TX_IDLE   ;
reg     [4:0]                   channel_up_cnt      = 'd0       ;

reg     [15:0]                  len_cnt             = 'd0       ;
reg     [31:0]                  frame_cnt           = 'd0       ;
reg     [7:0]                   eds_tx_delay_cnt    = 'd0       ;
reg                             eds_last_package    = 'd0       ;

reg                             eds_frame_en_d0     = 'd0       ;
reg                             eds_frame_en_d1     = 'd0       ;

reg                             pcie_pmt_stop_en    = 'd0       ;
reg                             pmt_start_en_d0     = 'd0       ;
reg                             pmt_start_en_d1     = 'd0       ;
reg                             pcie_eds_frame_end_flag = 'd0   ;

reg     [9:0]                   fbc_delay_cnt       = 'd0       ; 
reg                             aurora_fbc_end_d    = 'd0       ;
reg                             aurora_fbc_empty_d  = 'd0       ;
//*********************************Main Body of Code**********************************
always @ (posedge USER_CLK)
begin
    if(RESET)
        channel_up_cnt <= #TCQ 5'd0;
    else if(CHANNEL_UP)
        if(&channel_up_cnt)
            channel_up_cnt <= #TCQ channel_up_cnt;
        else 
            channel_up_cnt <= #TCQ channel_up_cnt + 1'b1;
    else
        channel_up_cnt <= #TCQ 5'd0;
end

assign dly_data_xfer = (&channel_up_cnt);

  //Generate RESET signal when Aurora channel is not ready
assign reset_c = RESET || !dly_data_xfer;

//EDS包帧长为帧头32bit + 32bit帧计数器 + 64bit X/W encoder数据 + 1024*32bit,
//帧头格式为16'h55aa + 16bit指令码
    //______________________________ Transmit Data  __________________________________   

always @ (posedge USER_CLK)begin
    eds_frame_en_d0 <= #TCQ eds_frame_en_i;
    eds_frame_en_d1 <= #TCQ eds_frame_en_d0;
end
always @ (posedge USER_CLK)begin
    pmt_start_en_d0 <= #TCQ pmt_start_en_i;
    pmt_start_en_d1 <= #TCQ pmt_start_en_d0;
end
always @(posedge USER_CLK) begin
    if(tx_state==TX_IDLE)
        pcie_pmt_stop_en <= #TCQ 'd0;
    else if(pcie_pmt_end_i)
        pcie_pmt_stop_en <= #TCQ 'd1;
end

reg [22-1:0] timeout_cnt = 'd0;  // 16.7ms
always @(posedge USER_CLK) begin
    if(pcie_pmt_stop_en)begin
        if(timeout_cnt[21])
            timeout_cnt <= #TCQ timeout_cnt;
        else
            timeout_cnt <= #TCQ timeout_cnt + 1;
    end
    else 
        timeout_cnt <= #TCQ 'd0;
end

assign wait_fbc_timeout  =  timeout_cnt[21];

assign pmt_start_pose   = pmt_start_en_d0 && ~pmt_start_en_d1;
assign eds_frame_pose   = eds_frame_en_d0 && (~eds_frame_en_d1);

always @(posedge USER_CLK) begin
    if(reset_c)
        tx_state <= #TCQ TX_IDLE;
    else if(pmt_start_pose || eds_frame_pose)
        tx_state <= #TCQ TX_IDLE;
    else 
        tx_state <= #TCQ tx_state_next;
end

always @(*) begin
    tx_state_next = tx_state;
    case(tx_state)
        TX_IDLE: begin
            if(eds_frame_en_d1)
                tx_state_next = TX_EDS_START;
            else if(pmt_start_en_d1)
                tx_state_next = TX_ENCODE_WITE;
        end 

        TX_EDS_START: begin
            if(tx_tlast)
                tx_state_next = TX_PCIE_WITE; 
        end

        TX_PCIE_WITE: begin
            if(eds_tx_delay_cnt=='d200)  //加延迟目的是给pcie光纤卡清buffer预留时间
                tx_state_next = TX_EDS_WITE;
        end

        TX_EDS_WITE: begin
            if(~eds_last_package)begin
                if(~eds_frame_en_d1)
                    tx_state_next = TX_EDS_END;
                else if(eds_to_aurora_rd_data_count_i >= 'd1024)
                    tx_state_next = TX_EDS_DATA;
                else if(pcie_eds_frame_end_flag)
                    tx_state_next = TX_IDLE;
            end
            else begin
                if(pcie_eds_frame_end_flag)
                    tx_state_next = TX_IDLE;
                else if(eds_to_aurora_rd_data_count_i >= 'd1024)
                    tx_state_next = TX_EDS_DATA;
            end
        end

        TX_EDS_END: begin
            if(tx_tlast)
                tx_state_next = TX_EDS_WITE; 
        end

        TX_EDS_DATA: begin
            if(tx_tlast)
                tx_state_next = TX_EDS_WITE; 
        end

        TX_ENCODE_WITE: begin
            if(pcie_pmt_stop_en)begin
                if((aurora_fbc_empty_i && aurora_fbc_end_i) || wait_fbc_timeout)
                    tx_state_next = TX_IDLE;
                else if(~aurora_fbc_empty_i) 
                    tx_state_next = TX_FBC_START;
            end
            else if(encode_w_data_out_en_i)
                tx_state_next = TX_ENCODE;
        end

        TX_ENCODE: begin
            if(tx_tlast)
                tx_state_next = TX_ENCODE_WITE; 
        end

        TX_FBC_START: begin
            if(tx_tlast)
                tx_state_next = TX_FBC_START_DELAY;
        end

        TX_FBC_START_DELAY: begin
            if(fbc_delay_cnt == 'd1000)
                tx_state_next = TX_FBC_WITE;
        end

        TX_FBC_WITE: begin
            if(~aurora_fbc_empty_i && aurora_fbc_end_i)
                tx_state_next = TX_FBC;
            else if(aurora_fbc_empty_i && aurora_fbc_end_i)
                tx_state_next = TX_FBC_END_DELAY;
            else if(aurora_fbc_count_i >= 'd1000)
                tx_state_next = TX_FBC;
        end

        TX_FBC: begin
            if(tx_tlast)begin
                if(aurora_fbc_end_i && aurora_fbc_empty_i)
                    tx_state_next = TX_FBC_END_DELAY;
                else 
                    tx_state_next = TX_FBC_WITE;
            end
        end

        TX_FBC_END_DELAY: begin
            if(fbc_delay_cnt == 'd1000)
                tx_state_next = TX_FBC_END;
        end

        TX_FBC_END: begin
            if(tx_tlast)
                tx_state_next = TX_IDLE;
        end

        default:tx_state_next = TX_IDLE;
    endcase
end

// eds 开始前清除buffer
always @(posedge USER_CLK) begin
    if(tx_state==TX_PCIE_WITE)
        eds_tx_delay_cnt <= #TCQ eds_tx_delay_cnt + 1;
    else 
        eds_tx_delay_cnt <= #TCQ 'd0;
end

// fbc 开始前delay, 错开end的延迟
always @(posedge USER_CLK) begin
    if(tx_state==TX_FBC_START_DELAY || tx_state==TX_FBC_END_DELAY)
        fbc_delay_cnt <= #TCQ fbc_delay_cnt + 1;
    else 
        fbc_delay_cnt <= 'd0;
end

// tx count
always @(posedge USER_CLK) begin
    if(tx_state==TX_EDS_START || tx_state==TX_EDS_END || tx_state==TX_EDS_DATA || tx_state==TX_ENCODE || tx_state==TX_FBC || tx_state==TX_FBC_START || tx_state==TX_FBC_END)begin
        if(tx_tlast)
            len_cnt <= #TCQ 'd0;
        else if(tx_tvalid)
            len_cnt <= #TCQ len_cnt + 1;
    end
    else begin
        len_cnt <= #TCQ 'd0;
    end
end

always @(posedge USER_CLK) begin
    if(tx_state==TX_IDLE)
        pcie_eds_frame_end_flag <= #TCQ 'd0;
    else if(pcie_eds_frame_end_i)
        pcie_eds_frame_end_flag <= #TCQ 'd1;
end


always @(posedge USER_CLK) begin
    if(tx_state==TX_IDLE)
        eds_last_package <= #TCQ 'd0;
    else if(tx_state==TX_EDS_WITE && tx_state_next==TX_EDS_END)
        eds_last_package <= #TCQ 'd1;
end

always @(posedge USER_CLK) begin
    if(tx_state==TX_IDLE)
        frame_cnt <= #TCQ 'd0;
    else if(tx_state==TX_EDS_DATA && tx_tlast)
        frame_cnt <= #TCQ frame_cnt + 1;
end

always @(posedge USER_CLK) begin
    aurora_fbc_end_d    <= #TCQ aurora_fbc_end_i;
    aurora_fbc_empty_d  <= #TCQ aurora_fbc_empty_i;
end

always @(*)
begin
    if(tx_state==TX_EDS_START || tx_state==TX_EDS_DATA || tx_state==TX_EDS_END || tx_state==TX_ENCODE || tx_state==TX_FBC || tx_state==TX_FBC_START || tx_state==TX_FBC_END)
        tx_tvalid = tx_tready;
    else
        tx_tvalid = 1'b0;
end

always @(*)
begin
    if((tx_state == TX_EDS_START)) begin
        if(len_cnt == 'd0) begin
            tx_data = 32'h55aa_0001;    
        end
        else if(len_cnt == 'd1) begin
            tx_data = 32'h0000_0001;    //EDS包开始
        end
        else begin
            tx_data = 'd0;
        end
    end
    else if((tx_state == TX_EDS_DATA)) begin
        if(len_cnt == 'd0) begin
            tx_data = 32'h55aa_0002;    //EDS包数据帧类型
        end
        else if(len_cnt == 'd1) begin
            tx_data = frame_cnt;
        end
        else if(len_cnt == 'd2) begin
            tx_data = encode_x_data_out_i;        //x encoder
        end
        else if(len_cnt == 'd3) begin
            tx_data = encode_w_data_out_i;        //w encoder
        end
        else begin
            tx_data = eds_to_aurora_txdata_i;
        end
    end
    else if((tx_state == TX_EDS_END)) begin
        if(len_cnt == 'd0) begin
            tx_data = 32'h55aa_0001;
        end
        else if(len_cnt == 'd1) begin
            tx_data = 32'h0000_0000;    //EDS包结束
        end
        else begin
            tx_data = 'd0;
        end
    end
    else if((tx_state==TX_ENCODE)) begin
        if(len_cnt == 'd0) begin
            tx_data = 32'h55aa_0003;
        end
        else if(len_cnt == 'd1) begin
            tx_data = encode_x_data_out_i;        //x encoder
        end
        else if(len_cnt == 'd2) begin
            tx_data = encode_w_data_out_i;        //w encoder
        end
        else begin
            tx_data = 'd0;
        end
    end
    else if((tx_state==TX_FBC)) begin
        if(len_cnt == 'd0) begin
            tx_data = 32'h55aa_0004;
        end
        else if(aurora_fbc_empty_d)begin
            tx_data = 32'h0;
        end
        else begin
            tx_data = aurora_fbc_data_i;
        end
    end
    else if((tx_state==TX_FBC_START)) begin
        if(len_cnt == 'd0) begin
            tx_data = 32'h55aa_0001;
        end
        else if(len_cnt == 'd1) begin
            tx_data = 32'h0000_0002;    //FBC包开始
        end
        else begin
            tx_data = 'd0;
        end
    end
    else if((tx_state==TX_FBC_END)) begin
        if(len_cnt == 'd0) begin
            tx_data = 32'h55aa_0001;
        end
        else if(len_cnt == 'd1) begin
            tx_data = 32'h0000_0003;    //FBC包结束
        end
        else begin
            tx_data = 'd0;
        end
    end
    else begin
        tx_data = 'd0;
    end
end

always @(*)
begin
    if((tx_state == TX_EDS_START) && (len_cnt == 'd1))
        tx_tlast = tx_tready;
    else if((tx_state == TX_EDS_DATA) && (len_cnt == EDS_PACKAGE_LENG))
        tx_tlast = tx_tready;
    else if((tx_state == TX_EDS_END) && (len_cnt == 'd1))
        tx_tlast = tx_tready;
    else if((tx_state == TX_ENCODE) && (len_cnt == 'd2))
        tx_tlast = tx_tready;
    else if((tx_state == TX_FBC) && (len_cnt == 'd1024))
        tx_tlast = tx_tready;
    else if((tx_state == TX_FBC_START) && (len_cnt == 'd1))
        tx_tlast = tx_tready;
    else if((tx_state == TX_FBC_END) && (len_cnt == 'd1))
        tx_tlast = tx_tready;
    else
        tx_tlast = 1'b0;
end   

assign clear_eds_buffer_o   = (tx_state==TX_PCIE_WITE) && (eds_tx_delay_cnt < 'd20);
assign eds_to_aurora_txen_o = ((tx_state == TX_EDS_DATA) && (len_cnt >= 'd4)) ? tx_tvalid : 1'b0;
assign tx_tkeep             = 4'b1111;
assign aurora_fbc_en_o      = ((tx_state == TX_FBC) && (len_cnt >= 'd1)) ? tx_tvalid : 1'b0;


endmodule
