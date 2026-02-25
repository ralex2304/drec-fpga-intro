`timescale 1ns/1ps

module cmp_tb;

localparam XLEN = 32;

reg [2:0] i_funct3;
reg [XLEN-1:0] i_op1, i_op2;
wire o_taken, o_illegal;

cmp #(
    .XLEN       (XLEN)
) cmp_inst (
    .i_funct3   (i_funct3),
    .i_op1      (i_op1),
    .i_op2      (i_op2),
    .o_taken    (o_taken)
);

`define CHECK(funct3_, op1_, op2_, taken_)                                                  \
    i_funct3 = funct3_;                                                                     \
    i_op1 = op1_;                                                                           \
    i_op2 = op2_;                                                                           \
    #1                                                                                      \
    if (o_taken !== taken_) begin                                                           \
        $display("[FAIL] funct3=%b. o_taken=%b (must be %0b)", funct3_, o_taken, taken_);   \
        $finish;                                                                            \
    end else if (o_illegal) begin                                                           \
        $display("[FAIL] funct3=%b. o_illegal is high");                                    \
        $finish;                                                                            \
    end

initial begin
    $dumpvars;

    `CHECK(3'b000, 72383, 12345, 0)
    `CHECK(3'b000, 72383, 72383, 1)

    `CHECK(3'b001, 72383, 12345, 1)
    `CHECK(3'b001, 72383, 72383, 0)

    `CHECK(3'b100, 72383, 12345, 0)
    `CHECK(3'b100, 72383, 72383, 0)
    `CHECK(3'b100, 72383, 82383, 1)
    `CHECK(3'b100, -2383,  2383, 1)
    `CHECK(3'b100, -5383, -2383, 1)

    `CHECK(3'b101, 72383, 12345, 1)
    `CHECK(3'b101, 72383, 72383, 1)
    `CHECK(3'b101, 72383, 82383, 0)
    `CHECK(3'b101, -2383,  2383, 0)
    `CHECK(3'b101, -5383, -2383, 0)

    `CHECK(3'b110, 72383, 12345, 0)
    `CHECK(3'b110, 72383, 72383, 0)
    `CHECK(3'b110, 72383, 82383, 1)

    `CHECK(3'b111, 72383, 12345, 1)
    `CHECK(3'b111, 72383, 72383, 1)
    `CHECK(3'b111, 72383, 82383, 0)

    i_funct3 = 3'b010;
    #1
    if (!o_illegal) begin
        $display("[FAIL] o_illegal is low");
        $finish;
    end

    $display("[PASS]");
    $finish;
end



endmodule

