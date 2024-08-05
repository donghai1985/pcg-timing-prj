`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: image_rx
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


module image_rx#( 
	parameter lvds_pairs                = 8
)(
        input                         clk_rxg,	 
        input                         clk_rxg_x2, 	 
        input                         clk_ddr, 	 
        input                         rst_rx,
		input						  eds_power_en,
		input						  eds_frame_en,
        input [lvds_pairs-1:0]		  sensor_data,
        input [11:0]		          training_word,
        input			              cmd_start_training,
        output reg 		              lval_out, 
        output reg [lvds_pairs*16-1:0]data_out,
        output			              training_done, 
        output						  training_result
    );
	
    wire[lvds_pairs*12-1:0]	data_par_trained;
    (*dont_touch = "true"*)wire[lvds_pairs-1:0]      data_valid; 
    wire 		                  lval_sync; 
    wire [lvds_pairs*12-1:0]	  data_sync;
 
    training #(         
		.lvds_pairs    	            (lvds_pairs) 
    )	training(
		.clk_rxg 		            (clk_rxg),		
		.clk_rxg_x2 	            (clk_rxg_x2),	
		.clk_ddr 		            (clk_ddr),		
		.rst_rx 		            (rst_rx),	 
		.sensor_data            	(sensor_data), 
		.training_word				(training_word),
		.cmd_start_training			(cmd_start_training), 
		.data_valid			        (data_valid), 
		.data_par_trained			(data_par_trained),
		.training_done				(training_done),
		.training_result			(training_result)
	);
      

 	lval_synncode_Nchan#(         
		.lvds_pairs    	            (lvds_pairs)
    )
	inst_lval_synncode_Nchan(
		.clk_rxg 		            (clk_rxg), 	 
		.rst_rx 		            (rst_rx),     
		.data_valid			        (data_valid), 
		.data_in			        (data_par_trained), 
 		.lval_out					(lval_sync), 
		.data_out			        (data_sync)  
	);

reg	[7:0]	cnt;
reg			eds_power_en_reg1;
reg			eds_power_en_reg2;
reg			eds_frame_en_reg1;
reg			eds_frame_en_reg2;
wire		up_edge_eds_frame_en;

always @(posedge clk_rxg)
begin
	if(rst_rx)begin
		eds_power_en_reg1	<=	1'b0;
		eds_power_en_reg2	<=	1'b0;
		eds_frame_en_reg1	<=	1'b0;
		eds_frame_en_reg2	<=	1'b0;
	end
	else begin
		eds_power_en_reg1	<=	eds_power_en;
		eds_power_en_reg2	<=	eds_power_en_reg1;
		eds_frame_en_reg1	<=	eds_frame_en;
		eds_frame_en_reg2	<=	eds_frame_en_reg1;
	end
end

assign	up_edge_eds_frame_en = eds_frame_en_reg1 && (~eds_frame_en_reg2);

always @(posedge clk_rxg)
begin
	if(rst_rx)begin
		cnt			<= 'd0;	
		lval_out    <= 1'b0;
        data_out    <= {lvds_pairs*16{1'b0}}; 
	end
	else if(~eds_power_en_reg2) begin
		cnt			<= 'd0;	
		lval_out    <= 1'b0;
        data_out    <= {lvds_pairs*16{1'b0}}; 
	end
	else if(up_edge_eds_frame_en) begin
		cnt			<= 'd0;	
		lval_out    <= 1'b0;
        data_out    <= {lvds_pairs*16{1'b0}}; 
	end
	else begin
		if(lval_sync && (cnt == 'd0)) begin			//每行的第一个数据高4bit置1
			cnt			<= cnt + 'd1;	
			lval_out    <= 1'b1;
			data_out    <= {4'd0,data_sync[95:84],4'd0,data_sync[83:72],4'd0,data_sync[71:60],4'd0,data_sync[59:48],
							4'd0,data_sync[47:36],4'd0,data_sync[35:24],4'd0,data_sync[23:12],4'b1111,data_sync[11:0]}; 
		end
		else if(lval_sync && (cnt == 'd255)) begin	//满1行数据
			cnt			<= 'd0;	
			lval_out    <= 1'b1;
			data_out    <= {4'd0,data_sync[95:84],4'd0,data_sync[83:72],4'd0,data_sync[71:60],4'd0,data_sync[59:48],
							4'd0,data_sync[47:36],4'd0,data_sync[35:24],4'd0,data_sync[23:12],4'd0,data_sync[11:0]}; 
		end
		else if(lval_sync) begin
			cnt			<= cnt + 'd1;	
			lval_out    <= 1'b1;
			data_out    <= {4'd0,data_sync[95:84],4'd0,data_sync[83:72],4'd0,data_sync[71:60],4'd0,data_sync[59:48],
							4'd0,data_sync[47:36],4'd0,data_sync[35:24],4'd0,data_sync[23:12],4'd0,data_sync[11:0]}; 
		end
		else begin
			cnt			<= cnt;	
			lval_out    <= 1'b0;
			data_out    <= data_out; 
		end
	end
end

	
endmodule
