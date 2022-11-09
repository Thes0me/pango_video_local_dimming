module gamma_fix_1_2_2(
    input                   clk,
    input                   rstn,
    input          [7:0]    block_mean_i,
    input                   data_valid_i,

    output         [7:0]    block_mean_fixed_o,
    output                  data_valid_o
);

//��data_vaild�źŽ��д��ģ��Ӻ�����ʱ��������gammaУ��֮����������
//�Ӻ���������Ϊģ���õ���rom������ʱΪ����
reg [1:0] data_valid_i_d;
always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        data_valid_i_d <= 2'b0;
    end
    else begin
        data_valid_i_d <= {data_valid_i_d[0], data_valid_i};
    end
end
assign data_valid_o = data_valid_i_d[1];

//����rom��ȡgammaУ��֮�������ֵ
blk_mem_gen_1 gamma_fix_1_2_2_rom (
  .clka(clk),    // input wire clka
  .addra(block_mean_i),  // input wire [7 : 0] addra
  .douta(block_mean_fixed_o)  // output wire [7 : 0] douta
);



endmodule
