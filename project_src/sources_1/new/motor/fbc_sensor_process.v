`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: songyuxin
// 
// Create Date: 2023/6/27
// Design Name: PCG_timing
// Module Name: fbc_sensor_process
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

module fbc_sensor_process#(
    parameter                   TCQ             = 0.1
)(
    input   wire                clk_sys_i                   ,
    input   wire                clk_h_i                     ,
    input   wire                rst_i                       ,

    // control command
    input   wire                cfg_fbc_rate_i              ,
    input   wire    [2:0]       data_acq_en_i               , // motor enable signal
    input   wire                bg_data_acq_en_i            , // background sample. pulse
    input   wire                position_cali_en_i          , // test
    input   wire    [1:0]       sensor_mode_sel_i           ,
    input   wire    [11-1:0]    sensor_ds_rate_i            ,

    // calibrate voltage. dark current * R
    output  wire                cali_data_en_o              ,
    output  wire    [23:0]      cali_data_a_o               ,
    output  wire    [23:0]      cali_data_b_o               ,
    
    // actual voltage
    output  wire                data_out_en_o               ,
    output  wire    [23:0]      data_out_a_o                ,
    output  wire    [23:0]      data_out_b_o                ,

    // background voltage. dark current * R
    output  wire                bg_data_en_o                ,
    output  wire    [23:0]      bg_data_a_o                 ,
    output  wire    [23:0]      bg_data_b_o                 ,

    output  wire                fbc_cache_vld_o             ,
    output  wire    [48-1:0]    fbc_cache_data_o            ,
    output  wire                pid_postion_vld_o           ,
    output  wire    [48-1:0]    pid_postion_data_o          ,
    // sensor spi info
    output  wire                MSPI_CLK                    ,
    output  wire                MSPI_MOSI                   ,
    input   wire                SSPI_CLK                    ,
    input   wire                SSPI_MISO                   
);
//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam                              SPI_CLK_DIVIDER         = 6  ; // SPI Clock Control / Divid
localparam                              SPI_MASTER_WIDTH        = 64 ; // master spi data width
localparam                              SPI_SLAVE_WIDTH         = 48 ; // slave spi data width

localparam                              ST_IDLE                 = 3'd0;
localparam                              BG_WAIT                 = 3'd1;
localparam                              BG_SUM                  = 3'd2;
localparam                              BG_AVG                  = 3'd3;
localparam                              CALI_WAIT               = 3'd4;
localparam                              CALI_SUM                = 3'd5;
localparam                              CALI_AVG                = 3'd6;
localparam                              ST_FINISH               = 3'd7;

`ifdef SIMULATE    // simulate use 100 us + 300us
localparam                              USELESS_LENGTH          = 16'd10; 
localparam                              BG_SUM_LENGTH           = 16'd30; 
localparam                              POSITION_SUM_LENGTH     = 16'd30; 
`else
localparam                              USELESS_LENGTH          = 16'd499;  // first 0.5s data is useless
localparam                              BG_SUM_LENGTH           = 16'd8191; // 8s
localparam                              POSITION_SUM_LENGTH     = 16'd8191; // 8s
`endif //SIMULATE
localparam                              SF_RATE                 = 7;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg         [2:0]                       bg_pos_state         = ST_IDLE;
reg         [2:0]                       bg_pos_state_next    = ST_IDLE;

reg                                     data_acq_en_d0          ;
reg                                     data_acq_en_d1          ;
reg                                     set_data_acq_en         = 'd0;
reg                                     mspi_wr_en              = 'd0;   
reg         [SPI_MASTER_WIDTH-1:0]      mspi_wr_data            = 'd0; 

reg         [16-1:0]                    state_data_cnt          = 'd0;
reg  signed [40-1:0]                    state_data_a_sum        = 'd0;
reg  signed [40-1:0]                    state_data_b_sum        = 'd0;
reg  signed [17-1:0]                    state_data_a_sum_l      = 'd0;
reg  signed [17-1:0]                    state_data_b_sum_l      = 'd0;
reg  signed [17-1:0]                    state_data_a_sum_h      = 'd0;
reg  signed [17-1:0]                    state_data_b_sum_h      = 'd0;

reg         [24-1:0]                    state_data_a_avg        = 'd0;
reg         [24-1:0]                    state_data_b_avg        = 'd0;
reg         [ 3-1:0]                    avg_beat                = 'd1;
reg                                     fbc_sensor_enable       = 'd0;

reg         [SPI_SLAVE_WIDTH-1:0]       filter_mem [0:127];
reg         [SF_RATE-1:0]               filter_cnt              = 'd0;
// reg         [SF_RATE-1:0]               filter_depth            = 'd0;
// reg         [2-1:0]                     sensor_ds_rate_d        = 'd0;
reg                                     filter_sum_flag         = 'd0;
reg         [24+SF_RATE-1:0]            rd_rx_data_a_sum        = 'd0;
reg         [24+SF_RATE-1:0]            rd_rx_data_b_sum        = 'd0;
reg         [SPI_SLAVE_WIDTH-1:0]       rd_rx_avg_data          = 'd0;
reg                                     rd_rx_avg_vld           = 'd0;
reg                                     rd_rx_avg_vld_d         = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                                    mspi_wr_en_h                ;
wire        [SPI_MASTER_WIDTH-1:0]      mspi_wr_data_h              ;

wire                                    sspi_rd_vld                 ;
wire        [SPI_SLAVE_WIDTH-1:0]       sspi_rd_data                ;
wire                                    sspi_rd_vld_sync            ;
wire        [SPI_SLAVE_WIDTH-1:0]       sspi_rd_data_sync           ;
wire                                    sspi_rd_avg_vld             ;
wire        [SPI_SLAVE_WIDTH-1:0]       sspi_rd_avg_data            ;
// wire                                    sspi_rd_avg_vld_sync        ;
// wire        [SPI_SLAVE_WIDTH-1:0]       sspi_rd_avg_data_sync       ;

// wire                                    sspi_rd_ds_vld              ;
// wire        [SPI_SLAVE_WIDTH-1:0]       sspi_rd_ds_data             ;

// wire        [2-1:0]                     sensor_mode_sel             ;
// wire        [11-1:0]                    sensor_ds_rate              ;
wire                                    pid_postion_vld             ;
wire        [SPI_SLAVE_WIDTH-1:0]       pid_postion_data            ;

wire                                    actual_data_vld             ;
wire signed [24-1:0]                    actual_data_a               ;
wire signed [24-1:0]                    actual_data_b               ;
// wire                                    data_out_en                 ;
// wire        [24-1:0]                    data_out_a                  ;
// wire        [24-1:0]                    data_out_b                  ;

// wire                                    bg_data_acq_en_sync         ;
// wire                                    position_cali_en_sync       ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
`ifdef SIMULATE
reg                             sspi_rd_vld_sim  = 'd0; 
reg  [SPI_SLAVE_WIDTH-1:0]      sspi_rd_data_sim = {24'd8192,24'd8192};
reg  [32-1:0]                   sim_cnt          = 'd0;
always @(posedge clk_sys_i) begin
    if(sim_cnt == 'd1_000)begin    // simulate 10 us
        sspi_rd_vld_sim <= #TCQ 'd1;
        sspi_rd_data_sim[23:0] <= #TCQ sspi_rd_data_sim[23:0] + 6 ;
        sspi_rd_data_sim[47:24] <= #TCQ sspi_rd_data_sim[47:24] + 2 ;
        sim_cnt <= #TCQ 'd0;
    end
    else begin
        sim_cnt <= #TCQ sim_cnt + 1;
        sspi_rd_vld_sim <= #TCQ 'd0;
    end
end
assign sspi_rd_avg_vld  = sspi_rd_vld_sim; 
assign sspi_rd_avg_data = sspi_rd_data_sim;

`else
bspi_ctrl #(
    .SPI_CLK_DIVIDER                ( SPI_CLK_DIVIDER       ), // SPI Clock Control / Divid
    .SPI_MASTER_WIDTH               ( SPI_MASTER_WIDTH      ), // master spi data width
    .SPI_SLAVE_WIDTH                ( SPI_SLAVE_WIDTH       )  // slave spi data width

)bspi_ctrl_inst(
    // clk & rst
    .clk_i                          ( clk_h_i               ),
    .rst_i                          ( rst_i                 ),
    
    // .sensor_ds_rate_i               ( sensor_ds_rate        ),

    .mspi_wr_en_i                   ( mspi_wr_en_h          ),
    .mspi_wr_data_i                 ( mspi_wr_data_h        ),
    .sspi_rd_vld_o                  ( sspi_rd_vld           ),
    .sspi_rd_data_o                 ( sspi_rd_data          ),
    // .sspi_rd_avg_vld_o              ( sspi_rd_avg_vld       ),
    // .sspi_rd_avg_data_o             ( sspi_rd_avg_data      ),
    // .sspi_rd_ds_vld_o               ( sspi_rd_ds_vld        ),
    // .sspi_rd_ds_data_o              ( sspi_rd_ds_data       ),
    // bspi info
    .MSPI_CLK                       ( MSPI_CLK              ),
    .MSPI_MOSI                      ( MSPI_MOSI             ),
    .SSPI_CLK                       ( SSPI_CLK              ),
    .SSPI_MISO                      ( SSPI_MISO             )
);
`endif //SIMULATE

handshake #(
    .TCQ                    ( TCQ                                   ),
    .DATA_WIDTH             ( SPI_SLAVE_WIDTH                       )
)fbc_rd_data_shake_inst(
    // clk & rst
    .src_clk_i              ( clk_h_i                               ),
    .src_rst_i              ( 'd0                                   ),
    .dest_clk_i             ( clk_sys_i                             ),
    .dest_rst_i             ( 'd0                                   ),
     

    .src_data_i             ( sspi_rd_data                          ),
    .src_vld_i              ( sspi_rd_vld                           ),

    .dest_data_o            ( sspi_rd_data_sync                     ),
    .dest_vld_o             ( sspi_rd_vld_sync                      )
);

handshake #(
    .TCQ                    ( TCQ                                   ),
    .DATA_WIDTH             ( SPI_MASTER_WIDTH                      )
)sensor_config_inst(
    // clk & rst
    .src_clk_i              ( clk_sys_i                             ),
    .src_rst_i              ( 'd0                                   ),
    .dest_clk_i             ( clk_h_i                               ),
    .dest_rst_i             ( 'd0                                   ),
     

    .src_data_i             ( mspi_wr_data                          ),
    .src_vld_i              ( mspi_wr_en                            ),

    .dest_data_o            ( mspi_wr_data_h                        ),
    .dest_vld_o             ( mspi_wr_en_h                          )
);
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// sensor spi tx
always @(posedge clk_sys_i)begin
    data_acq_en_d0  <= #TCQ (|data_acq_en_i)     ;
    data_acq_en_d1  <= #TCQ data_acq_en_d0       ;
end

always @(posedge clk_sys_i)begin
    set_data_acq_en <= #TCQ data_acq_en_d1 ^ data_acq_en_d0;
end

always @(posedge clk_sys_i) begin
    if(set_data_acq_en)begin
        mspi_wr_en <= #TCQ 'd1;
        mspi_wr_data <= #TCQ {16'h55aa,16'h0001,15'h0,data_acq_en_d1,16'd0};
    end
    else begin
        mspi_wr_en <= #TCQ 'd0;
    end
end

always @(posedge clk_sys_i) begin
    if(set_data_acq_en)
        fbc_sensor_enable <= #TCQ data_acq_en_d1;
end

// sensor spi rx average
// sliding filtering x128
always @(posedge clk_sys_i) begin
    if(rst_i)
        filter_cnt <= #TCQ 'd0;
    else if(sspi_rd_vld_sync)begin
        filter_cnt <= #TCQ filter_cnt + 1;
    end
end

always @(posedge clk_sys_i) begin
    if(sspi_rd_vld_sync)
        filter_mem[filter_cnt] <= #TCQ sspi_rd_data_sync;
end

always @(posedge clk_sys_i) begin
    if(rst_i)
        filter_sum_flag <= #TCQ 'd0;
    else if(sspi_rd_vld_sync && (&filter_cnt))
        filter_sum_flag <= #TCQ 'd1;
end

always @(posedge clk_sys_i) begin
    if(sspi_rd_vld_sync)begin
        if(filter_sum_flag)begin
            rd_rx_data_a_sum <= #TCQ rd_rx_data_a_sum + sspi_rd_data_sync[48-1:24] - filter_mem[filter_cnt][48-1:24];
            rd_rx_data_b_sum <= #TCQ rd_rx_data_b_sum + sspi_rd_data_sync[24-1:0] - filter_mem[filter_cnt][24-1:0];
        end
        else begin
            rd_rx_data_a_sum <= #TCQ rd_rx_data_a_sum + sspi_rd_data_sync[48-1:24];
            rd_rx_data_b_sum <= #TCQ rd_rx_data_b_sum + sspi_rd_data_sync[24-1:0];
        end
    end 
end

always @(posedge clk_sys_i) begin
    rd_rx_avg_vld   <= #TCQ sspi_rd_vld_sync && filter_sum_flag;
    rd_rx_avg_vld_d <= #TCQ rd_rx_avg_vld;
end

always @(posedge clk_sys_i) begin
    rd_rx_avg_data <= #TCQ {rd_rx_data_a_sum[24+SF_RATE-1 : SF_RATE],rd_rx_data_b_sum[24+SF_RATE-1 : SF_RATE]};
end

assign sspi_rd_avg_vld  = rd_rx_avg_vld_d;
assign sspi_rd_avg_data = rd_rx_avg_data;

// sensor spi rx
// sensor rx 1kHz output
// down sample x128
`ifdef SIMULATE
reg [1-1:0] down_sample_cnt = 'd0;
`else
reg [7-1:0] down_sample_cnt = 'd0;
`endif //SIMULATE
always @(posedge clk_sys_i) begin
    if(rst_i)
        down_sample_cnt <= #TCQ 'd0;
    else if(sspi_rd_avg_vld)
        down_sample_cnt <= #TCQ down_sample_cnt + 1;
end

assign actual_data_vld = cfg_fbc_rate_i ? sspi_rd_avg_vld && fbc_sensor_enable && (&down_sample_cnt)
                                            : sspi_rd_vld_sync && fbc_sensor_enable;

assign actual_data_a   = cfg_fbc_rate_i ? sspi_rd_avg_data[47:24]
                                            : sspi_rd_data_sync[47:24];

assign actual_data_b   = cfg_fbc_rate_i ? sspi_rd_avg_data[23:0]
                                            : sspi_rd_data_sync[23:0];


// background noise calculation
reg [1:0] actual_data_vld_d = 'd0;
always @(posedge clk_sys_i) begin
    actual_data_vld_d <= #TCQ {actual_data_vld_d[0],actual_data_vld};
end
wire [2:0] actual_data_vld_logic = {actual_data_vld_d,actual_data_vld};

// FSM control
always @(posedge clk_sys_i) begin
    if(rst_i)
        bg_pos_state <= #TCQ ST_IDLE;
    else 
        bg_pos_state <= #TCQ bg_pos_state_next;
end

always @(*) begin
    bg_pos_state_next = bg_pos_state;
    case (bg_pos_state)
        ST_IDLE: begin
            if(bg_data_acq_en_i)
                bg_pos_state_next = BG_WAIT;
            else if(position_cali_en_i && data_acq_en_i=='d3)
                bg_pos_state_next = CALI_WAIT;
        end

        BG_WAIT : begin
            if(actual_data_vld_logic[2] && (state_data_cnt == USELESS_LENGTH))
                bg_pos_state_next = BG_SUM;
        end

        BG_SUM: begin
            if(actual_data_vld_logic[2] && (state_data_cnt == USELESS_LENGTH + BG_SUM_LENGTH))
                bg_pos_state_next = BG_AVG;
        end
        BG_AVG: begin
            if(avg_beat[2])
                bg_pos_state_next = ST_FINISH;
        end
        
        CALI_WAIT : begin
            if(actual_data_vld_logic[2] && (state_data_cnt == USELESS_LENGTH))
                bg_pos_state_next = CALI_SUM;
        end

        CALI_SUM: begin
            if(actual_data_vld_logic[2] && (state_data_cnt == USELESS_LENGTH + BG_SUM_LENGTH))
                bg_pos_state_next = CALI_AVG;
        end
        CALI_AVG: begin
            if(avg_beat[2])
                bg_pos_state_next = ST_FINISH;
        end

        ST_FINISH : begin
            // if(~bg_data_acq_en_d1 && ~position_test_en_d1)
                bg_pos_state_next = ST_IDLE;
        end
        default: bg_pos_state_next = ST_IDLE;
    endcase
end

always @(posedge clk_sys_i) begin
    if(bg_pos_state==ST_IDLE || bg_pos_state==ST_FINISH)
        state_data_cnt <= #TCQ 'd0;
    else if(actual_data_vld)
        state_data_cnt <= #TCQ state_data_cnt + 1;
end

// calculate sum and average
always @(posedge clk_sys_i) begin
    case (bg_pos_state)
        ST_IDLE: begin
            state_data_a_sum <= #TCQ 'd0;
            state_data_b_sum <= #TCQ 'd0;
        end
        BG_SUM,
        CALI_SUM : begin
            if(actual_data_vld_logic[0])begin
                state_data_a_sum_l[16:0] <= #TCQ state_data_a_sum[15:0] + actual_data_a[15:0];
                state_data_b_sum_l[16:0] <= #TCQ state_data_b_sum[15:0] + actual_data_b[15:0];
            end
            else if(actual_data_vld_logic[1])begin
                state_data_a_sum_h[16:0] <= #TCQ state_data_a_sum[31:16] + {{'d8{actual_data_a[23]}},actual_data_a[23:16]} + state_data_a_sum_l[16];
                state_data_b_sum_h[16:0] <= #TCQ state_data_b_sum[31:16] + {{'d8{actual_data_b[23]}},actual_data_b[23:16]} + state_data_b_sum_l[16];
            end
            else if(actual_data_vld_logic[2])begin
                state_data_a_sum <= #TCQ {(state_data_a_sum[39:32] + {'d8{actual_data_a[23]}} + state_data_a_sum_h[16]),state_data_a_sum_h[15:0],state_data_a_sum_l[15:0]};
                state_data_b_sum <= #TCQ {(state_data_b_sum[39:32] + {'d8{actual_data_b[23]}} + state_data_b_sum_h[16]),state_data_b_sum_h[15:0],state_data_b_sum_l[15:0]};
            end
        end
        BG_AVG,
        CALI_AVG : begin
            if(avg_beat[0])begin
                state_data_a_sum <= #TCQ {{'d13{state_data_a_sum[39]}},state_data_a_sum[39:13]};
                state_data_b_sum <= #TCQ {{'d13{state_data_b_sum[39]}},state_data_b_sum[39:13]};
            end
            else if(avg_beat[1])begin
                state_data_a_avg <= #TCQ state_data_a_sum[23:0];
                state_data_b_avg <= #TCQ state_data_b_sum[23:0];
            end
        end
        default: /*default*/;
    endcase
end

always @(posedge clk_sys_i) begin
    if(bg_pos_state==ST_IDLE)
        avg_beat <= #TCQ 'd1;
    else if(bg_pos_state==BG_AVG || bg_pos_state==CALI_AVG)
        avg_beat <= #TCQ {avg_beat[1:0],1'b0};
end

assign data_out_en_o    = actual_data_vld;
assign data_out_a_o     = actual_data_a[23:0];
assign data_out_b_o     = actual_data_b[23:0];

assign bg_data_en_o     = avg_beat[2] && (bg_pos_state==BG_AVG);
assign bg_data_a_o      = state_data_a_avg[23:0];
assign bg_data_b_o      = state_data_b_avg[23:0];

assign cali_data_en_o   = avg_beat[2] && (bg_pos_state==CALI_AVG);
assign cali_data_a_o    = state_data_a_avg[23:0];
assign cali_data_b_o    = state_data_b_avg[23:0];

// pid actual postion
assign fbc_cache_vld_o    = sspi_rd_vld_sync && fbc_sensor_enable;
assign fbc_cache_data_o   = sspi_rd_data_sync;
assign pid_postion_vld_o  = sspi_rd_vld_sync && fbc_sensor_enable;
assign pid_postion_data_o = sspi_rd_data_sync;


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




endmodule