`timescale 1ns / 1ps

module uart_top #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115200,
    parameter DATA_BITS = 8,
    parameter FIFO_DEPTH = 16
)(
    input  wire clk,
    input  wire rst,

    // UART physical lines
    input  wire rx,
    output wire tx,

    // TX interface (System side)
    input  wire [DATA_BITS-1:0] tx_data,
    input  wire tx_valid,
    output wire tx_ready,

    // RX interface (System side)
    output wire [DATA_BITS-1:0] rx_data,
    input  wire rx_read,
    output wire rx_valid
);

    // internal wires 
    
    wire tx_en;
    wire rx_en;

    // TX FIFO signals
    wire tx_fifo_full;
    wire tx_fifo_empty;
    wire [DATA_BITS-1:0] tx_fifo_dout;
    wire tx_fifo_rd_en;
    wire tx_ready_tx;

    // RX FIFO signals
    wire rx_fifo_full;
    wire rx_fifo_empty;
    wire [DATA_BITS-1:0] rx_data_internal;
    wire rx_internal_valid;

    // baud generator
    
    B_G #(
        .CLOCK_FREQ(CLK_FREQ),     //  corrected parameter name
        .BAUD_RATE(BAUD_RATE)
    ) baud_gen_inst (
        .clk   (clk),
        .rst   (rst),
        .tx_en (tx_en),
        .rx_en (rx_en)
    );

    // TX Path: system -> TX FIFO -> TX Module -> tx line
    
    tx_fifo #(
        .DATA_WIDTH(DATA_BITS),
        .DEPTH(FIFO_DEPTH)
    ) tx_fifo_inst (
        .clk   (clk),
        .rst   (rst),
        .wr_en (tx_valid && !tx_fifo_full),  // write when system has data and FIFO not full
        .rd_en (tx_fifo_rd_en),
        .din   (tx_data),
        .dout  (tx_fifo_dout),
        .full  (tx_fifo_full),
        .empty (tx_fifo_empty)
    );

    // TX ready = FIFO not full
    assign tx_ready = !tx_fifo_full;

    // Read from FIFO when TX is ready and FIFO has data
    assign tx_fifo_rd_en = tx_ready_tx && !tx_fifo_empty;

    // TX module
    tx #(
        .DATA_BITS(DATA_BITS)
    ) tx_inst (
        .clk      (clk),
        .rst      (rst),
        .tx_en    (tx_en),
        .tx_data  (tx_fifo_dout),
        .tx_valid (!tx_fifo_empty),  // Valid when FIFO has data
        .tx_ready (tx_ready_tx),
        .tx       (tx)
    );

    
    // RX path: rx line -> RX Module -> RX FIFO -> System
   
    
    rx #(
        .DATA_BITS(DATA_BITS)
    ) rx_inst (
        .clk      (clk),
        .rst      (rst),
        .rx       (rx),
        .rx_en    (rx_en),
        .rx_data  (rx_data_internal),
        .rx_valid (rx_internal_valid)
    );

    // RX FIFO
    rx_fifo #(
        .DATA_WIDTH(DATA_BITS),
        .DEPTH(FIFO_DEPTH)
    ) rx_fifo_inst (
        .clk   (clk),
        .rst   (rst),
        .wr_en (rx_internal_valid && !rx_fifo_full),  // write when RX has valid data and FIFO not full
        .rd_en (rx_read),
        .din   (rx_data_internal),
        .dout  (rx_data),
        .full  (rx_fifo_full),
        .empty (rx_fifo_empty)
    );

    // RX valid = FIFO has data
    assign rx_valid = !rx_fifo_empty;

endmodule
