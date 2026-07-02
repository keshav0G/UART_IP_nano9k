`timescale 1ns/1ps

module transmitter_tb;

    reg clk;
    reg rst;
    reg clken;

    reg [7:0] tx_data;
    reg wr_en;

    wire tx;
    wire tx_busy;

    transmitter DUT(
        .clk(clk),
        .rst(rst),
        .clken(clken),
        .tx_data(tx_data),
        .wr_en(wr_en),
        .tx(tx),
        .tx_busy(tx_busy)
    );


//1 / 27 MHz = 37.037 ns
// half cycle = 18.5 ~ 19ns

    always #19 clk = ~clk;

    task baud_tick;
    begin
        @(posedge clk);
        clken = 1'b1;

        @(posedge clk);
        clken = 1'b0;
    end
    endtask

    initial begin
        clk= 0;
        rst = 1;
        clken = 0;

       repeat(5) @(posedge clk);

        rst = 1'b0;

        repeat(2) @(posedge clk);

         tx_data = 8'h41;
        wr_en   = 1'b1;

        @(posedge clk);
        wr_en = 1'b0;

        repeat(10)
            baud_tick();

        repeat(5) @(posedge clk);
 $finish;
    end


endmodule