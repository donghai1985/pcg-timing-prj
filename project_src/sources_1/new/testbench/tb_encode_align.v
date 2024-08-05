//~ `New testbench
`timescale  1ns / 1ps

module tb_encode_align;

// encode_align Parameters
parameter PERIOD = 10 ;
parameter TCQ  = 0.1;

// encode_align Inputs
reg   clk_i                                = 0 ;
reg   user_clk                                = 0 ;
reg   sys_clk_i                                = 0 ;
reg   rst_i                                = 0 ;
reg   precise_encode_en_i                  = 0 ;
reg   [32-1:0]  precise_encode_w_i         = 0 ;
reg   [32-1:0]  precise_encode_x_i         = 0 ;
reg   pmt_scan_en_i                        = 0 ;
reg   encode_sim_en                        = 0 ;

wire                    pmt_Wencode_align_rst   = 0;
wire signed   [32-1:0]  pmt_Wencode_align_set   = 500;
// wire                    pmt_Xencode_align_rst   = 0;
// wire signed   [32-1:0]  pmt_Xencode_align_set   = -500;
// wire                    eds_Wencode_align_rst   = 0;
// wire signed   [32-1:0]  eds_Wencode_align_set   = 400;
// wire                    eds_Xencode_align_rst   = 0;
// wire signed   [32-1:0]  eds_Xencode_align_set   = -400;

reg eds_scan_en_i = 'd0;
// encode_align Outputs
wire  pmt_encode_en_o                      ;
wire  [18-1:0]  pmt_encode_w_o             ;
wire  [18-1:0]  pmt_encode_x_o             ;
wire  eds_encode_en_o                      ;
wire  [32-1:0]  eds_encode_w_o             ;
wire  [32-1:0]  eds_encode_x_o             ;

wire                    eds_encode_rd_en        ;
wire                    eds_encode_full         ;
wire                    eds_encode_empty        ;
wire    [32-1:0]        precise_encode_w_data   ;
wire    [32-1:0]        precise_encode_x_data   ;

wire                    eds_rx_start            ;
wire                    eds_rx_end              ;
wire                    fbc_rx_start            ;
wire                    fbc_rx_end              ;

wire                    tx_tvalid;
wire    [64-1:0]        tx_tdata ;
wire    [8-1:0]         tx_tkeep ;
wire                    tx_tlast ;

wire             eds_rx_start_o                 ;
wire             eds_rx_end_o                   ;
wire             eds_aurora_rxen_o              ;
wire [64-1:0]    eds_aurora_rxdata_o            ;
wire             fbc_rx_start_o                 ;
wire             fbc_rx_end_o                   ;
wire             encoder_rxen_o                 ;
wire [64-1:0]    encoder_rxdata_o               ;

reg   [14-1:0]  timing_flag = 'd0;      
wire  [14-1:0]   align_timing_flag;

initial
begin
    forever #(PERIOD/2)  clk_i=~clk_i;
end

initial
begin
    forever #(3.2)  user_clk=~user_clk;
end

initial
begin
    forever #(4)  sys_clk_i=~sys_clk_i;
end


initial
begin
    rst_i  =  1;
    #(PERIOD*2);
    rst_i  =  0;
end

encode_align #(
    .TCQ ( TCQ ))
 u_encode_align (
    .clk_i                      ( clk_i                                 ),
    .rst_i                      ( rst_i                                 ),
    .precise_encode_en_i        ( precise_encode_en_i                   ),
    .precise_encode_w_i         ( precise_encode_w_i   [32-1:0]         ),
    .precise_encode_x_i         ( precise_encode_x_i   [32-1:0]         ),

    .encode_sim_en_i            ( encode_sim_en                         ),
    .pmt_scan_en_i              ( pmt_scan_en_i                         ),
    .pmt_Wencode_align_rst_i    ( pmt_Wencode_align_rst                 ),
    .pmt_Wencode_align_set_i    ( pmt_Wencode_align_set                 ),
    .pmt_encode_en_o            ( pmt_encode_en_o                       ),
    .pmt_encode_w_o             ( pmt_encode_w_o                     ),
    .pmt_encode_x_o             ( pmt_encode_x_o                     ),

    .eds_scan_en_i              ( eds_scan_en_i                         ),
    .eds_encode_en_o            ( eds_encode_en_o                       ),
    .eds_encode_w_o             ( eds_encode_w_o       [32-1:0]         ),
    .eds_encode_x_o             ( eds_encode_x_o       [32-1:0]         ),

    .timing_flag_i              ( timing_flag                           ),
    .align_timing_flag_o        ( align_timing_flag                     )
);

reg encode_en = 'd0;

always @(posedge clk_i) begin
    if(encode_en)begin
        precise_encode_en_i <= 'd1;
        precise_encode_w_i  <= precise_encode_w_i + 1;
        precise_encode_x_i  <= precise_encode_x_i + 1;
    end
    else begin
        precise_encode_en_i <= 'd0;
    end
    
end



// 100m -> 48k  100000/48 = 2083.3
reg [12-1:0] eds_encode_cnt = 'd2082;
always @(posedge clk_i) begin
    if(eds_scan_en_i)begin
        if(eds_encode_en_o)begin
            if(eds_encode_cnt == 'd2082)
                eds_encode_cnt <= #TCQ 'd0;
            else 
                eds_encode_cnt <= #TCQ eds_encode_cnt + 1;
        end
        else begin
            eds_encode_cnt <= #TCQ eds_encode_cnt;
        end
    end 
    else begin
        eds_encode_cnt <= #TCQ 'd2082;
    end
end 

wire eds_precise_encode_wr_en;

assign eds_precise_encode_wr_en = (eds_encode_cnt == 'd2082) && eds_encode_en_o && eds_scan_en_i;

sync_eds_encode_fifo sync_eds_encode_fifo_inst (
    .rst                        ( 'd0                                               ),  // input wire rst
    .wr_clk                     ( clk_i                                             ),  // input wire wr_clk
    .rd_clk                     ( user_clk                                          ),  // input wire rd_clk
    .din                        ( {eds_encode_w_o,eds_encode_x_o}                   ),  // input wire [63 : 0] din
    .wr_en                      ( eds_precise_encode_wr_en                          ),  // input wire wr_en
    .rd_en                      (  eds_encode_rd_en                                 ),  // input wire rd_en
    .dout                       (  {precise_encode_w_data,precise_encode_x_data}    ),  // output wire [63 : 0] dout
    .full                       (      ),  // output wire full
    .empty                      ( eds_encode_empty     )   // output wire empty
);

reg pcie_eds_end = 0;
wire eds_tx_en;
wire aurora_eds_end;
aurora_64b66b_tx aurora_64b66b_tx_inst(
    // eds
    .eds_frame_en_i             ( eds_frame_en_sync             ),
    .aurora_eds_end_o           ( aurora_eds_end                ),
    .eds_tx_en_o                ( eds_tx_en                     ),
    .eds_tx_data_i              ( 'h00ff00ff                    ),
    .eds_tx_prog_empty_i        ( 'd0                           ),

    .eds_encode_empty_i         ( eds_encode_empty              ),
    .eds_encode_en_o            ( eds_encode_rd_en              ),
    .precise_encode_w_data_i    ( precise_encode_w_data         ),
    .precise_encode_x_data_i    ( precise_encode_x_data         ),

    // System Interface
    .USER_CLK                   ( user_clk                      ),
    .RESET                      ( 'd0                           ),
    .CHANNEL_UP                 ( 'd1                           ),
    
    .tx_tvalid_o                ( tx_tvalid                     ),
    .tx_tdata_o                 ( tx_tdata                      ),
    .tx_tkeep_o                 ( tx_tkeep                      ),
    .tx_tlast_o                 ( tx_tlast                      ),
    .tx_tready_i                ( 'd1                     )
);




pcie_aurora_64b66b_rx aurora_64b66b_rx_inst(
    // eds
    .eds_rx_start_o             ( eds_rx_start                  ),
    .eds_rx_end_o               ( eds_rx_end                    ),
    .eds_aurora_rxen_o          ( eds_aurora_rxen_o             ),
    .eds_aurora_rxdata_o        ( eds_aurora_rxdata_o           ),
    // fbc
    .fbc_rx_start_o             ( fbc_rx_start                  ),
    .fbc_rx_end_o               ( fbc_rx_end                    ),
    // pmt encode
    .encoder_rxen_o             ( encoder_rxen_o                ), 
    .encoder_rxdata_o           ( encoder_rxdata_o              ), 
    
    // System Interface
    .USER_CLK                   ( user_clk                      ),      
    .RESET                      ( 'd0                    ),
    .CHANNEL_UP                 ( 'd1                           ),

    .rx_tvalid_i                ( tx_tvalid                     ),
    .rx_tdata_i                 ( tx_tdata                      ),
    .rx_tkeep_i                 ( tx_tkeep                      ),
    .rx_tlast_i                 ( tx_tlast                      )
);


xpm_cdc_array_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1),  // DECIMAL; 0=do not register input, 1=register input
    .WIDTH(4)           // DECIMAL; range: 1-1024
 )
 xpm_cdc_rx_signal_inst (
    .dest_out({
        eds_rx_start_o
       ,eds_rx_end_o  
       ,fbc_rx_start_o
       ,fbc_rx_end_o  
   }), // WIDTH-bit output: src_in synchronized to the destination clock domain. This
                         // output is registered.

    .dest_clk(sys_clk_i), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk(user_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in({
             eds_rx_start
            ,eds_rx_end  
            ,fbc_rx_start
            ,fbc_rx_end  
        })      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                         // domain. It is assumed that each bit of the array is unrelated to the others. This
                         // is reflected in the constraints applied to this macro. To transfer a binary value
                         // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.

 );


endmodule