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

module ipsl_hmic_h_phy_io_v1_1 #(
    parameter                 DQS_GATE_LOOP             ="TRUE",
    parameter                 R_EXTEND                  ="FALSE",
    parameter                 CORE_CLK_SEL              = 1'b0,   
    parameter     [31:0]      TEST_PATTERN2             =32'h0000_0000,								
    parameter     [31:0]      TEST_PATTERN3             =32'h0000_0000,
    parameter     integer     T200US                    =54000,        //0~131071
    parameter     [15:0]      MR0_DDR3                  =16'h1108,
    parameter     [15:0]      MR1_DDR3                  =16'h0001,
    parameter     [15:0]      MR2_DDR3                  =16'h0000,
    parameter     [15:0]      MR3_DDR3                  =16'h0000,
    parameter     [15:0]      MR_DDR2                   =16'h0100,
    parameter     [15:0]      EMR1_DDR2                 =16'h0401,
    parameter     [15:0]      EMR2_DDR2                 =16'h0000,
    parameter     [15:0]      EMR3_DDR2                 =16'h0000,
    parameter     [15:0]      MR_LPDDR                  =16'h0003,
    parameter     [15:0]      EMR_LPDDR                 =16'h0000,
    parameter     integer     TMRD                      =0,        //0~3		
    parameter     integer     TMOD                      =0,        //0~7 	
    parameter     integer     TZQINIT                   =0,        //0~1023	
    parameter     integer     TXPR                      =0,        //0~15			
    parameter     integer     TRP                       =0,        //0~7
    parameter     integer     TRFC                      =0,        //0~255		
    parameter                 WL_EN                     ="FALSE",   //"TRUE" or  "FALSE"
    parameter                 DDR_TYPE                  ="DDR3",   //"DDR3" ,"DDR2", "LPDDR"   
    parameter                 DATA_WIDTH                ="16BIT",  //"16BIT","8BIT"	
    parameter     [1:0]       DQS_GATE_MODE             =2'b00,    //2'b00~2'b11	
    parameter                 WRDATA_PATH_ADJ           ="FALSE",   //"TRUE" or  "FALSE"
    parameter                 CTRL_PATH_ADJ             ="FALSE",   //"TRUE" or  "FALSE" 
    parameter     [7:0]       WL_MAX_STEP               =8'h00,
    parameter     [4:0]       WL_MAX_CHECK              =5'h0,
    parameter                 MAN_WRLVL_DQS_L           = "FALSE",   //"TRUE" or  "FALSE"
    parameter                 MAN_WRLVL_DQS_H           = "FALSE",   //"TRUE" or  "FALSE"
    parameter     [2:0]       WL_CTRL_L                 = 3'h0,
    parameter     [2:0]       WL_CTRL_H                 = 3'h0,
    parameter     [1:0]       INIT_READ_CLK_CTRL        = 2'b00,
    parameter     [1:0]       INIT_READ_CLK_CTRL_H      = 2'b00,
    parameter     [3:0]       INIT_SLIP_STEP            = 4'h0,
    parameter     [3:0]       INIT_SLIP_STEP_H          = 4'h0,
    parameter                 FORCE_READ_CLK_CTRL_L     ="FALSE",   //"TRUE" or  "FALSE"
    parameter                 FORCE_READ_CLK_CTRL_H     ="FALSE",   //"TRUE" or  "FALSE"
    parameter                 STOP_WITH_ERROR           = "TRUE",   //"TRUE" or  "FALSE"
    parameter                 DQGT_DEBUG                = 1'b0,
    parameter                 WRITE_DEBUG               = 1'b0,
    parameter     [4:0]       RDEL_ADJ_MAX_RANG         = 5'h0,
    parameter     [3:0]       MIN_DQSI_WIN              = 4'h0,
    parameter     [7:0]       INIT_SAMP_POSITION        = 8'h0,
    parameter     [7:0]       INIT_SAMP_POSITION_H      = 8'h0,
    parameter                 FORCE_SAMP_POSITION_L     ="FALSE",   //"TRUE" or  "FALSE"
    parameter                 FORCE_SAMP_POSITION_H     ="FALSE",  //"TRUE" or  "FALSE"
    parameter     [18:0]      RDEL_RD_CNT               = 19'h0,
    parameter     integer     T400NS                    = 0,      //0~127 
    parameter     [8:0]       T_LPDDR                   = 9'h0,
    parameter     [7:0]       REF_CNT                   = 8'h0,
    parameter                 APB_VLD                   = "FALSE",  //"TRUE" or  "FALSE"
    parameter     [127:0]     TEST_PATTERN1             = 128'h0000ffff0000ffff0000ffff0000ffff,
    parameter                 TRAIN_RST_TYPE            ="FALSE",  //"TRUE" or  "FALSE"
    parameter     [7:0]       TXS                       =8'h0 ,
    parameter                 WL_SETTING                =1'b1 ,
    parameter                 WCLK_DEL_SEL              =1'b0 ,
    parameter     [7:0]       INIT_WRLVL_STEP_L         =8'h0 ,
    parameter     [7:0]       INIT_WRLVL_STEP_H         =8'h0
	)(   
    input                          srb_core_clk             ,
    input                          pll_clk                  ,
    output                         ioclk_div                ,
    input                          pclk                     ,
    input                          preset                   ,
    input[11:0]                    paddr                    ,
    input[31:0]                    pwdata                   ,
    input                          pwrite                   ,
    input                          penable                  ,
    input                          psel                     ,
    output                         pready                   ,
    output [31:0]                  prdata                   ,
    input                          srb_dqs_rst              ,
    input         [1:0]            ddrphy_update_type       ,
    input         [1:0]            ddrphy_update_comp_val_l ,
    input                          ddrphy_update_comp_dir_l ,
    input         [1:0]            ddrphy_update_comp_val_h ,
    input                          ddrphy_update_comp_dir_h ,
    input                          ddrphy_rst               ,
    output                         ddrphy_rst_req           ,
    input                          ddrphy_rst_ack           ,
    input                          ddrphy_update            ,
    output                         ddrphy_update_done       ,
    input                          dll_update_ack           ,
    input                          srb_rst_dll              ,
    input                          dll_update_n             ,
    output  [7:0]                  dll_step_copy            ,
    input                          srb_dll_freeze           ,
    input                          srb_iol_rst              ,
    input                          srb_dqs_rst_training     ,
    output                         dll_update_req           ,
    output                         dfi_error                ,
    output[2:0]                    dfi_error_info           ,
    output  [63:0]                 dfi_rddata               ,
    output  [3:0]                  dfi_rddata_valid         ,
    output                         dfi_ctrlupd_ack          ,
    output                         dfi_init_complete        ,
    output                         dfi_phyupd_req           ,
    output  [1:0]                  dfi_phyupd_type          ,
    output                         dfi_lp_ack               ,
    input   [31:0]                 dfi_address              ,
    input   [5:0]                  dfi_bank                 ,
    input   [1:0]                  dfi_cas_n                ,
    input   [1:0]                  dfi_ras_n                ,
    input   [1:0]                  dfi_we_n                 ,
    input   [1:0]                  dfi_cke                  ,
    input   [1:0]                  dfi_cs                   ,
    input   [1:0]                  dfi_odt                  ,
    input   [1:0]                  dfi_reset_n              ,
    input   [63:0]                 dfi_wrdata               ,
    input   [7:0]                  dfi_wrdata_mask          ,
    input   [3:0]                  dfi_wrdata_en            ,
    input   [3:0]                  dfi_rddata_en            ,
    input                          dfi_ctrlupd_req          ,
    input                          dfi_dram_clk_disable     ,
    input                          dfi_init_start           ,
    input   [4:0]                  dfi_frequency            ,
    input                          dfi_phyupd_ack           ,
    input                          dfi_lp_req               ,
    input   [3:0]                  dfi_lp_wakeup            ,

//-----------------------------------------------------------
    input                          pad_loop_in              ,
    input                          pad_loop_in_h            ,
    output                         pad_rstn_ch0             ,
    output                         pad_ddr_clk_w            ,
    output                         pad_ddr_clkn_w           ,
    output                         pad_csn_ch0              ,
    output [15:0]                  pad_addr_ch0             ,
    inout  [15:0]                  pad_dq_ch0               ,
    inout  [1:0]                   pad_dqs_ch0              ,
    inout  [1:0]                   pad_dqsn_ch0             ,
    output [1:0]                   pad_dm_rdqs_ch0          ,
    output                         pad_cke_ch0              ,
    output                         pad_odt_ch0              ,
    output                         pad_rasn_ch0             ,
    output                         pad_casn_ch0             ,
    output                         pad_wen_ch0              ,
    output [2:0]                   pad_ba_ch0               ,
    output                         pad_loop_out             ,
    output                         pad_loop_out_h           ,
    output                         dll_lock                 ,
    input                          srb_ioclkdiv_rstn        ,
    output  [1:0]                  dqs_drift_l              ,
    output  [1:0]                  dqs_drift_h              
	);
 

//---------------------------clk_mux-----------------------//
wire  sc_core_clk_sel;
wire  core_ddrc_clk;


//////////////phy_to_iol/dqs/////////////////////////
wire [7:0]                  ddrphy_dq_l             ; 
wire [7:0]                  ddrphy_dq_h             ; 
wire                        ddrphy_wl_ov_l          ;
wire                        ddrphy_dgts_l           ;
wire                        ddrphy_read_valid_l     ;
wire [7:0]                  ddrphy_dll_step         ;
wire                        ddrphy_rdel_ov_l        ;
wire [31:0]                 ddrphy_rdata_l          ;
wire                        ddrphy_wl_ov_h          ;
wire                        ddrphy_dgts_h           ;
wire                        ddrphy_read_valid_h     ;
wire                        ddrphy_rdel_ov_h        ;
wire [31:0]                 ddrphy_rdata_h          ;
wire                        ddrphy_gatei_h          ;
wire                        ddrphy_gatei_l          ;
wire [7:0]                  ddrphy_wl_step_l        ;
wire [2:0]                  ddrphy_wl_ctrl_l        ;
wire [2:0]                  ddrphy_rdqs_step_l      ;
wire [1:0]                  ddrphy_dqs_gate_ctrl_l  ;
wire [2:0]                  ddrphy_read_clk_ctrl_l  ;
wire [15:0]                 ddrphy_wen_l            ;
wire [31:0]                 ddrphy_wdata_l          ;
wire [3:0]                  ddrphy_wdqs_l           ;
wire [1:0]                  ddrphy_wdqs_en_l        ;
wire [3:0]                  ddrphy_dm_l             ;
wire [7:0]                  ddrphy_wl_step_h        ;
wire [2:0]                  ddrphy_wl_ctrl_h        ;
wire [2:0]                  ddrphy_rdqs_step_h      ;
wire [1:0]                  ddrphy_dqs_gate_ctrl_h  ;
wire [2:0]                  ddrphy_read_clk_ctrl_h  ;
wire [15:0]                 ddrphy_wen_h            ;
wire [31:0]                 ddrphy_wdata_h          ;
wire [3:0]                  ddrphy_wdqs_h           ;
wire [3:0]                  ddrphy_dm_h             ;
wire [1:0]                  ddrphy_wdqs_en_h        ;
wire [55:0]                 ddrphy_ca_en            ;  
wire [63:0]                 ddrphy_addr             ;
wire [11:0]                 ddrphy_ba               ;
wire [3:0]                  ddrphy_ck               ;
wire [3:0]                  ddrphy_cke              ;
wire [3:0]                  ddrphy_cs_n             ;
wire [3:0]                  ddrphy_ras_n            ;
wire [3:0]                  ddrphy_cas_n            ;
wire [3:0]                  ddrphy_we_n             ;
wire [3:0]                  ddrphy_odt              ;
wire                        ddrphy_mem_rst          ;
wire [59:0]                 buffer_iol_ce                   ;
wire [59:0]                 buffer_clk_sys                  ;
wire [59:0]                 buffer_iol_lrs                  ;
wire                        buffer_rst_dll                  ;
wire                        buffer_update_n                 ;
wire                        buffer_dll_clk_input            ;
wire                        buffer_dll_freeze               ;
wire [4:0]                  buffer_dqs_rst                  ;
wire [4:0]                  buffer_dqs_rst_training_n       ;
wire [4:0]                  buffer_dqs_clk_regional         ;
wire [2:0]                  buffer_dqs_gatei                ;
wire [23:0]                 buffer_dqs_wl_step              ;
wire [8:0]                  buffer_dqs_wl_ctrl              ;
wire [11:0]                 buffer_dqs_dqs_gate_ctrl        ;
wire [3:0]                  buffer_dqs_dqs_gate_ctrl_tf2    ;
wire [8:0]                  buffer_dqs_read_clk_ctrl        ;
wire [8:0]                  buffer_dqs_rdel_ctrl            ;
wire [103:0]                buffer_iol_tx_data_tf8          ;
wire [183:0]                buffer_iol_tx_data_tf4          ;
wire [6:0]                  buffer_iol_tx_data_tf7          ;
wire [179:0]                buffer_iol_iodly_ctrl           ;
wire [59:0]                 buffer_iol_mipi_sw_dyn_i        ;
wire [51:0]                 buffer_iol_ts_ctrl_tf4          ;
wire [91:0]                 buffer_iol_ts_ctrl_tf2          ;
wire [2:0]                  buffer_iol_ts_ctrl_tf3          ;
wire                        buffer_mem_rst_en               ;
wire [59:0]                 buffer_iol_lrs_regional         ;

/////////////ioclkbuf_signals//////////////
wire                        ioclk_01;
wire                        ioclk_02;

/////////////ioclkdiv_signals//////////////
wire                        glck;

////////////dqs0_signals//////////////
wire                        dqs_clkw_0;
wire                        dqs_clkw290_0;
wire                        dqs_90_0;
wire                        dqs_gate_to_loop_0;
wire [2:0]                  dqs_ififo_wpoint_0;
wire [2:0]                  dqs_ififo_rpoint_0;
wire                        dqs_gate_to_loop_0_in;
wire                        dqs0_clk_r;

////////////dqs1_signals//////////////
wire                        dqs_clkw_ca_01;
wire                        dqs_clkw290_ca_01;
wire                        dqs_ca_clk_r_01;

////////////dqs2_signals//////////////
wire                        dqs_clkw_1;
wire                        dqs_clkw290_1;
wire                        dqs_90_1;
wire                        dqs_gate_to_loop_1;
wire [2:0]                  dqs_ififo_wpoint_1;
wire [2:0]                  dqs_ififo_rpoint_1;
wire                        dqs_gate_to_loop_1_in;
wire                        dqs1_clk_r;

////////////dqs3_signals//////////////
wire                        dqs_clkw_ca_03;
wire                        dqs_clkw290_ca_03;
wire                        dqs_ca_clk_r_03;

////////////dqs1_signals//////////////
wire                        dqs_clkw_ca_04;
wire                        dqs_clkw290_ca_04;
wire                        dqs_ca_clk_r_04;

///////////iol_signals///////////////
wire [3:0]                  phy_dm_0;
wire [55:0]                 phy_ca_en;
wire [31:0]                 dqs_dq_r_0;
wire [31:0]                 dqs_dq_w_0;
wire [15:0]                 dqs_dq_w_en_0;
wire [3:0]                  dqs_dqs_w_0;
wire [1:0]                  dqs_dqs_w_en_0;
wire [3:0]                  phy_ck;
wire [3:0]                  phy_odt;
wire [3:0]                  phy_we_n;
wire [11:0]                 phy_ba;
wire [3:0]                  phy_cas_n;
wire [3:0]                  phy_ras_n;
wire [3:0]                  phy_cs_n;
wire [31:0]                 dqs_dq_r_1;
wire [31:0]                 dqs_dq_w_1;
wire [15:0]                 dqs_dq_w_en_1;
wire [3:0]                  dqs_dqs_w_1;
wire [1:0]                  dqs_dqs_w_en_1;
wire [3:0]                  phy_dm_1;
wire [63:0]                 phy_addr;
wire [3:0]                  phy_cke;
wire                        phy_reset_n;

wire [31:0]                 dqs_dq_r_0_null;
wire [31:0]                 dqs_dq_r_1_null;

////////////iob_signals//////////////
wire                        loop_in_di;
wire                        loop_in_do;
wire                        loop_in_to;
wire                        loop_out_di;
wire                        loop_out_do;
wire                        loop_out_to;

wire                        dm_do_0;
wire                        dm_to_0;
wire [15:0]                 dq_di;
wire [15:0]                 dq_do;
wire [15:0]                 dq_to;
wire                        dqs_di_0;
wire                        dqs_do_0;
wire                        dqs_to_0;

wire                        ck_do;
wire                        ck_to;
wire                        odt_do;
wire                        odt_to;

wire                        wen_do;
wire                        wen_to;

wire [2:0]                  ba_do;
wire [2:0]                  ba_to;

wire                        casn_do;
wire                        casn_to;

wire                        rasn_do;
wire                        rasn_to;

wire                        csn_do;
wire                        csn_to;
wire                        dqs_di_1;
wire                        dqs_do_1;
wire                        dqs_to_1;

wire                        dm_do_1;
wire                        dm_to_1;
wire                        loop_in_di_h;
wire                        loop_in_do_h;
wire                        loop_in_to_h;
wire                        loop_out_di_h;
wire                        loop_out_do_h;
wire                        loop_out_to_h;

wire [15:0]                 addr_do;
wire [15:0]                 addr_to;

wire                        cke_do;
wire                        cke_to;

wire                        resetn_do;
wire                        resetn_to;  

///////////////////the config of the IOCLKBUF////////////////////////////
defparam    ioclkbuf01_dut.GATE_EN                         =                   "FALSE";

//////////////////the config of the IOCLKBUF////////////////////////////
defparam    ioclkbuf02_dut.GATE_EN                         =                   "FALSE";

//////////////////the config of the IOCLKDIV////////////////////////////
defparam    ioclkdiv_dut.DIV_FACTOR                      =                   "2"; //"2"; "3.5"; "4"; "5"; 
defparam    ioclkdiv_dut.GRS_EN                          =                   "TRUE"; //"TRUE"; "FALSE"

//////////////////the config of the HMEMC_DLL////////////////////////////
defparam    dll_hmemc_dut.GRS_EN                               =            "TRUE";
defparam    dll_hmemc_dut.FAST_LOCK                      =                  "TRUE";
defparam    dll_hmemc_dut.DELAY_STEP_OFFSET              =                  0;

//////////////////the config of the DQS0////////////////////////////
defparam    dqs0_dut.DDC_MODE                             =                  "HALF_RATE";
defparam    dqs0_dut.IFIFO_GENERIC                        =                  "FALSE";
defparam    dqs0_dut.WCLK_DELAY_OFFSET                    =                  9'd0;
defparam    dqs0_dut.DQSI_DELAY_OFFSET                    =                  9'd0;
defparam    dqs0_dut.CLKA_GATE_EN                         =                  "TRUE";
defparam    dqs0_dut.R_MOVE_EN                            =                  "TRUE";
defparam    dqs0_dut.W_MOVE_EN                            =                  "TRUE";
defparam    dqs0_dut.R_DELAY_STEP_EN                      =                  "TRUE";
defparam    dqs0_dut.GRS_EN                               =                  "TRUE";
defparam    dqs0_dut.RADDR_INIT                           =                  3'd0;
defparam    dqs0_dut.WCLK_DELAY_SEL                       =                  "FALSE";
defparam    dqs0_dut.RCLK_SEL                             =                  "FALSE";

//////////////////the config of the DQS2////////////////////////////
defparam    dqs2_dut.DDC_MODE                             =                  "HALF_RATE";
defparam    dqs2_dut.IFIFO_GENERIC                        =                  "FALSE";
defparam    dqs2_dut.WCLK_DELAY_OFFSET                    =                  9'd0;
defparam    dqs2_dut.DQSI_DELAY_OFFSET                    =                  9'd0;
defparam    dqs2_dut.CLKA_GATE_EN                         =                  "TRUE";
defparam    dqs2_dut.R_MOVE_EN                            =                  "TRUE";
defparam    dqs2_dut.W_MOVE_EN                            =                  "TRUE";
defparam    dqs2_dut.R_DELAY_STEP_EN                      =                  "TRUE";
defparam    dqs2_dut.GRS_EN                               =                  "TRUE";
defparam    dqs2_dut.RADDR_INIT                           =                  3'd0;
defparam    dqs2_dut.WCLK_DELAY_SEL                       =                  "FALSE";
defparam    dqs2_dut.RCLK_SEL                             =                  "FALSE";

//////////////////the config of the DQS1////////////////////////////
defparam    dqs1_dut.DDC_MODE                             =                  "HALF_RATE";
defparam    dqs1_dut.IFIFO_GENERIC                        =                  "FALSE";
defparam    dqs1_dut.WCLK_DELAY_OFFSET                    =                  9'd0;
defparam    dqs1_dut.DQSI_DELAY_OFFSET                    =                  9'd0;
defparam    dqs1_dut.CLKA_GATE_EN                         =                  "FALSE";
defparam    dqs1_dut.R_MOVE_EN                            =                  "FALSE";
defparam    dqs1_dut.W_MOVE_EN                            =                  "FALSE";
defparam    dqs1_dut.R_EXTEND                             =                  "FALSE";
defparam    dqs1_dut.R_DELAY_STEP_EN                      =                  "TRUE";
defparam    dqs1_dut.GRS_EN                               =                  "TRUE";
defparam    dqs1_dut.RADDR_INIT                           =                  3'd0;
defparam    dqs1_dut.GATE_SEL                             =                  "FALSE";
defparam    dqs1_dut.WCLK_DELAY_SEL                       =                  "FALSE";
defparam    dqs1_dut.RCLK_SEL                             =                  "FALSE";

//////////////////the config of the DQS3////////////////////////////
defparam    dqs3_dut.DDC_MODE                             =                  "HALF_RATE";
defparam    dqs3_dut.IFIFO_GENERIC                        =                  "FALSE";
defparam    dqs3_dut.WCLK_DELAY_OFFSET                    =                  9'd0;
defparam    dqs3_dut.DQSI_DELAY_OFFSET                    =                  9'd0;
defparam    dqs3_dut.CLKA_GATE_EN                         =                  "FALSE";
defparam    dqs3_dut.R_MOVE_EN                            =                  "FALSE";
defparam    dqs3_dut.W_MOVE_EN                            =                  "FALSE";
defparam    dqs3_dut.R_EXTEND                             =                  "FALSE";
defparam    dqs3_dut.R_DELAY_STEP_EN                      =                  "TRUE";
defparam    dqs3_dut.GRS_EN                               =                  "TRUE";
defparam    dqs3_dut.RADDR_INIT                           =                  3'd0;
defparam    dqs3_dut.GATE_SEL                             =                  "FALSE";
defparam    dqs3_dut.WCLK_DELAY_SEL                       =                  "FALSE";
defparam    dqs3_dut.RCLK_SEL                             =                  "FALSE";

//////////////////the config of the DQS4////////////////////////////
defparam    dqs4_dut.DDC_MODE                             =                  "HALF_RATE";
defparam    dqs4_dut.IFIFO_GENERIC                        =                  "FALSE";
defparam    dqs4_dut.WCLK_DELAY_OFFSET                    =                  9'd0;
defparam    dqs4_dut.DQSI_DELAY_OFFSET                    =                  9'd0;
defparam    dqs4_dut.CLKA_GATE_EN                         =                  "FALSE";
defparam    dqs4_dut.R_MOVE_EN                            =                  "FALSE";
defparam    dqs4_dut.W_MOVE_EN                            =                  "FALSE";
defparam    dqs4_dut.R_EXTEND                             =                  "FALSE";
defparam    dqs4_dut.R_DELAY_STEP_EN                      =                  "TRUE";
defparam    dqs4_dut.GRS_EN                               =                  "TRUE";
defparam    dqs4_dut.RADDR_INIT                           =                  3'd0;
defparam    dqs4_dut.GATE_SEL                             =                  "FALSE";
defparam    dqs4_dut.WCLK_DELAY_SEL                       =                  "FALSE";
defparam    dqs4_dut.RCLK_SEL                             =                  "FALSE";

//////////////////the config of the IOL2////////////////////////////
defparam    iol_oddr2_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr2_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr2_dut.GRS_EN       = "TRUE";
defparam    iol_oddr2_dut.LRS_EN       = "TRUE";
defparam    iol_oddr2_dut.TSDDR_INIT   = 1'b0;


//////////////////the config of the IOL3////////////////////////////
defparam    iol_iddr3_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr3_dut.GRS_EN       = "TRUE";
defparam    iol_iddr3_dut.LRS_EN       = "TRUE";

defparam    iol_oddr3_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr3_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr3_dut.GRS_EN       = "TRUE";
defparam    iol_oddr3_dut.LRS_EN       = "TRUE";
defparam    iol_oddr3_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL4////////////////////////////
defparam    iol_iddr4_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr4_dut.GRS_EN       = "TRUE";
defparam    iol_iddr4_dut.LRS_EN       = "TRUE";

defparam    iol_oddr4_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr4_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr4_dut.GRS_EN       = "TRUE";
defparam    iol_oddr4_dut.LRS_EN       = "TRUE";
defparam    iol_oddr4_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL5////////////////////////////
defparam    iol_iddr5_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr5_dut.GRS_EN       = "TRUE";
defparam    iol_iddr5_dut.LRS_EN       = "TRUE";

defparam    iol_oddr5_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr5_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr5_dut.GRS_EN       = "TRUE";
defparam    iol_oddr5_dut.LRS_EN       = "TRUE";
defparam    iol_oddr5_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL6////////////////////////////
defparam    iol_iddr6_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr6_dut.GRS_EN       = "TRUE";
defparam    iol_iddr6_dut.LRS_EN       = "TRUE";

defparam    iol_oddr6_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr6_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr6_dut.GRS_EN       = "TRUE";
defparam    iol_oddr6_dut.LRS_EN       = "TRUE";
defparam    iol_oddr6_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL7////////////////////////////
defparam    iol_iddr7_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr7_dut.GRS_EN       = "TRUE";
defparam    iol_iddr7_dut.LRS_EN       = "TRUE";

defparam    iol_oddr7_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr7_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr7_dut.GRS_EN       = "TRUE";
defparam    iol_oddr7_dut.LRS_EN       = "TRUE";
defparam    iol_oddr7_dut.TSDDR_INIT   = 1'b1;

//////////////////the config of the IOL9////////////////////////////
//defparam    iol_iddr9_dut.ISERDES_MODE = "IMDES4";
//defparam    iol_iddr9_dut.GRS_EN       = "TRUE";
//defparam    iol_iddr9_dut.LRS_EN       = "TRUE";

defparam    iol_oddr9_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr9_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr9_dut.GRS_EN       = "TRUE";
defparam    iol_oddr9_dut.LRS_EN       = "TRUE";
defparam    iol_oddr9_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL10////////////////////////////
defparam    iol_iddr10_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr10_dut.GRS_EN       = "TRUE";
defparam    iol_iddr10_dut.LRS_EN       = "TRUE";

defparam    iol_oddr10_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr10_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr10_dut.GRS_EN       = "TRUE";
defparam    iol_oddr10_dut.LRS_EN       = "TRUE";
defparam    iol_oddr10_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL11////////////////////////////
defparam    iol_iddr11_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr11_dut.GRS_EN       = "TRUE";
defparam    iol_iddr11_dut.LRS_EN       = "TRUE";

defparam    iol_oddr11_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr11_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr11_dut.GRS_EN       = "TRUE";
defparam    iol_oddr11_dut.LRS_EN       = "TRUE";
defparam    iol_oddr11_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL12////////////////////////////
defparam    iol_iddr12_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr12_dut.GRS_EN       = "TRUE";
defparam    iol_iddr12_dut.LRS_EN       = "TRUE";

defparam    iol_oddr12_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr12_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr12_dut.GRS_EN       = "TRUE";
defparam    iol_oddr12_dut.LRS_EN       = "TRUE";
defparam    iol_oddr12_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL17////////////////////////////
defparam    iol_oddr17_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr17_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr17_dut.GRS_EN       = "TRUE";
defparam    iol_oddr17_dut.LRS_EN       = "TRUE";
defparam    iol_oddr17_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL18////////////////////////////
defparam    iol_oddr18_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr18_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr18_dut.GRS_EN       = "TRUE";
defparam    iol_oddr18_dut.LRS_EN       = "TRUE";
defparam    iol_oddr18_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL19////////////////////////////
defparam    iol_oddr19_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr19_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr19_dut.GRS_EN       = "TRUE";
defparam    iol_oddr19_dut.LRS_EN       = "TRUE";
defparam    iol_oddr19_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL20////////////////////////////
defparam    iol_oddr20_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr20_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr20_dut.GRS_EN       = "TRUE";
defparam    iol_oddr20_dut.LRS_EN       = "TRUE";
defparam    iol_oddr20_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL21////////////////////////////
defparam    iol_oddr21_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr21_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr21_dut.GRS_EN       = "TRUE";
defparam    iol_oddr21_dut.LRS_EN       = "TRUE";
defparam    iol_oddr21_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL22////////////////////////////


defparam    iol_oddr22_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr22_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr22_dut.GRS_EN       = "TRUE";
defparam    iol_oddr22_dut.LRS_EN       = "TRUE";
defparam    iol_oddr22_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL23////////////////////////////
defparam    iol_oddr23_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr23_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr23_dut.GRS_EN       = "TRUE";
defparam    iol_oddr23_dut.LRS_EN       = "TRUE";
defparam    iol_oddr23_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL24////////////////////////////
defparam    iol_oddr24_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr24_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr24_dut.GRS_EN       = "TRUE";
defparam    iol_oddr24_dut.LRS_EN       = "TRUE";
defparam    iol_oddr24_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL25////////////////////////////
defparam    iol_oddr25_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr25_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr25_dut.GRS_EN       = "TRUE";
defparam    iol_oddr25_dut.LRS_EN       = "TRUE";
defparam    iol_oddr25_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL27////////////////////////////
defparam    iol_iddr27_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr27_dut.GRS_EN       = "TRUE";
defparam    iol_iddr27_dut.LRS_EN       = "TRUE";

defparam    iol_oddr27_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr27_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr27_dut.GRS_EN       = "TRUE";
defparam    iol_oddr27_dut.LRS_EN       = "TRUE";
defparam    iol_oddr27_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL28////////////////////////////
defparam    iol_iddr28_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr28_dut.GRS_EN       = "TRUE";
defparam    iol_iddr28_dut.LRS_EN       = "TRUE";

defparam    iol_oddr28_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr28_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr28_dut.GRS_EN       = "TRUE";
defparam    iol_oddr28_dut.LRS_EN       = "TRUE";
defparam    iol_oddr28_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL29////////////////////////////
defparam    iol_iddr29_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr29_dut.GRS_EN       = "TRUE";
defparam    iol_iddr29_dut.LRS_EN       = "TRUE";

defparam    iol_oddr29_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr29_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr29_dut.GRS_EN       = "TRUE";
defparam    iol_oddr29_dut.LRS_EN       = "TRUE";
defparam    iol_oddr29_dut.TSDDR_INIT   = 1'b1;



//////////////////the config of the IOL31////////////////////////////

defparam    iol_oddr31_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr31_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr31_dut.GRS_EN       = "TRUE";
defparam    iol_oddr31_dut.LRS_EN       = "TRUE";
defparam    iol_oddr31_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL32////////////////////////////
defparam    iol_iddr32_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr32_dut.GRS_EN       = "TRUE";
defparam    iol_iddr32_dut.LRS_EN       = "TRUE";

defparam    iol_oddr32_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr32_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr32_dut.GRS_EN       = "TRUE";
defparam    iol_oddr32_dut.LRS_EN       = "TRUE";
defparam    iol_oddr32_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL33////////////////////////////
defparam    iol_iddr33_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr33_dut.GRS_EN       = "TRUE";
defparam    iol_iddr33_dut.LRS_EN       = "TRUE";

defparam    iol_oddr33_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr33_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr33_dut.GRS_EN       = "TRUE";
defparam    iol_oddr33_dut.LRS_EN       = "TRUE";
defparam    iol_oddr33_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL34////////////////////////////
defparam    iol_iddr34_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr34_dut.GRS_EN       = "TRUE";
defparam    iol_iddr34_dut.LRS_EN       = "TRUE";

defparam    iol_oddr34_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr34_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr34_dut.GRS_EN       = "TRUE";
defparam    iol_oddr34_dut.LRS_EN       = "TRUE";
defparam    iol_oddr34_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL35////////////////////////////
defparam    iol_iddr35_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr35_dut.GRS_EN       = "TRUE";
defparam    iol_iddr35_dut.LRS_EN       = "TRUE";

defparam    iol_oddr35_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr35_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr35_dut.GRS_EN       = "TRUE";
defparam    iol_oddr35_dut.LRS_EN       = "TRUE";
defparam    iol_oddr35_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL36////////////////////////////
defparam    iol_iddr36_dut.ISERDES_MODE = "IMDES4";
defparam    iol_iddr36_dut.GRS_EN       = "TRUE";
defparam    iol_iddr36_dut.LRS_EN       = "TRUE";

defparam    iol_oddr36_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr36_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr36_dut.GRS_EN       = "TRUE";
defparam    iol_oddr36_dut.LRS_EN       = "TRUE";
defparam    iol_oddr36_dut.TSDDR_INIT   = 1'b1;


//////////////////the config of the IOL37////////////////////////////
defparam    iol_oddr37_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr37_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr37_dut.GRS_EN       = "TRUE";
defparam    iol_oddr37_dut.LRS_EN       = "TRUE";
defparam    iol_oddr37_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL40////////////////////////////
defparam    iol_oddr40_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr40_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr40_dut.GRS_EN       = "TRUE";
defparam    iol_oddr40_dut.LRS_EN       = "TRUE";
defparam    iol_oddr40_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL41////////////////////////////
defparam    iol_oddr41_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr41_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr41_dut.GRS_EN       = "TRUE";
defparam    iol_oddr41_dut.LRS_EN       = "TRUE";
defparam    iol_oddr41_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL42////////////////////////////
defparam    iol_oddr42_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr42_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr42_dut.GRS_EN       = "TRUE";
defparam    iol_oddr42_dut.LRS_EN       = "TRUE";
defparam    iol_oddr42_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL43////////////////////////////
defparam    iol_oddr43_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr43_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr43_dut.GRS_EN       = "TRUE";
defparam    iol_oddr43_dut.LRS_EN       = "TRUE";
defparam    iol_oddr43_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL44////////////////////////////
defparam    iol_oddr44_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr44_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr44_dut.GRS_EN       = "TRUE";
defparam    iol_oddr44_dut.LRS_EN       = "TRUE";
defparam    iol_oddr44_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL45////////////////////////////
defparam    iol_oddr45_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr45_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr45_dut.GRS_EN       = "TRUE";
defparam    iol_oddr45_dut.LRS_EN       = "TRUE";
defparam    iol_oddr45_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL46////////////////////////////
defparam    iol_oddr46_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr46_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr46_dut.GRS_EN       = "TRUE";
defparam    iol_oddr46_dut.LRS_EN       = "TRUE";
defparam    iol_oddr46_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL47////////////////////////////
defparam    iol_oddr47_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr47_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr47_dut.GRS_EN       = "TRUE";
defparam    iol_oddr47_dut.LRS_EN       = "TRUE";
defparam    iol_oddr47_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL48////////////////////////////
defparam    iol_oddr48_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr48_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr48_dut.GRS_EN       = "TRUE";
defparam    iol_oddr48_dut.LRS_EN       = "TRUE";
defparam    iol_oddr48_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL49////////////////////////////
defparam    iol_oddr49_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr49_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr49_dut.GRS_EN       = "TRUE";
defparam    iol_oddr49_dut.LRS_EN       = "TRUE";
defparam    iol_oddr49_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL51////////////////////////////
defparam    iol_oddr51_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr51_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr51_dut.GRS_EN       = "TRUE";
defparam    iol_oddr51_dut.LRS_EN       = "TRUE";
defparam    iol_oddr51_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL52////////////////////////////
defparam    iol_oddr52_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr52_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr52_dut.GRS_EN       = "TRUE";
defparam    iol_oddr52_dut.LRS_EN       = "TRUE";
defparam    iol_oddr52_dut.TSDDR_INIT   = 1'b0;

//////////////////the config of the IOL55////////////////////////////
defparam    iol_oddr55_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr55_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr55_dut.GRS_EN       = "TRUE";
defparam    iol_oddr55_dut.LRS_EN       = "TRUE";
defparam    iol_oddr55_dut.TSDDR_INIT   = 1'b0;


//////////////////the config of the IOL56////////////////////////////
defparam    iol_oddr56_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr56_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr56_dut.GRS_EN       = "TRUE";
defparam    iol_oddr56_dut.LRS_EN       = "TRUE";
defparam    iol_oddr56_dut.TSDDR_INIT   = 1'b0;


//////////////////the config of the IOL57////////////////////////////
defparam    iol_oddr57_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr57_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr57_dut.GRS_EN       = "TRUE";
defparam    iol_oddr57_dut.LRS_EN       = "TRUE";
defparam    iol_oddr57_dut.TSDDR_INIT   = 1'b0;


//////////////////the config of the IOL58////////////////////////////
defparam    iol_oddr58_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr58_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr58_dut.GRS_EN       = "TRUE";
defparam    iol_oddr58_dut.LRS_EN       = "TRUE";
defparam    iol_oddr58_dut.TSDDR_INIT   = 1'b0;


//////////////////the config of the IOL59////////////////////////////
defparam    iol_oddr59_dut.OSERDES_MODE = "OMSER4";
defparam    iol_oddr59_dut.WL_EXTEND    = "FALSE";
defparam    iol_oddr59_dut.GRS_EN       = "TRUE";
defparam    iol_oddr59_dut.LRS_EN       = "TRUE";
defparam    iol_oddr59_dut.TSDDR_INIT   = 1'b0;
//*************************** parameter end     *************************//            
assign  sc_core_clk_sel= CORE_CLK_SEL;
assign  core_ddrc_clk= sc_core_clk_sel ? srb_core_clk : glck;
assign  ioclk_div=glck;
///////////HMEMC_TILE_14/138_0/////////////
//GTP_GRS GRS_INST(
//  .GRS_N(GRS_N));
///////////HMEMC_TILE_14/138_0/////////////
GTP_DDRPHY #(
    .TEST_PATTERN2          (TEST_PATTERN2        ),  	
    .TEST_PATTERN3          (TEST_PATTERN3        ),
    .T200US                 (T200US               ),
    .MR0_DDR3               (MR0_DDR3             ),
    .MR1_DDR3               (MR1_DDR3             ),
    .MR2_DDR3               (MR2_DDR3             ),
    .MR3_DDR3               (MR3_DDR3             ),
    .MR_DDR2                (MR_DDR2              ),
    .EMR1_DDR2              (EMR1_DDR2            ),
    .EMR2_DDR2              (EMR2_DDR2            ),
    .EMR3_DDR2              (EMR3_DDR2            ),
    .MR_LPDDR               (MR_LPDDR             ),
    .EMR_LPDDR              (EMR_LPDDR            ),
    .TMRD                   (TMRD                 ),
    .TMOD                   (TMOD                 ),
    .TZQINIT                (TZQINIT              ),
    .TXPR                   (TXPR                 ),
    .TRP                    (TRP                  ),
    .TRFC                   (TRFC                 ),
    .WL_EN                  (WL_EN                ),
    .DDR_TYPE               (DDR_TYPE             ),
    .DATA_WIDTH             (DATA_WIDTH           ),
    .DQS_GATE_MODE          (DQS_GATE_MODE        ),
    .WRDATA_PATH_ADJ        (WRDATA_PATH_ADJ      ),
    .CTRL_PATH_ADJ          (CTRL_PATH_ADJ        ),
    .WL_MAX_STEP            (WL_MAX_STEP          ),
    .WL_MAX_CHECK           (WL_MAX_CHECK         ),
    .MAN_WRLVL_DQS_L        (MAN_WRLVL_DQS_L      ),
    .MAN_WRLVL_DQS_H        (MAN_WRLVL_DQS_H      ),
    .WL_CTRL_L              (WL_CTRL_L            ),
    .WL_CTRL_H              (WL_CTRL_H            ),
    .INIT_READ_CLK_CTRL     (INIT_READ_CLK_CTRL   ),
    .INIT_READ_CLK_CTRL_H   (INIT_READ_CLK_CTRL_H ),
    .INIT_SLIP_STEP         (INIT_SLIP_STEP       ),
    .INIT_SLIP_STEP_H       (INIT_SLIP_STEP_H     ),
    .FORCE_READ_CLK_CTRL_L  (FORCE_READ_CLK_CTRL_L),
    .FORCE_READ_CLK_CTRL_H  (FORCE_READ_CLK_CTRL_H),
    .STOP_WITH_ERROR        (STOP_WITH_ERROR      ),
    .DQGT_DEBUG             (DQGT_DEBUG           ),
    .WRITE_DEBUG            (WRITE_DEBUG          ),
    .RDEL_ADJ_MAX_RANG      (RDEL_ADJ_MAX_RANG    ),
    .MIN_DQSI_WIN           (MIN_DQSI_WIN         ),
    .INIT_SAMP_POSITION     (INIT_SAMP_POSITION   ),
    .INIT_SAMP_POSITION_H   (INIT_SAMP_POSITION_H ),
    .FORCE_SAMP_POSITION_L  (FORCE_SAMP_POSITION_L),
    .FORCE_SAMP_POSITION_H  (FORCE_SAMP_POSITION_H),
    .RDEL_RD_CNT            (RDEL_RD_CNT          ),
    .T400NS                 (T400NS               ),
    .T_LPDDR                (T_LPDDR              ),
    .REF_CNT                (REF_CNT              ),
    .APB_VLD                (APB_VLD              ),
    .TEST_PATTERN1          (TEST_PATTERN1        ),
    .TRAIN_RST_TYPE         (TRAIN_RST_TYPE       ),    
    .TXS                    (TXS                  ),
    .WL_SETTING             (WL_SETTING           ),
    .WCLK_DEL_SEL           (WCLK_DEL_SEL         ),
    .INIT_WRLVL_STEP_L      (INIT_WRLVL_STEP_L    ),
    .INIT_WRLVL_STEP_H      (INIT_WRLVL_STEP_H    )
    ) u_gtp_ddrphy(
 //////intput of the PHY//////
    .DDRPHY_UPDATE_TYPE        (ddrphy_update_type       ),
    .DDRPHY_UPDATE_COMP_VAL_L  (ddrphy_update_comp_val_l ),
    .DDRPHY_UPDATE_COMP_DIR_L  (ddrphy_update_comp_dir_l ),
    .DDRPHY_UPDATE_COMP_VAL_H  (ddrphy_update_comp_val_h ),
    .DDRPHY_UPDATE_COMP_DIR_H  (ddrphy_update_comp_dir_h ),
    .DDRPHY_CLKIN              (core_ddrc_clk            ),  //core_ddrc_core_clk
    .DDRPHY_RST                (ddrphy_rst               ),
    .DDRPHY_RST_ACK            (ddrphy_rst_ack           ),
    .DDRPHY_UPDATE             (ddrphy_update            ),
    .PCLK                      (pclk                     ),
    .PRESET                    (preset                   ),
    .PADDR                     (paddr                    ),
    .PWDATA                    (pwdata                   ),
    .PWRITE                    (pwrite                   ),
    .PSEL                      (psel                     ),
    .PENABLE                   (penable                  ),
    .DDRPHY_DQ_L               (ddrphy_dq_l              ),   //iol_to_hmemc
    .DDRPHY_DQ_H               (ddrphy_dq_h              ),   //iol_to_hmemc
    .DLL_UPDATE_ACK            (dll_update_ack           ),              
    .DDRPHY_WL_OV_L            (ddrphy_wl_ov_l           ),   //dqs0_to_hmemc
    .DDRPHY_DGTS_L             (ddrphy_dgts_l            ),   //dqs0_to_hmemc
    .DDRPHY_READ_VALID_L       (ddrphy_read_valid_l      ),   //dqs0_to_hmemc
    .DDRPHY_DLL_STEP           (ddrphy_dll_step          ),   //dll_to_hmemc
    .DDRPHY_RDEL_OV_L          (ddrphy_rdel_ov_l         ),   //dqs0_to_hmemc
    .DDRPHY_RDATA_L            (ddrphy_rdata_l           ),   //iol_to_hmemc
    .DDRPHY_WL_OV_H            (ddrphy_wl_ov_h           ),   //dqs2_to_hmemc
    .DDRPHY_DGTS_H             (ddrphy_dgts_h            ),   //dqs2_to_hmemc
    .DDRPHY_READ_VALID_H       (ddrphy_read_valid_h      ),   //dqs2_to_hmemc
    .DDRPHY_RDEL_OV_H          (ddrphy_rdel_ov_h         ),   //dqs2_to_hmemc
    .DDRPHY_RDATA_H            (ddrphy_rdata_h           ),   //iol_to_hmemc
    .DFI_ADDRESS               (dfi_address              ),   //ddrc_to_phy
    .DFI_BANK                  (dfi_bank                 ),   //ddrc_to_phy
    .DFI_CAS_N                 (dfi_cas_n                ),   //ddrc_to_phy
    .DFI_RAS_N                 (dfi_ras_n                ),   //ddrc_to_phy
    .DFI_WE_N                  (dfi_we_n                 ),   //ddrc_to_phy
    .DFI_CKE                   (dfi_cke                  ),   //ddrc_to_phy
    .DFI_CS                    (dfi_cs                   ),   //ddrc_to_phy
    .DFI_ODT                   (dfi_odt                  ),   //ddrc_to_phy
    .DFI_RESET_N               (dfi_reset_n              ),   //ddrc_to_phy
    .DFI_WRDATA                (dfi_wrdata               ),   //ddrc_to_phy
    .DFI_WRDATA_MASK           (dfi_wrdata_mask          ),   //ddrc_to_phy
    .DFI_WRDATA_EN             (dfi_wrdata_en            ),   //ddrc_to_phy
    .DFI_RDDATA_EN             (dfi_rddata_en            ),   //ddrc_to_phy
    .DFI_CTRLUPD_REQ           (dfi_ctrlupd_req          ),   //ddrc_to_phy
    .DFI_DRAM_CLK_DISABLE      (dfi_dram_clk_disable     ),   //ddrc_to_phy
    .DFI_INIT_START            (dfi_init_start           ),   //ddrc_to_phy
    .DFI_FREQUENCY             (dfi_frequency            ),   //ddrc_to_phy
    .DFI_PHYUPD_ACK            (dfi_phyupd_ack           ),   //ddrc_to_phy
    .DFI_LP_REQ                (dfi_lp_req               ),   //ddrc_to_phy
    .DFI_LP_WAKEUP             (dfi_lp_wakeup            ),   //ddrc_to_phy
    .SRB_RST_DLL               (srb_rst_dll              ),
    .DLL_UPDATE_N              (dll_update_n             ),
    .SRB_DLL_FREEZE            (srb_dll_freeze           ),
    .SRB_IOL_RST               (srb_iol_rst              ),
    .SRB_DQS_RST               (srb_dqs_rst              ),
    .SRB_DQS_RST_TRAINING      (srb_dqs_rst_training     ),
                                                         
//////output of the PHY//////                            
    .DDRPHY_RST_REQ            (ddrphy_rst_req           ),
    .DDRPHY_UPDATE_DONE        (ddrphy_update_done       ),                	
    .PREADY                    (pready                   ),
    .PRDATA                    (prdata                   ),
    .DDRPHY_GATEI_H            (ddrphy_gatei_h           ),        //hmemc_to_dqs2
    .DDRPHY_GATEI_L            (ddrphy_gatei_l           ),        //hmemc_to_dqs0
    .DLL_UPDATE_REQ            (dll_update_req           ),
    .DDRPHY_WL_STEP_L          (ddrphy_wl_step_l         ),        //hmemc_to_dqs0
    .DDRPHY_WL_CTRL_L          (ddrphy_wl_ctrl_l         ),        //hmemc_to_dqs0
    .DDRPHY_RDQS_STEP_L        (ddrphy_rdqs_step_l       ),        //hmemc_to_dqs0
    .DDRPHY_DQS_GATE_CTRL_L    (ddrphy_dqs_gate_ctrl_l   ),        //hmemc_to_dqs0
    .DDRPHY_READ_CLK_CTRL_L    (ddrphy_read_clk_ctrl_l   ),        //hmemc_to_dqs0
    .DDRPHY_WEN_L              (ddrphy_wen_l             ),        //hmemc_to_iol
    .DDRPHY_WDATA_L            (ddrphy_wdata_l           ),        //hmemc_to_iol
    .DDRPHY_WDQS_L             (ddrphy_wdqs_l            ),        //hmemc_to_iol
    .DDRPHY_WDQS_EN_L          (ddrphy_wdqs_en_l         ),        //hmemc_to_iol
    .DDRPHY_DM_L               (ddrphy_dm_l              ),        //hmemc_to_iol
    .DDRPHY_WL_STEP_H          (ddrphy_wl_step_h         ),        //hmemc_to_dqs2
    .DDRPHY_WL_CTRL_H          (ddrphy_wl_ctrl_h         ),        //hmemc_to_dqs2
    .DDRPHY_RDQS_STEP_H        (ddrphy_rdqs_step_h       ),        //hmemc_to_dqs2
    .DDRPHY_DQS_GATE_CTRL_H    (ddrphy_dqs_gate_ctrl_h   ),        //hmemc_to_dqs2
    .DDRPHY_READ_CLK_CTRL_H    (ddrphy_read_clk_ctrl_h   ),        //hmemc_to_dqs2
    .DDRPHY_WEN_H              (ddrphy_wen_h             ),        //hmemc_to_iol
    .DDRPHY_WDATA_H            (ddrphy_wdata_h           ),        //hmemc_to_iol
    .DDRPHY_WDQS_H             (ddrphy_wdqs_h            ),        //hmemc_to_iol
    .DDRPHY_DM_H               (ddrphy_dm_h              ),        //hmemc_to_iol
    .DDRPHY_WDQS_EN_H          (ddrphy_wdqs_en_h         ),        //hmemc_to_iol
    .DDRPHY_CA_EN              (ddrphy_ca_en             ),        //hmemc_to_iol
    .DDRPHY_ADDR               (ddrphy_addr              ),        //hmemc_to_iol
    .DDRPHY_BA                 (ddrphy_ba                ),        //hmemc_to_iol
    .DDRPHY_CK                 (ddrphy_ck                ),        //hmemc_to_iol
    .DDRPHY_CKE                (ddrphy_cke               ),        //hmemc_to_iol
    .DDRPHY_CS_N               (ddrphy_cs_n              ),        //hmemc_to_iol
    .DDRPHY_RAS_N              (ddrphy_ras_n             ),        //hmemc_to_iol
    .DDRPHY_CAS_N              (ddrphy_cas_n             ),        //hmemc_to_iol
    .DDRPHY_WE_N               (ddrphy_we_n              ),        //hmemc_to_iol
    .DDRPHY_ODT                (ddrphy_odt               ),        //hmemc_to_iol
    .DDRPHY_MEM_RST            (ddrphy_mem_rst           ),        //hmemc_to_iol
    .DFI_RDDATA                (dfi_rddata               ),
    .DFI_RDDATA_VALID          (dfi_rddata_valid         ),
    .DFI_CTRLUPD_ACK           (dfi_ctrlupd_ack          ),
    .DFI_INIT_COMPLETE         (dfi_init_complete        ),
    .DFI_PHYUPD_REQ            (dfi_phyupd_req           ),
    .DFI_PHYUPD_TYPE           (dfi_phyupd_type          ),
    .DFI_LP_ACK                (dfi_lp_ack               ),
    .DFI_ERROR                 (dfi_error                ),
    .DFI_ERROR_INFO            (dfi_error_info           ),
    .IOL_CE                    (buffer_iol_ce                 ),
    .IOL_CLK_SYS               (buffer_clk_sys                ),
    .IOL_LRS                   (buffer_iol_lrs_regional       ),   //buffer_iol_lrs
    .RST_DLL                   (buffer_rst_dll                ),
    .UPDATE_N                  (buffer_update_n               ),
    .DLL_CLK_INPUT             (buffer_dll_clk_input          ),
    .DLL_FREEZE                (buffer_dll_freeze             ),                       
    .DQS_RST                   (buffer_dqs_rst                ),
    .DQS_RST_TRAINING_N        (buffer_dqs_rst_training_n     ),
    .DQS_CLK_REGIONAL          (buffer_dqs_clk_regional       ),
    .DQS_GATEI                 (buffer_dqs_gatei              ),
    .DQS_WL_STEP               (buffer_dqs_wl_step            ),
    .DQS_WL_CTRL               (buffer_dqs_wl_ctrl            ),
    .DQS_DQS_GATE_CTRL         (buffer_dqs_dqs_gate_ctrl      ),
    .DQS_DQS_GATE_CTRL_TF2     (buffer_dqs_dqs_gate_ctrl_tf2  ),   
    .DQS_READ_CLK_CTRL         (buffer_dqs_read_clk_ctrl      ),   
    .DQS_RDEL_CTRL             (buffer_dqs_rdel_ctrl          ),       
    .IOL_TX_DATA_TF8           (buffer_iol_tx_data_tf8        ),      
    .IOL_TX_DATA_TF4           (buffer_iol_tx_data_tf4        ),   
    .IOL_TX_DATA_TF7           (buffer_iol_tx_data_tf7        ),                               
    .IOL_IODLY_CTRL            (buffer_iol_iodly_ctrl         ),                
    .IOL_MIPI_SW_DYN_I         (buffer_iol_mipi_sw_dyn_i      ),                  
    .IOL_TS_CTRL_TF4           (buffer_iol_ts_ctrl_tf4        ), 
    .IOL_TS_CTRL_TF2           (buffer_iol_ts_ctrl_tf2        ),                               
    .IOL_TS_CTRL_TF3           (buffer_iol_ts_ctrl_tf3        ),
    .MEM_RST_EN                (buffer_mem_rst_en             )
);

GTP_IOCLKBUF ioclkbuf01_dut(
/////output of the ioclkbuf////
   .CLKOUT                               (ioclk_01),
/////input of the ioclkbuf////
   .CLKIN                                (pll_clk),
   .DI                                   (1'b0)
);

GTP_IOCLKBUF ioclkbuf02_dut(
/////output of the ioclkbuf////
   .CLKOUT                               (ioclk_02),
/////input of the ioclkbuf////
   .CLKIN                                (pll_clk),
   .DI                                   (1'b0)
);

GTP_IOCLKDIV ioclkdiv_dut(
/////output of the ioclkdiv////
   .CLKDIVOUT                            (glck),
/////input of the ioclkdiv////
   .CLKIN                                (ioclk_01),
   .RST_N                                (srb_ioclkdiv_rstn)   //srb_rst_dll
);

GTP_DLL dll_hmemc_dut(
////////output of the dll///////
   .DELAY_STEP                           (ddrphy_dll_step),
   .LOCK                                 (dll_lock ),//dll_lock
///////input of the dll////////
   .CLKIN                                (ioclk_01),   //buffer_dll_clk_input
   .UPDATE_N                             (buffer_update_n),//dll_update_n
   .RST                                  (buffer_rst_dll),//dll_rst_n
   .PWD                                  (buffer_dll_freeze)//dll_freeze
);

GTP_DLL  #(
 .GRS_EN         ("FALSE"), //"true"; "false"
 .FAST_LOCK      ("TRUE"), //"true"; "false"
 .DELAY_STEP_OFFSET    (0)  //-4, -3,-2, -1, 0, 1, 2, 3, 4
)I_GTP_DLL_copy(         
 .CLKIN          (ioclk_02),
 .UPDATE_N       (1'b0),
 .RST            (srb_rst_dll),
 .PWD            (1'b0),
 .DELAY_STEP     (dll_step_copy),
 .LOCK           ()
);

////////////HMEMC_TILE_6/150_24////////////
GTP_DDC_E1    #(
   .R_EXTEND                             (R_EXTEND),
   .GATE_SEL                             (DQS_GATE_LOOP)
   ) dqs0_dut(
   //output
   .WDELAY_OB                            (ddrphy_wl_ov_l),
   .WCLK                                 (dqs_clkw_0),
   .WCLK_DELAY                           (dqs_clkw290_0),
   .RCLK                                 (dqs0_clk_r),
   .RDELAY_OB                            (ddrphy_rdel_ov_l),
   .DQSI_DELAY                           (dqs_90_0),
   .DGTS                                 (ddrphy_dgts_l),
   .READ_VALID                           (ddrphy_read_valid_l),
   .GATE_OUT                             (dqs_gate_to_loop_0),
   .IFIFO_WADDR                          (dqs_ififo_wpoint_0),
   .IFIFO_RADDR                          (dqs_ififo_rpoint_0),
   .DQS_DRIFT                            (dqs_drift_l),
   .DRIFT_DETECT_ERR                     (),
   .DQS_DRIFT_STATUS                     (),
    //input                              (),
   .RST                                  (buffer_dqs_rst[0]),//dqs_rst
   .CLKB                                 (buffer_dqs_clk_regional[0]),//glck
   .CLKA                                 (ioclk_01),
   .CLKA_GATE                            (ddrphy_gatei_l),
   .DELAY_STEP1                          (ddrphy_dll_step),
   .DELAY_STEP0                          (ddrphy_wl_step_l),
   .W_DIRECTION                          (ddrphy_wl_ctrl_l[2]),
   .W_MOVE                               (ddrphy_wl_ctrl_l[1]),
   .W_LOAD_N                             (ddrphy_wl_ctrl_l[0]),
   .DQS_GATE_CTRL                        ({buffer_dqs_dqs_gate_ctrl_tf2[1:0],ddrphy_dqs_gate_ctrl_l}),
   .READ_CLK_CTRL                        (ddrphy_read_clk_ctrl_l),
   .DQSI                                 (dqs_di_0),
   .GATE_IN                              (dqs_gate_to_loop_0_in),
   .R_DIRECTION                          (ddrphy_rdqs_step_l[2]),
   .R_MOVE                               (ddrphy_rdqs_step_l[1]),
   .R_LOAD_N                             (ddrphy_rdqs_step_l[0]),
   .RST_TRAINING_N                       (buffer_dqs_rst_training_n[0])
);

////////////HMEMC_TILE_6/150_52////////////
GTP_DDC_E1   dqs1_dut(
    //output
   .WDELAY_OB                            (),
   .WCLK                                 (dqs_clkw_ca_01),
   .WCLK_DELAY                           (dqs_clkw290_ca_01),
   .RCLK                                 (dqs_ca_clk_r_01),
   .RDELAY_OB                            (),
   .DQSI_DELAY                           (),
   .DGTS                                 (),
   .READ_VALID                           (),
   .GATE_OUT                             (),
   .IFIFO_WADDR                          (),
   .IFIFO_RADDR                          (),
   .DQS_DRIFT                            (),
   .DRIFT_DETECT_ERR                     (),
   .DQS_DRIFT_STATUS                     (),
    //input                              (),
   .RST                                  (buffer_dqs_rst[1]),//dqs_rst
   .CLKB                                 (buffer_dqs_clk_regional[1]),//glck
   .CLKA                                 (ioclk_01),
   .CLKA_GATE                            (buffer_dqs_gatei[0]),//(1'b1),
   .DELAY_STEP1                          (ddrphy_dll_step),//(8'b0),
   .DELAY_STEP0                          (buffer_dqs_wl_step[7:0]),//(8'b0),
   .W_DIRECTION                          (buffer_dqs_wl_ctrl[2]),//(1'b0),
   .W_MOVE                               (buffer_dqs_wl_ctrl[1]),//(1'b0),
   .W_LOAD_N                             (buffer_dqs_wl_ctrl[0]),//(1'b0),
   .DQS_GATE_CTRL                        (buffer_dqs_dqs_gate_ctrl[3:0]),//(4'b0),
   .READ_CLK_CTRL                        (buffer_dqs_read_clk_ctrl[2:0]),//(3'b0),
   .DQSI                                 (),//(1'b0),
   .GATE_IN                              (),//(),
   .R_DIRECTION                          (buffer_dqs_rdel_ctrl[2]),//(1'b0),
   .R_MOVE                               (buffer_dqs_rdel_ctrl[1]),//(1'b0),
   .R_LOAD_N                             (buffer_dqs_rdel_ctrl[0]),//(1'b0),
   .RST_TRAINING_N                       (buffer_dqs_rst_training_n[1])//()
);

////////////HMEMC_TILE_6/150_96////////////
GTP_DDC_E1   #(
   .R_EXTEND                             (R_EXTEND),
   .GATE_SEL                             (DQS_GATE_LOOP)
   )  dqs2_dut(
    //output
   .WDELAY_OB                            (ddrphy_wl_ov_h),
   .WCLK                                 (dqs_clkw_1),
   .WCLK_DELAY                           (dqs_clkw290_1),
   .RCLK                                 (dqs1_clk_r),
   .RDELAY_OB                            (ddrphy_rdel_ov_h),
   .DQSI_DELAY                           (dqs_90_1),
   .DGTS                                 (ddrphy_dgts_h),
   .READ_VALID                           (ddrphy_read_valid_h),
   .GATE_OUT                             (dqs_gate_to_loop_1),
   .IFIFO_WADDR                          (dqs_ififo_wpoint_1),
   .IFIFO_RADDR                          (dqs_ififo_rpoint_1),
   .DQS_DRIFT                            (dqs_drift_h),
   .DRIFT_DETECT_ERR                     (),
   .DQS_DRIFT_STATUS                     (),
    //input                              (),
   .RST                                  (buffer_dqs_rst[2]),//dqs_rst
   .CLKB                                 (buffer_dqs_clk_regional[2]),//glck
   .CLKA                                 (ioclk_01),
   .CLKA_GATE                            (ddrphy_gatei_h),
   .DELAY_STEP1                          (ddrphy_dll_step),
   .DELAY_STEP0                          (ddrphy_wl_step_h),
   .W_DIRECTION                          (ddrphy_wl_ctrl_h[2]),
   .W_MOVE                               (ddrphy_wl_ctrl_h[1]),
   .W_LOAD_N                             (ddrphy_wl_ctrl_h[0]),
   .DQS_GATE_CTRL                        ({buffer_dqs_dqs_gate_ctrl_tf2[3:2],ddrphy_dqs_gate_ctrl_h}),
   .READ_CLK_CTRL                        (ddrphy_read_clk_ctrl_h),
   .DQSI                                 (dqs_di_1),
   .GATE_IN                              (dqs_gate_to_loop_1_in),
   .R_DIRECTION                          (ddrphy_rdqs_step_h[2]),
   .R_MOVE                               (ddrphy_rdqs_step_h[1]),
   .R_LOAD_N                             (ddrphy_rdqs_step_h[0]),
   .RST_TRAINING_N                       (buffer_dqs_rst_training_n[2])
);

//////////////HMEMC_TILE_6/150_148////////////
GTP_DDC_E1   dqs3_dut(
    //output
   .WDELAY_OB                            (),
   .WCLK                                 (dqs_clkw_ca_03),
   .WCLK_DELAY                           (dqs_clkw290_ca_03),
   .RCLK                                 (dqs_ca_clk_r_03),
   .RDELAY_OB                            (),
   .DQSI_DELAY                           (),
   .DGTS                                 (),
   .READ_VALID                           (),
   .GATE_OUT                             (),
   .IFIFO_WADDR                          (),
   .IFIFO_RADDR                          (),
   .DQS_DRIFT                            (),
   .DRIFT_DETECT_ERR                     (),
   .DQS_DRIFT_STATUS                     (),
    //input                              (),
   .RST                                  (buffer_dqs_rst[3]),//dqs_rst
   .CLKB                                 (buffer_dqs_clk_regional[3]),//glck
   .CLKA                                 (ioclk_02),
   .CLKA_GATE                            (buffer_dqs_gatei[1]),//(1'b1),
   .DELAY_STEP1                          (ddrphy_dll_step),//(8'b0),
   .DELAY_STEP0                          (buffer_dqs_wl_step[15:8]),//(8'b0),
   .W_DIRECTION                          (buffer_dqs_wl_ctrl[5]),//(1'b0),
   .W_MOVE                               (buffer_dqs_wl_ctrl[4]),//(1'b0),
   .W_LOAD_N                             (buffer_dqs_wl_ctrl[3]),//(1'b0),
   .DQS_GATE_CTRL                        (buffer_dqs_dqs_gate_ctrl[7:4]),//(4'b0),
   .READ_CLK_CTRL                        (buffer_dqs_read_clk_ctrl[5:3]),//(3'b0),
   .DQSI                                 (),//(1'b0),
   .GATE_IN                              (),//(),
   .R_DIRECTION                          (buffer_dqs_rdel_ctrl[5]),//(1'b0),
   .R_MOVE                               (buffer_dqs_rdel_ctrl[4]),//(1'b0),
   .R_LOAD_N                             (buffer_dqs_rdel_ctrl[3]),//(1'b0),
   .RST_TRAINING_N                       (buffer_dqs_rst_training_n[3])//()
);

//////////////HMEMC_TILE_6/150_176////////////
GTP_DDC_E1   dqs4_dut(
    //output
   .WDELAY_OB                            (),
   .WCLK                                 (dqs_clkw_ca_04),
   .WCLK_DELAY                           (dqs_clkw290_ca_04),
   .RCLK                                 (dqs_ca_clk_r_04),
   .RDELAY_OB                            (),
   .DQSI_DELAY                           (),
   .DGTS                                 (),
   .READ_VALID                           (),
   .GATE_OUT                             (),
   .IFIFO_WADDR                          (),
   .IFIFO_RADDR                          (),
   .DQS_DRIFT                            (),
   .DRIFT_DETECT_ERR                     (),
   .DQS_DRIFT_STATUS                     (),
    //input                              (),
   .RST                                  (buffer_dqs_rst[4]),//dqs_rst
   .CLKB                                 (buffer_dqs_clk_regional[4]),//glck
   .CLKA                                 (ioclk_02),
   .CLKA_GATE                            (buffer_dqs_gatei[2]),//(1'b1),
   .DELAY_STEP1                          (ddrphy_dll_step),//(8'b0),
   .DELAY_STEP0                          (buffer_dqs_wl_step[23:16]),//(8'b0),
   .W_DIRECTION                          (buffer_dqs_wl_ctrl[8]),//(1'b0),
   .W_MOVE                               (buffer_dqs_wl_ctrl[7]),//(1'b0),
   .W_LOAD_N                             (buffer_dqs_wl_ctrl[6]),//(1'b0),
   .DQS_GATE_CTRL                        (buffer_dqs_dqs_gate_ctrl[11:8]),//(4'b0),
   .READ_CLK_CTRL                        (buffer_dqs_read_clk_ctrl[8:6]),//(3'b0),
   .DQSI                                 (),//(1'b0),
   .GATE_IN                              (),//(),
   .R_DIRECTION                          (buffer_dqs_rdel_ctrl[8]),//(1'b0),
   .R_MOVE                               (buffer_dqs_rdel_ctrl[7]),//(1'b0),
   .R_LOAD_N                             (buffer_dqs_rdel_ctrl[6]),//(1'b0),
   .RST_TRAINING_N                       (buffer_dqs_rst_training_n[4])//()
);

genvar i;
generate
    for(i=0; i<60; i=i+1) begin :gtp_int_dut
        GTP_INV   inv_dut(
           .Z(buffer_iol_lrs[i]),
           .I(buffer_iol_lrs_regional[i])
        );
    end
endgenerate

/////////HMEMCIOL_TILE_6/150_8///////////
GTP_OSERDES iol_oddr2_dut(
   .DO                                   (dm_do_0),
   .TQ                                   (dm_to_0),
   .DI                                   ({buffer_iol_tx_data_tf4[3:0],phy_dm_0[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[1:0],phy_ca_en[1:0]}),
   .RCLK                                 (buffer_clk_sys[2]),//glck
   .SERCLK                               (dqs0_clk_r),
   .OCLK                                 (dqs_clkw290_0),
   .RST                                  (buffer_iol_lrs[2])
);

GTP_IODELAY iol_iodelay3_dut(
   .DO                                   (iol_iddr3_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[0]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[11]),
   .MOVE                                 (buffer_iol_iodly_ctrl[10]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[9])
);

GTP_ISERDES iol_iddr3_dut(
   .DI                                   (iol_iddr3_di),   //iol_iddr3_di
   .ICLK                                 (dqs_90_0),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[3]),//glck
   .WADDR                                (dqs_ififo_wpoint_0),
   .RADDR                                (dqs_ififo_rpoint_0),
   .RST                                  (buffer_iol_lrs[3]),
   .DO                                   ({dqs_dq_r_0[3:0],dqs_dq_r_0_null[3:0]})
);

GTP_OSERDES iol_oddr3_dut(
   .DO                                   (dq_do[0]),
   .TQ                                   (dq_to[0]),
   .DI                                   ({buffer_iol_tx_data_tf4[7:4],dqs_dq_w_0[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[3:2],dqs_dq_w_en_0[1:0]}),
   .RCLK                                 (buffer_clk_sys[3]),//glck
   .SERCLK                               (dqs0_clk_r),
   .OCLK                                 (dqs_clkw290_0),
   .RST                                  (buffer_iol_lrs[3])
);

///////HMEMCIOL_TILE_6/150_12///////////
GTP_IODELAY iol_iodelay4_dut(
   .DO                                   (iol_iddr4_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[1]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[14]),
   .MOVE                                 (buffer_iol_iodly_ctrl[13]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[12])
);

GTP_ISERDES iol_iddr4_dut(
   .DI                                   (iol_iddr4_di),   //iol_iddr4_di
   .ICLK                                 (dqs_90_0),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[4]),//glck
   .WADDR                                (dqs_ififo_wpoint_0),
   .RADDR                                (dqs_ififo_rpoint_0),
   .RST                                  (buffer_iol_lrs[4]),
   .DO                                   ({dqs_dq_r_0[7:4],dqs_dq_r_0_null[7:4]})
);

GTP_OSERDES iol_oddr4_dut(
   .DO                                   (dq_do[1]),
   .TQ                                   (dq_to[1]),
   .DI                                   ({buffer_iol_tx_data_tf4[11:8],dqs_dq_w_0[7:4]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[5:4],dqs_dq_w_en_0[3:2]}),
   .RCLK                                 (buffer_clk_sys[4]),//glck
   .SERCLK                               (dqs0_clk_r),
   .OCLK                                 (dqs_clkw290_0),
   .RST                                  (buffer_iol_lrs[4])
);

GTP_IODELAY iol_iodelay5_dut(
   .DO                                   (iol_iddr5_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[2]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[17]),
   .MOVE                                 (buffer_iol_iodly_ctrl[16]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[15])
);

GTP_ISERDES iol_iddr5_dut(
   .DI                                   (iol_iddr5_di),   //iol_iddr5_di
   .ICLK                                 (dqs_90_0),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[5]),//glck
   .WADDR                                (dqs_ififo_wpoint_0),
   .RADDR                                (dqs_ififo_rpoint_0),
   .RST                                  (buffer_iol_lrs[5]),
   .DO                                   ({dqs_dq_r_0[11:8],dqs_dq_r_0_null[11:8]})
);

GTP_OSERDES iol_oddr5_dut(
   .DO                                   (dq_do[2]),
   .TQ                                   (dq_to[2]),
   .DI                                   ({buffer_iol_tx_data_tf4[15:12],dqs_dq_w_0[11:8]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[7:6],dqs_dq_w_en_0[5:4]}),
   .RCLK                                 (buffer_clk_sys[5]),//glck
   .SERCLK                               (dqs0_clk_r),
   .OCLK                                 (dqs_clkw290_0),
   .RST                                  (buffer_iol_lrs[5])
);

///////HMEMCIOL_TILE_6/150_16///////////
GTP_IODELAY iol_iodelay6_dut(
   .DO                                   (iol_iddr6_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[3]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[20]),
   .MOVE                                 (buffer_iol_iodly_ctrl[19]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[18])
);

GTP_ISERDES iol_iddr6_dut(
   .DI                                   (iol_iddr6_di),   //iol_iddr6_di
   .ICLK                                 (dqs_90_0),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[6]),//glck
   .WADDR                                (dqs_ififo_wpoint_0),
   .RADDR                                (dqs_ififo_rpoint_0),
   .RST                                  (buffer_iol_lrs[6]),
   .DO                                   ({dqs_dq_r_0[15:12],dqs_dq_r_0_null[15:12]})
);

GTP_OSERDES iol_oddr6_dut(
   .DO                                   (dq_do[3]),
   .TQ                                   (dq_to[3]),
   .DI                                   ({buffer_iol_tx_data_tf4[19:16],dqs_dq_w_0[15:12]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[9:8],dqs_dq_w_en_0[7:6]}),
   .RCLK                                 (buffer_clk_sys[6]),//glck
   .SERCLK                               (dqs0_clk_r),
   .OCLK                                 (dqs_clkw290_0),
   .RST                                  (buffer_iol_lrs[6])
);

GTP_IODELAY iol_iodelay7_dut(
   .DO                                   (iol_iddr7_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[4]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[23]),
   .MOVE                                 (buffer_iol_iodly_ctrl[22]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[21])
);

GTP_ISERDES iol_iddr7_dut(
   .DI                                   (iol_iddr7_di),   //iol_iddr7_di
   .ICLK                                 (dqs_90_0),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[7]),//glck
   .WADDR                                (dqs_ififo_wpoint_0),
   .RADDR                                (dqs_ififo_rpoint_0),
   .RST                                  (buffer_iol_lrs[7]),
   .DO                                   ({dqs_dq_r_0[19:16],dqs_dq_r_0_null[19:16]})
);

GTP_OSERDES iol_oddr7_dut(
   .DO                                   (dq_do[4]),
   .TQ                                   (dq_to[4]),
   .DI                                   ({buffer_iol_tx_data_tf4[23:20],dqs_dq_w_0[19:16]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[11:10],dqs_dq_w_en_0[9:8]}),
   .RCLK                                 (buffer_clk_sys[7]),//glck
   .SERCLK                               (dqs0_clk_r),
   .OCLK                                 (dqs_clkw290_0),
   .RST                                  (buffer_iol_lrs[7])
);

///////////HMEMCIOL_TILE_6/150_20///////////

GTP_OSERDES iol_oddr9_dut(
   .DO                                   (dqs_do_0),
   .TQ                                   (dqs_to_0),
   .DI                                   ({buffer_iol_tx_data_tf4[27:24],dqs_dqs_w_0[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[13:12],dqs_dqs_w_en_0[1:0]}),
   .RCLK                                 (buffer_clk_sys[9]),//glck
   .SERCLK                               (dqs0_clk_r),
   .OCLK                                 (dqs_clkw_0),
   .RST                                  (buffer_iol_lrs[9])
);

///////HMEMCIOL_TILE_6/150_32///////////
GTP_IODELAY iol_iodelay10_dut(
   .DO                                   (iol_iddr10_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[5]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[32]),
   .MOVE                                 (buffer_iol_iodly_ctrl[31]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[30])
);

GTP_ISERDES iol_iddr10_dut(
   .DI                                   (iol_iddr10_di),   //iol_iddr10_di
   .ICLK                                 (dqs_90_0),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[10]),//glck
   .WADDR                                (dqs_ififo_wpoint_0),
   .RADDR                                (dqs_ififo_rpoint_0),
   .RST                                  (buffer_iol_lrs[10]),
   .DO                                   ({dqs_dq_r_0[23:20],dqs_dq_r_0_null[23:20]})
);

GTP_OSERDES iol_oddr10_dut(
   .DO                                   (dq_do[5]),
   .TQ                                   (dq_to[5]),
   .DI                                   ({buffer_iol_tx_data_tf4[31:28],dqs_dq_w_0[23:20]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[15:14],dqs_dq_w_en_0[11:10]}),
   .RCLK                                 (buffer_clk_sys[10]),//glck
   .SERCLK                               (dqs0_clk_r),
   .OCLK                                 (dqs_clkw290_0),
   .RST                                  (buffer_iol_lrs[10])
);

GTP_IODELAY iol_iodelay11_dut(
   .DO                                   (iol_iddr11_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[6]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[35]),
   .MOVE                                 (buffer_iol_iodly_ctrl[34]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[33])
);

GTP_ISERDES iol_iddr11_dut(
   .DI                                   (iol_iddr11_di),   //iol_iddr11_di
   .ICLK                                 (dqs_90_0),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[11]),//glck
   .WADDR                                (dqs_ififo_wpoint_0),
   .RADDR                                (dqs_ififo_rpoint_0),
   .RST                                  (buffer_iol_lrs[11]),
   .DO                                   ({dqs_dq_r_0[27:24],dqs_dq_r_0_null[27:24]})
);

GTP_OSERDES iol_oddr11_dut(
   .DO                                   (dq_do[6]),
   .TQ                                   (dq_to[6]),
   .DI                                   ({buffer_iol_tx_data_tf4[35:32],dqs_dq_w_0[27:24]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[17:16],dqs_dq_w_en_0[13:12]}),
   .RCLK                                 (buffer_clk_sys[11]),//glck
   .SERCLK                               (dqs0_clk_r),
   .OCLK                                 (dqs_clkw290_0),
   .RST                                  (buffer_iol_lrs[11])
);

///////HMEMCIOL_TILE_6/150_36///////////
GTP_IODELAY iol_iodelay12_dut(
   .DO                                   (iol_iddr12_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[7]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[38]),
   .MOVE                                 (buffer_iol_iodly_ctrl[37]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[36])
);

GTP_ISERDES iol_iddr12_dut(
   .DI                                   (iol_iddr12_di),   //iol_iddr12_di
   .ICLK                                 (dqs_90_0),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[12]),//glck
   .WADDR                                (dqs_ififo_wpoint_0),
   .RADDR                                (dqs_ififo_rpoint_0),
   .RST                                  (buffer_iol_lrs[12]),
   .DO                                   ({dqs_dq_r_0[31:28],dqs_dq_r_0_null[31:28]})
);

GTP_OSERDES iol_oddr12_dut(
   .DO                                   (dq_do[7]),
   .TQ                                   (dq_to[7]),
   .DI                                   ({buffer_iol_tx_data_tf4[39:36],dqs_dq_w_0[31:28]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[19:18],dqs_dq_w_en_0[15:14]}),
   .RCLK                                 (buffer_clk_sys[12]),//glck
   .SERCLK                               (dqs0_clk_r),
   .OCLK                                 (dqs_clkw290_0),
   .RST                                  (buffer_iol_lrs[12])
);

///////////HMEMCIOL_TILE_6/150_40///////////
GTP_OSERDES iol_oddr17_dut(
   .DO                                   (ck_do),
   .TQ                                   (ck_to),
   .DI                                   ({buffer_iol_tx_data_tf4[43:40],phy_ck[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[21:20],phy_ca_en[3:2]}),
   .RCLK                                 (buffer_clk_sys[17]),//glck
   .SERCLK                               (dqs_ca_clk_r_01),
   .OCLK                                 (dqs_clkw_ca_01),
   .RST                                  (buffer_iol_lrs[17])
);

/////////HMEMCIOL_TILE_6/150_48///////////
GTP_OSERDES iol_oddr18_dut(
   .DO                                   (odt_do),
   .TQ                                   (odt_to),
   .DI                                   ({buffer_iol_tx_data_tf4[47:44],phy_odt[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[23:22],phy_ca_en[5:4]}),
   .RCLK                                 (buffer_clk_sys[18]),//glck
   .SERCLK                               (dqs_ca_clk_r_01),
   .OCLK                                 (dqs_clkw_ca_01),
   .RST                                  (buffer_iol_lrs[18])
);

GTP_OSERDES iol_oddr19_dut(
   .DO                                   (wen_do),
   .TQ                                   (wen_to),
   .DI                                   ({buffer_iol_tx_data_tf4[51:48],phy_we_n[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[25:24],phy_ca_en[7:6]}),
   .RCLK                                 (buffer_clk_sys[19]),//glck
   .SERCLK                               (dqs_ca_clk_r_01),
   .OCLK                                 (dqs_clkw_ca_01),
   .RST                                  (buffer_iol_lrs[19])
);

/////////HMEMCIOL_TILE_6/150_72///////////
GTP_OSERDES iol_oddr20_dut(
   .DO                                   (ba_do[0]),
   .TQ                                   (ba_to[0]),
   .DI                                   ({buffer_iol_tx_data_tf4[55:52], phy_ba[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[27:26], phy_ca_en[9:8]}),
   .RCLK                                 (buffer_clk_sys[20]),//glck
   .SERCLK                               (dqs_ca_clk_r_01),
   .OCLK                                 (dqs_clkw_ca_01),
   .RST                                  (buffer_iol_lrs[20])
);

GTP_OSERDES iol_oddr21_dut(
   .DO                                   (ba_do[1]),
   .TQ                                   (ba_to[1]),
   .DI                                   ({buffer_iol_tx_data_tf4[59:56], phy_ba[7:4]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[29:28], phy_ca_en[11:10]}),
   .RCLK                                 (buffer_clk_sys[21]),//glck
   .SERCLK                               (dqs_ca_clk_r_01),
   .OCLK                                 (dqs_clkw_ca_01),
   .RST                                  (buffer_iol_lrs[21])
);

GTP_OSERDES iol_oddr22_dut(
   .DO                                   (ba_do[2]),
   .TQ                                   (ba_to[2]),
   .DI                                   ({buffer_iol_tx_data_tf4[63:60], phy_ba[11:8]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[31:30], phy_ca_en[13:12]}),
   .RCLK                                 (buffer_clk_sys[22]),//glck
   .SERCLK                               (dqs_ca_clk_r_01),
   .OCLK                                 (dqs_clkw_ca_01),
   .RST                                  (buffer_iol_lrs[22])
);

GTP_OSERDES iol_oddr23_dut(
   .DO                                   (casn_do),
   .TQ                                   (casn_to),
   .DI                                   ({buffer_iol_tx_data_tf4[67:64], phy_cas_n[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[33:32], phy_ca_en[15:14]}),
   .RCLK                                 (buffer_clk_sys[23]),//glck
   .SERCLK                               (dqs_ca_clk_r_01),
   .OCLK                                 (dqs_clkw_ca_01),
   .RST                                  (buffer_iol_lrs[23])
);

/////////HMEMCIOL_TILE_6/150_80///////////
GTP_OSERDES iol_oddr24_dut(
   .DO                                   (rasn_do),
   .TQ                                   (rasn_to),
   .DI                                   ({buffer_iol_tx_data_tf4[71:68], phy_ras_n[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[35:34], phy_ca_en[17:16]}),
   .RCLK                                 (buffer_clk_sys[24]),//glck
   .SERCLK                               (dqs_ca_clk_r_01),
   .OCLK                                 (dqs_clkw_ca_01),
   .RST                                  (buffer_iol_lrs[24])
);

GTP_OSERDES iol_oddr25_dut(
   .DO                                   (csn_do),
   .TQ                                   (csn_to),
   .DI                                   ({buffer_iol_tx_data_tf4[75:72], phy_cs_n[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[37:36], phy_ca_en[19:18]}),
   .RCLK                                 (buffer_clk_sys[25]),//glck
   .SERCLK                               (dqs_ca_clk_r_01),
   .OCLK                                 (dqs_clkw_ca_01),
   .RST                                  (buffer_iol_lrs[25])
);

///////////HMEMCIOL_TILE_6/150_84///////////

GTP_IODELAY iol_iodelay27_dut(
   .DO                                   (iol_iddr27_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[8]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[83]),
   .MOVE                                 (buffer_iol_iodly_ctrl[82]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[81])
);

GTP_ISERDES iol_iddr27_dut(
   .DI                                   (iol_iddr27_di),   //iol_iddr27_di
   .ICLK                                 (dqs_90_1),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[27]),//glck
   .WADDR                                (dqs_ififo_wpoint_1),
   .RADDR                                (dqs_ififo_rpoint_1),
   .RST                                  (buffer_iol_lrs[27]),
   .DO                                   ({dqs_dq_r_1[3:0],dqs_dq_r_1_null[3:0]})
);

GTP_OSERDES iol_oddr27_dut(
   .DO                                   (dq_do[8]),
   .TQ                                   (dq_to[8]),
   .DI                                   ({buffer_iol_tx_data_tf4[79:76],dqs_dq_w_1[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[39:38],dqs_dq_w_en_1[1:0]}),
   .RCLK                                 (buffer_clk_sys[27]),//glck
   .SERCLK                               (dqs1_clk_r),
   .OCLK                                 (dqs_clkw290_1),
   .RST                                  (buffer_iol_lrs[27])
);

/////////HMEMCIOL_TILE_6/150_88///////////
GTP_IODELAY iol_iodelay28_dut(
   .DO                                   (iol_iddr28_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[9]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[86]),
   .MOVE                                 (buffer_iol_iodly_ctrl[85]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[84])
);

GTP_ISERDES iol_iddr28_dut(
   .DI                                   (iol_iddr28_di),   //iol_iddr28_di
   .ICLK                                 (dqs_90_1),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[28]),//glck
   .WADDR                                (dqs_ififo_wpoint_1),
   .RADDR                                (dqs_ififo_rpoint_1),
   .RST                                  (buffer_iol_lrs[28]),
   .DO                                   ({dqs_dq_r_1[7:4],dqs_dq_r_1_null[7:4]})
);

GTP_OSERDES iol_oddr28_dut(
   .DO                                   (dq_do[9]),
   .TQ                                   (dq_to[9]),
   .DI                                   ({buffer_iol_tx_data_tf4[83:80],dqs_dq_w_1[7:4]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[41:40],dqs_dq_w_en_1[3:2]}),
   .RCLK                                 (buffer_clk_sys[28]),//glck
   .SERCLK                               (dqs1_clk_r),
   .OCLK                                 (dqs_clkw290_1),
   .RST                                  (buffer_iol_lrs[28])
);

GTP_IODELAY iol_iodelay29_dut(
   .DO                                   (iol_iddr29_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[10]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[89]),
   .MOVE                                 (buffer_iol_iodly_ctrl[88]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[87])
);

GTP_ISERDES iol_iddr29_dut(
   .DI                                   (iol_iddr29_di),   //iol_iddr29_di
   .ICLK                                 (dqs_90_1),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[29]),//glck
   .WADDR                                (dqs_ififo_wpoint_1),
   .RADDR                                (dqs_ififo_rpoint_1),
   .RST                                  (buffer_iol_lrs[29]),
   .DO                                   ({dqs_dq_r_1[11:8],dqs_dq_r_1_null[11:8]})
);

GTP_OSERDES iol_oddr29_dut(
   .DO                                   (dq_do[10]),
   .TQ                                   (dq_to[10]),
   .DI                                   ({buffer_iol_tx_data_tf4[87:84],dqs_dq_w_1[11:8]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[43:42],dqs_dq_w_en_1[5:4]}),
   .RCLK                                 (buffer_clk_sys[29]),//glck
   .SERCLK                               (dqs1_clk_r),
   .OCLK                                 (dqs_clkw290_1),
   .RST                                  (buffer_iol_lrs[29])
);

///////////HMEMCIOL_TILE_6/150_100///////////

GTP_OSERDES iol_oddr31_dut(
   .DO                                   (dqs_do_1),
   .TQ                                   (dqs_to_1),
   .DI                                   ({buffer_iol_tx_data_tf4[91:88], dqs_dqs_w_1[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[45:44], dqs_dqs_w_en_1[1:0]}),
   .RCLK                                 (buffer_clk_sys[31]),//glck
   .SERCLK                               (dqs1_clk_r),
   .OCLK                                 (dqs_clkw_1),
   .RST                                  (buffer_iol_lrs[31])
);

///////HMEMCIOL_TILE_6/150_104///////////
GTP_IODELAY iol_iodelay32_dut(
   .DO                                   (iol_iddr32_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[11]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[98]),
   .MOVE                                 (buffer_iol_iodly_ctrl[97]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[96])
);

GTP_ISERDES iol_iddr32_dut(
   .DI                                   (iol_iddr32_di),   //iol_iddr32_di
   .ICLK                                 (dqs_90_1),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[32]),//glck
   .WADDR                                (dqs_ififo_wpoint_1),
   .RADDR                                (dqs_ififo_rpoint_1),
   .RST                                  (buffer_iol_lrs[32]),
   .DO                                   ({dqs_dq_r_1[15:12],dqs_dq_r_1_null[15:12]})
);

GTP_OSERDES iol_oddr32_dut(
   .DO                                   (dq_do[11]),
   .TQ                                   (dq_to[11]),
   .DI                                   ({buffer_iol_tx_data_tf4[95:92], dqs_dq_w_1[15:12]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[47:46], dqs_dq_w_en_1[7:6]}),
   .RCLK                                 (buffer_clk_sys[32]),//glck
   .SERCLK                               (dqs1_clk_r),
   .OCLK                                 (dqs_clkw290_1),
   .RST                                  (buffer_iol_lrs[32])
);

GTP_IODELAY iol_iodelay33_dut(
   .DO                                   (iol_iddr33_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[12]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[101]),
   .MOVE                                 (buffer_iol_iodly_ctrl[100]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[99])
);

GTP_ISERDES iol_iddr33_dut(
   .DI                                   (iol_iddr33_di),   //iol_iddr33_di
   .ICLK                                 (dqs_90_1),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[33]),//glck
   .WADDR                                (dqs_ififo_wpoint_1),
   .RADDR                                (dqs_ififo_rpoint_1),
   .RST                                  (buffer_iol_lrs[33]),
   .DO                                   ({dqs_dq_r_1[19:16],dqs_dq_r_1_null[19:16]})
);

GTP_OSERDES iol_oddr33_dut(
   .DO                                   (dq_do[12]),
   .TQ                                   (dq_to[12]),
   .DI                                   ({buffer_iol_tx_data_tf4[99:96], dqs_dq_w_1[19:16]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[49:48], dqs_dq_w_en_1[9:8]}),
   .RCLK                                 (buffer_clk_sys[33]),//glck
   .SERCLK                               (dqs1_clk_r),
   .OCLK                                 (dqs_clkw290_1),
   .RST                                  (buffer_iol_lrs[33])
);

///////HMEMCIOL_TILE_6/150_108///////////
GTP_IODELAY iol_iodelay34_dut(
   .DO                                   (iol_iddr34_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[13]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[104]),
   .MOVE                                 (buffer_iol_iodly_ctrl[103]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[102])
);

GTP_ISERDES iol_iddr34_dut(
   .DI                                   (iol_iddr34_di),   //iol_iddr34_di
   .ICLK                                 (dqs_90_1),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[34]),//glck
   .WADDR                                (dqs_ififo_wpoint_1),
   .RADDR                                (dqs_ififo_rpoint_1),
   .RST                                  (buffer_iol_lrs[34]),
   .DO                                   ({dqs_dq_r_1[23:20],dqs_dq_r_1_null[23:20]})
);

GTP_OSERDES iol_oddr34_dut(
   .DO                                   (dq_do[13]),
   .TQ                                   (dq_to[13]),
   .DI                                   ({buffer_iol_tx_data_tf4[103:100], dqs_dq_w_1[23:20]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[51:50], dqs_dq_w_en_1[11:10]}),
   .RCLK                                 (buffer_clk_sys[34]),//glck
   .SERCLK                               (dqs1_clk_r),
   .OCLK                                 (dqs_clkw290_1),
   .RST                                  (buffer_iol_lrs[34])
);

GTP_IODELAY iol_iodelay35_dut(
   .DO                                   (iol_iddr35_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[14]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[107]),
   .MOVE                                 (buffer_iol_iodly_ctrl[106]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[105])
);

GTP_ISERDES iol_iddr35_dut(
   .DI                                   (iol_iddr35_di),   //iol_iddr35_di
   .ICLK                                 (dqs_90_1),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[35]),//glck
   .WADDR                                (dqs_ififo_wpoint_1),
   .RADDR                                (dqs_ififo_rpoint_1),
   .RST                                  (buffer_iol_lrs[35]),
   .DO                                   ({dqs_dq_r_1[27:24],dqs_dq_r_1_null[27:24]})
);

GTP_OSERDES iol_oddr35_dut(
   .DO                                   (dq_do[14]),
   .TQ                                   (dq_to[14]),
   .DI                                   ({buffer_iol_tx_data_tf4[107:104], dqs_dq_w_1[27:24]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[53:52], dqs_dq_w_en_1[13:12]}),
   .RCLK                                 (buffer_clk_sys[35]),//glck
   .SERCLK                               (dqs1_clk_r),
   .OCLK                                 (dqs_clkw290_1),
   .RST                                  (buffer_iol_lrs[35])
);

///////HMEMCIOL_TILE_6/150_112///////////
GTP_IODELAY iol_iodelay36_dut(
   .DO                                   (iol_iddr36_di),
   .DELAY_OB                             (),
   .DI                                   (dq_di[15]),
   .LOAD_N                               (buffer_iol_iodly_ctrl[110]),
   .MOVE                                 (buffer_iol_iodly_ctrl[109]),
   .DIRECTION                            (buffer_iol_iodly_ctrl[108])
);

GTP_ISERDES iol_iddr36_dut(
   .DI                                   (iol_iddr36_di),   //iol_iddr36_di
   .ICLK                                 (dqs_90_1),
   .DESCLK                               (ioclk_01),
   .RCLK                                 (buffer_clk_sys[36]),//glck
   .WADDR                                (dqs_ififo_wpoint_1),
   .RADDR                                (dqs_ififo_rpoint_1),
   .RST                                  (buffer_iol_lrs[36]),
   .DO                                   ({dqs_dq_r_1[31:28],dqs_dq_r_1_null[31:28]})
);

GTP_OSERDES iol_oddr36_dut(
   .DO                                   (dq_do[15]),
   .TQ                                   (dq_to[15]),
   .DI                                   ({buffer_iol_tx_data_tf4[111:108], dqs_dq_w_1[31:28]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[55:54], dqs_dq_w_en_1[15:14]}),
   .RCLK                                 (buffer_clk_sys[36]),//glck
   .SERCLK                               (dqs1_clk_r),
   .OCLK                                 (dqs_clkw290_1),
   .RST                                  (buffer_iol_lrs[36])
);

GTP_OSERDES iol_oddr37_dut(
   .DO                                   (dm_do_1),
   .TQ                                   (dm_to_1),
   .DI                                   ({buffer_iol_tx_data_tf4[115:112], phy_dm_1[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[57:56], phy_ca_en[21:20]}),
   .RCLK                                 (buffer_clk_sys[37]),//glck
   .SERCLK                               (dqs1_clk_r),
   .OCLK                                 (dqs_clkw290_1),
   .RST                                  (buffer_iol_lrs[37])
);


///////////HMEMCIOL_TILE_6/150_128///////////


GTP_OSERDES iol_oddr40_dut(
   .DO                                   (addr_do[0]),
   .TQ                                   (addr_to[0]),
   .DI                                   ({buffer_iol_tx_data_tf4[119:116], phy_addr[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[59:58], phy_ca_en[23:22]}),
   .RCLK                                 (buffer_clk_sys[40]),//glck
   .SERCLK                               (dqs_ca_clk_r_03),
   .OCLK                                 (dqs_clkw_ca_03),
   .RST                                  (buffer_iol_lrs[40])
);



GTP_OSERDES iol_oddr41_dut(
   .DO                                   (addr_do[1]),
   .TQ                                   (addr_to[1]),
   .DI                                   ({buffer_iol_tx_data_tf4[123:120], phy_addr[7:4]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[61:60], phy_ca_en[25:24]}),
   .RCLK                                 (buffer_clk_sys[41]),//glck
   .SERCLK                               (dqs_ca_clk_r_03),
   .OCLK                                 (dqs_clkw_ca_03),
   .RST                                  (buffer_iol_lrs[41])
);

/////////HMEMCIOL_TILE_6/150_132///////////


GTP_OSERDES iol_oddr42_dut(
   .DO                                   (addr_do[2]),
   .TQ                                   (addr_to[2]),
   .DI                                   ({buffer_iol_tx_data_tf4[127:124], phy_addr[11:8]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[63:62], phy_ca_en[27:26]}),
   .RCLK                                 (buffer_clk_sys[42]),//glck
   .SERCLK                               (dqs_ca_clk_r_03),
   .OCLK                                 (dqs_clkw_ca_03),
   .RST                                  (buffer_iol_lrs[42])
);

GTP_OSERDES iol_oddr43_dut(
   .DO                                   (addr_do[3]),
   .TQ                                   (addr_to[3]),
   .DI                                   ({buffer_iol_tx_data_tf4[131:128], phy_addr[15:12]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[65:64], phy_ca_en[29:28]}),
   .RCLK                                 (buffer_clk_sys[43]),//glck
   .SERCLK                               (dqs_ca_clk_r_03),
   .OCLK                                 (dqs_clkw_ca_03),
   .RST                                  (buffer_iol_lrs[43])
);

/////////HMEMCIOL_TILE_6/150_136///////////


GTP_OSERDES iol_oddr44_dut(
   .DO                                   (addr_do[4]),
   .TQ                                   (addr_to[4]),
   .DI                                   ({buffer_iol_tx_data_tf4[135:132], phy_addr[19:16]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[67:66], phy_ca_en[31:30]}),
   .RCLK                                 (buffer_clk_sys[44]),//glck
   .SERCLK                               (dqs_ca_clk_r_03),
   .OCLK                                 (dqs_clkw_ca_03),
   .RST                                  (buffer_iol_lrs[44])
);

GTP_OSERDES iol_oddr45_dut(
   .DO                                   (addr_do[5]),
   .TQ                                   (addr_to[5]),
   .DI                                   ({buffer_iol_tx_data_tf4[139:136], phy_addr[23:20]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[69:68], phy_ca_en[33:32]}),
   .RCLK                                 (buffer_clk_sys[45]),//glck
   .SERCLK                               (dqs_ca_clk_r_03),
   .OCLK                                 (dqs_clkw_ca_03),
   .RST                                  (buffer_iol_lrs[45])
);

/////////HMEMCIOL_TILE_6/150_140///////////
GTP_OSERDES iol_oddr46_dut(
   .DO                                   (addr_do[6]),
   .TQ                                   (addr_to[6]),
   .DI                                   ({buffer_iol_tx_data_tf4[143:140], phy_addr[27:24]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[71:70], phy_ca_en[35:34]}),
   .RCLK                                 (buffer_clk_sys[46]),//glck
   .SERCLK                               (dqs_ca_clk_r_03),
   .OCLK                                 (dqs_clkw_ca_03),
   .RST                                  (buffer_iol_lrs[46])
);
GTP_OSERDES iol_oddr47_dut(
   .DO                                   (addr_do[7]),
   .TQ                                   (addr_to[7]),
   .DI                                   ({buffer_iol_tx_data_tf4[147:144], phy_addr[31:28]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[73:72], phy_ca_en[37:36]}),
   .RCLK                                 (buffer_clk_sys[47]),//glck
   .SERCLK                               (dqs_ca_clk_r_03),
   .OCLK                                 (dqs_clkw_ca_03),
   .RST                                  (buffer_iol_lrs[47])
);

/////////HMEMCIOL_TILE_6/150_144///////////
GTP_OSERDES iol_oddr48_dut(
   .DO                                   (cke_do),
   .TQ                                   (cke_to),
   .DI                                   ({buffer_iol_tx_data_tf4[151:148], phy_cke[3:0]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[75:74], phy_ca_en[39:38]}),
   .RCLK                                 (buffer_clk_sys[48]),//glck
   .SERCLK                               (dqs_ca_clk_r_03),
   .OCLK                                 (dqs_clkw_ca_03),
   .RST                                  (buffer_iol_lrs[48])
);

GTP_OSERDES iol_oddr49_dut(
   .DO                                   (addr_do[8]),
   .TQ                                   (addr_to[8]),
   .DI                                   ({buffer_iol_tx_data_tf4[155:152], phy_addr[35:32]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[77:76], phy_ca_en[41:40]}),
   .RCLK                                 (buffer_clk_sys[49]),//glck
   .SERCLK                               (dqs_ca_clk_r_03),
   .OCLK                                 (dqs_clkw_ca_03),
   .RST                                  (buffer_iol_lrs[49])
);

/////////HMEMCIOL_TILE_6/150_156///////////

GTP_OSERDES iol_oddr51_dut(
   .DO                                   (addr_do[9]),
   .TQ                                   (addr_to[9]),
   .DI                                   ({buffer_iol_tx_data_tf4[159:156], phy_addr[39:36]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[79:78], phy_ca_en[43:42]}),
   .RCLK                                 (buffer_clk_sys[51]),//glck
   .SERCLK                               (dqs_ca_clk_r_03),
   .OCLK                                 (dqs_clkw_ca_03),
   .RST                                  (buffer_iol_lrs[51])
);

/////////HMEMCIOL_TILE_6/150_160///////////
GTP_OSERDES iol_oddr52_dut(
   .DO                                   (addr_do[10]),
   .TQ                                   (addr_to[10]),
   .DI                                   ({buffer_iol_tx_data_tf4[163:160], phy_addr[43:40]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[81:80], phy_ca_en[45:44]}),
   .RCLK                                 (buffer_clk_sys[52]),//glck
   .SERCLK                               (dqs_ca_clk_r_03),
   .OCLK                                 (dqs_clkw_ca_03),
   .RST                                  (buffer_iol_lrs[52])
);

/////////HMEMCIOL_TILE_6/150_164///////////


GTP_OSERDES iol_oddr55_dut(
   .DO                                   (addr_do[11]),
   .TQ                                   (addr_to[11]),
   .DI                                   ({buffer_iol_tx_data_tf4[167:164], phy_addr[47:44]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[83:82], phy_ca_en[47:46]}),
   .RCLK                                 (buffer_clk_sys[55]),//glck
   .SERCLK                               (dqs_ca_clk_r_04),
   .OCLK                                 (dqs_clkw_ca_04),
   .RST                                  (buffer_iol_lrs[55])
);

/////////HMEMCIOL_TILE_6/150_168///////////
GTP_OSERDES iol_oddr56_dut(
   .DO                                   (addr_do[12]),
   .TQ                                   (addr_to[12]),
   .DI                                   ({buffer_iol_tx_data_tf4[171:168], phy_addr[51:48]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[85:84], phy_ca_en[49:48]}),
   .RCLK                                 (buffer_clk_sys[56]),//glck
   .SERCLK                               (dqs_ca_clk_r_04),
   .OCLK                                 (dqs_clkw_ca_04),
   .RST                                  (buffer_iol_lrs[56])
);
GTP_OSERDES iol_oddr57_dut(
   .DO                                   (addr_do[13]),
   .TQ                                   (addr_to[13]),
   .DI                                   ({buffer_iol_tx_data_tf4[175:172], phy_addr[55:52]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[87:86], phy_ca_en[51:50]}),
   .RCLK                                 (buffer_clk_sys[57]),//glck
   .SERCLK                               (dqs_ca_clk_r_04),
   .OCLK                                 (dqs_clkw_ca_04),
   .RST                                  (buffer_iol_lrs[57])
);

/////////HMEMCIOL_TILE_6/150_172///////////
GTP_OSERDES iol_oddr58_dut(
   .DO                                   (addr_do[14]),
   .TQ                                   (addr_to[14]),
   .DI                                   ({buffer_iol_tx_data_tf4[179:176], phy_addr[59:56]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[89:88], phy_ca_en[53:52]}),
   .RCLK                                 (buffer_clk_sys[58]),//glck
   .SERCLK                               (dqs_ca_clk_r_04),
   .OCLK                                 (dqs_clkw_ca_04),
   .RST                                  (buffer_iol_lrs[58])
);



GTP_OSERDES iol_oddr59_dut(
   .DO                                   (addr_do[15]),
   .TQ                                   (addr_to[15]),
   .DI                                   ({buffer_iol_tx_data_tf4[183:180], phy_addr[63:60]}),
   .TI                                   ({buffer_iol_ts_ctrl_tf2[91:90], phy_ca_en[55:54]}),
   .RCLK                                 (buffer_clk_sys[59]),//glck
   .SERCLK                               (dqs_ca_clk_r_04),
   .OCLK                                 (dqs_clkw_ca_04),
   .RST                                  (buffer_iol_lrs[59])
);

GTP_INBUFG iob_00_dut(
   .O(dqs_gate_to_loop_0_in),
   .I(pad_loop_in)   //IOB_TILE0_PAD[39]
);

GTP_OUTBUF iob_01_dut(
   .O(pad_loop_out),   //IOB_TILE0_PAD[38]
   .I(dqs_gate_to_loop_0)
);

GTP_OUTBUFT iob_02_dut(
   .O                                    (pad_dm_rdqs_ch0[0]),   //IOB_TILE0_PAD[37]
   .I                                    (dm_do_0),
   .T                                    (dm_to_0)
);

GTP_IOBUF iob_03_dut(
   .O                                    (dq_di[0]),
   .IO                                   (pad_dq_ch0[0]),   //IOB_TILE0_PAD[36]
   .I                                    (dq_do[0]),
   .T                                    (dq_to[0])
);

GTP_IOBUF iob_04_dut(
   .O                                    (dq_di[1]),
   .IO                                   (pad_dq_ch0[1]),   //IOB_TILE0_PAD[35]
   .I                                    (dq_do[1]),
   .T                                    (dq_to[1])
);

GTP_IOBUF iob_05_dut(
   .O                                    (dq_di[2]),
   .IO                                   (pad_dq_ch0[2]),   //IOB_TILE0_PAD[34]
   .I                                    (dq_do[2]),
   .T                                    (dq_to[2])
);

GTP_IOBUF iob_06_dut(
   .O                                    (dq_di[3]),
   .IO                                   (pad_dq_ch0[3]),   //IOB_TILE0_PAD[33]
   .I                                    (dq_do[3]),
   .T                                    (dq_to[3])
);

GTP_IOBUF iob_07_dut(
   .O                                    (dq_di[4]),
   .IO                                   (pad_dq_ch0[4]),   //IOB_TILE0_PAD[32]
   .I                                    (dq_do[4]),
   .T                                    (dq_to[4])
);

generate
if (DDR_TYPE == "LPDDR") begin
GTP_IOBUF iob_08_09_dut(
   .O                                    (dqs_di_0),
   .IO                                   (pad_dqs_ch0[0]),   //IOB_TILE0_PAD[30]
   .I                                    (dqs_do_0),
   .T                                    (dqs_to_0)
);
end
else begin    
GTP_IOBUFCO iob_08_09_dut(
   .O                                    (dqs_di_0),
   .IO                                   (pad_dqs_ch0[0]),   //IOB_TILE0_PAD[30]
   .IOB                                  (pad_dqsn_ch0[0]),   //IOB_TILE0_PAD[31]
   .I                                    (dqs_do_0),
   .T                                    (dqs_to_0)
);
end
endgenerate

GTP_IOBUF iob_10_dut(
   .O                                    (dq_di[5]),
   .IO                                   (pad_dq_ch0[5]),   //IOB_TILE0_PAD[29]
   .I                                    (dq_do[5]),
   .T                                    (dq_to[5])
);


GTP_IOBUF iob_11_dut(
   .O                                    (dq_di[6]),
   .IO                                   (pad_dq_ch0[6]),   //IOB_TILE0_PAD[28]
   .I                                    (dq_do[6]),
   .T                                    (dq_to[6])
);


GTP_IOBUF iob_12_dut(
   .O                                    (dq_di[7]),
   .IO                                   (pad_dq_ch0[7]),   //IOB_TILE0_PAD[27]
   .I                                    (dq_do[7]),
   .T                                    (dq_to[7])
);


GTP_OUTBUFTCO iob_16_17_dut(
   .O                                    (pad_ddr_clk_w),   //IOB_TILE0_PAD[22]
   .OB                                   (pad_ddr_clkn_w),   //IOB_TILE0_PAD[23]
   .I                                    (ck_do),
   .T                                    (ck_to)
);


GTP_OUTBUFT iob_18_dut(
   .O                                    (pad_odt_ch0),   //IOB_TILE0_PAD[21]
   .I                                    (odt_do),
   .T                                    (odt_to)
);


GTP_OUTBUFT iob_19_dut(
   .O                                    (pad_wen_ch0),   //IOB_TILE0_PAD[20]
   .I                                    (wen_do),
   .T                                    (wen_to)
);


GTP_OUTBUFT iob_20_dut(
   .O                                    (pad_ba_ch0[0]),   //IOB_TILE0_PAD[19]
   .I                                    (ba_do[0]),
   .T                                    (ba_to[0])
);


GTP_OUTBUFT iob_21_dut(
   .O                                    (pad_ba_ch0[1]),   //IOB_TILE0_PAD[18]
   .I                                    (ba_do[1]),
   .T                                    (ba_to[1])
);


GTP_OUTBUFT iob_22_dut(
   .O                                    (pad_ba_ch0[2]),   //IOB_TILE0_PAD[17]
   .I                                    (ba_do[2]),
   .T                                    (ba_to[2])
);


GTP_OUTBUFT iob_23_dut(
   .O                                    (pad_casn_ch0),   //IOB_TILE0_PAD[16]
   .I                                    (casn_do),
   .T                                    (casn_to)
);


GTP_OUTBUFT iob_24_dut(
   .O                                    (pad_rasn_ch0),   //IOB_TILE0_PAD[15]
   .I                                    (rasn_do),
   .T                                    (rasn_to)
);


GTP_OUTBUFT iob_25_dut(
   .O                                    (pad_csn_ch0),   //IOB_TILE0_PAD[14]
   .I                                    (csn_do),
   .T                                    (csn_to)
);


GTP_IOBUF iob_27_dut(
   .O                                    (dq_di[8]),
   .IO                                   (pad_dq_ch0[8]),   //IOB_TILE0_PAD[12]
   .I                                    (dq_do[8]),
   .T                                    (dq_to[8])
);


GTP_IOBUF iob_28_dut(
   .O                                    (dq_di[9]),
   .IO                                   (pad_dq_ch0[9]),   //IOB_TILE0_PAD[11]
   .I                                    (dq_do[9]),
   .T                                    (dq_to[9])
);


GTP_IOBUF iob_29_dut(
   .O                                    (dq_di[10]),
   .IO                                   (pad_dq_ch0[10]),   //IOB_TILE0_PAD[10]
   .I                                    (dq_do[10]),
   .T                                    (dq_to[10])
);

generate
if (DDR_TYPE == "LPDDR") begin
GTP_IOBUF iob_30_31_dut(
   .O                                    (dqs_di_1),
   .IO                                   (pad_dqs_ch0[1]),   //IOB_TILE0_PAD[30]
   .I                                    (dqs_do_1),
   .T                                    (dqs_to_1)
);
end
else begin
GTP_IOBUFCO iob_30_31_dut(
   .O                                    (dqs_di_1),
   .IO                                   (pad_dqs_ch0[1]),   //IOB_TILE0_PAD[8]
   .IOB                                  (pad_dqsn_ch0[1]),   //IOB_TILE0_PAD[9]
   .I                                    (dqs_do_1),
   .T                                    (dqs_to_1)
);
end
endgenerate


GTP_IOBUF iob_32_dut(
   .O                                    (dq_di[11]),
   .IO                                   (pad_dq_ch0[11]),   //IOB_TILE0_PAD[7]
   .I                                    (dq_do[11]),
   .T                                    (dq_to[11])
);


GTP_IOBUF iob_33_dut(
   .O                                    (dq_di[12]),
   .IO                                   (pad_dq_ch0[12]),   //IOB_TILE0_PAD[6]
   .I                                    (dq_do[12]),
   .T                                    (dq_to[12])
);


GTP_IOBUF iob_34_dut(
   .O                                    (dq_di[13]),
   .IO                                   (pad_dq_ch0[13]),   //IOB_TILE0_PAD[5]
   .I                                    (dq_do[13]),
   .T                                    (dq_to[13])
);


GTP_IOBUF iob_35_dut(
   .O                                    (dq_di[14]),
   .IO                                   (pad_dq_ch0[14]),   //IOB_TILE0_PAD[4]
   .I                                    (dq_do[14]),
   .T                                    (dq_to[14])
);


GTP_IOBUF iob_36_dut(
   .O                                    (dq_di[15]),
   .IO                                   (pad_dq_ch0[15]),   //IOB_TILE0_PAD[3]
   .I                                    (dq_do[15]),
   .T                                    (dq_to[15])
);


GTP_OUTBUFT iob_37_dut(
   .O                                    (pad_dm_rdqs_ch0[1]),   //IOB_TILE0_PAD[2]
   .I                                    (dm_do_1),
   .T                                    (dm_to_1)
);


GTP_INBUFG iob_38_dut(
   .O(dqs_gate_to_loop_1_in),
   .I(pad_loop_in_h)   //IOB_TILE0_PAD[1]
);


GTP_OUTBUF iob_39_dut(
   .O(pad_loop_out_h),   //IOB_TILE0_PAD[0]
   .I(dqs_gate_to_loop_1)
);


GTP_OUTBUFT iob_40_dut(
   .O                                   (pad_addr_ch0[0]),   //IOB_TILE124_PAD[38]
   .I                                   (addr_do[0]),
   .T                                   (addr_to[0])
);


GTP_OUTBUFT iob_41_dut(
   .O                                    (pad_addr_ch0[1]),   //IOB_TILE124_PAD[37]
   .I                                    (addr_do[1]),
   .T                                    (addr_to[1])
);


GTP_OUTBUFT iob_42_dut(
   .O                                    (pad_addr_ch0[2]),   //IOB_TILE124_PAD[36]
   .I                                    (addr_do[2]),
   .T                                    (addr_to[2])
);


GTP_OUTBUFT iob_43_dut(
   .O                                    (pad_addr_ch0[3]),   //IOB_TILE124_PAD[35]
   .I                                    (addr_do[3]),
   .T                                    (addr_to[3])
);


GTP_OUTBUFT iob_44_dut(
   .O                                    (pad_addr_ch0[4]),   //IOB_TILE124_PAD[34]
   .I                                    (addr_do[4]),
   .T                                    (addr_to[4])
);


GTP_OUTBUFT iob_45_dut(
   .O                                    (pad_addr_ch0[5]),   //IOB_TILE124_PAD[33]
   .I                                    (addr_do[5]),
   .T                                    (addr_to[5])
);


GTP_OUTBUFT iob_46_dut(
   .O                                    (pad_addr_ch0[6]),   //IOB_TILE124_PAD[32]
   .I                                    (addr_do[6]),
   .T                                    (addr_to[6])
);


GTP_OUTBUFT iob_47_dut(
   .O                                    (pad_addr_ch0[7]),   //IOB_TILE124_PAD[31]
   .I                                    (addr_do[7]),
   .T                                    (addr_to[7])
);


GTP_OUTBUFT iob_48_dut(
   .O                                    (pad_cke_ch0),   //IOB_TILE124_PAD[30]
   .I                                    (cke_do),
   .T                                    (cke_to)
);


GTP_OUTBUFT iob_49_dut(
   .O                                    (pad_addr_ch0[8]),   //IOB_TILE124_PAD[29]
   .I                                    (addr_do[8]),
   .T                                    (addr_to[8])
);


GTP_OUTBUFT iob_50_dut(
   .O                                    (pad_rstn_ch0),   //IOB_TILE124_PAD[28]
   .I                                    (phy_reset_n),    //resetn_do
   .T                                    (buffer_mem_rst_en)    //resetn_to
);


GTP_OUTBUFT iob_51_dut(
   .O                                    (pad_addr_ch0[9]),   //IOB_TILE124_PAD[27]
   .I                                    (addr_do[9]),
   .T                                    (addr_to[9])
);


GTP_OUTBUFT iob_52_dut(
   .O                                    (pad_addr_ch0[10]),   //IOB_TILE124_PAD[26]
   .I                                    (addr_do[10]),
   .T                                    (addr_to[10])
);


GTP_OUTBUFT iob_55_dut(
   .O                                    (pad_addr_ch0[11]),   //IOB_TILE124_PAD[25]
   .I                                    (addr_do[11]),
   .T                                    (addr_to[11])
);


GTP_OUTBUFT iob_56_dut(
   .O                                    (pad_addr_ch0[12]),   //IOB_TILE124_PAD[24]
   .I                                    (addr_do[12]),
   .T                                    (addr_to[12])
);


GTP_OUTBUFT iob_57_dut(
   .O                                    (pad_addr_ch0[13]),   //IOB_TILE124_PAD[23]
   .I                                    (addr_do[13]),
   .T                                    (addr_to[13])
);


GTP_OUTBUFT iob_58_dut(
   .O                                    (pad_addr_ch0[14]),   //IOB_TILE124_PAD[22]
   .I                                    (addr_do[14]),
   .T                                    (addr_to[14])
);


GTP_OUTBUFT iob_59_dut(
   .O                                    (pad_addr_ch0[15]),   //IOB_TILE124_PAD[21]
   .I                                    (addr_do[15]),
   .T                                    (addr_to[15])
);

assign phy_dm_0        =    ddrphy_dm_l;
assign phy_ca_en       =    ddrphy_ca_en;
assign ddrphy_rdata_l  =    dqs_dq_r_0;
assign dqs_dq_w_0      =    ddrphy_wdata_l;
assign dqs_dq_w_en_0   =    ddrphy_wen_l;
assign dqs_dqs_w_0     =    ddrphy_wdqs_l;
assign dqs_dqs_w_en_0  =    ddrphy_wdqs_en_l;
assign phy_ck          =    ddrphy_ck;
assign phy_odt         =    ddrphy_odt;
assign phy_we_n        =    ddrphy_we_n;
assign phy_ba          =    ddrphy_ba;
assign phy_cas_n       =    ddrphy_cas_n;
assign phy_ras_n       =    ddrphy_ras_n;
assign phy_cs_n        =    ddrphy_cs_n;
assign ddrphy_rdata_h  =    dqs_dq_r_1;
assign dqs_dq_w_1      =    ddrphy_wdata_h;
assign dqs_dq_w_en_1   =    ddrphy_wen_h;
assign dqs_dqs_w_1     =    ddrphy_wdqs_h;
assign dqs_dqs_w_en_1  =    ddrphy_wdqs_en_h;
assign phy_dm_1        =    ddrphy_dm_h;
assign phy_addr        =    ddrphy_addr;
assign phy_cke         =    ddrphy_cke;
assign phy_reset_n     =    ddrphy_mem_rst;

assign ddrphy_dq_h     =    {iol_iddr36_di,iol_iddr35_di,iol_iddr34_di,iol_iddr33_di,iol_iddr32_di,iol_iddr29_di,iol_iddr28_di,iol_iddr27_di};
assign ddrphy_dq_l     =    {iol_iddr12_di,iol_iddr11_di,iol_iddr10_di,iol_iddr7_di,iol_iddr6_di,iol_iddr5_di,iol_iddr4_di,iol_iddr3_di};

endmodule

