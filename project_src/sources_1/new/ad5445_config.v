`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/13 13:26:52
// Design Name: 
// Module Name: ad5445_config
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


module ad5445_config(

input  wire             clk,             //100M
input  wire             rst,
input  wire [11:0]      dac_out,          //外部vio输入，范囿0~4095
output reg              rw_ctr,
output reg              cs_n,
input  wire             dac_out_en,
output reg  [11:0]      d_bit

);

reg [31:0]              t_cnt;
reg                     data_valid;
reg [1:0]               state;
reg                     cnt_en;



always @(posedge clk or posedge rst)begin
    if(rst)
	    t_cnt   <= 'd0;
	else if(data_valid)
	    t_cnt   <= 'd0;
	else if(cnt_en)
	    t_cnt   <= t_cnt + 1'b1;
	else
	    t_cnt   <= 'd0;
end




always @(posedge clk or posedge rst)begin
    if(rst)begin
	    data_valid   <= 1'b0;
		rw_ctr       <= 1'b1;
		cs_n         <= 1'b1;
		cnt_en       <= 1'b0;
		d_bit        <= 'd0;
		state        <= 'd0;
    end
	else begin
	    case(state)
		2'd0: begin
		    if(dac_out_en)begin
			    rw_ctr     <= 1'b0;
				cs_n       <= 1'b0;
				d_bit      <= dac_out;
				cnt_en     <= 1'b1;
				state      <= 4'd1;
				data_valid <= 1'b0;
			end
			else begin
			    rw_ctr     <= 1'b1;
				cs_n       <= 1'b1;
				state      <= state;
			end
		end
		
		2'd1: begin
		    if(t_cnt == 'd1)begin
			    rw_ctr     <= 1'b1;
				cs_n       <= 1'b1;
				d_bit      <= 'd0;
				state      <= 'd2;
			end            
			else begin     
			    rw_ctr     <= rw_ctr;
				cs_n       <= cs_n;
				state      <= state;
			end
		end
		
		2'd2: begin
		    if(t_cnt == 'd3)begin
			    data_valid <= 1'b1;
                state      <= 'd0;
			end
			else begin
			    data_valid <= 1'b0;
                state      <= state;
			end
		end
		default: ;
		endcase	
	end
end


endmodule
