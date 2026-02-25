`timescale 1ns/1ps

module alu_tb;

localparam XLEN = 32;

reg [6:0] i_funct7;
reg [2:0] i_funct3;
reg [XLEN-1:0] i_op1, i_op2;

wire [XLEN-1:0] o_result;
wire o_illegal;

alu #(
    .XLEN       (XLEN)
) alu_inst (
    .i_funct7   (i_funct7),
    .i_funct3   (i_funct3),
    .i_op1      (i_op1),
    .i_op2      (i_op2),
    .o_result   (o_result),
    .o_illegal  (o_illegal)
);

`define CHECK(funct7_, funct3_, op1_, op2_, result_)    \
    i_funct7 = funct7_;                                                                                         \
    i_funct3 = funct3_;                                                                                         \
    i_op1 = op1_;                                                                                               \
    i_op2 = op2_;                                                                                               \
    # 1                                                                                                         \
    if (o_result !== result_) begin                                                                             \
        $display("[FAIL] funct7=%b, funct3=%b, o_result=%h (must be %h)", funct7_, funct3_, o_result, result_); \
        $finish;                                                                                                \
    end else if (o_illegal) begin                                                                               \
        $display("[FAIL]");                                                                                     \
        $finish;                                                                                                \
    end

initial begin
    $dumpvars;

    `CHECK(7'b0000000, 3'b000, 123, 345, 468)

    `CHECK(7'b0100000, 3'b000, 345, 123, 222)

    `CHECK(7'b0000000, 3'b001, 32'hA, 32'h3, 32'h50)

    `CHECK(7'b0000000, 3'b010, 123,  321, 1)
    `CHECK(7'b0000000, 3'b010, 123,  123, 0)
    `CHECK(7'b0000000, 3'b010, 123, -321, 0)

    `CHECK(7'b0000000, 3'b011, 123,  321, 1)
    `CHECK(7'b0000000, 3'b011, 123,  123, 0)
    `CHECK(7'b0000000, 3'b011, 123, -321, 1)

    `CHECK(7'b0000000, 3'b100, 32'b0011, 32'b0101, 32'b0110)

    `CHECK(7'b0000000, 3'b101,  10, 1, 5)
    `CHECK(7'b0000000, 3'b101, -10, 1, 32'h7ffffffb)
 
    `CHECK(7'b0100000, 3'b101,  10, 1,  5)
    `CHECK(7'b0100000, 3'b101, -10, 1, -5)

    `CHECK(7'b0000000, 3'b110, 32'b0011, 32'b0101, 32'b0111)

    `CHECK(7'b0000000, 3'b111, 32'b0011, 32'b0101, 32'b0001)

    i_funct7 = 7'b1111111;
    i_funct3 = 3'b000;
    #1
    if (!o_illegal) begin
        $display("[FAIL] o_illegal is low");
        $finish;
    end



    $display("[PASS]");
    $finish;
end


endmodule
