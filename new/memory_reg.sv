`timescale 1ns/1ps
module memory_reg (
    input logic clk,
    input logic reset,
    input logic [31:0] ReadDataM,
    input logic [31:0] ALUOutM,
    input logic [3:0] WA3M,
    input logic [31:0] BranchTargetM,
    output logic [31:0] ReadDataW,
    output logic [31:0] ALUOutW,
    output logic [31:0] BranchTargetW,
    output logic [3:0] WA3W
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ReadDataW <= 0; 
            ALUOutW <= 0;
            WA3W <= 0;
            BranchTargetW <= 0;
        end
        else begin
            ReadDataW <= ReadDataM; 
            ALUOutW <= ALUOutM;
            WA3W <= WA3M;
            BranchTargetW <= BranchTargetM;
        end
    end 
endmodule

