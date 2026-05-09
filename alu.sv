module alu (
input logic [31:0] a, b,
input logic [2:0] ALUControl,
output logic [31:0] Result,
output logic [3:0] ALUFlags
);
logic neg, zero, carry, overflow;
logic [31:0] condinvb;
logic [32:0] sum;

assign condinvb = ALUControl[0] ? ~b : b;
assign sum = {1'b0, a} + {1'b0, condinvb} + {32'b0, ALUControl[0]};

always_comb begin
case(ALUControl)
3'b000: Result = sum[31:0];
3'b001: Result = sum[31:0];
3'b010: Result = a & b;
3'b011: Result = a | b;
3'b100: Result = a & ~b;
3'b101: Result = a ^ b;
3'b110: Result = b;
default: Result = sum[31:0];
endcase
end

always_comb begin
    neg = Result[31];
    if (Result == 32'b0)
        zero = 1'b1;
    else
        zero = 1'b0;
end

always_comb begin
    overflow = 1'b0;
    carry = 1'b0;
    if (ALUControl[2:1] == 2'b00) begin
        carry = sum[32];
        overflow = ~(a[31] ^ b[31] ^ ALUControl[0]) & (a[31] ^ sum[31]);
    end
end 

assign ALUFlags = {neg, zero, carry, overflow};

endmodule

