module mmio_xbar (
    input              clk,

    input  wire  [9:0] i_mmio_addr,
    input  wire [31:0] i_mmio_data,
    input  wire  [3:0] i_mmio_mask,
    input  wire        i_mmio_wren,
    output reg  [31:0] o_mmio_data,

    output wire [15:0] o_hexd_data,
    output wire  [1:0] o_hexd_mask,
    output reg         o_hexd_wren,
    input  wire [15:0] i_hexd_data
);

reg select, select_d;

always @(*) begin
    select = 1'bX;

    if (i_mmio_addr == 10'h8) begin
        select = 1'b0;
    end
end

always @(posedge clk) begin
    select_d <= select;
end

always @(*) begin
    o_hexd_wren = 1'b0;

    if (select == 0) begin
        o_hexd_wren = i_mmio_wren;
    end
end

assign o_hexd_data = i_mmio_data[15:0];
assign o_hexd_mask = i_mmio_mask[1:0];

always @(*) begin
    o_mmio_data = {32{1'bX}};

    if (select_d == 0) begin
        o_mmio_data = {16'b0, i_hexd_data};
    end
end

endmodule

