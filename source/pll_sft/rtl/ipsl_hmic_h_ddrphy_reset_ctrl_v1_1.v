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

module ipsl_hmic_h_ddrphy_reset_ctrl_v1_1
(
    input                                top_rst_n                      ,
    input                                clk                            ,

    input                                dll_update_iorst_req,
    output reg                           dll_update_iorst_ack,

    input                                dll_lock                       ,
    input                                pll_lock                       ,
    output reg                           dll_update_req_rst_ctrl        ,
    input                                dll_update_ack_rst_ctrl        ,
    output reg                           srb_rst_dll                    ,    //dll reset
    output wire                          srb_dll_freeze                 ,
    output reg                           ddrphy_rst                     ,
    output reg                           srb_iol_rst                    ,
    output reg                           srb_dqs_rstn                   ,
    output reg                           srb_ioclkdiv_rstn              ,
    output reg                           global_reset_n                 ,
    output reg                           led0_ddrphy_rst                
);

//parameter SRB_DQS_RST_TRAINING_HIGH_CLK = 4;

localparam E_IDLE          = 0;
localparam E_GRESET_DW     = 1;
localparam E_GRESET_UP     = 2;
localparam E_PLL_LOCKED    = 3;
localparam E_DLL_LOCKED    = 4;
localparam E_DLL_UP_HOLD   = 5;
localparam E_PHY_RST_UP    = 6;
localparam E_IO_RST_UP     = 7;
localparam E_IO_RST_END    = 8;
localparam E_PHY_RST_END   = 9;
localparam E_NORMAL        = 10;

reg [3:0] state;
reg [1:0] pll_lock_d;
reg [1:0] dll_lock_d;
reg [7:0] cnt;
reg [1:0] dll_update_ack_rst_ctrl_d;
reg rst_flag;
reg [1:0] dll_update_iorst_req_d;

always @(posedge clk or negedge top_rst_n)
begin
   if (!top_rst_n) begin
      pll_lock_d       <= 2'd0;
      dll_lock_d       <= 2'd0;
      dll_update_ack_rst_ctrl_d <= 2'd0;
      dll_update_iorst_req_d <= 2'd0;
   end
   else begin
      pll_lock_d       <= {pll_lock_d[0], pll_lock};
      dll_lock_d       <= {dll_lock_d[0], dll_lock};
      dll_update_ack_rst_ctrl_d <= {dll_update_ack_rst_ctrl_d[0], dll_update_ack_rst_ctrl};
      dll_update_iorst_req_d <= {dll_update_iorst_req_d[0], dll_update_iorst_req};
   end
end

always @(posedge clk or negedge top_rst_n)
begin
   if (!top_rst_n) begin
      state <= E_IDLE;
      cnt   <= 0; 
   end
   else begin
         case (state)
            E_IDLE: begin //wait for PLL lock
               cnt <= 0;
                  state <= E_GRESET_DW;
            end
            E_GRESET_DW: begin
               if (cnt[3])
                  state <= E_GRESET_UP;
               else
               cnt <= cnt + 1;
            end
            E_GRESET_UP: begin
               cnt <= 0;
               if(pll_lock_d[1])
               state <= E_PLL_LOCKED;   
            end
            E_PLL_LOCKED: begin //wait for DLL lock
               if (cnt[7]) begin
                  if (dll_lock_d[1])
                     state <= E_DLL_LOCKED;
               end
               else begin
                  cnt <= cnt + 1;
               end
            end
            E_DLL_LOCKED: begin
               cnt <= 0;
               if (dll_update_ack_rst_ctrl_d[1])
                  state <= E_DLL_UP_HOLD;
            end
            E_DLL_UP_HOLD: begin
               cnt <= 0;               
               if (~dll_update_ack_rst_ctrl_d[1])
                  state <= E_PHY_RST_UP;
            end
            E_PHY_RST_UP: begin
               if (cnt[2]) begin
                  cnt   <= 0;
                  state <= E_IO_RST_UP;
               end
               else
                  cnt   <= cnt + 1;
            end
            E_IO_RST_UP: begin
               if (cnt[3]) begin
                  state <= E_IO_RST_END;
                  cnt   <= 0;
               end
               else
                  cnt <= cnt + 1;
            end
            E_IO_RST_END: begin //switch back to clkdiv out
               if (cnt[1]) begin
                  cnt   <= 0;
                  state <= E_PHY_RST_END;
               end
               else
                  cnt <= cnt + 1;
            end
            E_PHY_RST_END: begin 
                 if(cnt[2]) begin              
                  state <= E_NORMAL;
                  cnt   <= 0;
                 end
                 else
                  cnt   <= cnt + 1;
            end
            E_NORMAL: begin
              if (~pll_lock_d[1]) begin
              state <= E_IDLE;
              cnt   <= 0; 
              end
              else if(dll_update_iorst_req_d[1])
              begin
              state <= E_IO_RST_UP;
              cnt   <= 0;
              end
            end
            default: begin
                state <= E_IDLE;
            end
         endcase   
   end
end


always @(posedge clk or negedge top_rst_n)
begin
    if (!top_rst_n) begin
         global_reset_n <= 1'b0;
    end
    else begin
         global_reset_n <= ~((state == E_GRESET_DW)||(state == E_IDLE)); 
    end
end

always @(posedge clk or negedge top_rst_n)
begin
    if (!top_rst_n) begin
         rst_flag <= 1'b0;
    end
    else if(state == E_IDLE)
         rst_flag <= 0;
    else if(state == E_NORMAL) begin
         rst_flag <= 1; 
    end
end

always @(posedge clk or negedge top_rst_n)
begin
    if (!top_rst_n)
    dll_update_iorst_ack <= 0;
    else 
    dll_update_iorst_ack <=  state == E_PHY_RST_END;
end

always @(posedge clk or negedge global_reset_n)
begin
   if (!global_reset_n) begin
        ddrphy_rst   <= 1'b1;
        led0_ddrphy_rst  <= 1'b0;
        srb_dqs_rstn <= 1'b1;
        srb_iol_rst <= 1'b0;
        srb_rst_dll <= 1'b1;
        srb_ioclkdiv_rstn <= 1'b1;
        dll_update_req_rst_ctrl <= 1'b0;
   end
   else begin
      srb_rst_dll <= (state == E_GRESET_UP)||(state == E_GRESET_DW)||(state == E_IDLE); //release dll reset after pll is locked
      dll_update_req_rst_ctrl <= state == E_DLL_LOCKED;   
       if(rst_flag == 0)begin  
          if ((state == E_PHY_RST_END)||(state == E_NORMAL))begin
            ddrphy_rst   <= 1'b0;
            led0_ddrphy_rst  <= 1'b1;
          end
          else begin
           ddrphy_rst   <= 1'b1;
           led0_ddrphy_rst  <= 1'b0;            
          end
      end      
      if (state == E_IO_RST_UP)
      begin
        srb_dqs_rstn <= 1'b0;
        srb_iol_rst <= 1'b1;
        srb_ioclkdiv_rstn <= 1'b0; 
      end
      else if (state == E_IO_RST_END)  
      begin
        srb_dqs_rstn <= 1'b1;
        srb_iol_rst <= 1'b0;
        srb_ioclkdiv_rstn <= 1'b1;
     end      
   end
end

assign srb_dll_freeze = 1'b0;

endmodule


