module baud16#(parameter BAUD_DIV1=5208/16) (
    input  wire clk,
    input  wire reset,
    output reg  baud16
);

    
    
    reg [12:0] count;  

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            baud16 <= 0;
        end
        else if (count == BAUD_DIV1 - 1) begin
            count <= 0;
            baud16 <= 1;   
        end
        else begin
            count <= count + 1;
            baud16 <= 0;
        end
    end

endmodule
