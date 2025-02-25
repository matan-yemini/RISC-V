`timescale 1ns/1ps

module Adder (
    input [31:0] PCF,              
    input [31:0] ImmExtD,          
    output [31:0] branch_jump_targetD  
);

    assign branch_jump_targetD = PCF + ImmExtD;

endmodule