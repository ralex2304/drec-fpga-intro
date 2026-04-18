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

wire [$clog2(DEPTH)-1:0] rd_addr [1:0];
assign rd_addr[0] = i_rd_addr_a;
assign rd_addr[1] = i_rd_addr_b;
reg [WIDTH-1:0] rd_data [1:0];
assign o_rd_data_a = rd_data[0];
assign o_rd_data_b = rd_data[1];

generate
genvar i;
for ( i = 0; i < 2; i = i + 1) begin : genRdPorts
    always @(*) begin
        if (rd_addr[i] == 0) begin
            rd_data[i] = {WIDTH{1'b0}};
        end else if (i_wr_en && rd_addr[i] == i_wr_addr) begin //< bypass
            rd_data[i] = i_wr_data;
        end else begin
            rd_data[i] = data[rd_addr[i]];
        end
    end
end
endgenerate

always @(posedge clk) begin
    if (i_wr_en && i_wr_addr != 0) begin
        data[i_wr_addr] <= i_wr_data;
    end
end

endmodule
