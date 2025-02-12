`timescale 1ns/1ps

module PC_plus4adder (
    input [31:0] PCF,   // Current PC value
    output [31:0] pc_plus4F  // Next PC value (PC + 4)
);

    // Add 4 to the current PC value
    assign pc_plus4F = PCF + 4;

endmodule
