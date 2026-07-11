// adds two numbers received from mcu(stm32 blue pill) 
//and puts the ans on serial
// UART Protocol
// MCU --> FPGA : "<num1>,<num2>\n"
// Example      : "12,37\n"
// FPGA --> MCU : "<sum>\n"
// Example      : "49\n"
module top_add (
    input clk, 
    input rst_btn,
    input uart_rx,
    output uart_tx,
    output [5:0]LED
);

wire rst = ~rst_btn;

//baud generat;or instance
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
  

// registers to store incoming data
reg[5:0] num1,num2,sum;


//parser states

localparam WAIT_NUM1 = 0,WAIT_NUM2 = 1, CALCULATE = 2;
reg [2:0]parser_state;


always@(posedge clk)begin
    wr_en <=1'b0;

    if(rst)begin
        parser_state <= WAIT_NUM1;
          num1 <= 0;
            num2 <= 0;
            sum  <= 0;
    end else begin
        case (parser_state)
        WAIT_NUM1:begin
            //clear parser 
            // hundreds <= 0;
            // tens <= 0;
            // ones <= 0;
            // sum <= 0;
            if(rx_valid) begin

        if(rx_data >= "0" && rx_data <= "9") begin
           
           num1 <= num1 * 10 + (rx_data - "0");
        end

        else if(rx_data == ",") begin
            parser_state <= WAIT_NUM2;
        end

    end
        end 
        WAIT_NUM2:begin
            if(rx_valid) begin

        if(rx_data >= "0" && rx_data <= "9") begin
            num2 <= num2 * 10 + (rx_data - "0");
        end

        else if(rx_data == "\n") begin
            parser_state <= CALCULATE;
        end

    end
        end

       CALCULATE: begin
        sum <= num1 + num2;
        num1 <= 0;
        num2 <= 0;
        parser_state <= WAIT_NUM1;
        end
        endcase
    end

end

assign LED = ~sum;

endmodule
