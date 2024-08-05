`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/09/18
// Design Name: PCG
// Module Name: fast_shutter_ctrl
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


module fast_shutter_ctrl #(
    parameter                       TCQ         = 0.1 
)(
    // clk & rst
    input                           clk_i                   ,
    input                           rst_i                   ,
    
    input                           fast_shutter_set_i      ,
    input                           fast_shutter_en_i       ,
    input                           soft_fast_shutter_set_i ,
    input                           soft_fast_shutter_en_i  ,
    output                          fast_shutter_out1_o     ,
    output                          fast_shutter_out2_o     ,

    output  [32-1:0]                fast_shutter_act_time_o ,
    input                           fast_back_in1_i         ,
    input                           fast_back_in2_i         ,
    output                          fast_shutter_state_o       
);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam          HOLD_WIDTH              = 20;
reg     [HOLD_WIDTH-1:0]   hold_cnt         = {1'b1,{(HOLD_WIDTH-1){1'b0}}};

reg                 fast_shutter_lock       = 'd0;
reg                 fast_shutter_en_d0      = 'd0;
reg                 fast_shutter_en_d1      = 'd0;
reg                 fast_shutter_state      = 'd0;

reg                 fast_shutter_active     = 'd0;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                fast_shutter_pose;

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) begin
    fast_shutter_en_d0 <= #TCQ fast_shutter_en_i || soft_fast_shutter_en_i;
    fast_shutter_en_d1 <= #TCQ fast_shutter_en_d0;
end
assign fast_shutter_pose = ~fast_shutter_en_d1 && fast_shutter_en_d0;


always @(posedge clk_i) begin
    if(fast_shutter_en_i)begin
        fast_shutter_lock <= #TCQ fast_shutter_set_i;
    end
    else if(soft_fast_shutter_en_i)begin
        fast_shutter_lock <= #TCQ soft_fast_shutter_set_i;
    end
end

always @(posedge clk_i) begin
    if(rst_i)
        hold_cnt <= #TCQ {1'b1,{(HOLD_WIDTH-1){1'b0}}};
    else begin
        if(fast_shutter_pose)
            hold_cnt <= #TCQ 'd0;
        else if(hold_cnt[HOLD_WIDTH-1])
            hold_cnt <= #TCQ hold_cnt;
        else 
            hold_cnt <= #TCQ hold_cnt + 1;
    end
end

always @(posedge clk_i) begin
    if(fast_back_in1_i && (~fast_back_in2_i))
        fast_shutter_state <= #TCQ 'd1;
    else if(~fast_back_in1_i && fast_back_in2_i)
        fast_shutter_state <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(hold_cnt[HOLD_WIDTH-2])
        fast_shutter_active <= #TCQ 'd1;
    else if(hold_cnt[HOLD_WIDTH-1])begin
        // if(fast_shutter_state == fast_shutter_lock)
            fast_shutter_active <= #TCQ 'd0;
    end
    else begin
        fast_shutter_active <= #TCQ 'd0;
    end
end

assign fast_shutter_out1_o  = fast_shutter_active;
assign fast_shutter_out2_o  = fast_shutter_lock;
assign fast_shutter_state_o = fast_shutter_state;

// check time
reg [32-1:0] fast_shutter_act_time = 'd0;
always @(posedge clk_i) begin
    if(rst_i)
        fast_shutter_act_time <= #TCQ 'd0;
    else begin
        if(fast_shutter_pose)
            fast_shutter_act_time <= #TCQ 'd0;
        else if(fast_shutter_state == fast_shutter_lock)
            fast_shutter_act_time <= #TCQ fast_shutter_act_time;
        else 
            fast_shutter_act_time <= #TCQ fast_shutter_act_time + 1;
    end
end
assign fast_shutter_act_time_o = fast_shutter_act_time;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
