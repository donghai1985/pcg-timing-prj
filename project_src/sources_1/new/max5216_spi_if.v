`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    2022/09/27 13:40:10
// Design Name: 
// Module Name:    max5216_spi_if 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module max5216_spi_if(
    input	wire		clk,		//
    input	wire		rst,
	
	input	wire		data_in_en,
	input	wire [15:0]	data_in,
	
    output	reg			spi_csn,
    output	reg			spi_clk,	//max 50M
    output	reg			spi_mosi,
	output	wire		clr_n,
	
	output	reg			spi_ok
);

localparam	CLK_DIV 	= 8'd9;
localparam	CLK_DIV_2	= 8'd4;

reg [7:0]	spi_counter;
reg [5:0]	spi_clk_cnt;

reg [3:0]	state;

reg [23:0] 	data_in_temp;

assign		clr_n	=	1'b1;


always @(posedge clk)begin
	if(rst) begin	
		spi_counter <= 'd0;
	end
	else if(state == 'd1) begin
		if(spi_counter == CLK_DIV) begin
			spi_counter	<= 'd0;
		end
		else begin
			spi_counter <= spi_counter + 1'd1;
		end
	end
	else begin
		spi_counter <= 'd0;
	end
end

always @(posedge clk)begin
	if(rst) begin
		state	<=	'd0;
	end
	else begin
		case(state)
		4'd0: begin
			if(data_in_en) begin
				state	<=	state + 1'd1;
			end
			else begin
				state	<=	'd0;
			end
		end
		4'd1: begin
			if((spi_clk_cnt == 6'd24)&&(spi_counter == CLK_DIV_2)) begin
				state	<=	state + 1'd1;
			end
			else begin
				state	<=	state;
			end
		end
		4'd2: begin
			if(spi_clk_cnt == 6'd12) begin
				state	<=	'd0;
			end
			else begin
				state	<=	state;
			end
		end
		default: begin
			state	<=	'd0;
		end
		endcase
	end
end


always @(posedge clk)begin
	if(rst) begin
		spi_csn		<=	1'b1;
		spi_clk		<=	1'b0;
		spi_clk_cnt	<=	6'd0;
		spi_mosi	<=	1'b0;
		spi_ok		<=	1'b0;
		data_in_temp<=	'd0;
	end
	else begin
	case(state)
	4'd0: begin
		
		spi_clk		<=	1'b0;
		spi_clk_cnt	<=	6'd0;
		spi_mosi	<=	1'b0;
		spi_ok		<=	1'b0;
		if(data_in_en) begin
			spi_csn		<=	1'b0;
			data_in_temp<=	{2'b01,data_in,6'd0};
		end
		else begin
			spi_csn		<=	1'b1;
			data_in_temp<=	'd0;
		end
	end
	4'd1: begin
        spi_csn		<=	1'b0;
		spi_ok		<=	1'b0;
		if((spi_clk_cnt == 6'd24)&&(spi_counter == CLK_DIV_2)) begin
			spi_clk		<=	1'b0;
			spi_clk_cnt	<=	6'd0;
		end
		else if(spi_counter == CLK_DIV_2) begin
			spi_clk		<=	1'b1;
			spi_clk_cnt	<=	spi_clk_cnt + 6'd1;
		end
		else if(spi_counter == CLK_DIV) begin
			spi_clk		<=	1'b0;
			spi_clk_cnt	<=	spi_clk_cnt;
		end
		else begin
			spi_clk		<=	spi_clk;
			spi_clk_cnt	<=	spi_clk_cnt;
		end
		
		if((spi_clk_cnt <= 6'd23) && (spi_counter == CLK_DIV_2)) begin
			spi_mosi	<=	data_in_temp[23];
			data_in_temp<=	{data_in_temp[22:0],data_in_temp[23]};
		end
		else begin
			spi_mosi	<=	spi_mosi;
			data_in_temp<=	data_in_temp;
		end
	end
	4'd2: begin
		spi_csn		<=	1'b1;
		spi_clk		<=	1'b0;
		spi_mosi	<=	1'b0;
		data_in_temp<=	'd0;

		if(spi_clk_cnt == 6'd12) begin
			spi_ok		<=	1'b1;
			spi_clk_cnt	<=	6'd0;
		end
		else begin
			spi_ok		<=	1'b0;
			spi_clk_cnt	<=	spi_clk_cnt + 1'd1;
		end
	end	
	default: begin
		spi_csn		<=	1'b1;
		spi_clk		<=	1'b0;
		spi_clk_cnt	<=	6'd0;
		spi_mosi	<=	1'b0;
		spi_ok		<=	1'b0;
		data_in_temp<=	'd0;
	end
	endcase
	end

end



endmodule
