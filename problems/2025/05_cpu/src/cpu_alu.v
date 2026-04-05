module cpu_alu #(
    parameter XLEN = 32
)(
    input  wire      [3:0] i_oper,
    input  wire [XLEN-1:0] i_op1,
    input  wire [XLEN-1:0] i_op2,

    output reg  [XLEN-1:0] o_result
);

always @(*) begin
    casez (i_oper)
        /* add  */ 4'b0_000: o_result = i_op1 + i_op2;
        /* sub  */ 4'b1_000: o_result = i_op1 - i_op2;
        /* sll  */ 4'b?_001: o_result = i_op1 << i_op2[$clog2(XLEN)-1:0];
        /* slt  */ 4'b?_010: o_result = {{XLEN-1{1'b0}}, $signed(i_op1) < $signed(i_op2)};
        /* sltu */ 4'b?_011: o_result = {{XLEN-1{1'b0}}, i_op1 < i_op2};
        /* xor  */ 4'b?_100: o_result = i_op1 ^ i_op2;
        /* srl  */ 4'b0_101: o_result = i_op1 >> i_op2[$clog2(XLEN)-1:0];
        /* sra  */ 4'b1_101: o_result = $signed(i_op1) >>> i_op2[$clog2(XLEN)-1:0];
        /* or   */ 4'b?_110: o_result = i_op1 | i_op2;
        /* and  */ 4'b?_111: o_result = i_op1 & i_op2;

        default:             o_result  = {XLEN{1'bX}};
    endcase
end

endmodule
