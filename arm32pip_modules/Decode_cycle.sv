`timescale 1ns/1ps
module Decode_Cycle(
    input  logic        clk,
    input  logic        rst,
    input  logic        FlushE,

    input  logic [1:0]  ImmSrcD,
    input  logic [1:0]  RegSrcD,

    input  logic [31:0] InstrD,

    input  logic        RegWriteW,
    input  logic [3:0]  WA3W,
    input  logic [31:0] ResultW,

    input  logic [31:0] PCPlus4F,

    output logic [3:0]  WA3E,
    output logic [3:0]  RA1E,
    output logic [3:0]  RA2E,

    output logic [3:0]  RA1D,
    output logic [3:0]  RA2D,

    output logic [31:0] RD1E,
    output logic [31:0] RD2E,
    output logic [31:0] Imm_Ext_E,
    output logic [31:0] PCPlus8E
);

    // Internal signals
    logic [3:0]  RA1D_int, RA2D_int;
    logic [3:0]  WA3D;

    logic [31:0] PCPlus8D;
    logic [31:0] RD1D, RD2D, Imm_Ext_D;


    // RA1 mux
    mux_2_to_1 #(.WIDTH(4)) MUX1 (
        .a(InstrD[19:16]),
        .b(4'b1111),
        .s(RegSrcD[0]),
        .c(RA1D_int)
    );

    // RA2 mux
    mux_2_to_1 #(.WIDTH(4)) MUX2 (
        .a(InstrD[3:0]),
        .b(InstrD[15:12]),
        .s(RegSrcD[1]),
        .c(RA2D_int)
    );

    // PC + 8
    PC_Adder pc1 (
        .a(PCPlus4F),
        .b(32'h00000004),
        .c(PCPlus8D)
    );

    // Destination register
    assign WA3D = InstrD[15:12];

    // Register File
    Register_File rf (
        .clk(clk),
        .rst(rst),
        .WE3(RegWriteW),
        .WD3(ResultW),

        .A1(RA1D),
        .A2(RA2D),
        .A3(WA3W),

        .R15(PCPlus8D),

        .RD1(RD1D),
        .RD2(RD2D)
    );

    // Sign Extend
    Sign_Extend extension (
        .Instr(InstrD[23:0]),
        .ImmSrc(ImmSrcD),
        .Imm_Ext(Imm_Ext_D)
    );

    // Pipeline Registers

    Rst_CL_FF #(.WIDTH(32)) FF_RD1 (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(RD1D),
        .q(RD1E)
    );

    Rst_CL_FF #(.WIDTH(32)) FF_RD2 (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(RD2D),
        .q(RD2E)
    );

    Rst_CL_FF #(.WIDTH(32)) FF_IMM (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(Imm_Ext_D),
        .q(Imm_Ext_E)
    );

    Rst_CL_FF #(.WIDTH(4)) FF_WA (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(WA3D),
        .q(WA3E)
    );

    Rst_CL_FF #(.WIDTH(4)) FF_RA1 (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(RA1D_int),
        .q(RA1E)
    );

    Rst_CL_FF #(.WIDTH(4)) FF_RA2 (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(RA2D_int),
        .q(RA2E)
    );

    Rst_CL_FF #(.WIDTH(32)) FF_PC (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(PCPlus8D),
        .q(PCPlus8E)
    );

    // Drive hazard-unit outputs
    assign RA1D = RA1D_int;
    assign RA2D = RA2D_int;

endmodule
