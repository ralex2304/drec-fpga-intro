`include "config.vh"

module system_top(
    input  wire clk,
    input  wire rst_n,

    output wire [3:0] anodes,
    output wire [7:0] segments
);

wire [15:0] hexd_data;
wire        hexd_wren;

wire [29:0] cpu2mmio_addr;
wire [31:0] cpu2mmio_data;
wire  [3:0] cpu2mmio_mask;
wire        cpu2mmio_wren;
wire [31:0] mmio2cpu_data;

reg [15:0] hexd_data_reg;
wire [1:0] hexd_mask;

cpu_top cpu_top(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .o_mmio_addr(cpu2mmio_addr  ),
    .o_mmio_data(cpu2mmio_data  ),
    .o_mmio_mask(cpu2mmio_mask  ),
    .o_mmio_wren(cpu2mmio_wren  ),
    .i_mmio_data(mmio2cpu_data  )
);

mmio_xbar mmio_xbar (
    .i_mmio_addr(cpu2mmio_addr[9:0]),
    .i_mmio_data(cpu2mmio_data  ),
    .i_mmio_mask(cpu2mmio_mask  ),
    .i_mmio_wren(cpu2mmio_wren  ),
    .o_mmio_data(mmio2cpu_data  ),

    .o_hexd_data(hexd_data      ),
    .o_hexd_mask(hexd_mask      ),
    .o_hexd_wren(hexd_wren      ),
    .i_hexd_data(hexd_data_reg  )
);

generate
genvar i;
for (i = 0; i < 2; i = i + 1) begin : genHexDispDataReg
    always @(posedge clk) begin
        if (hexd_wren && hexd_mask[i])
            hexd_data_reg[(i+1)*8-1:i*8] <= hexd_data[(i+1)*8-1:i*8];
    end
end
endgenerate

hex_display hex_display(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .i_num      (hexd_data_reg  ),
    .i_dots     (4'b0           ),
    .o_anodes   (anodes         ),
    .o_segments (segments       )
);

endmodule
