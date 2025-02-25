`timescale 1ns/1ps

module forwardA(
    input  [31:0] RD1E,
    input  [31:0] ResultW,
    input  [31:0] ALUResultM,
    input  [1:0] ForwardA,
    output [31:0] ForwardedA
);

    assign ForwardedA = (ForwardA == 2'b10) ? ALUResultM : 
                        (ForwardA == 2'b01) ? ResultW : RD1E;

endmodule