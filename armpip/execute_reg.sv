module execute_reg (
    input logic clk,
    input logic reset,
    input logic [31:0] ALUResultE,
    input logic [31:0] WriteDataE,
    input logic [31:0] WA3E,
    output logic [31:0] WA3M,
    output logic [31:0] ALUOutM,
    output logic [31:0] WriteDataM
);
    Rst_FF #(4) WA3M_reg (
    .clk(clk),
    .reset(rst),
    .d(WA3E),
    .q(WA3M)
    );

    Rst_FF #(32) ALUResultM_reg (
    .clk(clk),
    .reset(rst),
    .d(AluResultE),
    .q(ALUOutM)
    );

    Rst_FF #(32) WriteDataM_reg (
    .clk(clk),
    .reset(rst),
    .d(WriteDataE),
    .q(WriteDataM)
    );

    Rst_FF #(32) BranchTarget_reg (
    .clk(clk),
    .reset(rst),
    .d(BranchTargetE),
    .q(BranchTargetM)
    );

endmodule

