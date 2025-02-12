`timescale 1ns/1ps

module BPU #(
    parameter BTB_SIZE = 16
)(
    input wire clk,
    input wire reset,
    input wire [31:0] pc,
    input wire [31:0] branch_jump_targetD,
    input wire branch_taken,
    input wire BranchD,
    input wire BranchE,
    output wire [31:0] predicted_pc,
    output wire PredictionD
);

    reg [31:0] btb_pc [0:BTB_SIZE-1];
    reg [31:0] btb_target [0:BTB_SIZE-1];
    reg valid [0:BTB_SIZE-1];

    reg [1:0] state;
    integer i;

    reg btb_hit;
    reg [31:0] btb_predicted_pc;
    reg update_done;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < BTB_SIZE; i = i + 1) begin
                valid[i] <= 1'b0;
                btb_pc[i] <= 32'b0;
                btb_target[i] <= 32'b0;
            end
            state <= 2'b00;
        end
    end

    always @(*) begin
        btb_hit = 1'b0;
        btb_predicted_pc = 32'b0;
        if (BranchD) begin
            for (i = 0; i < BTB_SIZE; i = i + 1) begin
                if (valid[i] && btb_pc[i] == pc) begin
                    btb_hit = 1'b1;
                    btb_predicted_pc = btb_target[i];
                end
            end
        end
    end

    always @(posedge clk) begin
        if (BranchE && branch_taken) begin
            update_done = 1'b0;
            for (i = 0; i < BTB_SIZE && !update_done; i = i + 1) begin
                if (!valid[i]) begin
                    valid[i] <= 1'b1;
                    btb_pc[i] <= pc;
                    btb_target[i] <= branch_jump_targetD;
                    update_done = 1'b1;
                end
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 2'b00;
        end else if (BranchE) begin
            case (state)
                2'b00: state <= (branch_taken) ? 2'b01 : 2'b00;
                2'b01: state <= (branch_taken) ? 2'b10 : 2'b00;
                2'b10: state <= (branch_taken) ? 2'b11 : 2'b01;
                2'b11: state <= (branch_taken) ? 2'b11 : 2'b10;
                default: state <= 2'b00;
            endcase
        end
    end

    assign PredictionD = BranchD ? state[1] : 1'b0;
    assign predicted_pc = (btb_hit && PredictionD) ? btb_predicted_pc : pc + 4;

endmodule
