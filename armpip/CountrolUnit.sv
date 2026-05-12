module ControlUnit(

    input  logic [1:0] op,
    input  logic [5:0] Funct,
    input  logic [3:0] Rd,

    output logic       PCS,
    output logic       RegW,
    output logic       MemW,
    output logic       MemtoReg,
    output logic       ALUSrc,
    output logic       Branch,

    output logic [1:0] ImmSrc,
    output logic [1:0] RegSrc,

    output logic [2:0] ALUControl,
    output logic [1:0] FlagW
);

logic ALUOp;


//
// Main Decoder
//
MainDecoder MD (

    .op(op),
    .Funct(Funct),

    .Branch(Branch),
    .ALUOp(ALUOp),

    .RegW(RegW),
    .MemW(MemW),
    .MemtoReg(MemtoReg),
    .ALUSrc(ALUSrc),

    .ImmSrc(ImmSrc),
    .RegSrc(RegSrc)

);


//
// ALU Decoder
//
ALUdecoder AD (

    .ALUOp(ALUOp),
    .Funct(Funct),

    .ALUControl(ALUControl),
    .FlagW(FlagW)

);


//
// PC Logic
//
PCLogic PC (

    .Rd(Rd),
    .Branch(Branch),
    .RegW(RegW),

    .PCS(PCS)

);

endmodule