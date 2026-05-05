`include "config.vh"

module system_top(
    input  wire in_clk,
    input  wire rst_n,

    output wire o_stcp,
    output wire o_shcp,
    output wire o_ds,
    output wire o_oe
);

localparam NUM_CORES = 2;

wire [3:0] anodes;
wire [7:0] segments;

wire [29:0] cpu2mmio_addr [NUM_CORES-1:0];
wire [31:0] cpu2mmio_data [NUM_CORES-1:0];
wire  [3:0] cpu2mmio_mask [NUM_CORES-1:0];
wire        cpu2mmio_wren [NUM_CORES-1:0];
wire        cpu2mmio_rden [NUM_CORES-1:0];
wire [31:0] mmio2cpu_data [NUM_CORES-1:0];

wire [15:0] hexd_data     [NUM_CORES-1:0];
reg  [15:0] hexd_data_reg [NUM_CORES-1:0];
wire  [1:0] hexd_mask     [NUM_CORES-1:0];
wire        hexd_wren     [NUM_CORES-1:0];

wire [31:0] mmio2cdc_fifo_data  [NUM_CORES-1:0];
wire        mmio2cdc_fifo_put   [NUM_CORES-1:0];
wire [31:0] cdc_fifo2mmio_data  [NUM_CORES-1:0];
wire        mmio2cdc_fifo_get   [NUM_CORES-1:0];
wire        cdc_fifo2mmio_empty [NUM_CORES-1:0];
wire        cdc_fifo2mmio_full  [NUM_CORES-1:0];

wire clk [1:0];

pll_55MHz pll_55MHz (
    .inclk0 (in_clk),
    .c0     (clk[0])
);

pll_65MHz pll_65MHz (
    .inclk0 (in_clk),
    .c0     (clk[1])
);

generate
genvar core_i;
for (core_i = 0; core_i < NUM_CORES; core_i = core_i + 1) begin : genCores
    cpu_top cpu_top(
        .clk        (clk[core_i]),
        .rst_n      (rst_n),
        .o_mmio_addr(cpu2mmio_addr[core_i]),
        .o_mmio_data(cpu2mmio_data[core_i]),
        .o_mmio_mask(cpu2mmio_mask[core_i]),
        .o_mmio_wren(cpu2mmio_wren[core_i]),
        .o_mmio_rden(cpu2mmio_rden[core_i]),
        .i_mmio_data(mmio2cpu_data[core_i])
    );

    mmio_xbar mmio_xbar(
        .clk        (clk[core_i]),
        .i_mmio_addr(cpu2mmio_addr[core_i][9:0]),
        .i_mmio_data(cpu2mmio_data[core_i]),
        .i_mmio_mask(cpu2mmio_mask[core_i]),
        .i_mmio_wren(cpu2mmio_wren[core_i]),
        .i_mmio_rden(cpu2mmio_rden[core_i]),
        .o_mmio_data(mmio2cpu_data[core_i]),

        .o_cdc_fifo_data (mmio2cdc_fifo_data[core_i]),
        .o_cdc_fifo_put  (mmio2cdc_fifo_put[core_i]),
        .i_cdc_fifo_data (cdc_fifo2mmio_data[core_i]),
        .o_cdc_fifo_get  (mmio2cdc_fifo_get[core_i]),
        .i_cdc_fifo_empty(cdc_fifo2mmio_empty[core_i]),
        .i_cdc_fifo_full (cdc_fifo2mmio_full[core_i]),

        .i_core_id  (core_i),

        .o_hexd_data(hexd_data[core_i]),
        .o_hexd_mask(hexd_mask[core_i]),
        .o_hexd_wren(hexd_wren[core_i]),
        .i_hexd_data(hexd_data_reg[core_i])
    );
end
endgenerate

async_fifo async_fifo (
    .wrclk  (clk[0]),
    .wrreq  (mmio2cdc_fifo_put[0]),
    .wrfull (cdc_fifo2mmio_full[0]),
    .data   (mmio2cdc_fifo_data[0]),

    .rdclk  (clk[1]),
    .rdreq  (mmio2cdc_fifo_get[1]),
    .rdempty(cdc_fifo2mmio_empty[1]),
    .q      (cdc_fifo2mmio_data[1])
);

generate
genvar i;
for (i = 0; i < 2; i = i + 1) begin : genHexDispDataReg
    always @(posedge clk[1]) begin
        if (hexd_wren[1] && hexd_mask[1][i])
            hexd_data_reg[1][(i+1)*8-1:i*8] <= hexd_data[1][(i+1)*8-1:i*8];
    end
end
endgenerate


hex_display hex_display(
    .clk        (clk[1]         ),
    .rst_n      (rst_n          ),
    .i_num      (hexd_data_reg[1]),
    .i_dots     (4'b0           ),
    .o_anodes   (anodes         ),
    .o_segments (segments       )
);


ctrl_74hc595 ctrl_74hc595(
    .clk    (clk[1]             ),
    .rst_n  (rst_n              ),
    .i_data ({segments, anodes} ),
    .o_stcp (o_stcp             ),
    .o_shcp (o_shcp             ),
    .o_ds   (o_ds               ),
    .o_oe   (o_oe               )
);

endmodule
