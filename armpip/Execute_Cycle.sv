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
    input  logic [31:0] PCPlus8E,

    // Control
    input  logic        AluSrcE,
    input  logic [2:0]  AluControlE,

    // Hazard
    input  logic [1:0]  ForwardAE,
    input  logic [1:0]  ForwardBE,

    input  logic [31:0] ResultW,

    // Outputs
   
    output logic [3:0]  ALUFlags,

    // Pipeline Outputs
    output logic [3:0]  WA3M,
    output logic [31:0] ALUOutM,
    output logic [31:0] WriteDataM,
    output logic [31:0] AluResultE,
    //
    output logic [31:0] BranchTargetM

);

logic [31:0] WriteDataE;
logic [31:0] BranchTargetE ;

ExecuteOperation operation (.clk(clk), 
                .rst(rst), 
                .RA1E(RA1E), 
                .RA2E(RA2E), 
                .RD1E(RD1E), 
                .RD2E(RD2E), 
                .Imm_Ext_E(Imm_Ext_E), 
                .PCPlus8E(PCPlus8E), 
                .AluSrcE(AluSrcE), 
                .AluControlE(AluControlE), 
                .ForwardAE(ForwardAE), 
                .ForwardBE(ForwardBE), 
                .ResultW(ResultW), 
                .ALUOutM(ALUOutM), 
                .ALUFlags(ALUFlags), 
                .BranchTargetE(BranchTargetE), 
                .AluResultE(AluResultE), 
                .WriteDataE(WriteDataE)

);

execute_reg exreg (.clk(clk), 
            .reset(rst), 
            .ALUResultE(AluResultE), 
            .WriteDataE(WriteDataE), 
            .WA3E(WA3E), 
            .WA3M(WA3M), 
            .ALUOutM(ALUOutM), 
            .WriteDataM(WriteDataM)
);


endmodule