module uart_sender(input clk, wr_enb, rst, input[7:0] data_in, output reg tx, output busy);

parameter idle_state = 2'b00;
parameter start_state = 2'b01;
parameter data_state = 2'b10;
parameter stop_state = 2'b00;

reg[7:0] data;
reg [2:0] index;
reg[1:0] state = idle_state;

always@(posedge clk)
    begin 
        if(rst)
            tx = 1'b1;
        end

always@(posedge clk)
    begin 
        case(state)
                idle_state:
                    begin 
                        if(wr_enb)
                            begin
                                state <= start_state;
                                data <= data_in;
                                index <= 3'h0;
                            end
                        else
                            state <= idle_state;
                        end

                start_state:
                    begin
                        if(enb)
                            begin 
                                tx <= 1'b0;
                                state <= data_state;
                            end
                        else
                            sta <= start_state;
                    end

                data_state:
                    begin
                        if(enb)
                            begin
                                if(index == 3'h7)
                                    state <= stop_state;
                                else    
                                    index = index + 3'h1;
                                tx<= data[index];

                                end
                    end
                
                stop_state:
                    begin
                        if(enb)
                            begin
                                tx <= 1'b1;
                                state <= idle_state;

                            end
                    end

                default : begin
                    tx <= 1'b1;
                    state <= idle_state;

                end
            endcase
        end
    assign busy = (state != idle_state);



                    
