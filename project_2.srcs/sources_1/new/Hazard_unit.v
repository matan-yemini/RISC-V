`timescale 1ns/1ps

module Hazard_Unit (
    input [4:0] RdE,        // Destination register in the Execute stage
    input [4:0] RdM,        // Destination register in the Memory stage
    input [4:0] Rs1D, Rs2D, // Source registers in the Decode stage
    input JumpD,            // Indicates a jump instruction in the Decode stage
    input BranchTaken,      // Indicates whether the branch condition is taken
    input PredictionD,      // Indicates the prediction of the branch in Decode stage
    input PredictionE,      // Indicates the prediction of the branch in Execute stage
    input MemReadE,         // Indicates a load instruction in the Execute stage
    input [31:0] pc_plus4F, // PC + 4 default
    input [31:0] pc_plus4E, // PC + 4 from Execute stage
    input [31:0] branch_jump_targetE, // Branch/jump target address from Execute stage
    input [31:0] branch_jump_targetD, // Branch/jump target address from Decode stage
    input [31:0] predicted_pc, // Predicted PC when PredictionD is active
    output reg [31:0] next_pc_hazard, // Selected next PC
    output reg [1:0] ForwardA,  // Forwarding control signal for source A
    output reg [1:0] ForwardB,  // Forwarding control signal for source B
    output reg FlushD,          // Flush Decode stage
    output reg FlushE,          // Flush Execute stage
    output reg StallF,          // Stall Fetch stage
    output reg StallD,          // Stall Decode stage
    output reg pc_signal        // Signal: 1 for anything other than pc+4, 0 for pc+4
);

    reg LoadUseHazard; // Indicates a load-use hazard

    // Forwarding logic
    always @(*) begin
        // Forwarding for source A
        if (RdE != 5'b0 && RdE == Rs1D) begin
            ForwardA = 2'b10; // Forward from Execute stage
        end else if (RdM != 5'b0 && RdM == Rs1D) begin
            ForwardA = 2'b01; // Forward from Memory stage
        end else begin
            ForwardA = 2'b00; // No forwarding
        end

        // Forwarding for source B
        if (RdE != 5'b0 && RdE == Rs2D) begin
            ForwardB = 2'b10; // Forward from Execute stage
        end else if (RdM != 5'b0 && RdM == Rs2D) begin
            ForwardB = 2'b01; // Forward from Memory stage
        end else begin
            ForwardB = 2'b00; // No forwarding
        end
    end

    // Detect load-use hazard
    always @(*) begin
        LoadUseHazard = MemReadE && (RdE != 0) && (RdE == Rs1D || RdE == Rs2D);
    end

    // Generate stall signals
    always @(*) begin
        StallF = LoadUseHazard;
        StallD = LoadUseHazard;
        FlushE = LoadUseHazard; // Insert NOP in Execute stage
    end

    // Control Hazards handling and pc_signal generation
    always @(*) begin
        next_pc_hazard = pc_plus4F; // Default case
        pc_signal = 1'b0; // Default to PC + 4

        if (JumpD) begin
            next_pc_hazard = branch_jump_targetD; // Jump takes precedence
            pc_signal = 1'b1; // Not PC + 4
            if (!PredictionE && BranchTaken) begin
                next_pc_hazard = branch_jump_targetE; // Correct jump target from Execute stage
            end else if (PredictionE && !BranchTaken) begin
                next_pc_hazard = pc_plus4E; // Use PC + 4 from Execute stage
            end
        end else if (PredictionD) begin
            next_pc_hazard = predicted_pc; // Use predicted_pc when PredictionD is active
            pc_signal = 1'b1; // Not PC + 4
            if (!PredictionE && BranchTaken) begin
                next_pc_hazard = branch_jump_targetE; // Correct prediction from Execute stage
            end else if (PredictionE && !BranchTaken) begin
                next_pc_hazard = pc_plus4E; // Use PC + 4 from Execute stage
            end
        end
    end

    // Unified Flush and Stall Logic
    always @(*) begin
        FlushD = (JumpD || (!PredictionE && BranchTaken) || (PredictionE && !BranchTaken));
    end

endmodule
