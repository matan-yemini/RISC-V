`timescale 1ns/1ps

module IMem_IW (
    input clk,
    input reset,
    input [31:0] ALUResultM,
    input [31:0] ReadDataM,
    input [31:0] pc_plus4M,
    input [4:0] RdM,
    input RegWriteM,
    input [1:0] ResultSrcM,
    output reg [31:0] ALUResultW,
    output reg [31:0] ReadDataW,
    output reg [31:0] pc_plus4W,
    output reg [4:0] RdW,
    output reg RegWriteW,
    output reg [1:0] ResultSrcW
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ALUResultW <= 32'b0;
            ReadDataW <= 32'b0;
            pc_plus4W <= 32'b0;
            RdW <= 5'b0;
            RegWriteW <= 1'b0;
            ResultSrcW <= 2'b0;
        end else begin
            ALUResultW <= ALUResultM;
            ReadDataW <= ReadDataM;
            pc_plus4W <= pc_plus4M;
            RdW <= RdM;
            RegWriteW <= RegWriteM;
            ResultSrcW <= ResultSrcM;
        end
    end

endmodule