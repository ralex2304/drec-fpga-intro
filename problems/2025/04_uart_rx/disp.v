module disp (
    input  wire             clk,
    input  wire             rst_n,

    input  wire      [31:0] i_data,

    output wire     [4-1:0] o_anodes,
    output wire     [8-1:0] o_segments
);

reg [13:0] counter;
wire [1:0] pos = counter[13:12];
assign o_anodes = ~(4'b1 << pos);

always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        counter <= 14'b0;
    else
        counter <= counter + 1'b1;
end

assign o_segments = (i_data >> (pos * 8)) & 32'hFF;

endmodule
