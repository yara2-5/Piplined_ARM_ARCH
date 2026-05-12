 module Sign_Extend (
    input  logic [23:0] Instr,
    input  logic [1:0]  ImmSrc,
    output logic [31:0] Imm_Ext
);

always_comb begin
    case(ImmSrc)
        2'b00: Imm_Ext = {24'b0, Instr[7:0]};
        2'b01: Imm_Ext = {20'b0, Instr[11:0]};
        2'b10: Imm_Ext = {{6{Instr[23]}}, Instr[23:0], 2'b00};
        default: Imm_Ext = {24'b0, Instr[7:0]};
    endcase
end

endmodule