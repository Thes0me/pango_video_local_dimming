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

module ipsl_hmic_h_ddrc_apb_reset_v1_1 #(
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
   input               presetn,
   input               pclk,
   output   [31:0]     pwdata,
   output              pwrite,
   output  reg         penable,
   output  reg         psel,
   output   [11:0]     paddr,
   input    [31:0]     prdata,
   input               pready,
   input               ddrc_init_start,
   output  reg         ddrc_init_done
   );

localparam [7:0] ADDRMAP_BANK_B0 = (ADDRESS_MAPPING_SEL == 0) ? (MEM_COLUMN_ADDRESS - 8'd2) : (MEM_COLUMN_ADDRESS + MEM_ROW_ADDRESS - 8'd2);
localparam [7:0] ADDRMAP_BANK_B1 =  ADDRMAP_BANK_B0;
localparam [7:0] ADDRMAP_BANK_B2 =  (MEM_BANK_ADDRESS == 8'd3) ? ADDRMAP_BANK_B0 : 8'h1f;                                 
localparam [7:0] ADDRMAP_COL_B2 = 8'h0;
localparam [7:0] ADDRMAP_COL_B3 = 8'h0;
localparam [7:0] ADDRMAP_COL_B4 = 8'h0;
localparam [7:0] ADDRMAP_COL_B5 = 8'h0;
localparam [7:0] ADDRMAP_COL_B6 = 8'h0;
localparam [7:0] ADDRMAP_COL_B7 = 8'h0;
localparam [7:0] ADDRMAP_COL_B8 = (MEM_COLUMN_ADDRESS > 8'd8) ? 8'h0 : 8'h1f;
localparam [7:0] ADDRMAP_COL_B9 = (MEM_COLUMN_ADDRESS > 8'd9) ? 8'h0 : 8'h1f;
localparam [7:0] ADDRMAP_COL_B10 = (MEM_COLUMN_ADDRESS > 8'd10) ? 8'h0 : 8'h1f;
localparam [7:0] ADDRMAP_COL_B11 = (MEM_COLUMN_ADDRESS > 8'd11) ? 8'h0 : 8'h1f;
localparam [7:0] ADDRMAP_ROW_B0 = (ADDRESS_MAPPING_SEL == 0) ? (MEM_COLUMN_ADDRESS + MEM_BANK_ADDRESS - 8'd6) : (MEM_COLUMN_ADDRESS - 8'd6);
localparam [7:0] ADDRMAP_ROW_B1 = ADDRMAP_ROW_B0;
localparam [7:0] ADDRMAP_ROW_B2 = ADDRMAP_ROW_B0;
localparam [7:0] ADDRMAP_ROW_B3 = ADDRMAP_ROW_B0;
localparam [7:0] ADDRMAP_ROW_B4 = ADDRMAP_ROW_B0;
localparam [7:0] ADDRMAP_ROW_B5 = ADDRMAP_ROW_B0;
localparam [7:0] ADDRMAP_ROW_B6 = ADDRMAP_ROW_B0;
localparam [7:0] ADDRMAP_ROW_B7 = ADDRMAP_ROW_B0;
localparam [7:0] ADDRMAP_ROW_B8 = ADDRMAP_ROW_B0;
localparam [7:0] ADDRMAP_ROW_B9 = ADDRMAP_ROW_B0;
localparam [7:0] ADDRMAP_ROW_B10 = ADDRMAP_ROW_B0;
localparam [7:0] ADDRMAP_ROW_B11 = ADDRMAP_ROW_B0;
localparam [7:0] ADDRMAP_ROW_B12 = (MEM_ROW_ADDRESS > 8'd12) ? ADDRMAP_ROW_B0 : 8'h1f;
localparam [7:0] ADDRMAP_ROW_B13 = (MEM_ROW_ADDRESS > 8'd13) ? ADDRMAP_ROW_B0 : 8'h1f;
localparam [7:0] ADDRMAP_ROW_B14 = (MEM_ROW_ADDRESS > 8'd14) ? ADDRMAP_ROW_B0 : 8'h1f;
localparam [7:0] ADDRMAP_ROW_B15 = (MEM_ROW_ADDRESS > 8'd15) ? ADDRMAP_ROW_B0 : 8'h1f;

reg [43:0]      data;
reg [6:0]       cnt;
 
always @(posedge pclk or negedge presetn)
begin
    if(!presetn)
       psel<=1'b0;
    else if(ddrc_init_done)
         psel<=1'b0;
    else if(ddrc_init_start)
         psel<=1'b1;
    else
        psel<=1'b0;
end

assign pwrite=(cnt==7'h51)?1'b0:1'b1; 

always @(posedge pclk or negedge presetn)
begin
    if(!presetn)
       penable<=1'b0;
    else if(ddrc_init_done) 
       penable<=1'b0;
    else if(pready)
       penable<=1'b0;  
    else if(psel)
       penable<=1'b1;  
end

generate
if (DDR_TYPE == "DDR3") begin
always @(cnt or presetn)
        if(!presetn)
            data = 44'h0;
         else 
             begin
               case(cnt)
                 7'h0 :data = {12'h0,16'h4,2'b00,DATA_BUS_WIDTH,12'h201};
                 7'h1 :data = {12'h10,32'h10};
                 7'h2 :data = {12'h14,32'h3aed};
                 7'h3 :data = {12'h30,32'h4};
                 7'h4 :data = {12'h34,32'h5_0000};
                 7'h5 :data = {12'h38,32'h2};
                 7'h6 :data = {12'h50,32'hf0_e030};
                 7'h7 :data = {12'h60,32'h0};
                 7'h8 :data = {12'h64,4'h0,TREFI,6'h0,TRFC_MIN};
                 7'h9 :data = {12'hc0,32'h0};
                 7'ha :data = {12'hd0,32'h4007_0002};
                 7'hb :data = {12'hd4,32'h4_0006};
                 7'hc :data = {12'hdc,MR,EMR};
                 7'hd :data = {12'he0,EMR2,EMR3};
                 7'he :data = {12'he4,32'h9_0000};
                 7'hf :data = {12'hf0,32'h0};
                 7'h10 :data = {12'h100,1'b0,WR2PRE,2'h0,T_FAW,1'b0,T_RAS_MAX,2'b00,T_RAS_MIN};
                 7'h11 :data = {12'h104,11'h0,T_XP,2'b00,RD2PRE,1'b0,T_RC};
                 7'h12 :data = {12'h108,2'b00,WL,2'b00,RL,2'b00,RD2WR,2'b00,WR2RD};
                 7'h13 :data = {12'h10c,14'h0,T_MRD,2'b0,T_MOD};
                 7'h14 :data = {12'h110,3'b000,T_RCD,4'h0,T_CCD,4'h0,T_RRD,3'h0,T_RP};
                 7'h15 :data = {12'h114,4'h0,T_CKSRX,4'h0,T_CKSRE,2'h0,T_CKESR,3'h0,T_CKE};
                 7'h16 :data = {12'h118,32'hb0b_0007};
                 7'h17 :data = {12'h11c,32'h604};
                 7'h18 :data = {12'h120,32'h4703};
                 7'h19 :data = {12'h138,32'h0};
                 7'h1a :data = {12'h13c,32'h0};
                 7'h1b :data = {12'h180,32'h80_0020};
                 7'h1c :data = {12'h184,32'h70};
                 7'h1d :data = {12'h190,9'b010000000,DFI_T_RDDATA_EN,1'b1,9'h0,DFI_TPHY_WRLAT};
                 7'h1e :data = {12'h194,32'h5_0505};
                 7'h1f :data = {12'h198,32'h790_3020};
                 7'h20 :data = {12'h1a0,32'hc3ff_0005};
                 7'h21 :data = {12'h1a4,32'h1a_0037};
                 7'h22 :data = {12'h1a8,32'h8000_0000};
                 7'h23 :data = {12'h1b0,32'h1};
                 7'h24 :data = {12'h1c4,32'h0};
                 7'h25 :data = {12'h204,8'h0,ADDRMAP_BANK_B2,ADDRMAP_BANK_B1,ADDRMAP_BANK_B0};
                 7'h26 :data = {12'h208,ADDRMAP_COL_B5,ADDRMAP_COL_B4,ADDRMAP_COL_B3,ADDRMAP_COL_B2};
                 7'h27 :data = {12'h20c,ADDRMAP_COL_B9,ADDRMAP_COL_B8,ADDRMAP_COL_B7,ADDRMAP_COL_B6};
                 7'h28 :data = {12'h210,16'h0,ADDRMAP_COL_B11,ADDRMAP_COL_B10};
                 7'h29 :data = {12'h214,ADDRMAP_ROW_B11,8'hf,ADDRMAP_ROW_B1,ADDRMAP_ROW_B0};
                 7'h2a :data = {12'h218,ADDRMAP_ROW_B15,ADDRMAP_ROW_B14,ADDRMAP_ROW_B13,ADDRMAP_ROW_B12};
                 7'h2b :data = {12'h21c,32'h0f0f};
                 7'h2c :data = {12'h224,ADDRMAP_ROW_B5,ADDRMAP_ROW_B4,ADDRMAP_ROW_B3,ADDRMAP_ROW_B2};
                 7'h2d :data = {12'h228,ADDRMAP_ROW_B9,ADDRMAP_ROW_B8,ADDRMAP_ROW_B7,ADDRMAP_ROW_B6};
                 7'h2e :data = {12'h22c,24'h0,ADDRMAP_ROW_B10};
                 7'h2f :data = {12'h240,32'h600_0500};
                 7'h30 :data = {12'h244,32'h1};
                 7'h31 :data = {12'h250,32'h3921_0b05};
                 7'h32 :data = {12'h254,32'h30};
                 7'h33 :data = {12'h25c,32'hbe00_4133};
                 7'h34 :data = {12'h264,32'hc900_6465};
                 7'h35 :data = {12'h26c,32'h2000_193f};
                 7'h36 :data = {12'h300,32'h1};
                 7'h37 :data = {12'h304,32'h0};
                 7'h38 :data = {12'h30c,32'h0};
                 7'h39 :data = {12'h320,32'h1};
                 7'h3a :data = {12'h36c,32'h0};
                 7'h3b :data = {12'h400,32'h1};
                 7'h3c :data = {12'h404,32'h4062};
                 7'h3d :data = {12'h408,32'h332f};
                 7'h3e :data = {12'h490,32'h1};
                 7'h3f :data = {12'h494,32'h5};
                 7'h40 :data = {12'h498,32'ha9_053a};
                 7'h41 :data = {12'h49c,32'h11_0003};
                 7'h42 :data = {12'h4a0,32'h678};
                 7'h43 :data = {12'h4b4,32'h51ad};
                 7'h44 :data = {12'h4b8,32'h281};
                 7'h45 :data = {12'h540,32'h1};
                 7'h46 :data = {12'h544,32'h21_0007};
                 7'h47 :data = {12'h548,32'h305_003c};
                 7'h48 :data = {12'h54c,32'h10_0001};
                 7'h49 :data = {12'h550,32'h18f};
                 7'h4a :data = {12'h564,32'h60b3};
                 7'h4b :data = {12'h568,32'h162};
                 7'h4c :data = {12'h5f0,32'h1};
                 7'h4d :data = {12'h5f4,32'h1_0003};
                 7'h4e :data = {12'h5f8,32'h21_0117};
                 7'h4f :data = {12'h5fc,32'h10_0002};
                 7'h50 :data = {12'h600,32'h46c};
                 default: data = {12'h0,32'h4_0201};
               endcase
             end
end 
else if(DDR_TYPE == "DDR2") begin
always @(cnt or presetn)
        if(!presetn)
            data = 44'h0;
         else 
             begin
               case(cnt)
                 7'h0 :data = {12'h0,16'h4,2'b00,DATA_BUS_WIDTH,12'h000};
                 7'h1 :data = {12'h10,32'h7010};
                 7'h2 :data = {12'h14,32'hb640};
                 7'h3 :data = {12'h30,32'h4};
                 7'h4 :data = {12'h34,32'h24_0001};
                 7'h5 :data = {12'h38,32'h2};
                 7'h6 :data = {12'h50,32'hf0_e030};
                 7'h7 :data = {12'h60,32'h0};
                 7'h8 :data = {12'h64,4'h0,TREFI,6'h0,TRFC_MIN};
                 7'h9 :data = {12'hc0,32'h0};
                 7'ha :data = {12'hd0,32'h4002_0001};
                 7'hb :data = {12'hd4,32'h4_0006};
                 7'hc :data = {12'hdc,MR,EMR};
                 7'hd :data = {12'he0,EMR2,EMR3};
                 7'he :data = {12'he4,32'h9_0000};
                 7'hf :data = {12'hf0,32'h0};
                 7'h10 :data = {12'h100,1'b0,WR2PRE,2'h0,T_FAW,1'b0,T_RAS_MAX,2'b00,T_RAS_MIN};
                 7'h11 :data = {12'h104,11'h0,T_XP,2'b00,RD2PRE,1'b0,T_RC};
                 7'h12 :data = {12'h108,2'b00,WL,2'b00,RL,2'b00,RD2WR,2'b00,WR2RD};
                 7'h13 :data = {12'h10c,14'h0,T_MRD,2'b0,T_MOD};
                 7'h14 :data = {12'h110,3'b000,T_RCD,4'h0,T_CCD,4'h0,T_RRD,3'h0,T_RP};
                 7'h15 :data = {12'h114,4'h0,T_CKSRX,4'h0,T_CKSRE,2'h0,T_CKESR,3'h0,T_CKE};
                 7'h16 :data = {12'h118,32'hb0b_0007};
                 7'h17 :data = {12'h11c,32'h604};
                 7'h18 :data = {12'h120,32'h4703};
                 7'h19 :data = {12'h138,32'h596};
                 7'h1a :data = {12'h13c,32'h0};
                 7'h1b :data = {12'h180,32'h80_0020};
                 7'h1c :data = {12'h184,32'h70};
                 7'h1d :data = {12'h190,9'b010000000,DFI_T_RDDATA_EN,1'b1,9'h0,DFI_TPHY_WRLAT};
                 7'h1e :data = {12'h194,32'h5_0505};
                 7'h1f :data = {12'h198,32'h790_3020};
                 7'h20 :data = {12'h1a0,32'hc3ff_0005};
                 7'h21 :data = {12'h1a4,32'h1a_0037};
                 7'h22 :data = {12'h1a8,32'h8000_0000};
                 7'h23 :data = {12'h1b0,32'h1};
                 7'h24 :data = {12'h1c4,32'h0};
                 7'h25 :data = {12'h204,8'h0,ADDRMAP_BANK_B2,ADDRMAP_BANK_B1,ADDRMAP_BANK_B0};
                 7'h26 :data = {12'h208,ADDRMAP_COL_B5,ADDRMAP_COL_B4,ADDRMAP_COL_B3,ADDRMAP_COL_B2};
                 7'h27 :data = {12'h20c,ADDRMAP_COL_B9,ADDRMAP_COL_B8,ADDRMAP_COL_B7,ADDRMAP_COL_B6};
                 7'h28 :data = {12'h210,16'h0,ADDRMAP_COL_B11,ADDRMAP_COL_B10};
                 7'h29 :data = {12'h214,ADDRMAP_ROW_B11,8'hf,ADDRMAP_ROW_B1,ADDRMAP_ROW_B0};
                 7'h2a :data = {12'h218,ADDRMAP_ROW_B15,ADDRMAP_ROW_B14,ADDRMAP_ROW_B13,ADDRMAP_ROW_B12};
                 7'h2b :data = {12'h21c,32'h0f0f};
                 7'h2c :data = {12'h224,ADDRMAP_ROW_B5,ADDRMAP_ROW_B4,ADDRMAP_ROW_B3,ADDRMAP_ROW_B2};
                 7'h2d :data = {12'h228,ADDRMAP_ROW_B9,ADDRMAP_ROW_B8,ADDRMAP_ROW_B7,ADDRMAP_ROW_B6};
                 7'h2e :data = {12'h22c,24'h0,ADDRMAP_ROW_B10};
                 7'h2f :data = {12'h240,32'ha00_0600};
                 7'h30 :data = {12'h244,32'h1};
                 7'h31 :data = {12'h250,32'h3921_0805};
                 7'h32 :data = {12'h254,32'h30};
                 7'h33 :data = {12'h25c,32'hbe00_4133};
                 7'h34 :data = {12'h264,32'hc900_6465};
                 7'h35 :data = {12'h26c,32'h2000_193f};
                 7'h36 :data = {12'h300,32'h1};
                 7'h37 :data = {12'h304,32'h0};
                 7'h38 :data = {12'h30c,32'h0};
                 7'h39 :data = {12'h320,32'h1};
                 7'h3a :data = {12'h36c,32'h0001_0001};
                 7'h3b :data = {12'h400,32'h1};
                 7'h3c :data = {12'h404,32'h31b3};
                 7'h3d :data = {12'h408,32'h3050}; 
                 7'h3e :data = {12'h490,32'h1};
                 7'h3f :data = {12'h494,32'h0002_0007};
                 7'h40 :data = {12'h498,32'h0000_0064};
                 7'h41 :data = {12'h49c,32'h0010_0007};
                 7'h42 :data = {12'h4a0,32'h0000_0000};
                 7'h43 :data = {12'h4b4,32'h30ad};
                 7'h44 :data = {12'h4b8,32'h3050};
                 7'h45 :data = {12'h540,32'h1};
                 7'h46 :data = {12'h544,32'h0002_0007};
                 7'h47 :data = {12'h548,32'h0000_0064};
                 7'h48 :data = {12'h54c,32'h0010_0007};
                 7'h49 :data = {12'h550,32'h0000_0064};
                 7'h4a :data = {12'h564,32'h3062};
                 7'h4b :data = {12'h568,32'h3050};
                 7'h4c :data = {12'h5f0,32'h1};
                 7'h4d :data = {12'h5f4,32'h0002_0007};
                 7'h4e :data = {12'h5f8,32'h0000_0064};
                 7'h4f :data = {12'h5fc,32'h0010_0007};
                 7'h50 :data = {12'h600,32'h0000_0064};
                 default: data = {12'h0,32'h4_0201};
               endcase
             end    
end
else if(DDR_TYPE == "LPDDR") begin  
always @(cnt or presetn)
        if(!presetn)
            data = 44'h0;
         else 
             begin
               case(cnt)
                 7'h0 :data = {12'h0,16'h4,2'b00,DATA_BUS_WIDTH,10'h0,2'b10};
                 7'h1 :data = {12'h10,32'hb010};
                 7'h2 :data = {12'h14,32'h90f9};
                 7'h3 :data = {12'h30,32'ha};
                 7'h4 :data = {12'h34,32'h7_0003};
                 7'h5 :data = {12'h38,32'h4f_0002};
                 7'h6 :data = {12'h50,32'hf0_3040};
                 7'h7 :data = {12'h60,32'h0};
                 7'h8 :data = {12'h64,4'h0,TREFI,6'h0,TRFC_MIN};
                 7'h9 :data = {12'hc0,32'h0};
                 7'ha :data = {12'hd0,32'h4003_0001};
                 7'hb :data = {12'hd4,32'h1_0009};
                 7'hc :data = {12'hdc,MR,EMR};
                 7'hd :data = {12'he0,EMR2,EMR3};
                 7'he :data = {12'he4,32'h1_0000};
                 7'hf :data = {12'hf0,32'h0};
                 7'h10 :data = {12'h100,1'b0,WR2PRE,2'h0,T_FAW,1'b0,T_RAS_MAX,2'b00,T_RAS_MIN};
                 7'h11 :data = {12'h104,11'h0,T_XP,2'b00,RD2PRE,1'b0,T_RC};
                 7'h12 :data = {12'h108,2'b00,WL,2'b00,RL,2'b00,RD2WR,2'b00,WR2RD};
                 7'h13 :data = {12'h10c,14'h0,T_MRD,2'b0,T_MOD};
                 7'h14 :data = {12'h110,3'b000,T_RCD,4'h0,T_CCD,4'h0,T_RRD,3'h0,T_RP};
                 7'h15 :data = {12'h114,4'h0,T_CKSRX,4'h0,T_CKSRE,2'h0,T_CKESR,3'h0,T_CKE};
                 7'h16 :data = {12'h118,32'hb04_0001};
                 7'h17 :data = {12'h11c,32'hf01};
                 7'h18 :data = {12'h120,32'h101};
                 7'h19 :data = {12'h138,32'h14};
                 7'h1a :data = {12'h13c,32'h0};
                 7'h1b :data = {12'h180,32'h0};
                 7'h1c :data = {12'h184,32'h70};
                 7'h1d :data = {12'h190,9'b010000000,DFI_T_RDDATA_EN,1'b1,9'h0,DFI_TPHY_WRLAT};
                 7'h1e :data = {12'h194,32'h7_0505};
                 7'h1f :data = {12'h198,32'h750_9000};
                 7'h20 :data = {12'h1a0,32'he3ff_0005};
                 7'h21 :data = {12'h1a4,32'h6c_0079};
                 7'h22 :data = {12'h1a8,32'h8000_0000};
                 7'h23 :data = {12'h1b0,32'h1};
                 7'h24 :data = {12'h1c4,32'h0};
                 7'h25 :data = {12'h204,8'h0,ADDRMAP_BANK_B2,ADDRMAP_BANK_B1,ADDRMAP_BANK_B0};
                 7'h26 :data = {12'h208,ADDRMAP_COL_B5,ADDRMAP_COL_B4,ADDRMAP_COL_B3,ADDRMAP_COL_B2};
                 7'h27 :data = {12'h20c,ADDRMAP_COL_B9,ADDRMAP_COL_B8,ADDRMAP_COL_B7,ADDRMAP_COL_B6};
                 7'h28 :data = {12'h210,16'h0,ADDRMAP_COL_B11,ADDRMAP_COL_B10};
                 7'h29 :data = {12'h214,ADDRMAP_ROW_B11,8'hf,ADDRMAP_ROW_B1,ADDRMAP_ROW_B0};
                 7'h2a :data = {12'h218,ADDRMAP_ROW_B15,ADDRMAP_ROW_B14,ADDRMAP_ROW_B13,ADDRMAP_ROW_B12};
                 7'h2b :data = {12'h21c,32'h0f0f};
                 7'h2c :data = {12'h224,ADDRMAP_ROW_B5,ADDRMAP_ROW_B4,ADDRMAP_ROW_B3,ADDRMAP_ROW_B2};
                 7'h2d :data = {12'h228,ADDRMAP_ROW_B9,ADDRMAP_ROW_B8,ADDRMAP_ROW_B7,ADDRMAP_ROW_B6};
                 7'h2e :data = {12'h22c,24'h0,ADDRMAP_ROW_B10};
                 7'h2f :data = {12'h240,32'h813_035c};
                 7'h30 :data = {12'h244,32'h1};
                 7'h31 :data = {12'h250,32'h20b3_0b05};
                 7'h32 :data = {12'h254,32'h6};
                 7'h33 :data = {12'h25c,32'hcd00_90e2};
                 7'h34 :data = {12'h264,32'hb600_79ca};
                 7'h35 :data = {12'h26c,32'h5208};
                 7'h36 :data = {12'h300,32'h1};
                 7'h37 :data = {12'h304,32'h0};
                 7'h38 :data = {12'h30c,32'h0};
                 7'h39 :data = {12'h320,32'h1};
                 7'h3a :data = {12'h36c,32'h11_0000};
                 7'h3b :data = {12'h400,32'h1};
                 7'h3c :data = {12'h404,32'h31b3};
                 7'h3d :data = {12'h408,32'h3050}; 
                 7'h3e :data = {12'h490,32'h1};
                 7'h3f :data = {12'h494,32'h0002_0007};
                 7'h40 :data = {12'h498,32'h0000_0064};
                 7'h41 :data = {12'h49c,32'h0010_0007};
                 7'h42 :data = {12'h4a0,32'h0000_0000};
                 7'h43 :data = {12'h4b4,32'h30ad};
                 7'h44 :data = {12'h4b8,32'h3050};
                 7'h45 :data = {12'h540,32'h1};
                 7'h46 :data = {12'h544,32'h0002_0007};
                 7'h47 :data = {12'h548,32'h0000_0064};
                 7'h48 :data = {12'h54c,32'h0010_0007};
                 7'h49 :data = {12'h550,32'h0000_0064};
                 7'h4a :data = {12'h564,32'h3062};
                 7'h4b :data = {12'h568,32'h3050};
                 7'h4c :data = {12'h5f0,32'h1};
                 7'h4d :data = {12'h5f4,32'h0002_0007};
                 7'h4e :data = {12'h5f8,32'h0000_0064};
                 7'h4f :data = {12'h5fc,32'h0010_0007};
                 7'h50 :data = {12'h600,32'h0000_0064};
                 default: data = {12'h0,32'h4_0201};
               endcase
             end
end
endgenerate                          
             
always @(posedge pclk or negedge presetn)
begin
    if(!presetn)
       cnt<=7'h0;
    else if(ddrc_init_start)
       begin
          if((cnt<=7'h50)&pready)
            cnt<=cnt+7'h1;
       end
    else
      cnt<=7'h0; 
end

assign pwdata=psel?(pwrite?data[31:0]:32'h0):32'h0;
assign paddr=psel?(pwrite?data[43:32]:12'h4):12'h0;

always @(posedge pclk or negedge presetn)
begin
    if(!presetn)
      ddrc_init_done<=1'b0;
    else if(prdata[1:0]==2'b01)
      ddrc_init_done<=1'b1; 
end

endmodule
