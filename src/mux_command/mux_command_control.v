module mux_command_control(
    input                   clk                   ,
    input                   rstn                  ,
    input                   cmd_vaild             ,
    input       [7:0]       cmd_code              ,
    input       [31:0]      para_list             ,

    //原始模式输入
    input       [7:0]       block_mean_white      ,
    input       [5:0]       block_v_cnt_white     ,
    input                   data_vaild_white      ,
    //彩色模式输入
    input       [23:0]      block_mean_color      ,
    input       [5:0]       block_v_cnt_color     ,
    input                   data_vaild_color      ,

    //mux选择输出
    output      [23:0]      block_mean            ,
    output reg              data_vaild            ,
    output      [5:0]       block_v_cnt           
);
// ##########命令表##########
/* 
   1. code为 a0 时
      输出为带调亮度功能的纯白光分区
      参数表低8位为要减去的亮度阈值
   2. code为 a1 时
      输出为带调色功能的单色光分区
      参数表低24位分别为RGB对应的比例
      如24‘hff00ff则R:G:B为255:0:255
   3. code为a2 时
      输出为带调亮度功能的全彩色分区
      参数表低24位为要减去的各通道亮度阈值
      如24‘hff00ff则R:G:B为-255:0:-255
*/
// ##########命令表##########


// uart指令寄存
reg   [7:0]   cmd_code_r;
reg   [31:0]  para_list_r;
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        cmd_code_r <= 8'b0;
        para_list_r <= 32'b0;
    end
    else if(cmd_vaild) begin
        cmd_code_r <= cmd_code;
        para_list_r <= para_list;
    end
    else begin
        cmd_code_r <= cmd_code_r;
        para_list_r <= para_list_r;
    end
end

// block_mean mux输出生成
reg [23:0] block_mean_r;

wire flag_white;
assign flag_white = (block_mean_white>para_list_r[7:0]);

wire [15:0] r_ratio_fixed;
wire [15:0] g_ratio_fixed;
wire [15:0] b_ratio_fixed;
assign r_ratio_fixed = (block_mean_white*para_list_r[23:16])>>8;
assign g_ratio_fixed = (block_mean_white*para_list_r[15:8])>>8;
assign b_ratio_fixed = (block_mean_white*para_list_r[7:0])>>8;

wire flag_color_r;
wire flag_color_g;
wire flag_color_b;
assign flag_color_r = (block_mean_color[23:16]>para_list_r[23:16]);
assign flag_color_g = (block_mean_color[15:8] >para_list_r[15:8]);
assign flag_color_b = (block_mean_color[7:0]  >para_list_r[7:0]);

always @( *) begin
    case (cmd_code_r)
        8'ha0 : begin
            block_mean_r = {3{(flag_white)? (block_mean_white-para_list_r[7:0]) : 8'b0}};
        end
        8'ha1 : begin
            block_mean_r = {r_ratio_fixed[7:0],g_ratio_fixed[7:0],b_ratio_fixed[7:0]};
        end
        8'ha2 : begin
            block_mean_r[23:16] = (flag_color_r)? (block_mean_color[23:16]-para_list_r[23:16]) : 8'b0;
            block_mean_r[15:8] = (flag_color_g)? (block_mean_color[15:8]-para_list_r[15:8]) : 8'b0;
            block_mean_r[7:0] = (flag_color_b)? (block_mean_color[7:0]-para_list_r[7:0]) : 8'b0;
        end
        default : begin
            block_mean_r = {3{(flag_white)? (block_mean_white-para_list_r[7:0]) : 8'b0}};
        end
    endcase
end
assign block_mean = block_mean_r;

// data_vaild信号生成
// 有较大影响，color的数据出来的要快一些，根据情况选择vaild信号
always @( *) begin
    case (cmd_code_r)
        8'ha0 : data_vaild = data_vaild_white;
        8'ha1 : data_vaild = data_vaild_white;
        8'ha2 : data_vaild = data_vaild_color;
        default : data_vaild = data_vaild_white;
    endcase
end

// block_v_cnt信号生成
// 对时序影响不大，直接以white的计数值也能正常工作
assign block_v_cnt = block_v_cnt_white;


endmodule
