`timescale 1ns/1ps

module ID_EX (
    input clk,
    input reset,
    input clear,
    input FlushE,
    input [31:0] RD1D, RD2D, PCD,
    input [31:0] ImmExtD, pc_plus4D,
    input PredictionD,
    input MemReadD, MemWriteD, ALUSrcAD, ALUSrcBD,
    input [1:0] ResultSrcD, ALUOpD,
    input [31:0] branch_jump_targetD,
    input RegWriteD,
    input [31:0] InstrD,
    input BranchD,
    output reg [31:0] RD1E, RD2E, PCE,
    output reg [4:0] Rs1E, Rs2E, RdE,
    output reg [31:0] ImmExtE, pc_plus4E,
    output reg PredictionE,
    output reg MemReadE, MemWriteE, ALUSrcAE, ALUSrcBE,
    output reg [1:0] ResultSrcE, ALUOpE,
    output reg [31:0] branch_jump_targetE,
    output reg RegWriteE,
    output reg [2:0] funct3E,
    output reg funct7b5E,
    output reg opb5E,
    output reg BranchE
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            RD1E <= 0;
            RD2E <= 0;
            PCE <= 0;
            Rs1E <= 0;
            Rs2E <= 0;
            RdE <= 0;
            ImmExtE <= 0;
            pc_plus4E <= 0;
            PredictionE <= 0;
            MemReadE <= 0;
            MemWriteE <= 0;
            ALUSrcAE <= 0;
            ALUSrcBE <= 0;
            ResultSrcE <= 0;
            ALUOpE <= 0;
            branch_jump_targetE <= 0;
            RegWriteE <= 0;
            funct3E <= 0;
            funct7b5E <= 0;
            opb5E <= 0;
            BranchE <= 0;
        end else if (clear || FlushE) begin
            RD1E <= 0;
            RD2E <= 0;
            PCE <= 0;
            Rs1E <= 0;
            Rs2E <= 0;
            RdE <= 0;
            ImmExtE <= 0;
            pc_plus4E <= 0;
            PredictionE <= 0;
            MemReadE <= 0;
            MemWriteE <= 0;
            ALUSrcAE <= 0;
            ALUSrcBE <= 0;
            ResultSrcE <= 0;
            ALUOpE <= 0;
            branch_jump_targetE <= 0;
            RegWriteE <= 0;
            funct3E <= 0;
            funct7b5E <= 0;
            opb5E <= 0;
            BranchE <= 0;
        end else begin
            RD1E <= RD1D;
            RD2E <= RD2D;
            PCE <= PCD;
            Rs1E <= InstrD[19:15];
            Rs2E <= InstrD[24:20];
            RdE <= InstrD[11:7];
            ImmExtE <= ImmExtD;
            pc_plus4E <= pc_plus4D;
            PredictionE <= PredictionD;
            MemReadE <= MemReadD;
            MemWriteE <= MemWriteD;
            ALUSrcAE <= ALUSrcAD;
            ALUSrcBE <= ALUSrcBD;
            ResultSrcE <= ResultSrcD;
            ALUOpE <= ALUOpD;
            branch_jump_targetE <= branch_jump_targetD;
            RegWriteE <= RegWriteD;
            funct3E <= InstrD[14:12];
            funct7b5E <= InstrD[30];
            opb5E <= InstrD[5];
            BranchE <= BranchD;
        end
    end

endmodule
