module alu #(
    parameter XLEN = 32
)(
    input  wire      [6:0] i_funct7,
    input  wire      [2:0] i_funct3,
    input  wire [XLEN-1:0] i_op1,
    input  wire [XLEN-1:0] i_op2,

    output reg  [XLEN-1:0] o_result,
    output reg             o_illegal
);

always @(*) begin
    o_illegal = 1'b0;
    case ({i_funct7, i_funct3})
        /* add  */ 10'b0000000_000: o_result = i_op1 + i_op2;
        /* sub  */ 10'b0100000_000: o_result = i_op1 - i_op2;
        /* sll  */ 10'b0000000_001: o_result = i_op1 << i_op2[$clog2(XLEN)-1:0];
        /* slt  */ 10'b0000000_010: o_result = {{XLEN-1{1'b0}}, $signed(i_op1) < $signed(i_op2)};
        /* sltu */ 10'b0000000_011: o_result = {{XLEN-1{1'b0}}, i_op1 < i_op2};
        /* xor  */ 10'b0000000_100: o_result = i_op1 ^ i_op2;
        /* srl  */ 10'b0000000_101: o_result = i_op1 >> i_op2[$clog2(XLEN)-1:0];
        /* sra  */ 10'b0100000_101: o_result = $signed(i_op1) >>> i_op2[$clog2(XLEN)-1:0];
        /* or   */ 10'b0000000_110: o_result = i_op1 | i_op2;
        /* and  */ 10'b0000000_111: o_result = i_op1 & i_op2;
        default: begin
            o_result  = {XLEN{1'bX}};
            o_illegal = 1'b1;
        end
    endcase
end

endmodule
