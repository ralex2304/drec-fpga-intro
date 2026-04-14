module fp16add_pipe1 #(
    parameter XLEN = 16,
    parameter ELEN = 5
)(
    input  wire             clk,

    input  wire [XLEN-1:0] i_a,
    input  wire [XLEN-1:0] i_b,

    output wire [XLEN-1:0] o_res
);

localparam LATENCY = 1;

localparam MLEN = XLEN - 1 - ELEN;

reg op1_s[LATENCY:0], op2_s[LATENCY:0];
reg [ELEN-1:0] op1_e[LATENCY:0], op2_e[LATENCY:0];
reg [MLEN-1:0] op1_m[LATENCY:0], op2_m[LATENCY:0];

generate
genvar i;
for (i = 0; i < LATENCY; i = i + 1) begin : genOperandsPipe
    always @(posedge clk) begin
        op1_s[i+1] <= op1_s[i];
        op2_s[i+1] <= op2_s[i];

        op1_e[i+1] <= op1_e[i];
        op2_e[i+1] <= op2_e[i];

        op1_m[i+1] <= op1_m[i];
        op2_m[i+1] <= op2_m[i];
    end
end
endgenerate

/// STAGE 0

wire [ELEN+1-1:0] op_a_e = {1'b0, i_a[ELEN+MLEN-1:MLEN]};
wire [ELEN+1-1:0] op_b_e = {1'b0, i_b[ELEN+MLEN-1:MLEN]};

wire [ELEN+1-1:0] e_sub = op_a_e - op_b_e;

reg [ELEN-1:0] e_sub_abs;

always @(*) begin
    if (e_sub[ELEN]) begin
        {op1_s[0], op1_e[0], op1_m[0]} = i_b;
        {op2_s[0], op2_e[0], op2_m[0]} = i_a;
        e_sub_abs = -e_sub[ELEN-1:0];
    end else begin
        {op1_s[0], op1_e[0], op1_m[0]} = i_a;
        {op2_s[0], op2_e[0], op2_m[0]} = i_b;
        e_sub_abs = e_sub[ELEN-1:0];
    end
end

// op1_e >= op2_e
wire [MLEN*2+2:0] op1_shift_m = {3'b001, op1_m[0], {MLEN{1'b0}}};
wire [MLEN*2+2:0] op2_shift_m = {3'b001, op2_m[0], {MLEN{1'b0}}} >> e_sub_abs;

reg signed [MLEN*2+2:0] op1_signed_m;
reg signed [MLEN*2+2:0] op2_signed_m;

always @(*) begin
    if (op1_s[0]) op1_signed_m = -$signed(op1_shift_m);
    else          op1_signed_m =  $signed(op1_shift_m);

    if (op2_s[0]) op2_signed_m = -$signed(op2_shift_m);
    else          op2_signed_m =  $signed(op2_shift_m);
end

reg signed [MLEN*2+2:0] sum_signed_m;

always @(posedge clk) begin
    sum_signed_m <= op1_signed_m + op2_signed_m;
end

/// STAGE 1

wire sum_s = sum_signed_m[MLEN*2+2];
wire [MLEN*2+1:0] sum_abs_m = sum_s ? -sum_signed_m[MLEN*2+1:0] : sum_signed_m[MLEN*2+1:0];

reg [ELEN-1:0] m_shift;
reg m_one_found;
integer m_shift_i;
always @(*) begin
    m_shift = {ELEN{1'b0}};
    m_one_found = 1'b0;
    for (m_shift_i = MLEN*2+1; m_shift_i >= 0; m_shift_i = m_shift_i - 1) begin
        if (sum_abs_m[MLEN*2+1 - m_shift_i]) begin
            m_shift = m_shift_i[ELEN-1:0];
            m_one_found = 1'b1;
        end
    end
end

wire [MLEN*2-1:0] sum_shifted_m = (m_shift == 0) ? sum_abs_m[MLEN*2:1] : sum_abs_m[MLEN*2-1:0] << (m_shift - 1);
wire [MLEN-1:0] sum_round_m = sum_shifted_m[MLEN*2-1:MLEN];
wire [ELEN-1:0] sum_e = op1_e[LATENCY] - (m_shift - 1);

reg [ELEN-1:0] res_e;
reg [MLEN-1:0] res_m;

// denormal values {
always @(*) begin
    if ((&op1_e[LATENCY] && |op1_m[LATENCY]) || (&op2_e[LATENCY] && |op2_m[LATENCY])) begin // nan
        res_e = {ELEN{1'b1}};
        res_m = {MLEN{1'b1}};
    end else if (&op1_e[LATENCY] || &op2_e[LATENCY]) begin // inf
        res_e = {ELEN{1'b1}};
        res_m = {MLEN{1'b0}};
    end else if (!m_one_found) begin
        res_e = {ELEN{1'b0}};
        res_m = {MLEN{1'b0}};
    end else if (m_shift == 0 && &op1_e[LATENCY]) begin
        res_e = {ELEN{1'b1}};
        res_m = {MLEN{1'b0}};
    end else if (op1_e[LATENCY] + 1 < m_shift) begin
        res_e = {ELEN{1'b0}};
        res_m = {MLEN{1'b0}};
    end else if (&(~sum_e) && |sum_round_m) begin
        res_e = sum_e;
        res_m = {MLEN{1'b0}};
    end else begin
        res_e = sum_e;
        res_m = sum_round_m;
    end
end
// }

assign o_res = {sum_s, res_e, res_m};

endmodule
