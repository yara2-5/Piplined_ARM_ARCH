`timescale 1ns/1ps
module ControlUnit_tb();

    logic [1:0] op;
    logic [5:0] Funct;
    logic [3:0] Rd;

    logic PCSrcD;
    logic RegWriteD;
    logic MemWriteD;
    logic MemtoRegD;
    logic ALUSrcD;
    logic BranchD;

    logic [1:0] ImmSrcD;
    logic [1:0] RegSrcD;

    logic [2:0] ALUControlD;
    logic [1:0] FlagWriteD;

    ControlUnit dut (
        .op(op),
        .Funct(Funct),
        .Rd(Rd),
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

    initial begin
        op = 0;
        Funct = 0;
        Rd = 0;
        #50;

        op = 2'b00;
        Funct = 6'b000000;
        Rd = 4'b0000;
        #100;

        if (RegWriteD === 0 && MemWriteD === 0)
            $display("[PASS] Case 1");
        else
            $display("[FAIL] Case 1");

        op = 2'b01;
        Funct = 6'b010000;
        Rd = 4'b0010;
        #100;

        if (BranchD === 1)
            $display("[PASS] Case 2");
        else
            $display("[FAIL] Case 2");

        op = 2'b10;
        Funct = 6'b010100;
        Rd = 4'b0101;
        #100;

        if (ALUControlD !== 3'bxxx)
            $display("[PASS] Case 3");
        else
            $display("[FAIL] Case 3");

        #200;
        $finish;
    end

    initial begin
        $dumpfile("ControlUnit.vcd");
        $dumpvars(0, ControlUnit_tb);
    end

endmodule 