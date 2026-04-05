module mux4 #(
    parameter DATA_WIDTH = 32
)(
    input  wire                 [1:0] i_select,
    input  wire    [4*DATA_WIDTH-1:0] i_data,

    output wire      [DATA_WIDTH-1:0] o_data
);

wire [DATA_WIDTH-1:0] data [3:0];

generate
genvar i;
for (i = 0; i < 4; i = i + 1) begin : genDataArr
	assign data[i] = i_data[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH];
end
endgenerate

assign o_data = data[i_select];

endmodule
