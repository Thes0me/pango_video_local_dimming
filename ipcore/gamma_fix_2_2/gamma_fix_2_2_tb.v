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
// Filename:TB gamma_fix_2_2_tb.v 
//////////////////////////////////////////////////////////////////////////////
`timescale   1ns / 1ps

module  gamma_fix_2_2_tb;
  localparam  T_CLK_PERIOD       = 10 ;       //clock a half perid
  localparam  T_RST_TIME         = 200 ;       //reset time 

localparam ADDR_WIDTH = 8 ; // @IPC int 9,20

localparam DATA_WIDTH = 8 ; // @IPC int 1,1152

localparam OUTPUT_REG = 1 ; // @IPC bool

localparam RD_OCE_EN = 0 ; // @IPC bool

localparam CLK_OR_POL_INV = 0 ; // @IPC bool

localparam RESET_TYPE = "ASYNC" ; // @IPC enum Sync_Internally,SYNC,ASYNC

localparam POWER_OPT = 0 ; // @IPC bool

localparam INIT_FILE = "D:/Projects/FPGA_match/final_test/src/block_mean/dat_gamma_fix/gamma_fix_2.2.dat" ; // @IPC string

localparam INIT_FORMAT = "HEX" ; // @IPC enum BIN,HEX

  localparam  RESET_TYPE_SEL      = (RESET_TYPE == "ASYNC") ? "ASYNC_RESET" :
                                  (RESET_TYPE == "SYNC") ? "SYNC_RESET": "ASYNC_RESET_SYNC_RELEASE";

localparam CLK_EN = 0 ; // @IPC bool

localparam ADDR_STROBE_EN = 0 ; // @IPC bool

localparam INIT_EN = 1 ; // @IPC bool

localparam  DEVICE_NAME     = "PGL22G";

localparam  DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (DATA_WIDTH <= 9)) ? 10 : DATA_WIDTH;

// variable declaration 
reg                     clk            ;
wire                    tb_clk         ;
reg                     tb_rst         ;
reg                     tb_clk_en      ;
reg                     tb_addr_strobe ;
reg   [ADDR_WIDTH  :0]  tb_addr        ;
reg   [DATA_WIDTH-1:0]  tb_wrdata      ;
wire  [DATA_WIDTH-1:0]  tb_rddata      ;
reg                     tb_rd_en       ;
reg                     tb_rd_en_dly   ;
reg                     tb_rd_en_2dly  ;
reg                     tb_rd_oce      ;
reg                     check_err      ;
reg   [2:0]             results_cnt    ;
//************************************************************ CGU ****************************************************************************
//generate tb_clk
initial
begin
    tb_rst        = 1'b1 ;
    #T_RST_TIME;
    tb_rst        = 1'b0 ;
    clk           = 1'b0 ;

    tb_addr       = {ADDR_WIDTH+1{1'b0}} ;
    tb_wrdata     = {DATA_WIDTH{1'b0}} ;
    tb_rd_en      = 1'b0;

    if(RD_OCE_EN == 1)
        tb_rd_oce = 1'b1 ;
    else
        tb_rd_oce = 1'b0 ;
    
    if (CLK_EN == 1)
        tb_clk_en = 1'b1 ;
    else
        tb_clk_en = 1'b0 ;

    if (ADDR_STROBE_EN == 1'b1)
        tb_addr_strobe = 1'b0 ;
    else
        tb_addr_strobe = 1'b0 ;
end

initial
begin
    forever #(T_CLK_PERIOD/2)  clk = ~clk ;
end

assign tb_clk = (CLK_OR_POL_INV == 1) ? ~clk : clk;

task read_rom ;
    input read_rom ;

    begin
        tb_rd_en =1'b0 ;
        tb_addr  = {ADDR_WIDTH+1{1'b0}} ;
        while (tb_addr < 2**ADDR_WIDTH )
        begin
            @(posedge clk) ;
             tb_rd_en = 1'b1 ;
             tb_addr  = tb_addr + {{ADDR_WIDTH{1'b0}},1'b1} ;
        end
        tb_rd_en =1'b0 ;
    end
endtask

initial
begin
    $display("Reading ROM") ;
    read_rom(1) ;
    #10;
    $display("ROM Simulate is Done.") ;

    if (|results_cnt)
        $display("Simulation Failed due to Error Found.") ;
    else
        $display("Simulation Success.") ;

    #500 ;
    $finish ;
end
//check logic

always@(posedge tb_clk or posedge tb_rst)
begin
   if(tb_rst)
       check_err <= 1'b0 ;
   else if(tb_rd_en)
   begin 
       if (((RD_OCE_EN == 1'b1) && (tb_rd_en_2dly) && (tb_rd_oce))
         || ((OUTPUT_REG == 1'b0) && (tb_rd_en_dly))
         || ((OUTPUT_REG == 1'b1) && (tb_rd_en_2dly)))
            check_err <= ({DATA_WIDTH{1'b1}} != tb_rddata) ;
        else
            check_err <= 1'b0;
   end 
   else
       check_err <= 1'b0 ;
end

always @(posedge tb_clk or posedge tb_rst)
begin
    if (tb_rst)
        results_cnt <= 3'b000 ;
    else if (&results_cnt)
        results_cnt <= 3'b100 ;
    else if (check_err)
        results_cnt <= results_cnt + 3'd1 ;
end

//***************************************************************** DUT  INST **************************************************************************************
GTP_GRS GRS_INST(
    .GRS_N(1'b1)
    ) ;

gamma_fix_2_2 U_gamma_fix_2_2 (
    .addr        ( tb_addr[ADDR_WIDTH-1:0] ),
    .rd_data     ( tb_rddata               ),
    .clk         ( clk                     ),

    .rst         ( tb_rst                  )
   ) ;

endmodule
