`timescale 1ns/1ps

module m_s2p(
	input				i_clk			,
	input				i_rst_n			,
	input				i_uart_rx		,
	input				i_bps_done		,	
	output reg			o_bps_en,
	output reg			o_rx_en,
	output reg	[7:0] 	o_rx_data
    );

reg		[1:0]			r_uart_rx		;
wire 					neg_uart_rx		;
reg		[3:0]			r_bit_cnt		;
reg		[7:0]			r_rx_data		;

////////////////////////////////////////////
//����i_uart_rx�źŵ��½���

always @(posedge i_clk)
	if(!i_rst_n) r_uart_rx <= 'b0;
	else r_uart_rx <= {r_uart_rx[0],i_uart_rx};

assign neg_uart_rx = r_uart_rx[1] & ~r_uart_rx[0];

////////////////////////////////////////////
//���������ʼ���ʹ���ź�o_bps_done

always @(posedge i_clk)
	if(!i_rst_n) o_bps_en <= 'b0;
	else if(neg_uart_rx && !o_bps_en) o_bps_en <= 'b1;
	else if(i_bps_done && (r_bit_cnt == 4'd9)) o_bps_en <= 'b0;
	else ;
	
////////////////////////////////////////////
//i_uart_rx������λ���м���

always @(posedge i_clk)
	if(!i_rst_n) r_bit_cnt <= 'b0;
	else if(!o_bps_en) r_bit_cnt <= 'b0;
	else if(i_bps_done) r_bit_cnt <= r_bit_cnt+1;
	else ;
	
////////////////////////////////////////////
//��i_uart_rx����Ч���ݽ��д���ת��������

always @(posedge i_clk)
	if(!i_rst_n) r_rx_data <= 'b0;
	else if(i_bps_done) begin
		case(r_bit_cnt)
			4'd1: r_rx_data[0] <= i_uart_rx;
			4'd2: r_rx_data[1] <= i_uart_rx;
			4'd3: r_rx_data[2] <= i_uart_rx;
			4'd4: r_rx_data[3] <= i_uart_rx;
			4'd5: r_rx_data[4] <= i_uart_rx;
			4'd6: r_rx_data[5] <= i_uart_rx;
			4'd7: r_rx_data[6] <= i_uart_rx;
			4'd8: r_rx_data[7] <= i_uart_rx;
			default: ;
		endcase
	end
	else ;
	
////////////////////////////////////////////
//��������������Ч�źźͲ�����������

always @(posedge i_clk)
	if(!i_rst_n) o_rx_en <= 'b0;
	else if(i_bps_done && (r_bit_cnt == 4'd9)) o_rx_en <= 'b1;
	else o_rx_en <= 'b0;
	
always @(posedge i_clk)
	if(i_bps_done && (r_bit_cnt == 4'd9)) o_rx_data <= r_rx_data;
	else ;	

endmodule

