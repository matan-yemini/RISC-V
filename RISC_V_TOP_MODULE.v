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
    wire [4:0] Ra1D, Ra2D;
    wire error;

    // EXECUTE STAGE SIGNALS
    wire [31:0] PCE, pc_plus4E, RD1E, RD2E, ImmExtE;
    wire [4:0] Rs1E, Rs2E, RdE;
    wire [1:0] ALUOpE;
    wire [31:0] ALUResultE;
    wire [3:0] ALUControlE;
    wire [2:0] funct3E;
    wire funct7b5E, opb5E;
    wire [31:0] branch_jump_target;
    wire branch_taken;
    wire ALUSrcAE, ALUSrcBE;
    wire [31:0] ALUInputA, ALUInputB;
    wire [31:0] ForwardedA, ForwardedB;
    wire RegWriteE;
    wire MemWriteE;
    wire BranchE, JumpE;

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
    wire MemReadE;          

    // Outputs from Hazard_Unit
    wire [31:0] next_pc_hazard; 
    wire FlushD;          
    wire FlushE;          
    wire StallF;          
    wire StallD;          
    wire pc_select;

    // CONTROL SIGNALS
    wire ALUSrcAD, ALUSrcBD;
    wire [1:0] ResultSrcD, ResultSrcE, ResultSrcM, ResultSrcW, ALUOpD;
    wire MemWriteD, MemReadD, BranchD, JumpD;
    wire [2:0] ImmSrc;
    wire [1:0] ForwardA, ForwardB;
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
        .branch_jump_target(branch_jump_target),
        .pc_select(pc_select),
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

reg_file RegisterFile (
    .clk(clk), 
    .RegWriteW(RegWriteW),
    .Rs1D(InstrD[19:15]),  // Extract Rs1 address directly from instruction
    .Rs2D(InstrD[24:20]),  // Extract Rs2 address directly from instruction
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
        .funct3(InstrD[14:12]),
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
        .MemReadD(MemReadD), 
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
        .funct7b5E(funct7b5E),
        .JumpD(JumpD),
        .JumpE(JumpE)
    );

    // EXECUTE STAGE
    // Branch target calculator in execute stage
    Branch_Jump_Adder branch_calc (
        .PCE(PCE),
        .ImmExtE(ImmExtE),
        .branch_jump_target(branch_jump_target)
    );

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
        .ALUResultW(ALUResultW), 
        .ReadDataW(ReadDataW),
        .pc_plus4W(pc_plus4W),
        .ResultSrcW(ResultSrcW),
        .ALUResultM(ALUResultM),
        .ReadDataM(ReadDataM),
        .pc_plus4M(pc_plus4M),
        .ResultSrcM(ResultSrcM),
        .ForwardA(ForwardA), 
        .ForwardedA(ForwardedA)
    );

    forwardB ForwardB_Mux (
        .RD2E(RD2E), 
        .ALUResultW(ALUResultW), 
        .ReadDataW(ReadDataW),
        .pc_plus4W(pc_plus4W),
        .ResultSrcW(ResultSrcW),
        .ALUResultM(ALUResultM),
        .ReadDataM(ReadDataM),
        .pc_plus4M(pc_plus4M),
        .ResultSrcM(ResultSrcM),
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
        .ForwardedB(ForwardedB),
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
        .ReadDataM(ReadDataM)
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

    Hazard_Unit hazard_unit (
        .RdE(RdE), 
        .Rs2E(Rs2E),
        .Rs1E(Rs1E),
        .RdM(RdM),
        .RdW(RdW),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .Rs1D(InstrD[19:15]), 
        .Rs2D(InstrD[24:20]),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .branch_taken(branch_taken),
        .MemReadE(MemReadE),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB),
        .FlushD(FlushD), 
        .FlushE(FlushE),
        .StallF(StallF), 
        .StallD(StallD),
        .pc_select(pc_select)
    );

endmodule


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

`timescale 1ns/1ps
module PC_plus4adder (
    input [31:0] PCF,          // Current PC value
    output [31:0] pc_plus4F    // Next PC value (PC + 4)
);
    // Add 4 to the current PC value (normal sequential execution)
    assign pc_plus4F = PCF + 4;
endmodule

module Instruction_Memory(
    input [31:0] PCF, 
    output [31:0] InstrF
);
    reg [31:0] RAM [0:63]; // 64 instructions (word-addressable)
    integer i;
    integer file;
    reg [31:0] instruction;
    
    // Initialize memory by loading from file
    initial begin
        // Initialize all memory locations to NOP first
        for (i = 0; i < 64; i = i + 1) begin
            RAM[i] = 32'h0;
        end
        
        // Open the hex file for reading
        file = $fopen("C:/Users/User/Desktop/Vivado/Python_generator/instructions.hex", "r");
        
        // Check if file was opened successfully
        if (file == 0) begin
            $display("Error: Failed to open instructions.hex file");
            $finish;
        end
        
        // Read instructions from file
        i = 0;
        while (!$feof(file) && i < 64) begin
            if ($fscanf(file, "%h", instruction) == 1) begin
                RAM[i] = instruction;
                i = i + 1;
            end
        end
        
        // Close the file
        $fclose(file);
    end
    
    // PC is word-aligned (4-byte instructions), using 6 bits for 64 entries
    assign InstrF = RAM[PCF[7:2]]; 
endmodule

`timescale 1ns/1ps
module next_pc_mux (
    input wire [31:0] pc_plus4F,           // PC + 4 (default next PC)
    input wire [31:0] branch_jump_target,  // Branch/jump target from Execute stage
    input wire pc_select,                  // PC selection signal from Hazard Unit
    output reg [31:0] next_pc              // Final next PC selection
);
    always @(*) begin
        case (pc_select)
            1'b0: next_pc = pc_plus4F;           // Select PC + 4 (normal sequential execution)
            1'b1: next_pc = branch_jump_target;  // Select branch target
            default: next_pc = pc_plus4F;        // Default to PC + 4
        endcase
    end
endmodule

`timescale 1ns/1ps
module IF_ID (
    input clk,
    input reset,
    input clear,             // Synchronous clear
    input StallF,            // Stall signal (prevents register update)
    input FlushD,            // Flush signal (clears register contents)
    input [31:0] InstrF,     // Instruction from Fetch stage
    input [31:0] PCF,        // PC from Fetch stage
    input [31:0] pc_plus4F,  // PC+4 from Fetch stage
    output reg [31:0] InstrD,    // Instruction to Decode stage
    output reg [31:0] PCD,       // PC to Decode stage
    output reg [31:0] pc_plus4D  // PC+4 to Decode stage
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin // Asynchronous Clear
            InstrD <= 32'b0;
            PCD <= 32'b0;
            pc_plus4D <= 32'b0;
        end else if (FlushD) begin // Flush Decode stage
            InstrD <= 32'b0;
            PCD <= 32'b0;
            pc_plus4D <= 32'b0;
        end else if (!StallF) begin // Check StallF before writing
            if (clear) begin // Synchronous Clear
                InstrD <= 32'b0;
                PCD <= 32'b0;
                pc_plus4D <= 32'b0;
            end else begin
                InstrD <= InstrF;
                PCD <= PCF;
                pc_plus4D <= pc_plus4F;
            end
        end
    end
endmodule

module reg_file (
    input clk,
    input RegWriteW,         // Register write enable
    input [4:0] Rs1D,        // Source register 1 address
    input [4:0] Rs2D,        // Source register 2 address
    input [4:0] RdW,         // Destination register address
    input [31:0] ResultW,    // Write data
    output [31:0] RD1D, RD2D, // Read data outputs
    output ERROR             // Error signal
);
    reg [31:0] rf[31:0];     // 32 registers x 32 bits each
    integer i;
    
    // Initialize register file with reproducible random values
    initial begin
        $srandom(42);        // Fixed seed for consistent random values
        
        rf[0] = 32'b0;       // x0 is hardwired to zero
        
        // Set random initial values for other registers
        for (i = 1; i < 32; i = i + 1)
            rf[i] = $random;
    end
    
    // Read ports with forwarding from write port for same-cycle read-after-write
    assign RD1D = (Rs1D == 5'b0) ? 32'b0 :
                 ((Rs1D == RdW && RegWriteW) ? ResultW : rf[Rs1D]);
    
    assign RD2D = (Rs2D == 5'b0) ? 32'b0 :
                 ((Rs2D == RdW && RegWriteW) ? ResultW : rf[Rs2D]);
    
    // Write port - writes on positive clock edge if enabled and not writing to x0
    always @(posedge clk) begin
        if (RegWriteW && RdW != 5'b0) 
            rf[RdW] <= ResultW;
    end
    
    assign ERROR = 1'b0;
endmodule

`timescale 1ns/1ps
module Immediate_propagation (
    input wire [31:0] InstrD, // 32-bit instruction
    input wire [2:0] ImmSrc,  // Immediate type selector
    output reg [31:0] ImmExtD // Extended immediate value
);
    always @(*) begin
        case (ImmSrc)
            3'b000: // I-type (load, arithmetic immediate, JALR)
                ImmExtD = {{20{InstrD[31]}}, InstrD[31:20]};
                
            3'b001: // S-type (store instructions)
                ImmExtD = {{20{InstrD[31]}}, InstrD[31:25], InstrD[11:7]};
                
            3'b010: // B-type (branch instructions)
                ImmExtD = {{19{InstrD[31]}}, InstrD[31], InstrD[7], InstrD[30:25], InstrD[11:8], 1'b0};
                
            3'b011: // U-type (LUI, AUIPC)
                ImmExtD = {InstrD[31:12], 12'b0};
                
            3'b100: // J-type (JAL)
                ImmExtD = {{11{InstrD[31]}}, InstrD[31], InstrD[19:12], InstrD[20], InstrD[30:21], 1'b0};
                
            3'b101: // I-type shift operations (slli, srli, srai)
                ImmExtD = {27'b0, InstrD[24:20]}; // Extract shift amount only
                
            3'b110: // R-type (register-register operations)
                ImmExtD = 32'b0; // R-type instructions don't use immediate values
                
            default: 
                ImmExtD = 32'b0;
        endcase
    end
endmodule

`timescale 1ns/1ps
module Main_Decoder (
    input [6:0] op,          // Opcode field from instruction
    input [2:0] funct3,      // Function code field
    output reg [1:0] ResultSrc, // Result source selector
    output reg MemWriteD,    // Memory write enable
    output reg BranchD,      // Branch instruction flag
    output reg ALUSrcA,      // ALU source A selector
    output reg ALUSrcB,      // ALU source B selector
    output reg RegWriteD,    // Register write enable
    output reg JumpD,        // Jump instruction flag
    output reg [2:0] ImmSrc, // Immediate format selector
    output reg [1:0] ALUOp,  // ALU operation type
    output reg MemReadD      // Memory read enable
);
    always @(*) begin
        // Default values
        RegWriteD = 1'b0;
        ImmSrc = 3'b000;
        ALUSrcA = 1'b0;
        ALUSrcB = 1'b0;
        MemWriteD = 1'b0;
        ResultSrc = 2'b00;
        BranchD = 1'b0;
        ALUOp = 2'b00;
        JumpD = 1'b0;
        MemReadD = 1'b0;
        
        case (op)
            7'b0000011: begin // lw (load word)
                RegWriteD = 1'b1;
                ImmSrc = 3'b000;
                ALUSrcA = 1'b0;
                ALUSrcB = 1'b1;
                ResultSrc = 2'b01;
                MemReadD = 1'b1;
            end
            7'b0100011: begin // sw (store word)
                ImmSrc = 3'b001;
                ALUSrcA = 1'b0;
                ALUSrcB = 1'b1;
                MemWriteD = 1'b1;
            end
            7'b0110011: begin // R-type (register-register)
                RegWriteD = 1'b1;
                ALUSrcA = 1'b0;
                ALUSrcB = 1'b0;
                ALUOp = 2'b10;
                ImmSrc = 3'b110;
            end
            7'b1100011: begin // B-type (branch)
                ImmSrc = 3'b010;
                ALUSrcA = 1'b0;
                ALUSrcB = 1'b0;
                BranchD = 1'b1;
                ALUOp = 2'b01;
            end
            7'b0010011: begin // I-type ALU
                RegWriteD = 1'b1;
                ALUSrcA = 1'b0;
                ALUSrcB = 1'b1;
                ALUOp = 2'b10;
                
                // Different immediate handling for shift instructions
                if (funct3 == 3'b001 || funct3 == 3'b101)
                    ImmSrc = 3'b101; // slli, srli, srai
                else
                    ImmSrc = 3'b000; // Other I-type ALU instructions
            end
            7'b1101111: begin // JAL (jump and link)
                RegWriteD = 1'b1;
                ImmSrc = 3'b100;
                JumpD = 1'b1;
                ResultSrc = 2'b10;  // PC+4 to rd
            end
            7'b1100111: begin // JALR (jump and link register)
                RegWriteD = 1'b1;
                ImmSrc = 3'b000;
                ALUSrcA = 1'b0;
                ALUSrcB = 1'b1;
                JumpD = 1'b1;
                ResultSrc = 2'b10;  // PC+4 to rd
            end
            7'b0110111: begin // LUI (load upper immediate)
                RegWriteD = 1'b1;
                ImmSrc = 3'b011;
                ALUSrcA = 1'b0;
                ALUSrcB = 1'b1;
            end
            7'b0010111: begin // AUIPC (add upper immediate to pc)
                RegWriteD = 1'b1;
                ImmSrc = 3'b011;
                ALUSrcA = 1'b1;  // Use PC as source A
                ALUSrcB = 1'b1;  // Use immediate as source B
            end
        endcase
    end
endmodule

`timescale 1ns/1ps
module ID_EX (
    input clk,
    input reset,
    input clear,             // Synchronous clear
    input FlushE,            // Flush Execute stage
    input JumpD,             // Jump signal from Decode stage
    input [31:0] RD1D, RD2D, PCD,
    input [31:0] ImmExtD, pc_plus4D,
    input MemReadD, MemWriteD, ALUSrcAD, ALUSrcBD,
    input [1:0] ResultSrcD, ALUOpD,
    input RegWriteD,
    input [31:0] InstrD,
    input BranchD,

    // Pipeline register outputs to Execute stage
    output reg [31:0] RD1E, RD2E, PCE,
    output reg [4:0] Rs1E, Rs2E, RdE,
    output reg [31:0] ImmExtE, pc_plus4E,
    output reg MemReadE, MemWriteE, ALUSrcAE, ALUSrcBE,
    output reg [1:0] ResultSrcE, ALUOpE,
    output reg RegWriteE,
    output reg [2:0] funct3E,
    output reg funct7b5E,    // Bit 30 of instruction for ALU control
    output reg opb5E,        // Bit 5 of opcode for ALU control
    output reg BranchE,
    output reg JumpE
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all outputs to 0
            RD1E <= 0;
            RD2E <= 0;
            PCE <= 0;
            Rs1E <= 0;
            Rs2E <= 0;
            RdE <= 0;
            ImmExtE <= 0;
            pc_plus4E <= 0;
            MemReadE <= 0;
            MemWriteE <= 0;
            ALUSrcAE <= 0;
            ALUSrcBE <= 0;
            ResultSrcE <= 0;
            ALUOpE <= 0;
            RegWriteE <= 0;
            funct3E <= 0;
            funct7b5E <= 0;
            opb5E <= 0;
            BranchE <= 0;
            JumpE <= 0;
        end else if (clear || FlushE) begin
            // Clear/flush all outputs to 0
            RD1E <= 0;
            RD2E <= 0;
            PCE <= 0;
            Rs1E <= 0;
            Rs2E <= 0;
            RdE <= 0;
            ImmExtE <= 0;
            pc_plus4E <= 0;
            MemReadE <= 0;
            MemWriteE <= 0;
            ALUSrcAE <= 0;
            ALUSrcBE <= 0;
            ResultSrcE <= 0;
            ALUOpE <= 0;
            RegWriteE <= 0;
            funct3E <= 0;
            funct7b5E <= 0;
            opb5E <= 0;
            BranchE <= 0;
            JumpE <= 0;
        end else begin
            // Pass values from Decode to Execute stage
            RD1E <= RD1D;
            RD2E <= RD2D;
            PCE <= PCD;
            Rs1E <= InstrD[19:15];  // Extract rs1 field
            Rs2E <= InstrD[24:20];  // Extract rs2 field
            RdE <= InstrD[11:7];    // Extract rd field
            ImmExtE <= ImmExtD;
            pc_plus4E <= pc_plus4D;
            MemReadE <= MemReadD;
            MemWriteE <= MemWriteD;
            ALUSrcAE <= ALUSrcAD;
            ALUSrcBE <= ALUSrcBD;
            ResultSrcE <= ResultSrcD;
            ALUOpE <= ALUOpD;
            RegWriteE <= RegWriteD;
            funct3E <= InstrD[14:12];  // Extract funct3 field
            funct7b5E <= InstrD[30];   // Extract bit 30
            opb5E <= InstrD[5];        // Extract bit 5 of opcode
            BranchE <= BranchD;
            JumpE <= JumpD;
        end
    end
endmodule

`timescale 1ns/1ps
module Branch_Jump_Adder (
    input [31:0] PCE,        // Program counter value
    input [31:0] ImmExtE,    // Extended immediate value
    output reg [31:0] branch_jump_target  // Target address for branch/jump
);
    // Calculate branch/jump target address
    always @ (PCE, ImmExtE) begin
        branch_jump_target = PCE + ImmExtE;
    end
endmodule


`timescale 1ns/1ps
module ALU_Select (
    input  [31:0] PCE,        // Program Counter (Used for ALU A)
    input  [31:0] ForwardedA, // Forwarded data for ALU A
    input  [31:0] Immediate,  // Immediate value (Used for ALU B)
    input  [31:0] ForwardedB, // Forwarded data for ALU B
    input  ALUSrcAE,          // Select signal for ALU A
    input  ALUSrcBE,          // Select signal for ALU B
    output [31:0] ALUInputA,  // Output to ALU (A)
    output [31:0] ALUInputB   // Output to ALU (B)
);
    assign ALUInputA = ALUSrcAE ? PCE : ForwardedA;
    assign ALUInputB = ALUSrcBE ? Immediate : ForwardedB;
endmodule

module forwardA(
    input  [31:0] RD1E,        // Register read value
    input  [31:0] ALUResultW,  // ALU result from Writeback stage
    input  [31:0] ReadDataW,   // Data read from memory in Writeback stage
    input  [31:0] pc_plus4W,   // PC+4 value from Writeback stage
    input  [1:0] ResultSrcW,   // Result source in Writeback stage
    input  [31:0] ALUResultM,  // ALU result from Memory stage
    input  [31:0] ReadDataM,   // Data read from memory in Memory stage
    input  [31:0] pc_plus4M,   // PC+4 value from Memory stage
    input  [1:0] ResultSrcM,   // Result source in Memory stage
    input  [1:0] ForwardA,     // Forward signal from Hazard Unit
    output [31:0] ForwardedA   // Selected output
);
    reg [31:0] ResultM;
    reg [31:0] ResultW;

    // Select correct value from Memory stage based on ResultSrcM
    always @(*) begin
        case (ResultSrcM)
            2'b00: ResultM = ALUResultM;   // ALU result
            2'b01: ResultM = ReadDataM;    // Memory value (load)
            2'b10: ResultM = pc_plus4M;    // PC+4 (after jump)
            default: ResultM = ALUResultM;
        endcase
    end

    // Select correct value from Writeback stage based on ResultSrcW
    always @(*) begin
        case (ResultSrcW)
            2'b00: ResultW = ALUResultW;   // ALU result
            2'b01: ResultW = ReadDataW;    // Memory value (load)
            2'b10: ResultW = pc_plus4W;    // PC+4 (after jump)
            default: ResultW = ALUResultW;
        endcase
    end

    assign ForwardedA = (ForwardA == 2'b10) ? ResultM : 
                        (ForwardA == 2'b01) ? ResultW : RD1E;
endmodule

module forwardB(
    input  [31:0] RD2E,        // Register read value
    input  [31:0] ALUResultW,  // ALU result from Writeback stage
    input  [31:0] ReadDataW,   // Data read from memory in Writeback stage
    input  [31:0] pc_plus4W,   // PC+4 value from Writeback stage
    input  [1:0] ResultSrcW,   // Result source in Writeback stage
    input  [31:0] ALUResultM,  // ALU result from Memory stage
    input  [31:0] ReadDataM,   // Data read from memory in Memory stage
    input  [31:0] pc_plus4M,   // PC+4 value from Memory stage
    input  [1:0] ResultSrcM,   // Result source in Memory stage
    input  [1:0] ForwardB,     // Forward signal from Hazard Unit
    output [31:0] ForwardedB   // Selected output
);
    reg [31:0] ResultM;
    reg [31:0] ResultW;

    // Select correct value from Memory stage based on ResultSrcM
    always @(*) begin
        case (ResultSrcM)
            2'b00: ResultM = ALUResultM;   // ALU result
            2'b01: ResultM = ReadDataM;    // Memory value (load)
            2'b10: ResultM = pc_plus4M;    // PC+4 (after jump)
            default: ResultM = ALUResultM;
        endcase
    end

    // Select correct value from Writeback stage based on ResultSrcW
    always @(*) begin
        case (ResultSrcW)
            2'b00: ResultW = ALUResultW;   // ALU result
            2'b01: ResultW = ReadDataW;    // Memory value (load)
            2'b10: ResultW = pc_plus4W;    // PC+4 (after jump)
            default: ResultW = ALUResultW;
        endcase
    end

    assign ForwardedB = (ForwardB == 2'b10) ? ResultM : 
                        (ForwardB == 2'b01) ? ResultW : RD2E;
endmodule

`timescale 1ns/1ps
module ALU_Decoder (
    input wire opb5E, // Determine either add or a sub in some cases
    input wire [2:0] funct3E, // for inner operations inside the ISA type
    input wire funct7b5E, // same as the 1st comment
    input wire [1:0] ALUOpE, //from the main_Decode
    output reg [3:0] ALUControl 
);
    wire RtypeSub;
    assign RtypeSub = funct7b5E & opb5E; // TRUE for R-type subtract
    
    always @(*) begin
        case (ALUOpE)
            2'b00: ALUControl = 4'b0000; // addition (for loads/stores)
            2'b01: begin // Branch instructions
                case (funct3E)
                    3'b000: ALUControl = 4'b1001; // BEQ (Branch if Equal)
                    3'b001: ALUControl = 4'b1010; // BNE (Branch if Not Equal)
                    3'b100: ALUControl = 4'b1011; // BLT (Branch if Less Than)
                    3'b101: ALUControl = 4'b1100; // BGE (Branch if Greater or Equal)
                    3'b110: ALUControl = 4'b1101; // BLTU (Branch if Less Than Unsigned)
                    3'b111: ALUControl = 4'b1110; // BGEU (Branch if Greater or Equal Unsigned)
                    default: ALUControl = 4'b0001; // Default to subtraction for unrecognized branch
                endcase
            end
            default: begin
                case (funct3E) // R-type or I-type ALU
                    3'b000: if (RtypeSub)
                                ALUControl = 4'b0001; // sub
                            else
                                ALUControl = 4'b0000; // add, addi
                    3'b001: ALUControl = 4'b0100; // sll, slli
                    3'b010: ALUControl = 4'b0101; // slt, slti
                    3'b011: ALUControl = 4'b1000; // sltu, sltiu
                    3'b100: ALUControl = 4'b0110; // xor, xori
                    3'b101: if (~funct7b5E)
                                ALUControl = 4'b0111; // srl, srli
                            else
                                ALUControl = 4'b1111; // sra, srai
                    3'b110: ALUControl = 4'b0011; // or, ori
                    3'b111: ALUControl = 4'b0010; // and, andi
                    default: ALUControl = 4'bxxxx; // unknown
                endcase
            end
        endcase
    end
endmodule


`timescale 1ns/1ps
module ALU (
    input [31:0] SrcA,          // First operand
    input [31:0] SrcB,          // Second operand
    input [3:0] ALUControl,     // ALU operation control
    output reg signed [31:0] ALUResultE, // ALU result
    output wire zero,           // Zero flag (used for branches)
    output reg branch_taken     // Branch taken flag for conditional branches
);
    wire signed [31:0] signed_SrcA, signed_SrcB;
    assign signed_SrcA = SrcA;
    assign signed_SrcB = SrcB;
    
    // Zero flag - indicates if ALU result is zero
    assign zero = (ALUResultE == 32'b0);
    
    always @(*) begin
        // Default value - not taking branch
        branch_taken = 1'b0;
        
        case (ALUControl)
            4'b0000: ALUResultE = SrcA + SrcB;                           // ADD
            4'b0001: ALUResultE = SrcA - SrcB;                           // SUB
            4'b0010: ALUResultE = SrcA & SrcB;                           // AND
            4'b0011: ALUResultE = SrcA | SrcB;                           // OR
            4'b0100: ALUResultE = SrcA << SrcB[4:0];                     // SLL (Shift Left Logical)
            4'b0101: ALUResultE = (signed_SrcA < signed_SrcB) ? 32'b1 : 32'b0; // SLT (Set Less Than)
            4'b0110: ALUResultE = SrcA ^ SrcB;                           // XOR
            4'b0111: ALUResultE = SrcA >> SrcB[4:0];                     // SRL (Shift Right Logical)
            4'b1000: ALUResultE = (SrcA < SrcB) ? 32'b1 : 32'b0;         // SLTU (Set Less Than Unsigned)
            4'b1001: begin                                               // BEQ (Branch if Equal)
                ALUResultE = SrcA - SrcB;
                branch_taken = (ALUResultE == 32'b0);
            end
            4'b1010: begin                                               // BNE (Branch if Not Equal)
                ALUResultE = SrcA - SrcB;
                branch_taken = (ALUResultE != 32'b0);
            end
            4'b1011: begin                                               // BLT (Branch if Less Than)
                ALUResultE = (signed_SrcA < signed_SrcB) ? 32'b1 : 32'b0;
                branch_taken = (signed_SrcA < signed_SrcB);
            end
            4'b1100: begin                                               // BGE (Branch if Greater or Equal)
                ALUResultE = (signed_SrcA >= signed_SrcB) ? 32'b1 : 32'b0;
                branch_taken = (signed_SrcA >= signed_SrcB);
            end
            4'b1101: begin                                               // BLTU (Branch if Less Than Unsigned)
                ALUResultE = (SrcA < SrcB) ? 32'b1 : 32'b0;
                branch_taken = (SrcA < SrcB);
            end
            4'b1110: begin                                               // BGEU (Branch if Greater or Equal Unsigned)
                ALUResultE = (SrcA >= SrcB) ? 32'b1 : 32'b0;
                branch_taken = (SrcA >= SrcB);
            end
            4'b1111: ALUResultE = $signed(SrcA) >>> $unsigned(SrcB[4:0]); // SRA (Shift Right Arithmetic)
            default: ALUResultE = 32'b0;                                 // Default case
        endcase
    end
endmodule


`timescale 1ns/1ps
module IEx_IMem (
    input clk, reset,
    input [31:0] ALUResultE, ForwardedB,
    input [4:0] RdE,
    input [31:0] pc_plus4E,
    input [1:0] ResultSrcE,
    input MemReadE, MemWriteE,
    input RegWriteE,             // Input RegWrite signal from Execute stage
    output reg [31:0] ALUResultM, WriteDataM,
    output reg [4:0] RdM,
    output reg [31:0] pc_plus4M,
    output reg [1:0] ResultSrcM,  // 2-bit signal, corrected in reset block
    output reg MemReadM, MemWriteM,
    output reg RegWriteM         // Output RegWrite signal to Memory stage
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ALUResultM <= 32'b0;
            WriteDataM <= 32'b0;
            RdM <= 5'b0;
            pc_plus4M <= 32'b0;
            ResultSrcM <= 2'b0;  // Corrected from 3'b0 to 2'b0
            MemReadM <= 1'b0;
            MemWriteM <= 1'b0;
            RegWriteM <= 1'b0;   // Reset RegWrite signal
        end else begin
            ALUResultM <= ALUResultE;
            WriteDataM <= ForwardedB;
            RdM <= RdE;
            pc_plus4M <= pc_plus4E;
            ResultSrcM <= ResultSrcE;
            MemReadM <= MemReadE;
            MemWriteM <= MemWriteE;
            RegWriteM <= RegWriteE; // Forward RegWrite signal
        end
    end
endmodule

`timescale 1ns/1ps
module Data_Memory (
    input clk,             // Clock signal
    input we,              // Write Enable signal
    input [31:0] a,        // Address input
    input [31:0] wd,       // Write data input
    output [31:0] ReadDataM // Read data output
);
    reg [31:0] RAM [63:0]; // 64 x 32-bit memory
    integer i;             // Declare integer i at module level
    
    // Use only relevant address bits for indexing
    assign ReadDataM = RAM[a[7:2]]; // Word-aligned addressing (bits 7:2 for 64 entries)
    
    // Initialize memory to reproducible random values
    initial begin
        $srandom(42);      // Set a fixed seed for reproducibility
        for (i = 0; i < 64; i = i + 1) begin
            RAM[i] = $random; // Initialize all memory with random values
        end
    end
    
    always @(posedge clk) begin
        if (we) 
            RAM[a[7:2]] <= wd;
    end
endmodule

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

`timescale 1ns/1ps
module result_mux (
    input wire [31:0] ALUresultW,  // Input from the ALU
    input wire [31:0] ReadDataW,   // Input from the Read Data
    input wire [31:0] pc_plus4W,   // Input from the Program Counter
    input wire [1:0] ResultSrcW,   // Control signal for selecting the result
    output reg [31:0] ResultW      // Output result
);

    always @(*) begin
        case (ResultSrcW)
            2'b10: ResultW = pc_plus4W;  // PC+4 (for JAL/JALR)
            2'b01: ResultW = ReadDataW;  // Memory data (for load)
            default: ResultW = ALUresultW; // ALU result (default)
        endcase
    end
endmodule

module Hazard_Unit (
    input [4:0] Rs1E, Rs2E,  // Source registers in Execute stage
    input [4:0] RdE,         // Destination register in Execute stage
    input [4:0] RdM,         // Destination register in Memory stage
    input [4:0] RdW,         // Destination register in Writeback stage
    input [4:0] Rs1D, Rs2D,  // Source registers in Decode stage
    input JumpE,             // Jump signal in Execute stage
    input BranchE,           // Branch signal in Execute stage 
    input branch_taken,      // Branch taken signal from ALU
    input MemReadE,          // Memory read signal in Execute stage
    input RegWriteM,         // Register write signal in Memory stage
    input RegWriteW,         // Register write signal in Writeback stage
    input [1:0] ResultSrcM,  // Result source in Memory stage
    input [1:0] ResultSrcW,  // Result source in Writeback stage
    
    output reg [1:0] ForwardA,  // Forward control for ALU input A
    output reg [1:0] ForwardB,  // Forward control for ALU input B
    output reg FlushD,          // Flush Decode stage
    output reg FlushE,          // Flush Execute stage
    output reg StallF,          // Stall Fetch stage
    output reg StallD,          // Stall Decode stage
    output reg pc_select        // PC select signal (0:PC+4, 1:branch/jump target)
);

    reg LoadUseHazard; 

    // Forwarding logic - handles data hazards with forwarding
    always @(*) begin
        ForwardA = 2'b00;
        ForwardB = 2'b00;
        
        // Forward from Memory stage to ALU input A
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs1E)) begin
            ForwardA = 2'b10;
        end 
        // Forward from Writeback stage to ALU input A
        else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs1E)) begin
            ForwardA = 2'b01;
        end
        
        // Forward from Memory stage to ALU input B
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs2E)) begin
            ForwardB = 2'b10;
        end 
        // Forward from Writeback stage to ALU input B
        else if (RegWriteW && (RdW != 5'b0) && (RdW == Rs2E)) begin
            ForwardB = 2'b01;
        end
    end

    // Detect load-use data hazard
    always @(*) begin
        LoadUseHazard = MemReadE && (RdE != 0) && ((RdE == Rs1D) || (RdE == Rs2D));
    end

    // Control hazard handling and pipeline stalling
    always @(*) begin
        StallF = 1'b0;
        StallD = 1'b0;
        FlushE = 1'b0;
        FlushD = 1'b0;
        pc_select = 1'b0;

        // Handle load-use hazard - stall pipeline
        if (LoadUseHazard) begin
            StallF = 1'b1;  // Stall Fetch
            StallD = 1'b1;  // Stall Decode
            FlushE = 1'b1;  // Flush Execute
        end
        
        // Handle control hazards (branches and jumps)
        if (BranchE && branch_taken) begin
            FlushD = 1'b1;  // Flush Decode stage
            FlushE = 1'b1;  // Flush Execute stage
            pc_select = 1'b1; // Select branch target
        end
        else if (JumpE) begin
            FlushD = 1'b1;  // Flush Decode stage
            FlushE = 1'b1;  // Flush Execute stage
            pc_select = 1'b1; // Select jump target
        end
    end
endmodule