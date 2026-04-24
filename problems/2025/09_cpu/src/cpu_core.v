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

reg [31:0] instr_data_s1;

wire [1:0] ctrl_alu_sel1_s1;
wire [1:0] ctrl_alu_sel2_s1;
wire [1:0] ctrl_wb_sel_s1;

wire [3:0] ctrl2alu_oper_s1;

wire ctrl2lsu_wr_en_s1;

wire [31:0] alu_res_s1;
wire [31:0] lsu_res_s2;

wire ctrl_branch_s1;
wire ctrl_jump_s1;
wire branch_res_s1;

reg  [29:0] pc_s0, pc_next_s0;
wire [29:0] pc_inc_s0 = pc_s0 + 1;

wire taken_s1 = (ctrl_branch_s1 && branch_res_s1) || ctrl_jump_s1;
wire [29:0] taken_pc_s1;

wire [31:0] src0_s1, src1_s1;
wire [31:0] dst_s2;
wire [31:0] wb_dst_s1;
reg  [31:0] wb_dst_s2;
wire dst_en_s1;

wire [4:0] rs0_s0 = i_instr_data[19:15];
wire [4:0] rs1_s0 = i_instr_data[24:20];

reg [4:0] rs0_s1;
reg [4:0] rs1_s1;

reg  [29:0] pc_s1, pc_inc_s1;
wire [2:0] funct3_s1 = instr_data_s1[14:12];

wire [31:0] alu_op_a_s1;
wire [31:0] alu_op_b_s1;

wire [31:0] op_sum_s1 = alu_op_a_s1 + alu_op_b_s1;

reg misspredict_s2;

reg [1:0] wb_sel_s2;
reg [4:0] rd_s2;
reg dst_en_s2;

assign o_instr_addr = pc_next_s0;

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        pc_s0 <= 29'b0;
    end else begin
        pc_s0 <= pc_next_s0;
    end
end

always @(*) begin
    if (taken_s1) begin
        pc_next_s0 = taken_pc_s1;
    end else begin
        pc_next_s0 = pc_inc_s0;
    end
end

assign taken_pc_s1 = op_sum_s1[31:2];

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        misspredict_s2 <= 1'b1;
    end else begin
        misspredict_s2 <= taken_s1 && !misspredict_s2;
    end
end

always @(posedge clk) begin
    instr_data_s1 <= i_instr_data;
    pc_s1         <= pc_s0;
    pc_inc_s1     <= pc_inc_s0;
    rs0_s1        <= rs0_s0;
    rs1_s1        <= rs1_s0;
end

ctrl_unit ctrl_unit (
    .i_instr        (instr_data_s1),
    .o_sel1         (ctrl_alu_sel1_s1),
    .o_sel2         (ctrl_alu_sel2_s1),
    .o_sel_wb       (ctrl_wb_sel_s1),
    .o_wb_en        (dst_en_s1),
    .o_alu_oper     (ctrl2alu_oper_s1),
    .o_branch       (ctrl_branch_s1),
    .o_jump         (ctrl_jump_s1),
    .o_mem_wr_en    (ctrl2lsu_wr_en_s1),
    .i_misspredict  (misspredict_s2)
);

wire s_bit_s1 = instr_data_s1[31];

wire [31:0] imm_i_s1 = {{20{s_bit_s1}}, instr_data_s1[31:20]};
wire [31:0] imm_s_s1 = {{20{s_bit_s1}}, instr_data_s1[31:25], instr_data_s1[11:7]};
wire [31:0] imm_b_s1 = {{20{s_bit_s1}}, instr_data_s1[7], instr_data_s1[30:25], instr_data_s1[11:8], 1'b0};
wire [31:0] imm_u_s1 = {instr_data_s1[31:12], {12{1'b0}}};
wire [31:0] imm_j_s1 = {{12{s_bit_s1}}, instr_data_s1[19:12], instr_data_s1[20], instr_data_s1[30:21], 1'b0};

wire [4:0] rd_s1 = instr_data_s1[11:7];

mux4 #(
    .DATA_WIDTH(32)
) mux4_a (
    .i_select(ctrl_alu_sel1_s1),
    .i_data  ({src0_s1, imm_j_s1, imm_b_s1, imm_u_s1}),
    .o_data  (alu_op_a_s1)
);

mux4 #(
    .DATA_WIDTH(32)
) mux4_b (
    .i_select(ctrl_alu_sel2_s1),
    .i_data  ({src1_s1, imm_i_s1, imm_s_s1, {pc_s1, 2'b0}}),
    .o_data  (alu_op_b_s1)
);

wire [31:0] rf_src0_s1;
wire [31:0] rf_src1_s1;

rf_2r1w #(
    .WIDTH(32),
    .DEPTH(32)
) rf_2r1w (
    .clk        (clk),
    .i_rd_addr_a(rs0_s0),
    .o_rd_data_a(rf_src0_s1),
    .i_rd_addr_b(rs1_s0),
    .o_rd_data_b(rf_src1_s1),
    .i_wr_addr  (rd_s2),
    .i_wr_data  (dst_s2),
    .i_wr_en    (dst_en_s2)
);

assign src0_s1 = (dst_en_s2 && rd_s2 != 0 && rs0_s1 == rd_s2) ? dst_s2 : rf_src0_s1;
assign src1_s1 = (dst_en_s2 && rd_s2 != 0 && rs1_s1 == rd_s2) ? dst_s2 : rf_src1_s1;

cpu_alu #(
    .XLEN(32)
) alu (
    .i_oper   (ctrl2alu_oper_s1),
    .i_op1    (alu_op_a_s1),
    .i_op2    (alu_op_b_s1),
    .o_result (alu_res_s1)
);

always @(posedge clk) begin
    wb_sel_s2  <= ctrl_wb_sel_s1;
    rd_s2      <= rd_s1;
    dst_en_s2  <= dst_en_s1;
    wb_dst_s2  <= wb_dst_s1;
end

cmp #(
    .XLEN(32)
) cmp (
    .i_funct3 (funct3_s1),
    .i_op1    (src0_s1),
    .i_op2    (src1_s1),
    .o_taken  (branch_res_s1),
    .o_illegal()
);

wire [31:0] lsu_addr = src0_s1 + (ctrl_alu_sel2_s1[1] ? imm_i_s1 : imm_s_s1);

lsu lsu (
    .clk       (clk),
    .i_addr    (lsu_addr),
    .i_data    (src1_s1),
    .i_wr_en   (ctrl2lsu_wr_en_s1),
    .i_funct3  (funct3_s1),
    .o_data    (lsu_res_s2),
    .o_mem_addr(o_mem_addr),
    .o_mem_data(o_mem_data),
    .o_mem_we  (o_mem_we),
    .o_mem_mask(o_mem_mask),
    .i_mem_data(i_mem_data)
);

mux4 #(
    .DATA_WIDTH(32)
) mux4_wb (
    .i_select(ctrl_wb_sel_s1),
    .i_data  ({{32{1'bX}}, imm_u_s1, alu_res_s1, {pc_inc_s1, 2'b0}}),
    .o_data  (wb_dst_s1)
);

assign dst_s2 = (wb_sel_s2 == 2'b11) ? lsu_res_s2 : wb_dst_s2;

endmodule
