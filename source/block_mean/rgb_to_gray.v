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

// Y ≈ (( 77 * R + 150 * G + 29 * B ) >> 8)
// 进行乘法计算
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

// 进行加法计算
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

// 进行移位操作，直接提取高八位相当于右移八位
always @(posedge pclk_i or negedge rstn) begin
    if(~rstn) begin
        gray_temp_1 <= 8'd0;
    end
    else begin
        gray_temp_1 <= gray_temp_0[15:8];
    end
end

// 对hs,vs与de延时三拍保持信号同步,取MSB作为最终的行场信号输出
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

// gray延时一拍对齐counter的de
reg [7:0] gray_d;
always @(posedge pclk_i or negedge rstn) begin
    if(~rstn) begin
        gray_d <= 8'd0;
    end
    else begin
        gray_d <= gray_temp_1;
    end
end

// 输出部分
assign gray_o   =   gray_d;
assign hs_o     =   hs_d[2];
assign vs_o     =   vs_d[2];
assign de_o     =   de_d[2];


endmodule
