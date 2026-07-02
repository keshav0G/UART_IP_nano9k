module uart ( input wire [7:0] din,
        input wire wr_en,
        input wire clk,
        output wire tx,
        output wire tx_busy,
        input wire rx,
        output wire rdy,
        input rdy_clr,
        output wire [7:0] dout);

        wire rxclk_en, txclk_en;

        baud_rate_gen uart_baud(.clk_50m(clk),
                                .rxclk_en(rxclk_en),
                                .txclk_en(txclk_en));
        transmitter uart_tx(.din,
                        .clk_50m,
                        .txclk_en,
                        .tx,
                        .tx_busy);

        receiver uart_rx(.rx,
                        .rdy,
                        .rdy_clr,
                        .clk_50m,
                        .rxclk_en,
                        .dout);
     
    
endmodule