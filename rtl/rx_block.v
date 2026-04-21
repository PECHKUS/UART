
`timescale 1ns / 1ps

module rx #(
    parameter DATA_BITS = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire rx,
    input  wire rx_en,          // 16x baud enable
    output reg  [DATA_BITS-1:0] rx_data,
    output reg  rx_valid,
    output reg  rx_error        //  framing error flag
);

  
    // state machine
  
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state = IDLE;

    // internal registers 
    reg [3:0] sample_count;     // counts 0-15 (16x oversampling)
    reg [$clog2(DATA_BITS):0] bit_index;
    reg [DATA_BITS-1:0] data_reg;

   
    // sequential Logic
    always @(posedge clk) begin
        if (rst) begin
            state        <= IDLE;
            sample_count <= 0;
            bit_index    <= 0;
            data_reg     <= 0;
            rx_data      <= 0;
            rx_valid     <= 0;
            rx_error     <= 0;   //initialize error flag
        end
        else begin
            rx_valid <= 0;   // default (1-cycle pulse)
            rx_error <= 0;   // default (1-cycle pulse)

            if (rx_en) begin   // operate only at 16x baud
                case (state)

                    //   IDLE state 
                    IDLE: begin
                        sample_count <= 0;
                        bit_index    <= 0;

                        if (rx == 1'b0) begin   // detect start bit (LOW)
                            state <= START;
                        end
                    end

                    //   START State: verify start bit duration 
                    START: begin
                        if (sample_count == 7) begin
                            // sample at mid-point to verify start bit
                            if (rx == 1'b0) begin
                                sample_count <= 0;
                                state <= DATA;  // valid start bit detected
                            end
                            else begin
                                state <= IDLE;  // false start bit - return to IDLE
                            end
                        end
                        else begin
                            sample_count <= sample_count + 1;
                        end
                    end

                    //DATA State: Capture 8 bits
                    DATA: begin
                        if (sample_count == 15) begin
                            sample_count <= 0;

                            data_reg[bit_index] <= rx;  // capture bit at sample_count=15 (near end of bit)
                            
                            if (bit_index == DATA_BITS-1) begin
                                state <= STOP;  // move to STOP bit
                            end
                            else begin
                                bit_index <= bit_index + 1;  // next data bit
                            end
                        end
                        else begin
                            sample_count <= sample_count + 1;
                        end
                    end

                    // STOP state: verify stop bit 
                    STOP: begin
                        if (sample_count == 15) begin
                            // sample stop bit at mid-point (sample_count=15 is close to center)
                            
                            if (rx == 1'b1) begin
                                //  valid stop bit (HIGH)
                                state <= IDLE;
                                rx_data  <= data_reg;
                                rx_valid <= 1'b1;  // signal: byte received successfully
                            end
                            else begin
                                // ✗ framing Error: stop bit is LOW (should be HIGH)
                                state <= IDLE;
                                rx_error <= 1'b1;  //signal: framing error
                            
                            end
                            
                            sample_count <= 0;
                            bit_index <= 0;
                        end
                        else begin
                            sample_count <= sample_count + 1;
                        end
                    end

                    // Default: return to IDLE
                    default: begin
                        state <= IDLE;
                    end

                endcase
            end
        end
    end

endmodule
