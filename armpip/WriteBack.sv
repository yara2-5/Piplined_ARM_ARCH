module writeback_cycle (
    input clk, rst, MemtoRegW,
    input [31:0] ReadDataM, ALUOutM, WriteDataM,
    output [31:0] ResultW
    );

// Declaring internal signals
logic [31:0] ReadDataW, ALUOutW, WriteDataW;

write_back_reg (.clk(clk),
                .reset(rst),
                .ReadDataM(ReadDataM),
                .ALUOutM(ALUOutM),
                .WriteDataM(WriteDataM),
                .ReadDataW(ReadDataW),
                .ALUOutW(ALUOutW),
                .WriteDataW(WriteDataW)
            );
// Declaration of Module
mux_2_to_1 #(32) result_mux (    
                .a(ALUOutW),
                .b(ReadDataW),
                .s(MemtoRegW),
                .c(ResultW)
                );
endmodule
