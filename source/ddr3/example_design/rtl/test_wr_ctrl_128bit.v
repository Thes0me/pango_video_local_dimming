`timescale 1ns/1ns
module test_wr_ctrl_128bit #(
    parameter          CTRL_ADDR_WIDTH      =    28,
    parameter          MEM_DQ_WIDTH         =    16,
    parameter          MEM_COL_ADDR_WIDTH   =    10,
    parameter          MEM_SPACE_AW         =    18
)(                        
    input                                clk                ,
    input                                rst_n              ,   
    input                                init_start         ,
    input                                write_en           ,
    output reg                           write_done_p       ,
    output reg                           init_done          ,

    input [CTRL_ADDR_WIDTH-1:0]          random_rw_addr     ,     
    input [3:0]                          random_axi_id      ,
    input [3:0]                          random_axi_len     ,

    input                                data_pattern_01    ,
    input                                random_data_en     ,

    output reg [32-1:0]                  axi_awaddr          ,
    output reg [7:0]                     axi_awid            ,
    output reg [7:0]                     axi_awlen           ,
    output wire [2:0]                    axi_awsize          ,
    output wire [1:0]                    axi_awburst         ,
    output                               axi_awlock          ,
    input                                axi_awready         ,
    output reg                           axi_awvalid         ,
    output [3:0]                         axi_awqos           ,
    output                               axi_awurgent        ,
    output                               axi_awpoison        ,
          
    output reg [128-1:0]                 axi_wdata        ,
    output wire [15:0]                   axi_wstrb        ,
    output reg                           axi_wvalid       ,
    input                                axi_wready       ,
    output reg                           axi_wlast        ,
    
    input [7:0]                          axi_bid        ,
    input [1:0]                          axi_bresp      ,
    input                                axi_bvalid     ,
    output wire                          axi_bready                  
);

localparam DQ_NUM = MEM_DQ_WIDTH/16;
localparam ADDR_NUM_BIT = 31 - CTRL_ADDR_WIDTH;

localparam AXI_ADDR_MAX = (1<<(MEM_SPACE_AW+2));
localparam ADDR_MAX = (1<<(MEM_SPACE_AW+1));

localparam E_IDLE = 0;
localparam E_WR = 1;
localparam E_END = 2;

reg [31:0] init_addr;
reg [31:0] normal_wr_addr;
reg [3:0] state;
wire [7:0] wr_data_addr;
reg [15:0] req_wr_cnt     ;
reg [15:0] execute_wr_cnt ;
wire  write_finished ;
reg [7:0] cnt_len;
wire[127:0] prbs_out;

wire[7:0]   wr_data_random_0;
wire[7:0]   wr_data_random_1;
wire[7:0]   wr_data_random_2;
wire[7:0]   wr_data_random_3;
wire[7:0]   wr_data_random_4;
wire[7:0]   wr_data_random_5;
wire[7:0]   wr_data_random_6;
wire[7:0]   wr_data_random_7;

wire [7:0]   data_0;
wire [7:0]   data_1;
wire [7:0]   data_2;
wire [7:0]   data_3;
wire [7:0]   data_4;
wire [7:0]   data_5;
wire [7:0]   data_6;
wire [7:0]   data_7;

wire [15:0]   wr_data_0;
wire [15:0]   wr_data_1;
wire [15:0]   wr_data_2;
wire [15:0]   wr_data_3;
wire [15:0]   wr_data_4;
wire [15:0]   wr_data_5;
wire [15:0]   wr_data_6;
wire [15:0]   wr_data_7;


assign        axi_awlock        =1'b0     ; 
assign        axi_awqos         =4'b0     ; 
assign        axi_awurgent      =1'b0     ; 
assign        axi_awpoison      =1'b0     ;
assign        axi_bready = 1'b1;

assign  axi_wstrb = {16{1'b1}};
assign  axi_awsize  = 3'b100;
assign  axi_awburst = 2'd1; 

always @(posedge clk or negedge rst_n)
begin
   if (!rst_n) begin
      axi_awaddr     <= 32'b0;  
      axi_awid  <= 8'b0; 
      axi_awlen      <= 8'b0; 
      axi_awvalid    <= 1'b0; 
      state          <= E_IDLE;
      write_done_p   <= 1'b0;
   end
   else begin
    if(init_start) begin
        axi_awlen <= 8'd15;
        if (axi_awaddr < (AXI_ADDR_MAX - 32'h100)) begin
            axi_awvalid <= 1;
            if(axi_awvalid&axi_awready) begin
             axi_awaddr <= axi_awaddr + 32'h100;
             axi_awid  <= axi_awid + 8'b1;
            end
        end
        else if(axi_awaddr == (AXI_ADDR_MAX - 32'h100)) begin
           if(axi_awvalid&axi_awready) 
           axi_awvalid <= 0;
        end
        else
         axi_awvalid <= 0;
    end
    else begin
        if ((state == E_IDLE) && write_en && write_finished) begin //add more condition for easy debug
        axi_awid <= {4'b0000,random_axi_id};
   	    axi_awaddr    <= {{ADDR_NUM_BIT{1'b0}},{random_rw_addr},1'b0};
   	    axi_awlen     <= {4'b0000,{random_axi_len}};
   	    end 
   	    case(state) 
  	     	 E_IDLE: begin
   	     	 	  if (write_en && write_finished)
   	     	 	     state <= E_WR;
   	     	 end
   	     	 E_WR: begin
   	     	 	  axi_awvalid <= 1'b1;   	     	 	  
   	     	 	  if (axi_awvalid&axi_awready) begin
   	     	 	     state <= E_END;
   	     	 	     write_done_p <= 1'b1;
   	     	 	     axi_awvalid <= 1'b0;
   	     	 	  end
   	     	 end
   	     	 E_END: begin
   	     	      axi_awvalid <= 1'b0;
   	     	 	  write_done_p <= 1'b0;
   	     	 	  if (write_finished)
   	     	 	     state <= E_IDLE;
   	     	 end
   	     	 default: begin
   	     	 	  state <= E_IDLE;
   	     	 end   	        
   	endcase 
    end
end
end

always @(posedge clk or negedge rst_n)
begin
   if (!rst_n) begin
     axi_wdata <= 128'h0;
     axi_wvalid <=  0   ;
     axi_wlast  <=  0   ;
     init_addr <= 32'd0;
     normal_wr_addr <= 32'd0;
     cnt_len <= 8'd0;
     init_done <= 0;   
   end
   else begin
    if(init_start) begin
      if(init_addr < ADDR_MAX)begin
        axi_wvalid <= 1;
        axi_wdata <= {wr_data_7,wr_data_6,wr_data_5,wr_data_4,wr_data_3,wr_data_2,wr_data_1,wr_data_0};
        if(init_addr[6:3]==4'b1111) axi_wlast  <=  1;
        else axi_wlast  <=  0;
        if(axi_wvalid&axi_wready) begin 
        init_addr <= init_addr + 32'h8;
        axi_wvalid <= 0;    
    end   
    end
    else begin
       axi_wdata <= 128'h0;
       axi_wvalid <=  0   ;
       axi_wlast  <=  0   ;
       init_done <= 1; 
    end
    end
    else begin
        if(state == E_WR)begin 
        normal_wr_addr <= {1'b0,{axi_awaddr[31:1]}};
        cnt_len <= 8'd0;
        axi_wdata <= 128'h0;
        axi_wvalid <=  0   ;
        axi_wlast  <=  0   ; 
    end
        else if(state == E_END) begin
        axi_wdata <= {wr_data_7,wr_data_6,wr_data_5,wr_data_4,wr_data_3,wr_data_2,wr_data_1,wr_data_0};
        if(cnt_len == axi_awlen) axi_wlast  <=  1;
        else axi_wlast  <=  0;
        if(cnt_len <= axi_awlen) begin 
        axi_wvalid <= 1;
        if(axi_wvalid&axi_wready) begin
        normal_wr_addr <= normal_wr_addr + 32'h8;
        cnt_len <= cnt_len + 8'd1;
        axi_wvalid <= 0;
        end
        end
        else begin
          axi_wdata <= 128'h0;
          axi_wvalid <=  0   ;
          axi_wlast  <=  0   ; 
        end   
    end
    else begin
          axi_wdata <= 128'h0;
          axi_wvalid <=  0   ;
          axi_wlast  <=  0   ;
    end
    end
end
end


assign wr_data_addr = (init_start==1) ? init_addr[7:0] : normal_wr_addr[7:0];

always @(posedge clk or negedge rst_n)
   if (!rst_n) begin
   	  req_wr_cnt     <= 16'd0;
   	  execute_wr_cnt <= 16'd0;
   end
   else if (!init_start)
   begin
   	  if (axi_awvalid & axi_awready) begin
   	  	    req_wr_cnt <= req_wr_cnt + axi_awlen + 1;
   	  end   	  
   	  if (axi_wvalid & axi_wready) begin
   	     execute_wr_cnt <= execute_wr_cnt + 1;
   	  end      
   end
   else begin
   	  req_wr_cnt     <= 8'd0;
   	  execute_wr_cnt <= 8'd0;   
end

assign write_finished = (req_wr_cnt == execute_wr_cnt);

assign  data_0 = wr_data_addr + 8'd0;
assign  data_1 = wr_data_addr + 8'd1;
assign  data_2 = wr_data_addr + 8'd2;
assign  data_3 = wr_data_addr + 8'd3;
assign  data_4 = wr_data_addr + 8'd4;
assign  data_5 = wr_data_addr + 8'd5;
assign  data_6 = wr_data_addr + 8'd6;
assign  data_7 = wr_data_addr + 8'd7;

assign wr_data_0 = data_pattern_01 ? 16'hffff : {wr_data_random_0,(wr_data_random_0 ^ data_0)};
assign wr_data_1 = data_pattern_01 ? 16'h0000 : {wr_data_random_1,(wr_data_random_1 ^ data_1)};
assign wr_data_2 = data_pattern_01 ? 16'hffff : {wr_data_random_2,(wr_data_random_2 ^ data_2)};
assign wr_data_3 = data_pattern_01 ? 16'h0000 : {wr_data_random_3,(wr_data_random_3 ^ data_3)};
assign wr_data_4 = data_pattern_01 ? 16'hffff : {wr_data_random_4,(wr_data_random_4 ^ data_4)};
assign wr_data_5 = data_pattern_01 ? 16'h0000 : {wr_data_random_5,(wr_data_random_5 ^ data_5)};
assign wr_data_6 = data_pattern_01 ? 16'hffff : {wr_data_random_6,(wr_data_random_6 ^ data_6)};
assign wr_data_7 = data_pattern_01 ? 16'h0000 : {wr_data_random_7,(wr_data_random_7 ^ data_7)};

assign wr_data_random_0 = random_data_en ? prbs_out[7:0]   : 8'b0 ;
assign wr_data_random_1 = random_data_en ? prbs_out[15:8]  : 8'b0 ;
assign wr_data_random_2 = random_data_en ? prbs_out[23:16] : 8'b0 ;
assign wr_data_random_3 = random_data_en ? prbs_out[31:24] : 8'b0 ;
assign wr_data_random_4 = random_data_en ? prbs_out[39:32] : 8'b0 ;
assign wr_data_random_5 = random_data_en ? prbs_out[47:40] : 8'b0 ;
assign wr_data_random_6 = random_data_en ? prbs_out[55:48] : 8'b0 ;
assign wr_data_random_7 = random_data_en ? prbs_out[63:56] : 8'b0 ;

prbs31_128bit #(
    .PRBS_INIT      (128'h1234_5678_9abc_def0_8686_2016_0707_336a),
//    .PRBS_INIT      (128'h0),
    .PRBS_GEN_EN    (1'b1       )
)u_prbs(
    .clk            (clk        ),
    .rstn           (rst_n      ),
    .clk_en         (1'b1       ),

    .cnt_mode       (1'b0       ),
    .din            (128'b0     ),
    .dout           (prbs_out   ),
    .insert_er      (1'b0       ),
    .error          (           )
);
                    
endmodule