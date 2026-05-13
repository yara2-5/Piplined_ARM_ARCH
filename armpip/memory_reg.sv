module memory_reg (
    input logic clk,
    input logic reset,
    input logic [31:0] ReadDataM,
    input logic [31:0] ALUOutM,
    input logic [31:0] WA3M,
    output logic [31:0] ReadDataW,
    output logic [31:0] ALUOutW,
    output logic [31:0] WA3W
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ReadDataW <= 0; 
            ALUOutW <= 0;
            WA3W <= 0;
        end
        else begin
            ReadDataW <= ReadDataM; 
            ALUOutW <= ALUOutM;
            WA3W <= WA3M;
        end
    end 
endmodule

