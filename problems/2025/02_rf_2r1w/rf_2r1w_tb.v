`timescale 1ns/1ps

module rf_2r1w_tb;

localparam WIDTH = 32;
localparam DEPTH = 32;
localparam ADDR_W = $clog2(DEPTH);

reg clk = 1'b0;

always begin
    #1 clk <= ~clk;
end

reg [1:0][ADDR_W-1:0] i_rd_addr;
wire [1:0][DEPTH-1:0] o_rd_data;

reg [ADDR_W-1:0] i_wr_addr;
reg  [WIDTH-1:0] i_wr_data;
reg              i_wr_en = 1'b0;

rf_2r1w #(
    .WIDTH      (WIDTH),
    .DEPTH      (DEPTH)
) u_rf_2r1w(
    .clk        (clk),
    .i_rd_addr  (i_rd_addr),
    .o_rd_data  (o_rd_data),
    .i_wr_addr  (i_wr_addr),
    .i_wr_data  (i_wr_data),
    .i_wr_en    (i_wr_en)
);

reg test_start = 1'b0;
reg [WIDTH-1:0] test_data [DEPTH-1:0];

reg [WIDTH-1:0] random_data;
always @(posedge clk) begin
    random_data <= $urandom;
end

initial begin
    @(posedge clk);
    i_wr_en = 1'b1;
    for (integer i = 0; i < DEPTH; i = i + 1) begin
        i_wr_addr <= i;
        i_wr_data <= random_data;
        test_data[i] = random_data;
        @(posedge clk);
    end
    i_wr_en = 1'b0;
    @(posedge clk);
    test_start = 1'b1;
end

generate
for (genvar i = 0; i < 2; i = i + 1) begin : gen_rd
    always @(posedge clk) begin
        i_rd_addr[i] <= $urandom;
    end

    always @(posedge clk) begin
        if (test_start) begin
            if (o_rd_data[i] !== test_data[i_rd_addr[i]]) begin
                $display("[FAIL]");
                $finish;
            end
        end
    end
end

endgenerate
always @(posedge clk) begin
    if (test_start && $urandom_range(0, 1)) begin
        i_wr_addr <= $urandom;
        i_wr_data <= $urandom;
        i_wr_en   <= 1'b1;
    end else if (test_start) begin
        i_wr_en <= 1'b0;
    end
end

always @(posedge clk) begin
    if (test_start && i_wr_en) begin
        test_data[i_wr_addr] <= i_wr_data;
    end
end

initial begin
    $dumpvars;
    #1000000
    $display("[PASS]");
    $finish;
end

endmodule
