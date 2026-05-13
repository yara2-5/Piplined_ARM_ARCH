`timescale 1ns/1ps
module writeback_cycle (
    input logic MemtoRegW,
    input logic [31:0] ReadDataW, ALUOutW,
    output logic [31:0] ResultW
    );

    // Declaration of Module
    mux_2_to_1 #(32) result_mux (    
                .a(ALUOutW),
                .b(ReadDataW),
                .s(MemtoRegW),
                .c(ResultW)
                );
endmodule

`timescale 1ns/1ps
module writeback_tb();

    // ---------------- SIGNALS ----------------
    logic        MemtoRegW;
    logic [31:0] ReadDataW;
    logic [31:0] ALUOutW;
    logic [31:0] ResultW;

    // ---------------- DUT INSTANTIATION ----------------
    writeback_cycle dut (
        .MemtoRegW(MemtoRegW),
        .ReadDataW(ReadDataW),
        .ALUOutW(ALUOutW),
        .ResultW(ResultW)
    );

    // ---------------- STIMULUS ----------------
    initial begin
        $dumpfile("writeback_cycle.vcd");
        $dumpvars(0, writeback_tb);

        // Initialize values
        MemtoRegW = 0;
        ReadDataW = 32'hAAAA_AAAA;
        ALUOutW   = 32'hBBBB_BBBB;

        #10; // Small delay for combinational logic to settle

        // --- TEST 1: Select ALU Result (MemtoRegW = 0) ---
        MemtoRegW = 1'b0;
        #10;
        if (ResultW === 32'hBBBB_BBBB)
            $display("[PASS] TEST 1: ALUOutW Selected (MemtoRegW=0)");
        else
            $display("[FAIL] TEST 1: Expected BBBB_BBBB, Got %h", ResultW);

        // --- TEST 2: Select Memory Data (MemtoRegW = 1) ---
        MemtoRegW = 1'b1;
        #10;
        if (ResultW === 32'hAAAA_AAAA)
            $display("[PASS] TEST 2: ReadDataW Selected (MemtoRegW=1)");
        else
            $display("[FAIL] TEST 2: Expected AAAA_AAAA, Got %h", ResultW);

        // --- TEST 3: Data Change Sensitivity ---
        // Change the input while the mux is already pointing to it
        ALUOutW = 32'h1234_5678;
        MemtoRegW = 1'b0;
        #10;
        if (ResultW === 32'h1234_5678)
            $display("[PASS] TEST 3: Result updated with ALUOutW change");
        else
            $display("[FAIL] TEST 3: Result failed to update. Got %h", ResultW);

        $display("---------------------------------------");
        $display("[DONE] Writeback simulation finished");
        $display("---------------------------------------");
        $finish;
    end

endmodule