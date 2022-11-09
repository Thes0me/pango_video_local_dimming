`timescale 1ns / 1ps

module data_tx(
        input                             rd_clk,
        input                             rst_n, 
        input                             empty,
       //input                             data_valid,
        input                   [7:0]     dout,
        output     reg          [320-1:0] data0,
       output          reg               rd_start,
       output          reg     [5-1:0]          data_cnt
    );
    
//reg  [5-1:0] data_cnt;  
reg     [6-1:0]  cnt;

always  @(posedge rd_clk or negedge rst_n)begin
    if(!rst_n)begin
        rd_start <= 1'b0;
    end 
    else rd_start <= 1'b1;     
end  

always  @(posedge rd_clk or negedge rst_n)begin
    if(!rst_n)begin
        data_cnt <= 1'b0;
    end 
    else if(data_cnt == 5'b10100)
        data_cnt <= 1'b0;
    else if(cnt == 6'b101000)
        data_cnt <=  data_cnt + 1'b1;
    else data_cnt <= data_cnt;   
end

always  @(posedge rd_clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt <= 1'b0;
    end 
    else if(empty == 1'b1)
        cnt <= 1'b0;
    else cnt <= cnt + 1'b1;     
end

always  @(posedge rd_clk or negedge rst_n)begin
    if(!rst_n)begin
        data0[320-1:0]     <= 1'b0;
    end
    else 
    begin
        case(cnt)
        1: data0[8-1:0]         <= dout[8-1:0];
        2: data0[16-1:8]        <= dout[8-1:0];
        3: data0[24-1:16]       <= dout[8-1:0]; 
        4: data0[32-1:24]       <= dout[8-1:0];
        5: data0[40-1:32]       <= dout[8-1:0];
        6: data0[48-1:40]       <= dout[8-1:0];
        7: data0[56-1:48]       <= dout[8-1:0];
        8: data0[64-1:56]       <= dout[8-1:0];
        9: data0[72-1:64]       <= dout[8-1:0];
       10: data0[80-1:72]       <= dout[8-1:0];
       11: data0[88-1:80]       <= dout[8-1:0];
       12: data0[96-1:88]       <= dout[8-1:0];
       13: data0[104-1:96]      <= dout[8-1:0];
       14: data0[112-1:104]     <= dout[8-1:0];
       15: data0[120-1:112]     <= dout[8-1:0];
       16: data0[128-1:120]     <= dout[8-1:0];
       17: data0[136-1:128]     <= dout[8-1:0];
       18: data0[144-1:136]     <= dout[8-1:0];
       19: data0[152-1:144]     <= dout[8-1:0];
       20: data0[160-1:152]     <= dout[8-1:0];  
       21: data0[168-1:160]     <= dout[8-1:0];
       22: data0[176-1:168]     <= dout[8-1:0];
       23: data0[184-1:176]     <= dout[8-1:0];
       24: data0[192-1:184]     <= dout[8-1:0];
       25: data0[200-1:192]     <= dout[8-1:0];
       26: data0[208-1:200]     <= dout[8-1:0];
       27: data0[216-1:208]     <= dout[8-1:0];
       28: data0[224-1:216]     <= dout[8-1:0];
       29: data0[232-1:224]     <= dout[8-1:0];
       30: data0[240-1:232]     <= dout[8-1:0];
       31: data0[248-1:240]     <= dout[8-1:0];
       32: data0[256-1:248]     <= dout[8-1:0];
       33: data0[264-1:256]     <= dout[8-1:0];
       34: data0[272-1:264]     <= dout[8-1:0];
       35: data0[280-1:272]     <= dout[8-1:0];
       36: data0[288-1:280]     <= dout[8-1:0];
       37: data0[296-1:288]     <= dout[8-1:0];
       38: data0[304-1:296]     <= dout[8-1:0];
       39: data0[312-1:304]     <= dout[8-1:0];
       40: data0[320-1:312]     <= dout[8-1:0];
        endcase
    end
end
endmodule
