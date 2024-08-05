//~ `New testbench
`timescale  1ns / 1ps

module tb_fast_shutter_ctrl;

// fast_shutter_ctrl Parameters
parameter PERIOD = 10 ;
parameter TCQ  = 0.1;

// fast_shutter_ctrl Inputs
reg   clk_i                                = 0 ;
reg   rst_i                                = 0 ;
reg   fast_shutter_set_i                   = 0 ;
reg   fast_shutter_en_i                    = 0 ;
reg   soft_fast_shutter_set_i              = 0 ;
reg   soft_fast_shutter_en_i               = 0 ;
reg   fast_back_in1_i                      = 0 ;
reg   fast_back_in2_i                      = 0 ;

// fast_shutter_ctrl Outputs
wire  fast_shutter_out1_o                  ;
wire  fast_shutter_out2_o                  ;
wire  fast_shutter_err_act_o               ;
wire  [32-1:0]  fast_shutter_act_time_o    ;
wire  fast_shutter_state_o                 ;


initial
begin
    forever #(PERIOD/2)  clk_i=~clk_i;
end

initial
begin
    rst_i  =  1;
    #(PERIOD*2);
    rst_i  =  0;
end

fast_shutter_ctrl #(
    .TCQ ( TCQ ))
 u_fast_shutter_ctrl (
    .clk_i                    ( clk_i                             ),
    .rst_i                    ( rst_i                             ),
    .fast_shutter_set_i       ( fast_shutter_set_i                ),
    .fast_shutter_en_i        ( fast_shutter_en_i                 ),
    .soft_fast_shutter_set_i  ( soft_fast_shutter_set_i           ),
    .soft_fast_shutter_en_i   ( soft_fast_shutter_en_i            ),
    .fast_back_in1_i          ( fast_back_in1_i                   ),
    .fast_back_in2_i          ( fast_back_in2_i                   ),

    .fast_shutter_out1_o      ( fast_shutter_out1_o               ),
    .fast_shutter_out2_o      ( fast_shutter_out2_o               ),
    .fast_shutter_err_act_o   ( fast_shutter_err_act_o            ),
    .fast_shutter_act_time_o  ( fast_shutter_act_time_o  [32-1:0] ),
    .fast_shutter_state_o     ( fast_shutter_state_o              )
);

reg fast_shutter_active_d = 'd0;
always @(posedge clk_i) begin
    fast_shutter_active_d <= #TCQ fast_shutter_out1_o;
end

reg [32-1:0] fast_shutter_cnt = 'd5_000_00;
reg          fast_shutter_state = 'd0;
always @(posedge clk_i) begin
    if(~fast_shutter_active_d && fast_shutter_out1_o)
        fast_shutter_state <= #TCQ 'd1;
    else if(fast_shutter_cnt == 'd5_000_00)
        fast_shutter_state <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(fast_shutter_state)
        fast_shutter_cnt <= #TCQ fast_shutter_cnt + 1;
    else 
        fast_shutter_cnt <= #TCQ 'd0;
end

reg fast_shutter_state_d = 'd0;
always @(posedge clk_i) begin
    fast_shutter_state_d <= #TCQ fast_shutter_state;
end

always @(posedge clk_i) begin
    if(rst_i)begin
        fast_back_in1_i <= #TCQ 'd1;
        fast_back_in2_i <= #TCQ 'd0;
    end
    else if(fast_shutter_state_d)begin
        fast_back_in1_i <= #TCQ ~fast_back_in1_i;
        fast_back_in2_i <= #TCQ fast_back_in2_i ^ fast_back_in1_i;
    end
    else if(fast_shutter_state_d && (~fast_shutter_state))begin
        fast_back_in1_i <= #TCQ ~fast_shutter_out2_o;
        fast_back_in2_i <= #TCQ fast_shutter_out2_o;
    end
end






initial
begin
    #1000;
    $finish;
end

endmodule