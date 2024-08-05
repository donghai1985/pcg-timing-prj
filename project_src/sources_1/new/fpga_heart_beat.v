`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2024/06/26
// Design Name: PCG
// Module Name: fpga_heart_beat
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


module fpga_heart_beat #(
    parameter                       TCQ         = 0.1 
)(
    // clk & rst
    input                       clk_i                   ,
    input                       rst_i                   ,
    
    input                       fast_shutter_en_i       ,
    input                       fast_shutter_set_i      ,
    output      [64-1:0]        fpga_message_up_data_o  ,
    output                      fpga_message_up_o       ,

    input       [4-1:0]         scan_state_i            ,
    input                       fast_shutter_state_i    ,
    input       [3-1:0]         pmt_scan_en_i           ,
    input       [3-1:0]         fbc_motor_state_i       ,
    input                       laser_control_i         ,
    input                       laser_out_switch_i      ,
    input       [12-1:0]        laser_aom_voltage_i     ,
    input                       eds_power_en_i          ,
    input                       eds_frame_en_i          ,
    input       [4-1:0]         map_readback_cnt_i      ,
    input       [4-1:0]         main_scan_cnt_i         ,

    output      [64-1:0]        heartbeat_data_o        ,
    output                      heartbeat_en_o          
);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam                          MILLISECOND_TIME        = 1_000_00; // 1ms
localparam                          HEARTBEAT_TIME          = 500;      // 500ms





//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg                             unit_ms_tick                = 'd0;
reg     [17-1:0]                unit_ms_cnt                 = 'd0;
reg     [10-1:0]                heartbeat_time_cnt          = 'd0;

reg     [64-1:0]                heartbeat_data              = 'd0;
reg                             heartbeat_en                = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// unit time = 1ms
always @(posedge clk_i) begin
    if(unit_ms_cnt == MILLISECOND_TIME-1)begin
        unit_ms_cnt  <= #TCQ 'd0;
        unit_ms_tick <= #TCQ 'd1;
    end
    else begin
        unit_ms_cnt  <= #TCQ unit_ms_cnt + 1; 
        unit_ms_tick <= #TCQ 'd0;
    end
end

always @(posedge clk_i) begin
    if(heartbeat_time_cnt == HEARTBEAT_TIME)
        heartbeat_time_cnt <= #TCQ 'd0;
    else if(unit_ms_tick)
        heartbeat_time_cnt <= #TCQ heartbeat_time_cnt + 1;
end

always @(posedge clk_i) begin
    heartbeat_en    <= #TCQ (heartbeat_time_cnt == HEARTBEAT_TIME-1) && unit_ms_tick;
    heartbeat_data  <= #TCQ {
                                29'd0
                               ,map_readback_cnt_i
                               ,main_scan_cnt_i   
                               ,scan_state_i[4-1:0]
                               ,fast_shutter_state_i        
                               ,pmt_scan_en_i       [3-1:0] 
                               ,fbc_motor_state_i   [3-1:0] 
                               ,laser_control_i             
                               ,laser_out_switch_i          
                               ,laser_aom_voltage_i [12-1:0]
                               ,eds_power_en_i              
                               ,eds_frame_en_i              
                            };
end

assign heartbeat_en_o   = heartbeat_en  ;
assign heartbeat_data_o = heartbeat_data;

// fpga action up message
reg fpga_message_up = 'd0;
reg [64-1:0] fpga_message_up_data = 'd0;
always @(posedge clk_i) fpga_message_up <= #TCQ fast_shutter_en_i;
always @(posedge clk_i) fpga_message_up_data <= #TCQ {8'd1,24'd0,24'd0,7'd0,fast_shutter_set_i};

assign fpga_message_up_data_o   = fpga_message_up_data;
assign fpga_message_up_o        = fpga_message_up;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
