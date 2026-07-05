module receiver (
    input wire clk,
    input wire rst,
    input wire clken, //
    input wire rx,
    output reg[7:0] rx_data,
    output reg rx_valid 
);

reg rx_sync1;
reg rx_sync2;

reg[7:0] rx_shift; // temporary register holds the rx data unitl succesful reception

//state machine code
localparam S_IDLE      = 3'd0;
localparam S_WAIT_HALF = 3'd1; // waits for the middle to sample rx
localparam S_DATA      = 3'd2;
localparam S_STOP      = 3'd3;
reg[2:0]                         state;
//reg[2:0]                         next_state;

//counters
reg [3:0] sample_cnt;    // counts 0-15
reg [2:0] bitpos;        // counts 0-7


wire start_detect;
reg rx_prev;  // falling edge detetction

assign start_detect = rx_prev & ~rx_sync2;

always@(posedge clk) begin
    
    rx_sync1 <= rx;
    rx_sync2 <= rx_sync1; // form here on we'll refernce rx_sync2 everywhere instead of rx
end


always @(posedge clk) begin

    if(rst)
        rx_prev <= 1'b1;
    else
        rx_prev <= rx_sync2;

end

always @(posedge clk) begin
     if(rst)begin
        state<= S_IDLE;
        sample_cnt <= 0;
        bitpos<= 0;
        rx_valid<= 0;
        rx_data <= 0;
     end else begin

        rx_valid <=0;
        case (state)
            S_IDLE:begin
                sample_cnt<= 0;
                bitpos<= 0;

                if(start_detect)
                state<= S_WAIT_HALF; // enter start state on entering start bit
            end 

            S_WAIT_HALF:begin
                if(clken) begin

                sample_cnt <= sample_cnt + 1'b1;

                if(sample_cnt == 4'd7) begin

                    sample_cnt <= 4'd0;

                    if(rx_sync2 == 1'b0) // if the line is still low it was a start bit
                        state <= S_DATA;
                    else
                        state <= S_IDLE; // if the rx line goes back up shortly up it was a noise 

                end

            end
            end
            S_DATA:begin
                if(clken)begin
                    sample_cnt <= sample_cnt+1;
                    if(sample_cnt == 4'd15)begin
                        sample_cnt <= 0;
                        //sample incoming bit
                        rx_shift[bitpos]<= rx_sync2;

                        if(bitpos == 3'd7)begin
                            bitpos<= 0;
                            state <= S_STOP;
                        end else begin
                            bitpos <= bitpos+1;

                        end
                    end
                end
            end
            S_STOP:begin
                if(clken) begin
                    sample_cnt <= sample_cnt + 1'b1;
                    if(sample_cnt == 4'd15) begin
                        sample_cnt <= 4'd0;
                        if(rx_sync2 == 1'b1) begin
                            rx_data  <= rx_shift;
                            rx_valid <= 1'b1;
                        end
                        state <= S_IDLE;
                    end
                end
            end
            default: state <= S_IDLE;
        endcase
     end
end
    
endmodule