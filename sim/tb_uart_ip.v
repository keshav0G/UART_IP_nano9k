//testbench uses the tx module to send a byte to the rx bit 
//and prints the received data to monitor
module uart_tb ;
     reg clk;
    reg rst;
    wire rxclk_en;
    wire txclk_en;

    reg [7:0] tx_data;
    reg wr_en;

    wire tx_busy;

//initialise clock 
initial begin
    clk = 0;
end

//1 / 27 MHz = 37.037 ns
// half cycle = 18.5 ~ 19ns

always #19 clk = ~clk;

//baud generator
    baud_rate_gen #(
    .CLK_FRE(27_000_000),
    .BAUD_RATE(115200)
    ) baud(
    .clk(clk),
    .rst(rst),
    .txclk_en(txclk_en),
    .rxclk_en(rxclk_en)
    );

 wire serial_line; // connects rx and tx
//transmitter
 wire tx_done;
    transmitter tx_inst(
        .clk(clk),
        .rst(rst),
        .clken(txclk_en),
        .tx_data(tx_data),
        .wr_en(wr_en),
        .tx(serial_line),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

 wire [7:0] rx_data;
wire rx_valid;
//receiver

    receiver rx_inst(
          .clk(clk),
    .rst(rst),
    .clken(rxclk_en), //
    .rx(serial_line),
    .rx_data(rx_data),
    .rx_valid(rx_valid) 
    );

    //for waveform
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, uart_tb);
end

//task to send one byte
task send_byte;
input [7:0] data;
begin

    while(tx_busy)
        @(posedge clk);

    tx_data = data;
    wr_en   = 1'b1;

    // Wait until transmitter accepts it
    while(!tx_busy)
        @(posedge clk);

    wr_en = 1'b0;

end
endtask


    initial begin
    rst=1; 
    
    wr_en = 1;
    tx_data = 8'h00;

     #200;
        rst = 0;

        #200;
           send_byte(8'h55);

    //#10000;
    send_byte(8'hAA);
    //#10000;
    send_byte(8'h41);
    //#10000
    send_byte(8'h00);
    //#10000;
    send_byte(8'hFF);
    #50000;

    $finish;

    end
    
//print received data
    always @(posedge clk) begin

    if(rx_valid)
        $display("Received = %h", rx_data);
        
end

endmodule



