////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2015 Shenzhen Pango Microsystems CO.,LTD                       
// All Rights Reserved.                                                         
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module test_main_ctrl #(
parameter CTRL_ADDR_WIDTH = 28,
parameter MEM_DQ_WIDTH = 16,
parameter MEM_SPACE_AW = 18
)(
   output [CTRL_ADDR_WIDTH-1:0] random_rw_addr,
   output [3:0] random_axi_id,
   output [3:0] random_axi_len,
      
   input clk,
   input rst_n,
   
   input ddrc_init_done,
   output reg init_start,
   input init_done,
   output reg write_en,
   input  write_done_p,
   output reg read_en,
   input  read_done_p      
);

wire [127:0] prbs_dout;
wire random_write_en;

localparam E_IDLE      = 0;
localparam E_INIT      = 1;
localparam E_WR        = 2;
localparam E_RD        = 3;
localparam E_END       = 4;

reg [3:0] state;
always @(posedge clk or negedge rst_n)
   if (!rst_n) begin
      state    <= E_IDLE;
      write_en <= 1'b0;
      read_en  <= 1'b0;
      init_start <= 1'b0;
   end
   else begin
            case (state)
               E_IDLE: begin
                  if (ddrc_init_done)
                     state <= E_INIT;
                     else
                     state <= E_IDLE;
               end
               E_INIT : begin
                init_start <= 1'b1;
                if(init_done) begin
                state <= E_WR;
                init_start <= 1'b0;
            end
            end
               E_WR: begin
                  if (write_done_p) begin
                     write_en <= 1'b0;
                     state <= E_END;
                  end
                  else
                     write_en <= 1'b1;
               end
               E_RD: begin
                  if (read_done_p) begin
                     read_en <= 1'b0;
                     state <= E_END;
                  end
                  else
                     read_en <= 1'b1;                  
               end               
               E_END: begin
               	  if (random_write_en)
               	     state <= E_WR;
               	  else
               	     state <= E_RD;
               end
               default: begin
                  state <= E_IDLE;
               end                                               
      endcase
   end
   
assign prbs_clk_en = write_done_p | read_done_p;

prbs31_128bit  #(
.PRBS_INIT  (128'h1234_5678_9abc_def0_8686_2016_0707_336a),
.PRBS_GEN_EN (1'b1)
)
I_prbs31_128bit(
.clk       (clk),
.rstn      (rst_n),
.clk_en    (prbs_clk_en),

.cnt_mode  (1'b0   ),
.din       (128'd0),
.dout      (prbs_dout),
.insert_er (1'b0),
.error     ()
);

wire [CTRL_ADDR_WIDTH-1:0] random_rw_addr_mask = {CTRL_ADDR_WIDTH{1'b0}} + {MEM_SPACE_AW{1'b1}};

assign random_rw_addr  =  {prbs_dout[96+CTRL_ADDR_WIDTH-8:96], 7'd0} & random_rw_addr_mask;
assign random_axi_id   =  prbs_dout[39:36];
assign random_axi_len  =  prbs_dout[35:32];
assign random_write_en =  prbs_dout[0];

endmodule
