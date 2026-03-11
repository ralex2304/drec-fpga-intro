module ctrl_74hc595d #(
    parameter DATA_WIDTH = 12
)(
    input  wire                     clk,
    input  wire                     rst_n,

    input  wire    [DATA_WIDTH-1:0] i_data,

    output wire                     o_stcp,
    output wire                     o_shcp,
    output wire                     o_ds,
    output wire                     o_oe
);

assign o_oe = ~rst_n;

reg  [4:0] counter;
wire [3:0] position = counter[4:1];
wire [15:0] data = {{16-DATA_WIDTH{1'b0}}, i_data};

assign o_ds   = data[position];
assign o_shcp = (position <= (DATA_WIDTH-1)) && counter[0];
assign o_stcp = (position == DATA_WIDTH) && counter[0];

always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        counter <= 5'b0;
    else
        counter <= counter + 5'b1;
end

endmodule
