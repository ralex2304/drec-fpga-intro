module mux4 #(
    parameter DATA_WIDTH = 32
)(
    input  wire                 [1:0] i_select,
    input  wire [3:0][DATA_WIDTH-1:0] i_data,

    output wire      [DATA_WIDTH-1:0] o_data
);

assign o_data = i_data[i_select];

endmodule
