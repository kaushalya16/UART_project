module uart_tb;

    parameter DATABITS = 8;
    parameter BAUD_DIV = 5208;

    reg clk = 0;
    reg reset = 1;
    reg tx_start = 0;
    reg [DATABITS-1:0] tx_data = 8'h55;

    wire tx_line;
    wire [DATABITS-1:0] rx_data;
    wire rx_done;
    wire parity_error;

    always #5 clk = ~clk;

    uart_top #(
        .DATABITS(DATABITS),
        .BAUD_DIV(BAUD_DIV)
    ) dut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .rx_line(tx_line),
        .tx_line(tx_line),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .parity_error(parity_error)
    );

    initial begin
        reset = 1;
        #100;
        reset = 0;

        #200;
        tx_start = 1;
        #10;
        tx_start = 0;

        wait (rx_done);

        #20;
        $display("TX DATA = %h", tx_data);
        $display("RX DATA = %h", rx_data);
        $display("PARITY ERROR = %b", parity_error);

        #100;
        $stop;
    end

endmodule
