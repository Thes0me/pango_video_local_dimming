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

module ipsl_hmic_h_phy_top_v1_1 #(
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
    parameter     integer     PHY_TMRD                  =0,        //0~3
    parameter     integer     PHY_TMOD                  =0,        //0~7 
    parameter     integer     PHY_TZQINIT               =0,        //0~1023
    parameter     integer     PHY_TXPR                  =0,        //0~15
    parameter     integer     PHY_TRP                   =0,        //0~7
    parameter     integer     PHY_TRFC                  =0,        //0~255
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
    parameter     [7:0]       PHY_TXS                   =8'h0 ,
    parameter                 WL_SETTING                =1'b1 ,
    parameter                 WCLK_DEL_SEL              =1'b0 ,
    parameter     [7:0]       INIT_WRLVL_STEP_L         =8'h0 ,
    parameter     [7:0]       INIT_WRLVL_STEP_H         =8'h0
)(
    input                top_rst_n      ,
    input                logic_clk      ,
    input                pll_lock       ,
    input                ddrc_init_done ,
    input                phy_clk        ,
    input                phy_pclk       ,
    input                phy_preset     ,
    input[11:0]          phy_paddr      ,
    input[31:0]          phy_pwdata     ,
    input                phy_pwrite     ,
    input                phy_penable    ,
    output               pll_phy_clk_gate,    
    output               ddrc_core_clk  ,
    output wire          global_reset_n  ,
    output               ddrphy_rst_done,    

    output               dfi_error         ,            
    output  [2:0]        dfi_error_info    ,       
    output  [63:0]       dfi_rddata        ,           
    output  [3:0]        dfi_rddata_valid  ,     
    output               dfi_ctrlupd_ack   ,      
    output               dfi_init_complete ,    
    output               dfi_phyupd_req    ,       
    output  [1:0]        dfi_phyupd_type   ,      
    output               dfi_lp_ack        ,           
    input   [31:0]       dfi_address       ,          
    input   [5:0]        dfi_bank          ,             
    input   [1:0]        dfi_cas_n         ,            
    input   [1:0]        dfi_ras_n         ,            
    input   [1:0]        dfi_we_n          ,             
    input   [1:0]        dfi_cke           ,              
    input   [1:0]        dfi_cs            ,               
    input   [1:0]        dfi_odt           ,              
    input   [1:0]        dfi_reset_n       ,          
    input   [63:0]       dfi_wrdata        ,           
    input   [7:0]        dfi_wrdata_mask   ,      
    input   [3:0]        dfi_wrdata_en     ,        
    input   [3:0]        dfi_rddata_en     ,        
    input                dfi_ctrlupd_req   ,      
    input                dfi_dram_clk_disable, 
    input                dfi_init_start    ,       
    input   [4:0]        dfi_frequency     ,        
    input                dfi_phyupd_ack    ,       
    input                dfi_lp_req        ,           
    input   [3:0]        dfi_lp_wakeup     ,            
    input                pad_loop_in    ,
    input                pad_loop_in_h  ,
    output               pad_rstn_ch0   ,
    output               pad_ddr_clk_w  ,
    output               pad_ddr_clkn_w ,
    output               pad_csn_ch0    ,
    output [15:0]        pad_addr_ch0   ,
    inout  [16-1:0]      pad_dq_ch0     ,
    inout  [16/8-1:0]    pad_dqs_ch0    ,
    inout  [16/8-1:0]    pad_dqsn_ch0   ,
    output [16/8-1:0]    pad_dm_rdqs_ch0,
    output               pad_cke_ch0    ,
    output               pad_odt_ch0    ,
    output               pad_rasn_ch0   ,
    output               pad_casn_ch0   ,
    output               pad_wen_ch0    ,
    output [2:0]         pad_ba_ch0     ,
    output               pad_loop_out   ,
    output               pad_loop_out_h 
);

localparam UPDATE_MASK = (DQS_GATE_LOOP == "TRUE") ? 3'b000 : 3'b010;

wire           dll_lock;
wire           dll_update_req_rst_ctrl;
wire           dll_update_ack_rst_ctrl;
wire           srb_rst_dll;
wire           dll_update_n;
wire           srb_dll_freeze;
wire           ddrphy_rst;
wire           srb_iol_rst;
wire           srb_dqs_rstn;
wire           srb_ioclkdiv_rstn;
wire           ddrphy_rst_req;   
wire           ddrphy_rst_ack;
wire           srb_dqs_rst_training;
wire           dll_update_req;
wire           dll_update_ack;
wire  [7:0]    dll_step_copy;
wire  [1:0]    dqs_drift_l;
wire  [1:0]    dqs_drift_h;
wire  [1:0]    ddrphy_update_comp_val_l;
wire           ddrphy_update_comp_dir_l;
wire  [1:0]    ddrphy_update_comp_val_h;
wire           ddrphy_update_comp_dir_h;
wire  [1:0]    ddrphy_update_type; 
wire           update_start;
wire           ddrphy_update_done;
wire           dll_update_iorst_req;
wire           dll_update_iorst_ack;
   
assign pll_phy_clk_gate = ~srb_ioclkdiv_rstn;

ipsl_hmic_h_ddrphy_reset_ctrl_v1_1 u_ddrphy_reset_ctrl_v1_1
(
    .top_rst_n                      (top_rst_n   ),
    .clk                            (logic_clk),
    .global_reset_n                 (global_reset_n),
    .dll_lock                       (dll_lock),
    .pll_lock                       (pll_lock),
    .dll_update_iorst_req           (dll_update_iorst_req),
    .dll_update_iorst_ack           (dll_update_iorst_ack),
    .dll_update_req_rst_ctrl        (dll_update_req_rst_ctrl),
    .dll_update_ack_rst_ctrl        (dll_update_ack_rst_ctrl),    
    .srb_rst_dll                    (srb_rst_dll),
    .srb_dll_freeze                 (srb_dll_freeze),
    .ddrphy_rst                     (ddrphy_rst),
    .srb_iol_rst                    (srb_iol_rst),
    .srb_dqs_rstn                   (srb_dqs_rstn),
    .srb_ioclkdiv_rstn              (srb_ioclkdiv_rstn),
    .led0_ddrphy_rst                (ddrphy_rst_done)        
);

ipsl_hmic_h_ddrphy_training_ctrl_v1_1 u_ddrphy_training_ctrl_v1_1 (
    .clk                  (logic_clk ),
    .rstn                 (global_reset_n  ),
    .ddrphy_in_rst        (ddrphy_rst    ),
    .ddrphy_rst_req       (ddrphy_rst_req),
    .ddrphy_rst_ack       (ddrphy_rst_ack),
    .srb_dqs_rst_training (srb_dqs_rst_training)           
);

ipsl_hmic_h_ddrphy_dll_update_ctrl_v1_1 u_ddrphy_dll_update_ctrl_v1_1 (
.rclk                   (logic_clk),
.rst_n                  (global_reset_n),
.dll_update_req_rst_ctrl(dll_update_req_rst_ctrl),
.dll_update_ack_rst_ctrl(dll_update_ack_rst_ctrl),
.dll_update_req_training(dll_update_req),
.dll_update_ack_training(dll_update_ack),
.dll_update_iorst_req   (dll_update_iorst_req),
.dll_update_iorst_ack   (dll_update_iorst_ack),    
.dll_update_n           (dll_update_n)
);

ipsl_hmic_h_ddrphy_update_ctrl_v1_1 #(
.DATA_WIDTH              (DATA_WIDTH)
)u_ddrphy_update_ctrl_v1_1(
.rclk                    (logic_clk),
.rst_n                   (global_reset_n),
.ddr_init_done           (ddrc_init_done),
.dll_update_n            (dll_update_n),
.dll_step_copy           (dll_step_copy), //from DLL to monitor outputs
.dqs_drift_l             (dqs_drift_l),
.dqs_drift_h             (dqs_drift_h),
.ddrphy_update_comp_val_l(ddrphy_update_comp_val_l),
.ddrphy_update_comp_dir_l(ddrphy_update_comp_dir_l),
.ddrphy_update_comp_val_h(ddrphy_update_comp_val_h),
.ddrphy_update_comp_dir_h(ddrphy_update_comp_dir_h),
//.manual_update(manual_update),
.manual_update           (1'b0),
.update_mask             (UPDATE_MASK),
.ddrphy_update_type      (ddrphy_update_type),
.update_start            (ddrphy_update_start),
.ddrphy_update_done      (ddrphy_update_done)
);

ipsl_hmic_h_phy_io_v1_1  #( 
    .DQS_GATE_LOOP                            (DQS_GATE_LOOP        ),
    .TEST_PATTERN2                            (TEST_PATTERN2        ),  	
    .TEST_PATTERN3                            (TEST_PATTERN3        ),
    .T200US                                   (T200US               ),
    .MR0_DDR3                                 (MR0_DDR3             ),
    .MR1_DDR3                                 (MR1_DDR3             ),
    .MR2_DDR3                                 (MR2_DDR3             ),
    .MR3_DDR3                                 (MR3_DDR3             ),
    .MR_DDR2                                  (MR_DDR2              ),
    .EMR1_DDR2                                (EMR1_DDR2            ),
    .EMR2_DDR2                                (EMR2_DDR2            ),
    .EMR3_DDR2                                (EMR3_DDR2            ),
    .MR_LPDDR                                 (MR_LPDDR             ),
    .EMR_LPDDR                                (EMR_LPDDR            ),
    .TMRD                                     (PHY_TMRD             ),
    .TMOD                                     (PHY_TMOD             ),
    .TZQINIT                                  (PHY_TZQINIT          ),
    .TXPR                                     (PHY_TXPR             ),
    .TRP                                      (PHY_TRP              ),
    .TRFC                                     (PHY_TRFC             ),
    .WL_EN                                    (WL_EN                ),
    .DDR_TYPE                                 (DDR_TYPE             ),
    .DATA_WIDTH                               (DATA_WIDTH           ),
    .DQS_GATE_MODE                            (DQS_GATE_MODE        ),
    .WRDATA_PATH_ADJ                          (WRDATA_PATH_ADJ      ),
    .CTRL_PATH_ADJ                            (CTRL_PATH_ADJ        ),
    .WL_MAX_STEP                              (WL_MAX_STEP          ),
    .WL_MAX_CHECK                             (WL_MAX_CHECK         ),
    .MAN_WRLVL_DQS_L                          (MAN_WRLVL_DQS_L      ),
    .MAN_WRLVL_DQS_H                          (MAN_WRLVL_DQS_H      ),
    .WL_CTRL_L                                (WL_CTRL_L            ),
    .WL_CTRL_H                                (WL_CTRL_H            ),
    .INIT_READ_CLK_CTRL                       (INIT_READ_CLK_CTRL   ),
    .INIT_READ_CLK_CTRL_H                     (INIT_READ_CLK_CTRL_H ),
    .INIT_SLIP_STEP                           (INIT_SLIP_STEP       ),
    .INIT_SLIP_STEP_H                         (INIT_SLIP_STEP_H     ),
    .FORCE_READ_CLK_CTRL_L                    (FORCE_READ_CLK_CTRL_L),
    .FORCE_READ_CLK_CTRL_H                    (FORCE_READ_CLK_CTRL_H),
    .STOP_WITH_ERROR                          (STOP_WITH_ERROR      ),
    .DQGT_DEBUG                               (DQGT_DEBUG           ),
    .WRITE_DEBUG                              (WRITE_DEBUG          ),
    .RDEL_ADJ_MAX_RANG                        (RDEL_ADJ_MAX_RANG    ),
    .MIN_DQSI_WIN                             (MIN_DQSI_WIN         ),
    .INIT_SAMP_POSITION                       (INIT_SAMP_POSITION   ),
    .INIT_SAMP_POSITION_H                     (INIT_SAMP_POSITION_H ),
    .FORCE_SAMP_POSITION_L                    (FORCE_SAMP_POSITION_L),
    .FORCE_SAMP_POSITION_H                    (FORCE_SAMP_POSITION_H),
    .RDEL_RD_CNT                              (RDEL_RD_CNT          ),
    .T400NS                                   (T400NS               ),
    .T_LPDDR                                  (T_LPDDR              ),
    .REF_CNT                                  (REF_CNT              ),
    .APB_VLD                                  (APB_VLD              ),
    .TEST_PATTERN1                            (TEST_PATTERN1        ),
    .TRAIN_RST_TYPE                           (TRAIN_RST_TYPE       ),    
    .TXS                                      (PHY_TXS              ),
    .WL_SETTING                               (WL_SETTING           ),
    .WCLK_DEL_SEL                             (WCLK_DEL_SEL         ),
    .INIT_WRLVL_STEP_L                        (INIT_WRLVL_STEP_L    ),
    .INIT_WRLVL_STEP_H                        (INIT_WRLVL_STEP_H    )
    
) u_phy_io_v1_1 (
    .srb_core_clk                             (                        ),
    .pll_clk                                  (phy_clk                 ),
    .ioclk_div                                (ddrc_core_clk           ),
    .pclk                                     (phy_pclk                ),
    .preset                                   (phy_preset              ),
    .paddr                                    (phy_paddr               ),
    .pwdata                                   (phy_pwdata              ),
    .pwrite                                   (phy_pwrite              ),
    .penable                                  (phy_penable             ),
    .psel                                     (1'b0                    ),
    .pready                                   (                        ),
    .prdata                                   (                        ),
    .srb_dqs_rst                              (srb_dqs_rstn            ),
    .ddrphy_update_type                       (ddrphy_update_type      ),
    .ddrphy_update_comp_val_l                 (ddrphy_update_comp_val_l),
    .ddrphy_update_comp_dir_l                 (ddrphy_update_comp_dir_l),
    .ddrphy_update_comp_val_h                 (ddrphy_update_comp_val_h),
    .ddrphy_update_comp_dir_h                 (ddrphy_update_comp_dir_h),
    .ddrphy_rst                               (ddrphy_rst              ),
    .ddrphy_rst_req                           (ddrphy_rst_req          ),
    .ddrphy_rst_ack                           (ddrphy_rst_ack          ),
    .ddrphy_update                            (ddrphy_update_start     ),
    .ddrphy_update_done                       (ddrphy_update_done      ),
    .dll_update_ack                           (dll_update_ack          ),
    .srb_rst_dll                              (srb_rst_dll             ),
    .dll_update_n                             (dll_update_n            ),
    .dll_step_copy                            (dll_step_copy           ),
    .srb_dll_freeze                           (srb_dll_freeze          ),
    .srb_iol_rst                              (srb_iol_rst             ),
    .srb_dqs_rst_training                     (srb_dqs_rst_training    ),
    .dll_update_req                           (dll_update_req          ),
    .dfi_error                                (dfi_error               ),            
    .dfi_error_info                           (dfi_error_info          ),
    .dfi_rddata                               (dfi_rddata              ), 
    .dfi_rddata_valid                         (dfi_rddata_valid        ), 
    .dfi_ctrlupd_ack                          (dfi_ctrlupd_ack         ), 
    .dfi_init_complete                        (dfi_init_complete       ), 
    .dfi_phyupd_req                           (dfi_phyupd_req          ), 
    .dfi_phyupd_type                          (dfi_phyupd_type         ), 
    .dfi_lp_ack                               (dfi_lp_ack              ), 
    .dfi_address                              (dfi_address             ),
    .dfi_bank                                 (dfi_bank                ),
    .dfi_cas_n                                (dfi_cas_n               ),
    .dfi_ras_n                                (dfi_ras_n               ), 
    .dfi_we_n                                 (dfi_we_n                ), 
    .dfi_cke                                  (dfi_cke                 ),
    .dfi_cs                                   (dfi_cs                  ),
    .dfi_odt                                  (dfi_odt                 ),
    .dfi_reset_n                              (dfi_reset_n             ), 
    .dfi_wrdata                               (dfi_wrdata              ), 
    .dfi_wrdata_mask                          (dfi_wrdata_mask         ),
    .dfi_wrdata_en                            (dfi_wrdata_en           ),
    .dfi_rddata_en                            (dfi_rddata_en           ),
    .dfi_ctrlupd_req                          (dfi_ctrlupd_req         ),
    .dfi_dram_clk_disable                     (dfi_dram_clk_disable    ), 
    .dfi_init_start                           (dfi_init_start          ),
    .dfi_frequency                            (dfi_frequency           ),
    .dfi_phyupd_ack                           (dfi_phyupd_ack          ), 
    .dfi_lp_req                               (dfi_lp_req              ),      
    .dfi_lp_wakeup                            (dfi_lp_wakeup           ),
                                                                       
    .pad_loop_in                              (pad_loop_in             ),
    .pad_loop_in_h                            (pad_loop_in_h           ),
    .pad_rstn_ch0                             (pad_rstn_ch0            ),
    .pad_ddr_clk_w                            (pad_ddr_clk_w           ),
    .pad_ddr_clkn_w                           (pad_ddr_clkn_w          ),
    .pad_csn_ch0                              (pad_csn_ch0             ),
    .pad_addr_ch0                             (pad_addr_ch0            ),
    .pad_dq_ch0                               (pad_dq_ch0              ),
    .pad_dqs_ch0                              (pad_dqs_ch0             ),
    .pad_dqsn_ch0                             (pad_dqsn_ch0            ),
    .pad_dm_rdqs_ch0                          (pad_dm_rdqs_ch0         ),
    .pad_cke_ch0                              (pad_cke_ch0             ),
    .pad_odt_ch0                              (pad_odt_ch0             ),
    .pad_rasn_ch0                             (pad_rasn_ch0            ),
    .pad_casn_ch0                             (pad_casn_ch0            ),
    .pad_wen_ch0                              (pad_wen_ch0             ),
    .pad_ba_ch0                               (pad_ba_ch0              ),
    .pad_loop_out                             (pad_loop_out            ),
    .pad_loop_out_h                           (pad_loop_out_h          ),
    .dll_lock                                 (dll_lock                ),
    .srb_ioclkdiv_rstn                        (srb_ioclkdiv_rstn       ),
    .dqs_drift_l                              (dqs_drift_l             ),
    .dqs_drift_h                              (dqs_drift_h             )
);

endmodule
