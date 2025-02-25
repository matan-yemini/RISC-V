`timescale 1ns/1ps

module ALU (
    input  [31:0] SrcA, SrcB,      
    input  [3:0]  ALUControl,      
    output reg [31:0] ALUResultE,  
    output wire zero,              
    output reg branch_taken        
);

    wire [31:0] Sum;               
    wire Overflow;                 
    wire [31:0] OperandB;          

    // OperandB inversion for subtraction
    assign OperandB = (ALUControl[0] ? ~SrcB : SrcB);  
    assign Sum = SrcA + OperandB + ALUControl[0];      

    // Overflow detection
    assign Overflow = ~(ALUControl[0] ^ SrcB[31] ^ SrcA[31]) & (SrcA[31] ^ Sum[31]);

    assign zero = (ALUResultE == 0);

    always @(*) begin
        case (ALUControl)
            4'b0001: branch_taken = (SrcA == SrcB);  
            4'b0101: branch_taken = (SrcA != SrcB);  
            4'b0110: branch_taken = ($signed(SrcA) < $signed(SrcB)); 
            4'b0111: branch_taken = ($signed(SrcA) >= $signed(SrcB)); 
            4'b1000: branch_taken = (SrcA < SrcB);   
            4'b1001: branch_taken = (SrcA >= SrcB);  
            default: branch_taken = 1'b0;           
        endcase
    end

    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResultE = SrcA + SrcB;            
            4'b0001: ALUResultE = SrcA - SrcB;            
            4'b0010: ALUResultE = SrcA & SrcB;            
            4'b0011: ALUResultE = SrcA | SrcB;            
            4'b0100: ALUResultE = SrcA << SrcB[4:0];      
            4'b0101: ALUResultE = (SrcA < SrcB) ? 1 : 0;  
            4'b0110: ALUResultE = SrcA ^ SrcB;            
            4'b0111: ALUResultE = SrcA >> SrcB[4:0];      
            4'b1000: ALUResultE = (SrcA < SrcB) ? 1 : 0;  
            4'b1111: ALUResultE = $signed(SrcA) >>> SrcB[4:0]; 
            default: ALUResultE = 32'b0;                  
        endcase
    end

endmodule