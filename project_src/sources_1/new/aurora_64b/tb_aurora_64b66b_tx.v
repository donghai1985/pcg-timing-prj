//~ `New testbench
`timescale  1ns / 1ps

module tb_aurora_64b66b_tx;

// aurora_64b66b_tx Parameters
parameter PERIOD = 10 ;
parameter TCQ  = 0.1;

reg clk_i = 0;
reg user_clk = 0;
reg rst_i = 0;
initial
begin
    forever #(PERIOD/2)  clk_i=~clk_i;
end
initial
begin
    forever #(3.31)  user_clk=~user_clk;
end

initial
begin
    #(PERIOD*2);
    rst_i  =  1;
    #(PERIOD*2);
    rst_i  =  0;
end

wire                    aurora_fbc_en           ;
wire    [64-1:0]        aurora_fbc_data         ;
wire                    aurora_fbc_full         ;
wire                    aurora_fbc_empty        ;
wire                    aurora_fbc_almost_full  ;
wire                    aurora_fbc_prog_empty   ;
wire                    aurora_fbc_end          ;

wire    [63:0]          tx_tdata                ; 
wire                    tx_tvalid               ;
wire    [7:0]           tx_tkeep                ;  
wire                    tx_tlast                ;

reg                     aurora_fbc_vout_vld     = 'd0;
reg     [64-1:0]        aurora_fbc_vout_data    = 'd0;
reg                     pmt_start_en            = 'd0;
reg                     fbc_up_start            = 'd0;
reg                     tx_tready               = 'd0;

widen_enable #(
    .WIDEN_TYPE                 ( 1                             ),  // 1 = posedge lock
    .WIDEN_NUM                  ( 15                            )
)fbc_fifo_rst_inst(
    .clk_i                      ( clk_i                         ),
    .rst_i                      ( rst_i                         ),

    .src_signal_i               ( pmt_start_en                  ),
    .dest_signal_o              ( fbc_fifo_wrst                 ) 
);

cache_rd_fifo fbc_to_aurora_fifo_inst(
    .rst                        ( fbc_fifo_wrst                 ),
    .wr_clk                     ( clk_i                         ),
    .rd_clk                     ( user_clk                      ),
    .din                        ( aurora_fbc_vout_data          ),
    .wr_en                      ( aurora_fbc_vout_vld           ),
    .rd_en                      ( aurora_fbc_en                 ),
    .dout                       ( aurora_fbc_data               ),
    .full                       ( aurora_fbc_full               ),
    .empty                      ( aurora_fbc_empty              ),
    // .almost_empty               ( aurora_fbc_almost_empty       ),  // flag indicating 1 word from empty
    .almost_full                ( aurora_fbc_almost_full        ),
    .prog_empty                 ( aurora_fbc_prog_empty         ),
    .wr_rst_busy                ( aurora_fbc_wr_rst_busy        ),  // output wire wr_rst_busy
    .rd_rst_busy                ( aurora_fbc_rd_rst_busy        )   // output wire rd_rst_busy
);

aurora_64b66b_tx aurora_64b66b_tx_inst(
    // FBC 
    .fbc_up_start_i             ( fbc_up_start                  ),
    .aurora_fbc_end_o           ( aurora_fbc_end                ),
    .aurora_fbc_en_o            ( aurora_fbc_en                 ),
    .aurora_fbc_data_i          ( aurora_fbc_data               ),
    .aurora_fbc_prog_empty_i    ( aurora_fbc_prog_empty         ),
    .aurora_fbc_empty_i         ( aurora_fbc_empty              ),
    
    // System Interface
    .USER_CLK                   ( user_clk                      ),
    .RESET                      ( 0                             ),
    .CHANNEL_UP                 ( 'd1                           ),
    
    .tx_tvalid_o                ( tx_tvalid                     ),
    .tx_tdata_o                 ( tx_tdata                      ),
    .tx_tkeep_o                 ( tx_tkeep                      ),
    .tx_tlast_o                 ( tx_tlast                      ),
    .tx_tready_i                ( tx_tready                     )
);

reg fbc_data_enable = 'd0;
always @(posedge clk_i) begin
    if(fbc_up_start && fbc_data_enable)begin
        aurora_fbc_vout_vld  <= #TCQ 'd1;
        aurora_fbc_vout_data <= #TCQ aurora_fbc_vout_data + 1;
    end
    else begin
        aurora_fbc_vout_vld  <= #TCQ 'd0;
        aurora_fbc_vout_data <= #TCQ 'd0;
    end
end

reg [4-1:0] tx_ready_sim_cnt = 'd0;
always @(posedge clk_i) begin
    if(tx_ready_sim_cnt[3])begin
        tx_ready_sim_cnt <= #TCQ 'd0;
        tx_tready <= #TCQ 'd0;
    end
    else begin
        tx_ready_sim_cnt <= #TCQ tx_ready_sim_cnt + 1;
        tx_tready <= #TCQ 'd1;
    end

end

initial
begin
    #1000;
    pmt_start_en = 1;
    #1000;
    pmt_start_en = 0;
    #1000;
    fbc_up_start = 1;
    fbc_data_enable = 1;
    #35000;
    fbc_data_enable = 0;
    fbc_up_start = 0;
    wait(aurora_fbc_end);
    $finish;
end

endmodule