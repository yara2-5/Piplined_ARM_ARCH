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

