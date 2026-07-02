//baud rate generator to divide a 27MHz clock on the nano 9k into 115200 baud
// this generator however produces baud rate of 115384, ie error of 0.16%
// improvement would be to implement a fractional baud generator
module baud_rate_gen#( 
    parameter CLK_FRE = 27_000_000, //device clk freq
    parameter BAUD_RATE = 115200 // serial baud rate
)(input wire clk,
input wire rst,
output wire rxclk_en,
output wire txclk_en);

localparam integer RX_ACC_MAX = CLK_FRE/ (BAUD_RATE*16) ; //why 16? cuz were oversampling 16 bits instead of 8 
localparam integer TX_ACC_MAX = CLK_FRE / BAUD_RATE; // tx does not need to oversample
localparam RX_ACC_WIDTH = $clog2(RX_ACC_MAX); //counter width needed 
localparam TX_ACC_WIDTH = $clog2(TX_ACC_MAX); //since localparam cannot be overriden from outside
reg [RX_ACC_WIDTH - 1:0] rx_acc = 0; // this stores the count 
reg [TX_ACC_WIDTH - 1:0] tx_acc = 0;

//reset outputs
assign rxclk_en = (rx_acc == 0);
assign txclk_en = (tx_acc == 0);

if(rst) tx_acc = 0; 

always @(posedge clk)begin
    if(rx_acc == RX_ACC_MAX -1)
    rx_acc <= 0;
    else 
        rx_acc <= rx_acc + 1'b1;
end

always @(posedge clk)begin
    if (tx_acc== TX_ACC_MAX -1) begin
        tx_acc <= 0;
    end else begin
            tx_acc <= tx_acc + 1'b1;
    end
end

endmodule
