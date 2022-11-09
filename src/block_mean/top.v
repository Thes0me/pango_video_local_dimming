module top_block_mean(
    input clk,
    input rstn,
    
    output  [7:0]   block_mean,
    output          data_vaild
);

wire hs,de,vs,pclk;

//todooooooooooooooooooooooooooooooooooo
clk_wiz_0 pclk_gen
   (
    // Clock out ports
    .clk_out1(pclk),     // output clk_out1
    // Status and control signals
    .reset(~rstn), // input reset
    .locked(),       // output locked
   // Clock in ports
    .clk_in1(clk));      // input clk_in1

wire [7:0] rgb_r, rgb_g, rgb_b;
color_bar u_color_bar (
    .clk                     ( pclk     ),
    .rst                     ( ~rstn     ),

    .hs                      ( hs      ),
    .vs                      ( vs      ),
    .de                      ( de      ),
    .rgb_r                   ( rgb_r),
    .rgb_g                   ( rgb_g),
    .rgb_b                   ( rgb_b)
);

wire [7:0] gray_o;
wire g_hs_o, g_vs_o, g_de_o;
rgb_to_gray  u_rgb_to_gray (
    .rstn                    ( rstn     ),
    .rgb_i                   ( {rgb_r, rgb_g, rgb_b}),
    .pclk_i                  ( pclk   ),
    .hs_i                    ( hs     ),
    .vs_i                    ( vs     ),
    .de_i                    ( de     ),

    .gray_o                  ( gray_o   ),
    .hs_o                    ( g_hs_o     ),
    .vs_o                    ( g_vs_o     ),
    .de_o                    ( g_de_o     )
);

wire cnt_de_o;
video_pixel_counter  u_video_pixel_counter (
    .pclk                    ( pclk               ),
    .rstn                    ( rstn               ),
    .de                      ( g_de_o                 ),
    .hs                      ( g_hs_o                 ),
    .vs                      ( g_vs_o                 ),

    .p_cnt                   ( p_cnt              ),
    .line_cnt                ( line_cnt           ),
    .de_o                    ( cnt_de_o               ),
    .block_h_cnt             ( block_h_cnt        ),
    .block_v_cnt             ( block_v_cnt        ),
    .inblock_line_cnt        ( inblock_line_cnt   )
);

block_mean  u_block_mean (
    .clk                     ( pclk            ),
    .rstn                    ( rstn           ),
    .de                      ( cnt_de_o             ),
    .hs                      ( g_hs_o             ),
    .vs                      ( g_vs_o             ),
    .block_x                 ( block_h_cnt        ),
    .block_y                 ( block_v_cnt        ),
    .inblock_line            ( inblock_line_cnt   ),
    .gray                    ( gray_o           ),

    .block_mean              ( block_mean     ),
    .data_vaild              ( data_vaild     )
);

// wire data_vaild_o;
// gamma_fix_1_2_2  u_gamma_fix_1_2_2 (
//     .clk                     ( pclk               ),
//     .rstn                    ( rstn               ),
//     .block_mean_i            ( block_mean         ),
//     .data_valid_i            ( data_vaild         ),

//     .block_mean_fixed_o      (                    ),
//     .data_valid_o            (                    )
// );

// gamma_fix_2_2  u_gamma_fix_2_2 (
//     .clk                     ( pclk               ),
//     .rstn                    ( rstn               ),
//     .block_mean_i            ( block_mean         ),
//     .data_valid_i            ( data_vaild         ),

//     .block_mean_fixed_o      ( block_mean_fixed   ),
//     .data_valid_o            ( data_vaild_o       )
// );

endmodule
