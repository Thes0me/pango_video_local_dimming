`timescale 1ns/1ps


module test_rd_ctrl_64bit #(
   parameter CTRL_ADDR_WIDTH = 28,
   parameter MEM_DQ_WIDTH = 16,
   parameter MEM_COL_ADDR_WIDTH = 10,
   parameter MEM_SPACE_AW = 18
   
)(
   input [CTRL_ADDR_WIDTH-1:0] random_rw_addr,
   input [3:0] random_axi_id,
   input [3:0] random_axi_len,

   input clk,
   input rst_n,   
   input read_en,
   input data_pattern_01,
   input read_double_en,

   output reg read_done_p,
   
    output reg [32-1:0]    axi_araddr          ,
    output reg [7:0]       axi_arid            ,
    output reg [7:0]       axi_arlen           ,
    output wire [2:0]       axi_arsize         ,
    output wire [1:0]       axi_arburst        ,
    output wire             axi_arlock              ,
    output wire [3:0]        axi_arqos               ,
    output wire             axi_arpoison            ,
    output wire             axi_arurgent            ,
    input               axi_arready         ,
    output reg             axi_arvalid         ,

    input   [64-1:0]   axi_rdata           ,
    input   [7:0]       axi_rid             ,
    input               axi_rlast           ,
    input               axi_rvalid          ,
    output wire         axi_rready           ,
    input [1:0]         axi_rresp               ,
   output reg [7:0] err_cnt,
   output reg err_flag_led
   
);

localparam DQ_NUM = MEM_DQ_WIDTH/16;
localparam ADDR_NUM_BIT = 31 - CTRL_ADDR_WIDTH;

localparam E_IDLE = 0;
localparam E_RD   = 1;
localparam E_END  = 2;

reg [15:0] req_rd_cnt;
reg [15:0] execute_rd_cnt;
wire  read_finished;

wire [MEM_DQ_WIDTH-1:0] rd_data0;
wire [MEM_DQ_WIDTH-1:0] rd_data1;
wire [MEM_DQ_WIDTH-1:0] rd_data2;
wire [MEM_DQ_WIDTH-1:0] rd_data3;
wire [MEM_DQ_WIDTH-1:0] rd_data4;
wire [MEM_DQ_WIDTH-1:0] rd_data5;
wire [MEM_DQ_WIDTH-1:0] rd_data6;
wire [MEM_DQ_WIDTH-1:0] rd_data7;

wire [7:0]   addr_0_mux;
wire [7:0]   addr_1_mux;
wire [7:0]   addr_2_mux;
wire [7:0]   addr_3_mux;
wire [7:0]   addr_4_mux;
wire [7:0]   addr_5_mux;
wire [7:0]   addr_6_mux;
wire [7:0]   addr_7_mux;

wire [7:0] rd_data_addr;
reg [3:0]   data_err;

reg         axi_rvalid_d1;
//reg         axi_rvalid_d2;
reg [31:0] normal_rd_addr;
reg [2:0] state;
reg [7:0] cnt_len;
reg rd_cnt;
//reg [7:0] err_cnt;

assign  axi_arlock        =1'b0     ; 
assign  axi_arqos         =4'b0     ; 
assign  axi_arurgent      =1'b0    ; 
assign  axi_arpoison      =1'b0     ;
assign  axi_arsize = 3'b011;
assign  axi_arburst = 2'd1;
assign  axi_rready = 1;

always @(posedge clk or negedge rst_n)
begin
   if (!rst_n) begin
      axi_araddr     <= 32'b0; 
      axi_arid  <= 4'b0; 
      axi_arlen      <= 8'b0; 
      axi_arvalid    <= 1'b0; 
      state          <= E_IDLE;
      read_done_p    <= 1'b0;
      rd_cnt         <=  0;
   end
   else begin          
             if ((state == E_IDLE) & read_en & read_finished) begin
             axi_arid <= {4'b0000,random_axi_id};
   	         axi_araddr <= {{ADDR_NUM_BIT{1'b0}},random_rw_addr,1'b0}; 
   	  	     axi_arlen <= {4'b0000,random_axi_len};   	         
   	      end         
          
          case (state)
              E_IDLE: begin
                   if (read_en & read_finished)
                      state <= E_RD;
                      rd_cnt <= 0;
              end
              E_RD: begin
                   axi_arvalid <= 1'b1;                  
                   if (axi_arvalid&axi_arready) begin
                      axi_arvalid <= 1'b0; 
                      state <= E_END;
                      rd_cnt <= ~rd_cnt;
                      if(read_double_en) begin
                      if(rd_cnt==1)
                      read_done_p <= 1'b1;
                      else 
                      read_done_p <= 1'b0;
                      end
                     else
                      read_done_p <= 1'b1;
                   end
              end
              E_END: begin
                   axi_arvalid <= 1'b0;
                   read_done_p <= 1'b0;
                   if (read_finished)
                      state <= E_IDLE;
              end
              default: begin
              	  state <= E_IDLE;
              end
          endcase     
        end
end        

always @(posedge clk or negedge rst_n)
begin
   if (!rst_n) begin
     normal_rd_addr <= 32'd0;
     cnt_len <= 8'd0; 
   end
   else begin 
    if(state == E_RD) begin 
      normal_rd_addr <= {1'b0,{axi_araddr[31:1]}};
      cnt_len <= 8'd0;  
    end
    else if(state == E_END) begin
      if(cnt_len <= axi_arlen) begin
        if(axi_rvalid) begin
          normal_rd_addr <= normal_rd_addr + 32'd4;
          cnt_len <= cnt_len + 1;
        end
    end
    end
end
end



always @(posedge clk or negedge rst_n)
   if (!rst_n) begin
   	  req_rd_cnt     <= 16'd0;
   	  execute_rd_cnt <= 16'd0;
   end
   else begin
   	  if (axi_arvalid & axi_arready) begin
   	  	    req_rd_cnt <= req_rd_cnt + axi_arlen + 1;
   	  end   	  
   	  if (axi_rvalid) begin
   	     execute_rd_cnt <= execute_rd_cnt + 1;
   	  end      
   end

assign  read_finished = (req_rd_cnt == execute_rd_cnt);

assign rd_data0 = axi_rdata[MEM_DQ_WIDTH-1:0];
assign rd_data1 = axi_rdata[MEM_DQ_WIDTH*2-1:MEM_DQ_WIDTH];
assign rd_data2 = axi_rdata[MEM_DQ_WIDTH*3-1:MEM_DQ_WIDTH*2];
assign rd_data3 = axi_rdata[MEM_DQ_WIDTH*4-1:MEM_DQ_WIDTH*3];
//assign rd_data4 = axi_rdata[MEM_DQ_WIDTH*5-1:MEM_DQ_WIDTH*4];
//assign rd_data5 = axi_rdata[MEM_DQ_WIDTH*6-1:MEM_DQ_WIDTH*5];
//assign rd_data6 = axi_rdata[MEM_DQ_WIDTH*7-1:MEM_DQ_WIDTH*6];
//assign rd_data7 = axi_rdata[MEM_DQ_WIDTH*8-1:MEM_DQ_WIDTH*7];

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        axi_rvalid_d1 <= 1'b0;
//        axi_rvalid_d2 <= 1'b0;
    end
    else
    begin
        axi_rvalid_d1 <= axi_rvalid;
//        axi_rvalid_d2 <= axi_rvalid_d1;
    end
end

assign rd_data_addr = normal_rd_addr[7:0];

assign addr_0_mux = rd_data_addr + 8'd0;
assign addr_1_mux = rd_data_addr + 8'd1;
assign addr_2_mux = rd_data_addr + 8'd2;
assign addr_3_mux = rd_data_addr + 8'd3;
//assign addr_4_mux = rd_data_addr + 8'd4;
//assign addr_5_mux = rd_data_addr + 8'd5;
//assign addr_6_mux = rd_data_addr + 8'd6;
//assign addr_7_mux = rd_data_addr + 8'd7;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        data_err[0] <= 1'b0;
        data_err[1] <= 1'b0;
        data_err[2] <= 1'b0;
        data_err[3] <= 1'b0;
     //   data_err[4] <= 1'b0;
     //   data_err[5] <= 1'b0;
     //   data_err[6] <= 1'b0;
     //   data_err[7] <= 1'b0;
    end
    else
    begin
        if(data_pattern_01) begin
        data_err[0] <= rd_data0 == 16'hffff;
        data_err[1] <= rd_data1 == 16'h0000;
        data_err[2] <= rd_data2 == 16'hffff;
        data_err[3] <= rd_data3 == 16'h0000;
     //   data_err[4] <= rd_data4 == 16'hffff;
     //   data_err[5] <= rd_data5 == 16'h0000;
     //   data_err[6] <= rd_data6 == 16'hffff;
     //   data_err[7] <= rd_data7 == 16'h0000;
    end
    else begin
        data_err[0] <= DATA_CHK(rd_data0,addr_0_mux);
        data_err[1] <= DATA_CHK(rd_data1,addr_1_mux);
        data_err[2] <= DATA_CHK(rd_data2,addr_2_mux);
        data_err[3] <= DATA_CHK(rd_data3,addr_3_mux);
      //  data_err[4] <= DATA_CHK(rd_data4,addr_4_mux);
      //  data_err[5] <= DATA_CHK(rd_data5,addr_5_mux);
      //  data_err[6] <= DATA_CHK(rd_data6,addr_6_mux);
      //  data_err[7] <= DATA_CHK(rd_data7,addr_7_mux);
end
    end
end


assign err = |data_err;

function DATA_CHK;
    input [MEM_DQ_WIDTH-1:0] data_in;
    input   [7:0]   addr;
    reg     [7:0]   data_random;
    reg     [MEM_DQ_WIDTH-1:0]  expect_data;
    begin
        data_random = data_in[15:8];
        expect_data = {DQ_NUM{data_random,(data_random ^ addr)}};
        DATA_CHK = data_in != expect_data;
    end
endfunction

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        err_cnt <= 8'b0;
        err_flag_led <= 1'b0;
    end
    else if(err && axi_rvalid_d1)
    begin
        if(err_cnt == 8'hff)
            err_cnt <= err_cnt;
        else
            err_cnt <= err_cnt + 8'b1;
            err_flag_led <= 1'b1;
    end
end        
        
 endmodule
    
      	  	
