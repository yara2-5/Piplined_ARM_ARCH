 module Register_File(
    input logic clk,
    input logic rst,
    input logic WE3,

    input logic [3:0]  A1, A2, A3,
    input logic [31:0] WD3,
    input logic [31:0] R15,

    output logic [31:0] RD1, RD2
);

    reg [31:0] Register [14:0];
    integer i;

    always @(posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            for (i = 0; i < 15; i = i + 1)
                Register[i] <= 32'b0;
        end
        else
        begin
            if (WE3)
                Register[A3] <= WD3;
        end
    end

    assign RD1 = (A1 == 4'hF) ? R15 : Register[A1];
    assign RD2 = (A2 == 4'hF) ? R15 : Register[A2];

endmodule