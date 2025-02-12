`timescale 1ns/1ps

module ALU_Decoder (
    input wire opb5E,
    input wire [2:0] funct3E,
    input wire funct7b5E,
    input wire [1:0] ALUOpE,
    output reg [3:0] ALUControl
);

    wire RtypeSub;
    assign RtypeSub = funct7b5E & opb5E; // TRUE for R-type subtract

    always @(*) begin
        case (ALUOpE)
            2'b00: ALUControl = 4'b0000; // addition
            2'b01: ALUControl = 4'b0001; // subtraction
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
                                ALUControl = 4'b0111; // srl
                            else
                                ALUControl = 4'b1111; // sra
                    3'b110: ALUControl = 4'b0011; // or, ori
                    3'b111: ALUControl = 4'b0010; // and, andi
                    default: ALUControl = 4'bxxxx; // unknown
                endcase
            end
        endcase
    end

endmodule
