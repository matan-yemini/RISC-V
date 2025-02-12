`timescale 1ns/1ps

module forwardB(
    input  [31:0] RD2E,        // ערך קריאה מהרגיסטר
    input  [31:0] ResultW,     // ערך תוצאה משלב Write Back
    input  [31:0] ALUResultM,  // ערך תוצאה משלב Memory
    input  [1:0] ForwardB,     // סיגנל Forward מה-Hazard Unit
    output [31:0] ForwardedB   // הפלט שנבחר
);

    assign ForwardedB = (ForwardB == 2'b10) ? ALUResultM : 
                        (ForwardB == 2'b01) ? ResultW : RD2E;

endmodule