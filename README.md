<div align="center">
  <h1> UART Controller in Verilog</h1>
  <p><i>A robust, modular, and synthesizable Universal Asynchronous Receiver/Transmitter.</i></p>

</div>

<hr />

##  Overview
This repository contains a high-performance **UART** implementation designed for FPGA applications. It features a modular architecture that separates the baud rate logic from the transmission and reception blocks, ensuring easy debugging and integration into larger SoC projects.

### Key Features
* **Modular Design:** Independent RX, TX, and Baud Generator modules.
* **16x Oversampling:** The receiver samples at 16x the baud rate for high noise immunity.
* **Parameterizable:** Easily adjust the clock frequency and target baud rate (e.g., 9600, 115200).
* **Standard Frame:** Supports **8-N-1** (8 data bits, no parity, 1 stop bit).

<hr />

##  Project Architecture

<table width="100%">
  <tr>
    <th align="left">File</th>
    <th align="left">Description</th>
  </tr>
  <tr>
    <td><code>rtl/rx_block.v</code></td>
    <td>Handles serial-to-parallel conversion with start/stop bit detection.</td>
  </tr>
  <tr>
    <td><code>rtl/tx_block.v</code></td>
    <td>Handles parallel-to-serial conversion with state machine control.</td>
  </tr>
  <tr>
    <td><code>rtl/baud_gen.v</code></td>
    <td>Generates the 16x sampling tick based on system clock frequency.</td>
  </tr>
</table>

<hr />

##  Configuration & Usage

To calculate the required `CLKS_PER_BIT` for your specific hardware, use the following formula:

<div align="center">
  <img src="https://latex.codecogs.com/svg.image?CLKS\_PER\_BIT&space;=&space;\frac{Frequency_{Clock}}{BaudRate}" title="Baud Rate Equation" />
</div>

### Instantiation Example:
```verilog
// Example for 115200 Baud @ 50MHz Clock
uart_top #(
    .CLKS_PER_BIT(434) 
) my_uart (
    .clk(clk),
    .rst_n(rst_n),
    .tx_data(data_in),
    .rx_serial(fpga_rx_pin),
    .tx_serial(fpga_tx_pin),
    .rx_done(data_ready)
);
