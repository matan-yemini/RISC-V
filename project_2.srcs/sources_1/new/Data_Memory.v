`timescale 1ns/1ps
module Data_Memory (
    input clk,             // Clock signal
    input we,              // Write Enable signal
    input [31:0] a,        // Address input
    input [31:0] wd,       // Write data input
    output [31:0] rd       // Read data output
);
    reg [31:0] RAM [63:0]; // 64 x 32-bit memory
    integer i;             // Declare integer i at module level
    
    // Use only relevant address bits for indexing
    assign rd = RAM[a[7:2]]; // Word-aligned addressing (bits 7:2 for 64 entries)
    
    // Initialize memory to known values
    initial begin
        for (i = 0; i < 64; i = i + 1) begin
            RAM[i] = 32'h0; // Initialize all memory to zero
        end
    end
    
    always @(posedge clk) begin
        if (we) 
            RAM[a[7:2]] <= wd;
    end
endmodule