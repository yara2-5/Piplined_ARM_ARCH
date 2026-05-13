`timescale 1ns/1ps
module Condition_logic_tb();

    logic clk, rst;
    logic PCS, RegW, MemW, BranchE;
    logic [1:0] FlagW;
    logic [3:0] Cond;
    logic [3:0] ALUFlags;

    logic PCSrc;
    logic RegWrite;
    logic BranchTakenE;
    logic MemWrite;

    Condition_logic dut (
        .clk(clk),
        .rst(rst),
        .PCS(PCS),
        .RegW(RegW),
        .MemW(MemW),
        .BranchE(BranchE),
        .FlagW(FlagW),
        .Cond(Cond),
        .ALUFlags(ALUFlags),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .BranchTakenE(BranchTakenE),
        .MemWrite(MemWrite)
    );

    initial clk = 0;
    always #50 clk = ~clk;

    initial begin
        $dumpfile("Condition_logic.vcd");
        $dumpvars(0, Condition_logic_tb);

        rst = 1;
        PCS = 0;
        RegW = 0;
        MemW = 0;
        BranchE = 0;
        FlagW = 0;
        Cond = 0;
        ALUFlags = 0;

        #100;
        rst = 0;

        PCS = 1;
        RegW = 1;
        MemW = 1;
        BranchE = 1;
        FlagW = 2'b11;
        Cond = 4'b0000;
        ALUFlags = 4'b0000;

        #100;

        if (PCSrc === 0 && RegWrite === 0 && MemWrite === 0 && BranchTakenE === 0)
            $display("[PASS] Condition false case");
        else
            $display("[FAIL] Condition false case");

        ALUFlags = 4'b0100;
        Cond = 4'b0001;

        #100;

        if (PCSrc === 1 || RegWrite === 1 || MemWrite === 1 || BranchTakenE === 1)
            $display("[PASS] Condition true case");
        else
            $display("[FAIL] Condition true case");

        FlagW = 2'b10;
        ALUFlags = 4'b1111;
        Cond = 4'b1110;

        #100;

        $display("[DONE] Simulation finished at %t", $time);
        $finish;
    end

endmodule