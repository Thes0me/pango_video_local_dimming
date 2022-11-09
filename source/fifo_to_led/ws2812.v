`timescale 1ns / 1ps

module ws2812(
    input                        sys_clk,
    input                        sys_rst_n,
    input         [5:0]        data_cnt,
    input       [320-1:0]        data0,
    output      reg              LED0 ,
    output      reg              LED1 ,
    output      reg              LED2 ,
    output      reg              LED3 ,
    output      reg              LED4 ,
    output      reg              LED5 ,
    output      reg              LED6 ,
    output      reg              LED7 ,
    output      reg              LED8 ,
    output      reg              LED9 ,
    output      reg              LED10,
    output      reg              LED11,
    output      reg              LED12,
    output      reg              LED13,
    output      reg              LED14,
    output      reg              LED15,
    output      reg              LED16,
    output      reg              LED17,
    output      reg              LED18,
    output      reg              LED19,
    output      reg              LED20, 
    output      reg              LED21 ,
    output      reg              LED22 ,
    output      reg              LED23 ,
    output      reg              LED24 ,
    output      reg              LED25 ,
    output      reg              LED26 ,
    output      reg              LED27 ,
    output      reg              LED28 ,
    output      reg              LED29 ,
    output      reg              LED30,
    output      reg              LED31,
    output      reg              LED32,
    output      reg              LED33,
    output      reg              LED34,
    output      reg              LED35,
    output      reg              LED36,
    output      reg              LED37,
    output      reg              LED38,
    output      reg              LED39
    );
parameter    rst_delay  = 5000;
reg     [50-1:0]             sys_cnt;
reg      [10-1:0]            i;
reg                          led_state;  
parameter    led_number = 20;
reg   [5-1:0]  data_cnt_r;
reg       [24-1:0]           RGB[40-1:0];
reg      [10-1:0]            cnt;
reg      [10-1:0]            led_cnt;
reg                          symbol; 
reg                          RGB_RZ;
reg                           RZ1;
reg                           RZ2;
reg                           RZ3;
reg                           RZ4;
reg                           RZ5;
reg                           RZ6;
reg                           RZ7;
reg                           RZ8;
reg                           RZ9;
reg                          RZ10;
reg                          RZ11;
reg                          RZ12;
reg                          RZ13;
reg                          RZ14;
reg                          RZ15;
reg                          RZ16;
reg                          RZ17;
reg                          RZ18;
reg                          RZ19;
reg                          RZ20;
reg                          RZ21;
reg                          RZ22;
reg                          RZ23;
reg                          RZ24;
reg                          RZ25;
reg                          RZ26;
reg                          RZ27;
reg                          RZ28;
reg                          RZ29;
reg                          RZ30;
reg                          RZ31;
reg                          RZ32;
reg                          RZ33;
reg                          RZ34;
reg                          RZ35;
reg                          RZ36;
reg                          RZ37;
reg                          RZ38;
reg                          RZ39;
assign cnt_flag = (data_cnt_r == data_cnt)? 1'b0:1'b1;

always@(posedge sys_clk or negedge sys_rst_n )begin
    if(!sys_rst_n)
        data_cnt_r <= 1'b0;
    else
        data_cnt_r <= data_cnt;
end

always@(posedge sys_clk or negedge sys_rst_n )begin
    if(!sys_rst_n)
        sys_cnt <= 1'b0;
    else if(data_cnt == 6'b10100)
        sys_cnt <= 32'd0;
    else if(cnt_flag == 1'b1)
        sys_cnt <= 32'd0;
    else sys_cnt <= sys_cnt + 1'b1;
end

always@(posedge sys_clk or negedge sys_rst_n )begin
    if(!sys_rst_n)
        led_state <= 1'b0;
    else 
    if(sys_cnt < rst_delay)
            led_state <= 1'b0;
        else 
        led_state <= 1'b1; 
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		cnt <= 0;
		symbol <= 0;
	end
	else if(led_state == 0)
	begin
	    cnt <= 0;
		symbol <= 0;
	end
	else if(cnt == 32'd67)	begin		
		cnt <= 32'd0;
		symbol <= 1;
	end
	else	begin
		cnt <= cnt + 1'b1;
		symbol <= 0;
	end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
	led_cnt <= 0;
	end else if(led_state == 1'b0)
	led_cnt <= 0;
	else if(symbol && (i == 5'd23))begin
	led_cnt <= led_cnt + 1'b1;
	end
 
	else led_cnt <=led_cnt;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		        i <= 0;
		        RGB_RZ <= 0;
		        RZ1    <= 0;
				RZ2    <= 0;
				RZ3    <= 0;
				RZ4    <= 0;
				RZ5    <= 0;
				RZ6    <= 0;
				RZ7    <= 0;
				RZ8    <= 0;
				RZ9    <= 0;
				RZ10   <= 0;
		        RZ11   <= 0;
		        RZ12   <= 0;
		        RZ13   <= 0;
		        RZ14   <= 0;
		        RZ15   <= 0;
		        RZ16   <= 0;
		        RZ17   <= 0;
		        RZ18   <= 0;
		        RZ19   <= 0;
		        RZ20   <= 0;
		        RZ21   <= 0;
		        RZ22   <= 0;
		        RZ23   <= 0;
		        RZ24   <= 0;
		        RZ25   <= 0;
		        RZ26   <= 0;
		        RZ27   <= 0;
		        RZ28   <= 0;
		        RZ29   <= 0;
		        RZ30   <= 0;
		        RZ31   <= 0;
		        RZ32   <= 0;
		        RZ33   <= 0;
		        RZ34   <= 0;
		        RZ35   <= 0;
		        RZ36   <= 0;
		        RZ37   <= 0;
		        RZ38   <= 0;
		        RZ39   <= 0;
		        	
	end 
	else if(led_state == 1'b0)	
	begin
	    i <= 0;
		RGB_RZ <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
		RZ1    <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
		RZ2    <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
		RZ3    <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
		RZ4    <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
		RZ5    <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
		RZ6    <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
		RZ7    <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
		RZ8    <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
		RZ9    <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
		RZ10   <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
        RZ11   <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
        RZ12   <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
        RZ13   <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
        RZ14   <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
        RZ15   <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
        RZ16   <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
        RZ17   <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
        RZ18   <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
        RZ19   <=  ( RGB[0] & 24'b1 << 23 ) &&  1'b1;
        RZ20   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
		RZ21   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
		RZ22   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
		RZ23   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
		RZ24   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
		RZ25   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
		RZ26   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
		RZ27   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
		RZ28   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
		RZ29   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
		RZ30   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
        RZ31   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
        RZ32   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
        RZ33   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
        RZ34   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
        RZ35   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
        RZ36   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
        RZ37   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
        RZ38   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1;
        RZ39   <=  ( RGB[20] & 24'b1 << 23 ) &&  1'b1; 
	end
	else
	begin
		case (i)
			5'd0,5'd1,5'd2,5'd3,5'd4,5'd5,5'd6,5'd7,5'd8,5'd9,5'd10,5'd11,5'd12,5'd13,5'd14,5'd15,5'd16,5'd17,5'd18,5'd19,5'd20,5'd21,5'd22,5'd23:
			begin	
			     if(symbol)	begin
			     	i <= i + 1;
			     	case(data_cnt)
			     	0:
  begin   RGB_RZ <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;  RZ20 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			     	1:   begin  RZ1  <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ21 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			     	2:   begin  RZ2  <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ22 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			     	3:   begin  RZ3  <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ23 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			     	4:   begin  RZ4  <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ24 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			     	5:   begin  RZ5  <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ25 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			     	6:   begin  RZ6  <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ26 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			     	7:   begin  RZ7  <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ27 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			     	8:   begin  RZ8  <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ28 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			     	9:   begin  RZ9  <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ29 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			       10:   begin  RZ10 <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ30 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			       11:   begin  RZ11 <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ31 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			       12:   begin  RZ12 <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ32 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			       13:   begin  RZ13 <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ33 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			       14:   begin  RZ14 <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ34 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			       15:   begin  RZ15 <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ35 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			       16:   begin  RZ16 <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ36 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			       17:   begin  RZ17 <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ37 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			       18:   begin  RZ18 <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ38 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			       19:   begin  RZ19 <=  ( RGB[led_cnt] & (24'b1 << (23-i))) &&  1'b1;    RZ39 <=  ( RGB[led_cnt+20] & (24'b1 << (23-i))) &&  1'b1;     end
			     endcase
				end
				else	begin
					i <= i;
					RGB_RZ <= RGB_RZ;
					RZ1    <=          RZ1  ;
		            RZ2    <=          RZ2  ;
		            RZ3    <=          RZ3  ;
		            RZ4    <=          RZ4  ;
		            RZ5    <=          RZ5  ;
		            RZ6    <=          RZ6  ;
		            RZ7    <=          RZ7  ;
		            RZ8    <=          RZ8  ;
		            RZ9    <=          RZ9  ;
		            RZ10   <=          RZ10 ;
                    RZ11   <=          RZ11 ;
                    RZ12   <=          RZ12 ;
                    RZ13   <=          RZ13 ;
                    RZ14   <=          RZ14 ;
                    RZ15   <=          RZ15 ;
                    RZ16   <=          RZ16 ;
                    RZ17   <=          RZ17 ;
                    RZ18   <=          RZ18 ;
                    RZ19   <=          RZ19 ;
                    RZ20   <=          RZ20 ;
                    RZ21    <=          RZ21  ;
		            RZ22    <=          RZ22  ;
		            RZ23    <=          RZ23  ;
		            RZ24    <=          RZ24  ;
		            RZ25    <=          RZ25  ;
		            RZ26    <=          RZ26  ;
		            RZ27    <=          RZ27  ;
		            RZ28    <=          RZ28  ;
		            RZ29    <=          RZ29  ;
		            RZ30   <=          RZ30 ;
                    RZ31   <=          RZ31 ;
                    RZ32   <=          RZ32 ;
                    RZ33   <=          RZ33 ;
                    RZ34   <=          RZ34 ;
                    RZ35   <=          RZ35 ;
                    RZ36   <=          RZ36 ;
                    RZ37   <=          RZ37 ;
                    RZ38   <=          RZ38 ;
                    RZ39   <=          RZ39 ;
				end
			end
		  	default:	i <= 0;
		endcase
	end
end
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED0 <= 0;
	end
	else if(data_cnt == 1'b0)
    begin
        if(sys_cnt < 5070)
        LED0 <= 1'b0;
        else if(RGB_RZ == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED0 <= 1;
		    end
		    else	begin
			LED0 <= 0;
		    end 
        end
        else if(RGB_RZ == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED0 <= 1;
		    end
		    else	begin
			LED0 <= 0;
		    end
    end
    else LED0 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED20 <= 0;
	end
	else if(data_cnt == 1'b0)
    begin
        if(sys_cnt < 5070)
        LED20 <= 1'b0;
        else if(RZ20 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED20 <= 1;
		    end
		    else	begin
			LED20 <= 0;
		    end 
        end
        else if(RZ20 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED20 <= 1;
		    end
		    else	begin
			LED20 <= 0;
		    end
    end
    else LED20 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED1 <= 0;
	end
	else if(data_cnt == 1'b1)
    begin
        if(sys_cnt < 5070)
        LED1 <= 1'b0;
        else if(RZ1 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED1 <= 1;
		    end
		    else	begin
			LED1 <= 0;
		    end 
        end
        else if(RZ1 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED1 <= 1;
		    end
		    else	begin
			LED1 <= 0;
		    end
    end
    else LED1 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED21 <= 0;
	end
	else if(data_cnt == 1'b1)
    begin
        if(sys_cnt < 5070)
        LED21 <= 1'b0;
        else if(RZ21 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED21 <= 1;
		    end
		    else	begin
			LED21 <= 0;
		    end 
        end
        else if(RZ21 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED21 <= 1;
		    end
		    else	begin
			LED21 <= 0;
		    end
    end
    else LED21 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED2 <= 0;
	end
	else if(data_cnt == 2'b10)
    begin
        if(sys_cnt < 5070)
        LED2 <= 1'b0;
        else if(RZ2 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED2 <= 1;
		    end
		    else	begin
			LED2 <= 0;
		    end 
        end
        else if(RZ2 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED2 <= 1;
		    end
		    else	begin
			LED2 <= 0;
		    end
    end
    else LED2 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED22 <= 0;
	end
	else if(data_cnt == 2'b10)
    begin
        if(sys_cnt < 5070)
        LED22 <= 1'b0;
        else if(RZ22 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED22 <= 1;
		    end
		    else	begin
			LED22 <= 0;
		    end 
        end
        else if(RZ22 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED22 <= 1;
		    end
		    else	begin
			LED22 <= 0;
		    end
    end
    else LED22 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED3 <= 0;
	end
	else if(data_cnt == 2'b11)
    begin
        if(sys_cnt < 5070)
        LED3 <= 1'b0;
        else if(RZ3 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED3 <= 1;
		    end
		    else	begin
			LED3 <= 0;
		    end 
        end
        else if(RZ3 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED3 <= 1;
		    end
		    else	begin
			LED3 <= 0;
		    end
    end
    else LED3 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED23 <= 0;
	end
	else if(data_cnt == 2'b11)
    begin
        if(sys_cnt < 5070)
        LED23 <= 1'b0;
        else if(RZ23 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED23 <= 1;
		    end
		    else	begin
			LED23 <= 0;
		    end 
        end
        else if(RZ23 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED23 <= 1;
		    end
		    else	begin
			LED23 <= 0;
		    end
    end
    else LED23 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED4 <= 0;
	end
	else if(data_cnt == 3'b100)
    begin
        if(sys_cnt < 5070)
        LED4 <= 1'b0;
        else if(RZ4 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED4 <= 1;
		    end
		    else	begin
			LED4 <= 0;
		    end 
        end
        else if(RZ4 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED4 <= 1;
		    end
		    else	begin
			LED4 <= 0;
		    end
    end
    else LED4 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED24 <= 0;
	end
	else if(data_cnt == 3'b100)
    begin
        if(sys_cnt < 5070)
        LED24 <= 1'b0;
        else if(RZ24 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED24 <= 1;
		    end
		    else	begin
			LED24 <= 0;
		    end 
        end
        else if(RZ24 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED24 <= 1;
		    end
		    else	begin
			LED24 <= 0;
		    end
    end
    else LED24 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED5 <= 0;
	end
	else if(data_cnt == 3'b101)
    begin
        if(sys_cnt < 5070)
        LED5 <= 1'b0;
        else if(RZ5 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED5 <= 1;
		    end
		    else	begin
			LED5 <= 0;
		    end 
        end
        else if(RZ5 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED5 <= 1;
		    end
		    else	begin
			LED5 <= 0;
		    end
    end
    else LED5 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED25 <= 0;
	end
	else if(data_cnt == 3'b101)
    begin
        if(sys_cnt < 5070)
        LED25 <= 1'b0;
        else if(RZ25 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED25 <= 1;
		    end
		    else	begin
			LED25 <= 0;
		    end 
        end
        else if(RZ25 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED25 <= 1;
		    end
		    else	begin
			LED25 <= 0;
		    end
    end
    else LED25 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED6 <= 0;
	end
	else if(data_cnt == 3'b110)
    begin
        if(sys_cnt < 5070)
        LED6 <= 1'b0;
        else if(RZ6 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED6 <= 1;
		    end
		    else	begin
			LED6 <= 0;
		    end 
        end
        else if(RZ6 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED6 <= 1;
		    end
		    else	begin
			LED6 <= 0;
		    end
    end
    else LED6 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED26 <= 0;
	end
	else if(data_cnt == 3'b110)
    begin
        if(sys_cnt < 5070)
        LED26 <= 1'b0;
        else if(RZ26 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED26 <= 1;
		    end
		    else	begin
			LED26 <= 0;
		    end 
        end
        else if(RZ26 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED26 <= 1;
		    end
		    else	begin
			LED26 <= 0;
		    end
    end
    else LED26 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED7 <= 0;
	end
	else if(data_cnt == 3'b111)
    begin
        if(sys_cnt < 5070)
        LED7 <= 1'b0;
        else if(RZ7 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED7 <= 1;
		    end
		    else	begin
			LED7 <= 0;
		    end 
        end
        else if(RZ7 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED7 <= 1;
		    end
		    else	begin
			LED7 <= 0;
		    end
    end
    else LED7 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED27 <= 0;
	end
	else if(data_cnt == 3'b111)
    begin
        if(sys_cnt < 5070)
        LED27 <= 1'b0;
        else if(RZ27 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED27 <= 1;
		    end
		    else	begin
			LED27 <= 0;
		    end 
        end
        else if(RZ27 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED27 <= 1;
		    end
		    else	begin
			LED27 <= 0;
		    end
    end
    else LED27 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED8 <= 0;
	end
	else if(data_cnt == 4'b1000)
    begin
        if(sys_cnt < 5070)
        LED8 <= 1'b0;
        else if(RZ8 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED8 <= 1;
		    end
		    else	begin
			LED8 <= 0;
		    end 
        end
        else if(RZ8 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED8 <= 1;
		    end
		    else	begin
			LED8 <= 0;
		    end
    end
    else LED8 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED28 <= 0;
	end
	else if(data_cnt == 4'b1000)
    begin
        if(sys_cnt < 5070)
        LED28 <= 1'b0;
        else if(RZ28 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED28 <= 1;
		    end
		    else	begin
			LED28 <= 0;
		    end 
        end
        else if(RZ28 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED28 <= 1;
		    end
		    else	begin
			LED28 <= 0;
		    end
    end
    else LED28 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED9 <= 0;
	end
	else if(data_cnt == 4'b1001)
    begin
        if(sys_cnt < 5070)
        LED9 <= 1'b0;
        else if(RZ9 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED9 <= 1;
		    end
		    else	begin
			LED9 <= 0;
		    end 
        end
        else if(RZ9 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED9 <= 1;
		    end
		    else	begin
			LED9 <= 0;
		    end
    end
    else LED9 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED29 <= 0;
	end
	else if(data_cnt == 4'b1001)
    begin
        if(sys_cnt < 5070)
        LED29 <= 1'b0;
        else if(RZ29 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED29 <= 1;
		    end
		    else	begin
			LED29 <= 0;
		    end 
        end
        else if(RZ29 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED29 <= 1;
		    end
		    else	begin
			LED29 <= 0;
		    end
    end
    else LED29 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED10 <= 0;
	end
	else if(data_cnt == 4'b1010)
    begin
        if(sys_cnt < 5070)
        LED10 <= 1'b0;
        else if(RZ10 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED10 <= 1;
		    end
		    else	begin
			LED10 <= 0;
		    end 
        end
        else if(RZ10 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED10 <= 1;
		    end
		    else	begin
			LED10 <= 0;
		    end
    end
    else LED10 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED30 <= 0;
	end
	else if(data_cnt == 4'b1010)
    begin
        if(sys_cnt < 5070)
        LED30 <= 1'b0;
        else if(RZ30 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED30 <= 1;
		    end
		    else	begin
			LED30 <= 0;
		    end 
        end
        else if(RZ30 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED30 <= 1;
		    end
		    else	begin
			LED30 <= 0;
		    end
    end
    else LED30 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED11 <= 0;
	end
	else if(data_cnt == 4'b1011)
    begin
        if(sys_cnt < 5070)
        LED11 <= 1'b0;
        else if(RZ11 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED11 <= 1;
		    end
		    else	begin
			LED11 <= 0;
		    end 
        end
        else if(RZ11 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED11 <= 1;
		    end
		    else	begin
			LED11 <= 0;
		    end
    end
    else LED11 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED31 <= 0;
	end
	else if(data_cnt == 4'b1011)
    begin
        if(sys_cnt < 5070)
        LED31 <= 1'b0;
        else if(RZ31 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED31 <= 1;
		    end
		    else	begin
			LED31 <= 0;
		    end 
        end
        else if(RZ31 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED31 <= 1;
		    end
		    else	begin
			LED31 <= 0;
		    end
    end
    else LED31 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED12 <= 0;
	end
	else if(data_cnt == 4'b1100)
    begin
        if(sys_cnt < 5070)
        LED12 <= 1'b0;
        else if(RZ12 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED12 <= 1;
		    end
		    else	begin
			LED12 <= 0;
		    end 
        end
        else if(RZ12 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED12 <= 1;
		    end
		    else	begin
			LED12 <= 0;
		    end
    end
    else LED12 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED32 <= 0;
	end
	else if(data_cnt == 4'b1100)
    begin
        if(sys_cnt < 5070)
        LED32 <= 1'b0;
        else if(RZ32 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED32 <= 1;
		    end
		    else	begin
			LED32 <= 0;
		    end 
        end
        else if(RZ32 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED32 <= 1;
		    end
		    else	begin
			LED32 <= 0;
		    end
    end
    else LED32 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED13 <= 0;
	end
	else if(data_cnt == 4'b1101)
    begin
        if(sys_cnt < 5070)
        LED13 <= 1'b0;
        else if(RZ13 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED13 <= 1;
		    end
		    else	begin
			LED13 <= 0;
		    end 
        end
        else if(RZ13 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED13 <= 1;
		    end
		    else	begin
			LED13 <= 0;
		    end
    end
    else LED13 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED33 <= 0;
	end
	else if(data_cnt == 4'b1101)
    begin
        if(sys_cnt < 5070)
        LED33 <= 1'b0;
        else if(RZ33 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED33 <= 1;
		    end
		    else	begin
			LED33 <= 0;
		    end 
        end
        else if(RZ33 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED33 <= 1;
		    end
		    else	begin
			LED33 <= 0;
		    end
    end
    else LED33 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED14 <= 0;
	end
	else if(data_cnt == 4'b1110)
    begin
        if(sys_cnt < 5070)
        LED14 <= 1'b0;
        else if(RZ14 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED14 <= 1;
		    end
		    else	begin
			LED14 <= 0;
		    end 
        end
        else if(RZ14 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED14 <= 1;
		    end
		    else	begin
			LED14 <= 0;
		    end
    end
    else LED14 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED34 <= 0;
	end
	else if(data_cnt == 4'b1110)
    begin
        if(sys_cnt < 5070)
        LED34 <= 1'b0;
        else if(RZ34 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED34 <= 1;
		    end
		    else	begin
			LED34 <= 0;
		    end 
        end
        else if(RZ34 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED34 <= 1;
		    end
		    else	begin
			LED34 <= 0;
		    end
    end
    else LED34 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED15 <= 0;
	end
	else if(data_cnt == 4'b1111)
    begin
        if(sys_cnt < 5070)
        LED15 <= 1'b0;
        else if(RZ15 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED15 <= 1;
		    end
		    else	begin
			LED15 <= 0;
		    end 
        end
        else if(RZ15 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED15 <= 1;
		    end
		    else	begin
			LED15 <= 0;
		    end
    end
    else LED15 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED35 <= 0;
	end
	else if(data_cnt == 4'b1111)
    begin
        if(sys_cnt < 5070)
        LED35 <= 1'b0;
        else if(RZ35 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED35 <= 1;
		    end
		    else	begin
			LED35 <= 0;
		    end 
        end
        else if(RZ35 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED35 <= 1;
		    end
		    else	begin
			LED35 <= 0;
		    end
    end
    else LED35 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED16 <= 0;
	end
	else if(data_cnt == 5'b10000)
    begin
        if(sys_cnt < 5070)
        LED16 <= 1'b0;
        else if(RZ16 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED16 <= 1;
		    end
		    else	begin
			LED16 <= 0;
		    end 
        end
        else if(RZ16 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED16 <= 1;
		    end
		    else	begin
			LED16 <= 0;
		    end
    end
    else LED16 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED36 <= 0;
	end
	else if(data_cnt == 5'b10000)
    begin
        if(sys_cnt < 5070)
        LED36 <= 1'b0;
        else if(RZ36 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED36 <= 1;
		    end
		    else	begin
			LED36 <= 0;
		    end 
        end
        else if(RZ36 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED36 <= 1;
		    end
		    else	begin
			LED36 <= 0;
		    end
    end
    else LED36 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED17 <= 0;
	end
	else if(data_cnt == 5'b10001)
    begin
        if(sys_cnt < 5070)
        LED17 <= 1'b0;
        else if(RZ17 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED17 <= 1;
		    end
		    else	begin
			LED17 <= 0;
		    end 
        end
        else if(RZ17 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED17 <= 1;
		    end
		    else	begin
			LED17 <= 0;
		    end
    end
    else LED17 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED37 <= 0;
	end
	else if(data_cnt == 5'b10001)
    begin
        if(sys_cnt < 5070)
        LED37 <= 1'b0;
        else if(RZ37 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED37 <= 1;
		    end
		    else	begin
			LED37 <= 0;
		    end 
        end
        else if(RZ37 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED37 <= 1;
		    end
		    else	begin
			LED37 <= 0;
		    end
    end
    else LED37 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED18 <= 0;
	end
	else if(data_cnt == 5'b10010)
    begin
        if(sys_cnt < 5070)
        LED18 <= 1'b0;
        else if(RZ18 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED18 <= 1;
		    end
		    else	begin
			LED18 <= 0;
		    end 
        end
        else if(RZ18 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED18 <= 1;
		    end
		    else	begin
			LED18 <= 0;
		    end
    end
    else LED18 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED38 <= 0;
	end
	else if(data_cnt == 5'b10010)
    begin
        if(sys_cnt < 5070)
        LED38 <= 1'b0;
        else if(RZ38 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED38 <= 1;
		    end
		    else	begin
			LED38 <= 0;
		    end 
        end
        else if(RZ38 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED38 <= 1;
		    end
		    else	begin
			LED38 <= 0;
		    end
    end
    else LED38 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED19 <= 0;
	end
	else if(data_cnt == 5'b10011)
    begin
        if(sys_cnt < 5070)
        LED19 <= 1'b0;
        else if(RZ19 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED19 <= 1;
		    end
		    else	begin
			LED19 <= 0;
		    end 
        end
        else if(RZ19 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED19 <= 1;
		    end
		    else	begin
			LED19 <= 0;
		    end
    end
    else LED19 <= 1'b1; 	
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)	begin
		LED39 <= 0;
	end
	else if(data_cnt == 5'b10011)
    begin
        if(sys_cnt < 5070)
        LED39 <= 1'b0;
        else if(RZ39 == 0)begin
            if(cnt <= 32'd16)	begin		//?????????0.3us*50M=15
		    LED39 <= 1;
		    end
		    else	begin
			LED39 <= 0;
		    end 
        end
        else if(RZ39 == 1)
            if(cnt <= 32'd50)	begin		//????????0.9us*50M=45
			 LED39 <= 1;
		    end
		    else	begin
			LED39 <= 0;
		    end
    end
    else LED39 <= 1'b1; 	
end

always @(posedge sys_clk) begin
      begin
     RGB[0] <=     {3{data0[8-1:0]    }};
     RGB[1] <=     {3{data0[16-1:8]   }};
     RGB[2] <=     {3{data0[24-1:16]  }};
     RGB[3] <=     {3{data0[32-1:24]  }};
     RGB[4] <=     {3{data0[40-1:32]  }};
     RGB[5] <=     {3{data0[48-1:40]  }};
     RGB[6] <=     {3{data0[56-1:48]  }};
     RGB[7] <=     {3{data0[64-1:56]  }};
     RGB[8] <=     {3{data0[72-1:64]  }};
     RGB[9] <=     {3{data0[80-1:72]  }};
     RGB[10] <=    {3{data0[88-1:80]  }};
     RGB[11] <=    {3{data0[96-1:88]  }};
     RGB[12] <=    {3{data0[104-1:96] }};
     RGB[13] <=    {3{data0[112-1:104]}};
     RGB[14] <=    {3{data0[120-1:112]}};
     RGB[15] <=    {3{data0[128-1:120]}};
     RGB[16] <=    {3{data0[136-1:128]}};
     RGB[17] <=    {3{data0[144-1:136]}};
     RGB[18] <=    {3{data0[152-1:144]}};
     RGB[19] <=    {3{data0[160-1:152]}};
     RGB[20] <=    /*{3{data0[168-1:160]}};*/  {3{data0[320-1:312]}};
     RGB[21] <=    /*{3{data0[176-1:168]}};*/  {3{data0[312-1:304]}};
     RGB[22] <=    /*{3{data0[184-1:176]}};*/  {3{data0[304-1:296]}};
     RGB[23] <=    /*{3{data0[192-1:184]}};*/  {3{data0[296-1:288]}};
     RGB[24] <=    /*{3{data0[200-1:192]}};*/  {3{data0[288-1:280]}};
     RGB[25] <=    /*{3{data0[208-1:200]}};*/  {3{data0[280-1:272]}};
     RGB[26] <=    /*{3{data0[216-1:208]}};*/  {3{data0[272-1:264]}};
     RGB[27] <=    /*{3{data0[224-1:216]}};*/  {3{data0[264-1:256]}};
     RGB[28] <=    /*{3{data0[232-1:224]}};*/  {3{data0[256-1:248]}};
     RGB[29] <=    /*{3{data0[240-1:232]}};*/  {3{data0[248-1:240]}};
     RGB[30] <=    /*{3{data0[248-1:240]}};*/  {3{data0[240-1:232]}};
     RGB[31] <=    /*{3{data0[256-1:248]}};*/  {3{data0[232-1:224]}};
     RGB[32] <=    /*{3{data0[264-1:256]}};*/  {3{data0[224-1:216]}};
     RGB[33] <=    /*{3{data0[272-1:264]}};*/  {3{data0[216-1:208]}};
     RGB[34] <=    /*{3{data0[280-1:272]}};*/  {3{data0[208-1:200]}};
     RGB[35] <=    /*{3{data0[288-1:280]}};*/  {3{data0[200-1:192]}};
     RGB[36] <=    /*{3{data0[296-1:288]}};*/  {3{data0[192-1:184]}};
     RGB[37] <=    /*{3{data0[304-1:296]}};*/  {3{data0[184-1:176]}};
     RGB[38] <=    /*{3{data0[312-1:304]}};*/  {3{data0[176-1:168]}};
     RGB[39] <=    /*{3{data0[320-1:312]}};*/  {3{data0[168-1:160]}};
    end
end



 
endmodule
