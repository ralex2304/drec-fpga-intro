module rf_2r1w #(
    parameter WIDTH = 32,
    parameter DEPTH = 32
)(
    input  wire                             clk,

    input  wire         [$clog2(DEPTH)-1:0] i_rd_addr_a,
    output wire                 [WIDTH-1:0] o_rd_data_a,

    input  wire         [$clog2(DEPTH)-1:0] i_rd_addr_b,
    output wire                 [WIDTH-1:0] o_rd_data_b,

    input  wire         [$clog2(DEPTH)-1:0] i_wr_addr,
    input  wire                 [WIDTH-1:0] i_wr_data,
    input                                   i_wr_en
);

reg [WIDTH-1:0] data [DEPTH-1:0];

assign o_rd_data_a = i_rd_addr_a == 0 ? {WIDTH{1'b0}} : data[i_rd_addr_a];
assign o_rd_data_b = i_rd_addr_b == 0 ? {WIDTH{1'b0}} : data[i_rd_addr_b];

always @(posedge clk) begin
    if (i_wr_en && i_wr_addr != 0) begin
        data[i_wr_addr] <= i_wr_data;
    end
end

endmodule
