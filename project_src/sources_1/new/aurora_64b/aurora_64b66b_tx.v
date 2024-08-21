
`timescale 1 ns / 1 ps

//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/10/10
// Design Name: PCG
// Module Name: aurora_64b66b_tx
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


module aurora_64b66b_tx #(
    parameter                   TCQ             = 0.1
)(
    // eds
    input                   eds_frame_en_i                  ,
    output                  aurora_eds_end_o                ,
    output                  eds_tx_en_o                     ,
    input   [64-1:0]        eds_tx_data_i                   ,
    input                   eds_tx_prog_empty_i             ,

    input                   eds_encode_empty_i              ,
    output                  eds_encode_en_o                 ,
    input   [32-1:0]        precise_encode_w_data_i         ,
    input   [32-1:0]        precise_encode_x_data_i         ,

    // pmt encode
    input                   pmt_start_en_i                  ,
    output                  aurora_scan_end_o               ,
    output                  encode_tx_en_o                  ,
    input   [64-1:0]        encode_tx_data_i                ,
    input                   encode_tx_prog_empty_i          ,

    // FBC 
    input                   fbc_up_start_i                  ,
    output                  aurora_fbc_end_o                ,
    output                  aurora_fbc_en_o                 ,
    input   [64-1:0]        aurora_fbc_data_i               ,
    input                   aurora_fbc_prog_empty_i         ,
    input                   aurora_fbc_empty_i              ,

    input                   aurora_scan_reset_i             ,
    output                  aurora_tx_idle_o                ,
    output  [32-1:0]        eds_pack_cnt_o                  ,
    output  [32-1:0]        encode_pack_cnt_o               ,
    
    // System Interface
    input                   USER_CLK                        ,
    input                   RESET                           ,
    input                   CHANNEL_UP                      ,
    
    output                  tx_tvalid_o                     ,
    output  [64-1:0]        tx_tdata_o                      ,
    output  [8-1:0]         tx_tkeep_o                      ,
    output                  tx_tlast_o                      ,
    input                   tx_tready_i                     
);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam                  TX_IDLE             = 'd0       ;
localparam                  TX_EDS_START        = 'd1       ;
localparam                  TX_EDS_WITE         = 'd2       ;
localparam                  TX_EDS_DATA         = 'd3       ;
localparam                  TX_EDS_END          = 'd4       ;
localparam                  TX_EDS_RESET        = 'd5       ;
localparam                  TX_ENCODE_START     = 'd6       ;
localparam                  TX_ENCODE_WITE      = 'd7       ;
localparam                  TX_ENCODE_DATA      = 'd8       ;
localparam                  TX_ENCODE_END       = 'd9       ;
localparam                  TX_ENCODE_RESET     = 'd10      ;
localparam                  TX_FBC_START        = 'd11      ;
localparam                  TX_FBC_WITE         = 'd12      ;
localparam                  TX_FBC_DATA         = 'd13      ;
localparam                  TX_FBC_END          = 'd14      ;
localparam                  TX_FBC_RESET        = 'd15      ;

localparam                  EDS_LINE_LENGTH     = 'd512 + 1 ;
localparam                  RESET_DELAY_WID     = 'd8 ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

reg     [4-1:0]             tx_state            = TX_IDLE   ;
reg     [4-1:0]             tx_state_next       = TX_IDLE   ;
reg     [4:0]               channel_up_cnt      = 'd0       ;

reg     [15:0]              len_cnt             = 'd0       ;

reg     [7:0]               eds_delay_cnt       = 'd0       ;
reg                         eds_frame_en_d0     = 'd0       ;
reg                         eds_frame_en_d1     = 'd0       ;

reg     [RESET_DELAY_WID:0] rst_delay_cnt       = 'd0       ;
reg                         pmt_start_en_d0     = 'd0       ;
reg                         pmt_start_en_d1     = 'd0       ;

reg     [9:0]               fbc_delay_cnt       = 'd0       ;
reg                         fbc_up_start_d0     = 'd0       ;
reg                         fbc_up_start_d1     = 'd0       ;
reg                         aurora_fbc_empty_d  = 'd0       ;

reg                         tx_tvalid           = 'd0       ;
reg     [63:0]              tx_tdata            = 'd0       ;  
reg                         tx_tlast            = 'd0       ; 

reg                         aurora_eds_end      = 'd0       ;
reg                         aurora_scan_end     = 'd0       ;
reg                         aurora_fbc_end      = 'd0       ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                        reset_c                         ;
wire                        dly_data_xfer                   ;
wire                        eds_frame_pose                  ;
wire                        pmt_start_pose                  ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

always @ (posedge USER_CLK)begin
    if(RESET)
        channel_up_cnt <= #TCQ 'd0;
    else if(CHANNEL_UP)
        if(channel_up_cnt[4])
            channel_up_cnt <= #TCQ channel_up_cnt;
        else 
            channel_up_cnt <= #TCQ channel_up_cnt + 1'b1;
    else
        channel_up_cnt <= #TCQ 'd0;
end

assign dly_data_xfer = channel_up_cnt[4];

//Generate RESET signal when Aurora channel is not ready
assign reset_c = !dly_data_xfer;

//EDS包帧长为帧头64bit + 64bit X/W encoder数据 + 1024*32bit,
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
always @ (posedge USER_CLK)begin
    fbc_up_start_d0 <= #TCQ fbc_up_start_i;
    fbc_up_start_d1 <= #TCQ fbc_up_start_d0;
end

// assign pmt_start_pose   = pmt_start_en_d0 && (~pmt_start_en_d1);
// assign eds_frame_pose   = eds_frame_en_d0 && (~eds_frame_en_d1);

always @(posedge USER_CLK) begin
    if(reset_c)
        tx_state <= #TCQ TX_IDLE;
    else if(aurora_scan_reset_i)
        tx_state <= #TCQ TX_IDLE;
    else 
        tx_state <= #TCQ tx_state_next;
end

always @(*) begin
    tx_state_next = tx_state;
    case(tx_state)
        TX_IDLE: begin
            if(eds_frame_en_d0)
                tx_state_next = TX_EDS_START;
            else if(pmt_start_en_d0)
                tx_state_next = TX_ENCODE_START;
            else if(fbc_up_start_d0)
                tx_state_next = TX_FBC_START;
        end 

        TX_EDS_START: begin
            if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_state_next = TX_EDS_WITE; 
        end

        TX_EDS_WITE: begin
            if(~eds_frame_en_d1)
                tx_state_next = TX_EDS_END;
            else if((~eds_tx_prog_empty_i) && (~eds_encode_empty_i))
                tx_state_next = TX_EDS_DATA;
        end

        TX_EDS_DATA: begin
            if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_state_next = TX_EDS_WITE; 
        end

        TX_EDS_END: begin
            if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_state_next = TX_EDS_RESET; 
        end

        TX_EDS_RESET: begin
            if(rst_delay_cnt[RESET_DELAY_WID])
                tx_state_next = TX_IDLE;
        end


        TX_ENCODE_START: begin
            if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_state_next = TX_ENCODE_WITE; 
        end

        TX_ENCODE_WITE: begin
            if(~pmt_start_en_d0)
                tx_state_next = TX_ENCODE_END;
            else if(~encode_tx_prog_empty_i)
                tx_state_next = TX_ENCODE_DATA;
        end
        
        TX_ENCODE_DATA: begin
            if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_state_next = TX_ENCODE_WITE; 
        end
     
        TX_ENCODE_END: begin
            if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_state_next = TX_ENCODE_RESET; 
        end

        TX_ENCODE_RESET: begin
            if(rst_delay_cnt[RESET_DELAY_WID])
                tx_state_next = TX_IDLE;
        end


        TX_FBC_START: begin
            if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_state_next = TX_FBC_WITE;
        end

        TX_FBC_WITE: begin
            if(~fbc_up_start_d0)
                tx_state_next = TX_FBC_END;
            else if(~aurora_fbc_prog_empty_i)
                tx_state_next = TX_FBC_DATA;
        end

        TX_FBC_DATA: begin
            if(tx_tlast && tx_tvalid && tx_tready_i)begin
                // if(aurora_fbc_empty_i && (~fbc_up_start_d0))
                //     tx_state_next = TX_FBC_END;
                // else 
                    tx_state_next = TX_FBC_WITE;
            end
        end

        TX_FBC_END: begin
            if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_state_next = TX_FBC_RESET;
        end

        TX_FBC_RESET: begin
            if(rst_delay_cnt[RESET_DELAY_WID])
                tx_state_next = TX_IDLE;
        end

        default:tx_state_next = TX_IDLE;
    endcase
end

// 加延迟目的是给pcie光纤卡清buffer预留时间
// always @(posedge USER_CLK) begin
//     if(tx_state==TX_PCIE_WITE)
//         eds_delay_cnt <= #TCQ eds_delay_cnt + 1;
//     else 
//         eds_delay_cnt <= #TCQ 'd0;
// end

// tx结束，清除缓存
always @(posedge USER_CLK) begin
    if(tx_state==TX_ENCODE_RESET || tx_state==TX_EDS_RESET || tx_state==TX_FBC_RESET)
        rst_delay_cnt <= #TCQ rst_delay_cnt + 1;
    else 
        rst_delay_cnt <= #TCQ 'd0;
end

// fbc 开始前delay, 错开scan end的延迟
// always @(posedge USER_CLK) begin
//     if(tx_state==TX_FBC_START_DELAY)
//         fbc_delay_cnt <= #TCQ fbc_delay_cnt + 1;
//     else 
//         fbc_delay_cnt <= #TCQ 'd0;
// end

// always @(posedge USER_CLK) begin
//     aurora_fbc_empty_d  <= #TCQ aurora_fbc_empty_i;
// end


wire tx_state_flag ;
assign tx_state_flag =  tx_state==TX_EDS_START || tx_state==TX_EDS_DATA || tx_state==TX_EDS_END 
                     || tx_state==TX_ENCODE_START || tx_state==TX_ENCODE_DATA || tx_state==TX_ENCODE_END
                     || tx_state==TX_FBC_START || tx_state==TX_FBC_DATA || tx_state==TX_FBC_END;

// tx count
always @(posedge USER_CLK) begin
    if(tx_state_flag)begin
        if(tx_tlast && tx_tvalid && tx_tready_i)
            len_cnt <= #TCQ 'd0;
        else if(tx_tready_i && tx_tvalid)
            len_cnt <= #TCQ len_cnt + 1;
    end
    else begin
        len_cnt <= #TCQ 'd0;
    end
end

always @(posedge USER_CLK)begin
    if(tx_state_flag)begin
        if(tx_tlast && tx_tvalid && tx_tready_i)
            tx_tvalid <= #TCQ 'd0;
        else 
            tx_tvalid <= #TCQ tx_tready_i;
    end
    else begin
        tx_tvalid <= #TCQ 1'b0;
    end
end

always @(posedge USER_CLK)
begin
    case (tx_state)
        TX_EDS_START: begin
            if(tx_tvalid && tx_tready_i)begin
                if(len_cnt == 'd0) begin
                    tx_tdata <= #TCQ 'h55aa_0001;    
                end
                else if(len_cnt == 'd1) begin
                    tx_tdata <= #TCQ 'h0000_0001;    //EDS包开始
                end
            end
        end 

        TX_EDS_DATA: begin
            if(tx_tvalid && tx_tready_i)begin
                if(len_cnt == 'd0) begin
                    tx_tdata <= #TCQ 'h55aa_0002;    //EDS包数据帧类型
                end
                else if(len_cnt == 'd1) begin
                    tx_tdata <= #TCQ {precise_encode_w_data_i,precise_encode_x_data_i};        //encoder
                end
                else begin
                    tx_tdata <= #TCQ eds_tx_data_i;
                end
            end
        end

        TX_EDS_END: begin
            if(tx_tvalid && tx_tready_i)begin
                if(len_cnt == 'd0) begin
                    tx_tdata <= #TCQ 'h55aa_0001;
                end
                else if(len_cnt == 'd1) begin
                    tx_tdata <= #TCQ 'h0000_0000;    //EDS包结束
                end
            end
        end

        TX_ENCODE_START: begin
            if(tx_tvalid && tx_tready_i)begin
                if(len_cnt == 'd0) begin
                    tx_tdata <= #TCQ 'h55aa_0001;    
                end
                else if(len_cnt == 'd1) begin
                    tx_tdata <= #TCQ 'd4;           // PMT 包开始
                end
            end
        end 

        TX_ENCODE_DATA: begin
            if(tx_tvalid && tx_tready_i)begin
                if(len_cnt == 'd0) begin
                    tx_tdata <= #TCQ 'h55aa_0003;
                end
                else begin
                    tx_tdata <= #TCQ encode_tx_data_i;        //pmt encoder
                end
            end
        end

        TX_ENCODE_END: begin
            if(tx_tvalid && tx_tready_i)begin
                if(len_cnt == 'd0) begin
                    tx_tdata <= #TCQ 'h55aa_0001;
                end
                else if(len_cnt == 'd1) begin
                    tx_tdata <= #TCQ 'd5;                   //PMT包结束
                end
            end
        end

        TX_FBC_DATA: begin
            if(tx_tvalid && tx_tready_i)begin
                if(len_cnt == 'd0) begin
                    tx_tdata <= #TCQ 'h55aa_0004;
                end
                else if(aurora_fbc_empty_i)begin
                    tx_tdata <= #TCQ 'h0;
                end
                else begin
                    tx_tdata <= #TCQ aurora_fbc_data_i;
                end
            end
        end

        TX_FBC_START: begin
            if(tx_tvalid && tx_tready_i)begin
                if(len_cnt == 'd0) begin
                    tx_tdata <= #TCQ 'h55aa_0001;
                end
                else if(len_cnt == 'd1) begin
                    tx_tdata <= #TCQ 'h0000_0002;    //FBC包开始
                end
            end
        end

        TX_FBC_END: begin
            if(tx_tvalid && tx_tready_i)begin
                if(len_cnt == 'd0) begin
                    tx_tdata <= #TCQ 'h55aa_0001;
                end
                else if(len_cnt == 'd1) begin
                    tx_tdata <= #TCQ 'h0000_0003;    //FBC包结束
                end
            end
        end
        default: /*default*/;
    endcase
end

always @(posedge USER_CLK)
begin
    case (tx_state)
        TX_EDS_START: begin
            if(len_cnt == 'd1)
                tx_tlast <= #TCQ tx_tready_i && tx_tvalid;
            else if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_tlast <= #TCQ 'd0;
        end
        TX_EDS_DATA: begin
            if(len_cnt == EDS_LINE_LENGTH)
                tx_tlast <= #TCQ tx_tready_i && tx_tvalid;
            else if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_tlast <= #TCQ 'd0;
        end
        TX_EDS_END: begin
            if(len_cnt == 'd1)
                tx_tlast <= #TCQ tx_tready_i && tx_tvalid;
            else if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_tlast <= #TCQ 'd0;
        end

        TX_ENCODE_START: begin
            if(len_cnt == 'd1)
                tx_tlast <= #TCQ tx_tready_i && tx_tvalid;
            else if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_tlast <= #TCQ 'd0;
        end
        TX_ENCODE_DATA: begin
            if(len_cnt == 'd512)
                tx_tlast <= #TCQ tx_tready_i && tx_tvalid;
            else if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_tlast <= #TCQ 'd0;
        end
        TX_ENCODE_END: begin
            if(len_cnt == 'd1)
                tx_tlast <= #TCQ tx_tready_i && tx_tvalid;
            else if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_tlast <= #TCQ 'd0;
        end

        TX_FBC_DATA: begin
            if(len_cnt == 'd512)
                tx_tlast <= #TCQ tx_tready_i && tx_tvalid;
            else if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_tlast <= #TCQ 'd0;
        end
        TX_FBC_START: begin
            if(len_cnt == 'd1)
                tx_tlast <= #TCQ tx_tready_i && tx_tvalid;
            else if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_tlast <= #TCQ 'd0;
        end
        TX_FBC_END: begin
            if(len_cnt == 'd1)
                tx_tlast <= #TCQ tx_tready_i && tx_tvalid;
            else if(tx_tlast && tx_tvalid && tx_tready_i)
                tx_tlast <= #TCQ 'd0;
        end
        default: tx_tlast <= #TCQ 1'b0;
    endcase
end   

always @(posedge USER_CLK) aurora_scan_end  <= #TCQ (tx_state==TX_ENCODE_RESET);
always @(posedge USER_CLK) aurora_fbc_end   <= #TCQ (tx_state==TX_FBC_RESET);
always @(posedge USER_CLK) aurora_eds_end   <= #TCQ (tx_state==TX_EDS_RESET);

assign eds_encode_en_o      = ((tx_state == TX_EDS_DATA) && (len_cnt == 'd0)) ? (tx_tready_i && tx_tvalid && (~tx_tlast)) : 1'b0;
assign eds_tx_en_o          = ((tx_state == TX_EDS_DATA) && (len_cnt >= 'd2)) ? (tx_tready_i && tx_tvalid && (~tx_tlast)) : 1'b0;
assign encode_tx_en_o       = ((tx_state == TX_ENCODE_DATA) && (len_cnt >= 'd1) ) ? (tx_tready_i && tx_tvalid && (~tx_tlast)) : 1'b0;
assign aurora_fbc_en_o      = ((tx_state == TX_FBC_DATA) && (len_cnt >= 'd1) ) ? (tx_tready_i && tx_tvalid && (~tx_tlast)) : 1'b0;

assign aurora_scan_end_o    = aurora_scan_end;
assign aurora_fbc_end_o     = aurora_fbc_end;
assign aurora_eds_end_o     = aurora_eds_end;
assign aurora_tx_idle_o     = tx_state==TX_IDLE;

assign tx_tvalid_o          = tx_tvalid && (|len_cnt);
assign tx_tdata_o           = tx_tdata;  
assign tx_tkeep_o           = 8'hFF;
assign tx_tlast_o           = tx_tlast; 


// check eds pack number
reg [32-1:0] eds_pack_cnt = 'd0;
reg [32-1:0] encode_pack_cnt = 'd0;

always @(posedge USER_CLK) begin
    if(tx_state==TX_EDS_START)
        eds_pack_cnt <= #TCQ 'd0;
    else if(tx_state==TX_EDS_WITE && tx_state_next==TX_EDS_DATA)begin
        if(eds_pack_cnt[31])
            eds_pack_cnt <= #TCQ eds_pack_cnt;
        else 
            eds_pack_cnt <= #TCQ eds_pack_cnt + 1;
    end
end


always @(posedge USER_CLK) begin
    if(tx_state==TX_ENCODE_START)
        encode_pack_cnt <= #TCQ 'd0;
    else if(tx_state==TX_ENCODE_WITE && tx_state_next==TX_ENCODE_DATA)begin
        if(encode_pack_cnt[31])
            encode_pack_cnt <= #TCQ encode_pack_cnt;
        else 
            encode_pack_cnt <= #TCQ encode_pack_cnt + 1;
    end
end

assign eds_pack_cnt_o    = eds_pack_cnt;
assign encode_pack_cnt_o = encode_pack_cnt;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
