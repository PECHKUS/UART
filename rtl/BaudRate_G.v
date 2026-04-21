`timescale 1ns / 1ps
module B_G #(
    parameter integer CLOCK_FREQ = 100_000_000,
    parameter integer BAUD_RATE  = 9600
)(
    input  wire clk,
    input  wire rst,       // active HIGH synchronous reset
    output reg  tx_en,
    output reg  rx_en
);


    // divider calculation
    localparam integer TX_DIV = CLOCK_FREQ / BAUD_RATE;
    localparam integer RX_DIV = CLOCK_FREQ / (BAUD_RATE * 16);


localparam integer TX_W = $clog2(TX_DIV) + 1;
localparam integer RX_W = $clog2(RX_DIV) + 1;

reg [TX_W-1:0] tx_cnt;
reg [RX_W-1:0] rx_cnt;

    
    // baud generation logic
    
    always @(posedge clk) begin
        if (rst) begin
            tx_cnt <= 0;
            rx_cnt <= 0;
            tx_en  <= 1'b0;
            rx_en  <= 1'b0;
        end
        else begin
            // TX baud pulse
            if (tx_cnt == TX_DIV - 1) begin
                tx_cnt <= 0;
                tx_en  <= 1'b1;
            end
            else begin
                tx_cnt <= tx_cnt + 1'b1;
                tx_en  <= 1'b0;
            end

            // RX 16x baud pulse
            if (rx_cnt == RX_DIV - 1) begin
                rx_cnt <= 0;
                rx_en  <= 1'b1;
            end
            else begin
                rx_cnt <= rx_cnt + 1'b1;
                rx_en  <= 1'b0;
            end
        end
    end

endmodule

