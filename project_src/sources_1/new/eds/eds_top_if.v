`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/11 8:40:10
// Design Name: 
// Module Name: eds_top_if
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


module eds_top_if(
		input	wire		clk,
		input	wire		clk_h,
		input	wire		rst,
		
		output	wire		eds_clk,
        input   wire        clk_div_3,
        input   wire        clk_div_6,
		//spi if
		output	reg			spi_clk,
		output	reg			spi_mosi,
		
		input	wire		eds_power_en,
		input	wire		eds_frame_en,
		input	wire [31:0]	texp_time,
		input	wire [31:0]	frame_to_frame_time,
		input	wire		pcie_eds_frame_end,
		
		input	wire		eds_test_en,
		
		output	wire		eds_sensor_training_done,
		output	wire		eds_sensor_training_result,
		
		input	wire [7:0]	eds_data_in,
		
        // output  wire        eds_scan_en_o       ,
		output	wire		eds_sensor_data_en,
		output	wire [127:0]eds_sensor_data

);

// wire			clk_div_6;
// wire			clk_div_3;
wire            rst_h;
wire            rst_div;
wire            idelay_rdy;
reg             idelay_rst;

assign			eds_clk	= clk_div_6;

//////////////////////////////////////////////tx
reg				spi_csn;
reg		[63:0]	tx_data;
reg		[15:0]	tx_data_length;

reg		[3:0]	tx_state;
reg		[15:0]	tx_clk_cnt;
reg		[3:0]	spi_counter;

reg				eds_power_en_reg;
reg				eds_frame_en_reg1;
reg				eds_frame_en_reg2;
wire			up_edg_eds_frame_en;
reg		[31:0]	texp_time_reg;
reg		[31:0]	frame_to_frame_time_reg;

reg				pcie_eds_frame_end_reg1;
reg				pcie_eds_frame_end_reg2;
wire			up_edge_pcie_eds_frame_end;

reg				set_esd_power_en;
reg				set_texp_time;
reg				set_frame_to_frame_time;

reg				eds_test_en_reg;
reg				set_eds_test_en;

xpm_cdc_single #(
    .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
 )
 xpm_cdc_rst_h_inst (
    .dest_out(rst_h), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                         // registered.

    .dest_clk(clk_h), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk(clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in(rst)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );

 xpm_cdc_single #(
    .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
 )
 xpm_cdc_rsst_div_inst (
    .dest_out(rst_div), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                         // registered.

    .dest_clk(clk_div_6), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk(clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in(rst)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
 );


always @(posedge clk_h)begin
	if(rst_h) begin	
		eds_power_en_reg		<=	1'b0;
		eds_frame_en_reg1		<=	1'b0;
		eds_frame_en_reg2		<=	1'b0;
		texp_time_reg			<=	32'd0;
		frame_to_frame_time_reg	<=	32'd0;
		eds_test_en_reg			<=	1'b0;
		pcie_eds_frame_end_reg1	<=	1'b0;
		pcie_eds_frame_end_reg2	<=	1'b0;
	end
	else begin
		eds_power_en_reg		<=	eds_power_en;
		eds_frame_en_reg1		<=	eds_frame_en;
		eds_frame_en_reg2		<=	eds_frame_en_reg1;
		texp_time_reg			<=	texp_time;
		frame_to_frame_time_reg	<=	frame_to_frame_time;
		eds_test_en_reg			<=	eds_test_en;
		pcie_eds_frame_end_reg1	<=	pcie_eds_frame_end;
		pcie_eds_frame_end_reg2	<=	pcie_eds_frame_end_reg1;
	end
end

assign	up_edg_eds_frame_en			= eds_frame_en_reg1 && (~eds_frame_en_reg2);
assign	up_edge_pcie_eds_frame_end 	= pcie_eds_frame_end_reg1 && (~pcie_eds_frame_end_reg2);

always @(posedge clk_h)begin
	if(rst_h) begin	
		set_esd_power_en		<=	1'b0;
		set_texp_time			<=	1'b0;
		set_frame_to_frame_time	<=	1'b0;
		set_eds_test_en			<=	1'b0;
	end
	else begin
		if(eds_power_en_reg == eds_power_en) begin
			set_esd_power_en	<=	1'b0;
		end
		else begin
			set_esd_power_en	<=	1'b1;
		end
		if(texp_time_reg == texp_time) begin
			set_texp_time	<=	1'b0;
		end
		else begin
			set_texp_time	<=	1'b1;
		end
		if(frame_to_frame_time_reg == frame_to_frame_time) begin
			set_frame_to_frame_time	<=	1'b0;
		end
		else begin
			set_frame_to_frame_time	<=	1'b1;
		end
		if(eds_test_en_reg == eds_test_en) begin
			set_eds_test_en	<=	1'b0;
		end
		else begin
			set_eds_test_en	<=	1'b1;
		end
	end
end


always @(posedge clk_h)begin
	if(rst_h) begin	
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


always	@(posedge clk_h)
begin
	if(rst_h) begin
		tx_state	<=	'd0;
	end
	else begin
		case(tx_state)
		4'd0: begin
			if(set_esd_power_en || up_edg_eds_frame_en || set_texp_time || set_frame_to_frame_time || set_eds_test_en || up_edge_pcie_eds_frame_end) begin
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


always	@(posedge clk_h)
begin
	if(rst_h) begin
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
			if(set_esd_power_en) begin
				tx_data			<=	{16'h55aa,16'h0001,15'h0,eds_power_en_reg,16'd0};
				tx_data_length	<=	'd48;
			end
			else if(up_edg_eds_frame_en) begin
				tx_data			<=	{16'h55aa,16'h0002,15'h0,1'b1,16'd0};
				tx_data_length	<=	'd48;
			end
			else if(up_edge_pcie_eds_frame_end) begin
				tx_data			<=	{16'h55aa,16'h0002,15'h0,1'b0,16'd0};
				tx_data_length	<=	'd48;
			end
			else if(set_texp_time) begin
				tx_data			<=	{16'h55aa,16'h0003,texp_time_reg};
				tx_data_length	<=	'd64;
			end
			else if(set_frame_to_frame_time) begin
				tx_data			<=	{16'h55aa,16'h0004,frame_to_frame_time_reg};
				tx_data_length	<=	'd64;
			end
			else if(set_eds_test_en) begin
				tx_data			<=	{16'h55aa,16'h0005,15'h0,eds_test_en_reg,16'd0};
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

//////////////////////////////////////rx

localparam 	lvds_pairs			= 8;
localparam	TRAINING_WORD		= 12'd797;

reg			cmd_start_training;
reg			eds_power_en_reg1;
reg			eds_power_en_reg2;
wire		up_edge_eds_power_en;
reg	 [15:0]	delay_cnt;
reg  		delay_flag;

 /* 200 MHz = 78 ps, at 300 MHz = 52 ps, and at 400 MHz = 39 ps. */
(* IODELAY_GROUP =  "GROUP" *) IDELAYCTRL u_idelayctrl_inst(
		.RDY            (idelay_rdy),
		.REFCLK         (clk_h),
		.RST            (idelay_rst)
);

always @(posedge clk_h) begin
    if(rst_h || ~idelay_rdy)
        idelay_rst <= 'd1;
    else 
        idelay_rst <= 'd0;
end
// BUFR #(
//     .BUFR_DIVIDE("6"),          // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
//     .SIM_DEVICE("7SERIES")      // Must be set to "7SERIES" 
//     ) BUFR_inst1 (
//        .O           (clk_div_6),	// 1-bit output: Clock output port
//        .CE          (1'b1),   	// 1-bit input: Active high, clock enable (Divided modes only)
//        .CLR         (1'b0),   	// 1-bit input: Active high, asynchronous clear (Divided modes only)
//        .I           (clk)      	// 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
// ); 

// BUFR #(
//     .BUFR_DIVIDE("3"),          // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
//     .SIM_DEVICE("7SERIES")      // Must be set to "7SERIES" 
//     ) BUFR_inst2 (
//        .O           (clk_div_3),	// 1-bit output: Clock output port
//        .CE          (1'b1),   	// 1-bit input: Active high, clock enable (Divided modes only)
//        .CLR         (1'b0),   	// 1-bit input: Active high, asynchronous clear (Divided modes only)
//        .I           (clk)      	// 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
// ); 

always @(posedge clk_div_6)begin
	if(rst_div) begin	
		eds_power_en_reg1		<=	1'b0;
		eds_power_en_reg2		<=	1'b0;
	end
	else begin
		eds_power_en_reg1		<=	eds_power_en;
		eds_power_en_reg2		<=	eds_power_en_reg1;
	end
end

assign		up_edge_eds_power_en	=	eds_power_en_reg1 && (~eds_power_en_reg2);

always @(posedge clk_div_6)begin
	if(rst_div) begin	
		cmd_start_training		<=	1'b0;
		delay_flag				<=	1'b0;
		delay_cnt				<=	'd0;
	end
	else if(up_edge_eds_power_en) begin
		cmd_start_training		<=	1'b0;
		delay_flag				<=	1'b1;
		delay_cnt				<=	'd0;
	end
	else if(delay_cnt == 'd2000) begin
		cmd_start_training		<=	1'b1;
		delay_flag				<=	1'b0;
		delay_cnt				<=	'd0;
	end
	else if(delay_flag) begin
		cmd_start_training		<=	1'b0;
		delay_flag				<=	1'b1;
		delay_cnt				<=	delay_cnt + 1'd1;
	end
	else begin
		cmd_start_training		<=	1'b0;
		delay_flag				<=	1'b0;
		delay_cnt				<=	'd0;
	end
end

image_rx #(         
		.lvds_pairs(lvds_pairs) 
    ) image_rx_inst( 
		.clk_rxg					(clk_div_6),	//100M/6
		.clk_rxg_x2					(clk_div_3),
		.clk_ddr					(clk),			//100M
		.rst_rx						(rst_div),
		
		.eds_power_en				(eds_power_en),
		.eds_frame_en				(eds_frame_en),
		.sensor_data				(eds_data_in),
		.training_word				(TRAINING_WORD),
		.cmd_start_training			(cmd_start_training),	//脉冲宽度至少一个clk_rxg周期
		.lval_out			        (eds_sensor_data_en),
		.data_out			        (eds_sensor_data),
		.training_done				(eds_sensor_training_done),
		.training_result			(eds_sensor_training_result)
); 

// // geneare eds_scan_en
// reg eds_scan_en = 'd0;
// always @(posedge clk_h) begin
//     if(up_edg_eds_frame_en)
//         eds_scan_en <= 'd1;
//     else if(up_edge_pcie_eds_frame_end)
//         eds_scan_en <= 'd0;
// end

// assign eds_scan_en_o = eds_scan_en;

// ila_eds_data ila_eds_data_inst(
	// .clk(clk_div_6),
	// .probe0(eds_sensor_data_en),
	// .probe1(eds_sensor_data),
	// .probe2(pcie_eds_frame_end)
// ); 

endmodule