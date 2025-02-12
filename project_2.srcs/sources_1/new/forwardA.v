`timescale 1ns/1ps

module forwardA(
    input  [31:0] RD1E,        // ערך קריאה מהרגיסטר
    input  [31:0] ResultW,     // ערך תוצאה משלב Write Back
    input  [31:0] ALUResultM,  // ערך תוצאה משלב Memory
    input  [1:0] ForwardA,     // סיגנל Forward מה-Hazard Unit
    output [31:0] ForwardedA   // הפלט שנבחר
);

    assign ForwardedA = (ForwardA == 2'b10) ? ALUResultM : 
                        (ForwardA == 2'b01) ? ResultW : RD1E;

endmodule