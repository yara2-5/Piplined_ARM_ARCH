 `timescale 1ns/1ps

module hazard_tb();

    // Declare I/O
    logic rst;

    logic [3:0] RA1E, RA2E;
    logic [3:0] RA1D, RA2D;
    logic [3:0] WA3E, WA3M, WA3W;

    logic RegWriteE, RegWriteM, RegWriteW;
    logic MemtoRegE;

    logic PCSrcD, PCSrcE, PCSrcM, PCSrcW;
    logic BranchTakenE;

    logic [1:0] ForwardAE, ForwardBE;
    logic StallF, StallD;
    logic FlushD, FlushE;

    // DUT
    HazardUnit dut (
        .rst(rst),

        .RA1E(RA1E), .RA2E(RA2E),
        .RA1D(RA1D), .RA2D(RA2D),
        .WA3E(WA3E), .WA3M(WA3M), .WA3W(WA3W),

        .RegWriteE(RegWriteE),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),

        .MemtoRegE(MemtoRegE),

        .PCSrcD(PCSrcD),
        .PCSrcE(PCSrcE),
        .PCSrcM(PCSrcM),
        .PCSrcW(PCSrcW),

        .BranchTakenE(BranchTakenE),

        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),

        .StallF(StallF),
        .StallD(StallD),

        .FlushD(FlushD),
        .FlushE(FlushE)
    );

    // Generation of clock (not required but kept for style consistency)
    logic clk;
    initial clk = 0;
    always #50 clk = ~clk;

    // Stimulus
    initial begin

        // --- STEP 1: INITIALIZE ALL INPUTS TO 0 ---
        rst = 1;

        RA1E = 0; RA2E = 0;
        RA1D = 0; RA2D = 0;
        WA3E = 0; WA3M = 0; WA3W = 0;

        RegWriteE = 0; RegWriteM = 0; RegWriteW = 0;
        MemtoRegE = 0;

        PCSrcD = 0; PCSrcE = 0; PCSrcM = 0; PCSrcW = 0;
        BranchTakenE = 0;

        // VCD dump
        $dumpfile("dump.vcd");
        $dumpvars(0, hazard_tb);

        // --- STEP 2: RESET PHASE ---
        #105;
        rst = 0;
        $display("[INFO] Reset released at %t", $time);

        // =====================================================
        // Test Case 1: Forwarding from Memory stage (M)
        // =====================================================
        RA1E = 4'd2;
        WA3M = 4'd2;
        RegWriteM = 1;

        #50;
        if (ForwardAE === 2'b10)
            $display("[PASS] ForwardAE from M stage works");
        else
            $display("[FAIL] ForwardAE = %b", ForwardAE);

        // =====================================================
        // Test Case 2: Forwarding from Writeback stage (W)
        // =====================================================
        WA3M = 4'd0;
        WA3W = 4'd2;
        RegWriteM = 0;
        RegWriteW = 1;

        #50;
        if (ForwardAE === 2'b01)
            $display("[PASS] ForwardAE from W stage works");
        else
            $display("[FAIL] ForwardAE = %b", ForwardAE);

        // =====================================================
        // Test Case 3: Forward BE forwarding
        // =====================================================
        RA2E = 4'd5;
        WA3W = 4'd5;
        RegWriteW = 1;

        #50;
        if (ForwardBE === 2'b01)
            $display("[PASS] ForwardBE works");
        else
            $display("[FAIL] ForwardBE = %b", ForwardBE);

        // =====================================================
        // Test Case 4: Load-use hazard (stall)
        // =====================================================
        RA1D = 4'd3;
        WA3E = 4'd3;
        MemtoRegE = 1;
        RegWriteE = 1;

        #50;
        if (StallF === 1 && StallD === 1)
            $display("[PASS] Load-use stall detected");
        else
            $display("[FAIL] StallF=%b StallD=%b", StallF, StallD);

        // =====================================================
        // Test Case 5: Branch flush signals
        // =====================================================
        PCSrcW = 1;

        #50;
        if (FlushD === 1)
            $display("[PASS] FlushD triggered");
        else
            $display("[FAIL] FlushD = %b", FlushD);

        PCSrcW = 0;

        // =====================================================
        // Test Case 6: Branch taken flush
        // =====================================================
        BranchTakenE = 1;

        #50;
        if (FlushE === 1)
            $display("[PASS] FlushE triggered");
        else
            $display("[FAIL] FlushE = %b", FlushE);

        // END
        #100;
        $display("[DONE] Simulation finished at %t", $time);
        $finish;
    end

endmodule