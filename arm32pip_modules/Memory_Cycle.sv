`timescale 1ns/1ps
module memory_cycle (
    input logic clk, rst, MemWriteM,
    input logic [3:0] WA3M, 
    input logic [31:0] ALUOutM, WriteDataM, BranchTargetM,
    output logic [3:0] WA3W,
    output logic [31:0] ALUOutW, ReadDataW, BranchTargetW
    );

    logic [31:0] ReadDataM;

    Data_Memory dmem (.clk(clk), 
                .we(MemWriteM),
                .a(ALUOutM), 
                .wd(WriteDataM),
                .rd(ReadDataM)
                );

    memory_reg mreg (.clk(clk),
                .reset(rst),
                .ReadDataM(ReadDataM),
                .ALUOutM(ALUOutM),
                .WA3M(WA3M),
                .BranchTargetM(BranchTargetM),
                .ReadDataW(ReadDataW), 
                .ALUOutW(ALUOutW),
                .BranchTargetW(BranchTargetW),
                .WA3W(WA3W)
            );
    
endmodule
