`timescale 1ns/1ps

module ALU_Select (
    input  [31:0] PCE,        // Program Counter (Used for ALU A)
    input  [31:0] ForwardedA, // Forwarded data for ALU A
    input  [31:0] Immediate,  // Immediate value (Used for ALU B)
    input  [31:0] ForwardedB, // Forwarded data for ALU B
    input  ALUSrcAE,  // Select signal for ALU A
    input  ALUSrcBE,  // Select signal for ALU B
    output [31:0] ALUInputA, // Output to ALU (A)
    output [31:0] ALUInputB  // Output to ALU (B)
);

    assign ALUInputA = ALUSrcAE ? PCE : ForwardedA;
    assign ALUInputB = ALUSrcBE ? Immediate : ForwardedB;

endmodule
