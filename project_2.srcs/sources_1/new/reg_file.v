`timescale 1ns/1ps
module reg_file ( 
    input clk,
    input RegWriteW,
    input [31:0] InstrD,
    input [31:0] ResultW,
    input [4:0] RdW,        // Add this input for writeback stage register
    output reg [31:0] RD1D, RD2D,
    output reg ERROR
);
    // Extract register addresses from InstrD
    wire [4:0] Ra1D, Ra2D;
    assign Ra1D = InstrD[19:15];
    assign Ra2D = InstrD[24:20];
    
    // Register file
    reg [31:0] rf [0:31];
    
    // Initialize register file and ERROR signal
    integer i;
    initial begin
        ERROR = 1'b0;
        for (i = 0; i < 32; i = i + 1)
            rf[i] = 32'b0;
    end
    
    // Read operations
    always @(*) begin
        RD1D = rf[Ra1D];
        RD2D = rf[Ra2D];
    end
    
    // Write operation
    always @(negedge clk) begin
        if (RegWriteW && RdW != 5'b0) begin
            rf[RdW] <= ResultW;
        end
    end
    
    // ERROR detection
    always @(negedge clk) begin
        ERROR <= (RegWriteW && (RdW == 5'b0));
    end
endmodule