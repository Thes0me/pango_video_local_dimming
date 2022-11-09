module ipsl_ddrphy_reset_ctrl
(
    input                                ddr_rstn_key                   ,
    input                                clk                            ,

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
    output reg                           global_reset                   ,
    output reg                           led0_ddrphy_rst                
);

//parameter SRB_DQS_RST_TRAINING_HIGH_CLK = 4;

localparam e_IDLE          = 0;
localparam e_GRESET_DW     = 1;
localparam e_GRESET_UP     = 2;
localparam e_PLL_LOCKED    = 3;
localparam e_DLL_LOCKED    = 4;
localparam e_DLL_UP_HOLD   = 5;
localparam e_PHY_RST_UP    = 6;
localparam e_IO_RST_UP     = 7;
localparam e_IO_RST_END    = 8;
localparam e_PHY_RST_END   = 9;
localparam e_NORMAL        = 10;

reg [3:0] state;
reg [1:0] pll_lock_d;
reg [1:0] dll_lock_d;
reg [7:0] cnt;
reg [1:0] dll_update_ack_rst_ctrl_d;

always @(posedge clk or negedge ddr_rstn_key)
   if (!ddr_rstn_key) begin
      pll_lock_d       <= 2'd0;
      dll_lock_d       <= 2'd0;
      dll_update_ack_rst_ctrl_d <= 2'd0;
   end
   else begin
      pll_lock_d       <= {pll_lock_d[0], pll_lock};
      dll_lock_d       <= {dll_lock_d[0], dll_lock};      
      dll_update_ack_rst_ctrl_d <= {dll_update_ack_rst_ctrl_d[0], dll_update_ack_rst_ctrl};
   end

always @(posedge clk or negedge ddr_rstn_key)
   if (!ddr_rstn_key) begin
      state <= e_IDLE;
      cnt   <= 0; 
   end
   else begin
         case (state)
            e_IDLE: begin //wait for PLL lock
               cnt <= 0;
                  state <= e_GRESET_DW;
            end
            e_GRESET_DW: begin
               if (cnt[3])
                  state <= e_GRESET_UP;
               else
               cnt <= cnt + 1;
            end
            e_GRESET_UP: begin
               cnt <= 0;
               if(pll_lock_d[1])
               state <= e_PLL_LOCKED;   
            end
            e_PLL_LOCKED: begin //wait for DLL lock
               if (cnt[7]) begin
                  if (dll_lock_d[1])
                     state <= e_DLL_LOCKED;
               end
               else begin
                  cnt <= cnt + 1;
               end
            end
            e_DLL_LOCKED: begin
               cnt <= 0;
               if (dll_update_ack_rst_ctrl_d[1])
                  state <= e_DLL_UP_HOLD;
            end
            e_DLL_UP_HOLD: begin
               cnt <= 0;               
               if (~dll_update_ack_rst_ctrl_d[1])
                  state <= e_PHY_RST_UP;
            end
            e_PHY_RST_UP: begin
               if (cnt[2]) begin
                  cnt   <= 0;
                  state <= e_IO_RST_UP;
               end
               else
                  cnt   <= cnt + 1;
            end
            e_IO_RST_UP: begin
               if (cnt[3]) begin
                  state <= e_IO_RST_END;
                  cnt   <= 0;
               end
               else
                  cnt <= cnt + 1;
            end
            e_IO_RST_END: begin //switch back to clkdiv out
               if (cnt[1]) begin
                  cnt   <= 0;
                  state <= e_PHY_RST_END;
               end
               else
                  cnt <= cnt + 1;
            end
            e_PHY_RST_END: begin               
                  state <= e_NORMAL;
            end
            e_NORMAL: begin
              if (~pll_lock_d[1]) begin
              state <= e_IDLE;
              cnt   <= 0; 
              end
            end
            default: begin
                state <= e_IDLE;
            end
         endcase   
   end


always @(posedge clk or negedge ddr_rstn_key)
if (!ddr_rstn_key) begin
     global_reset <= 1'b0;
end
else begin
     global_reset <= ~((state == e_GRESET_DW)||(state == e_IDLE)); 
end

always @(posedge clk or negedge global_reset)
   if (!global_reset) begin
        ddrphy_rst   <= 1'b1;
        led0_ddrphy_rst  <= 1'b0;
        srb_dqs_rstn <= 1'b1;
        srb_iol_rst <= 1'b0;
        srb_rst_dll <= 1'b1;
        srb_ioclkdiv_rstn <= 1'b1;
        dll_update_req_rst_ctrl <= 1'b0;
   end
   else begin
      srb_rst_dll <= (state == e_GRESET_UP)||(state == e_GRESET_DW)||(state == e_IDLE); //release dll reset after pll is locked
      dll_update_req_rst_ctrl <= state == e_DLL_LOCKED;      
       if ((state == e_PHY_RST_END)||(state == e_NORMAL))begin
         ddrphy_rst   <= 1'b0;
         led0_ddrphy_rst  <= 1'b1;
         end
         else begin
         ddrphy_rst   <= 1'b1;
         led0_ddrphy_rst  <= 1'b0;            
        end
      
      if (state == e_IO_RST_UP)
      begin
        srb_dqs_rstn <= 1'b0;
        srb_iol_rst <= 1'b1;
        srb_ioclkdiv_rstn <= 1'b0; 
      end
      else if (state == e_IO_RST_END)  
      begin
        srb_dqs_rstn <= 1'b1;
        srb_iol_rst <= 1'b0;
        srb_ioclkdiv_rstn <= 1'b1;
     end        
   end


assign srb_dll_freeze = 1'b0;
endmodule 


