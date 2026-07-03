// uart transmitter 8 bit data + 1 start bit + 1 stop bit no parity bits
// improvement would be to add fifo buffer 
module transmitter (
    input wire [7:0] tx_data,
    input wire wr_en,
    input wire clk,
    input wire rst,
    input wire clken,
    output reg tx,
    output wire tx_busy,
    output reg tx_done
);

// initial begin
//     tx = 1'b1;
// end

localparam STATE_IDLE = 2'b00;
localparam STATE_DATA = 2'b10 ;
localparam STATE_START = 2'b01 ;
localparam STATE_STOP = 2'b11 ;

reg [7:0] data = 8'h00;
reg [2:0] bitpos = 3'h0; // data bit counter
reg[1:0] state = STATE_IDLE;

always@(posedge clk)begin

    tx_done <= 1'b0;

    if(rst)begin
        tx<= 1'b1;
        state<= STATE_IDLE;
        bitpos <= 3'd0;
        data <= 8'd0;
        tx_done <= 1'b0;
    end else begin

    case(state)
    STATE_IDLE: begin
        tx <= 1'b1;
        if(wr_en) begin
            state <= STATE_START;
            data <= tx_data;
            bitpos <= 3'd0; 
        end
    end
    STATE_START : begin
        if(clken)begin
            tx <= 1'b0;  //sends one start bit and goes into data state
            state <= STATE_DATA;

        end
    end
    STATE_DATA : begin
        if(clken) begin
               $display("Time=%0t bit=%0d data=%b tx=%b",
             $time,
             bitpos,
             data[bitpos],
             tx);
             //prints bitpos, data and tx
            tx<= data[bitpos]; // Alternative implementation: Use a shift register instead of indexing data[bitpos].
            if(bitpos == 3'd7)begin
            state<= STATE_STOP;
            end else begin
                bitpos <= bitpos +3'd1;
                
            end
        end
    end
    STATE_STOP : begin
        if(clken)begin
            tx <= 1'b1;
            state <= STATE_IDLE;
            tx_done <= 1'b1;
    end
end
    default : begin
        tx <= 1'b1; //tx pulled high by default/ while idling

        state <= STATE_IDLE;
    end
    endcase
end
end

assign tx_busy = (state != STATE_IDLE);


endmodule