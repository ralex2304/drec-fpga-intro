module fpga_top (
    input  wire CLK,

    input  wire [15:0] i_a,
    input  wire [15:0] i_b,

    output reg  [15:0] o_res
);

localparam LATENCY = 2;

reg [15:0] a, b;
wire [15:0] res;

always @(posedge CLK) begin
    a <= i_a;
    b <= i_b;
end

generate if (LATENCY == 0) begin : genPipe0
fp16add_pipe0 fp16add0 (
    .i_a      (a),
    .i_b      (b),
    .o_res    (res)
);
end else if (LATENCY == 1) begin : genPipe1
fp16add_pipe1 fp16add1 (
    .clk      (CLK),
    .i_a      (a),
    .i_b      (b),
    .o_res    (res)
);
end else if (LATENCY == 2) begin : genPipe2
fp16add_pipe2 fp16add2 (
    .clk      (CLK),
    .i_a      (a),
    .i_b      (b),
    .o_res    (res)
);
end
endgenerate

always @(posedge CLK) begin
    o_res <= res;
end

endmodule
