//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2017/7/19     meisq          1.0         Original
//*******************************************************************************/

`timescale 1ns/1ps
module frame_read_write
#
(
	parameter MEM_DATA_BITS          = 16,
	parameter READ_DATA_BITS         = 16,
	parameter WRITE_DATA_BITS        = 16,
	parameter ADDR_BITS              = 24,
	parameter BUSRT_BITS             = 10,
	parameter BURST_SIZE             = 128
)               
(
	input                            rst,                  
	input                            mem_clk,                    // external memory controller user interface clock
	output                           rd_burst_req/* synthesis PAP_MARK_DEBUG="true" */,               // to external memory controller,send out a burst read request
	output[BUSRT_BITS - 1:0]         rd_burst_len,               // to external memory controller,data length of the burst read request, not bytes
	output[ADDR_BITS - 1:0]          rd_burst_addr,              // to external memory controller,base address of the burst read request 
	input                            rd_burst_data_valid/* synthesis PAP_MARK_DEBUG="true" */,       // from external memory controller,read data valid 
	input[MEM_DATA_BITS - 1:0]       rd_burst_data/* synthesis PAP_MARK_DEBUG="true" */,            // from external memory controller,read request data
	input                            rd_burst_finish/* synthesis PAP_MARK_DEBUG="true" */,            // from external memory controller,burst read finish
	input                            read_clk,                   // data read module clock
	input                            read_req/* synthesis PAP_MARK_DEBUG="true" */,                  // data read module read request,keep '1' until read_req_ack = '1'
	output                           read_req_ack,               // data read module read request response
	output                           read_finish,                // data read module read request finish
	input[ADDR_BITS - 1:0]           read_addr_0,                // data read module read request base address 0, used when read_addr_index = 0
	input[ADDR_BITS - 1:0]           read_addr_1,                // data read module read request base address 1, used when read_addr_index = 1
	input[ADDR_BITS - 1:0]           read_addr_2,                // data read module read request base address 1, used when read_addr_index = 2
	input[ADDR_BITS - 1:0]           read_addr_3,                // data read module read request base address 1, used when read_addr_index = 3
	input[1:0]                       read_addr_index,            // select valid base address from read_addr_0 read_addr_1 read_addr_2 read_addr_3
	input[ADDR_BITS - 1:0]           read_len,                   // data read module read request data length
	input                            read_en,                    // data read module read request for one data, read_data valid next clock
	output[READ_DATA_BITS  - 1:0]    read_data,                  // read data
	output                           wr_burst_req/* synthesis PAP_MARK_DEBUG="true" */,              // to external memory controller,send out a burst write request
	output[BUSRT_BITS - 1:0]         wr_burst_len,               // to external memory controller,data length of the burst write request, not bytes
	output[ADDR_BITS - 1:0]          wr_burst_addr,              // to external memory controller,base address of the burst write request 
	input                            wr_burst_data_req/* synthesis PAP_MARK_DEBUG="true" */,         // from external memory controller,write data request ,before data 1 clock
	output[MEM_DATA_BITS - 1:0]      wr_burst_data/* synthesis PAP_MARK_DEBUG="true" */,            // to external memory controller,write data
	input                            wr_burst_finish/* synthesis PAP_MARK_DEBUG="true" */,           // from external memory controller,burst write finish
	input                            write_clk,                  // data write module clock
	input                            write_req/* synthesis PAP_MARK_DEBUG="true" */,                  // data write module write request,keep '1' until read_req_ack = '1'
	output                           write_req_ack,              // data write module write request response
	output                           write_finish/* synthesis PAP_MARK_DEBUG="true" */,              // data write module write request finish
	input[ADDR_BITS - 1:0]           write_addr_0,               // data write module write request base address 0, used when write_addr_index = 0
	input[ADDR_BITS - 1:0]           write_addr_1,               // data write module write request base address 1, used when write_addr_index = 1
	input[ADDR_BITS - 1:0]           write_addr_2,               // data write module write request base address 1, used when write_addr_index = 2
	input[ADDR_BITS - 1:0]           write_addr_3,               // data write module write request base address 1, used when write_addr_index = 3
	input[1:0]                       write_addr_index,           // select valid base address from write_addr_0 write_addr_1 write_addr_2 write_addr_3
	input[ADDR_BITS - 1:0]           write_len,                  // data write module write request data length
	input                            write_en/* synthesis PAP_MARK_DEBUG="true" */,                // data write module write request for one data
	input[WRITE_DATA_BITS - 1:0]     write_data/* synthesis PAP_MARK_DEBUG="true" */            // write data
);
wire[15:0]                           wrusedw/* synthesis PAP_MARK_DEBUG="true" */;                // write used words
wire[15:0]                           rdusedw/* synthesis PAP_MARK_DEBUG="true" */;                  // read used words
wire                                 read_fifo_aclr;             // fifo Asynchronous clear
wire                                 write_fifo_aclr;            // fifo Asynchronous clear
wire                                 wr_full/* synthesis PAP_MARK_DEBUG="true" */;            // fifo Asynchronous clear
wire                                 rd_empty/* synthesis PAP_MARK_DEBUG="true" */; 
//instantiate an asynchronous FIFO
/*afifo_32i_64o_256 write_buf (
	.rst                         (write_fifo_aclr         ),
	.wr_clk                      (write_clk               ),
	.rd_clk                      (mem_clk                 ),
	.din                         (write_data              ),
	.wr_en                       (write_en                ),
	.rd_en                       (wr_burst_data_req       ),
	.dout                        (wr_burst_data           ),
	.full                        (                        ),
	.empty                       (                        ),
	.rd_data_count               (rdusedw                 ),
	.wr_data_count               (                        )
);*/
reg wr_burst_data_req_d0/* synthesis PAP_MARK_DEBUG="true" */;
reg wr_burst_data_req_d1/* synthesis PAP_MARK_DEBUG="true" */;
always@(posedge mem_clk )
    begin
	wr_burst_data_req_d0<=wr_burst_data_req;
    wr_burst_data_req_d1<=wr_burst_data_req_d0;
	end
afifo_32i_64o_256depth write_buf(
    .wr_clk(write_clk),
    .wr_rst(write_fifo_aclr),
    .wr_byte_en(4'b1111), 
    .wr_en(write_en),
    .wr_data(write_data),
    .wr_full(wr_full),
    .wr_water_level(),
    .almost_full(),
    .rd_clk(mem_clk),
    .rd_rst(write_fifo_aclr),
    .rd_en(wr_burst_data_req),
   // .rd_en(wr_burst_data_req_d0),
    .rd_data(wr_burst_data),
    .rd_empty(rd_empty),
    .rd_water_level(rdusedw[8:0]),
    .almost_empty());

/*
afifo_16_256 write_buf
	(
	.rdclk                      (mem_clk                  ),          // Read side clock
	.wrclk                      (write_clk                ),          // Write side clock
	.aclr                       (write_fifo_aclr          ),          // Asynchronous clear
	.wrreq                      (write_en                 ),          // Write Request
	.rdreq                      (wr_burst_data_req        ),          // Read Request
	.data                       (write_data               ),          // Input Data
	.rdempty                    (                         ),          // Read side Empty flag
	.wrfull                     (                         ),          // Write side Full flag
	.rdusedw                    (rdusedw                  ),          // Read Used Words
	.wrusedw                    (                         ),          // Write Used Words
	.q                          (wr_burst_data            )
);
*/
frame_fifo_write
#
(
	.MEM_DATA_BITS              (MEM_DATA_BITS            ),
	.ADDR_BITS                  (ADDR_BITS                ),
	.BUSRT_BITS                 (BUSRT_BITS               ),
	.BURST_SIZE                 (BURST_SIZE               )
) 
frame_fifo_write_m0              
(  
	.rst                        (rst                      ),
	.mem_clk                    (mem_clk                  ),
	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ),
	.wr_burst_finish            (wr_burst_finish          ),
	.write_req                  (write_req                ),
	.write_req_ack              (write_req_ack            ),
	.write_finish               (write_finish             ),
	.write_addr_0               (write_addr_0             ),
	.write_addr_1               (write_addr_1             ),
	.write_addr_2               (write_addr_2             ),
	.write_addr_3               (write_addr_3             ),
	.write_addr_index           (write_addr_index         ),    
	.write_len                  (write_len                ),
	.fifo_aclr                  (write_fifo_aclr          ),
	.rdusedw                    (rdusedw                  ) 
	
);

//instantiate an asynchronous FIFO
/*afifo_64i_32o_128 read_buf (
	.rst                         (read_fifo_aclr          ),                     
	.wr_clk                      (mem_clk                 ),               
	.rd_clk                      (read_clk                ),               
	.din                         (rd_burst_data           ),                     
	.wr_en                       (rd_burst_data_valid     ),                 
	.rd_en                       (read_en                 ),                 
	.dout                        (read_data               ),                   
	.full                        (                        ),                   
	.empty                       (                        ),                 
	.rd_data_count               (                        ), 
	.wr_data_count               (wrusedw                 )  
);*/
afifo_64i_32o_128depth read_buf (
    .wr_clk(mem_clk),
    .wr_rst(read_fifo_aclr),
    .wr_en(rd_burst_data_valid),
    .wr_data(rd_burst_data),
    .wr_full(),
    .wr_water_level(wrusedw[8:0]),
    .almost_full(),
    .rd_clk(read_clk),
    .rd_rst(read_fifo_aclr),
    .rd_en(read_en),
    .rd_data(read_data),
    .rd_empty(),
    .rd_water_level(),
    .almost_empty());
/*
afifo_16_256 read_buf
	(
	.rdclk                     (read_clk                   ),          // Read side clock
	.wrclk                     (mem_clk                    ),          // Write side clock
	.aclr                      (read_fifo_aclr             ),          // Asynchronous clear
	.wrreq                     (rd_burst_data_valid        ),          // Write Request
	.rdreq                     (read_en                    ),          // Read Request
	.data                      (rd_burst_data              ),          // Input Data
	.rdempty                   (                           ),          // Read side Empty flag
	.wrfull                    (                           ),          // Write side Full flag
	.rdusedw                   (                           ),          // Read Used Words
	.wrusedw                   (wrusedw                    ),          // Write Used Words
	.q                         (read_data                  )
);
*/
frame_fifo_read
#
(
	.MEM_DATA_BITS              (MEM_DATA_BITS            ),
	.ADDR_BITS                  (ADDR_BITS                ),
	.FIFO_DEPTH                 (128                      ),
	.BUSRT_BITS                 (BUSRT_BITS               ),	
	.BURST_SIZE                 (BURST_SIZE               )
)
frame_fifo_read_m0
(
	.rst                        (rst                      ),
	.mem_clk                    (mem_clk                  ),
	.rd_burst_req               (rd_burst_req             ),   
	.rd_burst_len               (rd_burst_len             ),  
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ),    
	.rd_burst_finish            (rd_burst_finish          ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_finish                (read_finish              ),
	.read_addr_0                (read_addr_0              ),
	.read_addr_1                (read_addr_1              ),
	.read_addr_2                (read_addr_2              ),
	.read_addr_3                (read_addr_3              ),
	.read_addr_index            (read_addr_index          ),    
	.read_len                   (read_len                 ),
	.fifo_aclr                  (read_fifo_aclr           ),
	.wrusedw                    (wrusedw                  )
);

endmodule
