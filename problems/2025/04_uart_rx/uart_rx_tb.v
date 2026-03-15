`timescale 1ns/1ps

module uart_rx_tb();

localparam FREQ = 50_000_000;
localparam RATE = 2_000_000;

reg clk   = 1'b0;
reg rst_n = 1'b1;

always begin
    #1 clk <= ~clk;
end

initial begin
    #1 rst_n <= 1'b0;
    #1 rst_n <= 1'b1;
end

wire tx2rx;

reg [7:0] inp_data;
reg       inp_vld = 1'b0;
wire      inp_rdy;

wire [7:0] o_data;
wire       o_vld;


uart_rx #(
    .FREQ       (FREQ),
    .RATE       (RATE)
) u_uart_rx(
    .clk        (clk),
    .rst_n      (rst_n),

    .o_data     (o_data),
    .o_vld      (o_vld),
    .i_rx       (tx2rx)
);

uart_tx #(
    .FREQ    (FREQ),
    .RATE    (RATE)
) u_uart_tx(
    .clk     (clk),
    .rst_n   (rst_n),

    .i_data  (inp_data),
    .i_vld   (inp_vld),
    .o_rdy   (inp_rdy),
    .o_tx    (tx2rx)
);

task run_transaction;
    reg [7:0] data;
    begin
        data = $urandom;

        wait (inp_rdy);
        inp_vld  <= 1'b1;
        inp_data <= data;
        @(posedge clk);
        inp_vld  <= 1'b0;
        inp_data <= {8{1'bX}};
        wait (o_vld);
        if (data !== o_data) begin
            $display("[FAIL] got %b, expected %b", o_data, data);
        end
    end
endtask

initial begin
    $dumpvars;

    wait (!rst_n);
    wait (rst_n);
    @(posedge clk);

    repeat (1000) begin
        run_transaction();
    end
    $finish;
end


endmodule
