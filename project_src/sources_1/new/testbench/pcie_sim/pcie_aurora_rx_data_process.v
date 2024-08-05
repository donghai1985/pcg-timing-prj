`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/22 10:32:24
// Design Name: 
// Module Name: aurora_rx_data_process
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


module pcie_aurora_rx_data_process(
    input                   aurora_log_clk_0        ,
    input                   aurora_rst_0            ,
    input                   pmt_aurora_rxen_i       ,
    input       [31:0]      pmt_aurora_rxdata_i     ,
    input                   pmt_rx_start_i          ,
    input                   pcie_pmt_rx_end_i       ,
    input                   pcie_eds_rx_end_i       ,
    input                   pcie_fbc_rx_end_i       ,

    input                   aurora_log_clk_1        ,
    input                   aurora_rst_1            ,
    input                   eds_aurora_rxen_i       ,
    input       [63:0]      eds_aurora_rxdata_i     ,
    input                   eds_rx_start_i          ,

    input                   pmt_encode_en_i         ,
    input       [63:0]      pmt_encode_data_i       ,

    input                   fbc_rx_start_i          ,

    output  reg             aurora_rxen             ,
    output  reg [63:0]      aurora_rxdata
);

reg [3:0] 	state = 4'd0;

wire		aurora_rst;

reg			pmt_rx_start_reg1;
reg			pmt_rx_start_reg2;
reg			pcie_pmt_rx_end_reg1;
reg			pcie_pmt_rx_end_reg2;
reg			eds_rx_start_reg1;
reg			eds_rx_start_reg2;
reg			pcie_eds_rx_end_reg1;
reg			pcie_eds_rx_end_reg2;
wire        pmt_rx_start_pose;
wire        eds_rx_start_pose;

reg         fbc_rx_start_d0     ;
reg         fbc_rx_start_d1     ;
reg         pcie_fbc_rx_end_d0  ;
reg         pcie_fbc_rx_end_d1  ;
wire        fbc_rx_start_pose   ;

reg			eds_aurora_fifo_rd_en = 1'b0;
reg			eds_aurora_fifo_rd_vld = 1'b0;
wire [63:0]	eds_aurora_fifo_dout;
wire        eds_aurora_fifo_almost_empty;
wire		eds_aurora_fifo_empty;

reg         x_w_encoder_fifo_rd_en = 1'b0;
wire [63:0] x_w_encoder_fifo_dout;
wire        x_w_encoder_fifo_full;
wire        x_w_encoder_fifo_empty;
wire        x_w_encoder_fifo_almost_empty;
wire [14:0]	x_w_encoder_fifo_rd_count;
wire        encoder_fifo_sbiterr;
wire        encoder_fifo_dbiterr;

reg		    pmt_data_fifo_rd_en = 1'b0;
reg         pmt_data_fifo_rd_en_d = 'd0;
reg         pmt_data_fifo_rd_vld = 'd0;
wire [31:0] pmt_data_fifo_dout;
wire        pmt_data_fifo_full;
wire        pmt_data_fifo_empty;
wire        pmt_data_fifo_almost_empty;
wire [14:0]	pmt_data_fifo_rd_count;
wire        pmt_fifo_sbiterr;
wire        pmt_fifo_dbiterr;

// reg	 [15:0]	pmt_data_rd_cnt;

reg	 [35:0]	encoder_test_cnt;
reg  [63-1:0] pmt_test_cnt = 'd0;

always @(posedge aurora_log_clk_0)begin
    // aurora_log_clk_0
    pmt_rx_start_reg1		<=	pmt_rx_start_i;
    pmt_rx_start_reg2		<=	pmt_rx_start_reg1;
    pcie_pmt_rx_end_reg1	<=	pcie_pmt_rx_end_i;
    pcie_pmt_rx_end_reg2	<=	pcie_pmt_rx_end_reg1;
    pcie_eds_rx_end_reg1	<=	pcie_eds_rx_end_i;
    pcie_eds_rx_end_reg2	<=	pcie_eds_rx_end_reg1;
    pcie_fbc_rx_end_d0      <=  pcie_fbc_rx_end_i;
    pcie_fbc_rx_end_d1      <=  pcie_fbc_rx_end_d0;

    // aurora_log_clk_1
    eds_rx_start_reg1		<=	eds_rx_start_i;
    eds_rx_start_reg2		<=	eds_rx_start_reg1;
    fbc_rx_start_d0         <=  fbc_rx_start_i;
    fbc_rx_start_d1         <=  fbc_rx_start_d0;
end

assign	pmt_rx_start_pose	=	pmt_rx_start_reg1 && (~pmt_rx_start_reg2);
assign	eds_rx_start_pose	=	eds_rx_start_reg1 && (~eds_rx_start_reg2);
assign  fbc_rx_start_pose   =   fbc_rx_start_d0   && (~fbc_rx_start_d1);

assign  aurora_rst      =   aurora_rst_0 || aurora_rst_1;
wire    eds_fifo_reset  =   aurora_rst || eds_rx_start_i || fbc_rx_start_i;
eds_aurora_sync_fifo eds_aurora_sync_fifo_inst(
    .rst                    ( eds_fifo_reset                ),  // input wire rst
    .wr_clk                 ( aurora_log_clk_1              ),  // input wire wr_clk
    .rd_clk                 ( aurora_log_clk_0              ),  // input wire rd_clk
    .din                    ( eds_aurora_rxdata_i           ),  // input wire [63 : 0] din
    .wr_en                  ( eds_aurora_rxen_i             ),  // input wire wr_en
    .rd_en                  ( eds_aurora_fifo_rd_en         ),  // input wire rd_en
    .dout                   ( eds_aurora_fifo_dout          ),  // output wire [63 : 0] dout
    .full                   (                               ),  // output wire full
    .almost_empty           ( eds_aurora_fifo_almost_empty  ),  // output wire almost_empty
    .empty                  ( eds_aurora_fifo_empty         )   // output wire empty
);

x_w_encoder_fifo x_w_encoder_fifo_inst (
    .rst                    ( aurora_rst || pmt_rx_start_pose), // input wire rst
    .wr_clk                 ( aurora_log_clk_1              ),  // input wire wr_clk
    .rd_clk                 ( aurora_log_clk_0              ),  // input wire rd_clk
    .din                    ( pmt_encode_data_i             ),  // input wire [63 : 0] din
    .wr_en                  ( pmt_encode_en_i               ),  // input wire wr_en
    .rd_en                  ( x_w_encoder_fifo_rd_en        ),  // input wire rd_en
    .dout                   ( x_w_encoder_fifo_dout         ),  // output wire [63 : 0] dout
    .full                   ( x_w_encoder_fifo_full         ),  // output wire full
    .empty                  ( x_w_encoder_fifo_empty        ),  // output wire empty
    .almost_empty           ( x_w_encoder_fifo_almost_empty ),  // output wire almost_empty
    .sbiterr                ( encoder_fifo_sbiterr          ),  // output wire sbiterr
    .dbiterr                ( encoder_fifo_dbiterr          )   // output wire dbiterr
);

pmt_data_fifo pmt_data_fifo_inst (
    .clk                    ( aurora_log_clk_0              ),  // input wire clk
    .rst                    ( aurora_rst || pmt_rx_start_pose),  // input wire rst
    .din                    ( pmt_aurora_rxdata_i           ),  // input wire [31 : 0] din
    .wr_en                  ( pmt_aurora_rxen_i             ),  // input wire wr_en
    .rd_en                  ( pmt_data_fifo_rd_en           ),  // input wire rd_en
    .dout                   ( pmt_data_fifo_dout            ),  // output wire [31 : 0] dout
    .full                   ( pmt_data_fifo_full            ),  // output wire full
    .empty                  ( pmt_data_fifo_empty           ),  // output wire empty
    .almost_empty           ( pmt_data_fifo_almost_empty    ),  // output wire almost_empty
    .sbiterr                ( pmt_fifo_sbiterr              ),  // output wire sbiterr
    .dbiterr                ( pmt_fifo_dbiterr              )   // output wire dbiterr
);

always @(posedge aurora_log_clk_0)
begin
	if(aurora_rst) begin
		state  			<=	4'd0;
	end
	else if(pmt_rx_start_pose || eds_rx_start_pose || fbc_rx_start_pose) begin
		state  			<=	4'd0;
	end
	else begin
		case(state)
		4'd0: begin
			if(eds_rx_start_reg2) begin
				state  			<=	4'd1;
			end
            else if(fbc_rx_start_d1) begin
                state           <=	4'd6;
            end
			else if(pmt_rx_start_reg2) begin
				state  			<=	4'd4;
			end
			else begin
				state  			<=	4'd0;
			end
		end
		4'd1: begin
			if(pcie_eds_rx_end_reg2) begin
				state  			<=	4'd0;
			end
			// else if(~eds_aurora_fifo_almost_empty) begin
			// 	state  			<=	state + 1'd1;
			// end
			else begin
				state  			<=	state;
			end
		end
		// 4'd2: begin
		// 	state  			<=	4'd1;
		// end
        
        4'd6: begin
            if(pcie_fbc_rx_end_d1) begin
                state           <=  4'd0;
            end
            // else if(~eds_aurora_fifo_almost_empty) begin
            //     state           <=  state + 1'd1;
            // end
            else begin
                state           <=  state;
            end
        end
        // 4'd7: begin
        //     state           <=  4'd6;
        // end
		
		4'd4: begin
			if(pcie_pmt_rx_end_reg2) begin
				state  			<=	4'd0;
			end
			// else if((~x_w_encoder_fifo_almost_empty) && (~pmt_data_fifo_almost_empty)) begin
			// 	state  			<=	state + 1'd1;
			// end
			else begin
				state  			<=	state;
			end
		end
		// 4'd5: begin
		// 	state  			<=	4'd4;
		// end

		default: begin
			state  			<=	4'd0;
		end
		endcase
	end
end

always @(posedge aurora_log_clk_0)
begin
    case(state)
        4'd0: begin
            eds_aurora_fifo_rd_en   <= 'b0;
            x_w_encoder_fifo_rd_en  <= 'b0;
            pmt_data_fifo_rd_en     <= 'b0;
            aurora_rxen             <= 'b0;
            aurora_rxdata           <= 'd0;
        end
        4'd1: begin
            eds_aurora_fifo_rd_vld  <= eds_aurora_fifo_rd_en;  // read latency 

            aurora_rxen             <= eds_aurora_fifo_rd_vld;
            aurora_rxdata           <= eds_aurora_fifo_dout;

            if(pcie_eds_rx_end_reg2) begin
                eds_aurora_fifo_rd_en <= 'b0;
            end
            else if(~eds_aurora_fifo_almost_empty) begin
                eds_aurora_fifo_rd_en <= 'b1;
            end
            else begin
                eds_aurora_fifo_rd_en <= 'b0;
            end
        end
        // 4'd2: begin
        //     eds_aurora_fifo_rd_en   <= 'b0;
        //     aurora_rxen             <= 'b1;
        //     aurora_rxdata           <= eds_aurora_fifo_dout;
        // end

        4'd6: begin
            eds_aurora_fifo_rd_vld  <= eds_aurora_fifo_rd_en;  // read latency 

            aurora_rxen             <= eds_aurora_fifo_rd_vld;
            aurora_rxdata           <= eds_aurora_fifo_dout;

            if(pcie_fbc_rx_end_d1) begin
                eds_aurora_fifo_rd_en   <=  'b0;
            end
            else if(~eds_aurora_fifo_almost_empty) begin
                eds_aurora_fifo_rd_en   <=  'b1;
            end
            else begin
                eds_aurora_fifo_rd_en   <=  'b0;
            end
        end
        // 4'd7: begin
        //     eds_aurora_fifo_rd_en   <= 'b0;
        //     aurora_rxen             <= 'b1;
        //     aurora_rxdata           <= eds_aurora_fifo_dout;
        // end

        4'd4: begin
            pmt_data_fifo_rd_en_d   <= pmt_data_fifo_rd_en && x_w_encoder_fifo_rd_en;
            pmt_data_fifo_rd_vld    <= pmt_data_fifo_rd_en_d;
            
            aurora_rxen             <= pmt_data_fifo_rd_vld;
            aurora_rxdata           <= {1'b0,11'd0,x_w_encoder_fifo_dout[49:32],x_w_encoder_fifo_dout[17:0],pmt_data_fifo_dout[15:0]}; // {1'b1,pmt_test_cnt[62:0]}; 

            if(pcie_pmt_rx_end_reg2) begin
                x_w_encoder_fifo_rd_en  <= 1'b0;
                pmt_data_fifo_rd_en     <= 1'b0;
            end
            else if((~x_w_encoder_fifo_almost_empty) && (~pmt_data_fifo_almost_empty)) begin
                x_w_encoder_fifo_rd_en  <= 1'b1;
                pmt_data_fifo_rd_en     <= 1'b1;
            end
            else begin
                x_w_encoder_fifo_rd_en  <= 1'b0;
                pmt_data_fifo_rd_en     <= 1'b0;
            end
        end
        // 4'd5: begin
        //     x_w_encoder_fifo_rd_en  <= 1'b0;
        //     pmt_data_fifo_rd_en     <= 1'b0;
        //     aurora_rxen             <= 1'b1;
        //     aurora_rxdata           <= {1'b0,11'd0,x_w_encoder_fifo_dout[49:32],x_w_encoder_fifo_dout[17:0],pmt_data_fifo_dout[15:0]}; // {1'b1,pmt_test_cnt[62:0]}; 
        // end
        default: begin
            eds_aurora_fifo_rd_en   <= 'b0;
            x_w_encoder_fifo_rd_en  <= 'b0;
            pmt_data_fifo_rd_en     <= 'b0;
            aurora_rxen             <= 'b0;
            aurora_rxdata           <= 'd0;
        end
    endcase
end

// reg	[15:0]	test_cnt;
// reg			pmt_data_error;
// // reg			encoder_error;

// always @(posedge aurora_log_clk_0)
// begin
// 	if(aurora_rst) begin
// 		test_cnt		<=	'd0;
// 		pmt_data_error	<=	1'b0;
// 		// encoder_error	<=	1'b0;
// 	end
// 	else if(pmt_rx_start_reg2 || pcie_pmt_rx_end_reg2) begin
// 		test_cnt		<=	'd0;
// 		pmt_data_error	<=	1'b0;
// 		// encoder_error	<=	1'b0;
// 	end
// 	else if(aurora_rxen) begin
// 		test_cnt		<=	test_cnt + 1'd1;
// 		if(test_cnt == pmt_data_fifo_dout[15:0]) begin
// 			pmt_data_error	<=	pmt_data_error;
// 		end
// 		else begin
// 			pmt_data_error	<=	1'b1;
// 		end
// 		// if(test_cnt == aurora_rxdata[31:16]) begin
// 		// 	encoder_error	<=	encoder_error;
// 		// end
// 		// else begin
// 		// 	encoder_error	<=	1'b1;
// 		// end
// 	end
// 	else begin
// 		test_cnt		<=	test_cnt;
// 		pmt_data_error	<=	pmt_data_error;
// 		// encoder_error	<=	encoder_error;
// 	end
// end

// reg pmt_fifo_sbiterr_state = 'd0;
// always @(posedge aurora_log_clk_0) begin
//     if(aurora_rst || pmt_rx_start_i || pcie_pmt_rx_end_i)begin
//         pmt_fifo_sbiterr_state <= 'd0;
//     end
//     else if(pmt_fifo_sbiterr || pmt_fifo_dbiterr)begin
//         pmt_fifo_sbiterr_state <= 'd1;
//     end
// end
// reg encode_fifo_sbiterr_state = 'd0;
// always @(posedge aurora_log_clk_0) begin
//     if(aurora_rst || pmt_rx_start_i || pcie_pmt_rx_end_i)begin
//         encode_fifo_sbiterr_state <= 'd0;
//     end
//     else if(encoder_fifo_sbiterr || encoder_fifo_dbiterr)begin
//         encode_fifo_sbiterr_state <= 'd1;
//     end
// end

// assign fifo_biterr_state_o = {encode_fifo_sbiterr_state , pmt_fifo_sbiterr_state};

// debug code
// always @(posedge aurora_log_clk_0) begin
//     if(state=='d0)
//         pmt_test_cnt <= 'd0;
//     else if(pmt_data_fifo_rd_en)
//         pmt_test_cnt <= pmt_test_cnt + 1;
// end

endmodule
