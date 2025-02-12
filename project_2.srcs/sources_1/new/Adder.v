`timescale 1ns/1ps

module Adder (
    input [31:0] PCF,              // כתובת ה-PC הנוכחית
    input [31:0] ImmExtD,             // ImmExtDediate value (Offset)
    output [31:0] branch_jump_targetD   // כתובת יעד הקפיצה
);

    // Adder ל-PC + ImmExtD
    assign branch_jump_targetD = PCF + ImmExtD;

endmodule
