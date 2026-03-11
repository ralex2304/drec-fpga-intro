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

reg [9:0] cnt;
wire counter_clk;

clkdiv #(
    .IN_FREQ   (50_000_000),
    .OUT_FREQ  (10)
) u_clkdiv(
    .clk       (CLK),
    .rst_n     (rst_n),
    .o_clk     (counter_clk)
);

always @(posedge CLK, negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 10'd600;
    end else if (counter_clk) begin
        if (cnt == 10'b0) begin
            cnt <= 10'd600;
        end else begin
            cnt <= cnt - 10'b1;
        end
    end
end

reg [15:0] hex_disp_value;

integer i;
reg [9:0] cnt_convert;
always @(*) begin
    hex_disp_value = 16'b0;
    cnt_convert = cnt;
    for (i = 3; i >= 0; i = i - 1) begin
        hex_disp_value = (hex_disp_value >> 4) + ((cnt_convert % 10) << 12);
        cnt_convert = cnt_convert / 10;
    end
end

hex_display hex_display(CLK, rst_n, hex_disp_value, 4'b0010, anodes, segments);

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
