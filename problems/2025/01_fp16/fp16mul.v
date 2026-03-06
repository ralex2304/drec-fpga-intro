module fp16mul #(
    parameter XLEN = 16,
    parameter ELEN = 5,
    parameter ROUND_MODE = 0 //< 0 - rtte, 1 - rtz
)(
    input  wire [XLEN-1:0] i_a,
    input  wire [XLEN-1:0] i_b,

    output reg  [XLEN-1:0] o_res
);


localparam MLEN = XLEN - 1 - ELEN;
localparam [ELEN-1:0] BIAS = 2**(ELEN-1)-1;

// operand extraction {
wire op1_s = i_a[XLEN-1];
wire op2_s = i_b[XLEN-1];

wire [ELEN-1:0] op1_e = i_a[ELEN+MLEN-1:MLEN];
wire [ELEN-1:0] op2_e = i_b[ELEN+MLEN-1:MLEN];

wire [MLEN+1-1:0] op1_m = {1'b1, |op1_e ? i_a[MLEN-1:0] : {MLEN{1'b0}}};
wire [MLEN+1-1:0] op2_m = {1'b1, |op2_e ? i_b[MLEN-1:0] : {MLEN{1'b0}}};
// }

// sign {
wire res_s = op1_s ^ op2_s;
// }

// mantisa {
wire [MLEN*2+2-1:0] mul_m = op1_m * op2_m;
wire mul_m_needs_shift = mul_m[MLEN*2+2-1];
wire [MLEN*2-1:0] norm_m = mul_m_needs_shift ? mul_m[MLEN*2+1-1:1] : mul_m[MLEN*2-1:0];

reg round_m_inc;
wire round_e_inc;
wire [MLEN-1:0] round_m;
generate
if (ROUND_MODE == 0) begin : gen_rtte
    always @(*) begin
        casez ({norm_m[MLEN], norm_m[MLEN-1], |norm_m[MLEN-2:0]})
            3'b?0?,
            3'b010:  round_m_inc = 1'b0;
            default: round_m_inc = 1'b1;
        endcase
    end

    assign round_m = norm_m[MLEN*2-1:MLEN] + {{MLEN-1{1'b0}}, round_m_inc};
    assign round_e_inc = round_m_inc && (round_m == {MLEN{1'b0}});  
end else begin : gen_rtz
    assign round_m = norm_m[MLEN*2-1:MLEN];
    assign round_e_inc = 1'b0;
end
endgenerate
// }

// exponent {
wire [ELEN-1:0] sem_e = op1_e + op2_e - BIAS;
wire [ELEN-1:0] upd_e = sem_e + {{ELEN-1{1'b0}}, mul_m_needs_shift} 
                              + {{ELEN-1{1'b0}}, round_e_inc};
// }

reg [ELEN-1:0] res_e;
reg [MLEN-1:0] res_m;

// denormal values {
always @(*) begin
    if ((&op1_e && |op1_m) || (&op2_e && |op2_m)) begin // nan
        res_e = {ELEN{1'b1}};
        res_m = {MLEN{1'b1}};
    end else if (&op1_e || &op2_e) begin // inf
        res_e = {ELEN{1'b1}};
        res_m = {MLEN{1'b0}};
    end else if (&(~upd_e) && |round_m) begin
        res_e = upd_e;
        res_m = {MLEN{1'b0}};
    end else begin
        res_e = upd_e;
        res_m = round_m;
    end
end

// }

assign o_res = {res_s, res_e, res_m};

endmodule

