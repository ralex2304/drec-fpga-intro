`timescale 1ns/1ps

module lfsr_tb();

localparam WIDTH = 8;
localparam CHARACTERISTIC = 8'hFA; //< https://users.ece.cmu.edu/~koopman/lfsr/index.html

reg clk   = 1'b0;
reg rst_n = 1'b1;

always begin
    #1 clk <= ~clk;
end

wire [WIDTH-1:0] o_out;

reg [WIDTH-1:0] initial_value;

integer counter = 1;

initial begin
    $dumpvars;

    #1 rst_n <= 1'b0;
    #1 rst_n <= 1'b1;

    initial_value <= o_out;
    @(posedge clk);
    @(posedge clk);
    while (o_out !== initial_value) begin
        counter = counter + 1;
        @(posedge clk);
    end

    if (counter !== (2**WIDTH - 1)) begin
        $display("[FAIL] period=%d, expected %d", counter, 2**WIDTH - 1);
    end else begin
        $display("[PASS]");
    end
    $finish;
end

lfsr #(
    .WIDTH           (WIDTH),
    .CHARACTERISTIC  (CHARACTERISTIC)
) u_lfsr(
    .clk             (clk),
    .rst_n           (rst_n),
    .o_out           (o_out)
);

endmodule
