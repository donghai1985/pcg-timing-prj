
`timescale 1 ns / 1 ps

//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/10/10
// Design Name: PCG
// Module Name: aurora_64b66b_rx
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


module aurora_64b66b_rx #(
    parameter                   TCQ             = 0.1
)(
    
    output                  pcie_eds_end_o                  ,
    output                  pcie_pmt_end_o                  ,
    
    // System Interface
    input                   USER_CLK                        ,      
    input                   RESET                           ,
    input                   CHANNEL_UP                      ,

    input                   rx_tvalid_i                     ,
    input   [64-1:0]        rx_tdata_i                      ,
    input   [8-1:0]         rx_tkeep_i                      ,
    input                   rx_tlast_i                      
);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

localparam          RX_IDLE             = 'd0;   // FSM IDLE
localparam          RX_CHECK            = 'd1;   // FSM CHECK END

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

reg     [1-1:0]     rx_state            = RX_IDLE;
reg     [1-1:0]     rx_next_state       = RX_IDLE;

reg     [4:0]       channel_up_cnt      = 'd0;
reg     [15:0]      len_cnt             = 'd0;
reg     [31:0]      frame_cnt           = 'd0;
reg                 pmt_rx_end_pulse    = 'd0;
reg                 eds_rx_end_pulse    = 'd0;

reg                 erase_multiboot     = 'd0;
reg                 startup_rst         = 'd0;
reg                 startup_finish      = 'd0;
reg                 startup             = 'd0;
reg     [31:0]      startup_pack_cnt    = 'd0;
reg                 startup_vld         = 'd0;
reg     [31:0]      startup_data        = 'd0;
reg                 read_flash          = 'd0;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                reset_c                         ;
wire                dly_data_xfer                   ;
wire                eds_frame_pose                  ;
wire                pmt_start_pose                  ;
wire                wait_fbc_timeout                ;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
widen_enable #(
    .WIDEN_TYPE         ( 1                         ),  // 1 = posedge lock
    .WIDEN_NUM          ( 20                        )
)pcie_eds_end_inst(
    .clk_i              ( USER_CLK                  ),
    .rst_i              ( reset_c                   ),

    .src_signal_i       ( eds_rx_end_pulse          ),
    .dest_signal_o      ( pcie_eds_end_o            )    
);

widen_enable #(
    .WIDEN_TYPE         ( 1                         ),  // 1 = posedge lock
    .WIDEN_NUM          ( 20                        )
)pcie_pmt_end_inst(
    .clk_i              ( USER_CLK                  ),
    .rst_i              ( reset_c                   ),

    .src_signal_i       ( pmt_rx_end_pulse          ),
    .dest_signal_o      ( pcie_pmt_end_o            )    
);
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

always @(posedge USER_CLK) begin
    if(reset_c)
        rx_state <= #TCQ RX_IDLE;
    else 
        rx_state <= #TCQ rx_next_state;
end

always @(*) begin
    rx_next_state = rx_state;
    case (rx_state)
        RX_IDLE: begin
            if(rx_tvalid_i && rx_tdata_i[31:0] == 32'h55aa_0001)
                rx_next_state = RX_CHECK;
        end
        
        RX_CHECK: begin
            if(rx_tvalid_i && rx_tlast_i)
                rx_next_state = RX_IDLE;
        end

        default: rx_next_state = RX_IDLE;
    endcase
end

// pmt/eds end singal, delay 10 clk
always @(posedge USER_CLK) begin
    if(rx_state==RX_CHECK)begin
        if(rx_tvalid_i && rx_tlast_i && len_cnt=='d0)begin
            eds_rx_end_pulse <= #TCQ (rx_tdata_i[7:0]=='d1);
            pmt_rx_end_pulse <= #TCQ (rx_tdata_i[7:0]=='d2); 
        end
        else begin
            eds_rx_end_pulse <= #TCQ 'd0;
            pmt_rx_end_pulse <= #TCQ 'd0;
        end
    end
    else begin
            eds_rx_end_pulse <= #TCQ 'd0;
            pmt_rx_end_pulse <= #TCQ 'd0;
    end
end
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
