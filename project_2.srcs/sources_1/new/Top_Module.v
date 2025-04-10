`timescale 1ns/1ps

module Top_Module (
    input clk, reset, clear,
    output ERROR, zero
);

    // FETCH STAGE SIGNALS
    wire [31:0] PCF;
    wire [31:0] next_pc;
    wire [31:0] pc_plus4F;
    wire [31:0] InstrF;

    // DECODE STAGE SIGNALS
    wire [31:0] PCD, pc_plus4D, InstrD;
    wire [31:0] RD1D, RD2D, ImmExtD;
    wire [4:0] Ra1D, Ra2D, RdD;
    wire error;
    wire [31:0] branch_jump_targetD;

    // EXECUTE STAGE SIGNALS
    wire [31:0] PCE, pc_plus4E, RD1E, RD2E, ImmExtE;
    wire [4:0] Rs1E, Rs2E, RdE;
    wire [1:0] ALUOpE;
    wire [31:0] ALUResultE;
    wire [3:0] ALUControlE;
    wire [2:0] funct3E;
    wire funct7b5E, opb5E;
    wire [31:0] branch_jump_targetE;
    wire branch_taken;
    wire [31:0] predicted_pc;
    wire ALUSrcAE, ALUSrcBE;
    wire [31:0] ALUInputA, ALUInputB;
    wire [31:0] ForwardedA, ForwardedB;
    wire RegWriteE;
    wire MemWriteE;
    wire BranchE;

    // MEMORY STAGE SIGNALS
    wire [31:0] ALUResultM, WriteDataM, ReadDataM, pc_plus4M;
    wire [4:0] RdM;
    wire MemWriteM;
    wire MemReadM;
    wire RegWriteM;

    // WRITEBACK STAGE SIGNALS
    wire [31:0] ALUResultW, ReadDataW, pc_plus4W, ResultW;
    wire [4:0] RdW;
    wire RegWriteW;

    // Hazard unit signals
    wire [4:0] Rs1D, Rs2D; 
    wire PredictionD;      
    wire PredictionE;      
    wire MemReadE;          

    // Outputs from Hazard_Unit
    wire [31:0] next_pc_hazard; 
    wire FlushD;          
    wire FlushE;          
    wire StallF;          
    wire StallD;          
    wire pc_signal;

    // CONTROL SIGNALS
    wire ALUSrcAD, ALUSrcBD;
    wire [1:0] ResultSrcD, ResultSrcE, ResultSrcM, ResultSrcW,  ALUOpD;
    wire MemWriteD, MemReadD, BranchD, JumpD;
    wire [2:0] ImmSrc;
    wire [1:0] ForwardA, ForwardB;
    wire PCSrc, JumpTaken;
    wire RegWriteD;

    // FETCH STAGE
    PC_Stall_Unit PC_Reg (
        .clk(clk), 
        .reset(reset),
        .StallF(StallF),
        .next_pc(next_pc),
        .PCF(PCF)
    );

    Instruction_Memory IMEM (
        .PCF(PCF),
        .InstrF(InstrF)
    );

    PC_plus4adder PCAdder (
        .PCF(PCF),
        .pc_plus4F(pc_plus4F)
    );

    next_pc_mux Next (
        .pc_plus4F(pc_plus4F),
        .next_pc_hazard(next_pc_hazard),
        .pc_signal(pc_signal),
        .next_pc(next_pc)
    );

    // IF/ID PIPELINE REGISTER
    IF_ID IF_ID_Reg (
        .clk(clk), 
        .reset(reset), 
        .clear(clear), 
        .StallF(StallF),
        .FlushD(FlushD), 
        .InstrF(InstrF), 
        .PCF(PCF), 
        .pc_plus4F(pc_plus4F),
        .InstrD(InstrD), 
        .PCD(PCD), 
        .pc_plus4D(pc_plus4D)
    );

    // DECODE STAGE
    reg_file RegisterFile (
    .clk(clk), 
    .RegWriteW(RegWriteW),
    .InstrD(InstrD),   // Pass the full instruction instead of individual registers
    .RdW(RdW),
    .ResultW(ResultW),
    .RD1D(RD1D), 
    .RD2D(RD2D), 
    .ERROR(ERROR)
);


    Immediate_propagation ImmGen (
        .InstrD(InstrD),
        .ImmExtD(ImmExtD),
        .ImmSrc(ImmSrc)
    );

    Main_Decoder ControlUnit (
        .op(InstrD[6:0]),
        .ResultSrc(ResultSrcD), 
        .MemWriteD(MemWriteD),
        .BranchD(BranchD), 
        .ALUSrcA(ALUSrcAD), 
        .ALUSrcB(ALUSrcBD),
        .RegWriteD(RegWriteD), 
        .JumpD(JumpD),
        .ImmSrc(ImmSrc), 
        .ALUOp(ALUOpD), 
        .MemReadD(MemReadD)
    );

    Adder Add (
        .ImmExtD(ImmExtD),
        .PCF(PCF),
        .branch_jump_targetD(branch_jump_targetD)
    );

    BPU bpu (
        .clk(clk), 
        .BranchE(BranchE),
        .BranchD(BranchD),
        .reset(reset), 
        .pc(PCD), 
        .branch_jump_targetD(branch_jump_targetD),
        .branch_taken(branch_taken), 
        .predicted_pc(predicted_pc), 
        .PredictionD(PredictionD)
    );

    // ID/EX PIPELINE REGISTER
    ID_EX ID_EX_Reg (
        .clk(clk), 
        .reset(reset), 
        .BranchD(BranchD),
        .BranchE(BranchE),
        .clear(clear), 
        .FlushE(FlushE), 
        .RD1D(RD1D), 
        .RD2D(RD2D), 
        .ImmExtD(ImmExtD),
        .PCD(PCD), 
        .pc_plus4D(pc_plus4D),
        .PredictionD(PredictionD), 
        .PredictionE(PredictionE), 
        .MemReadD(MemReadD), 
        .branch_jump_targetD(branch_jump_targetD), 
        .branch_jump_targetE(branch_jump_targetE),
        .InstrD(InstrD), 
        .PCE(PCE), 
        .MemReadE(MemReadE),
        .ALUSrcAD(ALUSrcAD), 
        .ALUSrcBD(ALUSrcBD), 
        .ResultSrcD(ResultSrcD),
        .RegWriteD(RegWriteD), 
        .MemWriteD(MemWriteD),
        .ALUOpD(ALUOpD),
        .RD1E(RD1E), 
        .RD2E(RD2E), 
        .ImmExtE(ImmExtE),
        .pc_plus4E(pc_plus4E),
        .Rs1E(Rs1E), 
        .Rs2E(Rs2E), 
        .RdE(RdE),
        .ALUSrcAE(ALUSrcAE), 
        .ALUSrcBE(ALUSrcBE), 
        .ResultSrcE(ResultSrcE),
        .RegWriteE(RegWriteE), 
        .MemWriteE(MemWriteE),
        .ALUOpE(ALUOpE),
        .opb5E(opb5E), 
        .funct3E(funct3E), 
        .funct7b5E(funct7b5E)
    );

    // EXECUTE STAGE
    ALU_Select alu_select (
        .PCE(PCE), 
        .Immediate(ImmExtE), 
        .ForwardedA(ForwardedA), 
        .ForwardedB(ForwardedB), 
        .ALUSrcAE(ALUSrcAE), 
        .ALUSrcBE(ALUSrcBE), 
        .ALUInputA(ALUInputA), 
        .ALUInputB(ALUInputB)
    );

    forwardA ForwardA_Mux (
        .RD1E(RD1E), 
        .ResultW(ResultW), 
        .ALUResultM(ALUResultM),
        .ForwardA(ForwardA), 
        .ForwardedA(ForwardedA)
    );

    forwardB ForwardB_Mux (
        .RD2E(RD2E), 
        .ResultW(ResultW), 
        .ALUResultM(ALUResultM),
        .ForwardB(ForwardB), 
        .ForwardedB(ForwardedB)
    );

    ALU_Decoder ALUDecoder (
        .opb5E(opb5E), 
        .funct3E(funct3E), 
        .funct7b5E(funct7b5E),
        .ALUOpE(ALUOpE), 
        .ALUControl(ALUControlE)
    );

    ALU ALU_Unit (
        .SrcA(ALUInputA), 
        .SrcB(ALUInputB), 
        .ALUControl(ALUControlE),
        .ALUResultE(ALUResultE), 
        .branch_taken(branch_taken), 
        .zero(zero)
    );

    // EX/MEM PIPELINE REGISTER
    IEx_IMem EX_MEM_Reg (
        .clk(clk), 
        .reset(reset),
        .ALUResultE(ALUResultE), 
        .RD2E(RD2E),
        .pc_plus4E(pc_plus4E), 
        .RdE(RdE),
        .MemReadE(MemReadE),
        .MemReadM(MemReadM),
        .RegWriteE(RegWriteE), 
        .MemWriteE(MemWriteE),
        .ResultSrcE(ResultSrcE),
        .ALUResultM(ALUResultM), 
        .WriteDataM(WriteDataM),
        .pc_plus4M(pc_plus4M), 
        .RdM(RdM),
        .RegWriteM(RegWriteM), 
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM)
    );

    Data_Memory Dmem (
        .clk(clk), 
        .we(MemWriteM), 
        .a(ALUResultM), 
        .wd(WriteDataM),
        .rd(ReadDataM)
    );

    IMem_IW MEM_WB_Reg (
        .clk(clk), 
        .reset(reset),
        .ALUResultM(ALUResultM), 
        .ReadDataM(ReadDataM),
        .pc_plus4M(pc_plus4M), 
        .RdM(RdM),
        .RegWriteM(RegWriteM), 
        .ResultSrcM(ResultSrcM),
        .ALUResultW(ALUResultW), 
        .ReadDataW(ReadDataW),
        .pc_plus4W(pc_plus4W), 
        .RdW(RdW),
        .RegWriteW(RegWriteW), 
        .ResultSrcW(ResultSrcW)
    );

    result_mux ResultMux (
        .ALUresultW(ALUResultW), 
        .ReadDataW(ReadDataW), 
        .pc_plus4W(pc_plus4W),
        .ResultSrcW(ResultSrcW), 
        .ResultW(ResultW)
    );

     // Hazard Unit
    Hazard_Unit hazard_unit (
        .RdE(RdE), 
        .RdM(RdM),
        .Rs1D(InstrD[19:15]), 
        .Rs2D(InstrD[24:20]),
        .JumpD(JumpD),
        .BranchTaken(branch_taken),
        .PredictionD(PredictionD), 
        .PredictionE(PredictionE),
        .MemReadE(MemReadE),
        .pc_plus4F(pc_plus4F), 
        .pc_plus4E(pc_plus4E),
        .branch_jump_targetE(branch_jump_targetE),
        .branch_jump_targetD(branch_jump_targetD),
        .predicted_pc(predicted_pc),
        .next_pc_hazard(next_pc_hazard),
        .ForwardA(ForwardA), 
        .ForwardB(ForwardB),
        .FlushD(FlushD), 
        .FlushE(FlushE),
        .StallF(StallF), 
        .StallD(StallD),
        .pc_signal(pc_signal)
    );

endmodule
