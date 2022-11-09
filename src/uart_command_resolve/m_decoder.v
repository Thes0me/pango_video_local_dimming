`timescale 1ns/1ps

module m_decoder(
	input				 	clk			    ,
	input				 	rst_n			,
	input				 	i_rx_en			,
	input		[7:0]	 	i_rx_data		,
	output reg		 		o_led_en		,
	output reg	[31:0] 		o_para_list		,
	output reg	[7:0] 		o_check         ,
    output      [7:0]       cmdcode         ,
    output      [7:0]       cmd_len         ,
    output                  cmd_vaild
    );

//帧头
localparam DATA_FRAME_HEADER	= 8'h40;
//帧尾或校验和
localparam DATA_FRAME_TAIL		= 8'hbc;	
//状态
localparam  BCODE =   0,
            CLEN  =   1,
            CMD   =   2,
            PARA  =   3,
            CHECK =   4;
//中间信号
reg     [7:0]       r_bootcode      ;
reg     [7:0]       r_cmdlen        ;
reg     [7:0]       r_cmdcode       ;
reg     [3:0]       state_c, state_n;
reg     [7:0]       byte1[3:0]      ;
//计数器--用于解数据包中参数计数
reg     [31:0]      cnt    ;
wire                add_cnt;
wire                end_cnt;
//状态跳转条件
wire        bcode2clen_start    ;
wire        clen2cmd_start      ;
wire        cmd2para_start      ;
wire        para2check_start    ;
wire        check2bcode_start   ;
////////////////////////////////////////////
//时序逻辑状态切换
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_c <= BCODE;
    end
    else begin
        state_c <= state_n;
    end
end
////////////////////////////////////////////
//组合逻辑切换状态
always @(*) begin
    case (state_c)
        BCODE : begin
            if(bcode2clen_start) begin
                state_n <= CLEN;
            end
            else begin
                state_n <= state_c;
            end
        end
        CLEN : begin
            if(clen2cmd_start) begin
                state_n <= CMD;
            end
            else begin
                state_n <= state_c;
            end
        end
        CMD : begin
            if(cmd2para_start) begin
                state_n <= PARA;
            end
            else begin
                state_n <= state_c;
            end
        end
        PARA : begin
            if(para2check_start) begin
                state_n <= CHECK;
            end
            else begin
                state_n <= state_c;
            end
        end
        CHECK : begin
            if(check2bcode_start) begin
                state_n <= BCODE;
            end
            else begin
                state_n <= state_c;
            end
        end
        default : begin
            state_n <= BCODE;
        end
    endcase
end

//状态机第三段--设计转移条件
assign  bcode2clen_start  = state_c==BCODE && i_rx_en==1              ;
assign  clen2cmd_start    = state_c==CLEN  && i_rx_en==1              ;
assign  cmd2para_start    = state_c==CMD   && i_rx_en==1              ;
assign  para2check_start  = state_c==PARA  && i_rx_en==1 && end_cnt==1;
assign  check2bcode_start = state_c==CHECK && i_rx_en==1              ;

//状态机第四段--同步时序always模块，格式化
//获取命令包的引导码
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r_bootcode <= 8'b0;
        o_led_en <= 'b0;
    end
    else if(state_c==BCODE && i_rx_en==1) begin
        if(i_rx_data == 8'h40) begin
            r_bootcode <= i_rx_data;
            o_led_en <= 'b1;
        end
    end
    else begin
        o_led_en <= 'b0;
    end
end

//获取命令包的数据长度
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r_cmdlen <= 8'b0;
    end
    else if(state_c==CLEN&&i_rx_en==1) begin
        r_cmdlen <= i_rx_data;
    end
    else begin
    end
end
assign cmd_len = r_cmdlen;
//获取命令包的命令码
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r_cmdcode <= 8'b0;
    end
    else if(state_c==CMD&&i_rx_en==1) begin
        r_cmdcode <= i_rx_data;
    end
    else begin
    end
end
assign cmdcode = r_cmdcode;

//获取命令包的参数列表--使用计数器，根据数据包中指定的长度取参数
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 0;
    end
    else if(add_cnt) begin
        if(end_cnt) begin
            cnt <= 0;
        end
        else begin
            cnt <= cnt + 1;
        end
    end
end
//计数器加一条件
assign add_cnt = state_c==PARA && i_rx_en==1;
//计数器计数结束条件 //格式x-1, 包长x=命令+参数个数，因此参数个数=包长-2(再排出命令一字节)
assign end_cnt = add_cnt && cnt == r_cmdlen - 2;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        o_para_list <= 32'b0;
    end
    else if(state_c==PARA && add_cnt==1 && i_rx_en==1) begin
        byte1[cnt] <= i_rx_data;
    end
    else begin
        o_para_list <= {byte1[3],byte1[2],byte1[1],byte1[0]};
    end
end

//获取CHECK值
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        o_check <= 8'b0;
        o_led_en <= 1'b0;
    end
    else if(state_c==CHECK && i_rx_en==1) begin
        o_check <= i_rx_data;
        o_led_en <= 1'b1;
    end
end

//获取cmd_vaild的值
reg          r_cmd_vaild;
reg  [3:0]   state_d;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        state_d <= 4'b0;
    end
    else begin
        state_d <= state_c;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r_cmd_vaild <= 1'b0;
    end
    else if(state_c==BCODE && state_d==CHECK) begin
        r_cmd_vaild <= 1'b1;
    end
    else begin
        r_cmd_vaild <= 1'b0;
    end
end
assign cmd_vaild = r_cmd_vaild;


endmodule