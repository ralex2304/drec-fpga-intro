module cmp #(
    parameter XLEN = 32
)(
    input  wire      [2:0] i_funct3,
    input  wire [XLEN-1:0] i_op1,
    input  wire [XLEN-1:0] i_op2,

    output reg             o_taken,
    output reg             o_illegal
);

always @(*) begin
    o_illegal = 1'b0;
    case (i_funct3)
        3'b000:  o_taken = i_op1 == i_op2;
        3'b001:  o_taken = i_op1 != i_op2;
        3'b100:  o_taken = $signed(i_op1) <  $signed(i_op2);
        3'b101:  o_taken = $signed(i_op1) >= $signed(i_op2);
        3'b110:  o_taken = i_op1 <  i_op2;
        3'b111:  o_taken = i_op1 >= i_op2;
        default: begin
            o_taken   = 1'bX;
            o_illegal = 1'b1;
        end
    endcase
end

endmodule
