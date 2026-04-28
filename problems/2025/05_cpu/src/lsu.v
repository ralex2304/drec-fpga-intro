module lsu (
    input  wire [31:0] i_addr,
    input  wire [31:0] i_data,
    input  wire        i_wr_en,
    input  wire  [2:0] i_funct3,
    output reg  [31:0] o_data,

    output wire [29:0] o_mem_addr,
    output reg  [31:0] o_mem_data,
    output wire        o_mem_we,
    output reg   [3:0] o_mem_mask,
    input  wire [31:0] i_mem_data
);

assign o_mem_addr = i_addr[31:2];
assign o_mem_we   = i_wr_en;

always @(*) begin
    case (i_funct3)
        3'b000: begin
            o_mem_mask = 4'b1 << i_addr[1:0];
            o_mem_data = i_data[7:0] << (i_addr[1:0]*8);
        end
        3'b001: begin
            o_mem_mask = 4'b11 << (i_addr[1]*2);
            o_mem_data = i_data[15:0] << (i_addr[1]*16);
        end
        3'b010: begin
            o_mem_mask = 4'b1111;
            o_mem_data = i_data;
        end
        default: begin
            o_mem_mask = 4'bX;
            o_mem_data = 32'bX;
        end
    endcase
end

wire [7:0]  rd_data8  = i_mem_data[i_addr[1:0]+:8];
wire [15:0] rd_data16 = i_mem_data[i_addr[1]  +:16];

always @(*) begin
    case (i_funct3)
        3'b000:  o_data = {{24{rd_data8[7]}}, rd_data8[7:0]};
        3'b001:  o_data = {{16{rd_data16[15]}}, rd_data16[15:0]};
        3'b010:  o_data = i_mem_data;
        3'b100:  o_data = {{24{1'b0}}, rd_data8[7:0]};
        3'b101:  o_data = {{16{1'b0}}, rd_data16[15:0]};
        default: o_data = 32'bX;
    endcase
end

endmodule
