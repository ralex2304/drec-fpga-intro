module mem_xbar #(
    parameter DATA_START = 30'h0400,
    parameter DATA_LIMIT = 30'h3FFF,
    parameter MMIO_START = 30'h0000,
    parameter MMIO_LIMIT = 30'h03FF
)(
    input  wire [29:0] i_addr,
    input  wire [31:0] i_data,
    input  wire        i_wren,
    input  wire  [3:0] i_mask,
    output reg  [31:0] o_data,
    
    output reg  [29:0] o_dmem_addr,
    output reg  [31:0] o_dmem_data,
    output reg         o_dmem_wren,
    output reg   [3:0] o_dmem_mask,
    input  wire [31:0] i_dmem_data,

    output reg  [29:0] o_mmio_addr,
    output reg  [31:0] o_mmio_data,
    output reg         o_mmio_wren,
    output reg   [3:0] o_mmio_mask,
    input  wire [31:0] i_mmio_data
);

always @(*) begin
    o_dmem_addr = {30{1'bX}};
    o_dmem_data = {32{1'bX}};
    o_dmem_wren = 1'b0;
    o_dmem_mask = {4{1'bX}};
    o_mmio_addr = {30{1'bX}};
    o_mmio_data = {32{1'bX}};
    o_mmio_wren = 1'b0;
    o_mmio_mask = {4{1'bX}};

    o_data      = {32{1'bX}};

    if (DATA_START <= i_addr && i_addr <= DATA_LIMIT) begin
        o_dmem_addr = i_addr - DATA_START;
        o_dmem_data = i_data;
        o_dmem_wren = i_wren;
        o_dmem_mask = i_mask;
        o_data      = i_dmem_data;
    end else if (MMIO_START <= i_addr && i_addr <= MMIO_LIMIT) begin
        o_mmio_addr = i_addr - MMIO_START;
        o_mmio_data = i_data;
        o_mmio_wren = i_wren;
        o_mmio_mask = i_mask;
        o_data      = i_mmio_data;
    end
end

endmodule

