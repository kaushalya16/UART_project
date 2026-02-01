module uart_rx #(
    parameter DATABITS = 8
)(
    input  wire                 clk,
    input  wire                 reset,
    input  wire                 baud16,
    input  wire                 rx_line,
    output reg  [DATABITS-1:0]  rx_data,
    output reg                  rx_done,
    output reg                  parity_error
);

    localparam IDLE   = 3'd0;
    localparam START  = 3'd1;
    localparam DATA   = 3'd2;
    localparam PARITY = 3'd3;
    localparam STOP   = 3'd4;
    localparam DONE   = 3'd5;

    reg [2:0] state;
    reg [3:0] sample_cnt;
    reg [3:0] bit_cnt;
    reg [DATABITS-1:0] data_reg;
    reg rx_parity;
    reg first_bit;

    always @(posedge clk) begin
        if (reset) begin
            state         <= IDLE;
            sample_cnt   <= 0;
            bit_cnt      <= 0;
            data_reg     <= 0;
            rx_parity    <= 0;
            rx_data      <= 0;
            rx_done      <= 0;
            parity_error <= 0;
            first_bit    <= 0;
        end else begin
            rx_done <= 1'b0;

            if (baud16) begin
                case (state)

                    IDLE: begin
                        parity_error <= 1'b0;
                        if (!rx_line) begin
                            sample_cnt <= 0;
                            state <= START;
                        end
                    end

                    START: begin
                        sample_cnt <= sample_cnt + 1;
                        if (sample_cnt == 4'd7) begin
                            if (!rx_line) begin
                                sample_cnt <= 0;
                                bit_cnt <= 0;
                                first_bit <= 1'b1;
                                state <= DATA;
                            end else begin
                                state <= IDLE;
                            end
                        end
                    end

                    DATA: begin
                        sample_cnt <= sample_cnt + 1;

                        if (first_bit) begin
                            if (sample_cnt == 4'd15) begin
                                sample_cnt <= 0;
                                first_bit <= 1'b0;
                            end
                        end else begin
                            if (sample_cnt == 4'd15) begin
                                data_reg[bit_cnt] <= rx_line;
                                sample_cnt <= 0;
                                bit_cnt <= bit_cnt + 1;
                                if (bit_cnt == DATABITS-1)
                                    state <= PARITY;
                            end
                        end
                    end

                    PARITY: begin
                        sample_cnt <= sample_cnt + 1;
                        if (sample_cnt == 4'd15) begin
                            rx_parity <= rx_line;
                            sample_cnt <= 0;
                            state <= STOP;
                        end
                    end

                    STOP: begin
                        sample_cnt <= sample_cnt + 1;
                        if (sample_cnt == 4'd15) begin
                            sample_cnt <= 0;
                            state <= DONE;
                        end
                    end

                    DONE: begin
                        parity_error <= (rx_parity != ^data_reg);
                        rx_data <= data_reg;
                        rx_done <= 1'b1;
                        state <= IDLE;
                    end

                endcase
            end
        end
    end

endmodule
