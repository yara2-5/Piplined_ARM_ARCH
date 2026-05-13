`timescale 1ns/1ps
module DataPath_tb();

    // --- Clock and Reset ---
    logic clk;
    logic rst;

    // --- Inputs to DataPath ---
    logic MemtoRegW, PCSrcW;
    logic StallF, StallD;
    logic FlushD, FlushE;
    logic BranchTakenE;
    logic AluSrcE;
    logic MemWriteM;
    logic [1:0] ImmSrcD;
    logic [1:0] RegSrcD;
    logic [2:0] AluControlE;
    logic RegWriteW;
    logic [1:0] ForwardAE;
    logic [1:0] ForwardBE;

    // --- Outputs from DataPath ---
    logic [3:0]  ALUFlags;
    logic [31:0] InstrD;
    logic [31:0] AluResultE;
    
    // These signals MUST be declared for .* to work 
    // since they are ports in your DataPath module
    logic [3:0]  RA1D;
    logic [3:0]  RA2D;

    // --- Internal Tracking for Pass/Fail ---
    logic [31:0] expected_val;

    // --- Instantiate the Unit Under Test (UUT) ---
    DataPath uut (.*);

    // --- Clock Generation (100MHz) ---
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // --- Stimulus ---
    initial begin
        // 1. Initialize Inputs to default "safe" state
        rst = 1;
        {MemtoRegW, PCSrcW, StallF, StallD, FlushD, FlushE, BranchTakenE, AluSrcE, MemWriteM, RegWriteW} = '0;
        {ImmSrcD, RegSrcD, ForwardAE, ForwardBE} = '0;
        AluControlE = 3'b000;
        
        // 2. Release Reset
        #15 rst = 0;
        $display("--- Simulation Started: Testing DataPath Integration ---");

        // 3. Test Case: Manual ADD Operation
        // We assume your Register File or Memory has data ready.
        // We'll capture what's in the pipeline and track it.
        
        @(posedge clk);
        // Stage: Execute - Trigger an ADD
        AluControlE = 3'b000; // Assuming 000 is ADD
        AluSrcE     = 0;      // Using RD2, not Immediate
        
        // Let's capture the current values in the Execute stage
        #1; // Wait for combinational logic to settle after clock edge
        expected_val = uut.RD1E + uut.RD2E;
        $display("Time %0t: Captured Operands in Execute. RD1E=%d, RD2E=%d | Expected Result: %d", 
                 $time, uut.RD1E, uut.RD2E, expected_val);

        // 4. Wait for Pipeline Latency (3 Cycles to reach Writeback)
        // Cycle 1: Execute -> Memory
        // Cycle 2: Memory  -> Writeback
        // Cycle 3: Writeback result is stable
        repeat (3) @(posedge clk);

        // 5. Pass/Fail Verification
        #1; 
        if (expected_val === 32'hX) begin
            $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            $display("TEST FAILED: Result is X (Unknown).");
            $display("Check your Register File initialization or Reset logic.");
            $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        end
        else if (uut.ResultW === expected_val) begin
            $display("************************************");
            $display("TEST PASSED!");
            $display("Time: %0t | Final ResultW: %d", $time, uut.ResultW);
            $display("Logic successfully propagated through 5 stages.");
            $display("************************************");
        end 
        else begin
            $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            $display("TEST FAILED!");
            $display("Time: %0t | Expected: %d | Got: %d", $time, expected_val, uut.ResultW);
            $display("Check pipeline registers: execute_reg or memory_reg.");
            $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        end

        #50;
        $display("--- Simulation Finished ---");
        $finish;
    end

    // --- Monitor for Debugging ---
    initial begin
        $monitor("T=%0t | PCF=%h | InstrD=%h | AluResultE=%h | ResultW=%h", 
                 $time, uut.fetch.PCF, InstrD, AluResultE, uut.ResultW);
    end

endmodule
