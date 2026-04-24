module mem_xbar #(
    parameter DATA_START = 30'h0400,
    parameter DATA_LIMIT = 30'h3FFF,
    parameter MMIO_START = 30'h0000,
    parameter MMIO_LIMIT = 30'h03FF
)(
    input  wire        clk,

    input  wire [29:0] i_addr,
    input  wire [31:0] i_data,
    input  wire        i_wren,
    input  wire  [3:0] i_mask,
    output reg  [31:0] o_data,
    
    output wire [29:0] o_dmem_addr,
    output wire [31:0] o_dmem_data,
    output reg         o_dmem_wren,
    output wire  [3:0] o_dmem_mask,
    input  wire [31:0] i_dmem_data,

    output wire [29:0] o_mmio_addr,
    output wire [31:0] o_mmio_data,
    output reg         o_mmio_wren,
    output wire  [3:0] o_mmio_mask,
    input  wire [31:0] i_mmio_data
);

reg select, select_d;

always @(*) begin
    select = 1'bX;
    if (DATA_START <= i_addr && i_addr <= DATA_LIMIT) begin
        select = 1'b0;
    end else if (MMIO_START <= i_addr && i_addr <= MMIO_LIMIT) begin
        select = 1'b1;
    end
end

always @(posedge clk) begin
    select_d <= select;
end

always @(*) begin
    o_dmem_wren = 1'b0;
    o_mmio_wren = 1'b0;

    if (select == 0) begin
        o_dmem_wren = i_wren;
    end else if (select == 1) begin
        o_mmio_wren = i_wren;
    end
end

assign o_dmem_data = i_data;
assign o_dmem_mask = i_mask;
assign o_dmem_addr = i_addr - DATA_START;

assign o_mmio_data = i_data;
assign o_mmio_addr = i_addr - MMIO_START;
assign o_mmio_mask = i_mask;

always @(*) begin
    o_data = {32{1'bX}};

    if (select_d == 0) begin
        o_data = i_dmem_data;
    end else if (select_d == 1) begin
        o_data = i_mmio_data;
    end
end

endmodule

