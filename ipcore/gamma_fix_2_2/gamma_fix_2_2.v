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
// Library:
// Filename:gamma_fix_2_2.v
//////////////////////////////////////////////////////////////////////////////

module gamma_fix_2_2
    (
     addr        ,
     rd_data     ,
     clk         ,
     
     rst
    );


localparam ADDR_WIDTH = 8 ; // @IPC int 9,20

localparam DATA_WIDTH = 8 ; // @IPC int 1,1152

localparam OUTPUT_REG = 1 ; // @IPC bool

localparam RD_OCE_EN = 0 ; // @IPC bool

localparam CLK_OR_POL_INV = 0 ; // @IPC bool

localparam RESET_TYPE = "ASYNC" ; // @IPC enum ASYNC,SYNC,Sync_Internally

localparam POWER_OPT = 0 ; // @IPC bool

localparam INIT_FILE = "D:/Projects/FPGA_match/final_test/src/block_mean/dat_gamma_fix/gamma_fix_2.2.dat" ; // @IPC string

localparam INIT_FORMAT = "HEX" ; // @IPC enum BIN,HEX

localparam CLK_EN  = 0 ; // @IPC bool

localparam ADDR_STROBE_EN  = 0 ; // @IPC bool

localparam INIT_EN = 1 ; // @IPC bool

localparam  RESET_TYPE_SEL  = (RESET_TYPE == "ASYNC") ? "ASYNC_RESET" :
                              (RESET_TYPE == "SYNC")  ? "SYNC_RESET"  : "ASYNC_RESET_SYNC_RELEASE";
localparam  DEVICE_NAME     = "PGL22G";

localparam  DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (DATA_WIDTH <= 9)) ? 10 : DATA_WIDTH;
localparam  SIM_DEVICE      = ((DEVICE_NAME == "PGL22G") || (DEVICE_NAME == "PGL22GS")) ? "PGL22G" : "LOGOS";


input  [ADDR_WIDTH-1 : 0]     addr        ;
output [DATA_WIDTH-1 : 0]     rd_data     ;
input                         clk         ;

input                         rst         ;


wire [ADDR_WIDTH-1 : 0]       addr        ;
wire [DATA_WIDTH-1 : 0]       rd_data     ;
wire                          clk         ;
wire                          clk_en      ;
wire                          addr_strobe ;
wire                          rst         ;
wire                          rd_oce      ;

wire                          rd_oce_mux      ;
wire                          clk_en_mux      ;
wire                          addr_strobe_mux ;

wire [DATA_WIDTH_WRAP-1 : 0]  rd_data_wrap;

assign rd_oce_mux      = (RD_OCE_EN      == 1) ? rd_oce      :
                         (OUTPUT_REG     == 1) ? 1'b1 : 1'b0 ;
assign clk_en_mux      = (CLK_EN         == 1) ? clk_en      : 1'b1 ;
assign addr_strobe_mux = (ADDR_STROBE_EN == 1) ? addr_strobe : 1'b0 ;

assign rd_data         = ((DEVICE_NAME == "PGT30G") && (DATA_WIDTH <= 9)) ? rd_data_wrap[DATA_WIDTH-1 : 0] : rd_data_wrap;


//ipml_rom IP instance
ipml_rom_v1_5_gamma_fix_2_2
    #(
    .c_SIM_DEVICE       ( SIM_DEVICE            ),
    .c_ADDR_WIDTH       ( ADDR_WIDTH            ), //write address width  legal value:1~20 
    .c_DATA_WIDTH       ( DATA_WIDTH_WRAP       ), //write data width     legal value:8~1152
    .c_OUTPUT_REG       ( OUTPUT_REG            ), //output register      legal value:1~20
    .c_RD_OCE_EN        ( RD_OCE_EN             ),
    .c_CLK_EN           ( CLK_EN                ),
    .c_ADDR_STROBE_EN   ( ADDR_STROBE_EN        ),
    .c_RESET_TYPE       ( RESET_TYPE_SEL        ), //ASYNC_RESET_SYNC_RELEASE SYNC_RESET legal valve "ASYNC_RESET_SYNC_RELEASE" "SYNC_RESET" "ASYNC_RESET"
    .c_POWER_OPT        ( POWER_OPT             ), //0 :normal mode  1:low power mode legal value:0 or 1
    .c_CLK_OR_POL_INV   ( CLK_OR_POL_INV        ), //clk polarity invert for output register   legal value 1 or 0
    .c_INIT_FILE        ( "NONE"                ), //legal value:"NONE" or "initial file name"
    .c_INIT_FORMAT      ( INIT_FORMAT           )  //initial data format   legal valve: "bin" or "hex"
    ) U_ipml_rom_gamma_fix_2_2
    (
    .addr               ( addr                  ),
    .rd_data            ( rd_data_wrap          ),
    .clk                ( clk                   ),
    .clk_en             ( clk_en_mux            ),
    .addr_strobe        ( addr_strobe_mux       ),
    .rst                ( rst                   ),
    .rd_oce             ( rd_oce_mux            )
  );

endmodule
