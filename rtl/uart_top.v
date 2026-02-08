module uart_top(input rst , input [7:0] data_in, input wr_en,clk, input rdy_clr, output rdy, busy, output [7:0] data_out);

wire rx_clk_en;
wire tx_clk_enb;

wire tx_temp;

baud_rate_generator bg(clk, rst, tx_clk_enb, rx_clk_en);

uart_sender us(clk, wr_en, tx_clk_enb, rst, data_in, tx_temp, busy);

uart_receiver ur(clk, rst, tx_temp, rx_clk_en, rdy, data_out);

endmodule 

