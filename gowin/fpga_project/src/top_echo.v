//expects input from pc via serial port and echos back what was sent
module top (
    input clk,
    input rst_btn,
    output uart_tx,
    input uart_rx
);
    
wire rst = ~rst_btn;

//baud generator instance
wire txclk_en;
wire rxclk_en;

baud_rate_gen #(
    .CLK_FRE(27_000_000),
    .BAUD_RATE(115200)
)
baud_inst
(
    .clk(clk),
    .rst(rst),

    .txclk_en(txclk_en),
    .rxclk_en(rxclk_en)
);

// transmitter instance

reg [7:0] tx_data;
reg wr_en;

wire tx_busy;
wire tx_done;

transmitter tx_inst
(
    .clk(clk),
    .rst(rst),
    .clken(txclk_en),

    .tx_data(tx_data),
    .wr_en(wr_en),

    .tx(uart_tx),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);

//receiver instance
wire [7:0] rx_data;
wire rx_valid;

receiver rx_inst
(
    .clk(clk),
    .rst(rst),
    .clken(rxclk_en),

    .rx(uart_rx),

    .rx_data(rx_data),
    .rx_valid(rx_valid)
);

// logic
always@(posedge clk)begin
    if(rst)begin
        tx_data <= 0;
        wr_en <= 0; // rest registers are reset in individual modules
    end else begin
        wr_en <= 0; //disabled by default

         if(rx_valid && !tx_busy) // if byte arrives and tx is idle/not busy
        begin
            tx_data <= rx_data ; // echo . you can also play around with this line to make cool offset effects 
            wr_en   <= 1'b1;
        end
    end


end
endmodule
