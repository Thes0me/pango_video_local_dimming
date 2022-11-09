module rgb_to_gray(
input              rstn,
input    [23:0]    rgb_i,
input              pclk_i,
input              hs_i,
input              vs_i,
input              de_i,

output   [7:0]     gray_o,
output             hs_o,
output             vs_o,
output             de_o
);

// Y �� (( 77 * R + 150 * G + 29 * B ) >> 8)
// ���г˷�����
reg [15:0] r_temp, g_temp, b_temp;

always @(posedge pclk_i or negedge rstn) begin
    if(~rstn) begin
        r_temp <= 16'd0;
        g_temp <= 16'd0;
        b_temp <= 16'd0;
    end
    else begin
        r_temp <= rgb_i[23:16] * 8'd77;
        g_temp <= rgb_i[15:8] * 8'd150;
        b_temp <= rgb_i[7:0] * 8'd29;
    end
end

// ���мӷ�����
reg [15:0]  gray_temp_0;
reg [7:0]   gray_temp_1;

always @(posedge pclk_i or negedge rstn) begin
    if(~rstn) begin
        gray_temp_0 <= 16'd0;
    end
    else begin
        gray_temp_0 <= r_temp+g_temp+b_temp;
    end
end

// ������λ������ֱ����ȡ�߰�λ�൱�����ư�λ
always @(posedge pclk_i or negedge rstn) begin
    if(~rstn) begin
        gray_temp_1 <= 8'd0;
    end
    else begin
        gray_temp_1 <= gray_temp_0[15:8];
    end
end

// ��hs,vs��de��ʱ���ı����ź�ͬ��,ȡMSB��Ϊ���յ��г��ź����
reg [2:0] hs_d, vs_d, de_d;

always @(posedge pclk_i or negedge rstn) begin
    if(~rstn) begin
        hs_d <= 3'b0;
        vs_d <= 3'b0;
        de_d <= 3'b0;
    end
    else begin
        hs_d <= {hs_d[1:0], hs_i};
        vs_d <= {vs_d[1:0], vs_i};
        de_d <= {de_d[1:0], de_i};
    end
end

// gray��ʱһ�Ķ���counter��de
reg [7:0] gray_d;
always @(posedge pclk_i or negedge rstn) begin
    if(~rstn) begin
        gray_d <= 8'd0;
    end
    else begin
        gray_d <= gray_temp_1;
    end
end

// �������
assign gray_o   =   gray_d;
assign hs_o     =   hs_d[2];
assign vs_o     =   vs_d[2];
assign de_o     =   de_d[2];


endmodule
