module block_mean(
    input                         clk,
    input                         rstn,
    input                         de,
    input                         hs,
    input                         vs,
    input            [5:0]        block_x,
    input            [5:0]        block_y,
    input            [5:0]        inblock_line,
    input            [7:0]        gray,
    input            [7:0]        brightness,

    output           [7:0]        block_mean,
    output   reg                  data_vaild
);

// edge&change detect
// 1. hs_d
reg hs_d;
wire hs_rise;
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        hs_d <= 1'b0;
    end
    else begin
        hs_d <= hs;
    end
end
assign hs_rise = (~hs_d)&hs;
// 2. vs_d
reg vs_d;
wire vs_rise;
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        vs_d <= 1'b0;
    end
    else begin
        vs_d <= vs;
    end
end
assign vs_rise = (~vs_d)&vs;
// 3. de_fall
reg de_d;
wire de_fall;
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        de_d <= 1'b0;
    end
    else begin
        de_d <= de;
    end
end
assign de_fall = de_d&(~de);
// 4. block_y_d
reg [5:0] block_y_d;
wire block_y_changed;
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        block_y_d <= 6'd0;
    end
    else begin
        block_y_d <= block_y;
    end
end
assign block_y_changed = (block_y==block_y_d)? 1'b0:1'b1;

// horizontial accumulation
reg [13:0] h_reg[39:0];
integer i;

always @(posedge clk or negedge rstn) begin
    if(~rstn || hs_rise) begin
        for(i = 0; i < 40; i=i+1) begin
            h_reg[i] <= 14'd0;
        end
    end
    else begin
        case (block_x)
            6'd1  : h_reg[0]  <= h_reg[0]  + gray;
            6'd2  : h_reg[1]  <= h_reg[1]  + gray;
            6'd3  : h_reg[2]  <= h_reg[2]  + gray;
            6'd4  : h_reg[3]  <= h_reg[3]  + gray;
            6'd5  : h_reg[4]  <= h_reg[4]  + gray;
            6'd6  : h_reg[5]  <= h_reg[5]  + gray;
            6'd7  : h_reg[6]  <= h_reg[6]  + gray;
            6'd8  : h_reg[7]  <= h_reg[7]  + gray;
            6'd9  : h_reg[8]  <= h_reg[8]  + gray;
            6'd10 : h_reg[9]  <= h_reg[9]  + gray;
            6'd11 : h_reg[10] <= h_reg[10] + gray;
            6'd12 : h_reg[11] <= h_reg[11] + gray;
            6'd13 : h_reg[12] <= h_reg[12] + gray;
            6'd14 : h_reg[13] <= h_reg[13] + gray;
            6'd15 : h_reg[14] <= h_reg[14] + gray;
            6'd16 : h_reg[15] <= h_reg[15] + gray;
            6'd17 : h_reg[16] <= h_reg[16] + gray;
            6'd18 : h_reg[17] <= h_reg[17] + gray;
            6'd19 : h_reg[18] <= h_reg[18] + gray;
            6'd20 : h_reg[19] <= h_reg[19] + gray;
            6'd21 : h_reg[20] <= h_reg[20] + gray;
            6'd22 : h_reg[21] <= h_reg[21] + gray;
            6'd23 : h_reg[22] <= h_reg[22] + gray;
            6'd24 : h_reg[23] <= h_reg[23] + gray;
            6'd25 : h_reg[24] <= h_reg[24] + gray;
            6'd26 : h_reg[25] <= h_reg[25] + gray;
            6'd27 : h_reg[26] <= h_reg[26] + gray;
            6'd28 : h_reg[27] <= h_reg[27] + gray;
            6'd29 : h_reg[28] <= h_reg[28] + gray;
            6'd30 : h_reg[29] <= h_reg[29] + gray;
            6'd31 : h_reg[30] <= h_reg[30] + gray;
            6'd32 : h_reg[31] <= h_reg[31] + gray;
            6'd33 : h_reg[32] <= h_reg[32] + gray;
            6'd34 : h_reg[33] <= h_reg[33] + gray;
            6'd35 : h_reg[34] <= h_reg[34] + gray;
            6'd36 : h_reg[35] <= h_reg[35] + gray;
            6'd37 : h_reg[36] <= h_reg[36] + gray;
            6'd38 : h_reg[37] <= h_reg[37] + gray;
            6'd39 : h_reg[38] <= h_reg[38] + gray;
            6'd40 : h_reg[39] <= h_reg[39] + gray;
            default : ;
        endcase
    end
end

// vertical accumulation
reg [13:0] v_reg[39:0];
integer j;
always @(posedge clk or negedge rstn) begin
    if(~rstn || block_y_changed) begin
        for(j = 0; j < 40; j=j+1) begin
            v_reg[j] <= 14'd0;
        end
    end
    else if(de_fall) begin
        v_reg[0]  <= v_reg[0]  + (h_reg[0]  >> 5);
        v_reg[1]  <= v_reg[1]  + (h_reg[1]  >> 5);
        v_reg[2]  <= v_reg[2]  + (h_reg[2]  >> 5);
        v_reg[3]  <= v_reg[3]  + (h_reg[3]  >> 5);
        v_reg[4]  <= v_reg[4]  + (h_reg[4]  >> 5);
        v_reg[5]  <= v_reg[5]  + (h_reg[5]  >> 5);
        v_reg[6]  <= v_reg[6]  + (h_reg[6]  >> 5);
        v_reg[7]  <= v_reg[7]  + (h_reg[7]  >> 5);
        v_reg[8]  <= v_reg[8]  + (h_reg[8]  >> 5);
        v_reg[9]  <= v_reg[9]  + (h_reg[9]  >> 5);
        v_reg[10] <= v_reg[10] + (h_reg[10] >> 5);
        v_reg[11] <= v_reg[11] + (h_reg[11] >> 5);
        v_reg[12] <= v_reg[12] + (h_reg[12] >> 5);
        v_reg[13] <= v_reg[13] + (h_reg[13] >> 5);
        v_reg[14] <= v_reg[14] + (h_reg[14] >> 5);
        v_reg[15] <= v_reg[15] + (h_reg[15] >> 5);
        v_reg[16] <= v_reg[16] + (h_reg[16] >> 5);
        v_reg[17] <= v_reg[17] + (h_reg[17] >> 5);
        v_reg[18] <= v_reg[18] + (h_reg[18] >> 5);
        v_reg[19] <= v_reg[19] + (h_reg[19] >> 5);
        v_reg[20] <= v_reg[20] + (h_reg[20] >> 5);
        v_reg[21] <= v_reg[21] + (h_reg[21] >> 5);
        v_reg[22] <= v_reg[22] + (h_reg[22] >> 5);
        v_reg[23] <= v_reg[23] + (h_reg[23] >> 5);
        v_reg[24] <= v_reg[24] + (h_reg[24] >> 5);
        v_reg[25] <= v_reg[25] + (h_reg[25] >> 5);
        v_reg[26] <= v_reg[26] + (h_reg[26] >> 5);
        v_reg[27] <= v_reg[27] + (h_reg[27] >> 5);
        v_reg[28] <= v_reg[28] + (h_reg[28] >> 5);
        v_reg[29] <= v_reg[29] + (h_reg[29] >> 5);
        v_reg[30] <= v_reg[30] + (h_reg[30] >> 5);
        v_reg[31] <= v_reg[31] + (h_reg[31] >> 5);
        v_reg[32] <= v_reg[32] + (h_reg[32] >> 5);
        v_reg[33] <= v_reg[33] + (h_reg[33] >> 5);
        v_reg[34] <= v_reg[34] + (h_reg[34] >> 5);
        v_reg[35] <= v_reg[35] + (h_reg[35] >> 5);
        v_reg[36] <= v_reg[36] + (h_reg[36] >> 5);
        v_reg[37] <= v_reg[37] + (h_reg[37] >> 5);
        v_reg[38] <= v_reg[38] + (h_reg[38] >> 5);
        v_reg[39] <= v_reg[39] + (h_reg[39] >> 5);
    end
end

// data generate fsm
reg sending_over;
reg [1:0] state, next_state;
localparam  idle = 0,
            sending = 1;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        state <= idle;
    end
    else begin
        state <= next_state;
    end
end

always @(*) begin
    case (state)
        idle : begin
            if(hs_rise&&(inblock_line == 6'd36)&&(send_all_cnt < 20)) begin
                next_state = sending;
            end
            else begin
                next_state = idle;
            end
        end
        sending : next_state = (sending_over)? idle:sending;     
    endcase
end

reg [5:0] send_cnt;
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        send_cnt <= 6'd0;
    end
    else if(state == sending) begin
        send_cnt <= send_cnt + 6'd1;
    end
    else if(state == idle) begin
        send_cnt <= 6'd0;
    end
    else begin
        send_cnt <= send_cnt;
    end
end

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        sending_over <= 1'd0;
    end
    else begin
        sending_over <= (send_cnt == 6'd40)? 1'd1:1'd0;
    end
end

// reg [8:0] block_mean_temp;  //防止超出255范围
reg [17:0] block_mean_temp;
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        block_mean_temp <= 18'd0;
    end
    else if(state == sending) begin
        case (send_cnt)
            6'd1  : block_mean_temp <= v_reg[0] >> 5;
            6'd2  : block_mean_temp <= v_reg[1] >> 5;
            6'd3  : block_mean_temp <= v_reg[2] >> 5;
            6'd4  : block_mean_temp <= v_reg[3] >> 5;
            6'd5  : block_mean_temp <= v_reg[4] >> 5;
            6'd6  : block_mean_temp <= v_reg[5] >> 5;
            6'd7  : block_mean_temp <= v_reg[6] >> 5;
            6'd8  : block_mean_temp <= v_reg[7] >> 5;
            6'd9  : block_mean_temp <= v_reg[8] >> 5;
            6'd10 : block_mean_temp <= v_reg[9] >> 5;
            6'd11 : block_mean_temp <= v_reg[10] >> 5;
            6'd12 : block_mean_temp <= v_reg[11] >> 5;
            6'd13 : block_mean_temp <= v_reg[12] >> 5;
            6'd14 : block_mean_temp <= v_reg[13] >> 5;
            6'd15 : block_mean_temp <= v_reg[14] >> 5;
            6'd16 : block_mean_temp <= v_reg[15] >> 5;
            6'd17 : block_mean_temp <= v_reg[16] >> 5;
            6'd18 : block_mean_temp <= v_reg[17] >> 5;
            6'd19 : block_mean_temp <= v_reg[18] >> 5;
            6'd20 : block_mean_temp <= v_reg[19] >> 5;
            6'd21 : block_mean_temp <= v_reg[20] >> 5;
            6'd22 : block_mean_temp <= v_reg[21] >> 5;
            6'd23 : block_mean_temp <= v_reg[22] >> 5;
            6'd24 : block_mean_temp <= v_reg[23] >> 5;
            6'd25 : block_mean_temp <= v_reg[24] >> 5;
            6'd26 : block_mean_temp <= v_reg[25] >> 5;
            6'd27 : block_mean_temp <= v_reg[26] >> 5;
            6'd28 : block_mean_temp <= v_reg[27] >> 5;
            6'd29 : block_mean_temp <= v_reg[28] >> 5;
            6'd30 : block_mean_temp <= v_reg[29] >> 5;
            6'd31 : block_mean_temp <= v_reg[30] >> 5;
            6'd32 : block_mean_temp <= v_reg[31] >> 5;
            6'd33 : block_mean_temp <= v_reg[32] >> 5;
            6'd34 : block_mean_temp <= v_reg[33] >> 5;
            6'd35 : block_mean_temp <= v_reg[34] >> 5;
            6'd36 : block_mean_temp <= v_reg[35] >> 5;
            6'd37 : block_mean_temp <= v_reg[36] >> 5;
            6'd38 : block_mean_temp <= v_reg[37] >> 5;
            6'd39 : block_mean_temp <= v_reg[38] >> 5;
            6'd40 : block_mean_temp <= v_reg[39] >> 5;
        endcase
    end
    else begin
        block_mean_temp <= 18'd0;
    end
end
// assign block_mean = (block_mean_temp>8'd255)? 8'd255 : block_mean_temp[7:0];
// assign block_mean = (block_mean_temp * 910) >> 10;
//add by uart command solve module
assign block_mean = (((block_mean_temp * 910) >> 10)>brightness) ? ((block_mean_temp * 910) >> 10)-brightness : 8'b0;


always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        data_vaild <= 1'b0;
    end
    else if(state == sending) begin
        data_vaild <= 1'b1;
    end
    else begin
        data_vaild <= 1'b0;
    end
end

reg [5:0] send_all_cnt;
always @(posedge clk or negedge rstn) begin
    if(~rstn || vs_rise) begin
        send_all_cnt <= 6'd0;
    end
    else if(sending_over) begin
        send_all_cnt <= send_all_cnt + 6'd1;
    end
    else begin
        send_all_cnt <= send_all_cnt;
    end
end


endmodule
