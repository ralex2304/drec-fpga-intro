module sign_ext #(
    parameter IN_WIDTH    = 16,
    parameter OUT_WIDTH   = 32,
    parameter BEHAVIOURAL = 1
)(
    input  wire      [IN_WIDTH-1:0] i_num,
    output wire     [OUT_WIDTH-1:0] o_num
);

`ifndef SYNTHESYS
initial begin
    if (IN_WIDTH >= OUT_WIDTH) begin
        $error("Invalid parameters in sign_ext module");
    end
end
`endif

generate
if (BEHAVIOURAL) begin : gen_output_behav
    assign o_num = {{OUT_WIDTH-IN_WIDTH{i_num[IN_WIDTH-1]}}, i_num};
end else begin : gen_output_struct
    assign o_num[IN_WIDTH-1:0] = i_num;

    for (genvar i = IN_WIDTH; i < OUT_WIDTH; i = i + 1) begin
        sign_ext_bit sign_ext_bit_inst (
            .i_sign(i_num[IN_WIDTH-1]),
            .o_res (o_num[i]         )
        );
    end
end
endgenerate

endmodule
