
module fifo_stub #(
    localparam WIDTH = 32,
    localparam DEPTH = 8
)(
    input  wire             clk,
    input  wire             rst_n,

    input  wire             i_wr_vld,
    input  wire [WIDTH-1:0] i_wr_data,

    input  wire             i_rd_en,
    output wire [WIDTH-1:0] o_rd_data,

    output reg              o_full,
    output reg              o_empty
);

fifo #(
    .WIDTH      (WIDTH),
    .DEPTH      (DEPTH)
) fifo_inst (
    .clk        (clk),
    .rst_n      (rst_n),

    .i_wr_vld   (i_wr_vld),
    .i_wr_data  (i_wr_data),

    .i_rd_en    (i_rd_en),
    .o_rd_data  (o_rd_data),

    .o_full     (o_full),
    .o_empty    (o_empty)
);

initial begin
    $dumpvars();
    #1;
end

endmodule
