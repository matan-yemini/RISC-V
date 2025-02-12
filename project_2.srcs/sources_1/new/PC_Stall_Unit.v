`timescale 1ns/1ps

module PC_Stall_Unit (
    input clk,
    input reset,
    input StallF,           // Stall signal for the Fetch stage
    input [31:0] next_pc,   // Next PC value (calculated externally)
    output reg [31:0] PCF   // Current PC value
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PCF <= 32'b0; // Reset PC to zero
        end else if (!StallF) begin
            PCF <= next_pc; // Update PC only if StallF is not asserted
        end
        // If StallF is asserted, PCF holds its current value
    end

endmodule
