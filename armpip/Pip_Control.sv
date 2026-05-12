module Pip_Control (
    input logic clk, rst,
    input logic [31:0] InstrD,
    input logic [3:0] ALUFlags,
    output logic PCSrcW,
    output logic RegWriteW,
    output logic MemtoRegW,
    output logic BranchTakenE,
    output logic RegSrCD
);
    //internal signals
    logic PCSrcD;
    logic RegWriteD;
    logic MemWriteD;
    logic MemtoRegD;
    logic ALUSrcD;
    logic BranchD;
    logic PCSrc;
    logic RegWrite;
    logic MemWrite;
    logic [1:0] ImmSrcD;
    logic [1:0] RegSrcD;
    logic [2:0] ALUControlD;
    logic [1:0] FlagWriteD;

    //Control Unit
    ControlUnit control (.op(InstrD[27:26]),
                        .Funct(InstrD[25:20]),
                        .Rd(InstrD[15:12]),
                        .PCSrcD(PCSrcD),
                        .RegWriteD(RegWriteD),
                        .MemWriteD(MemWriteD),
                        .MemtoRegD(MemtoRegD),
                        .ALUSrcD(ALUSrcD),
                        .BranchD(BranchD),
                        .ImmSrcD(ImmSrcD),
                        .RegSrcD(RegSrcD),
                        .ALUControlD(ALUControlD),
                        .FlagWriteD(FlagWriteD)
                        );

    //Control reg of Decode Cycle
    Rst_CL_FF #(1) dec0 (.clk(clk), .reset(rst), .clear(FlushE), .d(PCSrcD), .q(PCSrcE));
    Rst_CL_FF #(1) dec1 (.clk(clk), .reset(rst), .clear(FlushE), .d(RegWriteD), .q(RegWriteE));
    Rst_CL_FF #(1) dec2 (.clk(clk), .reset(rst), .clear(FlushE), .d(MemtoRegD), .q(MemtoRegE));
    Rst_CL_FF #(1) dec3 (.clk(clk), .reset(rst), .clear(FlushE), .d(MemWriteD), .q(MemWriteE));
    Rst_CL_FF #(1) dec4 (.clk(clk), .reset(rst), .clear(FlushE), .d(ALUControlD), .q(ALUControlE));
    Rst_CL_FF #(1) dec5 (.clk(clk), .reset(rst), .clear(FlushE), .d(BranchD), .q(BranchE));
    Rst_CL_FF #(1) dec6 (.clk(clk), .reset(rst), .clear(FlushE), .d(ALUSrcD), .q(ALUSrcE));
    Rst_CL_FF #(1) dec7 (.clk(clk), .reset(rst), .clear(FlushE), .d(FlagWriteD), .q(FlagWriteE));
    Rst_CL_FF #(4) dec8 (.clk(clk), .reset(rst), .clear(FlushE), .d(InstrD[31:28]), .q(CondE));
    Rst_CL_FF #(1) dec9 (.clk(clk), .reset(rst), .clear(FlushE), .d(Flags), .q(FlagsE));

    //Condition logic 
    Condition_logic cond (.clk(clk), 
                        .rst(rst),
                        .PCS(PCSrcE), 
                        .RegW(RegWriteE),
                        .MemW(MemWriteE),
                        .BranchE(BranchE),
                        .FlagW(FlagWriteE),
                        .Cond(CondE),
                        .ALUFlags(FlagsE),
                        .PCSrc(PCSrc),
                        .RegWrite(RegWrite),
                        .BranchTakenE(BranchTakenE),
                        .MemWrite(MemWrite)
                        );


    //Control reg of Execute Cycle
    Rst_FF #(1) exc0 (.clk(clk), .reset(rst), .d(PCSrc), .q(PCSrcM));
    Rst_FF #(1) exc1 (.clk(clk), .reset(rst), .d(RegWrite), .q(RegWriteM));
    Rst_FF #(1) exc2 (.clk(clk), .reset(rst), .d(MemtoRegE), .q(MemtoRegM));
    Rst_FF #(1) exc3 (.clk(clk), .reset(rst), .d(MemWrite), .q(MemWriteM));

    //Control reg of memory Cycle
    Rst_FF #(1) mem0 (.clk(clk), .reset(rst), .d(PCSrcM), .q(PCSrcW));
    Rst_FF #(1) mem1 (.clk(clk), .reset(rst), .d(RegWriteM), .q(RegWriteM));
    Rst_FF #(1) mem2 (.clk(clk), .reset(rst), .d(MemtoRegM), .q(MemtoRegW));
    
endmodule
