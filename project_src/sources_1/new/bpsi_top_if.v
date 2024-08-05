`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/11 8:40:10
// Design Name: 
// Module Name: bpsi_top_if
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


module bpsi_top_if(
		input	wire		clk,
		input	wire		clk_h,
		input	wire		rst,
		
		input	wire		data_acq_en,
		input	wire		bg_data_acq_en,
		input	wire [24:0]	position_arm,
		input	wire [22:0]	kp,
		input	wire [1:0]	motor_freq,
		input	wire		position_test_en,
		
		output	reg			motor_data_in_en,
		output 	reg	 [15:0]	motor_data_in,
		output	reg			motor_rd_en,
		input	wire		motor_data_out_en,
		input	wire [15:0]	motor_data_out,
		
		//spi if
		output	reg			spi_clk,
		output	reg			spi_mosi,
		
		input	wire		to_spi_clk,
		input	wire		to_spi_mosi,

        output  wire        position_actual_en_o    ,
        output  wire [15:0] motor_feed_data_o       ,
        output  wire [24:0] position_actual_o       ,
        output  wire [24:0] delta_position_o        ,
        output  wire [15:0] motor_data_in_o         ,
		
        output  wire        position_actual_avg_en_o ,
		output	reg	 [24:0]	position_actual_avg,
		
		output	wire		data_out_en,
		output	wire [23:0]	data_out_a,
		output	wire [23:0]	data_out_b,	
		
        output  wire        bg_data_en_o ,
		output	reg	 [23:0]	bg_data_a,
		output	reg  [23:0]	bg_data_b

);

localparam		TIMEOUT_LENGTH	=	16'd300;	// > 300M/50M * 48

reg				spi_csn;
reg		[63:0]	tx_data;
reg		[15:0]	tx_data_length;

reg		[3:0]	tx_state;
reg		[15:0]	tx_clk_cnt;
reg		[3:0]	spi_counter;

reg				data_acq_en_reg;
reg				bg_data_acq_en_reg;
reg				position_test_en_reg;

reg				set_data_acq_en;
reg				set_bg_data_acq_en;
reg				set_position_test_en;

always @(posedge clk_h or posedge rst)begin
	if(rst) begin	
		data_acq_en_reg			<=	1'b0;
		bg_data_acq_en_reg		<=	1'b0;
		position_test_en_reg	<=	1'b0;
	end
	else begin
		data_acq_en_reg			<=	data_acq_en;
		bg_data_acq_en_reg		<=	bg_data_acq_en;
		position_test_en_reg	<=	position_test_en;
	end
end

always @(posedge clk_h or posedge rst)begin
	if(rst) begin	
		set_data_acq_en			<=	1'b0;
		set_bg_data_acq_en		<=	1'b0;
		set_position_test_en	<=	1'b0;
	end
	else begin
		if(data_acq_en_reg == data_acq_en) begin
			set_data_acq_en		<=	1'b0;
		end
		else begin
			set_data_acq_en		<=	1'b1;
		end
		
		if(bg_data_acq_en_reg == bg_data_acq_en) begin
			set_bg_data_acq_en	<=	1'b0;
		end
		else begin
			set_bg_data_acq_en	<=	1'b1;
		end
		
		if(position_test_en_reg == position_test_en) begin
			set_position_test_en	<=	1'b0;
		end
		else begin
			set_position_test_en	<=	1'b1;
		end
	end
end

always @(posedge clk_h or posedge rst)begin
	if(rst) begin	
		spi_counter <= 'd0;
	end
	else if(spi_csn ==1'b1) begin
		spi_counter <= 'd0;
	end
	else if(spi_counter == 'd5)
		spi_counter <= 'd0;
	else begin
		spi_counter <= spi_counter + 1'd1;
	end
end


always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		tx_state	<=	'd0;
	end
	else begin
		case(tx_state)
		4'd0: begin
			if(set_data_acq_en || set_bg_data_acq_en || set_position_test_en) begin
				tx_state	<=	'd1;
			end
			else begin
				tx_state	<=	'd0;
			end
		end
		4'd1: begin
			tx_state	<=	'd2;
		end
		4'd2: begin
			if((spi_counter == 'd5) && (tx_clk_cnt == tx_data_length - 'd1)) begin
				tx_state	<=	'd3;
			end
			else begin
				tx_state	<=	tx_state;
			end
		end
		4'd3: begin
			tx_state	<=	'd0;
		end
		default: begin
			tx_state	<=	'd0;
		end
		endcase
	end
end


always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		spi_clk			<=	1'b0;
		spi_csn			<=	1'b1;
		spi_mosi		<=	1'b0;
		tx_data			<=	'd0;
		tx_data_length	<=	'd0;
		tx_clk_cnt		<=	'd0;
	end
	else begin
		case(tx_state)
		4'd0: begin
			spi_clk		<=	1'b0;
			spi_csn		<=	1'b1;
			spi_mosi	<=	1'b0;
			tx_clk_cnt	<=	'd0;
			if(set_data_acq_en) begin
				tx_data			<=	{16'h55aa,16'h0001,15'h0,data_acq_en_reg,16'd0};
				tx_data_length	<=	'd48;
			end
			else if(set_bg_data_acq_en) begin
				tx_data			<=	{16'h55aa,16'h0001,15'h0,bg_data_acq_en_reg,16'd0};
				tx_data_length	<=	'd48;
			end
			else if(set_position_test_en) begin
				tx_data			<=	{16'h55aa,16'h0001,15'h0,position_test_en_reg,16'd0};
				tx_data_length	<=	'd48;
			end
			else begin
				tx_data			<=	'd0;
				tx_data_length	<=	'd0;
			end
		end
		4'd1: begin
			spi_clk			<=	1'b0;
			tx_clk_cnt		<=	'd0;
			spi_csn			<=	1'b0;
			spi_mosi		<=	tx_data[63];
			tx_data			<=	{tx_data[62:0],tx_data[63]};
			tx_data_length	<=	tx_data_length;
		end
		4'd2: begin
			spi_csn			<=	1'b0;
			tx_data_length	<=	tx_data_length;
			if((spi_counter == 'd5) && (tx_clk_cnt == tx_data_length - 'd1)) begin
				tx_clk_cnt	<=	'd0;
				spi_mosi	<=	1'b0;
				spi_clk		<=	1'd0;
				tx_data		<=	'd0;
			end
			else if(spi_counter == 'd5) begin
				tx_clk_cnt	<=	tx_clk_cnt + 'd1;
				spi_mosi	<=	tx_data[63];
				spi_clk		<=	1'b0;
				tx_data		<=	{tx_data[62:0],tx_data[63]};
			end
			else if(spi_counter == 'd2)begin
				tx_clk_cnt	<=	tx_clk_cnt;
				spi_mosi	<=	spi_mosi;
				spi_clk		<=	1'b1;
				tx_data		<=	tx_data;
			end
			else begin
				tx_clk_cnt	<=	tx_clk_cnt;
				spi_mosi	<=	spi_mosi;
				spi_clk		<=	spi_clk;
				tx_data		<=	tx_data;
			end
		end			
		4'd3: begin
			spi_clk			<=	1'b0;
			spi_csn			<=	1'b1;
			spi_mosi		<=	1'b0;
			tx_data			<=	'd0;
			tx_data_length	<=	'd0;
			tx_clk_cnt		<=	'd0;
		end
		default: begin
			spi_clk			<=	1'b0;
			spi_csn			<=	1'b1;
			spi_mosi		<=	1'b0;
			tx_data			<=	'd0;
			tx_data_length	<=	'd0;
			tx_clk_cnt		<=	'd0;
		end
		endcase
	end
end


//////////////////////////////////////////

localparam	BG_SUM_LENGTH			=	16'd8191;		//8s
localparam	POSITION_AVG_SUM_LENGTH	=	16'd8191;		//8s

reg		[3:0]	rx_state;
reg		[15:0]	rx_clk_cnt;
reg		[15:0]	timeout_cnt;

reg				rx_en_temp;
reg		[47:0]	rx_data_temp;

reg				to_spi_clk_reg1;
reg				to_spi_clk_reg2;
wire			up_edge_to_spi_clk;

wire	[23:0]	actual_data_a;
wire	[23:0]	actual_data_b;
reg				comp_data_en;
reg		[23:0]	comp_data_a;
reg		[23:0]	comp_data_b;

reg		[39:0]	bg_data_a_pos_sum;
reg		[39:0]	bg_data_a_neg_sum;
reg		[39:0]	bg_data_b_pos_sum;
reg		[39:0]	bg_data_b_neg_sum;
reg		[15:0]	bg_sum_cnt;

reg		[3:0]	bg_state;

reg				position_test_out_en;

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		to_spi_clk_reg1	<=	1'b0;
		to_spi_clk_reg2	<=	1'b0;
	end
	else begin
		to_spi_clk_reg1	<=	to_spi_clk;
		to_spi_clk_reg2	<=	to_spi_clk_reg1;
	end
end
assign		up_edge_to_spi_clk		= 	to_spi_clk_reg1 && (~to_spi_clk_reg2);

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		rx_state	<=	'd0;
	end
	else begin
		case(rx_state)
		4'd0: begin
			if(up_edge_to_spi_clk)begin
				rx_state	<=	'd1;
			end
			else begin
				rx_state	<=	'd0;
			end
		end
		4'd1: begin
			if(timeout_cnt == TIMEOUT_LENGTH) begin
				rx_state	<=	'd0;
			end
			else if(up_edge_to_spi_clk && (rx_clk_cnt == 'd47))begin
				rx_state	<=	'd0;
			end
			else begin
				rx_state	<=	'd1;
			end
		end
		default: begin
			rx_state	<=	'd0;
		end
		endcase
	end
end


always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		rx_data_temp<=	'd0;
		rx_en_temp	<=	1'b0;
		rx_clk_cnt	<=	'd0;
		timeout_cnt	<=	'd0;
	end
	else begin
		case(rx_state)
		4'd0: begin
			rx_en_temp	<=	1'b0;
			timeout_cnt	<=	'd0;
			if(up_edge_to_spi_clk) begin
				rx_data_temp<=	{rx_data_temp[46:0],to_spi_mosi};
				rx_clk_cnt	<=	rx_clk_cnt + 'd1;
			end
			else begin
				rx_data_temp<=	rx_data_temp;
				rx_clk_cnt	<=	'd0;
			end
		end
		4'd1: begin
			if(timeout_cnt == TIMEOUT_LENGTH) begin
				rx_data_temp<=	'd0;
				rx_clk_cnt	<=	'd0;
				rx_en_temp	<=	1'b0;
				timeout_cnt	<=	'd0;
			end
			else if(up_edge_to_spi_clk && (rx_clk_cnt == 'd47))begin
				rx_data_temp<=	{rx_data_temp[46:0],to_spi_mosi};
				rx_clk_cnt	<=	'd0;
				rx_en_temp	<=	1'b1;
				timeout_cnt	<=	'd0;
			end
			else if(up_edge_to_spi_clk) begin
				rx_data_temp<=	{rx_data_temp[46:0],to_spi_mosi};
				rx_clk_cnt	<=	rx_clk_cnt + 'd1;
				rx_en_temp	<=	1'b0;
				timeout_cnt	<=	timeout_cnt + 'd1;
			end
			else begin
				rx_data_temp<=	rx_data_temp;
				rx_clk_cnt	<=	rx_clk_cnt;
				rx_en_temp	<=	1'b0;
				timeout_cnt	<=	timeout_cnt + 'd1;
			end
		end
		default: begin
			rx_data_temp<=	'd0;
			rx_en_temp	<=	1'b0;
			rx_clk_cnt	<=	'd0;
			timeout_cnt	<=	'd0;
		end
		endcase
	end
end

assign		actual_data_a	=	rx_data_temp[47:24];
assign		actual_data_b	=	rx_data_temp[23:0];


//////////////背景噪声计算
always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		bg_state	<=	'd0;
	end
	else if((~bg_data_acq_en_reg) && (~position_test_en_reg)) begin
		bg_state	<=	'd0;
	end
	else begin
		case(bg_state)
		4'd0: begin
			if(rx_en_temp) begin
				if(bg_data_acq_en_reg)
					bg_state	<=	'd1;
				else
					bg_state	<=	'd8;
			end
			else begin
				bg_state	<=	'd0;
			end
		end
		4'd1: begin
			if(rx_en_temp && (bg_sum_cnt == 'd499)) begin	//前0.5s的数据扔掉
				bg_state	<=	bg_state + 1'd1;
			end
			else begin
				bg_state	<=	bg_state;
			end
		end
		4'd2: begin
			if(rx_en_temp && (bg_sum_cnt == BG_SUM_LENGTH)) begin
				bg_state	<=	bg_state + 1'd1;
			end
			else begin
				bg_state	<=	bg_state;
			end
		end
		4'd3: begin
			bg_state	<=	bg_state + 1'd1;
		end
		4'd4: begin
			bg_state	<=	bg_state + 1'd1;
		end
		4'd5: begin
			bg_state	<=	bg_state;
		end
		
		4'd8: begin
			if(rx_en_temp && (bg_sum_cnt == 'd499)) begin	//前0.5s的数据扔掉
				bg_state	<=	bg_state + 1'd1;
			end
			else begin
				bg_state	<=	bg_state;
			end
		end
		4'd9: begin
			if(rx_en_temp && (bg_sum_cnt == POSITION_AVG_SUM_LENGTH)) begin
				bg_state	<=	bg_state + 1'd1;
			end
			else begin
				bg_state	<=	bg_state;
			end
		end
		4'd10: begin
			bg_state	<=	bg_state + 1'd1;
		end
		4'd11: begin
			bg_state	<=	bg_state + 1'd1;
		end
		4'd12: begin
			bg_state	<=	bg_state;
		end
		default: begin
			bg_state	<=	'd0;
		end
		endcase
	end
end

always	@(posedge clk_h or posedge rst)
begin
	if(rst) begin
		bg_data_a			<=	'd0;
		bg_data_a_pos_sum	<=	'd0;
		bg_data_a_neg_sum	<=	'd0;
		bg_data_b			<=	'd0;
		bg_data_b_pos_sum	<=	'd0;
		bg_data_b_neg_sum	<=	'd0;
		bg_sum_cnt			<=	'd0;
		position_test_out_en<=	1'b0;
	end
	else if((~bg_data_acq_en_reg) && (~position_test_en_reg)) begin
		bg_data_a			<=	bg_data_a;
		bg_data_a_pos_sum	<=	'd0;
		bg_data_a_neg_sum	<=	'd0;
		bg_data_b			<=	bg_data_b;
		bg_data_b_pos_sum	<=	'd0;
		bg_data_b_neg_sum	<=	'd0;
		bg_sum_cnt			<=	'd0;
		position_test_out_en<=	1'b0;
	end
	else begin
		case(bg_state)
		4'd0: begin
			bg_data_a			<=	'd0;
			bg_data_a_pos_sum	<=	'd0;
			bg_data_a_neg_sum	<=	'd0;
			bg_data_b			<=	'd0;
			bg_data_b_pos_sum	<=	'd0;
			bg_data_b_neg_sum	<=	'd0;
			position_test_out_en<=	1'b0;
			if(rx_en_temp) begin
				bg_sum_cnt			<=	bg_sum_cnt + 1'd1;
			end
			else begin
				bg_sum_cnt			<=	'd0;
			end
		end
		4'd1: begin
			bg_data_a			<=	'd0;
			bg_data_a_pos_sum	<=	'd0;
			bg_data_a_neg_sum	<=	'd0;
			bg_data_b			<=	'd0;
			bg_data_b_pos_sum	<=	'd0;
			bg_data_b_neg_sum	<=	'd0;
			if(rx_en_temp && (bg_sum_cnt == 'd499)) begin
				bg_sum_cnt			<=	'd0;
			end
			else if(rx_en_temp) begin
				bg_sum_cnt			<=	bg_sum_cnt + 1'd1;
			end
			else begin
				bg_sum_cnt			<=	bg_sum_cnt;
			end
		end
		4'd2: begin
			bg_data_a			<=	'd0;
			bg_data_b			<=	'd0;
			if(rx_en_temp) begin
				bg_sum_cnt			<=	bg_sum_cnt + 1'd1;
				
				if(actual_data_a[23]) begin
					bg_data_a_pos_sum	<=	bg_data_a_pos_sum;
					bg_data_a_neg_sum	<=	bg_data_a_neg_sum + (~actual_data_a + 1'd1);
				end
				else begin
					bg_data_a_pos_sum	<=	bg_data_a_pos_sum + actual_data_a;
					bg_data_a_neg_sum	<=	bg_data_a_neg_sum;
				end
				
				if(actual_data_b[23]) begin
					bg_data_b_pos_sum	<=	bg_data_b_pos_sum;
					bg_data_b_neg_sum	<=	bg_data_b_neg_sum + (~actual_data_b + 1'd1);
				end
				else begin
					bg_data_b_pos_sum	<=	bg_data_b_pos_sum + actual_data_b;
					bg_data_b_neg_sum	<=	bg_data_b_neg_sum;
				end
			end
			else begin
				bg_sum_cnt			<=	bg_sum_cnt;
				bg_data_a_pos_sum	<=	bg_data_a_pos_sum;
				bg_data_a_neg_sum	<=	bg_data_a_neg_sum;
				bg_data_b_pos_sum	<=	bg_data_b_pos_sum;
				bg_data_b_neg_sum	<=	bg_data_b_neg_sum;
			end
		end
		4'd3: begin
			bg_data_a			<=	'd0;
			bg_data_b			<=	'd0;
			bg_sum_cnt			<=	'd0;
			
			bg_data_a_neg_sum	<=	'd0;
			if(bg_data_a_pos_sum == bg_data_a_neg_sum) begin
				bg_data_a_pos_sum	<=	'd0;
			end
			else if(bg_data_a_pos_sum > bg_data_a_neg_sum) begin
				bg_data_a_pos_sum	<=	(bg_data_a_pos_sum - bg_data_a_neg_sum) >> 13;
			end
			else begin
				bg_data_a_pos_sum	<=	~((bg_data_a_neg_sum - bg_data_a_pos_sum) >> 13) + 1'd1;
			end
			
			bg_data_b_neg_sum	<=	'd0;
			if(bg_data_b_pos_sum == bg_data_b_neg_sum) begin
				bg_data_b_pos_sum	<=	'd0;
			end
			else if(bg_data_b_pos_sum > bg_data_b_neg_sum) begin
				bg_data_b_pos_sum	<=	(bg_data_b_pos_sum - bg_data_b_neg_sum) >> 13;
			end
			else begin
				bg_data_b_pos_sum	<=	~((bg_data_b_neg_sum - bg_data_b_pos_sum) >> 13) + 1'd1;
			end
		end
		4'd4: begin
			bg_data_a			<=	bg_data_a_pos_sum[23:0];
			bg_data_a_pos_sum	<=	'd0;
			bg_data_a_neg_sum	<=	'd0;
			bg_data_b			<=	bg_data_b_pos_sum[23:0];
			bg_data_b_pos_sum	<=	'd0;
			bg_data_b_neg_sum	<=	'd0;
			bg_sum_cnt			<=	'd0;
		end
		4'd5: begin
			bg_data_a			<=	bg_data_a;
			bg_data_a_pos_sum	<=	'd0;
			bg_data_a_neg_sum	<=	'd0;
			bg_data_b			<=	bg_data_b;
			bg_data_b_pos_sum	<=	'd0;
			bg_data_b_neg_sum	<=	'd0;
			bg_sum_cnt			<=	'd0;
		end
		
		4'd8: begin
			bg_data_a			<=	'd0;
			bg_data_a_pos_sum	<=	'd0;
			bg_data_a_neg_sum	<=	'd0;
			bg_data_b			<=	'd0;
			bg_data_b_pos_sum	<=	'd0;
			bg_data_b_neg_sum	<=	'd0;
			position_test_out_en<=	1'b0;
			if(rx_en_temp && (bg_sum_cnt == 'd499)) begin
				bg_sum_cnt			<=	'd0;
			end
			else if(rx_en_temp) begin
				bg_sum_cnt			<=	bg_sum_cnt + 1'd1;
			end
			else begin
				bg_sum_cnt			<=	bg_sum_cnt;
			end
		end
		4'd9: begin
			bg_data_a			<=	'd0;
			bg_data_b			<=	'd0;
			position_test_out_en<=	1'b0;
			if(rx_en_temp) begin
				bg_sum_cnt			<=	bg_sum_cnt + 1'd1;
				
				if(actual_data_a[23]) begin
					bg_data_a_pos_sum	<=	bg_data_a_pos_sum;
					bg_data_a_neg_sum	<=	bg_data_a_neg_sum + (~actual_data_a + 1'd1);
				end
				else begin
					bg_data_a_pos_sum	<=	bg_data_a_pos_sum + actual_data_a;
					bg_data_a_neg_sum	<=	bg_data_a_neg_sum;
				end
				
				if(actual_data_b[23]) begin
					bg_data_b_pos_sum	<=	bg_data_b_pos_sum;
					bg_data_b_neg_sum	<=	bg_data_b_neg_sum + (~actual_data_b + 1'd1);
				end
				else begin
					bg_data_b_pos_sum	<=	bg_data_b_pos_sum + actual_data_b;
					bg_data_b_neg_sum	<=	bg_data_b_neg_sum;
				end
			end
			else begin
				bg_sum_cnt			<=	bg_sum_cnt;
				bg_data_a_pos_sum	<=	bg_data_a_pos_sum;
				bg_data_a_neg_sum	<=	bg_data_a_neg_sum;
				bg_data_b_pos_sum	<=	bg_data_b_pos_sum;
				bg_data_b_neg_sum	<=	bg_data_b_neg_sum;
			end
		end
		4'd10: begin
			bg_data_a			<=	'd0;
			bg_data_b			<=	'd0;
			bg_sum_cnt			<=	'd0;
			position_test_out_en<=	1'b0;
			
			bg_data_a_neg_sum	<=	'd0;
			if(bg_data_a_pos_sum == bg_data_a_neg_sum) begin
				bg_data_a_pos_sum	<=	'd0;
			end
			else if(bg_data_a_pos_sum > bg_data_a_neg_sum) begin
				bg_data_a_pos_sum	<=	(bg_data_a_pos_sum - bg_data_a_neg_sum) >> 13;
			end
			else begin
				bg_data_a_pos_sum	<=	~((bg_data_a_neg_sum - bg_data_a_pos_sum) >> 13) + 1'd1;
			end
			
			bg_data_b_neg_sum	<=	'd0;
			if(bg_data_b_pos_sum == bg_data_b_neg_sum) begin
				bg_data_b_pos_sum	<=	'd0;
			end
			else if(bg_data_b_pos_sum > bg_data_b_neg_sum) begin
				bg_data_b_pos_sum	<=	(bg_data_b_pos_sum - bg_data_b_neg_sum) >> 13;
			end
			else begin
				bg_data_b_pos_sum	<=	~((bg_data_b_neg_sum - bg_data_b_pos_sum) >> 13) + 1'd1;
			end
		end
		4'd11: begin
			bg_data_a			<=	bg_data_a_pos_sum[23:0];
			bg_data_a_pos_sum	<=	'd0;
			bg_data_a_neg_sum	<=	'd0;
			bg_data_b			<=	bg_data_b_pos_sum[23:0];
			bg_data_b_pos_sum	<=	'd0;
			bg_data_b_neg_sum	<=	'd0;
			bg_sum_cnt			<=	'd0;
			position_test_out_en<=	1'b0;
		end
		4'd12: begin
			bg_data_a			<=	bg_data_a;
			bg_data_a_pos_sum	<=	'd0;
			bg_data_a_neg_sum	<=	'd0;
			bg_data_b			<=	bg_data_b;
			bg_data_b_pos_sum	<=	'd0;
			bg_data_b_neg_sum	<=	'd0;
			bg_sum_cnt			<=	'd0;
			position_test_out_en<=	1'b1;
		end
		default: begin
			bg_data_a			<=	'd0;
			bg_data_a_pos_sum	<=	'd0;
			bg_data_a_neg_sum	<=	'd0;
			bg_data_b			<=	'd0;
			bg_data_b_pos_sum	<=	'd0;
			bg_data_b_neg_sum	<=	'd0;
			bg_sum_cnt			<=	'd0;
			position_test_out_en<=	1'b0;
		end
		endcase
	end
end

//////////////////////////////

reg				rx_en_temp_exp;
reg				rx_en_temp_exp_reg1;
reg				rx_en_temp_exp_reg2;
reg 	[7:0]	rx_en_temp_exp_cnt;
wire			up_edg_rx_en_temp_exp;

reg				data_acq_en_sync;

reg				position_test_out_en_reg1;
reg				position_test_out_en_reg2;
wire			up_edge_position_test_out_en;

reg		[3:0]	motor_state;
reg				divider_in_en;
reg		[24:0]	divisor_data;
reg		[23:0]	dividend_data;
wire			divider_out_en;
wire	[47:0]	divider_out_data;

reg				divider_neg_flag;

reg		[24:0]	position_actual;
reg		[24:0]	delta_position;

reg				motor_set_pulse;
reg		[31:0]	motor_set_pulse_cnt;
reg		[15:0]	motor_feed_data;

wire	[47:0]	mult_result;
wire	[63:0]	mult_result_2;
reg		[7:0]	delay_cnt;

   xpm_cdc_pulse #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .REG_OUTPUT(0),     // DECIMAL; 0=disable registered output, 1=enable registered output
      .RST_USED(0),       // DECIMAL; 0=no reset, 1=implement reset
      .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   )
   xpm_cdc_rx_en_temp_inst (
      .dest_pulse(up_edg_rx_en_temp_exp), // 1-bit output: Outputs a pulse the size of one dest_clk period when a pulse
                               // transfer is correctly initiated on src_pulse input. This output is
                               // combinatorial unless REG_OUTPUT is set to 1.

      .dest_clk(clk),     // 1-bit input: Destination clock.
      .dest_rst(1'b0),     // 1-bit input: optional; required when RST_USED = 1
      .src_clk(clk_h),       // 1-bit input: Source clock.
      .src_pulse(rx_en_temp),   // 1-bit input: Rising edge of this signal initiates a pulse transfer to the
                               // destination clock domain. The minimum gap between each pulse transfer must be
                               // at the minimum 2*(larger(src_clk period, dest_clk period)). This is measured
                               // between the falling edge of a src_pulse to the rising edge of the next
                               // src_pulse. This minimum gap will guarantee that each rising edge of src_pulse
                               // will generate a pulse the size of one dest_clk period in the destination
                               // clock domain. When RST_USED = 1, pulse transfers will not be guaranteed while
                               // src_rst and/or dest_rst are asserted.

      .src_rst(1'b0)        // 1-bit input: optional; required when RST_USED = 1
   );

// always	@(posedge clk_h or posedge rst)
// begin
// 	if(rst) begin
// 		rx_en_temp_exp		<=	1'b0;
// 		rx_en_temp_exp_cnt	<=	'd0;
// 	end
// 	else if(rx_en_temp) begin
// 		rx_en_temp_exp		<=	1'b1;
// 		rx_en_temp_exp_cnt	<=	rx_en_temp_exp_cnt + 1'd1;
// 	end
// 	else if(rx_en_temp_exp_cnt == 'd5) begin
// 		rx_en_temp_exp		<=	1'b0;
// 		rx_en_temp_exp_cnt	<=	'd0;
// 	end
// 	else if(rx_en_temp_exp) begin
// 		rx_en_temp_exp		<=	1'b1;
// 		rx_en_temp_exp_cnt	<=	rx_en_temp_exp_cnt + 1'd1;
// 	end
// 	else begin
// 		rx_en_temp_exp		<=	1'b0;
// 		rx_en_temp_exp_cnt	<=	'd0;
// 	end
// end

// always	@(posedge clk or posedge rst)
// begin
// 	if(rst) begin
// 		rx_en_temp_exp_reg1	<=	1'b0;
// 		rx_en_temp_exp_reg2	<=	1'b0;
// 	end
// 	else begin
// 		rx_en_temp_exp_reg1	<=	rx_en_temp_exp;
// 		rx_en_temp_exp_reg2	<=	rx_en_temp_exp_reg1;
// 	end
// end

// assign	up_edg_rx_en_temp_exp = rx_en_temp_exp_reg1 && (~rx_en_temp_exp_reg2);

assign	data_out_en		=	up_edg_rx_en_temp_exp;
assign	data_out_a		=	actual_data_a;
assign	data_out_b		=	actual_data_b;

   xpm_cdc_pulse #(
      .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .REG_OUTPUT(0),     // DECIMAL; 0=disable registered output, 1=enable registered output
      .RST_USED(0),       // DECIMAL; 0=no reset, 1=implement reset
      .SIM_ASSERT_CHK(0)  // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   )
   xpm_cdc_pulse_bg_inst (
      .dest_pulse(up_edge_position_test_out_en), // 1-bit output: Outputs a pulse the size of one dest_clk period when a pulse
                               // transfer is correctly initiated on src_pulse input. This output is
                               // combinatorial unless REG_OUTPUT is set to 1.

      .dest_clk(clk),     // 1-bit input: Destination clock.
      .dest_rst(1'b0),     // 1-bit input: optional; required when RST_USED = 1
      .src_clk(clk_h),       // 1-bit input: Source clock.
      .src_pulse(position_test_out_en),   // 1-bit input: Rising edge of this signal initiates a pulse transfer to the
                               // destination clock domain. The minimum gap between each pulse transfer must be
                               // at the minimum 2*(larger(src_clk period, dest_clk period)). This is measured
                               // between the falling edge of a src_pulse to the rising edge of the next
                               // src_pulse. This minimum gap will guarantee that each rising edge of src_pulse
                               // will generate a pulse the size of one dest_clk period in the destination
                               // clock domain. When RST_USED = 1, pulse transfers will not be guaranteed while
                               // src_rst and/or dest_rst are asserted.

      .src_rst(1'b0)        // 1-bit input: optional; required when RST_USED = 1
   );

// always	@(posedge clk or posedge rst)
// begin
// 	if(rst) begin
// 		position_test_out_en_reg1	<=	1'b0;
// 		position_test_out_en_reg2	<=	1'b0;
// 	end
// 	else begin
// 		position_test_out_en_reg1	<=	position_test_out_en;
// 		position_test_out_en_reg2	<=	position_test_out_en_reg1;
// 	end
// end

// assign	up_edge_position_test_out_en	=	position_test_out_en_reg1 && (~position_test_out_en_reg2);
assign  bg_data_en_o                = up_edge_position_test_out_en;
assign  position_actual_en_o        = motor_set_pulse && data_acq_en_sync;
assign  position_actual_avg_en_o    = up_edge_position_test_out_en;

assign  motor_data_in_o             = motor_data_in     ;
assign  motor_feed_data_o           = motor_feed_data   ;
assign  position_actual_o           = position_actual   ;
assign  delta_position_o            = delta_position    ;


always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		data_acq_en_sync	<=	1'b0;
	end
	else begin
		data_acq_en_sync	<=	data_acq_en;
	end
end

always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		comp_data_en	<=	1'b0;
		comp_data_a		<=	'd0;
		comp_data_b		<=	'd0;
	end
	else if(~data_acq_en_sync) begin
		comp_data_en	<=	1'b0;
		comp_data_a		<=	'd0;
		comp_data_b		<=	'd0;
	end
	else if(up_edg_rx_en_temp_exp) begin
		comp_data_en	<=	1'b1;
		if((~actual_data_a[23]) && (~bg_data_a[23])) begin
			if(actual_data_a >= bg_data_a) begin
				comp_data_a	<=	actual_data_a - bg_data_a;
			end
			else begin
				comp_data_a	<=	~(bg_data_a - comp_data_a) + 1'd1;
			end
		end
		else if((~actual_data_a[23]) && bg_data_a[23]) begin
			comp_data_a	<=	actual_data_a + (~bg_data_a) + 1'd1;
		end
		else if(actual_data_a[23] && (~bg_data_a[23])) begin
			comp_data_a	<=	actual_data_a - bg_data_a;
		end
		else begin
			if(actual_data_a >= bg_data_a) begin
				comp_data_a	<=	actual_data_a - bg_data_a;
			end
			else begin
				comp_data_a	<=	~(bg_data_a - actual_data_a) + 1'd1;
			end
		end
		
		if((~actual_data_b[23]) && (~bg_data_b[23])) begin
			if(actual_data_b >= bg_data_b) begin
				comp_data_b	<=	actual_data_b - bg_data_b;
			end
			else begin
				comp_data_b	<=	~(bg_data_b - comp_data_b) + 1'd1;
			end
		end
		else if((~actual_data_b[23]) && bg_data_b[23]) begin
			comp_data_b	<=	actual_data_b + (~bg_data_b) + 1'd1;
		end
		else if(actual_data_b[23] && (~bg_data_b[23])) begin
			comp_data_b	<=	actual_data_b - bg_data_b;
		end
		else begin
			if(actual_data_b >= bg_data_b) begin
				comp_data_b	<=	actual_data_b - bg_data_b;
			end
			else begin
				comp_data_b	<=	~(bg_data_b - actual_data_b) + 1'd1;
			end
		end
	end
	else begin
		comp_data_en	<=	1'b0;
		comp_data_a		<=	comp_data_a;
		comp_data_b		<=	comp_data_b;
	end
end

always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		motor_set_pulse		<=	1'b0;
		motor_set_pulse_cnt	<=	'd0;
	end
	// else if(~data_acq_en_sync) begin
	// 	motor_set_pulse		<=	1'b0;
	// 	motor_set_pulse_cnt	<=	'd0;
	// end
	else begin
		case(motor_freq)
		2'd0: begin
			if(motor_set_pulse_cnt == 'd999999) begin
				motor_set_pulse		<=	1'b1;
				motor_set_pulse_cnt	<=	'd0;
			end
			else begin
				motor_set_pulse		<=	1'b0;
				motor_set_pulse_cnt	<=	motor_set_pulse_cnt + 1'd1;
			end
		end
		2'd1: begin
			if(motor_set_pulse_cnt == 'd499999) begin
				motor_set_pulse		<=	1'b1;
				motor_set_pulse_cnt	<=	'd0;
			end
			else begin
				motor_set_pulse		<=	1'b0;
				motor_set_pulse_cnt	<=	motor_set_pulse_cnt + 1'd1;
			end
		end
		2'd2: begin
			if(motor_set_pulse_cnt == 'd333332) begin
				motor_set_pulse		<=	1'b1;
				motor_set_pulse_cnt	<=	'd0;
			end
			else begin
				motor_set_pulse		<=	1'b0;
				motor_set_pulse_cnt	<=	motor_set_pulse_cnt + 1'd1;
			end
		end
		default: begin
			motor_set_pulse		<=	1'b0;
			motor_set_pulse_cnt	<=	'd0;
		end
		endcase
	end
end



always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		motor_state	<=	'd0;
	end
	else if(~data_acq_en_sync) begin
		case(motor_state)
		4'd0: begin
			if(up_edge_position_test_out_en) begin
				motor_state	<=	motor_state + 1'd1;
			end
			else begin
				motor_state	<=	'd0;
			end
		end
		4'd1: begin
			if((~bg_data_a[23])&& (~bg_data_b[23])) begin
				motor_state	<=	motor_state + 1'd1;
			end
			else begin
				motor_state	<=	'd0;
			end
		end
		4'd2: begin
			if(divider_out_en) begin
				motor_state	<=	motor_state + 1'd1;
			end
			else begin
				motor_state	<=	motor_state;
			end
		end
		4'd3: begin
			motor_state	<=	'd0;
		end
		default: begin
			motor_state	<=	'd0;
		end
		endcase
	end
	else begin
		case(motor_state)
		4'd0: begin
			if(motor_set_pulse && data_acq_en_sync) begin
				motor_state	<=	motor_state + 1'd1;
			end
			else begin
				motor_state	<=	'd0;
			end
		end
		4'd1: begin
			if(motor_data_out_en) begin
				motor_state	<=	motor_state + 1'd1;
			end
			else begin
				motor_state	<=	motor_state;
			end
		end
		4'd2: begin
			if((~comp_data_a[23]) && (~comp_data_b[23])) begin
				motor_state	<=	motor_state + 1'd1;
			end
			else begin
				motor_state	<=	'd0;
			end
		end
		4'd3: begin
			if(divider_out_en) begin
				motor_state	<=	motor_state + 1'd1;
			end
			else begin
				motor_state	<=	motor_state;
			end
		end
		4'd4: begin
			motor_state	<=	motor_state + 1'd1;
		end
		4'd5: begin
			if(delay_cnt == 'd12) begin
				motor_state	<=	'd0;
			end
			else begin
				motor_state	<=	motor_state;
			end
		end
		default: begin
			motor_state	<=	'd0;
		end
		endcase
	end
end
	

always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		divider_in_en		<=	1'b0;
		dividend_data		<=	'd0;
		divisor_data		<=	'd0;
		divider_neg_flag	<=	1'b0;
		motor_rd_en			<=	1'b0;
		motor_data_in_en	<=	1'b0;
		motor_data_in		<=	'd0;
		motor_feed_data		<=	'd0;
		position_actual		<=	'd0;
		position_actual_avg	<=	'd0;
		delta_position		<=	'd0;
		delay_cnt			<=	'd0;
	end
	else if(~data_acq_en_sync) begin
		motor_rd_en			<=	1'b0;
		motor_data_in_en	<=	1'b0;
		motor_data_in		<=	'd0;
		motor_feed_data		<=	'd0;
		position_actual		<=	'd0;
		delta_position		<=	'd0;
		delay_cnt			<=	'd0;
		case(motor_state)
		4'd0: begin
			divider_in_en		<=	1'b0;
			dividend_data		<=	'd0;
			divisor_data		<=	'd0;
			divider_neg_flag	<=	1'b0;
			if(up_edge_position_test_out_en) begin
				position_actual_avg	<=	'd0;
			end
			else begin
				position_actual_avg	<=	position_actual_avg;
			end
		end
		4'd1: begin	
			position_actual_avg	<=	'd0;
			if((~bg_data_a[23]) && (~bg_data_b[23])) begin
				divider_in_en		<=	1'b1;
				divisor_data		<=	bg_data_a + bg_data_b;
				if(bg_data_a >= bg_data_b) begin
					dividend_data		<=	bg_data_a - bg_data_b;
					divider_neg_flag	<=	1'b0;
				end
				else begin
					dividend_data		<=	bg_data_a - bg_data_b;
					divider_neg_flag	<=	1'b1;
				end
			end
			else begin
				divider_in_en		<=	1'b0;
				dividend_data		<=	'd0;
				divisor_data		<=	'd0;
				divider_neg_flag	<=	1'b0;
			end
		end
		4'd2: begin
			divider_in_en		<=	1'b0;
			dividend_data		<=	'd0;
			divisor_data		<=	'd0;
			divider_neg_flag	<=	divider_neg_flag;
			if(divider_out_en) begin
				position_actual_avg		<=	{divider_out_data[20:0],2'd0} +  divider_out_data[20:0];
			end
			else begin
				position_actual_avg		<=	'd0;
			end
		end
		4'd3: begin
			divider_in_en		<=	1'b0;
			dividend_data		<=	'd0;
			divisor_data		<=	'd0;
			divider_neg_flag	<=	1'b0;
			if(divider_neg_flag) begin
				position_actual_avg		<=	(~position_actual_avg) + 1'd1;
			end
			else begin
				position_actual_avg		<=	position_actual_avg;
			end
		end
		default: begin
			divider_in_en		<=	1'b0;
			dividend_data		<=	'd0;
			divisor_data		<=	'd0;
			divider_neg_flag	<=	1'b0;
			position_actual_avg	<=	'd0;
		end
		endcase
	end
	else begin
		case(motor_state)
		4'd0: begin
			divider_in_en		<=	1'b0;
			dividend_data		<=	'd0;
			divisor_data		<=	'd0;
			divider_neg_flag	<=	1'b0;
			motor_data_in_en	<=	1'b0;
			delay_cnt			<=	'd0;
			position_actual_avg	<=	'd0;
			if(motor_set_pulse && data_acq_en_sync) begin
				motor_rd_en			<=	'd1;
				motor_data_in		<=	'd0;
				motor_feed_data		<=	'd0;
				position_actual		<=	'd0;
				delta_position		<=	'd0;
			end
			else begin
				motor_rd_en			<=	'd0;
				motor_data_in		<=	motor_data_in;
				motor_feed_data		<=	motor_feed_data;
				position_actual		<=	position_actual;
				delta_position		<=	delta_position;
			end
		end
		4'd1: begin
			divider_in_en		<=	1'b0;
			dividend_data		<=	'd0;
			divisor_data		<=	'd0;
			divider_neg_flag	<=	1'b0;
			motor_rd_en			<=	'd0;
			motor_data_in_en	<=	1'b0;
			motor_data_in		<=	'd0;
			motor_feed_data		<=	'd0;
			position_actual		<=	'd0;
			delta_position		<=	'd0;
			delay_cnt			<=	'd0;
			if(motor_data_out_en) begin
				motor_feed_data		<=	motor_data_out;
			end
			else begin
				motor_feed_data		<=	'd0;
			end
		end
		4'd2: begin
			motor_rd_en			<=	1'b0;
			motor_data_in_en	<=	1'b0;
			motor_data_in		<=	'd0;
			motor_feed_data		<=	motor_feed_data;
			position_actual		<=	'd0;
			delta_position		<=	'd0;
			delay_cnt			<=	'd0;
			if((~comp_data_a[23]) && (~comp_data_b[23])) begin
				divider_in_en		<=	1'b1;
				divisor_data		<=	comp_data_a + comp_data_b;
				if(comp_data_a >= comp_data_b) begin
					dividend_data		<=	comp_data_a - comp_data_b;
					divider_neg_flag	<=	1'b0;
				end
				else begin
					dividend_data		<=	comp_data_b - comp_data_a;
					divider_neg_flag	<=	1'b1;
				end
			end
			else begin
				divider_in_en		<=	1'b0;
				dividend_data		<=	'd0;
				divisor_data		<=	'd0;
				divider_neg_flag	<=	1'b0;
			end
		end
		4'd3: begin
			divider_in_en		<=	1'b0;
			dividend_data		<=	'd0;
			divisor_data		<=	'd0;
			divider_neg_flag	<=	divider_neg_flag;
			motor_rd_en			<=	1'b0;
			motor_data_in_en	<=	1'b0;
			motor_data_in		<=	'd0;
			motor_feed_data		<=	motor_feed_data;
			delta_position		<=	'd0;
			delay_cnt			<=	'd0;
			if(divider_out_en) begin
				position_actual		<=	{divider_out_data[20:0],2'd0} +  divider_out_data[20:0];
			end
			else begin
				position_actual		<=	'd0;
			end
		end
		4'd4: begin
			divider_in_en		<=	1'b0;
			dividend_data		<=	'd0;
			divisor_data		<=	'd0;
			divider_neg_flag	<=	1'b0;
			motor_rd_en			<=	1'b0;
			motor_data_in_en	<=	1'b0;
			motor_data_in		<=	'd0;
			motor_feed_data		<=	motor_feed_data;
			delay_cnt			<=	'd0;
			if(divider_neg_flag) begin
				position_actual		<=	(~position_actual) + 1'd1;
				delta_position		<=	(~position_actual) + 1'd1 - position_arm;
			end
			else begin
				position_actual		<=	position_actual;
				delta_position		<=	position_actual - position_arm;
			end
		end	
		4'd5: begin
			divider_in_en		<=	1'b0;
			dividend_data		<=	'd0;
			divisor_data		<=	'd0;
			motor_rd_en			<=	1'b0;
			motor_feed_data		<=	motor_feed_data;
			position_actual		<=	position_actual;
			delta_position		<=	delta_position;
			if(delay_cnt == 'd12) begin			// (mult_result/2^40)/4.096V *(2^16) = (mult_result/2^40)*16000
				motor_data_in_en	<=	1'b1;
				if(mult_result_2[55]) begin
					if((~mult_result_2[55:40] + 1'd1) > motor_feed_data) begin
						motor_data_in	<=	'd0;
					end
					else begin
						motor_data_in		<=	mult_result_2[55:40] + motor_feed_data;
					end
				end
				else begin
					if((16'hffff - mult_result_2[55:40]) < motor_feed_data) begin
						motor_data_in	<=	16'hffff;
					end
					else begin
						motor_data_in		<=	mult_result_2[55:40] + motor_feed_data;
					end
				end
				delay_cnt			<=	'd0;
			end
			else begin
				motor_data_in_en	<=	1'b0;
				motor_data_in		<=	'd0;
				delay_cnt			<=	delay_cnt + 1'd1;
			end
		end		
		default: begin
			divider_in_en		<=	1'b0;
			dividend_data		<=	'd0;
			divisor_data		<=	'd0;
			divider_neg_flag	<=	1'b0;
			motor_rd_en			<=	1'b0;
			motor_data_in_en	<=	1'b0;
			motor_data_in		<=	'd0;
			motor_feed_data		<=	'd0;
			position_actual		<=	'd0;
			position_actual_avg	<=	'd0;
			delta_position		<=	'd0;
			delay_cnt			<=	'd0;
		end
		endcase
	end
end			

pid_mult pid_mult_inst(
	.CLK(clk), 
	.A(delta_position), 
	.B(kp), 
	.P(mult_result)
);	

pid_mult_2 pid_mult_2_inst(
	.CLK(clk), 
	.A(mult_result), 
	.B(16'd16000), 
	.P(mult_result_2)
);	

bps_divider bps_divider_inst(
	.aclk(clk), 
	.aresetn(~rst), 
	.s_axis_divisor_tvalid(divider_in_en), 
	.s_axis_divisor_tdata(divisor_data), 
	.s_axis_dividend_tvalid(divider_in_en), 
	.s_axis_dividend_tdata(dividend_data), 
	.m_axis_dout_tvalid(divider_out_en), 
	.m_axis_dout_tdata(divider_out_data)
);

// ila_bpsi_if_test ila_bpsi_if_test_inst(
// 	.clk(clk),
// 	.probe0(motor_set_pulse),
// 	.probe1(actual_data_a),
// 	.probe2(actual_data_b),
// 	.probe3(comp_data_en),
// 	.probe4(comp_data_a),
// 	.probe5(comp_data_b),
// 	.probe6(position_actual),
// 	.probe7(motor_feed_data),
// 	.probe8(motor_data_in),
// 	.probe9(divider_out_en),
// 	.probe10(divider_out_data[20:0])
// );

endmodule