`timescale 1ns/1ps

module clkdiv_tb();

localparam TEST_DURATION = 10000000;

localparam [63:0] IN_FREQ  = 50_000_000;
localparam [63:0] OUT_FREQ = 9600;

reg clk   = 1'b0;
reg rst_n = 1'b1;

always begin
    #1 clk <= ~clk;
end

initial begin
    #1 rst_n <= 1'b0;
    #1 rst_n <= 1'b1;
end

wire o_clk;

clkdiv #(
    .IN_FREQ (IN_FREQ),
    .OUT_FREQ(OUT_FREQ)
) clkdiv (
    .clk    (clk),
    .rst_n  (rst_n),
    .o_clk  (o_clk)
);

reg [63:0] clk_count, o_clk_count;

always @(posedge clk) begin
    if (!rst_n) begin
        clk_count <= 0;
    end else begin
        clk_count <= clk_count + 1;
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        o_clk_count <= 0;
    end else if (o_clk) begin
        o_clk_count <= o_clk_count + 1;
    end
end

initial begin
    #TEST_DURATION
    $display("Out freq: %d, fact freq: %d", IN_FREQ * o_clk_count / clk_count, OUT_FREQ);
    $finish;
end

endmodule
