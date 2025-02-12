`timescale 1ns/1ps

module Main_Decoder (
    input [6:0] op,                     // Opcode (7 bits)
    output reg [1:0] ResultSrc,         // Select the result source
    output reg MemWriteD,               // Memory write enable
    output reg BranchD,                 // Branch signal
    output reg ALUSrcA,                 // ALU source A selection
    output reg ALUSrcB,                 // ALU source B selection
    output reg RegWriteD,               // Register write enable
    output reg JumpD,                   // Jump signal
    output reg [2:0] ImmSrc,            // Immediate source selection
    output reg [1:0] ALUOp,             // ALU operation
    output reg MemReadD                 // Memory read enable
);

    // Control signals (expanded to individual assignments)
    always @(*) begin
        // Default/reset values
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

        // Control logic
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
            7'b0110011: begin // R-type
                RegWriteD = 1'b1;
                ALUSrcA = 1'b0;
                ALUSrcB = 1'b0;
                ALUOp = 2'b10;
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
            end
            7'b1101111: begin // JAL (jump and link)
                RegWriteD = 1'b1;
                ImmSrc = 3'b011;
                JumpD = 1'b1;
            end
            default: begin
                // Default/reset values already set above
            end
        endcase
    end

endmodule
