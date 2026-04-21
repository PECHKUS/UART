`timescale 1ns / 1ps

module tx #(
    parameter DATA_BITS = 8
)(
    input  wire clk,
    input  wire rst,

    input  wire tx_en,              // this is the output of the baud generation if tx is enable 

    input  wire [DATA_BITS-1:0] tx_data,
    input  wire tx_valid,
    output wire tx_ready,

    output reg  tx
);

    // here the state encoding happens which tracks the state of the uart module for tx
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state = IDLE;  // this register remembers where is it in the transmission process 
    reg [DATA_BITS-1:0] data_reg;
    reg [$clog2(DATA_BITS):0] bit_index;  // tracks which bit we are currently sending 

    // this indicates the module is ready to get the new data to tansmit from when idle
    assign tx_ready = (state == IDLE);

    // sequential logic making starts here 
    always @(posedge clk) begin
    
    // on reset it goes to the known state which is predefined 
        if (rst) begin
            state     <= IDLE;
            tx        <= 1'b1;       // UART line idle is HIGH
            data_reg  <= 0;
            bit_index <= 0;
        end
        else begin
            case (state)

                // when the block is in idle state
                IDLE: begin
                    tx <= 1'b1;      // line stays high
                    if (tx_valid) begin
                        data_reg  <= tx_data;
                        bit_index <= 0;
                        state     <= START;
                    end
                end

                // when the block starts sending bits 
                START: begin
                    if (tx_en) begin
                        tx    <= 1'b0;   // start bit = 0
                        state <= DATA;
                    end
                end

                //this represents the data bits 

                DATA: begin
                     if (tx_en) begin
                        tx <= data_reg[bit_index];
        
                     if (bit_index == DATA_BITS-1)
                        state <= STOP;
                     else
                         bit_index <= bit_index + 1;  // increment after sending each bit
                     end
                end
                // defines the stop bits 
                STOP: begin
                    if (tx_en) begin
                        tx    <= 1'b1;   // stop bit = 1
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule
