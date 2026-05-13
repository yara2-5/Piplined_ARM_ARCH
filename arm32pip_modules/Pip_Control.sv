`timescale 1ns/1ps
module Pip_Control (
    input logic clk, rst,
    input logic [31:0] InstrD,
    input logic [3:0] ALUFlags,
    // HazardUnit provides FlushE so control registers align with flushed datapath regs.
    input logic FlushE,

    // Expose PCSrc/RegWrite pipeline control to HazardUnit.
    output logic PCSrcD,
    output logic PCSrcE,
    output logic PCSrcM,
    output logic PCSrcW,

    output logic RegWriteE,
    output logic RegWriteM,
    output logic RegWriteW,

    output logic MemtoRegE,
    output logic MemtoRegW,

    // Needed by Memory stage.
    output logic MemWriteM,

    output logic ALUSrcE,
    output logic [2:0] ALUControlE,
    output logic BranchTakenE,
    output logic [1:0] ImmSrcD,
    output logic [1:0] RegSrcD
);
    //internal signals
    logic RegWriteD;
    logic MemWriteD;
    logic MemtoRegD;
    logic ALUSrcD;
    logic BranchD;
    // Condition_logic gated outputs (used for M/W stage control).
    logic PCSrc_gated;
    logic RegWrite_gated;
    logic MemWrite_gated;
    logic [2:0] ALUControlD;
    logic [1:0] FlagWriteD;

    // Execute-stage control registers
    logic MemWriteE;
    logic BranchE;
    logic [1:0] FlagWriteE;
    logic [3:0] CondE;

    // Memory-stage control register
    logic MemtoRegM;

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
    // Decode -> Execute stage control registers
    Rst_CL_FF #(1) dec0 (.clk(clk), .reset(rst), .clear(FlushE), .d(PCSrcD), .q(PCSrcE));
    Rst_CL_FF #(1) dec1 (.clk(clk), .reset(rst), .clear(FlushE), .d(RegWriteD), .q(RegWriteE));
    Rst_CL_FF #(1) dec2 (.clk(clk), .reset(rst), .clear(FlushE), .d(MemtoRegD), .q(MemtoRegE));
    Rst_CL_FF #(1) dec3 (.clk(clk), .reset(rst), .clear(FlushE), .d(MemWriteD), .q(MemWriteE));
    Rst_CL_FF #(3) dec4 (.clk(clk), .reset(rst), .clear(FlushE), .d(ALUControlD), .q(ALUControlE));
    Rst_CL_FF #(1) dec5 (.clk(clk), .reset(rst), .clear(FlushE), .d(BranchD), .q(BranchE));
    Rst_CL_FF #(1) dec6 (.clk(clk), .reset(rst), .clear(FlushE), .d(ALUSrcD), .q(ALUSrcE));
    Rst_CL_FF #(2) dec7 (.clk(clk), .reset(rst), .clear(FlushE), .d(FlagWriteD), .q(FlagWriteE));
    Rst_CL_FF #(4) dec8 (.clk(clk), .reset(rst), .clear(FlushE), .d(InstrD[31:28]), .q(CondE));

    //Condition logic 
    Condition_logic cond (.clk(clk), 
                        .rst(rst),
                        .PCS(PCSrcE), 
                        .RegW(RegWriteE),
                        .MemW(MemWriteE),
                        .BranchE(BranchE),
                        .FlagW(FlagWriteE),
                        .Cond(CondE),
                        .ALUFlags(ALUFlags),
                        .PCSrc(PCSrc_gated),
                        .RegWrite(RegWrite_gated),
                        .BranchTakenE(BranchTakenE),
                        .MemWrite(MemWrite_gated)
                        );


    //Control reg of Execute Cycle
    Rst_FF #(1) exc0 (.clk(clk), .reset(rst), .d(PCSrc_gated), .q(PCSrcM));
    Rst_FF #(1) exc1 (.clk(clk), .reset(rst), .d(RegWrite_gated), .q(RegWriteM));
    Rst_FF #(1) exc2 (.clk(clk), .reset(rst), .d(MemtoRegE), .q(MemtoRegM));
    Rst_FF #(1) exc3 (.clk(clk), .reset(rst), .d(MemWrite_gated), .q(MemWriteM));

    //Control reg of memory Cycle
    Rst_FF #(1) mem0 (.clk(clk), .reset(rst), .d(PCSrcM), .q(PCSrcW));
    Rst_FF #(1) mem1 (.clk(clk), .reset(rst), .d(RegWriteM), .q(RegWriteW));
    Rst_FF #(1) mem2 (.clk(clk), .reset(rst), .d(MemtoRegM), .q(MemtoRegW));
    
endmodule