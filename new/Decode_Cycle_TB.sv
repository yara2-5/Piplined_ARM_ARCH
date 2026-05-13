`timescale 1ns/1ps

module decode_tb();

    // ---------------- SIGNALS ----------------
    logic clk, rst;
    logic FlushE;

    logic [1:0] ImmSrcD, RegSrcD;
    logic [31:0] InstrD;

    logic RegWriteW;
    logic [3:0] WA3W;
    logic [31:0] ResultW;

    logic [31:0] PCPlus4F;

    logic [3:0] WA3E, RA1E, RA2E, RA1D, RA2D;
    logic [31:0] RD1E, RD2E, Imm_Ext_E, PCPlus8E;

    // ---------------- DUT INSTANTIATION ----------------
    Decode_Cycle dut (
        .clk(clk),
        .rst(rst),
        .FlushE(FlushE),
        .ImmSrcD(ImmSrcD),
        .RegSrcD(RegSrcD),
        .InstrD(InstrD),
        .RegWriteW(RegWriteW),
        .WA3W(WA3W),
        .ResultW(ResultW),
        .PCPlus4F(PCPlus4F),
        .WA3E(WA3E),
        .RA1E(RA1E),
        .RA2E(RA2E),
        .RA1D(RA1D),
        .RA2D(RA2D),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .Imm_Ext_E(Imm_Ext_E),
        .PCPlus8E(PCPlus8E)
    );

    // ---------------- CLOCK GENERATION ----------------
    // 100ns period (10MHz)
    initial clk = 0;
    always #50 clk = ~clk;

    // ---------------- STIMULUS ----------------
    initial begin
        // Only ONE dump file call is allowed
        $dumpfile("decode_cycle.vcd");
        $dumpvars(0, decode_tb);

        // Initialize all inputs to 0
        rst = 1;
        FlushE = 0;
        RegWriteW = 0;
        InstrD = 0;
        ImmSrcD = 0;
        RegSrcD = 0;
        WA3W = 0;
        ResultW = 0;
        PCPlus4F = 0;

        // Reset sequence
        #150; 
        rst = 0;
        $display("[INFO] Reset released at %t", $time);

        // --- TEST 1: PC+8 check ---
        // PCPlus4F = 4, so PCPlus8E should be 8
        @(posedge clk);
        PCPlus4F = 32'h4;
        
        // Wait for the pipeline register to update (usually 1 clock cycle)
        @(posedge clk);
        #10; // small delay to allow logic to settle
        if (PCPlus8E === 32'h8)
            $display("[PASS] PC+8 is correct: %h", PCPlus8E);
        else
            $display("[FAIL] PC+8 is %h (Expected 8)", PCPlus8E);

        // --- TEST 2: Register Decode ---
        // Example: Register Source setup
        @(posedge clk);
        InstrD = 32'h00001234; 
        RegSrcD = 2'b00;
        
        @(posedge clk);
        #10;
        $display("[INFO] RA1D = %h, RA2D = %h", RA1D, RA2D);

        // --- TEST 3: Writeback check ---
        // Writing to Register 2
        @(posedge clk);
        RegWriteW = 1;
        WA3W = 4'd2;
        ResultW = 32'hAABBCCDD;

        // Allow write to complete and then read back
        @(posedge clk);
        #10;
        $display("[INFO] RD1E (Reg 1) = %h", RD1E);
        $display("[INFO] RD2E (Reg 2) = %h", RD2E);

        // --- TEST 4: Flush Logic ---
        @(posedge clk);
        FlushE = 1;
        @(posedge clk);
        #10;
        $display("[INFO] After flush RD1E=%h RD2E=%h (Should be 0)", RD1E, RD2E);
        
        FlushE = 0;

        #200;
        $display("[DONE] Simulation finished at %t", $time);
        $finish;
    end

endmodule