`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/09/14
// Design Name: PCG
// Module Name: fbc_motor
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


module fbc_motor #(
    parameter                       TCQ         = 0.1 

)(
    // clk & rst
    input   wire                    clk_i                   ,
    input   wire                    rst_i                   ,
    
    input   wire    [2:0]           motor_state_i           , // motor state
    input   wire                    motor_Ufeed_en_i        , // Ufeed en
    input   wire    [15:0]          motor_Ufeed_i           , // Ufeed

    input   wire                    overload_motor_en_i     ,
    input   wire    [15:0]          overload_ufeed_thre_i   ,
    output  wire    [31:0]          overload_pid_result_o   
);


//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg     [16-1:0]    mem[15:0];
reg     [4-1:0]     mem_waddr           = 'd0;
reg                 mem_ren             = 'd0;
reg     [4-1:0]     mem_raddr           = 'd0;
reg                 mem_vld             = 'd0;
reg     [16-1:0]    mem_dout            = 'd0;

reg                 mem_full            = 'd0;
reg     [16-1:0]    motor_ufeed_max     = 'd0;
reg     [16-1:0]    motor_ufeed_min     = 'hffff;
reg                 overload_check      = 'd0;
reg     [32-1:0]    overload_pid_result = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<





//////////////////////////////////////////////////////////////////////////////////
// *********** Instance Module
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
always @(posedge clk_i) begin
    if(overload_motor_en_i)begin
        if(motor_Ufeed_en_i)begin
            mem_waddr       <= #TCQ mem_waddr + 1;
            mem[mem_waddr]  <= #TCQ motor_Ufeed_i;
        end
    end
    else begin
        mem_waddr <= #TCQ 'd0;
    end
end

always @(posedge clk_i) begin
    if(overload_motor_en_i)begin
        if(&mem_waddr)
            mem_full <= #TCQ 'd1;
    end
    else begin
        mem_full <= #TCQ 'd0;
    end
end

always @(posedge clk_i) begin
    if(mem_full)begin
        if(motor_Ufeed_en_i)
            mem_ren <= #TCQ 'd1;
        else if(&mem_raddr)
            mem_ren <= #TCQ 'd0;
    end
    else begin
        mem_ren <= #TCQ 'd0;
    end
end

always @(posedge clk_i) begin
    if(mem_ren)
        mem_raddr <= #TCQ mem_raddr + 1;
end

always @(posedge clk_i) begin
    if(mem_ren)
        mem_dout <= #TCQ mem[mem_raddr];
end

always @(posedge clk_i) begin
    mem_vld <= #TCQ mem_ren;
end

always @(posedge clk_i) begin
    if(~mem_full || overload_check)begin
        motor_ufeed_max <= #TCQ 'd0;
        motor_ufeed_min <= #TCQ 'hffff;
    end
    else if(mem_vld)begin
        if(mem_dout > motor_ufeed_max)
            motor_ufeed_max <= #TCQ mem_dout;
        
        if(mem_dout < motor_ufeed_min)
            motor_ufeed_min <= #TCQ mem_dout;
    end
end

always @(posedge clk_i) begin
    overload_check <= #TCQ ~mem_ren && mem_vld;
end

always @(posedge clk_i) begin
    if(~overload_motor_en_i)begin
        overload_pid_result <= #TCQ 'd0;
    end
    else if(overload_check)begin
        if(motor_ufeed_max-motor_ufeed_min >= overload_ufeed_thre_i)begin
            overload_pid_result[31]     <= #TCQ 'd1;
            overload_pid_result[15:0]   <= #TCQ motor_ufeed_max-motor_ufeed_min;
        end
        else begin
            overload_pid_result[15:0]   <= #TCQ motor_ufeed_max-motor_ufeed_min;
        end
    end
end

assign overload_pid_result_o = overload_pid_result;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
