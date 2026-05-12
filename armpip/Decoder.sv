 module MainDecoder(
    input  logic [1:0] op,
    input  logic [5:0] Funct,

    output logic       Branch,
    output logic       ALUOp,
    output logic       RegW,
    output logic       MemW,
    output logic       MemtoReg,
    output logic       ALUSrc,

    output logic [1:0] ImmSrc,
    output logic [1:0] RegSrc
);

always_comb begin

    // default values
    Branch   = 0;
    ALUOp    = 0;
    RegW     = 0;
    MemW     = 0;
    MemtoReg = 0;
    ALUSrc   = 0;
    ImmSrc   = 2'b00;
    RegSrc   = 2'b00;

    case (op)

        // =========================
        // Data Processing
        // =========================
        2'b00: begin

            Branch   = 0;
            MemtoReg = 0;
            MemW     = 0;
            RegW     = 1;
            ALUOp    = 1;

            // DP immediate
            if (Funct[5]) begin
                ALUSrc = 1;
                ImmSrc = 2'b00;
                RegSrc = 2'b00;
            end

            // DP register
            else begin
                ALUSrc = 0;
                ImmSrc = 2'b00; 
                RegSrc = 2'b00;
            end
        end

        // =========================
        // Memory Instructions
        // =========================
        2'b01: begin

            ALUSrc = 1;
            ImmSrc = 2'b01;
            ALUOp  = 0;

            // STR
            if (Funct[0] == 0) begin
                Branch   = 0;
                MemtoReg = 0;
                MemW     = 1;
                RegW     = 0;
                RegSrc   = 2'b10;
            end

            // LDR
            else begin
                Branch   = 0;
                MemtoReg = 1;
                MemW     = 0;
                RegW     = 1;
                RegSrc   = 2'b00;
            end
        end

        // =========================
        // Branch
        // =========================
        2'b10: begin

            Branch   = 1;
            MemtoReg = 0;
            MemW     = 0;
            ALUSrc   = 1;
            ImmSrc   = 2'b10;
            RegW     = 0;
            RegSrc   = 2'b01;
            ALUOp    = 0;
        end

    endcase
end

endmodule



module PCLogic (
    input  logic [3:0] Rd,
    input  logic       Branch,
    input  logic       RegW,

    output logic       PCS
);

assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

endmodule



module ALUdecoder(
    input  logic       ALUOp,
    input  logic [5:0] Funct,

    output logic [2:0] ALUControl,
    output logic [1:0] FlagW
);

always_comb begin

    if (ALUOp) begin

        case(Funct[4:1])

            4'b0100: ALUControl = 3'b000; // ADD
            4'b0010: ALUControl = 3'b001; // SUB
            4'b0000: ALUControl = 3'b010; // AND
            4'b1100: ALUControl = 3'b011; // ORR
            4'b1110: ALUControl = 3'b100;
            4'b0001: ALUControl = 3'b101;
            4'b1101: ALUControl = 3'b110;
            4'b1111: ALUControl = 3'b110;
            4'b1010: ALUControl = 3'b001; // CMP

            default: ALUControl = 3'b000;

        endcase

        FlagW[1] = Funct[0];

        FlagW[0] = Funct[0] &
                   ((ALUControl == 3'b000) |
                    (ALUControl == 3'b001));

    end

    else begin
        ALUControl = 3'b000;
        FlagW      = 2'b00;
    end

end

endmodule