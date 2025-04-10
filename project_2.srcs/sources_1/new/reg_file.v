`timescale 1ns/1ps
module reg_file (
    input clk,
    input RegWriteW,
    input [31:0] InstrD,
    input [4:0] RdW,
    input [31:0] ResultW,
    output [31:0] RD1D, RD2D,
    output ERROR
);
    reg [31:0] rf[31:0];
    integer i;
    
    // Extract register addresses from instruction
    wire [4:0] Ra1D = InstrD[19:15]; // rs1
    wire [4:0] Ra2D = InstrD[24:20]; // rs2
    
    // Initialize register file
    initial begin
        for (i = 0; i < 32; i = i + 1)
            rf[i] = 32'b0;
    end
    
    // Read ports
    assign RD1D = (Ra1D != 0) ? rf[Ra1D] : 0;
    assign RD2D = (Ra2D != 0) ? rf[Ra2D] : 0;
    
    // Write port
    always @(posedge clk) begin
        if (RegWriteW) 
            rf[RdW] <= (RdW != 0) ? ResultW : 0;
    end
    
    assign ERROR = 1'b0; // You can implement error checking logic here
endmodule