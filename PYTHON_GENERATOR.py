import random


def generate_riscv_instruction(input_type):
    """
    Generate random RISC-V instruction based on input type

    Args:
        input_type (int): 0 for any instruction,
                          1 for save,
                          2 for i-type,
                          3 for load,
                          4 for branch,
                          5 for jump,
                          6 for r-type

    Returns:
        tuple: (assembly_instruction, hex_representation, instruction_type)
    """

    registers = [f"x{i}" for i in range(32)]

    # Define functions for different instruction types
    def generate_r_type():
        opcode = "0110011"
        r_instructions = {
            "add": {"funct3": "000", "funct7": "0000000"},
            "sub": {"funct3": "000", "funct7": "0100000"},
            "xor": {"funct3": "100", "funct7": "0000000"},
            "or": {"funct3": "110", "funct7": "0000000"},
            "and": {"funct3": "111", "funct7": "0000000"},
            "sll": {"funct3": "001", "funct7": "0000000"},
            "srl": {"funct3": "101", "funct7": "0000000"},
            "sra": {"funct3": "101", "funct7": "0100000"},
            "slt": {"funct3": "010", "funct7": "0000000"},
            "sltu": {"funct3": "011", "funct7": "0000000"}
        }

        instr_name = random.choice(list(r_instructions.keys()))
        rd = random.choice(registers)
        rs1 = random.choice(registers)
        rs2 = random.choice(registers)

        # Format: funct7 + rs2 + rs1 + funct3 + rd + opcode
        funct7 = r_instructions[instr_name]["funct7"]
        funct3 = r_instructions[instr_name]["funct3"]

        # Get register numbers
        rd_num = int(rd[1:])
        rs1_num = int(rs1[1:])
        rs2_num = int(rs2[1:])

        # Binary representation
        rd_bin = format(rd_num, '05b')
        rs1_bin = format(rs1_num, '05b')
        rs2_bin = format(rs2_num, '05b')

        binary = funct7 + rs2_bin + rs1_bin + funct3 + rd_bin + opcode

        # Convert to hex
        hex_representation = format(int(binary, 2), '08x')

        # Assembly representation
        assembly = f"{instr_name} {rd}, {rs1}, {rs2}"

        return assembly, hex_representation, "r-type"

    def generate_i_type():
        i_instructions = {
            "addi": {"opcode": "0010011", "funct3": "000", "is_shift": False},
            "xori": {"opcode": "0010011", "funct3": "100", "is_shift": False},
            "ori": {"opcode": "0010011", "funct3": "110", "is_shift": False},
            "andi": {"opcode": "0010011", "funct3": "111", "is_shift": False},
            "slli": {"opcode": "0010011", "funct3": "001", "is_shift": True, "funct7": "0000000"},
            "srli": {"opcode": "0010011", "funct3": "101", "is_shift": True, "funct7": "0000000"},
            "srai": {"opcode": "0010011", "funct3": "101", "is_shift": True, "funct7": "0100000"},
            "slti": {"opcode": "0010011", "funct3": "010", "is_shift": False},
            "sltiu": {"opcode": "0010011", "funct3": "011", "is_shift": False}
        }

        instr_name = random.choice(list(i_instructions.keys()))
        rd = random.choice(registers)
        rs1 = random.choice(registers)

        # Format depends on instruction type
        opcode = i_instructions[instr_name]["opcode"]
        funct3 = i_instructions[instr_name]["funct3"]
        is_shift = i_instructions[instr_name]["is_shift"]

        # Get register numbers
        rd_num = int(rd[1:])
        rs1_num = int(rs1[1:])
        rd_bin = format(rd_num, '05b')
        rs1_bin = format(rs1_num, '05b')

        # Special handling for shift instructions
        if is_shift:
            # For shift instructions, immediate is only 5 bits (0-31)
            imm = random.randint(0, 31)
            imm_bin = format(imm, '05b')
            funct7 = i_instructions[instr_name]["funct7"]

            # Format: funct7 + imm[4:0] + rs1 + funct3 + rd + opcode
            binary = funct7 + imm_bin + rs1_bin + funct3 + rd_bin + opcode
        else:
            # For regular I-type instructions, immediate is 12 bits
            imm = random.randint(0, 63)  # Limit immediate to memory range
            imm_bin = format(imm, '012b')

            # Format: imm[11:0] + rs1 + funct3 + rd + opcode
            binary = imm_bin + rs1_bin + funct3 + rd_bin + opcode

        # Convert to hex
        hex_representation = format(int(binary, 2), '08x')

        # Assembly representation
        assembly = f"{instr_name} {rd}, {rs1}, {imm}"

        return assembly, hex_representation, "i-type"

    def generate_load():
        opcode = "0000011"
        load_instructions = {
            "lw": {"funct3": "010"},
        }

        instr_name = random.choice(list(load_instructions.keys()))
        rd = random.choice(registers)
        rs1 = random.choice(registers)
        imm = random.randint(0, 252)  # Limit immediate to memory range

        # Format: imm[11:0] + rs1 + funct3 + rd + opcode
        funct3 = load_instructions[instr_name]["funct3"]

        # Get register numbers
        rd_num = int(rd[1:])
        rs1_num = int(rs1[1:])

        # Binary representation
        imm_bin = format(imm, '012b')
        rd_bin = format(rd_num, '05b')
        rs1_bin = format(rs1_num, '05b')

        binary = imm_bin + rs1_bin + funct3 + rd_bin + opcode

        # Convert to hex
        hex_representation = format(int(binary, 2), '08x')

        # Assembly representation
        assembly = f"{instr_name} {rd}, {imm}({rs1})"

        return assembly, hex_representation, "load"

    def generate_save():
        opcode = "0100011"
        save_instructions = {
            "sw": {"funct3": "010"}
        }

        instr_name = random.choice(list(save_instructions.keys()))
        rs1 = random.choice(registers)
        rs2 = random.choice(registers)
        imm = random.randint(0, 252)  # Limit immediate to memory range

        # Format: imm[11:5] + rs2 + rs1 + funct3 + imm[4:0] + opcode
        funct3 = save_instructions[instr_name]["funct3"]

        # Get register numbers
        rs1_num = int(rs1[1:])
        rs2_num = int(rs2[1:])

        # Binary representation
        imm_bin = format(imm, '012b')
        imm_high = imm_bin[:7]
        imm_low = imm_bin[7:]
        rs1_bin = format(rs1_num, '05b')
        rs2_bin = format(rs2_num, '05b')

        binary = imm_high + rs2_bin + rs1_bin + funct3 + imm_low + opcode

        # Convert to hex
        hex_representation = format(int(binary, 2), '08x')

        # Assembly representation
        assembly = f"{instr_name} {rs2}, {imm}({rs1})"

        return assembly, hex_representation, "save"

    def generate_branch():
        opcode = "1100011"
        branch_instructions = {
            "beq": {"funct3": "000"},
            "bne": {"funct3": "001"},
            "blt": {"funct3": "100"},
            "bge": {"funct3": "101"},
            "bltu": {"funct3": "110"},
            "bgeu": {"funct3": "111"}
        }

        instr_name = random.choice(list(branch_instructions.keys()))
        rs1 = random.choice(registers)
        rs2 = random.choice(registers)

        # Generate a random immediate value divisible by 4, starting from 8 (not 0 or 4)
        imm_raw = random.randint(2, 15) * 4  # This generates 8, 12, 16, ..., 60

        # Format: imm[12] + imm[10:5] + rs2 + rs1 + funct3 + imm[4:1] + imm[11] + opcode
        funct3 = branch_instructions[instr_name]["funct3"]

        # Get register numbers
        rs1_num = int(rs1[1:])
        rs2_num = int(rs2[1:])

        # Binary representation (simplified for our purposes)
        imm_bin = format(imm_raw, '013b')
        imm_12 = imm_bin[0]
        imm_10_5 = imm_bin[2:8]
        imm_4_1 = imm_bin[8:12]
        imm_11 = imm_bin[1]

        rs1_bin = format(rs1_num, '05b')
        rs2_bin = format(rs2_num, '05b')

        binary = imm_12 + imm_10_5 + rs2_bin + rs1_bin + funct3 + imm_4_1 + imm_11 + opcode

        # Convert to hex
        hex_representation = format(int(binary, 2), '08x')

        # Assembly representation
        assembly = f"{instr_name} {rs1}, {rs2}, {imm_raw}"

        return assembly, hex_representation, "branch"

    def generate_jump():
        opcode = "1101111"
        instr_name = "jal"
        rd = random.choice(registers)

        # Generate a random immediate value divisible by 4, starting from 8 (not 0 or 4)
        imm_raw = random.randint(2, 15) * 4  # This generates 8, 12, 16, ..., 60

        # Format: imm[20] + imm[10:1] + imm[11] + imm[19:12] + rd + opcode

        # Get register number
        rd_num = int(rd[1:])

        # Binary representation (simplified for our purposes)
        imm_bin = format(imm_raw, '021b')
        imm_20 = imm_bin[0]
        imm_10_1 = imm_bin[10:20]
        imm_11 = imm_bin[9]
        imm_19_12 = imm_bin[1:9]

        rd_bin = format(rd_num, '05b')

        binary = imm_20 + imm_10_1 + imm_11 + imm_19_12 + rd_bin + opcode

        # Convert to hex
        hex_representation = format(int(binary, 2), '08x')

        # Assembly representation
        assembly = f"{instr_name} {rd}, {imm_raw}"

        return assembly, hex_representation, "jump"

    # Handle input type
    if input_type == 0:
        # Generate any instruction type
        generators = [
            generate_r_type,
            generate_i_type,
            generate_load,
            generate_save,
            generate_branch,
            generate_jump
        ]
        return random.choice(generators)()

    elif input_type == 1:
        # Generate only save instruction
        return generate_save()

    elif input_type == 2:
        # Generate only i-type instruction
        return generate_i_type()

    elif input_type == 3:
        # Generate only load instruction
        return generate_load()

    elif input_type == 4:
        # Generate only branch instruction
        return generate_branch()

    elif input_type == 5:
        # Generate only jump instruction
        return generate_jump()

    elif input_type == 6:
        # Generate only R-type instruction
        return generate_r_type()

    else:
        raise ValueError("Input type must be 0, 1, 2, 3, 4, 5, or 6")


def simulate_instruction(validation_code, hex_code, assembly_code, registers, memory):
    """
    Simulates the execution of a RISC-V instruction by updating registers and memory state.
    Only executes if validation_code is 6 (valid instruction).

    Args:
        validation_code (int): Validation code (6 means valid)
        hex_code (str): Hexadecimal representation of the instruction
        assembly_code (str): Assembly representation of the instruction
        registers (dict): Dictionary with register values to be updated
        memory (dict): Dictionary with memory values to be updated

    Returns:
        bool: True if instruction was executed, False otherwise
    """
    # Only execute valid instructions
    if validation_code != 6:
        return False

    # Convert hex to binary for analysis
    binary = bin(int(hex_code, 16))[2:].zfill(32)

    # Extract opcode (last 7 bits)
    opcode = binary[-7:]

    # Special handling for register x0 which is always 0 in RISC-V
    registers['x0'] = 0

    # R-type instructions (register-register operations)
    if opcode == "0110011":
        # Extract fields
        funct7 = binary[0:7]
        rs2 = int(binary[7:12], 2)
        rs1 = int(binary[12:17], 2)
        funct3 = binary[17:20]
        rd = int(binary[20:25], 2)

        # Register names
        rs1_name = f"x{rs1}"
        rs2_name = f"x{rs2}"
        rd_name = f"x{rd}"

        # Skip if destination is x0 (always 0 in RISC-V)
        if rd_name == "x0":
            return True

        # Get source register values
        rs1_value = registers.get(rs1_name, 0)
        rs2_value = registers.get(rs2_name, 0)

        # Perform operation based on funct3 and funct7
        result = 0

        # ADD or SUB
        if funct3 == "000":
            if funct7 == "0000000":  # ADD
                result = rs1_value + rs2_value
            elif funct7 == "0100000":  # SUB
                result = rs1_value - rs2_value
        # XOR
        elif funct3 == "100":
            result = rs1_value ^ rs2_value
        # OR
        elif funct3 == "110":
            result = rs1_value | rs2_value
        # AND
        elif funct3 == "111":
            result = rs1_value & rs2_value
        # SLL (Shift Left Logical)
        elif funct3 == "001":
            result = rs1_value << (rs2_value & 0x1F)  # Only use bottom 5 bits for shift
        # SRL/SRA (Shift Right Logical/Arithmetic)
        elif funct3 == "101":
            shift_amt = rs2_value & 0x1F  # Only use bottom 5 bits for shift
            if funct7 == "0000000":  # SRL
                result = (rs1_value & 0xFFFFFFFF) >> shift_amt
            elif funct7 == "0100000":  # SRA
                # המר את rs1_value למחרוזת בינארית באורך 32 ביט
                rs1_value_temp = bin(rs1_value & 0xFFFFFFFF)[2:].zfill(32)

                # שמור את ה-MSB (ביט הסימן)
                msb = rs1_value_temp[0]

                # יצור מחרוזת לתוצאה
                temp = list(rs1_value_temp)

                # בצע הזזה ימינה אריתמטית
                # 1. הזז את כל הביטים ימינה ב-shift_amt מקומות
                # 2. מלא את הביטים העליונים עם ביט הסימן
                for i in range(31, shift_amt - 1, -1):
                    temp[i] = temp[i - shift_amt]

                # מלא את הביטים העליונים בביט הסימן
                for i in range(shift_amt):
                    temp[i] = msb

                # המר בחזרה למספר
                result = int(''.join(temp), 2) & 0xFFFFFFFF
        # SLT (Set Less Than)
        elif funct3 == "010":
            # Convert to signed 32-bit values
            signed_rs1 = rs1_value if (rs1_value & 0x80000000) == 0 else rs1_value - (1 << 32)
            signed_rs2 = rs2_value if (rs2_value & 0x80000000) == 0 else rs2_value - (1 << 32)
            result = 1 if (signed_rs1 < signed_rs2) else 0
        # SLTU (Set Less Than Unsigned)
        elif funct3 == "011":
            # Convert to unsigned 32-bit values
            unsigned_rs1 = rs1_value & 0xFFFFFFFF
            unsigned_rs2 = rs2_value & 0xFFFFFFFF
            result = 1 if (unsigned_rs1 < unsigned_rs2) else 0

        # Update destination register with 32-bit value
        registers[rd_name] = result & 0xFFFFFFFF

    # I-type instructions (immediate operations)
    elif opcode == "0010011":
        # Extract fields
        imm = int(binary[0:12], 2)
        # Sign extend if the most significant bit is 1
        if binary[0] == '1':
            imm = imm - (1 << 12)

        rs1 = int(binary[12:17], 2)
        funct3 = binary[17:20]
        rd = int(binary[20:25], 2)

        # Register names
        rs1_name = f"x{rs1}"
        rd_name = f"x{rd}"

        # Skip if destination is x0 (always 0 in RISC-V)
        if rd_name == "x0":
            return True

        # Get source register value
        rs1_value = registers.get(rs1_name, 0)

        # Perform operation based on funct3
        result = 0

        # ADDI
        if funct3 == "000":
            result = rs1_value + imm
        # XORI
        elif funct3 == "100":
            result = rs1_value ^ imm
        # ORI
        elif funct3 == "110":
            result = rs1_value | imm
        # ANDI
        elif funct3 == "111":
            result = rs1_value & imm
        # SLLI (Shift Left Logical Immediate)
        elif funct3 == "001":
            shift_amt = imm & 0x1F  # Only use bottom 5 bits for shift
            result = rs1_value << shift_amt
        # SRLI/SRAI (Shift Right Logical/Arithmetic Immediate)
        elif funct3 == "101":
            # Extract the shift amount (only lower 5 bits)
            shift_amt = imm & 0x1F

            # Check the funct7 field to determine if SRLI or SRAI
            # For I-type shifts, the top 7 bits of the immediate field act as funct7
            funct7_equiv = binary[0:7]

            # SRLI has funct7 = 0000000, SRAI has funct7 = 0100000
            # Check bit 30 (the 6th bit, or index 5 in zero-indexed)
            if funct7_equiv[5] == '0':  # SRLI
                result = (rs1_value & 0xFFFFFFFF) >> shift_amt
            else:  # SRAI
                # המר את rs1_value למחרוזת בינארית באורך 32 ביט
                rs1_value_temp = bin(rs1_value & 0xFFFFFFFF)[2:].zfill(32)

                # שמור את ה-MSB (ביט הסימן)
                msb = rs1_value_temp[0]

                # יצור מחרוזת לתוצאה
                temp = list(rs1_value_temp)

                # בצע הזזה ימינה אריתמטית
                # 1. הזז את כל הביטים ימינה ב-shift_amt מקומות
                # 2. מלא את הביטים העליונים עם ביט הסימן
                for i in range(31, shift_amt - 1, -1):
                    temp[i] = temp[i - shift_amt]

                # מלא את הביטים העליונים בביט הסימן
                for i in range(shift_amt):
                    temp[i] = msb

                # המר בחזרה למספר
                result = int(''.join(temp), 2) & 0xFFFFFFFF
        # SLTI (Set Less Than Immediate)
        elif funct3 == "010":
            # Convert to signed value
            signed_rs1 = rs1_value if (rs1_value & 0x80000000) == 0 else rs1_value - (1 << 32)
            # imm is already sign-extended
            result = 1 if (signed_rs1 < imm) else 0
        # SLTIU (Set Less Than Immediate Unsigned)
        elif funct3 == "011":
            # Convert to unsigned 32-bit values
            unsigned_rs1 = rs1_value & 0xFFFFFFFF
            unsigned_imm = imm & 0xFFFFFFFF
            result = 1 if (unsigned_rs1 < unsigned_imm) else 0

        # Update destination register with 32-bit value
        registers[rd_name] = result & 0xFFFFFFFF

    # Load instructions (I-type with different opcode)
    elif opcode == "0000011":
        # Extract fields
        imm = int(binary[0:12], 2)
        # Sign extend if the most significant bit is 1
        if binary[0] == '1':
            imm = imm - (1 << 12)

        rs1 = int(binary[12:17], 2)
        funct3 = binary[17:20]
        rd = int(binary[20:25], 2)

        # Register names
        rs1_name = f"x{rs1}"
        rd_name = f"x{rd}"

        # Skip if destination is x0 (always 0 in RISC-V)
        if rd_name == "x0":
            return True

        # Get base address from register
        base_addr = registers.get(rs1_name, 0)

        # Calculate memory address
        addr = ((base_addr + imm) // 4) & 0xFFFFFFFF

        # Load data based on funct3
        data = memory.get(addr, 0)

        # LW (Load Word)
        if funct3 == "010":
            registers[rd_name] = data


    # Store instructions (S-type)
    elif opcode == "0100011":
        # Extract fields
        imm_11_5 = binary[0:7]
        rs2 = int(binary[7:12], 2)
        rs1 = int(binary[12:17], 2)
        funct3 = binary[17:20]
        imm_4_0 = binary[20:25]

        # Reconstruct immediate value
        imm = int(imm_11_5 + imm_4_0, 2)
        # Sign extend if the most significant bit is 1
        if imm_11_5[0] == '1':
            imm = imm - (1 << 12)

        # Register names
        rs1_name = f"x{rs1}"
        rs2_name = f"x{rs2}"

        # Get source register values
        rs1_value = registers.get(rs1_name, 0)
        rs2_value = registers.get(rs2_name, 0)

        # Calculate memory address
        addr = ((rs1_value + imm) // 4) & 0xFFFFFFFF

        # Store data based on funct3
        if funct3 == "010":
            # Store the full word
            memory[addr] = rs2_value & 0xFFFFFFFF

    # Branch instructions (B-type)
    elif opcode == "1100011":
        # Extract fields
        imm_12 = binary[0]
        imm_10_5 = binary[1:7]
        rs2 = int(binary[7:12], 2)
        rs1 = int(binary[12:17], 2)
        funct3 = binary[17:20]
        imm_4_1 = binary[20:24]
        imm_11 = binary[24]

        # Reconstruct immediate value
        imm = int(imm_12 + imm_11 + imm_10_5 + imm_4_1 + "0", 2)
        # Sign extend if imm_12 is 1
        if imm_12 == '1':
            imm = imm - (1 << 13)

        # Register names
        rs1_name = f"x{rs1}"
        rs2_name = f"x{rs2}"

        # Get source register values
        rs1_value = registers.get(rs1_name, 0)
        rs2_value = registers.get(rs2_name, 0)

        # Current PC value
        pc = registers.get('pc', 0)

        # Evaluate branch condition based on funct3
        take_branch = False

        # BEQ (Branch if Equal)
        if funct3 == "000":
            take_branch = (rs1_value == rs2_value)
        # BNE (Branch if Not Equal)
        elif funct3 == "001":
            take_branch = (rs1_value != rs2_value)
        # BLT (Branch if Less Than)
        elif funct3 == "100":
            # Convert to signed values
            signed_rs1 = rs1_value if (rs1_value & 0x80000000) == 0 else rs1_value - (1 << 32)
            signed_rs2 = rs2_value if (rs2_value & 0x80000000) == 0 else rs2_value - (1 << 32)
            take_branch = (signed_rs1 < signed_rs2)
        # BGE (Branch if Greater or Equal)
        elif funct3 == "101":
            # Convert to signed values
            signed_rs1 = rs1_value if (rs1_value & 0x80000000) == 0 else rs1_value - (1 << 32)
            signed_rs2 = rs2_value if (rs2_value & 0x80000000) == 0 else rs2_value - (1 << 32)
            take_branch = (signed_rs1 >= signed_rs2)
        # BLTU (Branch if Less Than Unsigned)
        elif funct3 == "110":
            # Convert to unsigned 32-bit values
            unsigned_rs1 = rs1_value & 0xFFFFFFFF
            unsigned_rs2 = rs2_value & 0xFFFFFFFF
            take_branch = (unsigned_rs1 < unsigned_rs2)
        # BGEU (Branch if Greater or Equal Unsigned)
        elif funct3 == "111":
            # Convert to unsigned 32-bit values
            unsigned_rs1 = rs1_value & 0xFFFFFFFF
            unsigned_rs2 = rs2_value & 0xFFFFFFFF
            take_branch = (unsigned_rs1 >= unsigned_rs2)

        # Update PC if branch is taken
        if take_branch:
            registers['pc'] = (pc + imm) & 0xFFFFFFFF
        else:
            # In real hardware, PC would be incremented by 4, but we're simplifying
            registers['pc'] = (pc + 4) & 0xFFFFFFFF

    # Jump instructions (J-type)
    elif opcode == "1101111":
        # Extract fields
        imm_20 = binary[0]
        imm_10_1 = binary[1:11]
        imm_11 = binary[11]
        imm_19_12 = binary[12:20]
        rd = int(binary[20:25], 2)

        # Reconstruct immediate value
        imm = int(imm_20 + imm_19_12 + imm_11 + imm_10_1 + "0", 2)
        # Sign extend if imm_20 is 1
        if imm_20 == '1':
            imm = imm - (1 << 21)

        # Register name
        rd_name = f"x{rd}"

        # Current PC value
        pc = registers.get('pc', 0)

        # For JAL, save return address (PC+4) to rd
        if rd_name != "x0":
            registers[rd_name] = (pc + 4) & 0xFFFFFFFF

        # Update PC
        registers['pc'] = (pc + imm) & 0xFFFFFFFF

    # Add U-type instructions (LUI, AUIPC) and JALR if needed

    return True

def validate_instruction(hex_code, assembly_code, registers, memory):
    """
    Validates whether a RISC-V instruction is legal based on registers and memory state.

    Args:
        hex_code (str): Hexadecimal representation of the instruction
        assembly_code (str): Assembly representation of the instruction
        registers (dict): Dictionary with register values (e.g., {'x1': 10, 'x2': 20})
        memory (dict): Dictionary with memory values and limits
            Should contain 'min_addr' and 'max_addr' keys for memory bounds
            e.g., {'min_addr': 0, 'max_addr': 63, ...other memory values...}

    Returns:
        tuple: (validation_code, hex_code, assembly_code)
            validation_code:
                6 - Instruction is valid
                1 - Invalid S-type instruction (store address out of bounds)
                2 - Invalid I-type instruction (result would overflow 32 bits)
                3 - Invalid load instruction (load address out of bounds)
                4 - Invalid branch instruction (target address out of bounds)
                5 - Invalid jump instruction (target address out of bounds)
    """
    # Convert hex to binary for analysis
    binary = bin(int(hex_code, 16))[2:].zfill(32)

    # Extract opcode (last 7 bits)
    opcode = binary[-7:]

    # Memory bounds
    min_memory = memory.get('min_addr', 0)
    max_memory = memory.get('max_addr', 63)

    # Current program counter (default to 0 if not specified)
    pc = registers.get('pc', 0)

    # Parse different instruction types based on opcode

    # S-type instructions (store)
    if opcode == "0100011":
        # Extract fields
        imm_11_5 = binary[0:7]
        rs2 = int(binary[7:12], 2)
        rs1 = int(binary[12:17], 2)
        funct3 = binary[17:20]
        imm_4_0 = binary[20:25]

        # Reconstruct immediate value
        imm = int(imm_11_5 + imm_4_0, 2)
        # Sign extend if the most significant bit is 1
        if imm_11_5[0] == '1':
            imm = imm - (1 << 12)

        # Register names
        rs1_name = f"x{rs1}"
        rs2_name = f"x{rs2}"

        # Get base address from register
        base_addr = registers.get(rs1_name, 0)

        # Calculate target address
        target_addr = ((base_addr + imm) // 4) & 0xFFFFFFFF

        # Check if address is within bounds
        if target_addr < min_memory or target_addr > max_memory:
            return 1, hex_code, assembly_code

    # I-type instructions (immediate operations and loads)
    elif opcode == "0010011" or opcode == "0000011":
        # Extract fields
        imm = int(binary[0:12], 2)
        # Sign extend if the most significant bit is 1
        if binary[0] == '1':
            imm = imm - (1 << 12)

        rs1 = int(binary[12:17], 2)
        funct3 = binary[17:20]
        rd = int(binary[20:25], 2)

        # Register names
        rs1_name = f"x{rs1}"
        rd_name = f"x{rd}"

        # Load instructions (I-type with load opcode)
        if opcode == "0000011":
            # Get base address from register
            base_addr = registers.get(rs1_name, 0)

            # Calculate target address
            target_addr = ((base_addr + imm) //4) & 0xFFFFFFFF

            # Check if address is within bounds
            if target_addr < min_memory or target_addr > max_memory:
                return 3, hex_code, assembly_code

        # Regular I-type arithmetic instructions
        else:
            # Get source register value
            rs1_value = registers.get(rs1_name, 0)

            # Special handling for shift instructions
            if funct3 == "001" or funct3 == "101":  # SLLI, SRLI, SRAI
                # For shifts, make sure the shift amount is valid (0-31)
                shift_amt = imm & 0x1F  # Only lower 5 bits matter

                # For SRLI/SRAI (funct3 == "101"), check if the funct7 field is valid
                if funct3 == "101":
                    funct7_equiv = binary[0:7]
                    # Valid patterns are 0000000 (SRLI) and 0100000 (SRAI)
                    if funct7_equiv != "0000000" and funct7_equiv != "0100000":
                        return 2, hex_code, assembly_code
            else:
                # Perform operation based on funct3 to check for 32-bit overflow
                # This is simplified - actual operations would vary by funct3
                result = rs1_value + imm

                # Check for 32-bit overflow
                if result > 0xFFFFFFFF or result < -0x80000000:
                    return 2, hex_code, assembly_code

    # B-type instructions (branch)
    elif opcode == "1100011":
        # Extract fields
        imm_12 = binary[0]
        imm_10_5 = binary[1:7]
        rs2 = int(binary[7:12], 2)
        rs1 = int(binary[12:17], 2)
        funct3 = binary[17:20]
        imm_4_1 = binary[20:24]
        imm_11 = binary[24]

        # Reconstruct immediate value
        imm = int(imm_12 + imm_11 + imm_10_5 + imm_4_1 + "0", 2)
        # Sign extend if imm_12 is 1
        if imm_12 == '1':
            imm = imm - (1 << 13)

        # Calculate target address
        target_addr = pc + imm

        # Check if branch target is within bounds (assuming PC is 0-31)
        if target_addr < 0 or target_addr > 63:
            return 4, hex_code, assembly_code

    # J-type instructions (jump)
    elif opcode == "1101111":
        # Extract fields
        imm_20 = binary[0]
        imm_10_1 = binary[1:11]
        imm_11 = binary[11]
        imm_19_12 = binary[12:20]
        rd = int(binary[20:25], 2)

        # Reconstruct immediate value
        imm = int(imm_20 + imm_19_12 + imm_11 + imm_10_1 + "0", 2)
        # Sign extend if imm_20 is 1
        if imm_20 == '1':
            imm = imm - (1 << 21)

        # Calculate target address
        target_addr = pc + imm

        # Check if jump target is within bounds (assuming PC is 0-31)
        if target_addr < 0 or target_addr > 63:
            return 5, hex_code, assembly_code

    # If we get here, the instruction is valid
    return 6, hex_code, assembly_code


if __name__ == "__main__":
    # Initialize registers and memory with the given values
    registers = {
        'x0': 0x00000000, 'x8': 0x89375212, 'x16': 0xe33724c6, 'x24': 0xe77696ce,
        'x1': 0x12153524, 'x9': 0x00f3e301, 'x17': 0xe2f784c5, 'x25': 0xf4007ae8,
        'x2': 0xc0895e81, 'x10': 0x06d7cd0d, 'x18': 0xd513d2aa, 'x26': 0xe2ca4ec5,
        'x3': 0x8484d609, 'x11': 0x3b23f176, 'x19': 0x72aff7e5, 'x27': 0x2e58495c,
        'x4': 0xb1f05663, 'x12': 0x1e8dcd3d, 'x20': 0xbbd27277, 'x28': 0xde8e28bd,
        'x5': 0x06b97b0d, 'x13': 0x76d457ed, 'x21': 0x8932d612, 'x29': 0x96ab582d,
        'x6': 0x46df998d, 'x14': 0x462df78c, 'x22': 0x47ecdb8f, 'x30': 0xb2a72665,
        'x7': 0xb2c28465, 'x15': 0x7cfde9f9, 'x23': 0x793069f2, 'x31': 0xb1ef6263,
        'pc': 0  # Set PC to middle of memory for testing branch/jump
    }

    memory = {
        'min_addr': 0,
        'max_addr': 63,
        0: 0x0573870a, 1: 0xc03b2280, 2: 0x10642120, 3: 0x557845aa,
        4: 0xcecccc9d, 5: 0xcb203e96, 6: 0x8983b813, 7: 0x86bc380d,
        8: 0xa9a7d653, 9: 0x359fdd6b, 10: 0xeaa62ad5, 11: 0x81174a02,
        12: 0xd7563eae, 13: 0x0effe91d, 14: 0xe7c572cf, 15: 0x11844923,
        16: 0x0509650a, 17: 0xe5730aca, 18: 0x9e314c3c, 19: 0x7968bdf2,
        20: 0x452e618a, 21: 0x20c4b341, 22: 0xec4b34d8, 23: 0x3c20f378,
        24: 0xc48a1289, 25: 0x75c50deb, 26: 0x5b0265b6, 27: 0x634bf9c6,
        28: 0x571513ae, 29: 0xde7502bc, 30: 0x150fdd2a, 31: 0x85d79a0b,
        32: 0xb897be71, 33: 0x42f24185, 34: 0x27f2554f, 35: 0x9dcc603b,
        36: 0x1d06333a, 37: 0xbf23327e, 38: 0x0aaa4b15, 39: 0x78d99bf1,
        40: 0x6c9c4bd9, 41: 0x31230762, 42: 0x2635fb4c, 43: 0x4fa1559f,
        44: 0x47b9a18f, 45: 0x7c6da9f8, 46: 0xdbcd60b7, 47: 0xcfc4569f,
        48: 0xae7d945c, 49: 0xadcbc05b, 50: 0x44de3789, 51: 0xa4ae3249,
        52: 0xe8233ed0, 53: 0xebfec0d7, 54: 0xa8c7fc51, 55: 0x4b212f96,
        56: 0x061d7f0c, 57: 0xe12ccec2, 58: 0x6457edc8, 59: 0xbb825a77,
        60: 0x1ef2ed3d, 61: 0x090cdb12, 62: 0xbf05007e, 63: 0x36e5816d
    }

    # Array to store valid instructions
    valid_instructions = []

    # Counter for instructions to skip after jumps/branches
    skipped_instructions = 0

    # Generate and validate instructions until we have 32 valid ones
    print("Generating valid RISC-V instructions (target: 32):")
    print("-" * 80)

    attempts = 0
    instructions_executed = 0
    while len(valid_instructions) < 64:
        # Generate a random instruction
        assembly, hex_code, instr_type = generate_riscv_instruction(0)

        # Validate the instruction
        validation_code, validated_hex, validated_assembly = validate_instruction(
            hex_code, assembly, registers, memory
        )

        attempts += 1

        # Display the result
        status = "Valid" if validation_code == 6 else "Invalid"
        reason = ""

        if validation_code == 1:
            reason = "Store address out of bounds"
        elif validation_code == 2:
            reason = "I-type instruction result would overflow 32 bits"
        elif validation_code == 3:
            reason = "Load address out of bounds"
        elif validation_code == 4:
            reason = "Branch target out of bounds"
        elif validation_code == 5:
            reason = "Jump target out of bounds"

        print(f"Attempt {attempts} - Found {len(valid_instructions)}/64 valid instructions:")
        print(f"  Type: {instr_type}")
        print(f"  Assembly: {assembly}")
        print(f"  Hex: 0x{hex_code}")
        print(f"  Status: {status}")
        if reason:
            print(f"  Reason: {reason}")

        # If valid, add to our collection
        if validation_code == 6:
            valid_instructions.append((assembly, hex_code, instr_type))

            # Check if we need to skip this instruction due to a previous jump/branch
            if skipped_instructions > 0:
                print(f"  Instruction skipped (due to previous jump/branch)")
                skipped_instructions -= 1
            else:
                # Remember the current PC before execution
                old_pc = registers.get('pc', 0)

                # Simulate the instruction execution
                executed = simulate_instruction(validation_code, hex_code, assembly, registers, memory)

                # Get the new PC after execution
                new_pc = registers.get('pc', 0)

                if executed:
                    instructions_executed += 1
                    print(f"  Instruction executed successfully (PC: 0x{old_pc:08x} -> 0x{new_pc:08x})")

                    # Check if this was a branch or jump that changed PC
                    if instr_type in ["branch", "jump"] and new_pc != old_pc + 4:
                        # Calculate how many instructions to skip
                        # Assuming each instruction is 4 bytes
                        pc_diff = new_pc - (old_pc + 4)
                        instructions_to_skip = pc_diff // 4
                        if instructions_to_skip > 0:
                            skipped_instructions = instructions_to_skip
                            print(f"  Jump/branch taken: Skipping next {skipped_instructions} instructions")
                    elif instr_type not in ["branch", "jump"]:
                        # For non-branch/jump instructions, increment PC by 4
                        registers['pc'] = (old_pc + 4) & 0xFFFFFFFF
        print()

    # Print summary of valid instructions and execution
    print("\n" + "=" * 80)
    print(f"Found all 64 valid instructions in {attempts} attempts:")
    print(f"Executed {instructions_executed} of 64 instructions (due to branch/jump skipping)")
    print("=" * 80)

    for i, (assembly, hex_code, instr_type) in enumerate(valid_instructions):
        print(f"{i + 1}. Type: {instr_type}, Assembly: {assembly}, Hex: 0x{hex_code}")

    # Print final state of registers and memory
    print("\n" + "=" * 80)
    print("Final Register State:")
    print("=" * 80)
    for i in range(0, 32, 4):
        reg_values = []
        for j in range(4):
            if i + j < 32:
                reg_name = f"x{i + j}"
                reg_value = registers.get(reg_name, 0)
                reg_values.append(f"{reg_name}: 0x{reg_value & 0xFFFFFFFF :08x}")
        print("  ".join(reg_values))
    print(f"PC: 0x{registers.get('pc', 0):08x}")

    print("\n" + "=" * 80)
    print("Memory Locations That Changed:")
    print("=" * 80)

    # Get original memory values
    original_memory = {
        0: 0x0573870a, 1: 0xc03b2280, 2: 0x10642120, 3: 0x557845aa,
        4: 0xcecccc9d, 5: 0xcb203e96, 6: 0x8983b813, 7: 0x86bc380d,
        8: 0xa9a7d653, 9: 0x359fdd6b, 10: 0xeaa62ad5, 11: 0x81174a02,
        12: 0xd7563eae, 13: 0x0effe91d, 14: 0xe7c572cf, 15: 0x11844923,
        16: 0x0509650a, 17: 0xe5730aca, 18: 0x9e314c3c, 19: 0x7968bdf2,
        20: 0x452e618a, 21: 0x20c4b341, 22: 0xec4b34d8, 23: 0x3c20f378,
        24: 0xc48a1289, 25: 0x75c50deb, 26: 0x5b0265b6, 27: 0x634bf9c6,
        28: 0x571513ae, 29: 0xde7502bc, 30: 0x150fdd2a, 31: 0x85d79a0b,
        32: 0xb897be71, 33: 0x42f24185, 34: 0x27f2554f, 35: 0x9dcc603b,
        36: 0x1d06333a, 37: 0xbf23327e, 38: 0x0aaa4b15, 39: 0x78d99bf1,
        40: 0x6c9c4bd9, 41: 0x31230762, 42: 0x2635fb4c, 43: 0x4fa1559f,
        44: 0x47b9a18f, 45: 0x7c6da9f8, 46: 0xdbcd60b7, 47: 0xcfc4569f,
        48: 0xae7d945c, 49: 0xadcbc05b, 50: 0x44de3789, 51: 0xa4ae3249,
        52: 0xe8233ed0, 53: 0xebfec0d7, 54: 0xa8c7fc51, 55: 0x4b212f96,
        56: 0x061d7f0c, 57: 0xe12ccec2, 58: 0x6457edc8, 59: 0xbb825a77,
        60: 0x1ef2ed3d, 61: 0x090cdb12, 62: 0xbf05007e, 63: 0x36e5816d
    }

    # Find memory locations that changed
    changed_locations = []
    for addr in range(64):
        if addr in memory and addr in original_memory:
            if memory[addr] != original_memory[addr]:
                changed_locations.append(addr)

    if changed_locations:
        for addr in changed_locations:
            print(f"MEM[{addr:2d}]: 0x{original_memory[addr]:08x} -> 0x{memory[addr]:08x}")
    else:
        print("No memory locations changed.")

        # Export valid instructions to a HEX file
        import os

        # Specific path you mentioned
        output_file_path = r"C:\Users\User\Desktop\Vivado\Python_generator\Instructions.hex"

        try:
            # Ensure directory exists
            os.makedirs(os.path.dirname(output_file_path), exist_ok=True)

            # Write instructions to file
            with open(output_file_path, 'w') as hex_file:
                for _, hex_code, _ in valid_instructions:
                    hex_file.write(f"{hex_code}\n")

            print(f"\nSuccessfully saved {len(valid_instructions)} instructions to:")
            print(output_file_path)

            # Verify file contents
            with open(output_file_path, 'r') as verify_file:
                saved_instructions = verify_file.readlines()
                print(f"Verified: {len(saved_instructions)} instructions in the file")
                print("First few instructions:")
                for inst in saved_instructions[:5]:
                    print(inst.strip())

        except PermissionError:
            print(f"\nError: No write permission to {output_file_path}")
            print("Please check directory permissions.")

        except IOError as e:
            print(f"\nIO Error writing to file: {e}")

        except Exception as e:
            print(f"\nUnexpected error occurred: {e}")
            import traceback

            traceback.print_exc()# Export valid instructions to a HEX file
    import os

    # Specific path you mentioned
    output_file_path = r"C:\Users\User\Desktop\Vivado\Python_generator\Instructions.hex"

    try:
        # Ensure directory exists
        os.makedirs(os.path.dirname(output_file_path), exist_ok=True)

        # Write hex codes to file
        with open(output_file_path, 'w') as hex_file:
            for _, hex_code, _ in valid_instructions:
                hex_file.write(f"{hex_code}\n")

        print(f"\nSuccessfully saved {len(valid_instructions)} instructions to:")
        print(output_file_path)

        # Verify file contents
        with open(output_file_path, 'r') as verify_file:
            saved_instructions = verify_file.readlines()
            print(f"Verified: {len(saved_instructions)} instructions in the file")
            print("First instruction: 0x{saved_instructions[0].strip()}")

    except Exception as e:
        print(f"\nError writing to HEX file: {e}")
        import traceback
        traceback.print_exc()