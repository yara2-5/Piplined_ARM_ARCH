`timescale 1ns/1ps

module Condition_Check_tb();

    // DUT I/O
    logic [3:0] Cond;
    logic [3:0] Flags;
    logic CondEx;

    // DUT instance
    Condition_Check dut (
        .Cond(Cond),
        .Flags(Flags),
        .CondEx(CondEx)
    );

    // Clock (not required, but kept for same style consistency)
    logic clk;
    initial clk = 0;
    always begin
        clk = ~clk;
        #50;
    end

    // Task to check result
    task check(input string test_name, input logic expected);
        #1;
        if (CondEx === expected)
            $display("[PASS] %s | Cond=%b Flags=%b => CondEx=%b",
                      test_name, Cond, Flags, CondEx);
        else
            $display("[FAIL] %s | Cond=%b Flags=%b => CondEx=%b (Expected %b)",
                      test_name, Cond, Flags, CondEx, expected);
    endtask

    initial begin
        $dumpfile("Condition_Check.vcd");
        $dumpvars(0, Condition_Check_tb);

        // ----------------------------
        // FLAGS FORMAT: NZCV
        // ----------------------------

        // Test 1: ZERO flag
        Flags = 4'b0_1_0_0; // Z=1
        Cond  = 4'b0000;    // EQ
        #100;
        check("EQ when zero=1", 1);

        Cond = 4'b0001;     // NE
        #100;
        check("NE when zero=1", 0);

        // Test 2: NEG flag
        Flags = 4'b1_0_0_0; // N=1
        Cond  = 4'b0100;    // MI
        #100;
        check("MI when neg=1", 1);

        Cond = 4'b0101;     // PL
        #100;
        check("PL when neg=1", 0);

        // Test 3: CARRY flag
        Flags = 4'b0_0_1_0; // C=1
        Cond  = 4'b0010;    // CS
        #100;
        check("CS when carry=1", 1);

        Cond = 4'b0011;     // CC
        #100;
        check("CC when carry=1", 0);

        // Test 4: OVERFLOW
        Flags = 4'b0_0_0_1; // V=1
        Cond  = 4'b0110;    // VS
        #100;
        check("VS when overflow=1", 1);

        Cond = 4'b0111;     // VC
        #100;
        check("VC when overflow=1", 0);

        // Test 5: GE condition (N == V)
        Flags = 4'b1_0_0_1; // N=1, V=1 => GE=1
        Cond  = 4'b1010;
        #100;
        check("GE when N==V", 1);

        Flags = 4'b1_0_0_0; // N=1, V=0 => GE=0
        #100;
        check("GE when N!=V", 0);

        // Test 6: ALWAYS
        Flags = 4'b0_0_0_0;
        Cond  = 4'b1110;
        #100;
        check("Always true", 1);

        // Test 7: NEVER
        Cond  = 4'b1111;
        #100;
        check("Always false", 0);

        $display("[DONE] Simulation finished at %t", $time);
        $finish;
    end

endmodule