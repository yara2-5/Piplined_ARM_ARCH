module fetch_cycle(
    input logic clk, rst,
    input logic PCSrcW,
    input logic StallF, 
    input logic StallD,
    input logic FlushD,
    input logic BranchTakenE,
    input logic [31:0] ALUResultE,
    input logic [31:0] ResultW,
    output logic [31:0] InstrD,
    output logic [31:0] PCPlus4F
);

    // Declaring internal signals
    logic [31:0] first_mux_out, PCF, PC;
    logic [31:0] InstrF;

    // Declare muxs
    mux_2_to_1 #(32) PC_MUX1 (.a(PCPlus4F),
                        .b(ResultW),
                        .s(PCSrcW),
                        .c(first_mux_out)
                        );

    mux_2_to_1 #(32) PC_MUX2 (.a(first_mux_out),
                        .b(ALUResultE),
                        .s(BranchTakenE),
                        .c(PC)
                        );

    // Declare PC register
    enable_ff #(32) PC_reg (.clk(clk),
                      .reset(rst),
                      .en(~StallF),
                      .d(PC),
                      .q(PCF)
                       );
    
    
    // Declare PC adder
    PC_Adder PC_adder (
                .a(PCF),
                .b(32'h00000004),
                .c(PCPlus4F)
                );

    // Declare Instruction Memory
    Instruction_Memory IMEM (
                .a(PCF),
                .rd(InstrF)
                );

    // Fetch Cycle Register Logic
    en_cl_ff #(32) instruction_reg (.clk(clk),
                                    .reset(rst),
                                    .en(~StallD),
                                    .clear(FlushD),
                                    .d(InstrF),
                                    .q(InstrD)
                                );

endmodule


module fetch_tb();

    // Declare I/O
    logic clk, rst, PCSrcW, FlushD, StallF, StallD, BranchTakenE;
    logic [31:0] ALUResultE;
    logic [31:0] ResultW, InstrD, PCPlus4F;

    // Declare the design under test
    fetch_cycle dut (
        .clk(clk), .rst(rst), .PCSrcW(PCSrcW), .StallF(StallF), 
        .StallD(StallD), .FlushD(FlushD), .BranchTakenE(BranchTakenE), 
        .ALUResultE(ALUResultE), .ResultW(ResultW), .InstrD(InstrD), 
        .PCPlus4F(PCPlus4F)
    );

    // Generation of clock
    initial clk = 0; 
    always #50 clk = ~clk;

    // Stimulus
    initial begin
        // --- STEP 1: INITIALIZE ---
        PCSrcW = 0; FlushD = 0; StallF = 0; StallD = 0; 
        BranchTakenE = 0; ALUResultE = 32'b0; ResultW = 32'b0;
        rst = 1;
        
        // Wait 2 clock cycles in reset
        repeat (2) @(posedge clk);
        #5; // Offset slightly after the edge
        rst = 0;
        $display("[INFO] Reset released at %t", $time);

        // Test Case 1: Normal Increment
        // Wait for the NEXT edge (where PC will update from 0 to 4)
        @(posedge clk); 
        #10; // Let combinational logic settle (PC_Adder)
        
        // PCF should be 4, and PCPlus4F should be 8
        if (dut.PCF === 32'h4) 
            $display("[PASS] PC updated to 4. PCPlus4F is %h", PCPlus4F);
        else 
            $display("[FAIL] PC is %h, expected 4.", dut.PCF);

        // Test Case 2: Branching
        ALUResultE = 32'h0000_00A0;
        BranchTakenE = 1;
        @(posedge clk); // Edge captures the branch target
        #10;
        BranchTakenE = 0; 
        
        if (dut.PCF === 32'hA0)
            $display("[PASS] Branch taken successfully to %h", dut.PCF);
        else
            $display("[FAIL] Branch failed. PC is %h", dut.PCF);

        // Test Case 3: Stall (Should stay at A0, PC+4 should be A4)
        StallF = 1;
        #100;
        if (dut.PCF === 32'hA0) // PC should not have moved from the branch target
            $display("[PASS] Stall successfully froze the PC.");
        else
            $display("[FAIL] Stall failed. PC changed to %h", dut.PCF);

        StallF = 0; // Release stall
        #200;
        $display("[DONE] Simulation finished at %t", $time);
    end

endmodule