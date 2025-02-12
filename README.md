
RISC-V 5-Stage Pipelined Processor  

Language: Verilog/HDL  
Verification Tools: Xilinx Vivado, Icarus Verilog (EDA Playground)  

---

Overview  

This project implements a 5-stage pipelined RISC-V processor compliant with the RV32I base instruction set. It features hazard resolution, dynamic branch prediction, and a complete data path from Fetch to Writeback. The design emphasizes modularity for educational clarity and includes test cases for arithmetic, memory, and control-flow instructions.
THE BPU, HAZARD UNIT and many more are first timers and are a fruit of my imagination!

---

Key Features  

Pipeline Stages: Fetch (F), Decode (D), Execute (E), Memory (M), Writeback (W)  

Hazard Handling:  
- Forwarding: Resolves RAW hazards by bypassing results from later stages  
- Stalls: Detects load-use dependencies and pipeline conflicts  

Branch Prediction:  
- 2-Bit Dynamic Predictor with 16-entry Branch Target Buffer (BTB)  
- Pipeline flush on mispredictions  

Memory Subsystem:  
- Instruction Memory (IMEM): 128-byte ROM with preloaded test code  
- Data Memory: 256-byte RAM for load/store operations  

---

Pipeline Architecture  

Stage | Key (but not all) Components | Functionality  
------|---------------|--------------  
Fetch | PC Stall Unit, IMEM, next pc mux | Fetches instructions and computes next PC  
Decode | reg file, Main Decoder, ImmGen | Decodes instructions, reads registers  
Execute | ALU, Forwarding Unit, BPU | Executes ALU operations, predicts branches  
Memory | Data Memory | Handles lw/sw memory access  
Writeback | result mux | Writes results to registers  

---

Core Components  

1. Fetch Stage  
- PC Stall Unit: Manages PC updates and stalls during hazards  
- IMEM: Preloaded with test instructions (addi, beq, jal)  
- next pc mux: Selects next PC (PC+4 or branch target from Hazard Unit)  

2. Decode Stage  
- reg file: 32-register file with read/write ports (x0 hardwired to zero)  
- Main Decoder: Generates control signals (RegWriteD, MemWriteD, etc.)  
- ImmGen: Sign-extends immediates for I/S/B/U/J-type instructions  

3. Execute Stage  
- ALU: Supports arithmetic, logical, and comparison operations  
- Forwarding Unit: Resolves RAW hazards using results from Memory/Writeback stages  
- BPU: Predicts branches via a 2-bit saturating counter and BTB  

4. Memory Stage  
- Data Memory: 256-byte RAM for lw (load) and sw (store) operations  

5. Writeback Stage  
- result mux: Selects writeback source (ALU result, memory data, or PC+4)  

---

Hazard Resolution  

Forwarding Paths:  
- Execute to Execute: For back-to-back dependent instructions  
- Memory to Execute: For ALU dependencies after loads  

Stall Logic: Freezes Fetch/Decode stages during load-use hazards  

---

Branch Prediction  

- 2-Bit Saturating Counter: Predicts Taken (T) or Not Taken (NT) based on historical outcomes  
- Branch Target Buffer (BTB): Caches 16 branch targets for fast redirection  
- Misprediction Recovery: Flushes pipeline and updates PC via Hazard Unit  

---

Memory Specifications  

Component | Size | Description  
---------|------|------------  
IMEM | 128 bytes | Stores test instructions (32 x 4-byte)  
Data | 256 bytes | Supports word-aligned lw/sw operations  

---

Verification  

Tools: Validated using Xilinx Vivado (waveform analysis) and Icarus Verilog (EDA Playground)  

Test Coverage:  
- Arithmetic (addi, sub, and)  
- Memory (lw, sw with RAW hazard checks)  
- Control flow (beq, jal with branch prediction logs)  

---

Design Limitations  

- No support for exceptions or interrupts  
- Basic branch prediction (no correlation-based logic)  

---

Future Extensions  

- ISA Extensions: Multiply/Divide (M), Atomic (A)  
- Advanced Branch Prediction: TAGE or perceptron-based predictors  
- Cache Hierarchy: L1 instruction/data caches  

---

Developed By: Matan Yemini  

