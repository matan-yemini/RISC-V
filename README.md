
---

# RISC-V 5-Stage Pipeline Processor in Verilog

This project implements a 5-stage pipelined RISC-V processor in Verilog. It includes a full hazard-handling mechanism, a forwarding unit, and a complete testbench for simulation. A Python-based instruction generator produces randomized instruction sets, which are loaded into instruction memory for execution. The project features waveform output (.wfcg) and TCL console logs for deep debugging and pipeline analysis.

---

## Table of Contents

- Project Overview  
- Architecture  
- Hazard Handling  
- Forwarding Logic  
- Testbench & Simulation  
- Python Instruction Generator  
- Outputs  
- YouTube Playlist  
- Getting Started  
- License

---

## Project Overview

This repository contains:
- A full 5-stage RISC-V processor in Verilog (RISC_V_TOP_MODULE.v)
- A hazard detection unit and forwarding unit for pipeline stability
- A Verilog testbench (TESTBENCH.v) simulating reset and instruction execution cycles
- A Python generator for creating and validating randomized instructions
- Sample output files: waveform (.wfcg) and TCL console logs
- A detailed YouTube playlist explaining the entire design and implementation

The final presentation and complete waveform file are located inside the "other" folder.

---

## Architecture

The processor follows the classical 5-stage RISC-V pipeline:
1. Instruction Fetch (IF)
2. Instruction Decode (ID)
3. Execute (EX)
4. Memory Access (MEM)
5. Write Back (WB)

Each stage is modular and communicates via pipeline registers.

---

## Hazard Handling

The processor includes a Hazard Unit designed to handle all three types of hazards:

- Data Hazards: Detected and resolved via forwarding or stalling  
- Control Hazards: Resolved using pipeline flushing on branches  
- Structural Hazards: Prevented by managing access to shared resources  

---

## Forwarding Logic

A dedicated Forwarding Unit is implemented to:
- Detect data dependencies between instructions
- Forward results from EX/MEM/WB stages to earlier stages
- Eliminate unnecessary stalls for efficient pipeline flow

---

## Testbench & Simulation

The Verilog testbench (TESTBENCH.v) performs:
- 5 cycles of reset
- 10 instruction cycles for full pipeline traversal
- Observes instruction flow, register updates, and memory access

All output can be observed using:
- Waveform viewer via .wfcg file (see "other" folder)
- TCL console for debugging and real-time signal monitoring

---

## Python Instruction Generator

The included Python script:
- Randomly generates valid RISC-V instructions
- Validates the instruction set logic
- Simulates expected behavior
- Exports to .hex file
- Automatically loads into instruction memory for Verilog simulation

This ensures robust, randomized, and repeatable testing for the processor.

---

## Outputs

Waveform (.wfcg):
- Shows internal signal transitions and instruction movement across pipeline stages
- Helpful for debugging hazards, stalls, and forwarding behavior
- Included in the "other" folder

TCL Console:
- Live simulation logging
- Real-time updates of registers, memory, and control signals
- Useful for verifying correct behavior and debugging bugs

---

## YouTube Playlist

Watch the full explanation and walkthrough series here:  
1. [Introduction to RISC-V](https://www.youtube.com/watch?v=EwhaIYauKxE&list=PLgCz5alrQkyYZDYsZJtKFA_6z0v5epQhm&index=1)  
2. [Understanding the Architecture](https://www.youtube.com/watch?v=zLUKpBSjDa0&list=PLgCz5alrQkyYZDYsZJtKFA_6z0v5epQhm&index=2)  
3. [Hazard Unit (Data, Control, Structural)](https://www.youtube.com/watch?v=LexZLpl8oOU&list=PLgCz5alrQkyYZDYsZJtKFA_6z0v5epQhm&index=3)  
4. [Verilog Implementation – Part 1](https://www.youtube.com/watch?v=ndFy600LRRE&list=PLgCz5alrQkyYZDYsZJtKFA_6z0v5epQhm&index=4)  
5. [Verilog Implementation – Part 2 + Top Module](https://www.youtube.com/watch?v=up8JKAD2EOs&list=PLgCz5alrQkyYZDYsZJtKFA_6z0v5epQhm&index=5)  
6. [Testbench, Simulation, Waveform (.wfcg), TCL Console](https://www.youtube.com/watch?v=1XQGZZsroxM)  

---

## Getting Started

### Prerequisites

- Verilog simulator (e.g., ModelSim, Icarus Verilog)  
- Python 3.x  
- Waveform viewer that supports .wfcg format  

### Run Instructions

```bash
# Step 1: Generate instruction hex file
python3 generate_instructions.py

# Step 2: Compile Verilog sources
iverilog -o riscv_tb RISC_V_TOP_MODULE.v TESTBENCH.v

# Step 3: Run simulation
vvp riscv_tb

# Step 4 (Optional): Open waveform
# Use ModelSim or another tool to open the .wfcg waveform file in the "other" folder
```

---

## License

This project is licensed under the MIT License.

---

