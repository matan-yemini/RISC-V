`timescale 1ns/1ps

module next_pc_mux (
    input wire [31:0] pc_plus4F,        // PC + 4
    input wire [31:0] next_pc_hazard,  // Selected PC from Hazard Unit
    input wire pc_signal,              // Control signal from Hazard Unit
    output reg [31:0] next_pc     // Final PC selection
);

    always @(*) begin
        if (pc_signal) 
            next_pc = next_pc_hazard; // Use next_pc from Hazard Unit
        else 
            next_pc = pc_plus4F;       // Use PC + 4
    end

endmodule
