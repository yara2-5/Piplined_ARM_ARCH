module ControlUnit(

    input  logic [1:0] op,
    input  logic [5:0] Funct,
    input  logic [3:0] Rd,

    output logic       PCSD,
    output logic       RegWD,
    output logic       MemWD,
    output logic       MemtoRegD,
    output logic       ALUSrcD,
    output logic       BranchD,

    output logic [1:0] ImmSrcD,
    output logic [1:0] RegSrcD,

    output logic [2:0] ALUControlD,
    output logic [1:0] FlagWD
);

logic ALUOpD;


//
// Main Decoder
//
MainDecoder MD (

    .op(op),
    .Funct(Funct),

    .Branch(BranchD),
    .ALUOp(ALUOpD),

    .RegW(RegWD),
    .MemW(MemWD),
    .MemtoReg(MemtoRegD),
    .ALUSrc(ALUSrcD),

    .ImmSrc(ImmSrcD),
    .RegSrc(RegSrcD)

);


//
// ALU Decoder
//
ALUdecoder AD (

    .ALUOp(ALUOpD),
    .Funct(Funct),

    .ALUControl(ALUControlD),
    .FlagW(FlagWD)

);


//
// PC Logic
//
PCLogic PC (

    .Rd(Rd),
    .Branch(BranchD),
    .RegW(RegWD),

    .PCS(PCSD)

);

endmodule