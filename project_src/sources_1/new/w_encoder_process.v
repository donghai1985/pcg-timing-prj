`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/11 8:40:10
// Design Name: 
// Module Name: w_encoder_process
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

module w_encoder_process(
		input	wire		clk,
		input	wire		rst,
		
		input	wire		motion_en,
		
		output	wire		w_encoder_clk_out,
		input 	wire	 	w_encoder_data_in,
		input	wire		w_encoder_clk_in,			//2.5M
		output	wire		w_encoder_data_out,
		
		output	reg			w_data_out_en,
		output	reg	[31:0]	w_data_out,
		output	reg			w_data_error,
		output	reg			w_data_warn

);

reg				w_encoder_data_out_temp;
reg				w_encoder_clk_out_temp;

reg		[3:0]	driver_state;
reg		[3:0]	encoder_state;
reg		[33:0]	w_data_out_temp;
reg		[33:0]	w_data_out_temp_1;
reg		[36:0]	w_data_out_temp_2;
reg		[15:0]	cnt_25k;
reg				rd_en;		//	每40ms读取一次encoder数据
reg		[15:0]	time_out_cnt;
reg		[7:0]	data_cnt;
reg		[7:0]	clk_cnt;
reg		[7:0]	data_cnt_1;
reg		[7:0]	time_out_cnt_1;


reg				w_encoder_clk_in_reg1;
reg				w_encoder_clk_in_reg2;
wire			up_edge_w_encoder_clk_in;
wire			down_edge_w_encoder_clk_in;

always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		w_encoder_clk_in_reg1	<=	1'b0;
		w_encoder_clk_in_reg2	<=	1'b0;
	end
	else begin
		w_encoder_clk_in_reg1	<=	w_encoder_clk_in;
		w_encoder_clk_in_reg2	<=	w_encoder_clk_in_reg1;
	end
end

assign	up_edge_w_encoder_clk_in	=	w_encoder_clk_in_reg1 && (~w_encoder_clk_in_reg2);
assign	down_edge_w_encoder_clk_in	=	(~w_encoder_clk_in_reg1) && w_encoder_clk_in_reg2;

always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		driver_state	<=	'd0;
	end
	else if(~motion_en) begin
		driver_state	<=	'd0;
	end
	else begin
		case(driver_state)
		4'd0: begin
			if(down_edge_w_encoder_clk_in) begin
				driver_state	<=	driver_state + 1'd1;
			end
			else begin
				driver_state	<=	'd0;
			end
		end
		4'd1: begin
			if(time_out_cnt == 'd200) begin				//时钟最低频率为250K,超时时间 > 100M/250K
				driver_state	<=	'd0;
			end
			else if(up_edge_w_encoder_clk_in) begin		//第一个上升沿
				driver_state	<=	driver_state + 1'd1;
			end
			else begin
				driver_state	<=	driver_state;
			end
		end
		4'd2: begin
			if(time_out_cnt == 'd400) begin
				driver_state	<=	'd0;
			end
			else if(up_edge_w_encoder_clk_in) begin		//第二个上升沿
				driver_state	<=	driver_state + 1'd1;
			end
			else begin
				driver_state	<=	driver_state;
			end
		end
		4'd3: begin
			if(time_out_cnt == 'd1200) begin				//12us ACK时间
				driver_state	<=	driver_state + 1'd1;
			end
			else begin
				driver_state	<=	driver_state;
			end
		end
		4'd4: begin
			// if(time_out_cnt == 'd16000) begin				//超时时间 > (100M/250K*36bit)
			if(time_out_cnt == 'd12000) begin				//超时时间 > (100M/250K*28bit)
				driver_state	<=	'd0;
			end
			// else if(up_edge_w_encoder_clk_in && (data_cnt == 'd36)) begin		//传输数据
			else if(up_edge_w_encoder_clk_in && (data_cnt == 'd28)) begin		//传输数据
				driver_state	<=	driver_state + 1'd1;
			end
			else begin
				driver_state	<=	driver_state;
			end
		end
		4'd5: begin
			if(time_out_cnt == 'd100) begin				//确保请求循环率 < 25K
				driver_state	<=	'd0;
			end
			else begin
				driver_state	<=	driver_state;
			end
		end
		default: begin
			driver_state	<=	'd0;
		end
		endcase
	end
end

assign	w_encoder_data_out	=	motion_en	?	w_encoder_data_out_temp	:	w_encoder_data_in;

always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		w_encoder_data_out_temp	<=	1'b1;
		w_data_out_temp_2		<=	'd0;
		data_cnt				<=	'd0;
		time_out_cnt			<=	'd0;
	end
	else if(~motion_en) begin
		w_encoder_data_out_temp	<=	1'b1;
		w_data_out_temp_2		<=	'd0;
		data_cnt				<=	'd0;
		time_out_cnt			<=	'd0;
	end
	else begin
		case(driver_state)
		4'd0: begin
			w_encoder_data_out_temp	<=	1'b1;
			w_data_out_temp_2		<=	'd0;
			data_cnt				<=	'd0;
			time_out_cnt			<=	'd0;
		end
		4'd1: begin
			w_encoder_data_out_temp	<=	1'b1;
			w_data_out_temp_2		<=	'd0;
			data_cnt				<=	'd0;
			if(time_out_cnt == 'd200) begin
				time_out_cnt		<=	'd0;
			end
			else if(up_edge_w_encoder_clk_in) begin
				time_out_cnt		<=	'd0;
			end
			else begin
				time_out_cnt		<=	time_out_cnt + 1'd1;
			end
		end
		4'd2: begin
			w_data_out_temp_2	<=	'd0;
			data_cnt			<=	'd0;
			if(time_out_cnt == 'd400) begin
				w_encoder_data_out_temp	<=	1'b1;
				time_out_cnt			<=	'd0;
			end
			else if(up_edge_w_encoder_clk_in) begin
				w_encoder_data_out_temp	<=	1'b0;
				time_out_cnt			<=	'd0;
			end
			else begin
				w_encoder_data_out_temp	<=	1'b1;
				time_out_cnt			<=	time_out_cnt + 1'd1;
			end
		end
		4'd3: begin
			w_encoder_data_out_temp	<=	1'b0;
			data_cnt				<=	'd0;
			if(time_out_cnt == 'd1200) begin
				// w_data_out_temp_2	<=	{2'b10,w_data_out_temp_1,1'b0};
				w_data_out_temp_2	<=	{2'b10,w_data_out_temp_1[25:0],9'b0};
				time_out_cnt		<=	'd0;
			end
			else begin
				w_data_out_temp_2	<=	'd0;
				time_out_cnt		<=	time_out_cnt + 1'd1;
			end
		end
		4'd4: begin
			// if(time_out_cnt == 'd16000) begin
			if(time_out_cnt == 'd12000) begin
				time_out_cnt		<=	'd0;
			end
			// else if(up_edge_w_encoder_clk_in && (data_cnt == 'd36)) begin
			else if(up_edge_w_encoder_clk_in && (data_cnt == 'd28)) begin
				time_out_cnt		<=	'd0;
			end
			else begin
				time_out_cnt		<=	time_out_cnt + 1'd1;
			end
			
			// if(up_edge_w_encoder_clk_in && (data_cnt == 'd36)) begin
			if(up_edge_w_encoder_clk_in && (data_cnt == 'd28)) begin
				w_encoder_data_out_temp	<=	w_data_out_temp_2[36];
				w_data_out_temp_2		<=	{w_data_out_temp_2[35:0],w_data_out_temp_2[36]};
				data_cnt				<=	'd0;
			end
			else if(up_edge_w_encoder_clk_in) begin
				w_encoder_data_out_temp	<=	w_data_out_temp_2[36];
				w_data_out_temp_2		<=	{w_data_out_temp_2[35:0],w_data_out_temp_2[36]};
				data_cnt				<=	data_cnt + 1'd1;
			end
			else begin
				w_encoder_data_out_temp	<=	w_encoder_data_out_temp;
				w_data_out_temp_2		<=	w_data_out_temp_2;
				data_cnt				<=	data_cnt;
			end
		end
		4'd5: begin
			w_encoder_data_out_temp	<=	1'b0;
			w_data_out_temp_2		<=	'd0;
			data_cnt				<=	'd0;
			if(time_out_cnt == 'd100) begin
				time_out_cnt		<=	'd0;
			end
			else begin
				time_out_cnt		<=	time_out_cnt + 1'd1;
			end
		end
		default: begin
			w_encoder_data_out_temp	<=	1'b1;
			w_data_out_temp_2		<=	'd0;
			data_cnt				<=	'd0;
			time_out_cnt			<=	'd0;
		end
		endcase
	end
end
		


always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		cnt_25k		<=	'd0;
		rd_en		<=	1'b0;
	end
	else if(~motion_en) begin
		cnt_25k		<=	'd0;
		rd_en		<=	1'b0;
	end
	else if(cnt_25k == 'd3999) begin
		cnt_25k		<=	'd0;
		rd_en		<=	1'b1;
	end
	else begin
		cnt_25k		<=	cnt_25k	+ 1'd1;
		rd_en		<=	1'b0;
	end
end

always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		encoder_state	<=	'd0;
	end
	else if(~motion_en) begin
		encoder_state	<=	'd0;
	end
	else begin
		case(encoder_state)
		4'd0: begin
			if(rd_en && w_encoder_data_in) begin
				encoder_state	<=	encoder_state + 1'd1;
			end
			else begin
				encoder_state	<=	'd0;
			end
		end
		4'd1: begin
			if(clk_cnt == 'd49) begin
				encoder_state	<=	encoder_state + 1'd1;
			end
			else begin
				encoder_state	<=	encoder_state;
			end
		end
		4'd2: begin
			if(clk_cnt == 'd49) begin
				if(w_encoder_data_in) begin
					encoder_state	<=	'd0;
				end
				else begin
					encoder_state	<=	encoder_state + 1'd1;
				end
			end
			else begin
				encoder_state	<=	encoder_state;
			end
		end
		4'd3: begin
			if(time_out_cnt_1 == 'd2000) begin		//20us
				encoder_state	<=	'd0;
			end
			else if((clk_cnt == 'd49) && w_encoder_data_in) begin	//起始位
				encoder_state	<=	encoder_state + 1'd1;
			end
			else begin
				encoder_state	<=	encoder_state;
			end
		end
		4'd4: begin
			if(clk_cnt == 'd49) begin
				if(w_encoder_data_in) begin			
					encoder_state	<=	'd0;
				end
				else begin
					encoder_state	<=	encoder_state + 1'd1;
				end
			end
			else begin
				encoder_state	<=	encoder_state;
			end
		end
		4'd5: begin
			// if((clk_cnt == 'd49) && (data_cnt_1 == 'd33)) begin
			if((clk_cnt == 'd49) && (data_cnt_1 == 'd25)) begin
				encoder_state	<=	encoder_state + 1'd1;
			end
			else begin
				encoder_state	<=	encoder_state;
			end
		end
		4'd6: begin
			if(clk_cnt == 'd24) begin
				encoder_state	<=	'd0;
			end
			else begin
				encoder_state	<=	encoder_state;
			end
		end		
		default: begin
			encoder_state	<=	'd0;
		end
		endcase
	end
end

assign	w_encoder_clk_out	=	motion_en	?	w_encoder_clk_out_temp	:	w_encoder_clk_in;

always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		w_encoder_clk_out_temp	<=	1'b1;
		w_data_out_temp			<=	'd0;
		w_data_out_temp_1		<=	'd0;
		clk_cnt					<=	'd0;
		data_cnt_1				<=	'd0;
		time_out_cnt_1			<=	'd0;
	end
	else if(~motion_en) begin
		w_encoder_clk_out_temp	<=	1'b1;
		w_data_out_temp			<=	'd0;
		w_data_out_temp_1		<=	'd0;
		clk_cnt					<=	'd0;
		data_cnt_1				<=	'd0;
		time_out_cnt_1			<=	'd0;
	end
	else begin
		case(encoder_state)
		4'd0: begin
			w_data_out_temp			<=	'd0;
			w_data_out_temp_1		<=	w_data_out_temp_1;
			clk_cnt					<=	'd0;
			data_cnt_1				<=	'd0;
			time_out_cnt_1			<=	'd0;
			if(rd_en && w_encoder_data_in) begin
				w_encoder_clk_out_temp	<=	1'b0;
			end
			else begin
				w_encoder_clk_out_temp	<=	1'b1;
			end
		end
		4'd1: begin
			w_data_out_temp			<=	'd0;
			w_data_out_temp_1		<=	w_data_out_temp_1;
			data_cnt_1				<=	'd0;
			time_out_cnt_1			<=	'd0;
			if(clk_cnt == 'd49) begin		//时钟频率2M
				w_encoder_clk_out_temp	<=	1'b0;
				clk_cnt					<=	'd0;
			end
			else if(clk_cnt == 'd24) begin
				w_encoder_clk_out_temp	<=	1'b1;
				clk_cnt					<=	clk_cnt + 1'd1;
			end
			else begin
				w_encoder_clk_out_temp	<=	w_encoder_clk_out_temp;
				clk_cnt					<=	clk_cnt + 1'd1;
			end
		end
		4'd2: begin
			w_data_out_temp			<=	'd0;
			w_data_out_temp_1		<=	w_data_out_temp_1;
			data_cnt_1				<=	'd0;
			time_out_cnt_1			<=	'd0;
			if(clk_cnt == 'd49) begin
				if(w_encoder_data_in) begin
					w_encoder_clk_out_temp	<=	1'b1;
				end
				else begin
					w_encoder_clk_out_temp	<=	1'b0;
				end
				clk_cnt					<=	'd0;
			end
			else if(clk_cnt == 'd24) begin
				w_encoder_clk_out_temp	<=	1'b1;
				clk_cnt					<=	clk_cnt + 1'd1;
			end
			else begin
				w_encoder_clk_out_temp	<=	w_encoder_clk_out_temp;
				clk_cnt					<=	clk_cnt + 1'd1;
			end
		end
		4'd3: begin
			w_data_out_temp			<=	'd0;
			w_data_out_temp_1		<=	w_data_out_temp_1;
			data_cnt_1				<=	'd0;
			
			if(time_out_cnt_1 == 'd2000) begin
				time_out_cnt_1			<=	'd0;
			end
			else begin
				time_out_cnt_1			<=	time_out_cnt_1 + 1'd1;
			end
			
			if(clk_cnt == 'd49) begin
				w_encoder_clk_out_temp	<=	1'b0;
				clk_cnt					<=	'd0;
			end
			else if(clk_cnt == 'd24) begin
				w_encoder_clk_out_temp	<=	1'b1;
				clk_cnt					<=	clk_cnt + 1'd1;
			end
			else begin
				w_encoder_clk_out_temp	<=	w_encoder_clk_out_temp;
				clk_cnt					<=	clk_cnt + 1'd1;
			end
		end
		4'd4: begin
			w_data_out_temp			<=	'd0;
			w_data_out_temp_1		<=	w_data_out_temp_1;
			data_cnt_1				<=	'd0;
			time_out_cnt_1			<=	'd0;
			if(clk_cnt == 'd49) begin
				if(w_encoder_data_in) begin
					w_encoder_clk_out_temp	<=	1'b1;
				end
				else begin
					w_encoder_clk_out_temp	<=	1'b0;
				end
				clk_cnt					<=	'd0;
			end
			else if(clk_cnt == 'd24) begin
				w_encoder_clk_out_temp	<=	1'b1;
				clk_cnt					<=	clk_cnt + 1'd1;
			end
			else begin
				w_encoder_clk_out_temp	<=	w_encoder_clk_out_temp;
				clk_cnt					<=	clk_cnt + 1'd1;
			end
		end
		4'd5: begin
			w_data_out_temp_1		<=	w_data_out_temp_1;
			
			time_out_cnt_1			<=	'd0;
			if(clk_cnt == 'd49) begin
				w_data_out_temp			<=	{w_data_out_temp[32:0],w_encoder_data_in};
				w_encoder_clk_out_temp	<=	1'b0;
				data_cnt_1				<=	data_cnt_1 + 1'd1;
				clk_cnt					<=	'd0;
			end
			else if(clk_cnt == 'd24) begin
				w_data_out_temp			<=	w_data_out_temp;
				w_encoder_clk_out_temp	<=	1'b1;
				data_cnt_1				<=	data_cnt_1;
				clk_cnt					<=	clk_cnt + 1'd1;
			end
			else begin
				w_data_out_temp			<=	w_data_out_temp;
				w_encoder_clk_out_temp	<=	w_encoder_clk_out_temp;
				data_cnt_1				<=	data_cnt_1;
				clk_cnt					<=	clk_cnt + 1'd1;
			end
		end
		4'd6: begin
			w_data_out_temp			<=	w_data_out_temp;
			w_data_out_temp_1		<=	w_data_out_temp;
			data_cnt_1				<=	'd0;
			time_out_cnt_1			<=	'd0;
			if(clk_cnt == 'd24) begin
				w_encoder_clk_out_temp	<=	1'b1;
				clk_cnt					<=	'd0;
			end
			else begin
				w_encoder_clk_out_temp	<=	w_encoder_clk_out_temp;
				clk_cnt					<=	clk_cnt + 1'd1;
			end
		end
		default: begin
			w_encoder_clk_out_temp	<=	1'b1;
			w_data_out_temp			<=	'd0;
			w_data_out_temp_1		<=	'd0;
			clk_cnt					<=	'd0;
			data_cnt_1				<=	'd0;
			time_out_cnt_1			<=	'd0;
		end
		endcase
	end
end

always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		w_data_out_en	<=	1'b0;
		w_data_out		<=	'd0;
		w_data_error	<=	1'b0;
		w_data_warn		<=	1'b0;
	end
	else if(rd_en) begin
		w_data_out_en	<=	1'b1;
		// w_data_out		<=	{6'd0,w_data_out_temp_1[33:8]};
		w_data_out		<=	{14'd0,w_data_out_temp_1[25:8]};
		w_data_error	<=	w_data_out_temp_1[7];
		w_data_warn		<=	w_data_out_temp_1[6];
	end
	else begin
		w_data_out_en	<=	1'b0;
		w_data_out		<=	w_data_out;
		w_data_error	<=	w_data_error;
		w_data_warn		<=	w_data_warn;
	end
end
		
		
endmodule