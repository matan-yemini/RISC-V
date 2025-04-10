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
        
        // Apply reset for a few clock cycles
        repeat (5) @(posedge clk);
        
        // Release reset synchronously with clock
        @(posedge clk);
        reset = 0;
        
        // Run for a longer time to ensure pipeline fills completely
        repeat (200) @(posedge clk);
        
        // End simulation
        $finish;
    end
    
    // Add VCD waveform dumping for better debugging
    initial begin
        $dumpfile("riscv_processor.vcd");
        $dumpvars(0, Top_Module_tb);
        $display("VCD waveform dumping enabled...");
    end
    
    // More comprehensive monitoring
    initial begin
        // Print header
        $display("==== RISC-V Processor Simulation ====");
        
        // Monitor key signals, focusing on control signals that might have Z values
        $monitor("Time=%0t | Reset=%b | PC=%h | Instr=%h | RegWriteD=%b | MemReadE=%b | ALUOp=%b | ResultSrc=%b | ForwardA=%b ForwardB=%b",
                 $time, reset, dut.PCF, dut.InstrF, dut.RegWriteD, dut.MemReadE, 
                 dut.ALUOpD, dut.ResultSrcD, dut.ForwardA, dut.ForwardB);
    end
    
    // Custom display for tracking pipeline progression
    integer cycle_count = 0;
    always @(posedge clk) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;
            // Print pipeline status every 10 cycles
            if (cycle_count % 10 == 0) begin
                $display("Cycle %0d | InstrF=%h | InstrD=%h | RdE=%d | RdM=%d | RdW=%d",
                        cycle_count, dut.InstrF, dut.InstrD, dut.RdE, dut.RdM, dut.RdW);
            end
        end
    end
endmodule