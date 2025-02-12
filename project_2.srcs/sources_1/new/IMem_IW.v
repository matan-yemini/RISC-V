`timescale 1ns/1ps

module IMem_IW (
    input clk,               // Clock signal
    input reset,             // Reset signal
    input [31:0] ALUResultM, // ALU result from Memory stage
    input [31:0] ReadDataM,  // Data read from memory in Memory stage
    input [31:0] pc_plus4M,  // PC + 4 from Memory stage
    input [4:0] RdM,         // Destination register from Memory stage
    input RegWriteM,         // RegWrite signal from Memory stage
    input [1:0] ResultSrcM,  // Result source signal from Memory stage
    output reg [31:0] ALUResultW, // ALU result passed to Writeback stage
    output reg [31:0] ReadDataW,  // Data read from memory passed to Writeback stage
    output reg [31:0] pc_plus4W,  // PC + 4 passed to Writeback stage
    output reg [4:0] RdW,         // Destination register passed to Writeback stage
    output reg RegWriteW,         // RegWrite signal passed to Writeback stage
    output reg [1:0] ResultSrcW   // Result source signal passed to Writeback stage
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all outputs to zero
            ALUResultW <= 32'b0;
            ReadDataW <= 32'b0;
            pc_plus4W <= 32'b0;
            RdW <= 5'b0;
            RegWriteW <= 1'b0;
            ResultSrcW <= 2'b0;
        end else begin
            // Forward signals from Memory stage to Writeback stage
            ALUResultW <= ALUResultM;
            ReadDataW <= ReadDataM;
            pc_plus4W <= pc_plus4M;
            RdW <= RdM;
            RegWriteW <= RegWriteM;
            ResultSrcW <= ResultSrcM;
        end
    end

endmodule