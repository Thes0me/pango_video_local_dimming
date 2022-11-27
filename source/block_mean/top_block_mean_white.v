module top_white_block_mean(
    input            clk                ,
    input            rstn               ,
    input            de                 ,
    input            hs                 ,
    input            vs                 ,
    input   [7:0]    rgb_r              ,
    input   [7:0]    rgb_g              ,
    input   [7:0]    rgb_b              ,

    output  [7:0]    block_mean_white/*synthesis syn_keep=1*/,
    output           data_vaild_white/*synthesis syn_keep=1*/,
    output  [5:0]    block_v_cnt/*synthesis syn_keep=1*/
);

// RGB to Gray convert module
// rgb_to_gray Outputs
wire  [7:0]  gray_o;
wire  hs_o;
wire  vs_o;
wire  de_o;

rgb_to_gray  u_rgb_to_gray (
    .rstn                    ( rstn                   ),
    .rgb_i                   ( {rgb_r,rgb_g,rgb_b}    ),
    .pclk_i                  ( clk                    ),
    .hs_i                    ( hs                     ),
    .vs_i                    ( vs                     ),
    .de_i                    ( de                     ),

    .gray_o                  ( gray_o                 ),
    .hs_o                    ( hs_o                   ),
    .vs_o                    ( vs_o                   ),
    .de_o                    ( de_o                   )
);

//pixel counter instantiation
// video_pixel_counter Outputs
wire  [10:0]  p_cnt;
wire  [10:0]  line_cnt;
wire          de_o_cnt;
wire  [5:0]   block_h_cnt;
// wire  [5:0]   block_v_cnt;
wire  [5:0]   inblock_line_cnt;

video_pixel_counter  u_video_pixel_counter (
    .pclk                    ( clk                ),
    .rstn                    ( rstn               ),
    .de                      ( de_o               ),
    .hs                      ( hs_o               ),
    .vs                      ( vs_o               ),

    .p_cnt                   ( p_cnt              ),
    .line_cnt                ( line_cnt           ),
    .de_o                    ( de_o_cnt           ),
    .block_h_cnt             ( block_h_cnt        ),
    .block_v_cnt             ( block_v_cnt        ),
    .inblock_line_cnt        ( inblock_line_cnt   )
);

// white block mean cal module
wire [7:0] block_mean_i;
wire data_valid_i;
block_mean  u_block_mean_white (
    .clk                     ( clk             ),
    .rstn                    ( rstn            ),
    .de                      ( de_o_cnt        ),
    .hs                      ( hs_o            ),
    .vs                      ( vs_o            ),
    .block_x                 ( block_h_cnt     ),
    .block_y                 ( block_v_cnt     ),
    .inblock_line            ( inblock_line_cnt),
    .gray                    ( gray_o          ),

    .block_mean              ( block_mean_i    ),
    .data_vaild              ( data_vaild_i    )
);

// gamma fix module

gamma_fix_2_2_top  u_gamma_fix_2_2_top (
    .clk                     ( clk                  ),
    .rstn                    ( rstn                 ),
    .block_mean_i            ( block_mean_i         ),
    .data_valid_i            ( data_vaild_i         ),

    .block_mean_fixed_o      ( block_mean_white     ),
    .data_valid_o            ( data_vaild_white     )
);


endmodule
