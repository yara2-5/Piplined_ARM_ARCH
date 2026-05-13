`timescale 1ns/1ps
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
