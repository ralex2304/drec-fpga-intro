module clkdiv #(
    parameter IN_FREQ  = 50_000_000,
    parameter OUT_FREQ = 9600
)(
    input  wire     clk,
    input  wire     rst_n,
    output wire     o_clk
);

localparam COUNTER_W = $clog2(IN_FREQ/OUT_FREQ);

reg [COUNTER_W-1:0] counter;

assign o_clk = (counter == IN_FREQ/OUT_FREQ);

always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        counter <= {COUNTER_W{1'b0}};
    else if (o_clk)
        counter <= {COUNTER_W{1'b0}};
    else
        counter <= counter + 1;
end

endmodule
