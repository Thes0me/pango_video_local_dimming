//*************************************************************************\
//Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd,All rights reserved
//
//                   File Name  :  key_debounce.v
//                Project Name  :  
//                      Author  :  meisq
//                       Email  :  msq@qq.com
//                     Company  :  ALINX(shanghai) Technology Co.,Ltd
//                      taobao  :  https://oshcn.taobao.com/
//                         WEB  :  http://www.alinx.cn/
//==========================================================================
//   Description:   
//
//   
//==========================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------
//  2017/6/19     meisq         1.0         Original
//*************************************************************************/
module key_debounce(
    input        clk,
    input        rst_n,
	input        key1,
    output [5:0] seg_sel,
    output [7:0] seg_data
);
wire button_negedge;
ax_debounce ax_debounce_m0
(
    .clk             (clk),
    .rst             (~rst_n),
    .button_in       (key1),
    .button_posedge  (),
    .button_negedge  (button_negedge),
    .button_out      ()
);

wire[3:0] count;
count_m10 count10_m0(
    .clk    (clk),
    .rst_n  (rst_n),
    .en     (button_negedge),
    .clr    (1'b0),
    .data   (count),
    .t      ()
);

wire[6:0] seg_data_0;
seg_decoder seg_decoder_m0(
    .bin_data  (count),
    .seg_data  (seg_data_0)
);

seg_scan seg_scan_m0(
    .clk        (clk),
    .rst_n      (rst_n),
    .seg_sel    (seg_sel),
    .seg_data   (seg_data),
    .seg_data_0 ({1'b1,7'b1111_111}),
    .seg_data_1 ({1'b1,7'b1111_111}),
    .seg_data_2 ({1'b1,7'b1111_111}),
    .seg_data_3 ({1'b1,7'b1111_111}),
    .seg_data_4 ({1'b1,7'b1111_111}),
    .seg_data_5 ({1'b1,seg_data_0})
);
endmodule 