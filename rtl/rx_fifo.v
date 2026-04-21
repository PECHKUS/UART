`timescale 1ns / 1ps

module rx_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)(
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    wr_en,
    input  wire                    rd_en,
    input  wire [DATA_WIDTH-1:0]   din,
    output reg  [DATA_WIDTH-1:0]   dout,
    output wire                    full,
    output wire                    empty
);

     
    // derived parameters
    
    localparam ADDR_WIDTH = $clog2(DEPTH);

     
    // memory + pointers
   
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [ADDR_WIDTH:0] wr_ptr;  // one extra bit for wrap detection
    reg [ADDR_WIDTH:0] rd_ptr;
    reg [ADDR_WIDTH:0] count;

    
    // status flags
   
    assign full  = (count == DEPTH);
    assign empty = (count == 0);

   
    // valid operation logic  
   
    wire write_ok;
    wire read_ok;

     
    assign write_ok = wr_en && (!full || rd_en);
    assign read_ok  = rd_en && (!empty || wr_en);

     
    // sequential logic  
     
    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            dout   <= 0;
        end
        else begin

            // write operation
            if (write_ok) begin
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= din;
                wr_ptr <= wr_ptr + 1;
            end

            //read operation
            if (read_ok) begin
                dout <= mem[rd_ptr[ADDR_WIDTH-1:0]];
                rd_ptr <= rd_ptr + 1;
            end

            //count update
            case ({write_ok, read_ok})
                2'b10: count <= count + 1;  // write only
                2'b01: count <= count - 1;  // read only
                default: count <= count;    // none or both (net zero)
            endcase

        end
    end

endmodule