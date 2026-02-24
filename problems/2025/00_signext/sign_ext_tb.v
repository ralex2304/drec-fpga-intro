`timescale 1ns/1ps

module sign_ext_tb;

localparam TEST_NUM = 10_000;

localparam IN_WIDTH = 12;
localparam OUT_WIDTH = 32;

reg   [IN_WIDTH-1:0] inp;
wire [OUT_WIDTH-1:0] res_behav, res_struct;

sign_ext #(
    .IN_WIDTH (IN_WIDTH),
    .OUT_WIDTH(OUT_WIDTH),
    .BEHAVIOURAL(0)
) sign_ext_inst_struct (
    .i_num(inp),
    .o_num(res_struct)
);

sign_ext #(
    .IN_WIDTH (IN_WIDTH),
    .OUT_WIDTH(OUT_WIDTH),
    .BEHAVIOURAL(1)
) sign_ext_inst_behav (
    .i_num(inp),
    .o_num(res_behav)
);

integer i;
integer failed = 0;
initial begin
    $dumpvars;

    for (i = 0; i < TEST_NUM; i++) begin
        inp <= $urandom;
        #1

        if (res_struct !== res_behav) begin
            $display("%0d [FAIL] inp=%b, res_struct=%b, res_behav=%b", i, inp, res_struct, res_behav);
            failed <= failed + 1;
        end else if (res_struct[IN_WIDTH-1:0] !== inp) begin
            $display("%0d [FAIL] inp=%b, res_struct=res_behav=%b", i, inp, res_struct);
            failed <= failed + 1;
        end else if (res_struct[OUT_WIDTH-1:IN_WIDTH] != {OUT_WIDTH-IN_WIDTH{inp[IN_WIDTH-1]}}) begin
            $display("%0d [FAIL] inp=%b, res_struct=res_behav=%b", i, inp, res_struct);
            failed <= failed + 1;
        end
    end
    #1

    if (failed !== 0)
        $display("[FAIL] %d/%d tests failed", failed, TEST_NUM);
    else
        $display("[PASS] %d tests passed", TEST_NUM);

    $finish;
end

endmodule
