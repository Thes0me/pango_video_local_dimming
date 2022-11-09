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

module ipsl_hmic_h_ddrc_reset_ctrl_v1_1 #
(
    parameter     [9:0]            TRFC_MIN                  = 10'h8c,  
    parameter     [11:0]           TREFI                     = 12'h62,  
    parameter     [5:0]            T_MRD                     = 6'h0,    
    parameter     [9:0]            T_MOD                     = 10'h0,   
    parameter                      DDR_TYPE                  = "DDR3",  
    parameter     [15:0]           MR                        = 16'h1108,
    parameter     [15:0]           EMR                       = 16'h0001,
    parameter     [15:0]           EMR2                      = 16'h0000,
    parameter     [15:0]           EMR3                      = 16'h0000,
    parameter     [6:0]            WR2PRE                    = 7'hf,
    parameter     [5:0]            T_FAW                     = 6'h10,
    parameter     [6:0]            T_RAS_MAX                 = 7'h1b,
    parameter     [5:0]            T_RAS_MIN                 = 6'hf,
    parameter     [4:0]            T_XP                      = 5'h8,
    parameter     [5:0]            RD2PRE                    = 6'h4,
    parameter     [6:0]            T_RC                      = 7'h14,
    parameter     [5:0]            WL                        = 6'h3,
    parameter     [5:0]            RL                        = 6'h5,
    parameter     [5:0]            RD2WR                     = 6'h6,
    parameter     [5:0]            WR2RD                     = 6'hd,
    parameter     [4:0]            T_RCD                     = 5'h5,
    parameter     [3:0]            T_CCD                     = 4'h4,
    parameter     [3:0]            T_RRD                     = 4'h4,
    parameter     [4:0]            T_RP                      = 5'h5,
    parameter     [3:0]            T_CKSRX                   = 4'h5,
    parameter     [3:0]            T_CKSRE                   = 4'h5,
    parameter     [5:0]            T_CKESR                   = 6'h4,
    parameter     [4:0]            T_CKE                     = 5'h3,
    parameter     [6:0]            DFI_T_RDDATA_EN           = 7'h2,
    parameter     [5:0]            DFI_TPHY_WRLAT            = 6'h2,
    parameter     [1:0]            DATA_BUS_WIDTH            = 2'b00,
    parameter                      ADDRESS_MAPPING_SEL       = 0,
    parameter     [7:0]            MEM_ROW_ADDRESS           = 8'd14,
    parameter     [7:0]            MEM_COLUMN_ADDRESS        = 8'd10,
    parameter     [7:0]            MEM_BANK_ADDRESS          = 8'd3
)
(
  input              pclk   ,
  input              resetn ,
  input              user_preset ,
  input [31:0]       user_pwdata ,
  input              user_pwrite ,
  input              user_penable,
  input              user_psel   ,
  input [11:0]       user_paddr  ,
  input              user_ddrc_rst,
  input              user_axi_reset0,
  input              user_axi_reset1,
  input              user_axi_reset2,
  
  output   reg        ddr_init_done,
  output   wire       ddrc_rst,
  output   wire       ddrc_axi_reset0,
  output   wire       ddrc_axi_reset1,
  output   wire       ddrc_axi_reset2,
  output   wire       ddrc_preset ,
  output   [31:0]     ddrc_pwdata,
  output              ddrc_pwrite,
  output   wire       ddrc_penable,
  output   wire       ddrc_psel,
  output   [11:0]     ddrc_paddr,
  input    [31:0]     ddrc_prdata,
  input               ddrc_pready
);

reg [7:0 ] rst_cnt;
reg [7:0 ] ddrc_rst_cnt;
reg init_ddrc_rst;
reg init_axi_reset0;
reg init_axi_reset1;
reg init_axi_reset2;
reg init_preset;
reg ddrc_init_start;
reg presetn;
wire [31:0] init_pwdata   ;
wire        init_pwrite   ;
wire        init_penable  ;
wire        init_psel     ;
wire [11:0] init_paddr    ;
wire ddrc_init_done ;

always @(posedge pclk or negedge resetn)
begin
    if(!resetn)
   rst_cnt <= 8'd0;  
   else if(rst_cnt < 8'd30)
    rst_cnt <= rst_cnt + 8'd1;
   else
    rst_cnt <= rst_cnt;
end

always @(posedge pclk or negedge resetn)
begin
 if(!resetn) begin
   init_preset <= 1; 
   presetn <= 0; 
end 
else if(rst_cnt == 8'd15) begin
   init_preset <= 0;
   presetn <= 0; 
end 
else if(rst_cnt == 8'd30) begin
   init_preset <= 0;
   presetn <= 1;     
end
end


always @(posedge pclk or negedge resetn)
begin
    if(!resetn)
    ddrc_rst_cnt <= 8'd0;
    else if(init_pwrite == 1'b1)
    ddrc_rst_cnt <= 8'd0;
    else if(ddrc_rst_cnt < 8'd30)
    ddrc_rst_cnt <= ddrc_rst_cnt + 8'd1;
    else 
    ddrc_rst_cnt <= ddrc_rst_cnt;
end

always @(posedge pclk or negedge resetn)
begin
    if(!resetn) begin
    init_ddrc_rst <= 1;
    init_axi_reset0 <= 1;
    init_axi_reset1 <= 1;
    init_axi_reset2 <= 1;
end
    else if(ddrc_rst_cnt == 8'd30) begin
    init_ddrc_rst <= 0;
    init_axi_reset0 <= 0;
    init_axi_reset1 <= 0;
    init_axi_reset2 <= 0;
end
end

always @(posedge pclk or negedge resetn)
begin
    if(!resetn) begin
    ddrc_init_start <= 1;
    ddr_init_done <= 0;
    end
    else if (ddrc_init_done) begin
    ddrc_init_start <= 0;
    ddr_init_done <= 1;
end
end
 assign   ddrc_rst     =   (ddrc_init_start==1) ? init_ddrc_rst   :  user_ddrc_rst    ;   
 assign   ddrc_axi_reset0   =   (ddrc_init_start==1) ? init_axi_reset0 :  user_axi_reset0  ;   
 assign   ddrc_axi_reset1   =   (ddrc_init_start==1) ? init_axi_reset1 :  user_axi_reset1  ;   
 assign   ddrc_axi_reset2   =   (ddrc_init_start==1) ? init_axi_reset2 :  user_axi_reset2  ;   
 assign   ddrc_preset       =   (ddrc_init_start==1) ? init_preset     :  user_preset      ;   
 assign   ddrc_pwdata       =   (ddrc_init_start==1) ? init_pwdata   : user_pwdata      ;
 assign   ddrc_pwrite       =   (ddrc_init_start==1) ? init_pwrite   : user_pwrite      ;
 assign   ddrc_penable      =   (ddrc_init_start==1) ? init_penable  : user_penable     ;
 assign   ddrc_psel         =   (ddrc_init_start==1) ? init_psel     : user_psel        ;
 assign   ddrc_paddr        =   (ddrc_init_start==1) ? init_paddr    : user_paddr       ;

ipsl_hmic_h_ddrc_apb_reset_v1_1 #
(
 .TRFC_MIN            (TRFC_MIN       ),
 .TREFI               (TREFI          ),
 .T_MRD               (T_MRD          ),
 .T_MOD               (T_MOD          ),
 .DDR_TYPE            (DDR_TYPE       ),
 .MR                  (MR             ),
 .EMR                 (EMR            ),
 .EMR2                (EMR2           ),
 .EMR3                (EMR3           ),
 .WR2PRE              (WR2PRE         ),
 .T_FAW               (T_FAW          ),
 .T_RAS_MAX           (T_RAS_MAX      ),
 .T_RAS_MIN           (T_RAS_MIN      ),
 .T_XP                (T_XP           ),
 .RD2PRE              (RD2PRE         ),
 .T_RC                (T_RC           ),
 .WL                  (WL             ),
 .RL                  (RL             ),
 .RD2WR               (RD2WR          ),
 .WR2RD               (WR2RD          ),
 .T_RCD               (T_RCD          ),
 .T_CCD               (T_CCD          ),
 .T_RRD               (T_RRD          ),
 .T_RP                (T_RP           ),
 .T_CKSRX             (T_CKSRX        ),
 .T_CKSRE             (T_CKSRE        ),
 .T_CKESR             (T_CKESR        ),
 .T_CKE               (T_CKE          ),
 .DFI_T_RDDATA_EN     (DFI_T_RDDATA_EN),
 .DFI_TPHY_WRLAT      (DFI_TPHY_WRLAT ),
 .DATA_BUS_WIDTH      (DATA_BUS_WIDTH ),
 .ADDRESS_MAPPING_SEL (ADDRESS_MAPPING_SEL),
 .MEM_ROW_ADDRESS     (MEM_ROW_ADDRESS    ),
 .MEM_COLUMN_ADDRESS  (MEM_COLUMN_ADDRESS ),
 .MEM_BANK_ADDRESS    (MEM_BANK_ADDRESS   )
)u_ddrc_apb_reset_v1_1(
    .presetn               (presetn ),   
    .pclk                  (pclk    ),
    .pwdata                (init_pwdata  ),
    .pwrite                (init_pwrite  ),
    .penable               (init_penable  ),
    .psel                  (init_psel    ),
    .paddr                 (init_paddr   ),
    .prdata                (ddrc_prdata  ),
    .pready                (ddrc_pready  ),
    .ddrc_init_start       (ddrc_init_start),
    .ddrc_init_done        (ddrc_init_done)
  );
  
endmodule