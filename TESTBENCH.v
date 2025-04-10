`timescale 1ns/1ps
module Top_Module_tb();
    reg clk;
    reg reset;
    reg clear;
    wire ERROR;
    wire zero;
    
    // Instruction counter for tracking progress
    integer instr_count;
    
    
    // Variables for tracking the last instruction
    reg last_instr_detected;
    integer nop_cycles;
    reg [31:0] last_instr;
    reg force_nop;
    
    // Instantiate the design under test
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
        forever #5 clk = ~clk;
    end
    
    // Force NOP when needed
    always @(*) begin
        if (force_nop) begin
            // Force InstrF to NOP (32'h0) using force/release
            force dut.InstrF = 32'h0;
        end else begin
            // Make sure InstrF is not forced
            release dut.InstrF;
        end
    end
    
    // Test sequence - modified to run through all instructions and then 5 NOPs
    initial begin
        reset = 1;
        clear = 0;
        instr_count = 0;
        last_instr_detected = 0;
        nop_cycles = 0;
        force_nop = 0;
        
        // Get the last instruction from memory
        last_instr = dut.IMEM.RAM[dut.IMEM.i-1]; // The last instruction loaded
        $display("Last instruction in HEX file: 0x%h at index %0d", last_instr, dut.IMEM.i-1);
        
        repeat (5) @(posedge clk);
        
        @(posedge clk);
        reset = 0;
        
        // Wait until we've had 10 NOP cycles after the last instruction
        wait(nop_cycles >= 10);
        
        $display("Simulation ended at time %0t", $time);
        $display("Successfully completed execution with 10 NOPs after the last instruction!");
        $finish;
    end
    
    // Track instruction execution and progress
    // This block counts unique instruction addresses to determine progress
    integer last_pc;
    integer unique_pc_count;
    
    initial begin
        last_pc = -4; // Initialize to a value not matching any PC
        unique_pc_count = 0;
    end
    
    always @(posedge clk) begin
        if (!reset && dut.InstrF != 32'h0) begin
            // Count unique PC addresses to track instruction execution progress
            if (dut.PCF != last_pc) begin
                unique_pc_count = unique_pc_count + 1;
                last_pc = dut.PCF;
                
                // Display progress every 64 instructions
                if (unique_pc_count % 64 == 0) begin
                    $display("Progress: Executed %0d instructions so far", unique_pc_count);
                end
            end
            
            // Check if we have reached the last instruction
            if (!last_instr_detected && dut.InstrF == last_instr) begin
                $display("Last instruction detected at time %0t, PC=0x%h", $time, dut.PCF);
                last_instr_detected = 1;
            end
        end
        
        // Once last instruction is detected, start counting NOP cycles
        if (last_instr_detected && !reset) begin
            force_nop = 1;
            nop_cycles = nop_cycles + 1;
            $display("Injecting NOP cycle %0d at time %0t", nop_cycles, $time);
        end
    end
    
    // Monitor all pipeline stages
    initial begin
        $display("Starting simulation - monitoring all pipeline stages");
        $display("==================================================");
    end
    
    // Monitor Fetch Stage
    always @(posedge clk) begin
        if (!reset) begin
            $display("\n[%0t] --- Clock Cycle ---", $time);
            $display("FETCH STAGE:");
            $display("  PCF: 0x%h", dut.PCF);
            $display("  InstrF: 0x%h", dut.InstrF);
            $display("  pc_plus4F: 0x%h", dut.pc_plus4F);
            $display("  StallF: %b", dut.StallF);
            $display("  next_pc: 0x%h", dut.next_pc);
            
            if (force_nop) begin
                $display("  FORCED NOP ACTIVE (%0d of 5)", nop_cycles);
            end
        end
    end
    
    // Monitor Decode Stage
    always @(posedge clk) begin
        if (!reset) begin
            $display("DECODE STAGE:");
            $display("  PCD: 0x%h", dut.PCD);
            $display("  InstrD: 0x%h", dut.InstrD);
            $display("  pc_plus4D: 0x%h", dut.pc_plus4D);
            $display("  RD1D: 0x%h", dut.RD1D);
            $display("  RD2D: 0x%h", dut.RD2D);
            $display("  ImmExtD: 0x%h", dut.ImmExtD);
            $display("  ImmSrc: %b", dut.ImmSrc);  // Added ImmSrc monitoring
            $display("  Rs1D: %d", dut.InstrD[19:15]);
            $display("  Rs2D: %d", dut.InstrD[24:20]);
            $display("  RdD: %d", dut.InstrD[11:7]);
            $display("  Control Signals: RegWriteD=%b, MemWriteD=%b, BranchD=%b, JumpD=%b", 
                     dut.RegWriteD, dut.MemWriteD, dut.BranchD, dut.JumpD);
            $display("  ALUOp: %b", dut.ALUOpD);  // Added ALUOp monitoring
            $display("  FlushD: %b, StallD: %b", dut.FlushD, dut.StallD);
        end
    end
    
    // Monitor Execute Stage
    always @(posedge clk) begin
        if (!reset) begin
            $display("EXECUTE STAGE:");
            $display("  PCE: 0x%h", dut.PCE);
            $display("  pc_plus4E: 0x%h", dut.pc_plus4E);
            $display("  RD1E: 0x%h", dut.RD1E);
            $display("  RD2E: 0x%h", dut.RD2E);
            $display("  Rs1E: %d", dut.Rs1E);
            $display("  Rs2E: %d", dut.Rs2E);
            $display("  RdE: %d", dut.RdE);
            $display("  ImmExtE: 0x%h", dut.ImmExtE);
            $display("  ForwardedA: 0x%h", dut.ForwardedA);
            $display("  ForwardedB: 0x%h", dut.ForwardedB);
            $display("  ALUInputA: 0x%h", dut.ALUInputA);
            $display("  ALUInputB: 0x%h", dut.ALUInputB);
            $display("  ALUControlE: %b", dut.ALUControlE);
            $display("  ALUOpE: %b", dut.ALUOpE);  // Added ALUOpE monitoring
            $display("  ALUResultE: 0x%h", dut.ALUResultE);
            $display("  funct3E: %b", dut.funct3E);  // Added funct3E monitoring
            $display("  branch_taken: %b", dut.branch_taken);
            $display("  branch_jump_target: 0x%h", dut.branch_jump_target);
            $display("  Control Signals: RegWriteE=%b, MemWriteE=%b, BranchE=%b, JumpE=%b", 
                     dut.RegWriteE, dut.MemWriteE, dut.BranchE, dut.JumpE);
            $display("  ForwardA: %b, ForwardB: %b, FlushE: %b", 
                     dut.ForwardA, dut.ForwardB, dut.FlushE);
        end
    end
    
    // Monitor Memory Stage
    always @(posedge clk) begin
        if (!reset) begin
            $display("MEMORY STAGE:");
            $display("  ALUResultM: 0x%h", dut.ALUResultM);
            $display("  WriteDataM: 0x%h", dut.WriteDataM);
            $display("  RdM: %d", dut.RdM);
            $display("  ReadDataM: 0x%h", dut.ReadDataM);
            $display("  pc_plus4M: 0x%h", dut.pc_plus4M);
            $display("  Control Signals: RegWriteM=%b, MemWriteM=%b, MemReadM=%b", 
                     dut.RegWriteM, dut.MemWriteM, dut.MemReadM);
            $display("  ResultSrcM: %b", dut.ResultSrcM);
        end
    end
    
    // Monitor Writeback Stage
    always @(posedge clk) begin
        if (!reset) begin
            $display("WRITEBACK STAGE:");
            $display("  ALUResultW: 0x%h", dut.ALUResultW);
            $display("  ReadDataW: 0x%h", dut.ReadDataW);
            $display("  pc_plus4W: 0x%h", dut.pc_plus4W);
            $display("  RdW: %d", dut.RdW);
            $display("  ResultW: 0x%h", dut.ResultW);
            $display("  Control Signals: RegWriteW=%b, ResultSrcW=%b", 
                     dut.RegWriteW, dut.ResultSrcW);
        end
    end
    
    // Monitor Register File
    integer i;
    always @(posedge clk) begin
        if (!reset) begin
            $display("REGISTER FILE VALUES:");
            for (i = 0; i < 8; i = i + 1) begin
                $display("  x%0d: 0x%h  x%0d: 0x%h  x%0d: 0x%h  x%0d: 0x%h", 
                         i, dut.RegisterFile.rf[i], 
                         i+8, dut.RegisterFile.rf[i+8], 
                         i+16, dut.RegisterFile.rf[i+16], 
                         i+24, dut.RegisterFile.rf[i+24]);
            end
        end
    end
    
    // Monitor Hazard Unit
    always @(posedge clk) begin
        if (!reset) begin
            $display("HAZARD UNIT:");
            $display("  pc_select: %b", dut.pc_select);
            $display("  StallF: %b, StallD: %b", dut.StallF, dut.StallD);
            $display("  FlushD: %b, FlushE: %b", dut.FlushD, dut.FlushE);
            $display("  ForwardA: %b, ForwardB: %b", dut.ForwardA, dut.ForwardB);
            $display("  LoadUseHazard: %b", dut.hazard_unit.LoadUseHazard);  // Added LoadUseHazard monitoring
        end
    end

    // Monitor ALL Data Memory locations (all 64 entries)
    always @(posedge clk) begin
        if (!reset) begin
            $display("DATA MEMORY (all 64 locations):");
            for (i = 0; i < 64; i = i + 4) begin
                $display("  MEM[%2d]: 0x%h  MEM[%2d]: 0x%h  MEM[%2d]: 0x%h  MEM[%2d]: 0x%h", 
                         i, dut.Dmem.RAM[i], 
                         i+1, dut.Dmem.RAM[i+1], 
                         i+2, dut.Dmem.RAM[i+2], 
                         i+3, dut.Dmem.RAM[i+3]);
            end
        end
    end
    
    // Optional: Track instruction execution
    always @(posedge clk) begin
        if (!reset && dut.InstrF != 32'h0) begin
            case (dut.InstrF[6:0])
                7'b0110011: $display("Instr: R-type at PC=0x%h, Instr=0x%h", dut.PCF, dut.InstrF);
                7'b0010011: $display("Instr: I-type at PC=0x%h, Instr=0x%h", dut.PCF, dut.InstrF);
                7'b0000011: $display("Instr: Load at PC=0x%h, Instr=0x%h", dut.PCF, dut.InstrF);
                7'b0100011: $display("Instr: Store at PC=0x%h, Instr=0x%h", dut.PCF, dut.InstrF);
                7'b1100011: $display("Instr: Branch at PC=0x%h, Instr=0x%h", dut.PCF, dut.InstrF);
                7'b1101111: $display("Instr: JAL at PC=0x%h, Instr=0x%h", dut.PCF, dut.InstrF);
                7'b1100111: $display("Instr: JALR at PC=0x%h, Instr=0x%h", dut.PCF, dut.InstrF);
                7'b0110111: $display("Instr: LUI at PC=0x%h, Instr=0x%h", dut.PCF, dut.InstrF);
                7'b0010111: $display("Instr: AUIPC at PC=0x%h, Instr=0x%h", dut.PCF, dut.InstrF);
                default: $display("Instr: Unknown at PC=0x%h, Instr=0x%h", dut.PCF, dut.InstrF);
            endcase
        end
    end
    
    // Monitor branch-specific signals when branch instructions are executed
    always @(posedge clk) begin
        if (!reset && dut.InstrD[6:0] == 7'b1100011) begin
            $display("BRANCH ANALYSIS (Decode Stage):");
            $display("  Branch instruction: 0x%h", dut.InstrD);
            $display("  Immediate value: 0x%h", dut.ImmExtD);
            $display("  BranchD: %b", dut.BranchD);
            $display("  Rs1D value: 0x%h, Rs2D value: 0x%h", dut.RD1D, dut.RD2D);
        end
        
        if (!reset && dut.BranchE) begin
            $display("BRANCH ANALYSIS (Execute Stage):");
            $display("  BranchE: %b", dut.BranchE);
            $display("  branch_taken: %b", dut.branch_taken);
            $display("  ALUResultE: 0x%h", dut.ALUResultE);
            $display("  PC: 0x%h, Target: 0x%h", dut.PCE, dut.branch_jump_target);
            $display("  pc_select: %b", dut.pc_select);
        end
    end
    
    // Add a timeout in case simulation gets stuck
    initial begin
        // Set a timeout limit (much longer to accommodate all instructions)
        #20000000; // 5ms should be more than enough
        $display("SIMULATION TIMEOUT - Did not complete in the allotted time");
        $finish;
    end
endmodule