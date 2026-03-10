`timescale 1ns/1ps

module shiftreg_tb();

localparam WIDTH = 8;

reg clk = 1'b0;

always begin
    #1 clk <= ~clk;
end

reg i_en = 1'b0;

reg i_load_en = 1'b0;
reg [WIDTH-1:0] i_load_data;

initial i_load_data = $urandom;

wire o_out;

shiftreg #(
    .WIDTH        (WIDTH)
) u_shiftreg(
    .clk          (clk),
    .i_en         (i_en),
    .i_load_en    (i_load_en),
    .i_load_data  (i_load_data),
    .o_out        (o_out)
);

reg [WIDTH-1:0] res;

always @(posedge clk) begin
    if (i_en) begin
        #1 res = {res[WIDTH-2:0], o_out};
    end
end

integer counter = 0;

always @(posedge clk) begin
    if (counter == WIDTH) begin
        counter <= 0;
        if (res !== i_load_data) begin
            $display("[FAIL]");
            $finish;
        end
    end else if (i_en && counter == 0) begin
        counter <= i_load_en ? counter + 1 : counter;
    end else if (i_en) begin
        counter <= counter + 1;
    end
end

always @(posedge clk) begin
    if (counter == 0 && !i_en && !i_load_en) begin
        i_load_en   <= $urandom;
        i_load_data <= $urandom;
        i_en <= 1'b0;
    end else if (counter == 0 && i_load_en) begin
        i_load_en <= 1'b0;
        i_en <= 1'b1;
    end else begin
        i_en <= $urandom;
    end
end

initial begin
    $dumpvars;
    #1000000
    $display("[PASS]");
    $finish;
end

endmodule
