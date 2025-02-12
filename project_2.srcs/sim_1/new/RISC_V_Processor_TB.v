`timescale 1ns/1ps

module Top_Module_tb();
    // Signals
    reg clk;
    reg reset;
    reg clear;
    wire ERROR;
    wire zero;

    // Instantiate the Top_Module
    Top_Module dut (
        .clk(clk),
        .reset(reset),
        .clear(clear),
        .ERROR(ERROR),
        .zero(zero)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock (10ns period)
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        reset = 1;
        clear = 0;
        
        // Wait 100 ns for global reset
        #100;
        
        // Release reset
        reset = 0;
        
        // Run for some time
        #1000;
        
        // End simulation
        $finish;
    end

    // Optional: Monitor important signals
    initial begin
        $monitor("Time=%0t reset=%b ERROR=%b zero=%b PC=%h Instr=%h",
                 $time, reset, ERROR, zero, dut.PCF, dut.InstrF);
    end

endmodule