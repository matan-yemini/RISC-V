`timescale 1ns/1ps

module Data_Memory (
    input clk,             // Clock signal
    input we,              // Write Enable signal
    input [31:0] a,        // Address input
    input [31:0] wd,       // Write data input
    output [31:0] rd       // Read data output
);

    reg [31:0] RAM [63:0]; // 64 x 32-bit memory

    // Read operation (asynchronous)
    assign rd = RAM[a[31:0]]; // Address divided by 4 (word-aligned)

    // Write operation (synchronous)
    always @(posedge clk) begin
        if (we) 
            RAM[a[31:0]] <= wd; // Write data to memory if write enable is active
    end

endmodule