`timescale 1ns/1ps

module MainDecoderTB();

    // Inputs
    logic [1:0] op;
    logic [5:0] Funct;

    // Outputs
    logic Branch;
    logic ALUOp;
    logic RegW;
    logic MemW;
    logic MemtoReg;
    logic ALUSrc;

    logic [1:0] ImmSrc;
    logic [1:0] RegSrc;

    // DUT
    MainDecoder dut (
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

    initial begin

        // =========================
        // Test 1 : DP Register
        // =========================
        op = 2'b00;
        Funct = 6'b000000;
        #50;

        if (RegW && ALUOp && !ALUSrc)
            $display("[PASS] DP Register Test Passed");
        else
            $display("[FAIL] DP Register Test Failed");

        // =========================
        // Test 2 : DP Immediate
        // =========================
        Funct = 6'b100000;
        #50;

        if (ALUSrc && ImmSrc == 2'b00)
            $display("[PASS] DP Immediate Test Passed");
        else
            $display("[FAIL] DP Immediate Test Failed");

        // =========================
        // Test 3 : STR
        // =========================
        op = 2'b01;
        Funct = 6'b000000;
        #50;

        if (MemW && !RegW)
            $display("[PASS] STR Test Passed");
        else
            $display("[FAIL] STR Test Failed");

        // =========================
        // Test 4 : LDR
        // =========================
        Funct = 6'b000001;
        #50;

        if (MemtoReg && RegW)
            $display("[PASS] LDR Test Passed");
        else
            $display("[FAIL] LDR Test Failed");

        // =========================
        // Test 5 : Branch
        // =========================
        op = 2'b10;
        #50;

        if (Branch && ALUSrc)
            $display("[PASS] Branch Test Passed");
        else
            $display("[FAIL] Branch Test Failed");

        $finish;

    end

endmodule