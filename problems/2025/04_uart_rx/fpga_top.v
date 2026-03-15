module fpga_top(
    input  wire CLK,
    input  wire RSTN,

    input  wire RXD,
    output wire TXD,
    output wire [11:0] LED,

    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

localparam FREQ = 50_000_000;
localparam RATE = 2_000_000;

assign LED[0] = RXD;
assign LED[4] = TXD;
assign {LED[11:5], LED[3:1]}  = ~10'b0;

// RSTN synchronizer
reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

// RX synchronizer
reg rx, RXD_d;

always @(posedge CLK) begin
    rx    <= RXD_d;
    RXD_d <= RXD;
end

wire [7:0] rx_data;
wire rx_vld;

uart_rx #(
    .FREQ       (FREQ      ),
    .RATE       (RATE      )
) u_uart_rx (
    .clk        (CLK       ),
    .rst_n      (rst_n     ),
    .o_data     (rx_data   ),
    .o_vld      (rx_vld    ),
    .i_rx       (rx        )
);

wire  [3:0] anodes;
wire  [7:0] segments;

reg [31:0] disp_data;

disp disp(CLK, rst_n, disp_data, anodes, segments);

ctrl_74hc595d ctrl(
    .clk    (CLK                ),
    .rst_n  (rst_n              ),
    .i_data ({segments, anodes} ),
    .o_stcp (STCP               ),
    .o_shcp (SHCP               ),
    .o_ds   (DS                 ),
    .o_oe   (OE                 )
);

always @(posedge CLK, negedge rst_n) begin
    if (!rst_n) begin
        disp_data <= {32{1'b0}};
    end else if (rx_vld) begin
        disp_data <= {disp_data[23:0], rx_data};
    end
end

endmodule
