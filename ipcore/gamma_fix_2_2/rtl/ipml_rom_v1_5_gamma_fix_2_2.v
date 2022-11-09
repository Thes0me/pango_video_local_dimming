// Created by IP Generator (Version 2021.1-SP7.3 build 94852)



//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename:ipml_rom.v
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module ipml_rom_v1_5_gamma_fix_2_2
 #(
    parameter  c_SIM_DEVICE     = "LOGOS"      ,
    parameter  c_ADDR_WIDTH     = 10           ,           //write address width  legal value:1~20 
    parameter  c_DATA_WIDTH     = 32           ,           //write data width     legal value:8~1152
    parameter  c_OUTPUT_REG     = 0            ,           //output register      legal value:1~20
    parameter  c_RD_OCE_EN      = 0            ,
    parameter  c_CLK_EN         = 0            ,
    parameter  c_ADDR_STROBE_EN = 0            ,
    parameter  c_RESET_TYPE     = "ASYNC_RESET",           //ASYNC_RESET_SYNC_RELEASE SYNC_RESET legal valve "ASYNC_RESET_SYNC_RELEASE" "SYNC_RESET" "ASYNC_RESET"
    parameter  c_POWER_OPT      = 0            ,           //0 :normal mode  1:low power mode legal value:0 or 1
    parameter  c_CLK_OR_POL_INV = 0            ,           //clk polarity invert for output register   legal value 1 or 0           
    parameter  c_INIT_FILE      = "NONE"       ,           //legal value:"NONE" or "initial file name"
    parameter  c_INIT_FORMAT    = "BIN"                   //initial data format   legal valve: "bin" or "hex"
    
 )
  (
   
    input  wire [c_ADDR_WIDTH-1 : 0]  addr        ,
    output wire [c_DATA_WIDTH-1 : 0]  rd_data     ,
    input  wire                       clk         ,
    input  wire                       clk_en      ,
    input  wire                       addr_strobe ,
    input  wire                       rst         ,
    input  wire                       rd_oce       
  );

//**********************************************************************************************************************************************   
    
//main code
//*************************************************************************************************************************************
//inner variables

ipml_spram_v1_5_gamma_fix_2_2
 #(
    .c_SIM_DEVICE     (c_SIM_DEVICE),
    .c_ADDR_WIDTH     (c_ADDR_WIDTH),           //write address width  legal value:1~20                              
    .c_DATA_WIDTH     (c_DATA_WIDTH),           //write data width     legal value:8~1152                            
    .c_OUTPUT_REG     (c_OUTPUT_REG),           //output register      legal value:1~20                              
    .c_RD_OCE_EN      (c_RD_OCE_EN),
    .c_ADDR_STROBE_EN (c_ADDR_STROBE_EN),
    .c_CLK_EN         (c_CLK_EN),
    .c_RESET_TYPE     (c_RESET_TYPE),           //legal valve "ASYNC_RESET_SYNC_RELEASE" "SYNC_RESET" "ASYNC_RESET"  
    .c_POWER_OPT      (c_POWER_OPT),            //0 :normal mode  1:low power mode legal value:0 or 1                 
    .c_CLK_OR_POL_INV (c_CLK_OR_POL_INV),       //clk polarity invert for output register legal value 1 or 0         
    .c_INIT_FILE      (c_INIT_FILE),            //legal value:"NONE" or "initial file name"                          
    .c_INIT_FORMAT    (c_INIT_FORMAT),          //initial data format   legal valve: "bin" or "hex"                  
    .c_WR_BYTE_EN     (0),                      //byte write enable    legal value: 0 or 1                            
    .c_BE_WIDTH       (1),                      //byte width legal value: 1~128
    .c_RAM_MODE       ("ROM"),
    .c_WRITE_MODE     ("NORMAL_WRITE")          //global reset enable  legal value 0 or 1                            
 )  U_ipml_spram_gamma_fix_2_2                       //"NORMAL_WRITE"; // TRANSPARENT_WRITE READ_BEFORE_WRITE             
  (
   
    .addr        (addr),
    .wr_data     (),
    .rd_data     (rd_data),
    .wr_en       (1'b0),
    .clk         (clk),
    .clk_en      (clk_en),
    .addr_strobe (addr_strobe),
    .rst         (rst),
    .wr_byte_en  (),
    .rd_oce      (rd_oce) 
  );
 

endmodule

