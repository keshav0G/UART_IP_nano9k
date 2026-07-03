module top (
    input clk,
    input rst_btn,
    output uart_tx
);

wire rst = ~rst_btn; // active low buttons
wire baud_tick;
reg [7:0] tx_data;
reg wr_en;

//delay counter
reg[24:0] delay_cnt;
reg waiting;

//create a ROM to hold the message
reg [7:0] message [0:12];
reg[3:0] msg_index;

wire tx_done;
wire tx_busy;

reg first_send;// tx_done stays in low until the first byte is kickstarted

initial begin
    message[0]  = "H";
    message[1]  = "e";
    message[2]  = "l";
    message[3]  = "l";
    message[4]  = "o";
    message[5]  = " ";
    message[6]  = "F";
    message[7]  = "P";
    message[8]  = "G";
    message[9]  = "A";
    message[10] = "!";
    message[11] = 8'h0D;   // Carriage Return
message[12] = 8'h0A;   // Line Feed
end


//instantiate baude generator
baud_rate_gen#(
    .CLK_FRE(27_000_000),
    .BAUD_RATE(115200)
) baud_gen(

    .clk(clk),
    .rst(rst),

    .txclk_en(baud_tick),
    .rxclk_en() // no use for rx yet

);


// instantiate transmitter 
transmitter tx(

    .clk(clk),
    .rst(rst),
    .clken(baud_tick),

    .tx_data(tx_data),
    .wr_en(wr_en),

    .tx(uart_tx),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);
    


always @(posedge clk) begin

        if (rst) begin
            // tx_data <= 8'h41;      // ASCII 'A'
            tx_data    <= 8'h00;
            wr_en      <= 1'b0;
            msg_index  <= 0;
            delay_cnt  <= 0;
            waiting    <= 0;
            first_send <= 1'b1;
        end
        else begin

            // Default: don't request a transmission
            wr_en <= 1'b0;

//delay before sending
            if(waiting) begin

                if(delay_cnt == 27_000_000-1) begin
                    delay_cnt <= 0;
                    waiting <= 0;
                    msg_index <= 0;

                    first_send <= 1'b1;
                end
                else begin
                    delay_cnt <= delay_cnt + 1'b1;
                end

            end            
            // When transmitter is idle, send another 'A'
            else if (tx_done ||first_send) begin
                //tx_data <= 8'h41; //sends a stream of 'A' on the serial
                tx_data <= message[msg_index];
                wr_en   <= 1'b1;   // One-clock pulse
                first_send <= 1'b0;
                
                if(msg_index == 12)begin
                    waiting<= 1'b1;
                end
                else begin
                msg_index <= msg_index + 1;
                
                end
            end

        end

    end
    
endmodule