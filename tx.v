module uart_tx #(
    parameter DATABITS = 8
)(
    input  wire                 clk,
    input  wire                 reset,
    input  wire                 baud_tick,
    input  wire                 tx_start,
    input  wire [DATABITS-1:0]  tx_data,
    output reg                  tx_line
);

    reg [4:0] bit_cnt;
    reg [DATABITS+2:0] shift_reg;
    wire parity_bit;

    assign parity_bit = ^tx_data;

    always @(posedge clk) begin
        if (reset) begin
            tx_line  <= 1'b1;
            bit_cnt  <= 0;
            shift_reg <= 0;
        end
        else if (tx_start && bit_cnt == 0) begin
            shift_reg <= {1'b1, parity_bit, tx_data, 1'b0};
            bit_cnt   <= DATABITS + 3;
            tx_line   <= 1'b0;
        end
        else if (baud_tick && bit_cnt != 0) begin
            tx_line   <= shift_reg[0];
            shift_reg <= shift_reg >> 1;
            bit_cnt   <= bit_cnt - 1;
        end
    end

endmodule
