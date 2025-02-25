`timescale 1ns/1ps

module IEx_IMem (
    input clk, reset,
    input [31:0] ALUResultE, RD2E,
    input [4:0] RdE,
    input [31:0] pc_plus4E,
    input [1:0] ResultSrcE,
    input MemReadE, MemWriteE,
    input RegWriteE,
    output reg [31:0] ALUResultM, WriteDataM,
    output reg [4:0] RdM,
    output reg [31:0] pc_plus4M,
    output reg [1:0] ResultSrcM,
    output reg MemReadM, MemWriteM,
    output reg RegWriteM
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ALUResultM <= 32'b0;
            WriteDataM <= 32'b0;
            RdM <= 5'b0;
            pc_plus4M <= 32'b0;
            ResultSrcM <= 2'b0;
            MemReadM <= 1'b0;
            MemWriteM <= 1'b0;
            RegWriteM <= 1'b0;
        end else begin
            ALUResultM <= ALUResultE;
            WriteDataM <= RD2E;
            RdM <= RdE;
            pc_plus4M <= pc_plus4E;
            ResultSrcM <= ResultSrcE;
            MemReadM <= MemReadE;
            MemWriteM <= MemWriteE;
            RegWriteM <= RegWriteE;
        end
    end

endmodule