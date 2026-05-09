module mux_2_to_1 (
    input [31:0]a,b,
    input s,
    output [31:0]c
);

    assign c = s ? b : a ;
    
endmodule

module mux_3_to_1 (
    input [31:0] a,b,c,
    input [1:0] s,
    output logic [31:0] d
);
    always_comb begin
        case(s)
            2'b00: d = a;
            2'b01: d = b;
            2'b10: d = c;
            default: d = a;
        endcase
    end
    
endmodule
