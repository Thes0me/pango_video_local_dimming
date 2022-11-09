//////////////////////////////////////////////////////////////////////////////////
//  sd bmp vga display                                                          //
//                                                                              //
//  Author: lhj                                                               //
//                                                                  //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2018/01/11    lhj         1.0         Original
//*******************************************************************************/
module top(
	//system clocks
	input                              sys_clk,
	input                              rst_n,
	input                              key,
	output[3:0]                        led,
	output                             sd_ncs,            //SD card chip select (SPI mode)
	output                             sd_dclk,           //SD card clock
	output                             sd_mosi,           //SD card controller data output
	input                              sd_miso,           //SD card controller data input
	//DDR3
   // input                                resetn                 ,
    input                                pll_refclk_in          ,                                                               
    output reg                           clk_led                ,
    output                               pll_lock               ,
    output                               ddr_init_done          ,
    output                               ddrphy_rst_done        ,                                                                                                                          
    input                                pad_loop_in            ,
    input                                pad_loop_in_h          ,
    output                               pad_rstn_ch0           ,
    output                               pad_ddr_clk_w          ,
    output                               pad_ddr_clkn_w         ,
    output                               pad_csn_ch0            ,
    output [15:0]                        pad_addr_ch0           ,
    inout  [16-1:0]                      pad_dq_ch0             ,
    inout  [16/8-1:0]                    pad_dqs_ch0            ,
    inout  [16/8-1:0]                    pad_dqsn_ch0           ,
    output [16/8-1:0]                    pad_dm_rdqs_ch0        ,
    output                               pad_cke_ch0            ,
    output                               pad_odt_ch0            ,
    output                               pad_rasn_ch0           ,
    output                               pad_casn_ch0           ,
    output                               pad_wen_ch0            ,
    output [2:0]                         pad_ba_ch0             ,
    output                               pad_loop_out           ,
    output                               pad_loop_out_h         ,
    output                               err_flag,
                
   /* inout [31:0]                       ddr3_dq,
	inout [3:0]                        ddr3_dqs_n,
	inout [3:0]                        ddr3_dqs_p,
	output [14:0]                      ddr3_addr,
	output [2:0]                       ddr3_ba,
	output                             ddr3_ras_n,
	output                             ddr3_cas_n,
	output                             ddr3_we_n,
	output                             ddr3_reset_n,
	output[0:0]                        ddr3_ck_p,
	output[0:0]                        ddr3_ck_n,
	output[0:0]                        ddr3_cke,
	output[0:0]                        ddr3_cs_n,
	output[3:0]                        ddr3_dm,
	output[0:0]                        ddr3_odt,*/
   //hdmi output        
   output                             tmds_clk_p,
   output                             tmds_clk_n,
   output[2:0]                        tmds_data_p,       
   output[2:0]                        tmds_data_n       
);

parameter MEM_DATA_BITS         = 64  ;            //external memory user interface data width
parameter ADDR_BITS             = 25  ;            //external memory user interface address width
parameter BUSRT_BITS            = 10  ;            //external memory user interface burst width
wire                            wr_burst_data_req;
wire                            wr_burst_finish;
wire                            rd_burst_finish;
wire                            rd_burst_req;
wire                            wr_burst_req;
wire[BUSRT_BITS - 1:0]          rd_burst_len;
wire[BUSRT_BITS - 1:0]          wr_burst_len;
wire[ADDR_BITS - 1:0]           rd_burst_addr;
wire[ADDR_BITS - 1:0]           wr_burst_addr;
wire                            rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     wr_burst_data;
wire                            read_req;
wire                            read_req_ack;
wire                            read_en;
wire[31:0]                      read_data;
wire                            write_en;
wire[31:0]                      write_data;
wire                            write_req;
wire                            write_req_ack;
wire                            sd_card_clk;       //SD card controller clock
wire                            video_clk;         //video pixel clock
wire                            video_clk5x;
wire                            hs;
wire                            vs;
wire                            de;
wire[31:0]                      vout_data;
wire[3:0]                       state_code;

wire                            hdmi_hs;
wire                            hdmi_vs;
wire                            hdmi_de;
wire[7:0]                       hdmi_r;
wire[7:0]                       hdmi_g;
wire[7:0]                       hdmi_b;

assign  hdmi_hs    = hs;
assign  hdmi_vs     = vs;
assign  hdmi_de    = de;
assign hdmi_r      = vout_data[23:16];
assign hdmi_g      = vout_data[15:8];
assign hdmi_b      = vout_data[7:0];

assign led = ~state_code;
wire                            ui_clk;
wire                            ui_clk_sync_rst;
wire                            init_calib_complete;
// Master Write Address
wire [3:0]                      s00_axi_awid;
wire [63:0]                     s00_axi_awaddr;
wire [7:0]                      s00_axi_awlen;    // burst length: 0-255
wire [2:0]                      s00_axi_awsize;   // burst size: fixed 2'b011
wire [1:0]                      s00_axi_awburst;  // burst type: fixed 2'b01(incremental burst)
wire                            s00_axi_awlock;   // lock: fixed 2'b00
wire [3:0]                      s00_axi_awcache;  // cache: fiex 2'b0011
wire [2:0]                      s00_axi_awprot;   // protect: fixed 2'b000
wire [3:0]                      s00_axi_awqos;    // qos: fixed 2'b0000
wire [0:0]                      s00_axi_awuser;   // user: fixed 32'd0
wire                            s00_axi_awvalid;
wire                            s00_axi_awready;
// master write data
wire [63:0]                     s00_axi_wdata;
wire [7:0]                      s00_axi_wstrb;
wire                            s00_axi_wlast;
wire [0:0]                      s00_axi_wuser;
wire                            s00_axi_wvalid;
wire                            s00_axi_wready;
// master write response
wire [3:0]                      s00_axi_bid;
wire [1:0]                      s00_axi_bresp;
wire [0:0]                      s00_axi_buser;
wire                            s00_axi_bvalid;
wire                            s00_axi_bready;
// master read address
wire [3:0]                      s00_axi_arid;
wire [63:0]                     s00_axi_araddr;
wire [7:0]                      s00_axi_arlen;
wire [2:0]                      s00_axi_arsize;
wire [1:0]                      s00_axi_arburst;
wire [1:0]                      s00_axi_arlock;
wire [3:0]                      s00_axi_arcache;
wire [2:0]                      s00_axi_arprot;
wire [3:0]                      s00_axi_arqos;
wire [0:0]                      s00_axi_aruser;
wire                            s00_axi_arvalid;
wire                            s00_axi_arready;
// master read data
wire [3:0]                      s00_axi_rid;
wire [63:0]                     s00_axi_rdata;
wire [1:0]                      s00_axi_rresp;
wire                            s00_axi_rlast;
wire [0:0]                      s00_axi_ruser;
wire                            s00_axi_rvalid;
wire                            s00_axi_rready;

assign sd_card_clk = sys_clk;
/*  clk_200M clk_ref_m0
 (
  // Clock out ports
  .clk_out1                     (clk_200MHz                 ),     // output clk_out1
  // Status and control signals
  .reset                        (1'b0                       ),     // input reset
  .locked                       (                           ),    // output locked
 // Clock in ports
  .clk_in1                      (sys_clk                    ));      // input clk_in1*/
/*video_pll video_pll_m0
 (
    .pll_rst(1'b0),
    .clkin1(sys_clk),
    .pll_lock(),
    .clkout0(video_clk),
    .clkout1(video_clk5x));
*/
//SD card BMP file read
/*sd_card_bmp  sd_card_bmp_m0(
	.clk                        (sd_card_clk              ),
	.rst                        (~rst_n                   ),
	.key                        (key                     ),
	.state_code                 (state_code               ),
	.bmp_width                  (16'd1024                 ),  //image width
	.write_req                  (write_req                ),
	.write_req_ack              (write_req_ack            ),
	.write_en                   (write_en                 ),
	.write_data                 (write_data               ),
	.SD_nCS                     (sd_ncs                   ),
	.SD_DCLK                    (sd_dclk                  ),
	.SD_MOSI                    (sd_mosi                  ),
	.SD_MISO                    (sd_miso                  )
);
dvi_encoder dvi_encoder_m0
 (
     .pixelclk      (video_clk          ),// system clock
     .pixelclk5x    (video_clk5x        ),// system clock x5
     .rstin         (~rst_n             ),// reset
     .blue_din      (hdmi_b             ),// Blue data in
     .green_din     (hdmi_g             ),// Green data in
     .red_din       (hdmi_r             ),// Red data in
     .hsync         (hdmi_hs            ),// hsync data
     .vsync         (hdmi_vs            ),// vsync data
     .de            (hdmi_de            ),// data enable
     .tmds_clk_p    (tmds_clk_p         ),
     .tmds_clk_n    (tmds_clk_n         ),
     .tmds_data_p   (tmds_data_p        ),//rgb
     .tmds_data_n   (tmds_data_n        ) //rgb
 );
video_timing_data#(
	.DATA_WIDTH (32)                       // Video data one clock data width
)
 video_timing_data_m0
(
	.video_clk                  (video_clk                ),
	.rst                        (~rst_n                   ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),
	.hs                         (hs                       ),
	.vs                         (vs                       ),
	.de                         (de                       ),
	.vout_data                  (vout_data                )
);
//video frame data read-write control
frame_read_write
#
(
	.MEM_DATA_BITS              (64                       ),
	.READ_DATA_BITS             (32                       ),
	.WRITE_DATA_BITS            (32                       ),
	.ADDR_BITS                  (25                       ),
	.BUSRT_BITS                 (10                       ),
	.BURST_SIZE                 (64                       )
)
frame_read_write_m0
(
	.rst                        (~rst_n                   ),
	.mem_clk                    (ui_clk                   ),
	.rd_burst_req               (rd_burst_req             ),
	.rd_burst_len               (rd_burst_len             ),
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ),
	.rd_burst_data              (rd_burst_data            ),
	.rd_burst_finish            (rd_burst_finish          ),
	.read_clk                   (video_clk                ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_finish                (                         ),
	.read_addr_0                (25'd0                    ), //first frame base address is 0
	.read_addr_1                (25'd0                    ),
	.read_addr_2                (25'd0                    ),
	.read_addr_3                (25'd0                    ),
	.read_addr_index            (2'd0                     ), //use only read_addr_0
	.read_len                   (25'd393216               ), //frame size 1024 * 768 * 32 / 64
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),

	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ),
	.wr_burst_data              (wr_burst_data            ),
	.wr_burst_finish            (wr_burst_finish          ),
	.write_clk                  (sd_card_clk              ),
	.write_req                  (write_req                ),
	.write_req_ack              (write_req_ack            ),
	.write_finish               (                         ),
	.write_addr_0               (25'd0                    ),
	.write_addr_1               (25'd0                    ),
	.write_addr_2               (25'd0                    ),
	.write_addr_3               (25'd0                    ),
	.write_addr_index           (2'd0                     ), //use only write_addr_0
	.write_len                  (25'd393216               ), //frame size
	.write_en                   (write_en                 ),
	.write_data                 (write_data               )
);*/
ddr3 u_ddr3 (
    .pll_refclk_in        (sys_clk        ),
    .ddr_rstn_key         (rst_n          ),
      
    .pll_aclk_0           (              ),
   // .pll_aclk_1           (axi_clk       ),
    .pll_aclk_1           (ui_clk       ),
    .pll_aclk_2           (              ),
    
    .pll_lock             (     ),
   // .ddrphy_rst_done      (ddrphy_rst_done),
    .ddrphy_rst_done      (ui_clk_sync_rst),
    .ddrc_init_done       (ddr_init_done ),
    .ddrc_rst         (0),    
      
    .areset_1         (0),               
    .aclk_1           (ui_clk),                                                        
    .awid_1           (s00_axi_awid),       
    .awaddr_1         (s00_axi_awaddr),     
    .awlen_1          (s00_axi_awlen),      
    .awsize_1         (s00_axi_awsize),     
    .awburst_1        (s00_axi_awburst),    
    .awlock_1         (s00_axi_awlock),                       
    .awvalid_1        (s00_axi_awvalid),    
    .awready_1        (s00_axi_awready),    
  //  .awurgent_1       (axi_awurgent),  //? 
  //  .awpoison_1       (axi_awpoison),   //?     
    .awurgent_1       (1'b0),  //? 
    .awpoison_1       (1'b0),   //?                 
    .wdata_1          (s00_axi_wdata),      
    .wstrb_1          (s00_axi_wstrb),      
    .wlast_1          (s00_axi_wlast),      
    .wvalid_1         (s00_axi_wvalid),     
    .wready_1         (s00_axi_wready),                       
    .bid_1            (s00_axi_bid),        
    .bresp_1          (s00_axi_bresp),      
    .bvalid_1         (s00_axi_bvalid),     
    .bready_1         (s00_axi_bready),                                    
    .arid_1           (s00_axi_arid     ),  
    .araddr_1         (s00_axi_araddr   ),  
    .arlen_1          (s00_axi_arlen    ),  
    .arsize_1         (s00_axi_arsize   ),  
    .arburst_1        (s00_axi_arburst  ),  
    .arlock_1         (s00_axi_arlock   ),                      
    .arvalid_1        (s00_axi_arvalid  ),  
    .arready_1        (s00_axi_arready  ),  
   // .arpoison_1       (s00_axi_arqos ),   //?   
    .arpoison_1       (1'b0 ),   //?                  
    .rid_1            (s00_axi_rid      ),  
    .rdata_1          (s00_axi_rdata    ),  
    .rresp_1          (s00_axi_rresp    ),  
    .rlast_1          (s00_axi_rlast    ),  
    .rvalid_1         (s00_axi_rvalid   ),  
    .rready_1         (s00_axi_rready   ),  
   // .arurgent_1       (axi_arurgent ),    //?    
    .arurgent_1       (1'b0),    //?        
    .csysreq_1        (1'b1),               
    .csysack_1        (),           
    .cactive_1        (), 
          
    .csysreq_ddrc     (1'b1),
    .csysack_ddrc     (),
    .cactive_ddrc     (),
             
    .pad_loop_in           (pad_loop_in),
    .pad_loop_in_h         (pad_loop_in_h),
    .pad_rstn_ch0          (pad_rstn_ch0),
    .pad_ddr_clk_w         (pad_ddr_clk_w),
    .pad_ddr_clkn_w        (pad_ddr_clkn_w),
    .pad_csn_ch0           (pad_csn_ch0),
    .pad_addr_ch0          (pad_addr_ch0),
    .pad_dq_ch0            (pad_dq_ch0),
    .pad_dqs_ch0           (pad_dqs_ch0),
    .pad_dqsn_ch0          (pad_dqsn_ch0),
    .pad_dm_rdqs_ch0       (pad_dm_rdqs_ch0),
    .pad_cke_ch0           (pad_cke_ch0),
    .pad_odt_ch0           (pad_odt_ch0),
    .pad_rasn_ch0          (pad_rasn_ch0),
    .pad_casn_ch0          (pad_casn_ch0),
    .pad_wen_ch0           (pad_wen_ch0),
    .pad_ba_ch0            (pad_ba_ch0),
    .pad_loop_out          (pad_loop_out),
    .pad_loop_out_h        (pad_loop_out_h)                                
);                                      

/*aq_axi_master u_aq_axi_master
	(
	//  .ARESETN                     (~ui_clk_sync_rst                          ),
	  .ARESETN                     (rst_n                        ),
	  .ACLK                        (ui_clk                                    ),
	  .M_AXI_AWID                  (s00_axi_awid                              ),
	  .M_AXI_AWADDR                (s00_axi_awaddr                            ),
	  .M_AXI_AWLEN                 (s00_axi_awlen                             ),
	  .M_AXI_AWSIZE                (s00_axi_awsize                            ),
	  .M_AXI_AWBURST               (s00_axi_awburst                           ),
	  .M_AXI_AWLOCK                (s00_axi_awlock                            ),
	  .M_AXI_AWCACHE               (s00_axi_awcache                           ),
	  .M_AXI_AWPROT                (s00_axi_awprot                            ),
	  .M_AXI_AWQOS                 (s00_axi_awqos                             ),
	  .M_AXI_AWUSER                (s00_axi_awuser                            ),
	  .M_AXI_AWVALID               (s00_axi_awvalid                           ),
	  .M_AXI_AWREADY               (s00_axi_awready                           ),
	  .M_AXI_WDATA                 (s00_axi_wdata                             ),
	  .M_AXI_WSTRB                 (s00_axi_wstrb                             ),
	  .M_AXI_WLAST                 (s00_axi_wlast                             ),
	  .M_AXI_WUSER                 (s00_axi_wuser                             ),
	  .M_AXI_WVALID                (s00_axi_wvalid                            ),
	  .M_AXI_WREADY                (s00_axi_wready                            ),
	  .M_AXI_BID                   (s00_axi_bid                               ),
	  .M_AXI_BRESP                 (s00_axi_bresp                             ),
	  .M_AXI_BUSER                 (s00_axi_buser                             ),
	  .M_AXI_BVALID                (s00_axi_bvalid                            ),
	  .M_AXI_BREADY                (s00_axi_bready                            ),
	  .M_AXI_ARID                  (s00_axi_arid                              ),
	  .M_AXI_ARADDR                (s00_axi_araddr                            ),
	  .M_AXI_ARLEN                 (s00_axi_arlen                             ),
	  .M_AXI_ARSIZE                (s00_axi_arsize                            ),
	  .M_AXI_ARBURST               (s00_axi_arburst                           ),
	  .M_AXI_ARLOCK                (s00_axi_arlock                            ),
	  .M_AXI_ARCACHE               (s00_axi_arcache                           ),
	  .M_AXI_ARPROT                (s00_axi_arprot                            ),
	  .M_AXI_ARQOS                 (s00_axi_arqos                             ),
	  .M_AXI_ARUSER                (s00_axi_aruser                            ),
	  .M_AXI_ARVALID               (s00_axi_arvalid                           ),
	  .M_AXI_ARREADY               (s00_axi_arready                           ),
	  .M_AXI_RID                   (s00_axi_rid                               ),
	  .M_AXI_RDATA                 (s00_axi_rdata                             ),
	  .M_AXI_RRESP                 (s00_axi_rresp                             ),
	  .M_AXI_RLAST                 (s00_axi_rlast                             ),
	  .M_AXI_RUSER                 (s00_axi_ruser                             ),
	  .M_AXI_RVALID                (s00_axi_rvalid                            ),
	  .M_AXI_RREADY                (s00_axi_rready                            ),
	  .MASTER_RST                  (1'b0                                     ),
	  .WR_START                    (wr_burst_req                             ),
	  .WR_ADRS                     ({wr_burst_addr,3'd0}                     ),
	  .WR_LEN                      ({wr_burst_len,3'd0}                      ),
	  .WR_READY                    (                                         ),
	  .WR_FIFO_RE                  (wr_burst_data_req                        ),
	  .WR_FIFO_EMPTY               (1'b0                                     ),
	  .WR_FIFO_AEMPTY              (1'b0                                     ),
	  .WR_FIFO_DATA                (wr_burst_data                            ),
	  .WR_DONE                     (wr_burst_finish                          ),
	  .RD_START                    (rd_burst_req                             ),
	  .RD_ADRS                     ({rd_burst_addr,3'd0}                     ),
	  .RD_LEN                      ({rd_burst_len,3'd0}                      ),
	  .RD_READY                    (                                         ),
	  .RD_FIFO_WE                  (rd_burst_data_valid                      ),
	  .RD_FIFO_FULL                (1'b0                                     ),
	  .RD_FIFO_AFULL               (1'b0                                     ),
	  .RD_FIFO_DATA                (rd_burst_data                            ),
	  .RD_DONE                     (rd_burst_finish                          ),
	  .DEBUG                       (                                         )
	);*/
endmodule