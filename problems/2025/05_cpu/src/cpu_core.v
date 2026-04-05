module cpu_core (
    input  wire clk,
    input  wire rst_n,

    input  wire [31:0] i_instr_data,
    output wire [29:0] o_instr_addr,
    output wire [29:0] o_mem_addr,
    output wire [31:0] o_mem_data,
    output wire        o_mem_we,
    output wire  [3:0] o_mem_mask,
    input  wire [31:0] i_mem_data
);

wire [1:0] ctrl_alu_sel1;
wire [1:0] ctrl_alu_sel2;
wire [1:0] ctrl_wb_sel;

wire [3:0] ctrl2alu_oper;

wire ctrl2lsu_wr_en;

wire [31:0] alu_res;
wire [31:0] lsu_res;

wire ctrl_branch;
wire ctrl_jump;
wire branch_res;

reg  [29:0] pc;
wire [29:0] pc_inc = pc + 1;

wire taken = (ctrl_branch && branch_res) || ctrl_jump;
wire [29:0] taken_pc;

wire [31:0] src0, src1;
wire [31:0] dst;
wire dst_en;

wire [4:0] rd = i_instr_data[11:7];
wire [4:0] rs0 = i_instr_data[19:15];
wire [4:0] rs1 = i_instr_data[24:20];

wire s_bit = i_instr_data[31];

wire [31:0] imm_i = {{20{s_bit}}, i_instr_data[31:20]};
wire [31:0] imm_s = {{20{s_bit}}, i_instr_data[31:25], i_instr_data[11:7]};
wire [31:0] imm_b = {{20{s_bit}}, i_instr_data[7], i_instr_data[30:25], i_instr_data[11:8], 1'b0};
wire [31:0] imm_u = {i_instr_data[31:12], {12{1'b0}}};
wire [31:0] imm_j = {{12{s_bit}}, i_instr_data[19:12], i_instr_data[20], i_instr_data[30:21], 1'b0};

wire [2:0] funct3 = i_instr_data[14:12];

wire [31:0] alu_op_a;
wire [31:0] alu_op_b;

assign o_instr_addr = pc;

assign taken_pc = alu_res[31:2];

ctrl_unit ctrl_unit (
    .i_instr    (i_instr_data),
    .o_sel1     (ctrl_alu_sel1),
    .o_sel2     (ctrl_alu_sel2),
    .o_sel_wb   (ctrl_wb_sel),
    .o_wb_en    (dst_en),
    .o_alu_oper (ctrl2alu_oper),
    .o_branch   (ctrl_branch),
    .o_jump     (ctrl_jump),
    .o_mem_wr_en(ctrl2lsu_wr_en)
);

mux4 #(
    .DATA_WIDTH(32)
) mux4_a (
    .i_select(ctrl_alu_sel1),
    .i_data  ({src0, imm_j, imm_b, imm_u}),
    .o_data  (alu_op_a)
);

mux4 #(
    .DATA_WIDTH(32)
) mux4_b (
    .i_select(ctrl_alu_sel2),
    .i_data  ({src1, imm_i, imm_s, {pc, 2'b0}}),
    .o_data  (alu_op_b)
);

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        pc <= 29'b0;
    end else if (taken) begin
        pc <= taken_pc;
    end else begin
        pc <= pc_inc;
    end
end

rf_2r1w #(
    .WIDTH(32),
    .DEPTH(32)
) rf_2r1w (
    .clk        (clk),
    .i_rd_addr_a(rs0),
    .o_rd_data_a(src0),
    .i_rd_addr_b(rs1),
    .o_rd_data_b(src1),
    .i_wr_addr  (rd),
    .i_wr_data  (dst),
    .i_wr_en    (dst_en)
);

cpu_alu #(
    .XLEN(32)
) alu (
    .i_oper   (ctrl2alu_oper),
    .i_op1    (alu_op_a),
    .i_op2    (alu_op_b),
    .o_result (alu_res)
);

mux4 #(
    .DATA_WIDTH(32)
) mux4_wb (
    .i_select(ctrl_wb_sel),
    .i_data  ({imm_u, alu_res, lsu_res, {pc_inc, 2'b0}}),
    .o_data  (dst)
);

cmp #(
    .XLEN(32)
) cmp (
    .i_funct3 (funct3),
    .i_op1    (src0),
    .i_op2    (src1),
    .o_taken  (branch_res),
    .o_illegal()
);

lsu lsu (
    .i_addr    (alu_res),
    .i_data    (src1),
    .i_wr_en   (ctrl2lsu_wr_en),
    .i_funct3  (funct3),
    .o_data    (lsu_res),
    .o_mem_addr(o_mem_addr),
    .o_mem_data(o_mem_data),
    .o_mem_we  (o_mem_we),
    .o_mem_mask(o_mem_mask),
    .i_mem_data(i_mem_data)
);

endmodule
