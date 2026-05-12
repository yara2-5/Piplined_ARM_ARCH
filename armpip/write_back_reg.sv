module write_back_reg (
    input logic clk,
    input logic reset,
    input logic [31:0] ReadDataM,
    input logic [31:0] ALUOutM,
    input logic [31:0] WriteDataM,
    output logic [31:0] ReadDataW,
    output logic [31:0] ALUOutW,
    output logic [31:0] WriteDataW
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ReadDataW <= 0; 
            ALUOutW <= 0;
            WriteDataW <= 0;
        end
        else begin
            ReadDataW <= ReadDataM; 
            ALUOutW <= ALUOutM;
            WriteDataW <= WriteDataM;
        end
    end 
endmodule

