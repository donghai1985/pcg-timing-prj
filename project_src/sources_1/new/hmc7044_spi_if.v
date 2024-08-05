`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    2022/09/27 13:40:10
// Design Name: 
// Module Name:    hmc7044_spi_if 
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
module hmc7044_spi_if(
    clk,		//
    rst_n,

    wr_data_en,
	wr_data,
	
	rd_add_en,
	rd_add,
	
    spi_csn,
    spi_clk,
    spi_data,
	
	spi_busy,
	
	rd_data_en,
	rd_data
	
    );
	

input clk;
input rst_n;

input wr_data_en;
input [23:0] wr_data;
input rd_add_en;
input [12:0] rd_add;

output reg spi_csn;
output reg spi_clk;
inout spi_data;	
	
output reg 	spi_busy;

output reg 	rd_data_en;
output reg [7:0] rd_data;


reg [7:0]	spi_counter;
reg [7:0]	spi_clk_cnt;
reg			spi_mosi;

reg [3:0]	state;

reg [23:0] 	conif_data;

assign		spi_data = ((state == 'd1) || (state == 'd4)) ? spi_mosi : 1'bz;

always @(posedge clk or negedge rst_n)begin
	if(rst_n == 1'b0) begin	
		spi_counter <= 'd0;
	end
	else if(spi_csn ==1'b1) begin
		spi_counter <= 'd0;
	end
	else if(spi_counter == 'd11) begin
		spi_counter <= 'd0;
	end
	else begin
		spi_counter <= spi_counter + 'd1;
	end
end


always @(posedge clk or negedge rst_n)begin
	if(rst_n == 1'b0) begin
		spi_csn		<=	1'b1;
		spi_clk		<=	1'b0;
		spi_mosi	<=	1'b0;

		state		<=	4'd0;
		
		spi_clk_cnt	<=	'd0;
		conif_data  <=  'd0;
		
		rd_data_en	<=	1'b0;
		rd_data		<=	8'd0;

		spi_busy	<=	1'b0;
	end
	else begin
	case(state)
	4'd0: begin
	    spi_clk		<=	1'b0;
		spi_clk_cnt	<=	'd0;
		rd_data_en	<=	1'b0;
		rd_data		<=	rd_data;

		if(wr_data_en) begin
			state		<=	4'd1;
			spi_csn		<=	1'b0;
			spi_mosi	<=	wr_data[23];
			conif_data	<=	{wr_data[22:0],wr_data[23]};
			spi_busy	<=	1'b1;
		end
		else if(rd_add_en) begin
			state		<=	4'd4;
			spi_csn		<=	1'b0;
			spi_mosi	<=	1'b1;
			conif_data	<=	{2'b00,rd_add,8'd0,1'b0};
			spi_busy	<=	1'b1;
		end
		else begin
			state		<=	4'd0;
			spi_csn		<=	1'b1;
			spi_mosi	<=	1'b0;
			conif_data	<=	'd0;
			spi_busy	<=	1'b0;
		end
	end
	4'd1: begin
        spi_csn		<=	1'b0;	
	    spi_busy	<=	1'b1;
		rd_data_en	<=	1'b0;
		rd_data		<=	8'd0;
		
		if((spi_clk_cnt == 'd24)&&(spi_counter == 'd11)) begin
			spi_clk		<=	1'b0;
			spi_clk_cnt	<=	'd0;
			spi_mosi	<=	1'b0;
			conif_data	<=	'd0;
		end
		else if(spi_counter == 'd11) begin
			spi_clk		<=	1'b0;
			spi_clk_cnt	<=	spi_clk_cnt;
			spi_mosi	<=	conif_data[23];
			conif_data	<=	{conif_data[22:0],conif_data[23]};
		end
		else if(spi_counter == 'd5) begin
			spi_clk		<=	1'b1;

			spi_clk_cnt	<=	spi_clk_cnt + 'd1;
			spi_mosi	<=	spi_mosi;
			conif_data	<=	conif_data;
		end
		else begin
			spi_clk		<=	spi_clk;
			spi_clk_cnt	<=	spi_clk_cnt;
			spi_mosi	<=	spi_mosi;
			conif_data	<=	conif_data;
		end
		
		if((spi_clk_cnt == 'd24)&&(spi_counter == 'd11)) begin
			state		<=	4'd2;
		end
		else begin
			state		<=	state;
		end
	end
	4'd2: begin
	    spi_clk		<=	1'b0;
		spi_mosi	<=	1'b0;
		conif_data	<=	'd0;
		spi_busy	<=	1'b1;
		spi_clk_cnt	<=	'd0;
		rd_data_en	<=	1'b0;
		rd_data		<=	8'd0;
		
		if(spi_counter == 'd5) begin
			spi_csn		<=	1'b1;
			state		<=	4'd3;
		end
		else begin
			spi_csn		<=	spi_csn;
			state		<=	state;
		end
	end	
	4'd3: begin
		spi_clk		<=	1'b0;
        spi_mosi	<=	1'b0;
		spi_csn		<=	1'b1;
		conif_data	<=	'd0;
		rd_data_en	<=	1'b0;
		rd_data		<=	8'd0;
		
		if(spi_clk_cnt == 'd50) begin
			spi_clk_cnt	<=	'd0;
			state		<=	4'd0;
			spi_busy	<=	1'b0;
		end
		else begin
			spi_clk_cnt	<=	spi_clk_cnt + 'd1;
			state		<=	state;
			spi_busy	<=	spi_busy;
		end
	end
	
	4'd4: begin
        spi_csn		<=	1'b0;	
	    spi_busy	<=	1'b1;
		rd_data_en	<=	1'b0;
		rd_data		<=	8'd0;
		if(spi_counter == 'd11) begin
			spi_clk		<=	1'b0;
			spi_clk_cnt	<=	spi_clk_cnt;
			spi_mosi	<=	conif_data[23];
			conif_data	<=	{conif_data[22:0],conif_data[23]};
		end
		else if(spi_counter == 'd5) begin
			spi_clk		<=	1'b1;
			spi_clk_cnt	<=	spi_clk_cnt + 'd1;
			spi_mosi	<=	spi_mosi;
			conif_data	<=	conif_data;
		end
		else begin
			spi_clk		<=	spi_clk;
			spi_clk_cnt	<=	spi_clk_cnt;
			spi_mosi	<=	spi_mosi;
			conif_data	<=	conif_data;
		end
		
		if((spi_clk_cnt == 'd16)&&(spi_counter == 'd8)) begin
			state		<=	4'd5;
		end
		else begin
			state		<=	state;
		end
	end
	4'd5: begin
        spi_csn		<=	1'b0;	
	    spi_busy	<=	1'b1;
		spi_mosi	<=	1'b0;
		conif_data	<=	'd0;
		rd_data_en	<=	1'b0;
		
		if(spi_counter == 'd11) begin
			spi_clk		<=	1'b0;
			spi_clk_cnt	<=	spi_clk_cnt;
			rd_data		<=	rd_data;
		end
		else if(spi_counter == 'd5) begin
			spi_clk		<=	1'b1;
			spi_clk_cnt	<=	spi_clk_cnt + 'd1;
			rd_data		<=	{rd_data[6:0],spi_data};
		end
		else begin
			spi_clk		<=	spi_clk;
			spi_clk_cnt	<=	spi_clk_cnt;
			rd_data		<=	rd_data;
		end
		
		if((spi_clk_cnt == 'd24)&&(spi_counter == 'd11)) begin
			state		<=	4'd6;
		end
		else begin
			state		<=	state;
		end
	end
	4'd6: begin
	    spi_clk		<=	1'b0;
		spi_mosi	<=	1'b0;
		conif_data	<=	'd0;
		spi_busy	<=	1'b1;
		spi_clk_cnt	<=	'd0;
		rd_data_en	<=	1'b0;
		rd_data		<=	rd_data;
		
		if(spi_counter == 'd5) begin
			spi_csn		<=	1'b1;
			state		<=	4'd7;
		end
		else begin
			spi_csn		<=	spi_csn;
			state		<=	state;
		end
	end	
	4'd7: begin
		spi_clk		<=	1'b0;
        spi_mosi	<=	1'b0;
		spi_csn		<=	1'b1;
		conif_data	<=	'd0;
		rd_data		<=	rd_data;
		
		if(spi_clk_cnt == 'd50) begin
			spi_clk_cnt	<=	'd0;
			state		<=	4'd0;
			spi_busy	<=	1'b0;
			rd_data_en	<=	1'b1;
		end
		else begin
			spi_clk_cnt	<=	spi_clk_cnt + 'd1;
			state		<=	state;
			spi_busy	<=	spi_busy;
			rd_data_en	<=	1'b0;
		end
	end
	default: begin
		spi_csn		<=	1'b1;
		spi_clk		<=	1'b0;
		spi_mosi	<=	1'b0;
		state		<=	4'd0;
		spi_clk_cnt	<=	'd0;
		conif_data  <=  'd0;
		spi_busy	<=	1'b0;
		rd_data_en	<=	1'b0;
		rd_data		<=	8'd0;
	end
	endcase
	end

end



endmodule
