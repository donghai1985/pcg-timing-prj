`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/11 8:40:10
// Design Name: 
// Module Name: motion_top_if
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

module motion_top_if(
		input	wire		clk,
		input	wire		rst,
		
        input   wire        cfg_spindle_width_i,
		// input	wire		motion_en,
        input   wire        x_encode_zero_calib_i,
		
		input	wire		x_encoder_a_in,
		input	wire		x_encoder_b_in,
		input	wire 		x_encoder_z_in,
		output	wire 		x_encoder_a_out,
		output	wire 		x_encoder_b_out,
		output	wire		x_encoder_z_out,
		
		output	wire		w_encoder_clk_out,
		input 	wire	 	w_encoder_data_in,
		input	wire		w_encoder_clk_in,
		output	wire		w_encoder_data_out,
		
		output	wire		x_zero_flag,
		output	wire		x_data_out_en,
		output	wire [31:0]	x_data_out,
		
		output	wire		w_data_out_en,
		output	wire [31:0]	w_data_out,
		output	wire		w_data_error,
		output	wire		w_data_warn

);

reg     motion_en               = 'd1;
reg     cfg_spindle_width_d     = 'd0;
always @(posedge clk) begin
    cfg_spindle_width_d <= cfg_spindle_width_i;
    motion_en           <= ~(cfg_spindle_width_d ^ cfg_spindle_width_i);
end

x_encoder_process	x_encoder_process_inst(
		.clk(clk),
		.rst(rst),
		
        .x_encode_zero_calib_i      ( x_encode_zero_calib_i ),
		.x_encoder_a_in(x_encoder_a_in),
		.x_encoder_b_in(x_encoder_b_in),
		.x_encoder_z_in(x_encoder_z_in),
		.x_encoder_a_out(x_encoder_a_out),
		.x_encoder_b_out(x_encoder_b_out),
		.x_encoder_z_out(x_encoder_z_out),
		
		.zero_flag(x_zero_flag),
		.x_data_out_en(x_data_out_en),
		.x_data_out(x_data_out)
);

w_encoder_process_v2	w_encoder_process_inst(
		.clk(clk),
		.rst(rst),
		
        .cfg_spindle_width_i(cfg_spindle_width_i),
		.motion_en(motion_en),
		
		.w_encoder_clk_out(w_encoder_clk_out),
		.w_encoder_data_in(w_encoder_data_in),
		.w_encoder_clk_in(w_encoder_clk_in),
		.w_encoder_data_out(w_encoder_data_out),
		
		.w_data_out_en(w_data_out_en),
		.w_data_out(w_data_out),
		.w_data_error(w_data_error),
		.w_data_warn(w_data_warn)
);

// ila_motion	ila_motion_inst(
		// .clk(clk),
		// .probe0(x_zero_flag),
		// .probe1(x_data_out_en),
		// .probe2(x_data_out),
		// .probe3(w_data_out_en),
		// .probe4(w_data_out),
		// .probe5(w_data_error),
		// .probe6(w_data_warn)
// );

endmodule