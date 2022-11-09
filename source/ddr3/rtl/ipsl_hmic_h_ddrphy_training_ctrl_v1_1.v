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

module ipsl_hmic_h_ddrphy_training_ctrl_v1_1
(
    input              clk                  ,
    input              rstn                 ,
    input              ddrphy_in_rst        ,
    input              ddrphy_rst_req       ,
    output             ddrphy_rst_ack       ,
    output reg         srb_dqs_rst_training 
);

localparam RST_TRAINING_HIGH_CLK = 4;

reg ddrphy_rst_req_d1; 
reg ddrphy_rst_req_d2; 
reg ddrphy_rst_req_d3;
wire ddrphy_rst_req_p;
reg [2:0] dqs_rst_training_high_cnt;
reg srb_dqs_rst_training_d;

always @ (posedge clk or negedge rstn) 
begin
    if (!rstn) begin
        ddrphy_rst_req_d1 <= 0;
        ddrphy_rst_req_d2 <= 0;
        ddrphy_rst_req_d3 <= 0;
    end
    else begin
        ddrphy_rst_req_d1 <= ddrphy_rst_req;
        ddrphy_rst_req_d2 <= ddrphy_rst_req_d1;
        ddrphy_rst_req_d3 <= ddrphy_rst_req_d2;
    end
end

assign ddrphy_rst_req_p = ddrphy_rst_req_d2 & ~ddrphy_rst_req_d3;

always @ (posedge clk or negedge rstn)
begin
    if (!rstn)
        dqs_rst_training_high_cnt <= 3'h0;
    else if (ddrphy_rst_req_p)
        dqs_rst_training_high_cnt <= RST_TRAINING_HIGH_CLK;
    else if (|dqs_rst_training_high_cnt)
        dqs_rst_training_high_cnt <= dqs_rst_training_high_cnt - 3'h1;
    else
        dqs_rst_training_high_cnt <= dqs_rst_training_high_cnt;
end

//CLK_AND_RST_PLAN = 1, not to reset clk for default plan
always @ (posedge clk or negedge rstn)
begin
    if (!rstn)
        srb_dqs_rst_training <= 1'b1;
    else if (ddrphy_in_rst)
        srb_dqs_rst_training <= 1'b1;
    else if (|dqs_rst_training_high_cnt)
        srb_dqs_rst_training <= 1'b1;
    else
        srb_dqs_rst_training <= 1'b0;
end

always @ (posedge clk or negedge rstn)
begin
    if (!rstn)
        srb_dqs_rst_training_d <= 1'b1;
    else
	srb_dqs_rst_training_d <= srb_dqs_rst_training;
end

assign ddrphy_rst_ack = ~srb_dqs_rst_training & srb_dqs_rst_training_d;

endmodule