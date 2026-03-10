module shiftreg #(
    parameter WIDTH = 8
)(
    input  wire             clk,

    input  wire             i_en,

    input  wire             i_load_en,
    input  wire [WIDTH-1:0] i_load_data, 

    output wire             o_out
);

reg [WIDTH:0] data;

always @(posedge clk) begin
    if (i_load_en) begin
        data <= {1'b0, i_load_data};
    end else if (i_en) begin
        data <= data << 1;
    end
end

assign o_out = data[WIDTH];

endmodule
