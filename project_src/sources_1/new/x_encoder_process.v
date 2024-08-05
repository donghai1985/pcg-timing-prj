`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/11 8:40:10
// Design Name: 
// Module Name: x_encoder_process
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

module x_encoder_process(
		input	wire		clk,
		input	wire		rst,

        input   wire        x_encode_zero_calib_i,
		
		input	wire		x_encoder_a_in,
		input	wire		x_encoder_b_in,
		input	wire 		x_encoder_z_in,
		output	wire 		x_encoder_a_out,
		output	wire 		x_encoder_b_out,
		output	wire		x_encoder_z_out,
		
		output	reg			zero_flag,
		output	reg			x_data_out_en,
		output  reg [31:0]  x_data_out

);

assign		x_encoder_a_out 	= 	x_encoder_a_in;
assign		x_encoder_b_out		=	x_encoder_b_in;
assign		x_encoder_z_out		=	x_encoder_z_in;

reg			x_encoder_a_reg1;
reg			x_encoder_a_reg2;
reg			x_encoder_a_reg3;
wire		up_edge_x_encoder_a;
wire		down_edge_x_encoder_a;
reg			x_encoder_b_reg1;
reg			x_encoder_b_reg2;
reg			x_encoder_b_reg3;
wire		up_edge_x_encoder_b;
wire		down_edge_x_encoder_b;
reg			x_encoder_z_reg1;
reg			x_encoder_z_reg2;
reg			x_encoder_z_reg3;
wire		up_edge_x_encoder_z;
wire		down_edge_x_encoder_z;

reg         x_encoder_zero_cali_d0 = 'd0;
reg         x_encoder_zero_cali_d1 = 'd0;
reg         x_encoder_zero_cali_d2 = 'd0;
wire        x_encode_zero_flag ;
reg			find_zero;

always	@(posedge clk)
begin
	if(rst) begin
		x_encoder_a_reg1	<=	1'b0;
		x_encoder_a_reg2	<=	1'b0;
		x_encoder_a_reg3	<=	1'b0;
		x_encoder_b_reg1	<=	1'b0;
		x_encoder_b_reg2	<=	1'b0;
		x_encoder_b_reg3	<=	1'b0;
		x_encoder_z_reg1	<=	1'b0;
		x_encoder_z_reg2	<=	1'b0;
		x_encoder_z_reg3	<=	1'b0;
        x_encoder_zero_cali_d0 <= 'd0;
        x_encoder_zero_cali_d1 <= 'd0;
        x_encoder_zero_cali_d2 <= 'd0;
	end
	else begin
		x_encoder_a_reg1	<=	x_encoder_a_in;
		x_encoder_a_reg2	<=	x_encoder_a_reg1;
		x_encoder_a_reg3	<=	x_encoder_a_reg2;
		x_encoder_b_reg1	<=	x_encoder_b_in;
		x_encoder_b_reg2	<=	x_encoder_b_reg1;
		x_encoder_b_reg3	<=	x_encoder_b_reg2;
		x_encoder_z_reg1	<=	x_encoder_z_in;
		x_encoder_z_reg2	<=	x_encoder_z_reg1;
		x_encoder_z_reg3	<=	x_encoder_z_reg2;
        x_encoder_zero_cali_d0 <= x_encode_zero_calib_i;
        x_encoder_zero_cali_d1 <= x_encoder_zero_cali_d0;
        x_encoder_zero_cali_d2 <= x_encoder_zero_cali_d1;
	end
end

assign		up_edge_x_encoder_a		=	x_encoder_a_reg2 && (~x_encoder_a_reg3);
assign		down_edge_x_encoder_a	=	(~x_encoder_a_reg2) && x_encoder_a_reg3;
assign		up_edge_x_encoder_b		=	x_encoder_b_reg2 && (~x_encoder_b_reg3);
assign		down_edge_x_encoder_b	=	(~x_encoder_b_reg2) && x_encoder_b_reg3;
assign		up_edge_x_encoder_z		=	x_encoder_z_reg2 && (~x_encoder_z_reg3);
assign		down_edge_x_encoder_z	=	(~x_encoder_z_reg2) && x_encoder_z_reg3;

assign      x_encode_zero_flag      = x_encoder_zero_cali_d1 && (~x_encoder_zero_cali_d2);

always	@(posedge clk)
begin
	if(rst) begin
		zero_flag		<=	1'b0;
		find_zero		<=	1'b0;
		x_data_out_en	<=	1'b0;
		x_data_out		<=	'd0;
	end
	else if(x_encode_zero_flag) begin
		zero_flag		<=	1'b1;
		find_zero		<=	1'b1;
		x_data_out_en	<=	1'b1;
		x_data_out		<=	'd0;
	end
	// else if(find_zero) begin
	else begin
		zero_flag		<=	1'b0;
		find_zero		<=	1'b1;
		if(up_edge_x_encoder_a && (~x_encoder_b_reg2)) begin
			x_data_out_en	<=	1'b1;
			x_data_out		<=	x_data_out + 1'd1;
		end
		else if(up_edge_x_encoder_a && x_encoder_b_reg2) begin
			x_data_out_en	<=	1'b1;
			x_data_out		<=	x_data_out - 1'd1;
		end
		else if(down_edge_x_encoder_a && x_encoder_b_reg2) begin
			x_data_out_en	<=	1'b1;
			x_data_out		<=	x_data_out + 1'd1;
		end
		else if(down_edge_x_encoder_a && (~x_encoder_b_reg2)) begin
			x_data_out_en	<=	1'b1;
			x_data_out		<=	x_data_out - 1'd1;
		end
		else if(up_edge_x_encoder_b && (~x_encoder_a_reg2)) begin
			x_data_out_en	<=	1'b1;
			x_data_out		<=	x_data_out - 1'd1;
		end
		else if(up_edge_x_encoder_b && x_encoder_a_reg2) begin
			x_data_out_en	<=	1'b1;
			x_data_out		<=	x_data_out + 1'd1;
		end
		else if(down_edge_x_encoder_b && x_encoder_a_reg2) begin
			x_data_out_en	<=	1'b1;
			x_data_out		<=	x_data_out - 1'd1;
		end
		else if(down_edge_x_encoder_b && (~x_encoder_a_reg2)) begin
			x_data_out_en	<=	1'b1;
			x_data_out		<=	x_data_out + 1'd1;
		end
		else begin
			x_data_out_en	<=	1'b0;
			x_data_out		<=	x_data_out;
		end
	end
	// else begin
		// zero_flag		<=	1'b0;
		// find_zero		<=	1'b0;
		// x_data_out_en	<=	1'b0;
		// x_data_out		<=	'd0;
	// end
end

endmodule