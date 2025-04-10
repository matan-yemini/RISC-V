`timescale 1ns/1ps
module Instruction_Memory(
    input [31:0] PCF, 
    output [31:0] InstrF
);
    reg [31:0] RAM [0:31]; // 32 instructions (word-addressable)
    integer i; // Declare integer i at module level
    
    // Initialize all memory locations
    initial begin
        // Instruction: 00500113
        RAM[0]  = 8'h13; RAM[1]  = 8'h01; RAM[2]  = 8'h50; RAM[3]  = 8'h00;
        // Instruction: 00c00193
        RAM[4]  = 8'h93; RAM[5]  = 8'h01; RAM[6]  = 8'hc0; RAM[7]  = 8'h00;
        // Instruction: ff718393
        RAM[8]  = 8'h93; RAM[9]  = 8'h83; RAM[10] = 8'h71; RAM[11] = 8'hff;
        // Instruction: 0023e233
        RAM[12] = 8'h33; RAM[13] = 8'he2; RAM[14] = 8'h23; RAM[15] = 8'h00;
        // Instruction: 0041c2b3
        RAM[16] = 8'hb3; RAM[17] = 8'hc2; RAM[18] = 8'h41; RAM[19] = 8'h00;
        // Instruction: 004282b3
        RAM[20] = 8'hb3; RAM[21] = 8'h82; RAM[22] = 8'h42; RAM[23] = 8'h00;
        // Instruction: 02728863
        RAM[24] = 8'h63; RAM[25] = 8'h88; RAM[26] = 8'h72; RAM[27] = 8'h02;
        // Instruction: 0041a233
        RAM[28] = 8'h33; RAM[29] = 8'ha2; RAM[30] = 8'h41; RAM[31] = 8'h00;
        // Instruction: 00020463
        RAM[32] = 8'h63; RAM[33] = 8'h04; RAM[34] = 8'h02; RAM[35] = 8'h00;
        // Instruction: 00000293
        RAM[36] = 8'h93; RAM[37] = 8'h02; RAM[38] = 8'h00; RAM[39] = 8'h00;
        // Instruction: 0023a233
        RAM[40] = 8'h33; RAM[41] = 8'ha2; RAM[42] = 8'h23; RAM[43] = 8'h00;
        // Instruction: 005203b3
        RAM[44] = 8'hb3; RAM[45] = 8'h03; RAM[46] = 8'h52; RAM[47] = 8'h00;
        // Instruction: 402383b2
        RAM[48] = 8'hb2; RAM[49] = 8'h83; RAM[50] = 8'h23; RAM[51] = 8'h40;
        // Instruction: 0471aa23
        RAM[52] = 8'h23; RAM[53] = 8'haa; RAM[54] = 8'h71; RAM[55] = 8'h04;
        // Instruction: 06002103
        RAM[56] = 8'h03; RAM[57] = 8'h21; RAM[58] = 8'h00; RAM[59] = 8'h06;
        // Instruction: 005104b3
        RAM[60] = 8'hb3; RAM[61] = 8'h04; RAM[62] = 8'h51; RAM[63] = 8'h00;
        // Instruction: 008001ef
        RAM[64] = 8'hef; RAM[65] = 8'h01; RAM[66] = 8'h00; RAM[67] = 8'h08;
        // Instruction: 00100113
        RAM[68] = 8'h13; RAM[69] = 8'h01; RAM[70] = 8'h10; RAM[71] = 8'h00;
        // Instruction: 00910133
        RAM[72] = 8'h33; RAM[73] = 8'h01; RAM[74] = 8'h91; RAM[75] = 8'h00;
        // Instruction: 00100213
        RAM[76] = 8'h13; RAM[77] = 8'h02; RAM[78] = 8'h10; RAM[79] = 8'h00;
        // Instruction: 800002b7
        RAM[80] = 8'h
