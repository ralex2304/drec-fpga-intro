module uart_rx #(
    parameter FREQ = 50_000_000,
    parameter RATE = 2_000_000
)(
    input  wire         clk,
    input  wire         rst_n,

    output reg    [7:0] o_data,
    output wire         o_vld,

    input  wire         i_rx
);

localparam UART_CLK_PERIOD_TICKS = FREQ / RATE;

localparam [0:0] START_BIT = 1'b0;

localparam [3:0] IDLE = 0, START = 1, BIT0 = 2, BIT7 = BIT0 + 7, STOP = BIT7 + 1;

reg [3:0] state, state_next;

reg i_rx_d;
always @(posedge clk) i_rx_d <= i_rx;
wire inp_negedge = ~i_rx && i_rx_d;

reg [$clog2(UART_CLK_PERIOD_TICKS)-1:0] counter;
wire clk_en = &(~counter);

always @(posedge clk) begin
    if (inp_negedge && state == IDLE) begin
        counter <= UART_CLK_PERIOD_TICKS/2 - 1;
    end else if (&(~counter)) begin
        counter <= UART_CLK_PERIOD_TICKS - 1;
    end else begin
        counter <= counter - 1;
    end
end

/// FSM {
always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
    end else if ((state == IDLE && inp_negedge) || clk_en) begin
        state <= state_next;
    end
end

always @(*) begin
    case (state)
        IDLE:    state_next = inp_negedge ? START : IDLE;
        START:   state_next = (i_rx == START_BIT) ? BIT0 : IDLE;
        default: state_next = state + 1;
        BIT7:    state_next = STOP;
        STOP:    state_next = IDLE;
    endcase
end
/// } FSM

always @(posedge clk) begin
    if (clk_en && BIT0 <= state && state <= BIT7) begin
        o_data <= {i_rx, o_data[7:1]};
    end
end

assign o_vld = clk_en && (state == STOP);

endmodule
