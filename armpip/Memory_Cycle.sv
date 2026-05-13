module memory_cycle (
    input logic clk, rst, MemWriteM,
    input logic [31:0] ALUOutM, WriteDataM, WA3M,
    output logic [31:0]  WA3W, WriteDataW, ALUOutW, ReadDataW
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
                .ReadDataW(ReadDataW),
                .ALUOutW(ALUOutW),
                .WA3W(WA3W)
            );
    

endmodule
