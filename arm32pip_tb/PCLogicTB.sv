  `timescale 1ns/1ps

module PCLogicTB();

    // Inputs
    logic [3:0] Rd;
    logic Branch;
    logic RegW;

    // Output
    logic PCS;

    // DUT
    PCLogic dut (
        .Rd(Rd),
        .Branch(Branch),
        .RegW(RegW),
        .PCS(PCS)
    );

    initial begin

        // =========================
        // Test 1
        // =========================
        Rd = 4'd0;
        Branch = 0;
        RegW = 0;
        #50;

        if (PCS == 0)
            $display("[PASS] Test 1 Passed");
        else
            $display("[FAIL] Test 1 Failed");

        // =========================
        // Test 2
        // =========================
        Rd = 4'd15;
        RegW = 1;
        Branch = 0;
        #50;

        if (PCS == 1)
            $display("[PASS] Test 2 Passed");
        else
            $display("[FAIL] Test 2 Failed");

        // =========================
        // Test 3
        // =========================
        Branch = 1;
        #50;

        if (PCS == 1)
            $display("[PASS] Test 3 Passed");
        else
            $display("[FAIL] Test 3 Failed");

        $finish;

    end

endmodule