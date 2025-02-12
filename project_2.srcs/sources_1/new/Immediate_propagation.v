`timescale 1ns/1ps

module Immediate_propagation (
    input wire [31:0] InstrD, // 32-bit InstrD
    input wire [2:0] ImmSrc,     // ImmExtD type selector (I, S, B, U, J)
    output reg [31:0] ImmExtD    // Propagated ImmExtD value
);

    always @(*) begin
        case (ImmSrc)
            3'b000: // I-type (includes arithmetic/logical and shift operations)
                if (InstrD[14:12] == 3'b001 || InstrD[14:12] == 3'b101) begin
                    // Shift operations: slli, srli, srai
                    ImmExtD = {27'b0, InstrD[24:20]}; // Extract shift amount
                end else begin
                    // Arithmetic/logical InstrDs like addi, andi, ori
                    ImmExtD = {{20{InstrD[31]}}, InstrD[31:20]}; // Sign-extended ImmExtD
                end
            3'b001: // S-type (store InstrDs)
                ImmExtD = {{20{InstrD[31]}}, InstrD[31:25], InstrD[11:7]};
            3'b010: // B-type (branch InstrDs)
                ImmExtD = {{19{InstrD[31]}}, InstrD[31], InstrD[7], InstrD[30:25], InstrD[11:8], 1'b0};
            3'b011: // U-type (upper ImmExtD)
                ImmExtD = {InstrD[31:12], 12'b0};
            3'b100: // J-type (jump InstrDs)
                ImmExtD = {{11{InstrD[31]}}, InstrD[31], InstrD[19:12], InstrD[20], InstrD[30:21], 1'b0};
            default: // Default case: zero out ImmExtD if type is invalid
                ImmExtD = 32'b0;
        endcase
    end

endmodule
