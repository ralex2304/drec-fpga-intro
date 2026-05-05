module mmio_xbar (
    input              clk,

    input  wire  [9:0] i_mmio_addr,
    input  wire [31:0] i_mmio_data,
    input  wire  [3:0] i_mmio_mask,
    input  wire        i_mmio_wren,
    input  wire        i_mmio_rden,
    output reg  [31:0] o_mmio_data,

    output wire [31:0] o_cdc_fifo_data,
    output reg         o_cdc_fifo_put,
    input  wire [31:0] i_cdc_fifo_data,
    output reg         o_cdc_fifo_get,
    input  wire        i_cdc_fifo_empty,
    input  wire        i_cdc_fifo_full,

    input  wire [31:0] i_core_id,

    output wire [15:0] o_hexd_data,
    output wire  [1:0] o_hexd_mask,
    output reg         o_hexd_wren,
    input  wire [15:0] i_hexd_data
);

wire [9:0] select;
reg  [9:0] select_d;

assign select = i_mmio_addr - 9'h4;

always @(posedge clk) begin
    select_d <= select;
end

always @(*) begin
    o_cdc_fifo_put = 1'b0;
    o_cdc_fifo_get = 1'b0;
    o_hexd_wren    = 1'b0;

    if (select == 9'd0) begin
        o_cdc_fifo_put = i_mmio_wren;
        o_cdc_fifo_get = i_mmio_rden;
    end else if (select == 9'd4) begin
        o_hexd_wren = i_mmio_wren;
    end
end

assign o_cdc_fifo_data = i_mmio_data;

assign o_hexd_data = i_mmio_data[15:0];
assign o_hexd_mask = i_mmio_mask[1:0];

always @(*) begin
    case (select_d)
        9'd0:    o_mmio_data = i_cdc_fifo_data;
        9'd1:    o_mmio_data = {31'b0, i_cdc_fifo_full};
        9'd2:    o_mmio_data = {31'b0, i_cdc_fifo_empty};
        9'd3:    o_mmio_data = i_core_id;
        9'd4:    o_mmio_data = {16'b0, i_hexd_data};

        default: o_mmio_data = 32'bX;
    endcase
end

endmodule

