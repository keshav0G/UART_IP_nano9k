module top (
    input clk,
    input rst_btn,
    output uart_tx
);

wire rst = ~rst_btn; // active low buttons
wire baud_tick;
reg [7:0] tx_data;
reg wr_en;

wire tx_busy;
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
    .tx_busy(tx_busy)

);
    


always @(posedge clk) begin

        if (rst) begin
            tx_data <= 8'h41;      // ASCII 'A'
            wr_en   <= 1'b0;
        end
        else begin

            // Default: don't request a transmission
            wr_en <= 1'b0;

            // When transmitter is idle, send another 'A'
            if (!tx_busy) begin
                tx_data <= 8'h41;
                wr_en   <= 1'b1;   // One-clock pulse
            end

        end

    end
    
endmodule