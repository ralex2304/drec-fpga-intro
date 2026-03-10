module lfsr #(
    parameter WIDTH = 8,
    parameter CHARACTERISTIC = 8'hFA //< https://users.ece.cmu.edu/~koopman/lfsr/index.html
)(
    input  wire             clk,
    input  wire             rst_n,

    output reg  [WIDTH-1:0] o_out
);

reg [WIDTH:0] xor_reg;

always @(*) begin
    xor_reg[0] = 1'b0;
    for (integer i = 0; i < WIDTH; i = i + 1) begin
        if (CHARACTERISTIC[i]) begin
            xor_reg[i+1] = xor_reg[i] ^ o_out[i];
        end else begin
            xor_reg[i+1] = xor_reg[i];
        end
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        o_out <= {WIDTH{1'b1}};
    end else begin
        o_out[0]         <= xor_reg[WIDTH];
        o_out[WIDTH-1:1] <= o_out[WIDTH-2:0];
    end
end

endmodule
