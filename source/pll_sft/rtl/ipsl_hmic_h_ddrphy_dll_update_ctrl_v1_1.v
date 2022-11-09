//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS RESERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TQ PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
/////////////////////////////////////////////////////////////////////////////
// Revision:1.0(initial)
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module ipsl_hmic_h_ddrphy_dll_update_ctrl_v1_1
(
input      rclk                   ,
input      rst_n                  ,
input      dll_update_req_rst_ctrl,
output reg dll_update_ack_rst_ctrl,
input      dll_update_req_training,
output reg dll_update_ack_training,
output reg dll_update_iorst_req   ,
input      dll_update_iorst_ack   ,
output reg dll_update_n
);

localparam IDLE     = 2'd0;
localparam DLL_UP   = 2'd1;
localparam WAIT     = 2'd2;
localparam ACK      = 2'd3;

reg [1:0] dll_update_req_rst_ctrl_d;
reg [1:0] state;
reg update_from_training;
reg [0:0] cnt; 
wire update_req;

//*****************************************************
//update from rst_ctrl is async while update req from training is sync
always @(posedge rclk or negedge rst_n)
begin
   if (!rst_n) begin
      dll_update_req_rst_ctrl_d <= 2'd0;
   end
   else begin
      dll_update_req_rst_ctrl_d <= {dll_update_req_rst_ctrl_d[0], dll_update_req_rst_ctrl};
   end
end

assign update_req = dll_update_req_rst_ctrl_d[1] | dll_update_req_training;

always @(posedge rclk or negedge rst_n)
begin
   if (!rst_n) begin
      state                <= IDLE;
      update_from_training <= 1'b0;
      cnt                  <= 0;
   end
   else begin
      case (state)
         IDLE: begin
            cnt   <= 0;
            if (update_req) begin
               state <= DLL_UP;
               update_from_training <= dll_update_req_training;
            end
         end
         DLL_UP: begin //assert dll_update_n; capture DLL step
            if (cnt[0]) begin
               state <= WAIT;
               cnt   <= 0;
            end
            else
               cnt <= cnt + 1;
         end
         WAIT: begin
            if (update_from_training)begin
               if(dll_update_iorst_ack) begin
               cnt   <= 0;
               state <= ACK;
               end
            end
            else begin
               if(cnt[0]) begin
               cnt   <= 0;
               state <= ACK;
               end
               else
               cnt   <= cnt + 1;
            end
         end
         ACK: begin
            cnt   <= 0;
            if (~update_req)
               state <= IDLE;
         end
         default:
            state <= IDLE;
      endcase
   end
end


always @(posedge rclk or negedge rst_n)
begin
  if (!rst_n)
  dll_update_iorst_req <= 0;
  else if((state == WAIT)&&(update_from_training == 1))
  dll_update_iorst_req <= 1; 
  else
  dll_update_iorst_req <= 0;
end
   
always @(posedge rclk or negedge rst_n)
begin
   if (!rst_n) begin
      dll_update_ack_rst_ctrl <= 1'b0;
      dll_update_ack_training <= 1'b0;
      dll_update_n            <= 1'b0;
   end
   else begin
      if (state == ACK) begin
         if (update_from_training)
            dll_update_ack_training <= 1'b1;
         else
            dll_update_ack_rst_ctrl <= 1'b1;
      end
      else begin
         dll_update_ack_training <= 1'b0;
         dll_update_ack_rst_ctrl <= 1'b0;
      end
      
      if (state == DLL_UP)
         dll_update_n <= 1'b0; //when cnt = 0/1
      else
         dll_update_n <= 1'b1;
   end
end
   
endmodule