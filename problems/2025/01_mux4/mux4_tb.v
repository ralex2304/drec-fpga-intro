`timescale 1ns/1ps

module mux4_tb;

localparam NUM_TESTS = 1024;
localparam DATA_WIDTH = 32;

reg [1:0] i_select;
reg [3:0][DATA_WIDTH-1:0] i_data;
wire [DATA_WIDTH-1:0] o_data;

mux4 #(
    .DATA_WIDTH  (DATA_WIDTH)
) u_mux4(
    .i_select    (i_select),
    .i_data      (i_data),
    .o_data      (o_data)
);

integer i = 0;
integer j = 0;
integer failed = 0;
initial begin
    $dumpvars;

    for (i = 0; i < NUM_TESTS; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin
            i_data[j] = $urandom;
        end
        i_select = $urandom;
        # 1

        if (o_data !== i_data[i_select]) begin
            failed = failed + 1;
            $display("[FAIL]");
        end
    end
    # 1

    if (failed != 0)
        $display("[FAIL] %d/%d tests failed", failed, NUM_TESTS);
    else
        $display("[PASS]");

    $finish;
end

endmodule
