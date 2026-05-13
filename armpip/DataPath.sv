module DataPath(
    input clk, rst, MemtoRegW,
    input logic PCSrcW,
    input logic StallF, 
    input logic StallD,
    input logic FlushD,
    input logic FlushE,
    input logic BranchTakenE,
    input logic AluSrcE,
    input logic MemWriteM,
    input logic [1:0] ImmSrcD,
    input logic [1:0] RegSrcD,
    input logic [2:0]  AluControlE,
    input logic RegWriteW,
    input logic [31:0] ALUResultE,
    input logic [1:0]  ForwardAE,
    input logic [1:0]  ForwardBE,
    output logic [3:0]  ALUFlags,
    output logic [31:0] InstrD
);

    //internal signals
    logic [31:0] BranchTargetM;
    logic [31:0] ResultW;
    logic [31:0] AluResultE;
    logic [31:0] ALUOutM;
    logic [31:0] PCPlus8E;
    logic [31:0] PCPlus4F;
    logic [3:0]  WA3E;
    logic [3:0]  RA1E;
    logic [3:0]  RA2E;
    logic [31:0] RD1E;
    logic [31:0] RD2E;
    logic [31:0] Imm_Ext_E;
    logic [31:0] WriteDataM;
    logic [31:0] ReadDataM;
    logic [3:0]  WA3W;
    logic [31:0] WA3M;
    logic [31:0] ReadDataW;
    logic [31:0] ALUOutW;
    

    //Fetch Cycle
    fetch_cycle fetch (.clk(clk), 
                        .rst(rst), 
                        .PCSrcW(PCSrcW), 
                        .StallF(StallF), 
                        .StallD(StallD),
                        .FlushD(FlushD), 
                        .BranchTakenE(BranchTakenE), 
                        .ALUResultE(ALUResultE),
                        .ResultW(ResultW),
                        .InstrD(InstrD),
                        .PCPlus4F(PCPlus4F)
                        );

    //Dcode cycle
    Decode_Cycle(.clk(clk), 
                .rst(rst), 
                .FlushE(FlushE), 
                .ImmSrcD(ImmSrcD), 
                .RegSrcD(RegSrcD), 
                .InstrD(InstrD), 
                .RegWriteW(RegWriteW), 
                .WA3W(WA3W), 
                .ResultW(ResultW), 
                .PCPlus4F(PCPlus4F), 
                .WA3E(WA3E), 
                .RA1E(RA1E), 
                .RA2E(RA2E), 
                .RD1E(RD1E), 
                .RD2E(RD2E), 
                .Imm_Ext_E(Imm_Ext_E), 
                .PCPlus8E(PCPlus8E)
                );

    //Execute_Cycle
    Execute_Cycle(.clk(clk), 
                .rst(rst), 
                .WA3E(WA3E), 
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
                .ALUFlags(ALUFlags), 
                .WA3M(WA3M), 
                .ALUOutM(ALUOutM), 
                .WriteDataM(WriteDataM),
                .AluResultE(AluResultE),
                .BranchTargetM(BranchTargetM)
                );
    

    //Memory cycle
    memory_cycle (.clk(clk), 
                .rst(rst),
                .MemWriteM(MemWriteM), 
                .ALUOutM(ALUOutM),
                .WriteDataM(WriteDataM),
                .WA3M(WA3M),
                .WA3W(WA3W),
                .WriteDataW(WriteDataW),
                .ALUOutW(ALUOutW),
                .ReadDataW(ReadDataW)
                );


    //Write Back cycle
    writeback_cycle WriteBack (.MemtoRegW(MemtoRegW), 
                               .ReadDataW(ReadDataW), 
                               .ALUOutW(ALUOutW), 
                               .ResultW(ResultW)
                            );
endmodule