 `timescale 1ns/1ps
// Hazard Unit
module HazardUnit (
    input  logic rst,

    input  logic [3:0] RA1E, RA2E,
    input  logic [3:0] RA1D, RA2D,
    input  logic [3:0] WA3E, WA3M, WA3W,

    input  logic RegWriteE, RegWriteM, RegWriteW,
    input  logic MemtoRegE,

    input  logic PCSrcD, PCSrcE, PCSrcM, PCSrcW,
    input  logic BranchTakenE,

    output logic [1:0] ForwardAE, ForwardBE,
    output logic StallF, StallD,
    output logic FlushD, FlushE
);

logic Match_1E_M, Match_2E_M;
logic Match_1E_W, Match_2E_W;

logic LDRStall;
logic PCWrPendingF;

// Forwarding Comparators
assign Match_1E_M = (RA1E == WA3M) & RegWriteM;
assign Match_2E_M = (RA2E == WA3M) & RegWriteM;

assign Match_1E_W = (RA1E == WA3W) & RegWriteW;
assign Match_2E_W = (RA2E == WA3W) & RegWriteW;

// Forwarding MUX Control
always_comb begin

    // Src A
    if (Match_1E_M)
        ForwardAE = 2'b10;
    else if (Match_1E_W)
        ForwardAE = 2'b01;
    else
        ForwardAE = 2'b00;

    // Src B
    if (Match_2E_M)
        ForwardBE = 2'b10;
    else if (Match_2E_W)
        ForwardBE = 2'b01;
    else
        ForwardBE = 2'b00;

end

// Load-use hazard
assign LDRStall =
       ((RA1D == WA3E) | (RA2D == WA3E))
        & MemtoRegE
        & RegWriteE;

// Pending PC write
assign PCWrPendingF = PCSrcD | PCSrcE | PCSrcM;

// Stall Signals
assign StallF = LDRStall | PCWrPendingF;
assign StallD = LDRStall;

assign FlushD = rst ? 1'b0 : (PCWrPendingF | PCSrcW | BranchTakenE);
assign FlushE = rst ? 1'b0 : (LDRStall | BranchTakenE);

endmodule