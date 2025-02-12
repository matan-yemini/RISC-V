`timescale 1ns/1ps

module ALU (
    input  [31:0] SrcA, SrcB,      // ALU input operands
    input  [3:0]  ALUControl,      // ALU control signal
    output reg [31:0] ALUResultE,  // ALU result
    output wire zero,              // Zero flag (changed to wire)
    output reg branch_taken        // Branch Taken signal
);

    wire [31:0] Sum;               // Result of addition/subtraction
    wire Overflow;                 // Overflow flag
    wire [31:0] OperandB;          // Operand B with possible inversion for subtraction

    // Determine OperandB based on ALUControl (for addition/subtraction)
    assign OperandB = (ALUControl[0] ? ~SrcB : SrcB);  // Invert SrcB for subtraction
    assign Sum = SrcA + OperandB + ALUControl[0];      // Addition or subtraction

    // Overflow detection logic for signed addition/subtraction
    assign Overflow = ~(ALUControl[0] ^ SrcB[31] ^ SrcA[31]) & (SrcA[31] ^ Sum[31]);

    // Zero flag logic (Zero is active if ALUResultE is zero)
    assign zero = (ALUResultE == 0);

    // Branch Taken logic
    always @(*) begin
        case (ALUControl)
            4'b0001: branch_taken = (SrcA == SrcB);  // BEQ (Branch if Equal)
            4'b0101: branch_taken = (SrcA != SrcB);  // BNE (Branch if Not Equal)
            4'b0110: branch_taken = ($signed(SrcA) < $signed(SrcB)); // BLT (Signed Less Than)
            4'b0111: branch_taken = ($signed(SrcA) >= $signed(SrcB)); // BGE (Signed Greater or Equal)
            4'b1000: branch_taken = (SrcA < SrcB);   // BLTU (Unsigned Less Than)
            4'b1001: branch_taken = (SrcA >= SrcB);  // BGEU (Unsigned Greater or Equal)
            default: branch_taken = 1'b0;           // Default: No branch
        endcase
    end

    // ALU Operation logic
    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResultE = SrcA + SrcB;            // ADD
            4'b0001: ALUResultE = SrcA - SrcB;            // SUB
            4'b0010: ALUResultE = SrcA & SrcB;            // AND
            4'b0011: ALUResultE = SrcA | SrcB;            // OR
            4'b0100: ALUResultE = SrcA << SrcB[4:0];      // SLL (Shift Left Logical)
            4'b0101: ALUResultE = (SrcA < SrcB) ? 1 : 0;  // SLT (Set Less Than)
            4'b0110: ALUResultE = SrcA ^ SrcB;            // XOR
            4'b0111: ALUResultE = SrcA >> SrcB[4:0];      // SRL (Shift Right Logical)
            4'b1000: ALUResultE = (SrcA < SrcB) ? 1 : 0;  // SLTU (Unsigned Set Less Than)
            4'b1111: ALUResultE = $signed(SrcA) >>> SrcB[4:0]; // SRA (Shift Right Arithmetic)
            default: ALUResultE = 32'b0;                  // Default: Zero
        endcase
    end

endmodule
