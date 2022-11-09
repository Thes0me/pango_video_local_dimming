`timescale 1ns / 1ps
module hc595(
	       clk,
	       rst,
           LED0,
           LED1 ,
           LED2 ,
           LED3 ,
           LED4 ,
           LED5 ,
           LED6 ,
           LED7 ,
           LED8 ,
           LED9 ,
           LED10,
           LED11,
           LED12,
           LED13,
           LED14,
           LED15,
           LED16,
           LED17,
           LED18,
           LED19,
           LED20,
           LED21,
           LED22,
           LED23,
           LED24,
           LED25,
           LED26,
           LED27,
           LED28,
           LED29,
           LED30,
           LED31,
           LED32,
           LED33,
           LED34,
           LED35,
           LED36,
           LED37,
           LED38,
           LED39,     
	       shcp,
	       stcp,
	       ds0,
	       ds1,
	       ds2,
	       ds3,
	       ds4,
	       ds5
);
	input clk,rst;
	input  LED0,LED1,LED2,LED3,LED4,LED5,LED6,LED7,LED8,LED9,LED10,LED11,LED12,LED13,LED14,LED15,LED16,LED17,LED18,LED19;
	input  LED20,LED21,LED22,LED23,LED24,LED25,LED26,LED27,LED28,LED29,LED30,LED31,LED32,LED33,LED34,LED35,LED36,LED37,LED38,LED39;
	output reg shcp;
	output reg stcp;	//输出到引脚的开关
	output reg ds0;
	output reg ds1;
	output reg ds2;
	output reg ds3;
	output reg ds4;
	output reg ds5;

	reg [7:0] diver_cnt;	//分频计数器
	wire sck_plus;
	reg [5:0]shcp_edge_cnt;
	reg [40-1:0]rdata;
	parameter CNT_MAX = 2;
	//parameter [15:0] data = 16'b10101010_10101010;
	parameter S_EN = 1;
	always@(posedge clk)
		if(S_EN)	
			rdata <= {{LED0},{LED1},{LED2},{LED3},{LED4},{LED5},{LED6},{LED7},{LED8},{LED9},{LED10},{LED11},{LED12},{LED13},{LED14},{LED15},{LED16},{LED17},{LED18},{LED19},{LED20},{LED21},{LED22},{LED23},{LED24},{LED25},{LED26},{LED27},{LED28},{LED29},{LED30},{LED31},{LED32},{LED33},{LED34},{LED35},{LED36},{LED37},{LED38},{LED39}} ;
	          //rdata <=  16'b00000000_00000000 + LED0 ;
	always@(posedge clk or negedge rst)
		if(!rst)
			diver_cnt <= 0;
		else if(diver_cnt == CNT_MAX - 1'b1)
			diver_cnt <= 0;
		else
			diver_cnt <= diver_cnt +1'b1;

	//assign sck_plus = (diver_cnt == CNT_MAX - 1'b1);
	assign sck_plus = 1'b1;

/*
	always@(posedge clk or negedge rst)
		if(!rst)
			shcp <= 0;
		else if(sck_plus)
			shcp <= ~shcp;
*/			
	always@(posedge clk or negedge rst)
		if(!rst)
			shcp_edge_cnt <= 0;
		else if(sck_plus)begin
			if(shcp_edge_cnt == 6'd16)
				shcp_edge_cnt <= 0;
			else
				shcp_edge_cnt <= shcp_edge_cnt +1'b1;
		end
		else
			shcp_edge_cnt <= shcp_edge_cnt;

	always@(posedge clk or negedge rst)
		if(!rst)begin
			stcp <= 0;
			ds0 <= 0;
			shcp <= 0;
		end
		else begin
			case(shcp_edge_cnt)
				0:  begin shcp <= 0; stcp <= 0;ds0 <= rdata[39]; ds3 <= rdata[19]; ds1 <= rdata[31];   ds4 <= rdata[11];     ds2 <= rdata[23];    ds5 <= rdata[3]; end
				1:  begin shcp <= 1; end                                                                                                                     
				2:  begin shcp <= 0; ds0 <= rdata[38];           ds3 <= rdata[18]; ds1 <= rdata[30];   ds4 <= rdata[10];     ds2 <= rdata[22];    ds5 <= rdata[2]; end
				3:  begin shcp <= 1; end                                                                                                                     
				4:  begin shcp <= 0; ds0 <= rdata[37];           ds3 <= rdata[17]; ds1 <= rdata[29];  ds4 <= rdata[9];     ds2 <= rdata[21];    ds5 <= rdata[1]; end
				5:  begin shcp <= 1; end                                                                                                                     
				6:  begin shcp <= 0; ds0 <= rdata[36];           ds3 <= rdata[16]; ds1 <= rdata[28];  ds4 <= rdata[8];     ds2 <= rdata[20];    ds5 <= rdata[0]; end
				7:  begin shcp <= 1; end                    
				8:  begin shcp <= 0; ds0 <= rdata[35];           ds3 <= rdata[15]; ds1 <= rdata[27];  ds4 <= rdata[7];     end
				9:  begin shcp <= 1; end                    
				10: begin shcp <= 0; ds0 <= rdata[34];           ds3 <= rdata[14]; ds1 <= rdata[26];  ds4 <= rdata[6];     end
				11: begin shcp <= 1; end                    
				12: begin shcp <= 0; ds0 <= rdata[33];           ds3 <= rdata[13]; ds1 <= rdata[25];  ds4 <= rdata[5];     end
				13: begin shcp <= 1; end                    
				14: begin shcp <= 0; ds0 <= rdata[32];           ds3 <= rdata[12]; ds1 <= rdata[24];  ds4 <= rdata[4];     end
				15: begin shcp <= 1; end
				16: begin stcp <= 1'b1;end
				default: begin shcp <= 0; stcp <= 0; ds0 <= 0; end
			endcase
		end
		
		
endmodule
