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

module w_encoder_process_v2(
		input	wire		clk,
		input	wire		rst,
		
        input   wire        cfg_spindle_width_i,
		input	wire		motion_en,
		
		output	wire		w_encoder_clk_out,
		input 	wire	 	w_encoder_data_in,
		input	wire		w_encoder_clk_in,			//2.5M
		output	wire		w_encoder_data_out,
		
		output	reg			w_data_out_en,
		output	reg [31:0]	w_data_out,
		output	reg			w_data_error,
		output	reg			w_data_warn,
		output	reg			driver_error

);


assign	w_encoder_clk_out	=	w_encoder_clk_in;
assign	w_encoder_data_out	=	w_encoder_data_in;

reg		[3:0]	driver_state;
reg		[33:0]	w_data_out_temp;
reg		[33:0]	w_data_out_temp_1;
reg				update_en;
reg		[15:0]	cnt_16k;
reg		[15:0]	time_out_cnt;
reg		[7:0]	data_cnt;

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
			if(down_edge_w_encoder_clk_in && w_encoder_data_in) begin
				driver_state	<=	driver_state + 1'd1;
			end
			else begin
				driver_state	<=	'd0;
			end
		end
		4'd1: begin
			if(time_out_cnt == 'd25) begin				//时钟频率为2.5M
				driver_state	<=	'd0;
			end
			else if(up_edge_w_encoder_clk_in) begin
				if(w_encoder_data_in)
					driver_state	<=	driver_state + 1'd1;
				else
					driver_state	<=	'd0;
			end
			else begin
				driver_state	<=	driver_state;
			end
		end
		4'd2: begin
			if(time_out_cnt == 'd25) begin
				driver_state	<=	'd0;
			end
			else if(down_edge_w_encoder_clk_in) begin
				if(w_encoder_data_in)
					driver_state	<=	driver_state + 1'd1;
				else
					driver_state	<=	'd0;
			end
			else begin
				driver_state	<=	driver_state;
			end
		end
		4'd3: begin
			if(time_out_cnt == 'd50) begin
				driver_state	<=	'd0;
			end
			else if(down_edge_w_encoder_clk_in) begin
				if(~w_encoder_data_in)		//检测ACK
					driver_state	<=	driver_state + 1'd1;
				else
					driver_state	<=	'd0;
			end
			else begin
				driver_state	<=	driver_state;
			end
		end
		4'd4: begin
			if(time_out_cnt == 'd2000) begin				//20us ACK时间
				driver_state	<=	'd0;
			end
			else if(down_edge_w_encoder_clk_in && w_encoder_data_in) begin
				driver_state	<=	driver_state + 1'd1;	//start
			end
			else begin
				driver_state	<=	driver_state;
			end
		end
		4'd5: begin
			if(time_out_cnt == 'd50) begin
				driver_state	<=	'd0;
			end
			else if(down_edge_w_encoder_clk_in) begin
				if(~w_encoder_data_in) begin
					driver_state	<=	driver_state + 1'd1;	//0
				end
				else begin
					driver_state	<=	'd0;
				end
			end
			else begin
				driver_state	<=	driver_state;
			end
		end
		4'd6: begin
			if(    ((time_out_cnt == 'd1100) && (~cfg_spindle_width_i))             //超时时间 > (100M/2.5M*26bit) 18bit wencode
                || ((time_out_cnt == 'd1400) && cfg_spindle_width_i)    ) begin	    //超时时间 > (100M/2.5M*34bit) 26bit wencode
				driver_state	<=	'd0;
			end
			else if((down_edge_w_encoder_clk_in && (data_cnt == 'd25) && (~cfg_spindle_width_i))            // 18bit wencode
                 || (down_edge_w_encoder_clk_in && (data_cnt == 'd33) && cfg_spindle_width_i)  ) begin		// 26bit wencode
				driver_state	<=	driver_state + 1'd1;
			end
			else begin
				driver_state	<=	driver_state;
			end
		end
		4'd7: begin
			if(time_out_cnt == 'd25) begin
				driver_state	<=	'd0;
			end
			else if(up_edge_w_encoder_clk_in) begin
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



always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		w_data_out_temp			<=	'd0;
		w_data_out_temp_1		<=	'd0;
		update_en				<=	1'b0;
		data_cnt				<=	'd0;
		time_out_cnt			<=	'd0;
		driver_error			<=	1'b0;
	end
	else if(~motion_en) begin
		w_data_out_temp			<=	'd0;
		w_data_out_temp_1		<=	'd0;
		update_en				<=	1'b0;
		data_cnt				<=	'd0;
		time_out_cnt			<=	'd0;
		driver_error			<=	1'b0;
	end
	else begin
		case(driver_state)
		4'd0: begin
			w_data_out_temp			<=	'd0;
			w_data_out_temp_1		<=	w_data_out_temp_1;
			update_en				<=	1'b0;
			data_cnt				<=	'd0;
			time_out_cnt			<=	'd0;
			driver_error			<=	1'b0;
		end
		4'd1: begin
			w_data_out_temp			<=	'd0;
			w_data_out_temp_1		<=	w_data_out_temp_1;
			update_en				<=	1'b0;
			data_cnt				<=	'd0;
			if(time_out_cnt == 'd25) begin
				time_out_cnt		<=	'd0;
				driver_error		<=	1'b1;
			end
			else if(up_edge_w_encoder_clk_in) begin
				time_out_cnt		<=	'd0;
				if(w_encoder_data_in)
					driver_error		<=	1'b0;
				else
					driver_error		<=	1'b1;
			end
			else begin
				time_out_cnt		<=	time_out_cnt + 1'd1;
				driver_error		<=	1'b0;
			end
		end
		4'd2: begin
			w_data_out_temp			<=	'd0;
			w_data_out_temp_1		<=	w_data_out_temp_1;
			update_en				<=	1'b0;
			data_cnt				<=	'd0;
			if(time_out_cnt == 'd25) begin
				time_out_cnt			<=	'd0;
				driver_error			<=	1'b1;
			end
			else if(down_edge_w_encoder_clk_in) begin
				time_out_cnt		<=	'd0;
				if(w_encoder_data_in)
					driver_error		<=	1'b0;
				else
					driver_error		<=	1'b1;
			end
			else begin
				time_out_cnt			<=	time_out_cnt + 1'd1;
				driver_error			<=	1'b0;
			end
		end
		4'd3: begin
			w_data_out_temp			<=	'd0;
			w_data_out_temp_1		<=	w_data_out_temp_1;
			update_en				<=	1'b0;
			data_cnt				<=	'd0;
			if(time_out_cnt == 'd50) begin
				time_out_cnt			<=	'd0;
				driver_error			<=	1'b1;
			end
			else if(down_edge_w_encoder_clk_in) begin
				time_out_cnt		<=	'd0;
				if(~w_encoder_data_in)
					driver_error		<=	1'b0;
				else
					driver_error		<=	1'b1;
			end
			else begin
				time_out_cnt			<=	time_out_cnt + 1'd1;
				driver_error			<=	1'b0;
			end
		end
		4'd4: begin
			w_data_out_temp			<=	'd0;
			w_data_out_temp_1		<=	w_data_out_temp_1;
			update_en				<=	1'b0;
			data_cnt				<=	'd0;
			if(time_out_cnt == 'd2000) begin
				time_out_cnt			<=	'd0;
				driver_error			<=	1'b1;
			end
			else if(down_edge_w_encoder_clk_in && w_encoder_data_in) begin
				time_out_cnt			<=	'd0;
				driver_error			<=	1'b0;
			end
			else begin
				time_out_cnt			<=	time_out_cnt + 1'd1;
				driver_error			<=	1'b0;
			end
		end
		4'd5: begin
			w_data_out_temp			<=	'd0;
			w_data_out_temp_1		<=	w_data_out_temp_1;
			update_en				<=	1'b0;
			data_cnt				<=	'd0;
			if(time_out_cnt == 'd50) begin
				time_out_cnt			<=	'd0;
				driver_error			<=	1'b1;
			end
			else if(down_edge_w_encoder_clk_in) begin
				time_out_cnt			<=	'd0;
				if(~w_encoder_data_in)
					driver_error		<=	1'b0;
				else
					driver_error		<=	1'b1;
			end
			else begin
				time_out_cnt			<=	time_out_cnt + 1'd1;
				driver_error			<=	1'b0;
			end
		end
		4'd6: begin
			w_data_out_temp_1		<=	w_data_out_temp_1;
			if(    (time_out_cnt == 'd1100) && (~cfg_spindle_width_i)
                || (time_out_cnt == 'd1400) && (cfg_spindle_width_i)    ) begin
				time_out_cnt		<=	'd0;
				driver_error		<=	1'b1;
			end
			else if(   (down_edge_w_encoder_clk_in && (data_cnt == 'd25) && (~cfg_spindle_width_i))
                    || (down_edge_w_encoder_clk_in && (data_cnt == 'd33) && (cfg_spindle_width_i)) ) begin
				time_out_cnt		<=	'd0;
				driver_error		<=	1'b0;
			end
			else begin
				time_out_cnt		<=	time_out_cnt + 1'd1;
				driver_error		<=	1'b0;
			end
			
			if(    (down_edge_w_encoder_clk_in && (data_cnt == 'd25) && (~cfg_spindle_width_i))
                || (down_edge_w_encoder_clk_in && (data_cnt == 'd33) && (cfg_spindle_width_i)) ) begin
				w_data_out_temp			<=	{w_data_out_temp[32:0],w_encoder_data_in};
				data_cnt				<=	'd0;
				update_en				<=	1'b1;
			end
			else if(down_edge_w_encoder_clk_in) begin
				w_data_out_temp			<=	{w_data_out_temp[32:0],w_encoder_data_in};
				data_cnt				<=	data_cnt + 1'd1;
				update_en				<=	1'b0;
			end
			else begin
				w_data_out_temp			<=	w_data_out_temp;
				data_cnt				<=	data_cnt;
				update_en				<=	1'b0;
			end
		end
		4'd7: begin
			w_data_out_temp			<=	w_data_out_temp;
			w_data_out_temp_1		<=	w_data_out_temp;
			update_en				<=	1'b0;
			data_cnt				<=	'd0;
			if(time_out_cnt == 'd25) begin
				time_out_cnt			<=	'd0;
				driver_error			<=	1'b1;
			end
			else if(up_edge_w_encoder_clk_in) begin
				time_out_cnt			<=	'd0;
				driver_error			<=	1'b0;
			end
			else begin
				time_out_cnt			<=	time_out_cnt + 1'd1;
				driver_error			<=	1'b0;
			end
		end
		default: begin
			w_data_out_temp			<=	'd0;
			w_data_out_temp_1		<=	'd0;
			update_en				<=	1'b0;
			data_cnt				<=	'd0;
			time_out_cnt			<=	'd0;
			driver_error			<=	1'b0;
		end
		endcase
	end
end
		
reg		[3:0] 	state;

always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		cnt_16k			<=	'd0;
		w_data_out_en	<=	1'b0;
		w_data_out		<=	'd0;
		w_data_error	<=	1'b0;
		w_data_warn		<=	1'b0;
		state			<=	'd0;
	end
	else if(~motion_en) begin
		cnt_16k			<=	'd0;
		w_data_out_en	<=	1'b0;
		w_data_out		<=	'd0;
		w_data_error	<=	1'b0;
		w_data_warn		<=	1'b0;
		state			<=	'd0;
	end
	else begin
		case(state)
		4'd0: begin
			w_data_out_en	<=	1'b0;
			// w_data_out		<=	'd0;
			w_data_error	<=	1'b0;
			w_data_warn		<=	1'b0;
			if((driver_state == 4'd1) && up_edge_w_encoder_clk_in && w_encoder_data_in) begin
				cnt_16k		<=	'd0;
				state		<=	state + 1'd1;
			end
			else begin
				cnt_16k		<=	cnt_16k + 1'd1;
				state		<=	'd0;
			end
		end
		4'd1: begin
			if(driver_error) begin
				cnt_16k			<=	'd0;
				w_data_out_en	<=	1'b0;
				// w_data_out		<=	'd0;
				w_data_error	<=	1'b0;
				w_data_warn		<=	1'b0;
				state			<=	'd0;
			end
            else if(cnt_16k == 'd3500) begin  // <6249
				state			<=	'd0;
				cnt_16k			<=	cnt_16k + 1'd1;
				w_data_out_en	<=	1'b1;
				w_data_out		<=	cfg_spindle_width_i ? {14'd0,w_data_out_temp_1[33:16]} : {14'd0,w_data_out_temp_1[25:8]};
				w_data_error	<=	w_data_out_temp_1[7];
				w_data_warn		<=	w_data_out_temp_1[6];
			end
			else begin
				state			<=	state;
				cnt_16k			<=	cnt_16k	+ 1'd1;
				w_data_out_en	<=	1'b0;
				w_data_out		<=	w_data_out;
				w_data_error	<=	w_data_error;
				w_data_warn		<=	w_data_warn;
			end
		end
		default: begin
			cnt_16k			<=	'd0;
			w_data_out_en	<=	1'b0;
			state			<=	'd0;
		end
		endcase
	end
end

reg				cnt_16k_reg_en;
reg 	[15:0] 	cnt_16k_reg;
always	@(posedge clk or posedge rst)
begin
	if(rst) begin
		cnt_16k_reg_en	<=	1'b0;
		cnt_16k_reg		<=	'd0;
	end
	else if((driver_state == 4'd1) && up_edge_w_encoder_clk_in && w_encoder_data_in) begin
		cnt_16k_reg_en	<=	1'b1;
		cnt_16k_reg		<=	cnt_16k;
	end
	else begin
		cnt_16k_reg_en	<=	1'b0;
		cnt_16k_reg		<=	cnt_16k_reg;
	end
end


// ila_0	ila_0_inst(
	// .clk(clk),
	// .probe0({driver_error,state,driver_state,w_data_error,w_data_warn,update_en,w_data_out_en,cnt_16k_reg_en,2'd0}),
	// .probe1(cnt_16k),
	// .probe2(cnt_16k_reg/*time_out_cnt*/),
	// .probe3(w_data_out)
// );
		
endmodule