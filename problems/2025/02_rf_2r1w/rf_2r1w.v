module rf_2r1w #(
    parameter WIDTH = 32,
    parameter DEPTH = 32
)(
    input  wire                             clk,

    input  wire    [1:0][$clog2(DEPTH)-1:0] i_rd_addr,
    output wire            [1:0][WIDTH-1:0] o_rd_data,

    input  wire         [$clog2(DEPTH)-1:0] i_wr_addr,
    input  wire                 [WIDTH-1:0] i_wr_data,
    input                                   i_wr_en
);

reg [WIDTH-1:0] data [DEPTH-1:0];

generate
for (genvar i = 0; i < 2; i = i + 1) begin : gen_rd_channels
    assign o_rd_data[i] = data[i_rd_addr[i]];
end
endgenerate

always @(posedge clk) begin
    if (i_wr_en) begin
        data[i_wr_addr] <= i_wr_data;
    end
end

endmodule
