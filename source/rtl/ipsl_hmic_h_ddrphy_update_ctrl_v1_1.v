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

module ipsl_hmic_h_ddrphy_update_ctrl_v1_1 
#(
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

`ifdef SIMULATION
localparam DLL_DELAY_CNT = 16'd20; 
`else
localparam DLL_DELAY_CNT = 16'd20000;
`endif

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
reg [15:0] dll_cnt;
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

reg [1:0] ddrphy_update_comp_val_l_d;
reg ddrphy_update_comp_dir_l_d;
reg [1:0] ddrphy_update_comp_val_h_d ;
reg ddrphy_update_comp_dir_h_d;
reg [2:0] dll_update_d;
wire [7:0] dll_step_minus;
wire [7:0] dll_step_plus;
wire dll_update_pos;

always @(posedge rclk or negedge rst_n)
begin
    if(!rst_n)
        dll_update_d <= 3'b000;
    else
        dll_update_d <= {dll_update_d[1:0],dll_update_n};
end

assign dll_update_pos = dll_update_d[2:1] == 2'b01;

always @(posedge rclk or negedge rst_n)
begin
    if(!rst_n)begin
        last_dll_step <= 8'd0;
    end
    else if(dll_update_pos) begin
        last_dll_step <= dll_step_copy;
    end
end


//**********************************************************************************
//DLL update request generation
always @(posedge rclk or negedge rst_n)
begin
   if (!rst_n) begin
   	dll_step_copy_d1     <= 8'd0;
   	dll_step_copy_d2     <= 8'd0;
   	dll_step_copy_d3     <= 8'd0;
   end
   else begin
   	dll_step_copy_d1     <= dll_step_copy;
   	dll_step_copy_d2     <= dll_step_copy_d1;
   	dll_step_copy_d3     <= dll_step_copy_d2;
   end
end


always @(posedge rclk or negedge rst_n)
begin
 if (!rst_n) 
 dll_cnt<= 16'd0; 
 else if(dll_update_pos)
 dll_cnt<= 16'd0;
 else if(dll_step_copy_d2 == dll_step_copy_d3)
 begin
    if(dll_cnt < 16'd65535)
    dll_cnt <= dll_cnt + 16'd1;
 end
 else
 dll_cnt<= 16'd0;
end

always @(posedge rclk or negedge rst_n)
begin
 if (!rst_n)
 dll_step_copy_synced <= 8'd0;
 else if(dll_update_pos)
 dll_step_copy_synced <= dll_step_copy_d2;
 else if(dll_cnt == DLL_DELAY_CNT)
 dll_step_copy_synced <= dll_step_copy_d2;
end

assign dll_step_minus = last_dll_step - DLL_OFFSET;
assign dll_step_plus  = last_dll_step + DLL_OFFSET;

always @(posedge rclk or negedge rst_n)
begin
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
end

always @(posedge rclk or negedge rst_n)
begin
 if (!rst_n) begin
    dqs_drift_l_d1 <= 2'b00; 
    dqs_drift_l_now <= 2'b00;       
 end
 else begin
    dqs_drift_l_d1 <= dqs_drift_l; 
    if(dqs_drift_l_cnt == 8'd200)
    dqs_drift_l_now <= dqs_drift_l_d1;   
 end
end

always @(posedge rclk or negedge rst_n)
begin
 if (!rst_n) begin
    dqs_drift_l_cnt<= 8'd0;      
 end
 else begin   
    if(dqs_drift_l_d1==dqs_drift_l) begin
       if(dqs_drift_l_cnt < 8'd255) 
       dqs_drift_l_cnt <= dqs_drift_l_cnt + 8'd1;
    end
    else dqs_drift_l_cnt <= 8'd0;
 end
end

always @(posedge rclk or negedge rst_n)
begin
 if (!rst_n) begin
    dqs_drift_h_d1 <= 2'b00; 
    dqs_drift_h_now <= 2'b00;       
 end
 else begin
    dqs_drift_h_d1 <= dqs_drift_h; 
    if(dqs_drift_h_cnt == 8'd200)
    dqs_drift_h_now <= dqs_drift_h_d1;   
 end
end

always @(posedge rclk or negedge rst_n)
begin
 if (!rst_n) begin
    dqs_drift_h_cnt<= 8'd0;      
 end
 else begin   
    if(dqs_drift_h_d1==dqs_drift_h) begin
       if(dqs_drift_h_cnt < 8'd255) 
       dqs_drift_h_cnt <= dqs_drift_h_cnt + 8'd1;
    end
    else dqs_drift_h_cnt <= 8'd0;
 end
end

always @(posedge rclk or negedge rst_n)
begin
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
end

always @(dqs_drift_l_last or dqs_drift_l_now)
begin
    case (dqs_drift_l_last)
        2'b00:begin
            if (dqs_drift_l_now == 2'b01) begin
               ddrphy_update_comp_val_l_d = 2'b1;
               ddrphy_update_comp_dir_l_d = 1'b1; 
            end
            else if (dqs_drift_l_now == 2'b10) begin
               ddrphy_update_comp_val_l_d = 2'b1;
               ddrphy_update_comp_dir_l_d = 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_l_d = 2'b0;
               ddrphy_update_comp_dir_l_d = 1'b0;  
            end
        end
        2'b01:begin
             if (dqs_drift_l_now == 2'b11) begin
               ddrphy_update_comp_val_l_d = 2'b1;
               ddrphy_update_comp_dir_l_d = 1'b1; 
            end
            else if (dqs_drift_l_now == 2'b00) begin
               ddrphy_update_comp_val_l_d = 2'b1;
               ddrphy_update_comp_dir_l_d = 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_l_d = 2'b0;
               ddrphy_update_comp_dir_l_d = 1'b0;  
            end
        end
        2'b10:begin
             if (dqs_drift_l_now == 2'b00) begin
               ddrphy_update_comp_val_l_d = 2'b1;
               ddrphy_update_comp_dir_l_d = 1'b1; 
            end
            else if (dqs_drift_l_now == 2'b11) begin
               ddrphy_update_comp_val_l_d = 2'b1;
               ddrphy_update_comp_dir_l_d = 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_l_d = 2'b0;
               ddrphy_update_comp_dir_l_d = 1'b0;  
            end            
        end
        2'b11:begin
             if (dqs_drift_l_now == 2'b10) begin
               ddrphy_update_comp_val_l_d = 2'b1;
               ddrphy_update_comp_dir_l_d = 1'b1; 
            end
            else if (dqs_drift_l_now == 2'b01) begin
               ddrphy_update_comp_val_l_d = 2'b1;
               ddrphy_update_comp_dir_l_d = 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_l_d = 2'b0;
               ddrphy_update_comp_dir_l_d = 1'b0;  
            end            
        end
        default: begin
               ddrphy_update_comp_val_l_d = 2'b0;
               ddrphy_update_comp_dir_l_d = 1'b0;             
        end
    endcase        
end


always @(dqs_drift_h_last or dqs_drift_h_now)
begin
    case (dqs_drift_h_last)
        2'b00:begin
            if (dqs_drift_h_now == 2'b01) begin
               ddrphy_update_comp_val_h_d = 2'b1;
               ddrphy_update_comp_dir_h_d = 1'b1; 
            end
            else if (dqs_drift_h_now == 2'b10) begin
               ddrphy_update_comp_val_h_d = 2'b1;
               ddrphy_update_comp_dir_h_d = 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_h_d = 2'b0;
               ddrphy_update_comp_dir_h_d = 1'b0;  
            end
        end
        2'b01:begin
             if (dqs_drift_h_now == 2'b11) begin
               ddrphy_update_comp_val_h_d = 2'b1;
               ddrphy_update_comp_dir_h_d = 1'b1; 
            end
            else if (dqs_drift_h_now == 2'b00) begin
               ddrphy_update_comp_val_h_d = 2'b1;
               ddrphy_update_comp_dir_h_d = 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_h_d = 2'b0;
               ddrphy_update_comp_dir_h_d = 1'b0;  
            end
        end
        2'b10:begin
             if (dqs_drift_h_now == 2'b00) begin
               ddrphy_update_comp_val_h_d = 2'b1;
               ddrphy_update_comp_dir_h_d = 1'b1; 
            end
            else if (dqs_drift_h_now == 2'b11) begin
               ddrphy_update_comp_val_h_d = 2'b1;
               ddrphy_update_comp_dir_h_d = 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_h_d = 2'b0;
               ddrphy_update_comp_dir_h_d = 1'b0;  
            end            
        end
        2'b11:begin
             if (dqs_drift_h_now == 2'b10) begin
               ddrphy_update_comp_val_h_d = 2'b1;
               ddrphy_update_comp_dir_h_d = 1'b1; 
            end
            else if (dqs_drift_h_now == 2'b01) begin
               ddrphy_update_comp_val_h_d = 2'b1;
               ddrphy_update_comp_dir_h_d = 1'b0;                 
            end
            else begin
               ddrphy_update_comp_val_h_d = 2'b0;
               ddrphy_update_comp_dir_h_d = 1'b0;  
            end            
        end
        default: begin
               ddrphy_update_comp_val_h_d = 2'b0;
               ddrphy_update_comp_dir_h_d = 1'b0;             
        end
    endcase        
end

//phy-initiated update interface
always @(posedge rclk or negedge rst_n)
begin
   if (!rst_n) begin
      state   <= IDLE;
   end
   else begin
      case (state)
         IDLE: begin
            if(ddr_init_done) begin
                if (dll_req | manual_update | dqs_drift_req)
                state <= UPDATE;
            end
         end
         UPDATE: begin
            if(ddrphy_update_done)
               state <= IDLE;
         end
         default: begin
            state <= IDLE;
        end
      endcase
   end
end

always @(posedge rclk or negedge rst_n)
begin
   if (!rst_n) begin
      ddrphy_update_type <= 2'b10;
      dqs_drift_l_last <= 2'b0;
      dqs_drift_h_last <= 2'b0;
      ddrphy_update_comp_val_l <= 2'b0;
      ddrphy_update_comp_dir_l <= 1'b0; 
      ddrphy_update_comp_val_h <= 2'b0;
      ddrphy_update_comp_dir_h <= 1'b0;
   end
   else if(state == IDLE) begin
            if(ddr_init_done) begin
            if(dqs_drift_req) begin
               ddrphy_update_comp_val_l <= ddrphy_update_comp_val_l_d;
               ddrphy_update_comp_dir_l <= ddrphy_update_comp_dir_l_d; 
               ddrphy_update_comp_val_h <= ddrphy_update_comp_val_h_d;
               ddrphy_update_comp_dir_h <= ddrphy_update_comp_dir_h_d;
               dqs_drift_l_last <= dqs_drift_l_now;
               dqs_drift_h_last <= dqs_drift_h_now; 
               ddrphy_update_type <= 2'b01;
            end
            else if(dll_req)
            ddrphy_update_type <= 2'b00;
            else if(manual_update)
            ddrphy_update_type <= 2'b00;
            else 
            ddrphy_update_type <= 2'b10;
            end
            else begin
                 dqs_drift_l_last <= dqs_drift_l_now;
                 dqs_drift_h_last <= dqs_drift_h_now;
            end            
   end
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