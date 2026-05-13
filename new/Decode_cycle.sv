`timescale 1ns/1ps
module Decode_Cycle(
    input  logic        clk,
    input  logic        rst,
    input  logic        FlushE,

    input  logic [1:0]  ImmSrcD,
    input  logic [1:0]  RegSrcD,

    input  logic [31:0] InstrD,

    input  logic        RegWriteW,
    input  logic [3:0]  WA3W,
    input  logic [31:0] ResultW,

    input  logic [31:0] PCPlus4F,

    output logic [3:0]  WA3E,
    output logic [3:0]  RA1E,
    output logic [3:0]  RA2E,
    // Hazard unit needs the *decode-stage* source registers for load-use detection.
    output logic [3:0]  RA1D,
    output logic [3:0]  RA2D,

    output logic [31:0] RD1E,
    output logic [31:0] RD2E,
    output logic [31:0] Imm_Ext_E,
    output logic [31:0] PCPlus8E
);

    // Internal signals
    logic [3:0]  RA1D_int, RA2D_int;
    logic [3:0]  WA3D;

    logic [31:0] PCPlus8D;
    logic [31:0] RD1D, RD2D, Imm_Ext_D;


    // RA1 mux
    mux_2_to_1 #(.WIDTH(4)) MUX1 (
        .a(InstrD[19:16]),
        .b(4'b1111),
        .s(RegSrcD[0]),
        .c(RA1D_int)
    );

    // RA2 mux
    mux_2_to_1 #(.WIDTH(4)) MUX2 (
        .a(InstrD[3:0]),
        .b(InstrD[15:12]),
        .s(RegSrcD[1]),
        .c(RA2D_int)
    );

    // PC + 8
    PC_Adder pc1 (
        .a(PCPlus4F),
        .b(32'h00000004),
        .c(PCPlus8D)
    );

    // Destination register
    assign WA3D = InstrD[15:12];

    // Register File
    Register_File rf (
        .clk(clk),
        .rst(rst),
        .WE3(RegWriteW),
        .WD3(ResultW),

        .A1(RA1D),
        .A2(RA2D),
        .A3(WA3W),

        .R15(PCPlus8D),

        .RD1(RD1D),
        .RD2(RD2D)
    );

    // Sign Extend
    Sign_Extend extension (
        .Instr(InstrD[23:0]),
        .ImmSrc(ImmSrcD),
        .Imm_Ext(Imm_Ext_D)
    );

    // Pipeline Registers

    Rst_CL_FF #(.WIDTH(32)) FF_RD1 (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(RD1D),
        .q(RD1E)
    );

    Rst_CL_FF #(.WIDTH(32)) FF_RD2 (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(RD2D),
        .q(RD2E)
    );

    Rst_CL_FF #(.WIDTH(32)) FF_IMM (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(Imm_Ext_D),
        .q(Imm_Ext_E)
    );

    Rst_CL_FF #(.WIDTH(4)) FF_WA (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(WA3D),
        .q(WA3E)
    );

    Rst_CL_FF #(.WIDTH(4)) FF_RA1 (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(RA1D_int),
        .q(RA1E)
    );

    Rst_CL_FF #(.WIDTH(4)) FF_RA2 (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(RA2D_int),
        .q(RA2E)
    );

    Rst_CL_FF #(.WIDTH(32)) FF_PC (
        .clk(clk),
        .reset(rst),
        .clear(FlushE),
        .d(PCPlus8D),
        .q(PCPlus8E)
    );

    // Drive hazard-unit outputs
    assign RA1D = RA1D_int;
    assign RA2D = RA2D_int;

endmodule

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

        // --- TEST 1: PC+8 check ---
        @(posedge clk);
        PCPlus4F = 32'h4;
        
        @(posedge clk);
        #10; 
        if (PCPlus8E === 32'h8)
            $display("[PASS] TEST 1: PC+8 Calculation");
        else
            $display("[FAIL] TEST 1: PC+8 Calculation. Expected 8, Got %h", PCPlus8E);

        // --- TEST 2: Register Address Decode ---
        @(posedge clk);
        // InstrD[19:16] = 1, InstrD[3:0] = 4
        InstrD = 32'h00010004; 
        RegSrcD = 2'b00; // RA1 = Instr[19:16], RA2 = Instr[3:0]
        
        @(posedge clk);
        #10;
        if (RA1E === 4'h1 && RA2E === 4'h4)
            $display("[PASS] TEST 2: Register Address Decoding");
        else
            $display("[FAIL] TEST 2: Register Address Decoding. Expected RA1=1, RA2=4. Got RA1=%h, RA2=%h", RA1E, RA2E);

        // --- TEST 3: Writeback and Synchronous Read check ---
        @(posedge clk);
        RegWriteW = 1;
        WA3W = 4'd2;
        ResultW = 32'hAABBCCDD;
        // Set RA2D to 2 so we read what we are writing
        RegSrcD = 2'b00; 
        InstrD[3:0] = 4'd2; 

        @(posedge clk); // Write happens here
        @(posedge clk); // Read data moves to 'E' registers here
        #10;
        if (RD2E === 32'hAABBCCDD)
            $display("[PASS] TEST 3: Register File Write/Read");
        else
            $display("[FAIL] TEST 3: Register File Write/Read. Expected AABBCCDD, Got %h", RD2E);

        // --- TEST 4: Flush Logic ---
        @(posedge clk);
        FlushE = 1;
        @(posedge clk);
        #10;
        if (RD1E === 0 && RD2E === 0 && WA3E === 0)
            $display("[PASS] TEST 4: Flush Logic");
        else
            $display("[FAIL] TEST 4: Flush Logic. Pipeline registers not cleared. RD1E=%h, RD2E=%h", RD1E, RD2E);
        
        FlushE = 0;

        #200;
        $display("---------------------------------------");
        $display("[DONE] Simulation finished at %t", $time);
        $display("---------------------------------------");
        $finish;
    end

endmodule