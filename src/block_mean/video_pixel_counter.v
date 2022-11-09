
module video_pixel_counter(
input                       pclk,
input                       rstn,
input                       de,
input                       hs,
input                       vs,
 
output         [10:0]       p_cnt,
output         [10:0]       line_cnt,
output                      de_o,  //counter的结果比de慢一个pclk，所以延迟de
output   reg   [5:0]        block_h_cnt,  // 1~40 horizontial block number
output   reg   [5:0]        block_v_cnt,  // 1~20  vertical block number
output   reg   [5:0]        inblock_line_cnt  //在一行40个block内分出1~36线
);


// 每一行的像素计数器，对于1280x720则是从1计数到1280
reg [10:0] p_cnt_temp;

always @(posedge pclk or negedge rstn) begin
    if(~rstn || hs || vs) begin
        p_cnt_temp <= 11'd0;
    end
    else if(de) begin
        p_cnt_temp <= p_cnt_temp + 11'd1;
    end
    else begin
        p_cnt_temp <= p_cnt_temp;
    end
end

// 每一帧内的行计数器，如1280x720则是从1计数到720
reg [10:0] line_cnt_temp;
reg de_d;
wire de_rise;

// de打拍检测上升沿
always @(posedge pclk or negedge rstn) begin
    if(~rstn) begin
        de_d <= 1'b0;
    end
    else begin
        de_d <= de;
    end
end
assign de_rise = (~de_d) & de;
assign de_o = de_d;

always @(posedge pclk or negedge rstn) begin
    if(~rstn || vs) begin
        line_cnt_temp <= 11'd0;
    end
    else if(de_rise) begin
        line_cnt_temp <= line_cnt_temp + 11'd1;
    end
    else begin
        line_cnt_temp <= line_cnt_temp;
    end
end

// 横向40个区块计数器
reg [5:0] cnt_32;
always @(posedge pclk or negedge rstn) begin
    if(~rstn || hs || vs) begin
        cnt_32 <= 1;
        block_h_cnt <= 6'd1;
    end
    else if(cnt_32 >= 32) begin
        cnt_32 <= 1;
        block_h_cnt <= block_h_cnt + 6'd1;
    end
    else begin
        cnt_32 <= (de_o)? cnt_32 + 1 : cnt_32;
    end
end

// 纵向20个区块计数器
reg [6:0] cnt_36;

always @(posedge de_o or negedge rstn or posedge vs) begin
    if(~rstn || vs) begin
        cnt_36 <= 0;
        block_v_cnt <= 6'd1;
    end
    else if(cnt_36 >= 36) begin
        cnt_36 <= 1;
        block_v_cnt <= block_v_cnt + 6'd1;
    end
    else begin
        cnt_36 <= cnt_36 + 1;
    end
end

// 横向区块内36线计数器
always @(posedge de_o or negedge rstn or posedge vs) begin
    if(~rstn || vs) begin
        inblock_line_cnt <= 6'd0;
    end
    else if(inblock_line_cnt >= 36) begin
        inblock_line_cnt <= 6'd1;
    end
    else begin
        inblock_line_cnt <= inblock_line_cnt + 6'd1;
    end
end

// 输出
assign p_cnt = p_cnt_temp;
assign line_cnt = line_cnt_temp;


endmodule
