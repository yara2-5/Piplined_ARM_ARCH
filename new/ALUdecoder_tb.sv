 `timescale 1ns/1ps

module ALUdecoder_tb();

    // Inputs
    logic       ALUOp;
    logic [5:0] Funct;

    // Outputs
    logic [2:0] ALUControl;
    logic [1:0] FlagW;

    // DUT
    ALUdecoder dut (
        .ALUOp(ALUOp),
        .Funct(Funct),
        .ALUControl(ALUControl),
        .FlagW(FlagW)
    );

    initial begin

        // =====================================
        // Test 1 : ALUOp = 0
        // =====================================
        ALUOp = 0;
        Funct = 6'b000000;
        #10;

        if (ALUControl == 3'b000 && FlagW == 2'b00)
            $display("TEST1 PASS");
        else
            $display("TEST1 FAIL");


        // =====================================
        // Test 2 : ADD
        // Funct[4:1] = 0100
        // =====================================
        ALUOp = 1;
        Funct = 6'b001001;
        #10;

        if (ALUControl == 3'b000)
            $display("ADD PASS");
        else
            $display("ADD FAIL");


        // =====================================
        // Test 3 : SUB
        // =====================================
        Funct = 6'b000101;
        #10;

        if (ALUControl == 3'b001)
            $display("SUB PASS");
        else
            $display("SUB FAIL");


        // =====================================
        // Test 4 : AND
        // =====================================
        Funct = 6'b000001;
        #10;

        if (ALUControl == 3'b010)
            $display("AND PASS");
        else
            $display("AND FAIL");


        // =====================================
        // Test 5 : ORR
        // =====================================
        Funct = 6'b011001;
        #10;

        if (ALUControl == 3'b011)
            $display("ORR PASS");
        else
            $display("ORR FAIL");


        // =====================================
        // Test 6 : BIC
        // =====================================
        Funct = 6'b011101;
        #10;

        if (ALUControl == 3'b100)
            $display("BIC PASS");
        else
            $display("BIC FAIL");


        // =====================================
        // Test 7 : EOR
        // =====================================
        Funct = 6'b000011;
        #10;

        if (ALUControl == 3'b101)
            $display("EOR PASS");
        else
            $display("EOR FAIL");


        // =====================================
        // Test 8 : MOV
        // =====================================
        Funct = 6'b011011;
        #10;

        if (ALUControl == 3'b110)
            $display("MOV PASS");
        else
            $display("MOV FAIL");


        // =====================================
        // Test 9 : MVN
        // =====================================
        Funct = 6'b011111;
        #10;

        if (ALUControl == 3'b111)
            $display("MVN PASS");
        else
            $display("MVN FAIL");


        // =====================================
        // Test 10 : CMP
        // =====================================
        Funct = 6'b010101;
        #10;

        if (ALUControl == 3'b001)
            $display("CMP PASS");
        else
            $display("CMP FAIL");


        

    end

endmodule