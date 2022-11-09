module ipsl_ddrphy_update_ctrl #(
parameter  DATA_WIDTH   ="16BIT" //"16BIT","8BIT"
)(
input rclk,
input rst_n,
input dll_update_n,
input ddr_init_done,
input [7:0] dll_step_copy, //from DLL to monitor outputs
input [1:0] dqs_drift_l,
input [1:0] dqs_drift_h,
input  manual_update,
input  [2:0] update_mask,
output reg update_start,
output reg [1:0] ddrphy_update_type,
output reg [1:0] ddrphy_update_comp_val_l,
output reg ddrphy_update_comp_dir_l,
output reg [1:0] ddrphy_update_comp_val_h ,
output reg ddrphy_update_comp_dir_h,
input  ddrphy_update_done
);

localparam DLL_OFFSET = 2; //offset between dll_step&dll_step_copy for dll_update generation
localparam IDLE       = 0;
localparam REQ        = 1;
localparam UPDATE     = 2;
localparam WAIT_END   = 3;

localparam DQSH_REQ_EN = (DATA_WIDTH=="16BIT") ? 1'b1 : 1'b0;

reg [7:0] last_dll_step;
reg [7:0] dll_step_copy_d1;
reg [7:0] dll_step_copy_d2;
reg [7:0] dll_step_copy_d3;
reg [7:0] dll_step_copy_synced;
reg [1:0] dqs_drift_l_d1;
reg [1:0] dqs_drift_h_d1;
reg [7:0] dqs_drift_l_cnt;
reg [7:0] dqs_drift_h_cnt;
reg [1:0] dqs_drift_l_now;
reg [1:0] dqs_drift_h_now;
reg [1:0] dqs_drift_l_last;
reg [1:0] dqs_drift_h_last;
reg dll_req;
reg dqsi_dpi_mon_req;
reg dly_loop_mon_req;
reg [1:0] state;
reg dqs_drift_req;

reg [1:0] ddrphy_update_comp_val_l_reg;
reg ddrphy_update_comp_dir_l_reg;
reg [1:0] ddrphy_update_comp_val_h_reg ;
reg ddrphy_update_comp_dir_h_reg;

always @(posedge dll_update_n or negedge rst_n)
if(!rst_n)begin
    last_dll_step <= 8'd0;
end
else begin
    last_dll_step <= dll_step_copy;
end
//**********************************************************************************************************************
//DLL update request generation
always @(posedge rclk or negedge rst_n)
   if (!rst_n) begin
   	dll_step_copy_d1     <= 8'd0;
   	dll_step_copy_d2     <= 8'd0;
   	dll_step_copy_d3     <= 8'd0;
   	dll_step_copy_synced <= 8'd0;
   end
   else begin
   	dll_step_copy_d1     <= dll_step_copy;
   	dll_step_copy_d2     <= dll_step_copy_d1;
   	dll_step_copy_d3     <= dll_step_copy_d2;
      //assume that dll_step_copy will not updated continuously
   	if (dll_step_copy_d3 == dll_step_copy_d2)
         dll_step_copy_synced <= dll_step_copy_d2;
   end


wire [7:0] dll_step_minus = last_dll_step - DLL_OFFSET;
wire [7:0] dll_step_plus  = last_dll_step + DLL_OFFSET;

always @(posedge rclk or negedge rst_n)
   if (!rst_n) begin
   	dll_req <= 1'b0;
   end
   else begin
   	if (~update_start) begin
         if ((dll_step_copy_synced >= dll_step_plus) || (dll_step_copy_synced <= dll_step_minus))
            dll_req <= ~update_mask[0];
         else
         dll_req <= 1'b0;
   	end
   	else begin
         dll_req <= 1'b0;
   	end
   end




always @(posedge rclk or negedge rst_n)
begin
 if (!rst_n) begin
 dqs_drift_l_d1 <= 2'b00;
 dqs_drift_l_cnt<= 8'd0; 
 dqs_drift_l_now <= 2'b00;       
  end
  else begin
 dqs_drift_l_d1 <= dqs_drift_l;    
 if(dqs_drift_l_d1==dqs_drift_l) begin
    if(dqs_drift_l_cnt < 8'd255) 
    dqs_drift_l_cnt <= dqs_drift_l_cnt + 8'd1;
end
else dqs_drift_l_cnt <= 8'd0;
 if(dqs_drift_l_cnt == 8'd200)
 dqs_drift_l_now <= dqs_drift_l_d1;
end
end

always @(posedge rclk or negedge rst_n)
begin
 if (!rst_n) begin
 dqs_drift_h_d1 <= 2'b00;
 dqs_drift_h_cnt<= 8'd0; 
 dqs_drift_h_now <= 2'b00;       
  end
  else begin
 dqs_drift_h_d1 <= dqs_drift_h;    
 if(dqs_drift_h_d1==dqs_drift_h) begin
    if(dqs_drift_h_cnt < 8'd255)
    dqs_drift_h_cnt <= dqs_drift_h_cnt + 8'd1;
end
else dqs_drift_h_cnt <= 8'd0;
 if(dqs_drift_h_cnt == 8'd200)
 dqs_drift_h_now <= dqs_drift_h_d1;
end
end


always @(posedge rclk or negedge rst_n)
   if (!rst_n) begin
   	dqs_drift_req <= 1'b0;
   end
   else begin
   	if (~update_start) begin
         if ((dqs_drift_l_now != dqs_drift_l_last)||((dqs_drift_h_now != dqs_drift_h_last) & DQSH_REQ_EN))
         begin
            dqs_drift_req <= ~update_mask[1];
       end 
       else
           dqs_drift_req <= 0;
   	end
   	else begin
         dqs_drift_req <= 1'b0;
   	end
   end

always @(dqs_drift_l_last or dqs_drift_l_now)
begin
    case (dqs_drift_l_last)
        2'b00:begin
            if (dqs_drift_l_now == 2'b01) begin
               ddrphy_update_comp_val_l_reg <= 2'b1;
               ddrphy_update_comp_dir_l_reg <= 1'b1; 
            end
            else if (dqs_drift_l_now == 2'b10) begin
               ddrphy_update_comp_val_l_reg <= 2'b1;
               ddrphy_update_comp_dir_l_reg <= 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_l_reg <= 2'b0;
               ddrphy_update_comp_dir_l_reg <= 1'b0;  
            end
        end
        2'b01:begin
             if (dqs_drift_l_now == 2'b11) begin
               ddrphy_update_comp_val_l_reg <= 2'b1;
               ddrphy_update_comp_dir_l_reg <= 1'b1; 
            end
            else if (dqs_drift_l_now == 2'b00) begin
               ddrphy_update_comp_val_l_reg <= 2'b1;
               ddrphy_update_comp_dir_l_reg <= 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_l_reg <= 2'b0;
               ddrphy_update_comp_dir_l_reg <= 1'b0;  
            end
        end
        2'b10:begin
             if (dqs_drift_l_now == 2'b00) begin
               ddrphy_update_comp_val_l_reg <= 2'b1;
               ddrphy_update_comp_dir_l_reg <= 1'b1; 
            end
            else if (dqs_drift_l_now == 2'b11) begin
               ddrphy_update_comp_val_l_reg <= 2'b1;
               ddrphy_update_comp_dir_l_reg <= 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_l_reg <= 2'b0;
               ddrphy_update_comp_dir_l_reg <= 1'b0;  
            end            
        end
        2'b11:begin
             if (dqs_drift_l_now == 2'b10) begin
               ddrphy_update_comp_val_l_reg <= 2'b1;
               ddrphy_update_comp_dir_l_reg <= 1'b1; 
            end
            else if (dqs_drift_l_now == 2'b01) begin
               ddrphy_update_comp_val_l_reg <= 2'b1;
               ddrphy_update_comp_dir_l_reg <= 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_l_reg <= 2'b0;
               ddrphy_update_comp_dir_l_reg <= 1'b0;  
            end            
        end
        default: begin
               ddrphy_update_comp_val_l_reg <= 2'b0;
               ddrphy_update_comp_dir_l_reg <= 1'b0;             
        end
    endcase        
end


always @(dqs_drift_h_last or dqs_drift_h_now)
begin
    case (dqs_drift_h_last)
        2'b00:begin
            if (dqs_drift_h_now == 2'b01) begin
               ddrphy_update_comp_val_h_reg <= 2'b1;
               ddrphy_update_comp_dir_h_reg <= 1'b1; 
            end
            else if (dqs_drift_h_now == 2'b10) begin
               ddrphy_update_comp_val_h_reg <= 2'b1;
               ddrphy_update_comp_dir_h_reg <= 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_h_reg <= 2'b0;
               ddrphy_update_comp_dir_h_reg <= 1'b0;  
            end
        end
        2'b01:begin
             if (dqs_drift_h_now == 2'b11) begin
               ddrphy_update_comp_val_h_reg <= 2'b1;
               ddrphy_update_comp_dir_h_reg <= 1'b1; 
            end
            else if (dqs_drift_h_now == 2'b00) begin
               ddrphy_update_comp_val_h_reg <= 2'b1;
               ddrphy_update_comp_dir_h_reg <= 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_h_reg <= 2'b0;
               ddrphy_update_comp_dir_h_reg <= 1'b0;  
            end
        end
        2'b10:begin
             if (dqs_drift_h_now == 2'b00) begin
               ddrphy_update_comp_val_h_reg <= 2'b1;
               ddrphy_update_comp_dir_h_reg <= 1'b1; 
            end
            else if (dqs_drift_h_now == 2'b11) begin
               ddrphy_update_comp_val_h_reg <= 2'b1;
               ddrphy_update_comp_dir_h_reg <= 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_h_reg <= 2'b0;
               ddrphy_update_comp_dir_h_reg <= 1'b0;  
            end            
        end
        2'b11:begin
             if (dqs_drift_h_now == 2'b10) begin
               ddrphy_update_comp_val_h_reg <= 2'b1;
               ddrphy_update_comp_dir_h_reg <= 1'b1; 
            end
            else if (dqs_drift_h_now == 2'b01) begin
               ddrphy_update_comp_val_h_reg <= 2'b1;
               ddrphy_update_comp_dir_h_reg <= 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_h_reg <= 2'b0;
               ddrphy_update_comp_dir_h_reg <= 1'b0;  
            end            
        end
        default: begin
               ddrphy_update_comp_val_h_reg <= 2'b0;
               ddrphy_update_comp_dir_h_reg <= 1'b0;             
        end
    endcase        
end

//phy-initiated update interface
always @(posedge rclk or negedge rst_n)
   if (!rst_n) begin
      state   <= IDLE;
      ddrphy_update_type <= 2'b10;
      dqs_drift_l_last <= 2'b0;
      dqs_drift_h_last <= 2'b0;
      ddrphy_update_comp_val_l <= 2'b0;
      ddrphy_update_comp_dir_l <= 1'b0; 
      ddrphy_update_comp_val_h <= 2'b0;
      ddrphy_update_comp_dir_h <= 1'b0;
   end
   else begin
      case (state)
         IDLE: begin
            if(ddr_init_done) begin
            if (dll_req | manual_update | dqs_drift_req)
               state <= UPDATE;
            if(dqs_drift_req) begin
               ddrphy_update_comp_val_l <= ddrphy_update_comp_val_l_reg;
               ddrphy_update_comp_dir_l <= ddrphy_update_comp_dir_l_reg; 
               ddrphy_update_comp_val_h <= ddrphy_update_comp_val_h_reg;
               ddrphy_update_comp_dir_h <= ddrphy_update_comp_dir_h_reg;
               dqs_drift_l_last <= dqs_drift_l_now;
               dqs_drift_h_last <= dqs_drift_h_now; 
            end
             if(dqs_drift_req)
             ddrphy_update_type <= 2'b01;
             else if(dll_req)
             ddrphy_update_type <= 2'b00;
             else if(manual_update)
             ddrphy_update_type <= 2'b10;
             else 
             ddrphy_update_type <= 2'b10;
            end
            else begin
                 dqs_drift_l_last <= dqs_drift_l_now;
                 dqs_drift_h_last <= dqs_drift_h_now;
            end            
         end
         UPDATE: begin
            if (ddrphy_update_done)
               state <= IDLE;
         end
         default: begin
            state <= IDLE;
        end
      endcase
   end
   
always @(posedge rclk or negedge rst_n)
   if (!rst_n) begin
//      dfi_phyupd_req <= 1'b0;
      update_start   <= 1'b0;
   end
   else begin
//      dfi_phyupd_req <= (state == REQ) || (state == UPDATE);
      update_start   <= ((state == UPDATE)) && (~ddrphy_update_done);
   end
   
endmodule