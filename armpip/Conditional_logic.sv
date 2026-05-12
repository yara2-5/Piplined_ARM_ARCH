module Condition_logic (
    input logic clk, rst,
    input logic PCS, 
    input logic RegW,
    input logic MemW,
    input logic BranchE,
    input logic [1:0] FlagW,
    input logic [3:0] Cond,
    input logic [3:0] ALUFlags,
    output logic PCSrc,
    output logic RegWrite,
    output logic BranchTakenE,
    output logic MemWrite
);
    //internal signals
    logic [1:0] FlagWrite;
    logic [3:0] Flags;
    logic CondEx;

    //Registers
    enable_ff #(2) first_reg (.clk(clk),
                      .reset(rst),
                      .en(FlagWrite[1]),
                      .d(ALUFlags[3:2]),
                      .q(Flags[3:2])
                       );
    
    enable_ff #(2) sec_reg (.clk(clk),
                      .reset(rst),
                      .en(FlagWrite[1]),
                      .d(ALUFlags[3:2]),
                      .q(Flags[3:2])
                       );


    //Condition Check
    Condition_Check condition (.Cond(Cond),
                            .Flags(Flags),
                            .CondEx(CondEx)
                            );

    //Anding
    assign PCSrc    = PCS & CondEx;
    assign RegWrite = RegW & CondEx;
    assign MemWrite = MemW & CondEx;
    assign BranchTakenE = BranchE & CondEx;

    // Bitwise ANDing
    assign FlagWrite = {2{CondEx}} & FlagW;

endmodule
