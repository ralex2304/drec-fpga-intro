module ctrl_unit (
    input  wire [31:0] i_instr,

    output reg [1:0] o_sel1,
    output reg [1:0] o_sel2,
    output reg [1:0] o_sel_wb,
    output wire      o_wb_en,

    output reg  [3:0] o_alu_oper,

    output wire o_branch,
    output wire o_jump,
    output wire o_mem_wr_en,

    input  wire i_misspredict
);

wire [6:0] opcode = i_instr[6:0];
wire [2:0] funct3 = i_instr[14:12];

/// MUX A
localparam [1:0] IMM_U = 2'b00;
localparam [1:0] IMM_B = 2'b01;
localparam [1:0] IMM_J = 2'b10;
localparam [1:0] SRC_0 = 2'b11;

/// MUX B
localparam [1:0] PC    = 2'b00;
localparam [1:0] IMM_S = 2'b01;
localparam [1:0] IMM_I = 2'b10;
localparam [1:0] SRC_1 = 2'b11;

/// MUX WB
localparam [1:0] WB_PCINC = 0;
localparam [1:0] WB_ALU   = 1;
localparam [1:0] WB_IMM_U = 2;
localparam [1:0] WB_LSU   = 3;

/// Opcodes
localparam [6:0] LOAD   = 7'b00000_11;
localparam [6:0] OP_IMM = 7'b00100_11;
localparam [6:0] AUIPC  = 7'b00101_11;
localparam [6:0] STORE  = 7'b01000_11;
localparam [6:0] OP     = 7'b01100_11;
localparam [6:0] LUI    = 7'b01101_11;
localparam [6:0] BRANCH = 7'b11000_11;
localparam [6:0] JALR   = 7'b11001_11;
localparam [6:0] JAL    = 7'b11011_11;

always @(*) begin
    case (opcode)
        LUI:     {o_sel1, o_sel2, o_sel_wb} = {2'bX,  2'bX,  WB_IMM_U};
        AUIPC:   {o_sel1, o_sel2, o_sel_wb} = {IMM_U, PC   , WB_ALU  };
        OP_IMM:  {o_sel1, o_sel2, o_sel_wb} = {SRC_0, IMM_I, WB_ALU  };
        OP:      {o_sel1, o_sel2, o_sel_wb} = {SRC_0, SRC_1, WB_ALU  };
        LOAD:    {o_sel1, o_sel2, o_sel_wb} = {SRC_0, IMM_I, WB_LSU  };
        STORE:   {o_sel1, o_sel2, o_sel_wb} = {SRC_0, IMM_S, 2'bX    };
        BRANCH:  {o_sel1, o_sel2, o_sel_wb} = {IMM_B, PC   , 2'bX    };
        JALR:    {o_sel1, o_sel2, o_sel_wb} = {SRC_0, IMM_I, WB_PCINC};
        JAL:     {o_sel1, o_sel2, o_sel_wb} = {IMM_J, PC   , WB_PCINC};
        default: {o_sel1, o_sel2, o_sel_wb} = 6'bX;
    endcase
end

assign o_wb_en = ((opcode != STORE) && (opcode != BRANCH)) && !i_misspredict;

always @(*) begin
    o_alu_oper = {i_instr[30], funct3};

    if (opcode == OP_IMM && funct3 == 3'b000) begin // addi
        o_alu_oper[3] = 1'b0;
    end else if (opcode == LOAD || opcode == STORE) begin
        o_alu_oper = 4'b0000;
    end
end

assign o_branch = (opcode == BRANCH) && !i_misspredict;

assign o_jump   = ((opcode == JALR) || (opcode == JAL)) && !i_misspredict;

assign o_mem_wr_en = (opcode == STORE) && !i_misspredict;

endmodule

