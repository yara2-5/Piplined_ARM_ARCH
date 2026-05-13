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

    // DUT
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

        // =========================
        // Initialize
        // =========================
        op    = 0;
        Funct = 0;
        Rd    = 0;

        #50;

        // ==================================================
        // Test 1 : Data Processing Register
        // ==================================================
        op    = 2'b00;
        Funct = 6'b000000; // DP register
        Rd    = 4'b0000;

        #100;

        if (RegWriteD === 1 &&
            MemWriteD === 0 &&
            ALUSrcD   === 0 &&
            BranchD   === 0)
        begin
            $display("[PASS] DP Register");
        end
        else begin
            $display("[FAIL] DP Register");
            $display("RegWrite=%b MemWrite=%b ALUSrc=%b Branch=%b",
                      RegWriteD, MemWriteD, ALUSrcD, BranchD);
        end


        // ==================================================
        // Test 2 : Data Processing Immediate
        // ==================================================
        op    = 2'b00;
        Funct = 6'b100000; // Funct[5]=1 -> immediate
        Rd    = 4'b0001;

        #100;

        if (RegWriteD === 1 &&
            MemWriteD === 0 &&
            ALUSrcD   === 1 &&
            BranchD   === 0)
        begin
            $display("[PASS] DP Immediate");
        end
        else begin
            $display("[FAIL] DP Immediate");
            $display("RegWrite=%b MemWrite=%b ALUSrc=%b Branch=%b",
                      RegWriteD, MemWriteD, ALUSrcD, BranchD);
        end


        // ==================================================
        // Test 3 : STR
        // ==================================================
        op    = 2'b01;
        Funct = 6'b000000; // STR -> Funct[0]=0
        Rd    = 4'b0010;

        #100;

        if (MemWriteD === 1 &&
            RegWriteD === 0 &&
            ALUSrcD   === 1 &&
            MemtoRegD === 0)
        begin
            $display("[PASS] STR");
        end
        else begin
            $display("[FAIL] STR");
            $display("MemWrite=%b RegWrite=%b ALUSrc=%b MemtoReg=%b",
                      MemWriteD, RegWriteD, ALUSrcD, MemtoRegD);
        end


        // ==================================================
        // Test 4 : LDR
        // ==================================================
        op    = 2'b01;
        Funct = 6'b000001; // LDR -> Funct[0]=1
        Rd    = 4'b0011;

        #100;

        if (RegWriteD === 1 &&
            MemtoRegD === 1 &&
            MemWriteD === 0 &&
            ALUSrcD   === 1)
        begin
            $display("[PASS] LDR");
        end
        else begin
            $display("[FAIL] LDR");
            $display("RegWrite=%b MemtoReg=%b MemWrite=%b ALUSrc=%b",
                      RegWriteD, MemtoRegD, MemWriteD, ALUSrcD);
        end


        // ==================================================
        // Test 5 : Branch
        // ==================================================
        op    = 2'b10;
        Funct = 6'b000000;
        Rd    = 4'b0101;

        #100;

        if (BranchD   === 1 &&
            RegWriteD === 0 &&
            MemWriteD === 0 &&
            PCSrcD    === 1)
        begin
            $display("[PASS] Branch");
        end
        else begin
            $display("[FAIL] Branch");
            $display("Branch=%b RegWrite=%b MemWrite=%b PCSrc=%b",
                      BranchD, RegWriteD, MemWriteD, PCSrcD);
        end


        // ==================================================
        // Test 6 : PCSrc from Rd == 1111
        // ==================================================
        op    = 2'b00;
        Funct = 6'b000000;
        Rd    = 4'b1111;

        #100;

        if (PCSrcD === 1)
        begin
            $display("[PASS] PC Logic");
        end
        else begin
            $display("[FAIL] PC Logic");
            $display("PCSrc=%b", PCSrcD);
        end


        #200;
        $finish;

    end


    // Waveform
    initial begin
        $dumpfile("ControlUnit.vcd");
        $dumpvars(0, ControlUnit_tb);
    end

endmodule