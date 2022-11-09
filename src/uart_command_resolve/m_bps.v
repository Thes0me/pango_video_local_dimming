`timescale 1ns/1ps

module m_bps	#(
	parameter	UART_BPS_RATE	= 		115200,	//串口波特率设置（<=115200），单位：bps
	parameter	CLK_PERIORD		= 		20		//时钟周期设置，单位：ns
)
(
	input			i_clk,
	input			i_rst_n,
	input			i_bps_en,
	output reg 		o_bps_done
    );

localparam BPS_CNT_MAX		= 		1000_000_000/UART_BPS_RATE/CLK_PERIORD-1;
localparam BPS_CNT_HALF 	= 		BPS_CNT_MAX/2-1;
	
reg		[15:0] 		r_bps_cnt;	
	
////////////////////////////////////////////
//波特率的分频计数

always @(posedge i_clk)
	if(!i_rst_n) r_bps_cnt <= 'b0;
	else if(i_bps_en) begin
		if(r_bps_cnt < BPS_CNT_MAX) r_bps_cnt <= r_bps_cnt+1;
		else r_bps_cnt <= 'b0;
	end
	else r_bps_cnt <= 'b0;

////////////////////////////////////////////
//产生o_bps_done信号

always @(posedge i_clk)
	if(r_bps_cnt == BPS_CNT_HALF) o_bps_done <= 1'b1;
	else o_bps_done <= 1'b0;
	

endmodule

