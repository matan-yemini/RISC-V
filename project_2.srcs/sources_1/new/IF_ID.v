`timescale 1ns/1ps

module IF_ID (
    input clk,
    input reset,
    input clear,
    input StallF,              // Stall signal for the Fetch stage
    input FlushD,              // Flush signal for Decode stage
    input [31:0] InstrF,
    input [31:0] PCF,
    input [31:0] pc_plus4F,
    output reg [31:0] InstrD,
    output reg [31:0] PCD,
    output reg [31:0] pc_plus4D
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin // Asynchronous Clear
            InstrD <= 32'b0;
            PCD <= 32'b0;
            pc_plus4D
     <= 32'b0;
        end else if (FlushD) begin // Flush Decode stage
            InstrD <= 32'b0;
            PCD <= 32'b0;
            pc_plus4D<= 32'b0;
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
