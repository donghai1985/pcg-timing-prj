`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    2022/09/27 13:40:10
// Design Name: 
// Module Name:    ad7680_spi_if 
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
module ad7680_spi_if(
    input	wire		clk,		//
    input	wire		rst,
	
	input	wire		adc_rd_en,
	
    output	reg			spi_csn,
    output	reg			spi_clk,	//max 2.5M, min 250K
    input	wire		spi_miso,
	
	output	reg			data_out_en,
	output	reg [15:0]	data_out
	
);

localparam	CLK_DIV 	= 8'd49;
localparam	CLK_DIV_2	= 8'd24;

reg [7:0]	spi_counter;
reg [5:0]	spi_clk_cnt;

reg [3:0]	state;

reg			adc_rd_en_reg1;
reg			adc_rd_en_reg2;
wire		up_edge_adc_rd_en;

always @(posedge clk)begin
	if(rst) begin
		adc_rd_en_reg1	<=	1'b0;
		adc_rd_en_reg2	<=	1'b0;
	end
	else begin
		adc_rd_en_reg1	<=	adc_rd_en;
		adc_rd_en_reg2	<=	adc_rd_en_reg1;
	end
end

assign	up_edge_adc_rd_en = adc_rd_en_reg1 && (~adc_rd_en_reg2);

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
			if(up_edge_adc_rd_en) begin
				state	<=	state + 1'd1;
			end
			else begin
				state	<=	'd0;
			end
		end
		4'd1: begin
			if((spi_clk_cnt == 6'd20)&&(spi_counter == CLK_DIV_2)) begin
				state	<=	state + 1'd1;
			end
			else begin
				state	<=	state;
			end
		end
		4'd2: begin
			if(spi_clk_cnt == 6'd6) begin
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
		data_out_en	<=	1'b0;
		data_out	<=	'd0;
	end
	else begin
	case(state)
	4'd0: begin
		spi_csn		<=	1'b1;
		spi_clk		<=	1'b0;
		spi_clk_cnt	<=	6'd0;
		data_out_en	<=	1'b0;
		if(up_edge_adc_rd_en) begin
			data_out	<=	'd0;
		end
		else begin
			data_out	<=	data_out;
		end
	end
	4'd1: begin
        data_out_en	<=	1'b0;
		
		if((spi_clk_cnt == 6'd20)&&(spi_counter == CLK_DIV_2)) begin
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
		
		if((spi_clk_cnt == 6'd0)&&(spi_counter == CLK_DIV_2)) begin
			spi_csn		<=	1'b0;
		end
		else begin
			spi_csn		<=	spi_csn;	
		end
		
		if((spi_clk_cnt >= 6'd4) && (spi_clk_cnt <= 6'd19) && (spi_counter == CLK_DIV_2)) begin
			data_out	<=	{data_out[14:0],spi_miso};
		end
		else begin
			data_out	<=	data_out;
		end
	end
	4'd2: begin
		spi_csn		<=	1'b1;
		spi_clk		<=	1'b0;		
		data_out	<=	data_out;
		if(spi_clk_cnt == 6'd6) begin
			data_out_en	<=	1'b1;
			spi_clk_cnt	<=	6'd0;
		end
		else begin
			data_out_en	<=	1'b0;
			spi_clk_cnt	<=	spi_clk_cnt + 1'd1;
		end
	end	
	default: begin
		spi_csn		<=	1'b1;
		spi_clk		<=	1'b0;
		spi_clk_cnt	<=	6'd0;
		data_out_en	<=	1'b0;
		data_out	<=	'd0;
	end
	endcase
	end

end



endmodule
