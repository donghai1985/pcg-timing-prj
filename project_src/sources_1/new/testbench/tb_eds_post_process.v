//~ `New testbench
`timescale  1ns / 1ps

module tb_eds_post_process;

// eds_post_process Parameters
parameter PERIOD = 10 ;
parameter TCQ  = 0.1;

// eds_post_process Inputs
reg   clk_i                                = 0 ;
reg   rst_i                                = 0 ;
reg   eds_clk_i                            = 0 ;
reg   eds_frame_en_i                       = 0 ;
reg   eds_sensor_data_en_i                 = 0 ;
reg   [128-1:0]  eds_sensor_data_i         = 128'h00080006000700040005000200030001 ;

// eds_post_process Outputs
wire  eds_post_vld_o                       ;
wire  [64-1:0]  eds_post_data_o            ;
wire  [32-1:0]  eds_error_cnt_o            ;
wire  eds_error_vld_o                      ;
wire  [16-1:0]  eds_error_data_o           ;

wire    [127:0]     eds_sensor_data_temp            ;

initial
begin
    forever #(PERIOD/2)  clk_i=~clk_i;
end

initial
begin
    forever #(PERIOD*3)  eds_clk_i=~eds_clk_i;
end

initial
begin
    #(PERIOD*2) rst_i  =  1;
    #(PERIOD*2) rst_i  =  0;
end

eds_post_process #(
    .TCQ ( TCQ ))
 u_eds_post_process (
    .clk_i                   ( clk_i                           ),
    .rst_i                   ( rst_i                           ),
    .eds_clk_i               ( eds_clk_i                       ),
    .eds_frame_en_i          ( eds_frame_en_i                  ),
    .eds_sensor_data_en_i    ( eds_sensor_data_en_i            ),
    .eds_sensor_data_i       ( eds_sensor_data_temp  [128-1:0] ),

    .eds_post_vld_o          ( eds_post_vld_o                  ),
    .eds_post_data_o         ( eds_post_data_o       [64-1:0]  ),
    .eds_error_cnt_o         ( eds_error_cnt_o       [32-1:0]  ),
    .eds_error_vld_o         ( eds_error_vld_o                 ),
    .eds_error_data_o        ( eds_error_data_o      [16-1:0]  )
);

assign	eds_sensor_data_temp		=	{eds_sensor_data_i[63:0],eds_sensor_data_i[127:64]};

// 48k 20us cycle
reg [10-1:0] eds_cycle_cnt = 'd0;
always @(posedge eds_clk_i) begin
    if(eds_frame_en_i)begin
        if(eds_cycle_cnt == 347)
            eds_cycle_cnt <= #TCQ 'd0;
        else
            eds_cycle_cnt <= #TCQ eds_cycle_cnt + 1;
    end
    else 
        eds_cycle_cnt <= #TCQ 'd0;
end

reg [16-1:0] eds_data_cnt = 'd0;

always @(posedge eds_clk_i) begin
    if(eds_cycle_cnt=='d347)
        eds_sensor_data_en_i <= #TCQ 'd1;
    else if(eds_data_cnt == 'd255)
        eds_sensor_data_en_i <= #TCQ 'd0;
end

always @(posedge eds_clk_i) begin
    if(eds_sensor_data_en_i)
        eds_data_cnt <= #TCQ eds_data_cnt + 1;
    else 
        eds_data_cnt <= #TCQ 'd0;
end


always @(posedge eds_clk_i) begin
    if(eds_sensor_data_en_i)
        eds_sensor_data_i <= #TCQ 128'h00080006000700040005000200030001 + {8{eds_data_cnt}};
    else 
        eds_sensor_data_i <= #TCQ 128'h0008000600070004000500020003f001 ;
end


reg [16-1:0] slave_tx_ack = 'd0;
reg slave_tx_byte_en_d = 'd0;

arbitrate_bpsi arbitrate_bpsi_inst(
    .clk_i                          ( clk_i                         ),
    .rst_i                          ( rst_i                         ),
    

    .eds_error_vld_i                ( eds_error_vld_o               ),
    .eds_error_data_i               ( eds_error_data_o              ),

    .slave_tx_ack_i                 ( slave_tx_ack[15]              ),
    .slave_tx_byte_en_o             ( slave_tx_byte_en              ),
    .slave_tx_byte_o                ( slave_tx_byte                 ),
    .slave_tx_byte_num_en_o         ( slave_tx_byte_num_en          ),
    .slave_tx_byte_num_o            ( slave_tx_byte_num             )

);

always @(posedge clk_i) begin
    slave_tx_byte_en_d <= #TCQ slave_tx_byte_en;
end
always @(posedge clk_i) begin
    slave_tx_ack <= #TCQ {slave_tx_ack[14:0],(slave_tx_byte_en_d && (~slave_tx_byte_en))};
end


// initial
// begin

//     $finish;
// end

endmodule