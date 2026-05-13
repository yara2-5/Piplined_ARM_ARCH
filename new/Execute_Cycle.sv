`timescale 1ns/1ps
module Execute_Cycle(

    input  logic        clk,
    input  logic        rst,

    // Decode
    input  logic [3:0]  WA3E,
    input  logic [3:0]  RA1E,
    input  logic [3:0]  RA2E,

    input  logic [31:0] RD1E,
    input  logic [31:0] RD2E,
    input  logic [31:0] Imm_Ext_E,
    input  logic [31:0] PCPlus8E,

    // Control
    input  logic        AluSrcE,
    input  logic [2:0]  AluControlE,

    // Hazard
    input  logic [1:0]  ForwardAE,
    input  logic [1:0]  ForwardBE,

    input  logic [31:0] ResultW,

    // Outputs
   
    output logic [3:0]  ALUFlags,

    // Pipeline Outputs
    output logic [3:0]  WA3M,
    output logic [31:0] ALUOutM,
    output logic [31:0] WriteDataM,
    output logic [31:0] AluResultE,
    output logic [31:0] BranchTargetM

);

logic [31:0] WriteDataE;
logic [31:0] BranchTargetE ;

ExecuteOperation operation (.clk(clk), 
                .rst(rst), 
                .RA1E(RA1E), 
                .RA2E(RA2E), 
                .RD1E(RD1E), 
                .RD2E(RD2E), 
                .Imm_Ext_E(Imm_Ext_E), 
                .PCPlus8E(PCPlus8E), 
                .AluSrcE(AluSrcE), 
                .AluControlE(AluControlE), 
                .ForwardAE(ForwardAE), 
                .ForwardBE(ForwardBE), 
                .ResultW(ResultW), 
                .ALUOutM(ALUOutM), 
                .ALUFlags(ALUFlags), 
                .BranchTargetE(BranchTargetE), 
                .AluResultE(AluResultE), 
                .WriteDataE(WriteDataE)

);

execute_reg exreg (.clk(clk), 
            .reset(rst), 
            .ALUResultE(AluResultE), 
            .WriteDataE(WriteDataE), 
            .WA3E(WA3E), 
            .WA3M(WA3M), 
            .ALUOutM(ALUOutM), 
            .WriteDataM(WriteDataM),
            .BranchTargetE(BranchTargetE), 
            .BranchTargetM(BranchTargetM)  
);


endmodule

`timescale 1ns/1ps
module execute_tb();

    // ---------------- SIGNALS ----------------
    logic clk, rst;

    // Decode Inputs
    logic [3:0]  WA3E, RA1E, RA2E;
    logic [31:0] RD1E, RD2E, Imm_Ext_E, PCPlus8E;

    // Control Inputs
    logic        AluSrcE;
    logic [2:0]  AluControlE;

    // Hazard/Forwarding Inputs
    logic [1:0]  ForwardAE, ForwardBE;
    logic [31:0] ResultW;

    // Outputs
    logic [3:0]  ALUFlags;
    
    // Pipeline Outputs
    logic [3:0]  WA3M;
    logic [31:0] ALUOutM, WriteDataM, AluResultE, BranchTargetM;

    // ---------------- DUT INSTANTIATION ----------------
    Execute_Cycle dut (
        .clk(clk),
        .rst(rst),
        .WA3E(WA3E),
        .RA1E(RA1E),
        .RA2E(RA2E),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .Imm_Ext_E(Imm_Ext_E),
        .PCPlus8E(PCPlus8E),
        .AluSrcE(AluSrcE),
        .AluControlE(AluControlE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .ResultW(ResultW),
        .ALUFlags(ALUFlags),
        .WA3M(WA3M),
        .ALUOutM(ALUOutM),
        .WriteDataM(WriteDataM),
        .AluResultE(AluResultE),
        .BranchTargetM(BranchTargetM)
    );

    // ---------------- CLOCK GENERATION ----------------
    initial clk = 0;
    always #50 clk = ~clk;

    // ---------------- STIMULUS ----------------
    initial begin
        $dumpfile("execute_cycle.vcd");
        $dumpvars(0, execute_tb);

        // Initialize Inputs
        rst = 1;
        WA3E = 0; RA1E = 0; RA2E = 0;
        RD1E = 0; RD2E = 0; Imm_Ext_E = 0; PCPlus8E = 0;
        AluSrcE = 0; AluControlE = 3'b000; // Assume 000 is ADD
        ForwardAE = 2'b00; ForwardBE = 2'b00;
        ResultW = 0;

        #150 rst = 0;

        // --- TEST 1: Basic ALU Addition (Reg + Reg) ---
        @(posedge clk);
        RD1E = 32'd10;
        RD2E = 32'd20;
        AluControlE = 3'b000; // ADD
        AluSrcE = 0;          // Select WriteDataE (RD2E)
        ForwardAE = 2'b00;    // Select RD1E
        ForwardBE = 2'b00;    // Select RD2E
        
        #10; // Combinational check
        if (AluResultE === 32'd30)
            $display("[PASS] TEST 1: Basic Addition. Result: %d", AluResultE);
        else
            $display("[FAIL] TEST 1: Basic Addition. Got %d", AluResultE);

        // --- TEST 2: ALU with Immediate (Reg + Imm) ---
        @(posedge clk);
        RD1E = 32'd50;
        Imm_Ext_E = 32'd100;
        AluSrcE = 1;          // Select Immediate
        
        #10;
        if (AluResultE === 32'd150)
            $display("[PASS] TEST 2: Immediate Addition. Result: %d", AluResultE);
        else
            $display("[FAIL] TEST 2: Immediate Addition. Got %d", AluResultE);

        // --- TEST 3: Forwarding from Writeback (ResultW) ---
        @(posedge clk);
        RD1E = 32'd0;         // Should be ignored
        ResultW = 32'd77;     // Data to forward
        ForwardAE = 2'b01;    // Select ResultW
        AluSrcE = 1;
        Imm_Ext_E = 32'd3;
        
        #10;
        if (AluResultE === 32'd80)
            $display("[PASS] TEST 3: Forwarding from Writeback. Result: %d", AluResultE);
        else
            $display("[FAIL] TEST 3: Forwarding from Writeback. Got %d", AluResultE);

        // --- TEST 4: Pipeline Register Check (Execute -> Memory) ---
        @(posedge clk);
        WA3E = 4'hA;
        // The result from the PREVIOUS clock (80) should move to ALUOutM now
        @(posedge clk);
        #10;
        if (WA3M === 4'hA && ALUOutM === 32'd80)
            $display("[PASS] TEST 4: Pipeline Register Transfer");
        else
            $display("[FAIL] TEST 4: Pipeline Register Transfer. WA3M=%h, ALUOutM=%d", WA3M, ALUOutM);

        // --- TEST 5: Branch Target Calculation ---
        @(posedge clk);
        PCPlus8E = 32'h1000;
        Imm_Ext_E = 32'h4;    // (Assuming branch offset is already shifted or handled)
        
        #10;
        // BranchTargetE is combinational in your module
        if (dut.BranchTargetE === 32'h1004)
            $display("[PASS] TEST 5: Branch Target Calculation");
        else
            $display("[FAIL] TEST 5: Branch Target Calculation. Got %h", dut.BranchTargetE);

        #200;
        $finish;
    end

endmodule