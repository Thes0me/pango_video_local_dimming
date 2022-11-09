module ipsl_ddrphy_training_ctrl
(
    input                                clk                            ,
    input                                rstn                    ,
    input                                ddrphy_in_rst                  ,
    input                                ddrphy_rst_req                 ,
    output                               ddrphy_rst_ack                 ,
    output reg                           srb_dqs_rst_training           
);

parameter SRB_DQS_RST_TRAINING_HIGH_CLK = 4;

reg ddrphy_rst_req_d1, ddrphy_rst_req_d2, ddrphy_rst_req_d3;
wire ddrphy_rst_req_p;

always @ (posedge clk) begin
    ddrphy_rst_req_d1 <= ddrphy_rst_req;
    ddrphy_rst_req_d2 <= ddrphy_rst_req_d1;
    ddrphy_rst_req_d3 <= ddrphy_rst_req_d2;
end

assign ddrphy_rst_req_p = ddrphy_rst_req_d2 & ~ddrphy_rst_req_d3;

reg [2:0] dqs_rst_training_high_cnt;

always @ (posedge clk or negedge rstn)
    if (!rstn)
        dqs_rst_training_high_cnt <= 3'h0;
    else if (ddrphy_rst_req_p)
        dqs_rst_training_high_cnt <= SRB_DQS_RST_TRAINING_HIGH_CLK;
    else if (|dqs_rst_training_high_cnt)
        dqs_rst_training_high_cnt <= dqs_rst_training_high_cnt - 3'h1;
    else
        dqs_rst_training_high_cnt <= dqs_rst_training_high_cnt;



//CLK_AND_RST_PLAN = 1, not to reset clk for default plan
always @ (posedge clk or negedge rstn)
    if (!rstn)
        srb_dqs_rst_training <= 1'b1;
    else if (ddrphy_in_rst)
        srb_dqs_rst_training <= 1'b1;
    else if (|dqs_rst_training_high_cnt)
        srb_dqs_rst_training <= 1'b1;
    else
        srb_dqs_rst_training <= 1'b0;

reg srb_dqs_rst_training_d;

always @ (posedge clk or negedge rstn)
    if (!rstn)
        srb_dqs_rst_training_d <= 1'b1;
    else
	srb_dqs_rst_training_d <= srb_dqs_rst_training;

assign ddrphy_rst_ack = ~srb_dqs_rst_training & srb_dqs_rst_training_d;

endmodule