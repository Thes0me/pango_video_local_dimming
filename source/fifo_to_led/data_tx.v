module data_tx(
        input                             rd_clk,
        input                             rst_n, 
        input                             empty,
       //input                             data_valid,
       input             [5:0]          block_v_cnt,
        input                   [23:0]     dout,
       output     reg          [960-1:0] data0,
       output          reg               rd_start,
       output          reg     [5:0]          data_cnt
    );
    
//reg  [5-1:0] data_cnt;  
reg     [6-1:0]  cnt;
reg              empty_r;
assign data_flag = ((~empty_r) & empty) ? 1'b1:1'b0;
always  @(posedge rd_clk or negedge rst_n)begin
    if(!rst_n)begin
        rd_start <= 1'b0;
    end 
    else rd_start <= 1'b1;     
end  

always  @(posedge rd_clk or negedge rst_n)begin
    if(!rst_n)begin
        empty_r <= 1'b0;
    end 
    else empty_r <= empty;     
end


always  @(posedge rd_clk or negedge rst_n)begin
    if(!rst_n)begin
        data_cnt <= 1'b0;
    end 
    else if(data_flag == 1'b1)
    data_cnt <=  block_v_cnt-1'b1;
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
        1: data0[24-1:0]         <= dout[24-1:0];
        2: data0[48-1:24]        <= dout[24-1:0];
        3: data0[72-1:48]       <= dout[24-1:0]; 
        4: data0[96-1:72]       <= dout[24-1:0];
        5: data0[120-1:96]       <= dout[24-1:0];
        6: data0[144-1:120]       <= dout[24-1:0];
        7: data0[168-1:144]       <= dout[24-1:0];
        8: data0[192-1:168]       <= dout[24-1:0];
        9: data0[216-1:192]       <= dout[24-1:0];
       10: data0[240-1:216]       <= dout[24-1:0];
       11: data0[264-1:240]       <= dout[24-1:0];
       12: data0[288-1:264]       <= dout[24-1:0];
       13: data0[312-1:288]      <= dout[24-1:0];
       14: data0[336-1:312]     <= dout[24-1:0];
       15: data0[360-1:336]     <= dout[24-1:0];
       16: data0[384-1:360]     <= dout[24-1:0];
       17: data0[408-1:384]     <= dout[24-1:0];
       18: data0[432-1:408]     <= dout[24-1:0];
       19: data0[456-1:432]     <= dout[24-1:0];
       20: data0[480-1:456]     <= dout[24-1:0];  
       21: data0[504-1:480]     <= dout[24-1:0];
       22: data0[528-1:504]     <= dout[24-1:0];
       23: data0[552-1:528]     <= dout[24-1:0];
       24: data0[576-1:552]     <= dout[24-1:0];
       25: data0[600-1:576]     <= dout[24-1:0];
       26: data0[624-1:600]     <= dout[24-1:0];
       27: data0[648-1:624]     <= dout[24-1:0];
       28: data0[672-1:648]     <= dout[24-1:0];
       29: data0[696-1:672]     <= dout[24-1:0];
       30: data0[720-1:696]     <= dout[24-1:0];
       31: data0[744-1:720]     <= dout[24-1:0];
       32: data0[768-1:744]     <= dout[24-1:0];
       33: data0[792-1:768]     <= dout[24-1:0];
       34: data0[816-1:792]     <= dout[24-1:0];
       35: data0[840-1:816]     <= dout[24-1:0];
       36: data0[864-1:840]     <= dout[24-1:0];
       37: data0[888-1:864]     <= dout[24-1:0];
       38: data0[912-1:888]     <= dout[24-1:0];
       39: data0[936-1:912]     <= dout[24-1:0];
       40: data0[960-1:936]     <= dout[24-1:0];
        endcase
    end
end
endmodule