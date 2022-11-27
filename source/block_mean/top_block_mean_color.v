module top_color_block_mean(
    input            clk                ,
    input            rstn               ,
    input            de                 ,
    input            hs                 ,
    input            vs                 ,
    input   [7:0]    rgb_r              ,
    input   [7:0]    rgb_g              ,
    input   [7:0]    rgb_b              ,

    output  [23:0]   block_mean_color   ,
    output           data_vaild         ,
    output  [5:0]    block_v_cnt
);


// //pclk instantiation
// wire pclk;
// clk_wiz_0 pclk_gen (
//     // Clock out ports
//     .pclk(pclk),     // output pclk
//     // Status and control signals
//     .reset(~rstn), // input reset
//     // Clock in ports
//     .clk(clk)
// );      // input clk

//color bar instantiation
// color_bar Outputs
// wire  hs;
// wire  vs;
// wire  de;
// wire  [7:0]  rgb_r;
// wire  [7:0]  rgb_g;
// wire  [7:0]  rgb_b;

//rgb 打拍延时对齐时序
wire  [7:0]  rgb_r_o;
wire  [7:0]  rgb_g_o;
wire  [7:0]  rgb_b_o;
reg  [7:0]  rgb_r_d;
reg  [7:0]  rgb_g_d;
reg  [7:0]  rgb_b_d;

always @(posedge clk or negedge rstn) begin
    if(~rstn) begin
        rgb_r_d <= 8'b0;
        rgb_g_d <= 8'b0;
        rgb_b_d <= 8'b0;
    end
    else begin
        rgb_r_d <= rgb_r;
        rgb_g_d <= rgb_g;
        rgb_b_d <= rgb_b;
    end
end
assign rgb_r_o = rgb_r_d;
assign rgb_g_o = rgb_g_d;
assign rgb_b_o = rgb_b_d;

// color_bar u_color_bar (
//     .clk                     ( pclk    ),
//     .rst                     ( ~rstn   ),

//     .hs                      ( hs      ),
//     .vs                      ( vs      ),
//     .de                      ( de      ),
//     .rgb_r                   ( rgb_r   ),
//     .rgb_g                   ( rgb_g   ),
//     .rgb_b                   ( rgb_b   )
// );

//pixel counter instantiation
// video_pixel_counter Outputs
wire  [10:0]  p_cnt;
wire  [10:0]  line_cnt;
wire          de_o;
wire  [5:0]   block_h_cnt;
// wire  [5:0]   block_v_cnt;
wire  [5:0]   inblock_line_cnt;

video_pixel_counter  u_video_pixel_counter (
    .pclk                    ( clk                ),
    .rstn                    ( rstn               ),
    .de                      ( de                 ),
    .hs                      ( hs                 ),
    .vs                      ( vs                 ),

    .p_cnt                   ( p_cnt              ),
    .line_cnt                ( line_cnt           ),
    .de_o                    ( de_o               ),
    .block_h_cnt             ( block_h_cnt        ),
    .block_v_cnt             ( block_v_cnt        ),
    .inblock_line_cnt        ( inblock_line_cnt   )
);

// R channel block mean
// block_mean Outputs
wire  [7:0]  block_mean_r;
wire  data_vaild_r;

block_mean  u_block_mean_R (
    .clk                     ( clk             ),
    .rstn                    ( rstn            ),
    .de                      ( de_o            ),
    .hs                      ( hs              ),
    .vs                      ( vs              ),
    .block_x                 ( block_h_cnt     ),
    .block_y                 ( block_v_cnt     ),
    .inblock_line            ( inblock_line_cnt),
    .gray                    ( rgb_r_o         ),

    .block_mean              ( block_mean_r    ),
    .data_vaild              ( data_vaild/*data_vaild_r*/      )
);

// G channel block mean
// block_mean Outputs
wire  [7:0]  block_mean_g;
// wire  data_vaild;

block_mean  u_block_mean_G (
    .clk                     ( clk             ),
    .rstn                    ( rstn            ),
    .de                      ( de_o            ),
    .hs                      ( hs              ),
    .vs                      ( vs              ),
    .block_x                 ( block_h_cnt     ),
    .block_y                 ( block_v_cnt     ),
    .inblock_line            ( inblock_line_cnt),
    .gray                    ( rgb_g_o         ),

    .block_mean              ( block_mean_g    ),
    .data_vaild              (                 )
);

// B channel block mean
// block_mean Outputs
wire  [7:0]  block_mean_b;
// wire  data_vaild;

block_mean  u_block_mean_B (
    .clk                     ( clk             ),
    .rstn                    ( rstn            ),
    .de                      ( de_o            ),
    .hs                      ( hs              ),
    .vs                      ( vs              ),
    .block_x                 ( block_h_cnt     ),
    .block_y                 ( block_v_cnt     ),
    .inblock_line            ( inblock_line_cnt),
    .gray                    ( rgb_b_o         ),

    .block_mean              ( block_mean_b    ),
    .data_vaild              (                 )
);

//output wire bus assign
//wire  [7:0]  block_mean_r;
//wire  [7:0]  block_mean_g;
//wire  [7:0]  block_mean_b;
//wire  [7:0]  block_mean_r_fixed;
//wire  [7:0]  block_mean_g_fixed;
//wire  [7:0]  block_mean_b_fixed;
//assign block_mean_color = {block_mean_r_fixed, block_mean_g_fixed, block_mean_b_fixed};
assign block_mean_color = {block_mean_r, block_mean_g, block_mean_b};

// add gamma fix to rgb channel
// R channel
//gamma_fix_2_2_top u_gamma_fix_r
//    (
//    .clk(clk),                                // input
//    .rstn(rstn),                              // input
//    .data_valid_i(data_vaild_r),              // input
//    .data_valid_o(data_vaild),              // output
//    .block_mean_i(block_mean_r),              // input[7:0]
//    .block_mean_fixed_o(block_mean_r_fixed)   // output[7:0]
//);
//
//gamma_fix_2_2_top u_gamma_fix_g
//    (
//    .clk(clk),                                // input
//    .rstn(rstn),                              // input
//    .data_valid_i(),              // input
//    .data_valid_o(),              // output
//    .block_mean_i(block_mean_g),              // input[7:0]
//    .block_mean_fixed_o(block_mean_g_fixed)   // output[7:0]
//);
//
//gamma_fix_2_2_top u_gamma_fix_b
//    (
//    .clk(clk),                                // input
//    .rstn(rstn),                              // input
//    .data_valid_i(),              // input
//    .data_valid_o(),              // output
//    .block_mean_i(block_mean_b),              // input[7:0]
//    .block_mean_fixed_o(block_mean_b_fixed)   // output[7:0]
//);


endmodule
