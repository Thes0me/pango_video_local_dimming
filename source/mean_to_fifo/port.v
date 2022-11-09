module port_in(
    input   rd_clk,                 
    input   wr_clk,                
    input   rst_n,                  
    input   data_valid, 
    input   [7:0]   din,           
    input    rd_start,    
    //output  full,                 
    output  empty,  
    output  [7:0]    dout
    );
parameter cnt_max = 42 - 1;

reg     wr_en;
reg     rd_en;
reg     [5:0] cnt;

reg     [7:0]   wr_data;


always @(posedge wr_clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 1'b0;
    end
    else if(data_valid == 1'b1) begin
         
     if(cnt >= cnt_max)
        cnt <= 1'b0;
    else
        cnt <= cnt + 1'b1;
    end

    else
    cnt<=1'b0;
end

/*
always @(posedge wr_clk or negedge rst_n) begin
    if(!rst_n)
    mean_reg[cnt] <= 0;
    else if(data_valid == 1'b1) begin
        mean_reg[cnt] <= din;
    end
    else begin
        mean_reg[cnt] <= mean_reg[cnt];
    end
end
*/

always@(posedge wr_clk or negedge rst_n)begin
    if(!rst_n)begin
        wr_en <= 1'b0;
    end
    else if(data_valid == 1'b1)begin
     if(cnt <= 6'd39)
        wr_en <= 1'b1;
     else 
        wr_en <= 1'b0;
    end
    else
     wr_en <= 1'b0;
end

always@(posedge wr_clk or negedge rst_n)begin
    if(!rst_n)begin
        wr_data <= 8'b0;
    end
    else if(data_valid == 1'b1)begin
        wr_data <= din;
    end
     else begin
        wr_data <= wr_data;
    end
end
//--------------------rd_en--------------------
always  @(posedge rd_clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        rd_en <= 1'b0;
    end
    else if(rd_start==1'b1)begin//读开始信号拉高后，读使能信号拉高
        rd_en <= 1'b1;
    end
    else begin
        rd_en <= 1'b0;
    end
end

// ip replace
// fifo_generator_0 inst_fifo_port (
//   .wr_clk(wr_clk),  // input wire wr_clk
//   .rd_clk(rd_clk),  // input wire rd_clk
//   .din(din),        // input wire [7 : 0] din
//   .wr_en(wr_en),    // input wire wr_en
//   .rd_en(rd_en),    // input wire rd_en
//   .dout(dout),      // output wire [7 : 0] dout
//   .full(),      // output wire full
//   .empty(empty)    // output wire empty
// );

fifo_led mean_in_led_out (
  .wr_clk(wr_clk),                // input
  .wr_rst(),                // input
  .wr_en(wr_en),                  // input
  .wr_data(din),              // input [7:0]
  .wr_full(),              // output
  .almost_full(),      // output
  .rd_clk(rd_clk),                // input
  .rd_rst(),                // input
  .rd_en(rd_en),                  // input
  .rd_data(dout),              // output [7:0]
  .rd_empty(empty),            // output
  .almost_empty()     // output
);

endmodule
