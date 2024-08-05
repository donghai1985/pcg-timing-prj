`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: ddr_test_top_if
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


module ddr_test_top_if(
		input	wire		clk,
		input	wire		rst,
		
		input	wire		ddr_ui_clk,
		input	wire		ddr3_init_done,
		
		input	wire		ddr_wr_en,
		output	wire [511:0]ddr_wr_data,
		output	wire [8:0]	ddr_wr_data_count,
		input	wire		ddr_rd_en,
		input	wire [511:0]ddr_rd_data,
		
		output	wire		complete_vio,
		output	reg			ddr_test_ok
);

reg					test_data_en;
reg  [63:0]			test_data;

wire				ddr_test_en;
wire [511:0]		ddr_wr_data_temp;

wire				eds_to_ddr3_fifo_full;


reg [63:0]			ddr_test_cnt;

// vio_ddr_test vio_ddr_test_inst(
// 		.clk(clk),           		// input wire clk
		
// 		.probe_out0(ddr_test_en),	// output wire [0 : 0] probe_out0
// 		.probe_out1(complete_vio),	// output wire [0 : 0] probe_out1
// 		.probe_out2(), 				// output wire [0 : 0] probe_out2
// 		.probe_out3()				// output wire [0 : 0] probe_out3
// );

always @(posedge clk or posedge rst) 
begin
	if(rst || (~ddr3_init_done)) begin
		test_data_en	<=	'd0;
		test_data		<=	64'hffff_ffff_ffff_ffff;
	end
	else if(ddr_test_en) begin
		if(complete_vio) begin
			test_data_en	<=	1'b0;
			test_data		<=	'd0;
		end
		else begin
			test_data_en	<=	1'b1;
			test_data		<=	test_data + 'd1;
		end
	end
	else begin
		test_data_en	<=	'd0;
		test_data		<=	64'hffff_ffff_ffff_ffff;
	end
end

always @(posedge ddr_ui_clk or posedge rst) 
begin
	if(rst || (~ddr3_init_done)) begin
		ddr_test_ok		<=	'd0;
		ddr_test_cnt	<=	'd0;
	end
	else if(ddr_rd_en) begin
		ddr_test_cnt	<=	ddr_test_cnt + 'd8;
		if( (ddr_rd_data[63:0] 		== ddr_test_cnt		 ) &&
			(ddr_rd_data[127:64] 	== ddr_test_cnt + 'd1) &&
			(ddr_rd_data[191:128]	== ddr_test_cnt + 'd2) &&
			(ddr_rd_data[255:192] 	== ddr_test_cnt + 'd3) &&
			(ddr_rd_data[319:256] 	== ddr_test_cnt + 'd4) &&
			(ddr_rd_data[383:320] 	== ddr_test_cnt + 'd5) &&
			(ddr_rd_data[447:384]	== ddr_test_cnt + 'd6) &&
			(ddr_rd_data[511:448]	== ddr_test_cnt + 'd7) ) begin
			ddr_test_ok		<=	'd1;
		end
		else begin
			ddr_test_ok		<=	'd0;
		end
	end
	else begin
		ddr_test_ok		<=	ddr_test_ok;
		ddr_test_cnt	<=	ddr_test_cnt;
	end
end

test_data_to_ddr3_fifo test_data_to_ddr3_fifo_inst(
		.rst(rst),
		.wr_clk(clk),
		.rd_clk(ddr_ui_clk),
		.din(test_data),
		.wr_en(test_data_en),
		.rd_en(ddr_wr_en),
		.dout(ddr_wr_data_temp),
		.full(eds_to_ddr3_fifo_full),
		.empty(),
		.rd_data_count(ddr_wr_data_count)
);

assign	ddr_wr_data		=	{ddr_wr_data_temp[63:0],ddr_wr_data_temp[127:64],ddr_wr_data_temp[191:128],ddr_wr_data_temp[255:192],
							 ddr_wr_data_temp[319:256],ddr_wr_data_temp[383:320],ddr_wr_data_temp[447:384],ddr_wr_data_temp[511:448]};

// ila_ddr_test	ila_ddr_test_inst(
// 		.clk(ddr_ui_clk),
// 		.probe0(ddr_rd_en),
// 		.probe1(ddr_rd_data),
// 		.probe2(ddr_test_cnt),
// 		.probe3(ddr_test_ok),
// 		.probe4(ddr3_init_done)
// );

endmodule
