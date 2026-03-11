module hex_display (
    input  wire             clk,
    input  wire             rst_n,

    input  wire      [15:0] i_num,
    input  wire       [3:0] i_dots,

    output wire     [4-1:0] o_anodes,
    output reg      [8-1:0] o_segments
);

reg [13:0] counter;
wire [1:0] pos = counter[13:12];
assign o_anodes = ~(4'b1 << pos);

always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        counter <= 14'b0;
    else
        counter <= counter + 1'b1;
end

wire [3:0] num = (i_num >> (pos * 4)) & 16'hF;

always @(*) begin
    case (num)
        4'h0:    o_segments[7:1] = 7'b1111110;
        4'h1:    o_segments[7:1] = 7'b0110000;
        4'h2:    o_segments[7:1] = 7'b1101101;
        4'h3:    o_segments[7:1] = 7'b1111001;
        4'h4:    o_segments[7:1] = 7'b0110011;
        4'h5:    o_segments[7:1] = 7'b1011011;
        4'h6:    o_segments[7:1] = 7'b1011111;
        4'h7:    o_segments[7:1] = 7'b1110000;
        4'h8:    o_segments[7:1] = 7'b1111111;
        4'h9:    o_segments[7:1] = 7'b1111011;
        4'hA:    o_segments[7:1] = 7'b1110111;
        4'hb:    o_segments[7:1] = 7'b0011111;
        4'hC:    o_segments[7:1] = 7'b1001110;
        4'hd:    o_segments[7:1] = 7'b0111101;
        4'hE:    o_segments[7:1] = 7'b1001111;
        4'hF:    o_segments[7:1] = 7'b1000111;
        default: o_segments[7:1] = 7'b0000000;
    endcase

    o_segments[0] = i_dots[pos];
end


endmodule
