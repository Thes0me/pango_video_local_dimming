module top_fifo_to_led(
    input                   clk,
    input                   pclk,
    input                   rstn,
    input       [23:0]      block_mean,
    input                   data_vaild,
    //added by test3
    input       [5:0]       block_v_cnt,

    output                  shcp,
    output                  stcp,
    output                  ds0, 
    output                  ds1,
    output                  ds2,
    output                  ds3,
    output                  ds4,
    output                  ds5
);

   
wire               empty/*synthesis syn_keep=1*/;
wire    [23:0]      dout/*synthesis syn_keep=1*/;

wire               LED0;
wire               LED1;
wire               LED2;
wire               LED3;
wire               LED4;
wire               LED5;
wire               LED6;
wire               LED7;
wire               LED8;
wire               LED9;
wire               LED10;
wire               LED11;
wire               LED12;
wire               LED13;
wire               LED14;
wire               LED15;
wire               LED16;
wire               LED17;
wire               LED18;
wire               LED19;
wire               LED20;
wire               LED21;
wire               LED22;
wire               LED23;
wire               LED24;
wire               LED25;
wire               LED26;
wire               LED27;
wire               LED28;
wire               LED29;
wire               LED30;
wire               LED31;
wire               LED32;
wire               LED33;
wire               LED34;
wire               LED35;
wire               LED36;
wire               LED37;
wire               LED38;
wire               LED39;

wire               rd_clk;
wire               rd_start;
assign  rd_clk = clk;

wire  [960-1:0]    data0       ;
wire  [5:0]        data_cnt/*synthesis syn_keep=1*/    ;

//todoooooooooooooooooooooooooooooooooooooooooooooooooo
port_in u_port_in(
    .rd_clk(rd_clk),
    .wr_clk(pclk),
    .rst_n(rstn),
    .data_valid(data_vaild),
    .din(block_mean),
    .rd_start(rd_start),
    .empty(empty),
    .dout(dout)
);

// data_tx u_data_tx(
//     .rd_clk(rd_clk),
//     .rst_n(rstn),
//     .empty(empty),
//     .dout(dout),
//     .rd_start(rd_start),
//     .data0      (data0)     ,      
//     .data_cnt   (data_cnt) 
// );

//added by test3
data_tx  u_data_tx (
    .rd_clk                  ( rd_clk        ),
    .rst_n                   ( rstn         ),
    .empty                   ( empty         ),
    .dout                    ( dout          ),
    .block_v_cnt             ( block_v_cnt   ),

    .data0                   ( data0         ),
    .rd_start                ( rd_start      ),
    .data_cnt                ( data_cnt      )
);

ws2812 u_WS2812(
          .  sys_clk      (rd_clk)   ,  
          .  sys_rst_n    (rstn)     ,
          .  data0        (data0)    ,         
          .  LED0         ( LED0)    ,
          .  LED1         ( LED1)    ,
          .  LED2         ( LED2)    ,
          .  LED3         ( LED3)    ,
          .  LED4         ( LED4)    ,
          .  LED5         ( LED5)    ,
          .  LED6         ( LED6)    ,
          .  LED7         ( LED7)    ,
          .  LED8         ( LED8)    ,
          .  LED9         ( LED9)    ,
          .  LED10        ( LED10)   ,
          .  LED11        ( LED11)   ,
          .  LED12        ( LED12)   ,
          .  LED13        ( LED13)   ,
          .  LED14        ( LED14)   ,
          .  LED15        ( LED15)   ,
          .  LED16        ( LED16)   ,
          .  LED17        ( LED17)   ,
          .  LED18        ( LED18)   ,
          .  LED19        ( LED19)   ,
          .  LED20        ( LED20)   ,
          .  LED21        ( LED21)   ,
          .  LED22        ( LED22)   ,
          .  LED23        ( LED23)   ,
          .  LED24        ( LED24)   ,
          .  LED25        ( LED25)   ,
          .  LED26        ( LED26)   ,
          .  LED27        ( LED27)   ,
          .  LED28        ( LED28)   ,
          .  LED29        ( LED29)   ,
          .  LED30        ( LED30)   ,
          .  LED31        ( LED31)   ,
          .  LED32        ( LED32)   ,
          .  LED33        ( LED33)   ,
          .  LED34        ( LED34)   ,
          .  LED35        ( LED35)   ,
          .  LED36        ( LED36)   ,
          .  LED37        ( LED37)   ,
          .  LED38        ( LED38)   ,
          .  LED39        ( LED39)   ,         
          
          .  data_cnt     (data_cnt)
);

hc595 u_hc595(
	      . clk        (rd_clk     )    ,                   
	      . rst        (rstn     )      ,               
          . LED0       (LED0  )         ,           
          . LED1       (LED1  )         ,           
          . LED2       (LED2  )         ,           
          . LED3       (LED3  )         ,           
          . LED4       (LED4  )         ,           
          . LED5       (LED5  )         ,           
          . LED6       (LED6  )         ,           
          . LED7       (LED7  )         ,           
          . LED8       (LED8  )         ,           
          . LED9       (LED9  )         ,           
          . LED10      (LED10 )         ,           
          . LED11      (LED11 )         ,           
          . LED12      (LED12 )         ,           
          . LED13      (LED13 )         ,           
          . LED14      (LED14 )         ,           
          . LED15      (LED15 )         ,           
          . LED16      (LED16 )         ,           
          . LED17      (LED17 )         ,           
          . LED18      (LED18 )         ,           
          . LED19      (LED19 )         ,               
          . LED20      (LED20 )         ,           
          . LED21      (LED21 )         ,       
          . LED22      (LED22 )         ,       
          . LED23      (LED23 )         ,       
          . LED24      (LED24 )         ,       
          . LED25      (LED25 )         ,       
          . LED26      (LED26 )         ,       
          . LED27      (LED27 )         ,       
          . LED28      (LED28 )         ,       
          . LED29      (LED29 )         ,       
          . LED30      (LED30 )         ,           
          . LED31      (LED31 )         ,       
          . LED32      (LED32 )         ,       
          . LED33      (LED33 )         ,       
          . LED34      (LED34 )         ,       
          . LED35      (LED35 )         ,       
          . LED36      (LED36 )         ,       
          . LED37      (LED37 )         ,       
          . LED38      (LED38 )         ,       
          . LED39      (LED39 )         ,           
	      . shcp       (shcp  )         ,           
	      . stcp       (stcp  )         ,           
	      . ds0        (ds0   )         ,           
	      . ds1        (ds1   )         ,           
	      . ds2        (ds2   )         ,           
	      . ds3        (ds3   )         ,           
	      . ds4        (ds4   )         ,           
	      . ds5        (ds5   )                   
);


endmodule
