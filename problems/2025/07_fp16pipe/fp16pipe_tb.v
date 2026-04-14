module fp16pipe_tb;

localparam LATENCY = 0;

reg clk = 1'b0;

always begin
    #1 clk <= ~clk;
end

wire [15:0] c;

reg [15:0] a, b, z;

reg [15:0] z_pipe [LATENCY:0];

wire       z_sign = z[15];
wire [4:0] z_bexp = z[14:10];
wire [9:0] z_mant = z[9:0];

wire       c_sign = c[15];
wire [4:0] c_bexp = c[14:10];
wire [9:0] c_mant = c[9:0];

generate if (LATENCY == 0) begin : genPipe0
fp16add_pipe0 fp16add0 (
    .i_a      (a),
    .i_b      (b),
    .o_res    (c)
);
end else if (LATENCY == 1) begin : genPipe1
fp16add_pipe1 fp16add1 (
    .clk      (clk),
    .i_a      (a),
    .i_b      (b),
    .o_res    (c)
);
end else if (LATENCY == 2) begin : genPipe2
fp16add_pipe2 fp16add2 (
    .clk      (clk),
    .i_a      (a),
    .i_b      (b),
    .o_res    (c)
);
end
endgenerate

reg [3*16-1:0] test[`TEST_SIZE];
reg [$clog2(`TEST_SIZE)-1:0] idx = 0;

reg ok, pass = 1;

always @(*) begin
    {a, b, z_pipe[0]} = test[idx];
end

generate
for (genvar i = 0; i < LATENCY; i = i + 1) begin : genZpipe
    always @(posedge clk) begin
        z_pipe[i+1] <= z_pipe[i];
    end
end
endgenerate

assign z = z_pipe[LATENCY];

initial begin
    $readmemh("test.txt", test);
end

wire signed [14:0] diff = $signed(c[14:0]) - $signed(z[14:0]);

always @(*) begin
    if (z_bexp == 5'h0) // Zero/denormal
        ok = (c_bexp == 5'h00) && (c_mant == 10'h0) && (c_sign == z_sign);
    else if (z_bexp == 5'h1F) // Inf/NaN
        ok = (c_bexp == 5'h1F) && (c_mant == 10'h0) && (c_sign == z_sign);
    else
        ok = ($abs(diff) < 2) && (c_sign == z_sign);
end

reg started = 1'b0;
initial begin
    repeat(LATENCY) @(posedge clk);

    started <= 1'b1;
end

always @(posedge clk) begin
    idx <= idx + 1;
    if (started) begin
        if (`DEBUG || !ok) begin
            $display("[%d] %h %h -> %h z=%h ok=%d", idx, a, b, c, z, ok);
        end
        pass <= ok ? pass : 0;
    end

    if (idx == `TEST_SIZE-1) begin
        $display("Result: %s", pass ? "PASS" : "FAIL");
        $finish;
    end
end

initial begin
    $dumpvars;
    $display("Test size: %d", `TEST_SIZE);
end

endmodule
