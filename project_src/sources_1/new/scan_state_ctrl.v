`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zas
// Engineer: songyuxin
// 
// Create Date: 2023/09/18
// Design Name: PCG
// Module Name: scan_state_ctrl
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

module scan_state_ctrl #(
    parameter                       TCQ         = 0.1 
)(
    // clk & rst
    input                           clk_i                   ,
    input                           rst_i                   ,
    
    input   [3-1:0]                 aurora_tx_idle_i        ,
    output                          aurora_scan_reset_o     ,
    input                           scan_soft_reset_i       ,
    input                           scan_start_cmd_i        ,
    input   [3-1:0]                 scan_start_sel_i        ,
    input                           fast_shutter_state_i    ,
    input                           fbc_close_state_i       ,
    input                           fbc_close_state_err_i   ,
    input                           fbc_ratio_err_i         ,
    input                           scan_fbc_switch_i       ,

    input   [32-1:0]                x_encode_i              ,
    input   [32-1:0]                scan_encode_offset_i    ,
    input   [32-1:0]                x_start_encode_i        ,
    input   [32-1:0]                fast_shutter_encode_i   ,
    input   [32-1:0]                x_end_encode_i          ,
    input   [32-1:0]                plc_x_encode_i          ,
    input                           plc_x_encode_en_i       ,

    output                          fast_shutter_set_o      ,
    output                          fast_shutter_en_o       ,
    output                          fbc_close_loop_o        ,
    output                          fbc_open_loop_o         ,
    output                          real_scan_start_o       ,
    output  [3-1:0]                 real_scan_sel_o         ,
    output                          scan_finish_comm_o      ,
    input                           scan_finish_comm_ack_i  ,
    output                          scan_error_comm_o       ,
    output  [4-1:0]                 scan_error_comm_flag_o  ,
    output  [4-1:0]                 scan_state_o            ,
    output                          PLC_ACC_IN              ,
    output                          ACS_IN1                 ,
    input                           ACS_OUT1                ,
    output                          acc_force_on_o          ,
    output  [32-1:0]                start_encode_latch_o    ,
    output  [32-1:0]                sfrst_encode_latch_o    ,

    input   [32-1:0]                autocal_encode_offset_i ,
    input   [3-1:0]                 autocal_fbp_sel_i       ,
    input   [32-1:0]                fbp_encode_start_i      ,
    input   [32-1:0]                fbp_encode_end_i        ,

    input   [3-1:0]                 autocal_pow_sel_i       ,
    input   [32-1:0]                pow_encode_start_i      ,
    input   [32-1:0]                pow_encode_end_i        ,

    input   [3-1:0]                 autocal_lpo_sel_i       ,
    input   [32-1:0]                lpo_encode_start_i      ,
    input   [32-1:0]                lpo_encode_end_i        ,

    output  [32-1:0]                precise_encode_offset_o ,
    output                          main_scan_start_o       ,
    output  [4-1:0]                 autocal_process_o       ,
    output                          autocal_fbp_scan_o      ,
    output                          autocal_pow_scan_o      ,
    output                          autocal_lpo_scan_o      ,

    // function safety, aom overload
    input                           aom_continuous_trig_err_i,
    input                           aom_integral_trig_err_i  
);

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Parameter Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
localparam  [4-1:0] ST_IDLE                 = 'd0;
localparam  [4-1:0] ST_OPEN_SHUTTER         = 'd1;
localparam  [4-1:0] ST_FBC_CLOSE_LOOP       = 'd2;
localparam  [4-1:0] ST_SCAN                 = 'd3;
localparam  [4-1:0] ST_FBC_OPEN_LOOP        = 'd4;
localparam  [4-1:0] ST_CLOSE_SHUTTER        = 'd5;
localparam  [4-1:0] ST_ERROR                = 'd6;
localparam  [4-1:0] ST_FINISH               = 'd7;
localparam  [4-1:0] ST_AUTOCAL_SCAN         = 'd8;
localparam  [4-1:0] ST_FAST_SHUTTER_WAIT    = 'd9;

localparam          TIMEOUT_NUM             = 'd100_000_000;  // 1s
localparam          SHUTTER_WAIT            = 'd500_000;  //5ms

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//////////////////////////////////////////////////////////////////////////////////
// *********** Define Register Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reg     [4-1:0]     state                   = ST_IDLE;
reg     [4-1:0]     next_state              = ST_IDLE;

reg     [28-1:0]    timeout_cnt             = 'd0;
reg                 timeout_flag            = 'd0;
reg     [20-1:0]    shutter_wait_cnt        = 'd0;
reg                 shutter_wait_flag       = 'd0;

reg                 scan_start_cmd_flag     = 'd0;
reg                 fast_shutter_set        = 'd0;
reg                 fast_shutter_en         = 'd0;
reg                 real_scan_start         = 'd0;
reg     [3-1:0]     real_scan_sel           = 'd7;

reg     [32-1:0]    start_encode_latch      = 'd0;
reg     [32-1:0]    sfrst_encode_latch      = 'd0;
reg                 acc_force_on            = 'd0;
reg                 fast_shutter_flag_d0    = 'd0;
reg                 fast_shutter_flag_d1    = 'd0;
reg                 scan_start_flag_d0      = 'd0;
reg                 scan_start_flag_d1      = 'd0;
reg                 fbc_close_loop          = 'd0;
reg                 fbc_open_loop           = 'd0;
reg                 scan_finish_comm        = 'd0;
reg                 scan_error_comm         = 'd0;

reg                 wait_scan_ack           = 'd0;
reg     [28-1:0]    wait_scan_ack_cnt       = 'd0;
reg                 scan_finish_retran      = 'd0;
reg     [2-1:0]     scan_finish_retran_cnt  = 'd0;

reg                 plc_acc_set_flag        = 'd0;
reg     [4-1:0]     scan_error_comm_flag    = 'd0;

reg                 aurora_idle_timeout     = 'd0;
reg     [28-1:0]    check_aurora_idle_cnt   = 'd0;

reg     [32-1:0]    precise_encode_offset   = 'd0;


reg                 fbp_start_flag_d0       = 'd0;
reg                 fbp_start_flag_d1       = 'd0;
reg                 pow_start_flag_d0       = 'd0;
reg                 pow_start_flag_d1       = 'd0;
reg                 lpo_start_flag_d0       = 'd0;
reg                 lpo_start_flag_d1       = 'd0;

reg                 fbp_start_cmd_flag      = 'd0;
reg                 pow_start_cmd_flag      = 'd0;
reg                 lpo_start_cmd_flag      = 'd0;

reg     [4-1:0]     autocal_process         = 'd0;
reg                 autocal_fbp_scan        = 'd0;
reg                 autocal_pow_scan        = 'd0;
reg                 autocal_lpo_scan        = 'd0;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Define Wire Signal
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
wire                scan_start_flag     ;
wire                fast_shutter_flag   ;
wire                scan_end_flag       ;
wire                scan_plc_acc_flag   ;
wire                scan_start_flag_pose;

wire                scan_spindle_exercise   ;
wire                autocal_spindle_end     ;

wire                fbp_start_flag      ;
wire                fbp_end_flag        ;
wire                fbp_start_flag_pose ;
wire                pow_start_flag      ;
wire                pow_end_flag        ;
wire                pow_start_flag_pose ;
wire                lpo_start_flag      ;
wire                lpo_end_flag        ;
wire                lpo_start_flag_pose ;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//////////////////////////////////////////////////////////////////////////////////
// *********** Logic Design
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
assign fbp_start_flag   = x_encode_i >= fbp_encode_start_i;
assign fbp_end_flag     = x_encode_i >= fbp_encode_end_i  ;
assign pow_start_flag   = x_encode_i >= pow_encode_start_i;
assign pow_end_flag     = x_encode_i >= pow_encode_end_i  ;
assign lpo_start_flag   = x_encode_i >= lpo_encode_start_i;
assign lpo_end_flag     = x_encode_i >= lpo_encode_end_i  ;

assign scan_start_flag  = x_encode_i >= x_start_encode_i;
assign fast_shutter_flag= x_encode_i >= fast_shutter_encode_i;
assign scan_end_flag    = x_encode_i >= x_end_encode_i;
assign scan_plc_acc_flag= x_encode_i >= plc_x_encode_i;

always @(posedge clk_i) begin
    scan_start_flag_d0 <= #TCQ scan_start_flag;
    scan_start_flag_d1 <= #TCQ scan_start_flag_d0;
    fast_shutter_flag_d0 <= #TCQ fast_shutter_flag;
    fast_shutter_flag_d1 <= #TCQ fast_shutter_flag_d0;

    fbp_start_flag_d0  <= #TCQ fbp_start_flag;
    fbp_start_flag_d1  <= #TCQ fbp_start_flag_d0;
    pow_start_flag_d0  <= #TCQ pow_start_flag;
    pow_start_flag_d1  <= #TCQ pow_start_flag_d0;
    lpo_start_flag_d0  <= #TCQ lpo_start_flag;
    lpo_start_flag_d1  <= #TCQ lpo_start_flag_d0;
end

assign scan_start_flag_pose = ~scan_start_flag_d1 && scan_start_flag_d0;
assign fast_shutter_flag_pose = ~fast_shutter_flag_d1 && fast_shutter_flag_d0;
assign fbp_start_flag_pose  = ~fbp_start_flag_d1 && fbp_start_flag_d0;
assign pow_start_flag_pose  = ~pow_start_flag_d1 && pow_start_flag_d0;
assign lpo_start_flag_pose  = ~lpo_start_flag_d1 && lpo_start_flag_d0;

always @(posedge clk_i) begin
    if(scan_start_cmd_i)
        scan_start_cmd_flag <= #TCQ 'd1;
    else if(state==ST_FINISH)
        scan_start_cmd_flag <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(fbp_start_flag_pose && (|autocal_fbp_sel_i))
        fbp_start_cmd_flag <= #TCQ 'd1;
    else if(state==ST_FINISH && fbp_start_cmd_flag)
        fbp_start_cmd_flag <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(pow_start_flag_pose && (|autocal_pow_sel_i))
        pow_start_cmd_flag <= #TCQ 'd1;
    else if(state==ST_FINISH && pow_start_cmd_flag)
        pow_start_cmd_flag <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(lpo_start_flag_pose && (|autocal_lpo_sel_i))
        lpo_start_cmd_flag <= #TCQ 'd1;
    else if(state==ST_FINISH && lpo_start_cmd_flag)
        lpo_start_cmd_flag <= #TCQ 'd0;
end

assign scan_spindle_exercise  = scan_start_flag && scan_start_cmd_flag; // 实时检查当前 encode 是否越过 san start encode 位置
assign autocal_spindle_end    = (fbp_end_flag && fbp_start_cmd_flag) || (pow_end_flag && pow_start_cmd_flag) || (lpo_end_flag && lpo_start_cmd_flag);
assign autocal_other_enable   = ({1'b0,fbp_start_cmd_flag} + {1'b0,pow_start_cmd_flag} + {1'b0,lpo_start_cmd_flag})>1;

always @(posedge clk_i) begin
    if(rst_i)
        state <= #TCQ ST_IDLE;
    else
        state <= #TCQ next_state;
end

always @(*) begin
    next_state = state;
    case (state)
        ST_IDLE: begin
            // if(scan_start_cmd_flag || fbp_start_cmd_flag || pow_start_cmd_flag || lpo_start_cmd_flag)
            if(scan_start_cmd_flag)
                next_state = ST_FAST_SHUTTER_WAIT;
        end

        ST_FAST_SHUTTER_WAIT: begin
            if(fast_shutter_flag_d0)
                next_state = ST_OPEN_SHUTTER;
            else if(scan_spindle_exercise)
                next_state = ST_ERROR;
            else if(scan_soft_reset_i)
                next_state = ST_FINISH; 
        end

        ST_OPEN_SHUTTER: begin
            if(fast_shutter_state_i == 'd0 && shutter_wait_flag)begin
                if(scan_fbc_switch_i)
                    next_state = ST_FBC_CLOSE_LOOP;
                else if(fbp_start_cmd_flag || pow_start_cmd_flag || lpo_start_cmd_flag)
                    next_state = ST_AUTOCAL_SCAN;
                else 
                    next_state = ST_SCAN;
            end
            else if(timeout_flag || scan_spindle_exercise || autocal_spindle_end)
                next_state = ST_ERROR;
        end

        ST_FBC_CLOSE_LOOP: begin
            if(fbc_close_state_i)begin
                if(fbp_start_cmd_flag || pow_start_cmd_flag || lpo_start_cmd_flag)
                    next_state = ST_AUTOCAL_SCAN;
                else 
                    next_state = ST_SCAN;
            end 
            else if(timeout_flag || scan_spindle_exercise || autocal_spindle_end)
                next_state = ST_ERROR;
        end

        ST_SCAN: begin
            if(scan_end_flag && real_scan_start)begin
                if(scan_fbc_switch_i)
                    next_state = ST_FBC_OPEN_LOOP;
                else 
                    next_state = ST_CLOSE_SHUTTER;
            end
            else if((scan_end_flag && (~real_scan_start)) 
                     || fbc_ratio_err_i || fbc_close_state_err_i )
                    //  || aom_continuous_trig_err_i || aom_integral_trig_err_i)
                next_state = ST_ERROR;
            else if(scan_soft_reset_i)
                next_state = ST_FINISH; 
        end
        
        ST_AUTOCAL_SCAN: begin
            if(autocal_spindle_end)begin
                if(scan_fbc_switch_i)
                    next_state = ST_FBC_OPEN_LOOP;
                else 
                    next_state = ST_CLOSE_SHUTTER;
            end
            else if(fbc_ratio_err_i || fbc_close_state_err_i)
                next_state = ST_ERROR;
            else if(scan_soft_reset_i)
                next_state = ST_FINISH; 
        end

        ST_FBC_OPEN_LOOP: begin
            if(fbc_close_state_i == 'd0)
                next_state = ST_CLOSE_SHUTTER;
            else if(timeout_flag)
                next_state = ST_ERROR;
        end

        ST_CLOSE_SHUTTER: begin
            if(fast_shutter_state_i == 'd1)
                next_state = ST_FINISH;
            else if(timeout_flag || autocal_other_enable)
                next_state = ST_ERROR;
        end

        ST_ERROR: begin
            if(scan_soft_reset_i)
                next_state = ST_FINISH; 
        end

        ST_FINISH: begin
            if(aurora_idle_timeout || (&aurora_tx_idle_i))
                next_state = ST_IDLE;
        end
        default:next_state = ST_IDLE;
    endcase
end

// check FBC close loop or fast shutter timeout
always @(posedge clk_i) begin
    if(state!=next_state)
        timeout_cnt <= #TCQ 'd0;
    else if(state==ST_OPEN_SHUTTER || state==ST_FBC_CLOSE_LOOP || state==ST_FBC_OPEN_LOOP || state==ST_CLOSE_SHUTTER)
        timeout_cnt <= #TCQ timeout_cnt + 1;
end

always @(posedge clk_i) begin
    if(timeout_cnt >= TIMEOUT_NUM-1)
        timeout_flag <= #TCQ 'd1;
    else 
        timeout_flag <= #TCQ 'd0;
end

// open fast shutter delay scan
always @(posedge clk_i) begin
    if(shutter_wait_cnt >= SHUTTER_WAIT-1)
        shutter_wait_flag <= #TCQ 'd1;
    else 
        shutter_wait_flag <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(state==ST_OPEN_SHUTTER && fast_shutter_state_i == 'd0)
        shutter_wait_cnt <= #TCQ shutter_wait_cnt + 1;
    else 
        shutter_wait_cnt <= #TCQ 'd0;
end

// control fast shutter
always @(posedge clk_i) begin
    if(state==ST_FAST_SHUTTER_WAIT && fast_shutter_flag_d0)begin
        fast_shutter_set <= #TCQ 'd0;
        fast_shutter_en  <= #TCQ 'd1;
    end
    else if(state!=ST_CLOSE_SHUTTER && next_state==ST_CLOSE_SHUTTER)begin
        fast_shutter_set <= #TCQ 'd1;
        fast_shutter_en  <= #TCQ 'd1;
    end
    else if((state!=ST_ERROR) && (next_state==ST_ERROR))begin
        fast_shutter_set <= #TCQ 'd1;
        fast_shutter_en  <= #TCQ 'd1;
    end
    else begin
        fast_shutter_en  <= #TCQ 'd0;
    end
end

always @(posedge clk_i) begin
    if(scan_start_cmd_flag)
        precise_encode_offset <= #TCQ scan_encode_offset_i;
    else 
        precise_encode_offset <= #TCQ autocal_encode_offset_i;
end

always @(posedge clk_i) begin
    if(state==ST_SCAN && scan_start_flag_pose)
        real_scan_start <= #TCQ 'd1;
    else if(state==ST_SCAN && next_state!=ST_SCAN)
        real_scan_start <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(scan_start_cmd_flag)
        real_scan_sel <= #TCQ scan_start_sel_i;
    else if(fbp_start_cmd_flag)
        real_scan_sel <= #TCQ autocal_fbp_sel_i;
    else if(pow_start_cmd_flag)
        real_scan_sel <= #TCQ autocal_pow_sel_i;
    else if(lpo_start_cmd_flag)
        real_scan_sel <= #TCQ autocal_lpo_sel_i;
end

// fast shutter and force on acc
always @(posedge clk_i) begin
    if(state==ST_ERROR)
        acc_force_on <= #TCQ 'd0;
    else if(state==ST_FAST_SHUTTER_WAIT && fast_shutter_flag_d0)
        acc_force_on <= #TCQ 'd1;
    else if(state==ST_SCAN && scan_start_flag_pose)
        acc_force_on <= #TCQ 'd0;
end


always @(posedge clk_i) begin
    if(scan_start_cmd_i)
        start_encode_latch <= #TCQ x_encode_i;
end

always @(posedge clk_i) begin
    if(scan_soft_reset_i)
        sfrst_encode_latch <= #TCQ x_encode_i;
end

// scan finish check aurora idle
always @(posedge clk_i) begin
    if(state==ST_FINISH)
        check_aurora_idle_cnt <= #TCQ check_aurora_idle_cnt + 1;
    else 
        check_aurora_idle_cnt <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    aurora_idle_timeout <= #TCQ check_aurora_idle_cnt >= 'd99_999_999;
end

// scan finish message retransmission 3 times with 1s
always @(posedge clk_i) begin
    if((state == ST_CLOSE_SHUTTER && next_state==ST_FINISH) && scan_start_cmd_flag)
        wait_scan_ack <= #TCQ 'd1;
    else if(scan_finish_retran_cnt == 'd2 || scan_finish_comm_ack_i)
        wait_scan_ack <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    scan_finish_retran <= #TCQ wait_scan_ack_cnt=='d99_999_999;     // 1s
end

always @(posedge clk_i) begin
    if(wait_scan_ack)begin
        if(scan_finish_retran)
            wait_scan_ack_cnt <= #TCQ 'd0;
        else 
            wait_scan_ack_cnt <= #TCQ wait_scan_ack_cnt + 1;
    end
    else
        wait_scan_ack_cnt <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    if(wait_scan_ack)begin
        if(scan_finish_retran)
            scan_finish_retran_cnt <= #TCQ scan_finish_retran_cnt + 1;
    end
    else 
        scan_finish_retran_cnt <= #TCQ 'd0;
end

always @(posedge clk_i) begin
    // if(state==ST_IDLE)
    //     scan_error_comm_flag <= #TCQ 'd0;   // flag reset
    if(state==ST_OPEN_SHUTTER && timeout_flag)
        scan_error_comm_flag <= #TCQ 'd1;   // open fast shutter timeout error
    if(state==ST_FBC_CLOSE_LOOP && timeout_flag)
        scan_error_comm_flag <= #TCQ 'd2;   // fbc close loop timeout error
    if(state==ST_CLOSE_SHUTTER && timeout_flag)
        scan_error_comm_flag <= #TCQ 'd3;   // close fast shutter timeout error
    if((state==ST_OPEN_SHUTTER || state==ST_FBC_CLOSE_LOOP || state==ST_FAST_SHUTTER_WAIT) && scan_spindle_exercise)
        scan_error_comm_flag <= #TCQ 'd4;   // spindle advance exercise error
    if((state==ST_SCAN) && fbc_ratio_err_i)
        scan_error_comm_flag <= #TCQ 'd5;   // fbc laser energy error
    if((state==ST_SCAN) && scan_end_flag && (~real_scan_start))
        scan_error_comm_flag <= #TCQ 'd6;   // scan not start trigger error
    if((state==ST_SCAN) && fbc_close_state_err_i)
        scan_error_comm_flag <= #TCQ 'd7;   // fbc voltage oscillation error

    if((state==ST_OPEN_SHUTTER || state==ST_FBC_CLOSE_LOOP || state==ST_FAST_SHUTTER_WAIT) && autocal_spindle_end)
        scan_error_comm_flag <= #TCQ 'd8;   // autocal scan err
    if((state==ST_AUTOCAL_SCAN) && fbc_ratio_err_i)
        scan_error_comm_flag <= #TCQ 'd9;   // autocal fbc laser energy error
    if((state==ST_AUTOCAL_SCAN) && fbc_close_state_err_i)
        scan_error_comm_flag <= #TCQ 'd10;  // autocal fbc voltage oscillation error
    if((state==ST_CLOSE_SHUTTER) && autocal_other_enable)
        scan_error_comm_flag <= #TCQ 'd11;  // autocal spindle moving too fast

    if(state==ST_FAST_SHUTTER_WAIT && timeout_flag)
        scan_error_comm_flag <= #TCQ 'd12;   // wait fast shutter encode timeout error
    // if((state==ST_SCAN) && aom_integral_trig_err_i)
    //     scan_error_comm_flag <= #TCQ 'd13;  // aom integral trigger timeout
end

always @(posedge clk_i) fbc_close_loop   <= #TCQ (state==ST_OPEN_SHUTTER) && (next_state==ST_FBC_CLOSE_LOOP);
always @(posedge clk_i) fbc_open_loop    <= #TCQ (state==ST_SCAN && next_state==ST_FBC_OPEN_LOOP);
always @(posedge clk_i) scan_finish_comm <= #TCQ ((state == ST_CLOSE_SHUTTER && next_state==ST_FINISH) && scan_start_cmd_flag) || scan_finish_retran;
always @(posedge clk_i) scan_error_comm  <= #TCQ (state!=ST_ERROR) && (next_state==ST_ERROR);
always @(posedge clk_i) plc_acc_set_flag <= #TCQ (state==ST_SCAN) && scan_plc_acc_flag && plc_x_encode_en_i;

always @(posedge clk_i) autocal_fbp_scan <= #TCQ (state==ST_AUTOCAL_SCAN) && fbp_start_cmd_flag;
always @(posedge clk_i) autocal_pow_scan <= #TCQ (state==ST_AUTOCAL_SCAN) && pow_start_cmd_flag;
always @(posedge clk_i) autocal_lpo_scan <= #TCQ (state==ST_AUTOCAL_SCAN) && lpo_start_cmd_flag;
always @(posedge clk_i) autocal_process  <= #TCQ fbp_start_cmd_flag + {pow_start_cmd_flag,1'b0} + {lpo_start_cmd_flag,1'b0} + lpo_start_cmd_flag;

assign aurora_scan_reset_o  = aurora_idle_timeout;
assign fast_shutter_set_o   = fast_shutter_set;
assign fast_shutter_en_o    = fast_shutter_en ;
assign real_scan_start_o    = real_scan_start || autocal_fbp_scan || autocal_pow_scan || autocal_lpo_scan;
assign real_scan_sel_o      = real_scan_sel   ;
assign fbc_close_loop_o     = fbc_close_loop  ;
assign fbc_open_loop_o      = fbc_open_loop   ;
assign scan_finish_comm_o   = scan_finish_comm;
assign scan_error_comm_o    = scan_error_comm ;
assign scan_error_comm_flag_o = scan_error_comm_flag;
assign scan_state_o         = state;
assign PLC_ACC_IN           = plc_acc_set_flag;
assign ACS_IN1              = 1'd0; // state == ST_SCAN;
assign acc_force_on_o       = acc_force_on;
assign start_encode_latch_o = start_encode_latch;
assign sfrst_encode_latch_o = sfrst_encode_latch;

assign precise_encode_offset_o = precise_encode_offset;
assign main_scan_start_o    = real_scan_start ;
assign autocal_process_o    = autocal_process;
assign autocal_fbp_scan_o   = autocal_fbp_scan;
assign autocal_pow_scan_o   = autocal_pow_scan;
assign autocal_lpo_scan_o   = autocal_lpo_scan;
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


endmodule
