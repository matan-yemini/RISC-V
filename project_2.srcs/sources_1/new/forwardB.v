`timescale 1ns/1ps

module forwardB(
    input  [31:0] RD2E,
    input  [31:0] ResultW,
    input  [31:0] ALUResultM,
    input  [1:0] ForwardB,
    output [31:0] ForwardedB
);

    assign ForwardedB = (ForwardB == 2'b10) ? ALUResultM : 
                        (ForwardB == 2'b01) ? ResultW : RD2E;

endmodule