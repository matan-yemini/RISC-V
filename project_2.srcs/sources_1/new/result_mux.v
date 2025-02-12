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
            2'b10: ResultW = pc_plus4W;
            2'b01: ResultW = ReadDataW;
            default: ResultW = ALUresultW;
        endcase
    end

endmodule
