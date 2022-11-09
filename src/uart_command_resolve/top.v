module top_uart_cmd_resolve(
    input            clk,
    input            rst_n,
    input            uart_rx,
    
    output  [31:0]   para_list_fixed,
    output  [7:0]    cmdcode,
    output  [7:0]    cmd_len,
    output  [7:0]    check,
    output           led_en,
    output           cmd_vaild
);

`define CLK_PERIORD						20		//时钟周期设置为20ns（50MHz）	
parameter UART_BPS_RATE 		= 		115200;
parameter BPS_DLY_BIT			= 		1000000000/UART_BPS_RATE;

wire					w_bps_en;
wire					w_bps_done;
wire					w_rx_en;
wire	[7:0] 			w_rx_data;

m_bps #(
	.UART_BPS_RATE(UART_BPS_RATE),	//串口波特率设置（<=115200），单位：bps
	.CLK_PERIORD(`CLK_PERIORD)		//时钟周期设置，单位：ns
) u_m_bps(
	.i_clk(clk),
	.i_rst_n(rst_n),
	.i_bps_en(w_bps_en),
	.o_bps_done(w_bps_done)
);

m_s2p u_m_s2p(
	.i_clk(clk),
	.i_rst_n(rst_n),
	.i_uart_rx(uart_rx),
	.i_bps_done(w_bps_done),	
	.o_bps_en(w_bps_en),
	.o_rx_en(w_rx_en),
	.o_rx_data(w_rx_data)
);

wire        cmd_vaild;
wire [7:0]  cmdcode;
wire [7:0]  cmd_len;
wire [31:0] para_list;
m_decoder u_m_decoder(
	.clk(clk),
	.rst_n(rst_n),
	.i_rx_en(w_rx_en),
	.i_rx_data(w_rx_data),
	.o_led_en(led_en),
	.o_para_list(para_list),
	.o_check(check),
    .cmdcode(cmdcode),
    .cmd_len(cmd_len),
    .cmd_vaild(cmd_vaild)
);
assign para_list_fixed = {para_list[7:0],para_list[15:8],para_list[23:16],para_list[31:24]};


endmodule
