`timescale 1ns/1ps
module memory_tb();

    // ---------------- SIGNALS ----------------
    logic clk, rst;
    logic MemWriteM;
    logic [31:0] ALUOutM, WriteDataM, BranchTargetM;
    logic [3:0]  WA3M; // Fixed to 4-bit to match Execute Cycle

    // Outputs
    logic [3:0]  WA3W;
    logic [31:0] ALUOutW, ReadDataW, BranchTargetW;

    // ---------------- DUT INSTANTIATION ----------------
    memory_cycle dut (
        .clk(clk),
        .rst(rst),
        .MemWriteM(MemWriteM),
        .ALUOutM(ALUOutM),
        .WriteDataM(WriteDataM),
        .WA3M(WA3M),
        .BranchTargetM(BranchTargetM),
        .WA3W(WA3W),
        .ALUOutW(ALUOutW),
        .ReadDataW(ReadDataW),
        .BranchTargetW(BranchTargetW)
    );

    // ---------------- CLOCK GENERATION ----------------
    initial clk = 0;
    always #50 clk = ~clk;

    // ---------------- STIMULUS ----------------
    initial begin
        $dumpfile("memory_cycle.vcd");
        $dumpvars(0, memory_tb);

        // Initialize Inputs
        rst = 1;
        MemWriteM = 0;
        ALUOutM = 0;
        WriteDataM = 0;
        WA3M = 0;
        BranchTargetM = 0;

        #150 rst = 0;

        // --- TEST 1: Memory Write (Store Word) ---
        @(posedge clk);
        MemWriteM = 1;
        ALUOutM = 32'd4;       // Writing to address 4 (RAM index 1)
        WriteDataM = 32'hDEADBEEF;
        WA3M = 4'h5;           // Destination register for later
        
        @(posedge clk);        // Write occurs here
        MemWriteM = 0;
        
        #10;
        // Check if the write was successful by looking inside the RAM
        if (dut.dmem.RAM[1] === 32'hDEADBEEF)
            $display("[PASS] TEST 1: Memory Write successful");
        else
            $display("[FAIL] TEST 1: Memory Write. Got %h", dut.dmem.RAM[1]);

        // --- TEST 2: Memory Read (Load Word) ---
        @(posedge clk);
        ALUOutM = 32'd4;       // Read from the address we just wrote
        
        #10;
        // Check combinational ReadDataM before it hits the pipeline reg
        if (dut.ReadDataM === 32'hDEADBEEF)
            $display("[PASS] TEST 2: Memory Read successful");
        else
            $display("[FAIL] TEST 2: Memory Read. Got %h", dut.ReadDataM);

        // --- TEST 3: Pipeline Register Check (M -> W) ---
        // At the next clock edge, the data from Test 2 should move to 'W' outputs
        @(posedge clk);
        #10;
        if (ReadDataW === 32'hDEADBEEF && ALUOutW === 32'd4 && WA3W === 4'h5)
            $display("[PASS] TEST 3: Pipeline Registers (M to W) Transfer");
        else begin
            $display("[FAIL] TEST 3: Pipeline Transfer Error!");
            $display("       ReadDataW: %h, ALUOutW: %h, WA3W: %h", ReadDataW, ALUOutW, WA3W);
        end

        // --- TEST 4: Branch Target Propagation ---
        @(posedge clk);
        BranchTargetM = 32'h000010FC;
        @(posedge clk);
        #10;
        if (BranchTargetW === 32'h000010FC)
            $display("[PASS] TEST 4: Branch Target Propagation");
        else
            $display("[FAIL] TEST 4: Branch Target Propagation. Got %h", BranchTargetW);

        #200;
        $display("---------------------------------------");
        $display("[DONE] Memory Cycle Simulation Finished");
        $display("---------------------------------------");
        $finish;
    end

endmodule

