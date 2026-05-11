module Execute_Cycle(

    input  logic        clk,
    input  logic        rst,

    // Decode
    input  logic [3:0]  WA3E,
    input  logic [3:0]  RA1E,
    input  logic [3:0]  RA2E,

    input  logic [31:0] RD1E,
    input  logic [31:0] RD2E,
    input  logic [31:0] Imm_Ext_E,

    // Control
    input  logic        AluSrcE,
    input  logic [2:0]  AluControlE,

    // Hazard
    input  logic [1:0]  ForwardAE,
    input  logic [1:0]  ForwardBE,

    input  logic [31:0] ResultW,
    input  logic [31:0] ALUResultM,

    // Outputs
    output logic [31:0] AluResultE,
    output logic [3:0]  ALUFlags,

    // Pipeline Outputs
    output logic [3:0]  WA3M,
    output logic [31:0] ALUResultM_out,
    output logic [31:0] WriteDataM

);

logic [31:0] SrcAE, SrcBE;
logic [31:0] WriteDataE;

// Forward A
mux_3_to_1 #(32) ForwardA_mux (
    .a(RD1E),
    .b(ResultW),
    .c(ALUResultM),
    .s(ForwardAE),
    .d(SrcAE)
);

// Forward B
mux_3_to_1 #(32) ForwardB_mux (
    .a(RD2E),
    .b(ResultW),
    .c(ALUResultM),
    .s(ForwardBE),
    .d(WriteDataE)
);

// ALU Src MUX
mux_2_to_1 #(32) ALUSrc_mux (
    .a(WriteDataE),
    .b(Imm_Ext_E),
    .s(AluSrcE),
    .c(SrcBE)
);

// ALU
alu Alu (
   .a(SrcAE),
   .b(SrcBE),
   .ALUControl(AluControlE),
   .Result(AluResultE),
   .ALUFlags(ALUFlags)
);

// Pipeline Registers

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
    .q(ALUResultM_out)
);

Rst_FF #(32) WriteDataM_reg (
    .clk(clk),
    .reset(rst),
    .d(WriteDataE),
    .q(WriteDataM)
);

endmodule