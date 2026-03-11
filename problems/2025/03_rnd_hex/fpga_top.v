module fpga_top(
    input  wire CLK,
    input  wire RSTN,  // BUTTON RST (NEGATIVE)
    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

wire  [3:0] anodes;
wire  [7:0] segments;

reg  [15:0] rand_num;
wire [15:0] lfsr_out;

wire rand_gen_clk_en;

clkdiv #(
    .IN_FREQ   (50_000_000),
    .OUT_FREQ  (1)
) u_clkdiv(
    .clk       (CLK),
    .rst_n     (rst_n),
    .o_clk     (rand_gen_clk_en)
);

lfsr #(
    .WIDTH           (16),
    .CHARACTERISTIC  (16'h84E2)
) u_lfsr(
    .clk             (CLK),
    .rst_n           (rst_n),
    .o_out           (lfsr_out)
);

always @(posedge CLK) begin
    if (rand_gen_clk_en) begin
        rand_num <= lfsr_out;
    end
end

hex_display hex_display(CLK, rst_n, rand_num, 4'b0000, anodes, segments);

ctrl_74hc595d ctrl(
    .clk    (CLK                ),
    .rst_n  (rst_n              ),
    .i_data ({segments, anodes} ),
    .o_stcp (STCP               ),
    .o_shcp (SHCP               ),
    .o_ds   (DS                 ),
    .o_oe   (OE                 )
);

endmodule
