module uart_top #(
    parameter DATABITS = 8,
    parameter BAUD_DIV = 5208
)(
    input  wire                    clk,
    input  wire                    reset,
    input  wire                    tx_start,
    input  wire [DATABITS-1:0]     tx_data,
    input  wire                    rx_line,
    output wire                    tx_line,
    output wire [DATABITS-1:0]     rx_data,
    output wire                    rx_done,
    output wire                    parity_error
);

    wire baud_tick;
    wire baud16;

    baud_gen #(
        .BAUD_DIV(BAUD_DIV)
    ) u_baud (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    baud16 #(
        .BAUD_DIV1(BAUD_DIV/16)
    ) u_baud16 (
        .clk(clk),
        .reset(reset),
        .baud16(baud16)
    );

    uart_tx #(
        .DATABITS(DATABITS)
    ) u_tx (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_line(tx_line)
    );

    uart_rx #(
        .DATABITS(DATABITS)
    ) u_rx (
        .clk(clk),
        .reset(reset),
        .baud16(baud16),
        .rx_line(rx_line),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .parity_error(parity_error)
    );

endmodule
