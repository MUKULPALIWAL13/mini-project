import re
import sys

# --- RISC-V Register Mappings (ABI names to register numbers) ---
REG_MAP = {
    'zero': 0, 'ra': 1, 'sp': 2, 'gp': 3, 'tp': 4,
    't0': 5, 't1': 6, 't2': 7, 's0': 8, 'fp': 8, 's1': 9,
    'a0': 10, 'a1': 11, 'a2': 12, 'a3': 13, 'a4': 14, 'a5': 15,
    'a6': 16, 'a7': 17, 's2': 18, 's3': 19, 's4': 20, 's5': 21,
    's6': 22, 's7': 23, 's8': 24, 's9': 25, 's10': 26, 's11': 27,
    't3': 28, 't4': 29, 't5': 30, 't6': 31,
}
# Also support x-notation
for i in range(32):
    REG_MAP[f'x{i}'] = i

# --- RISC-V Instruction Field Definitions ---
# Type: (opcode, funct3, funct7) - funct7 is optional for non-R types
INSTR_MAP = {
    # R-Type: (opcode, funct3, funct7)
    'add': ('0110011', '000', '0000000'),
    'sub': ('0110011', '000', '0100000'),
    'slt': ('0110011', '010', '0000000'),  # ADDED: Set Less Than
    'and': ('0110011', '111', '0000000'),
    'or':  ('0110011', '110', '0000000'),
    'sll': ('0110011', '001', '0000000'),
    'srl': ('0110011', '101', '0000000'),

    # I-Type (Arithmetic/Logical): (opcode, funct3)
    'addi': ('0010011', '000'),
    'andi': ('0010011', '111'),
    'ori':  ('0010011', '110'),

    # I-Type (Load): (opcode, funct3)
    'lw': ('0000011', '010'),

    # S-Type (Store): (opcode, funct3)
    'sw': ('0100011', '010'),

    # B-Type (Branch): (opcode, funct3)
    'beq': ('1100011', '000'),
    'bne': ('1100011', '001'),
}

# --- Core Encoding Functions ---

def get_reg_num(reg_name):
    """Converts register name (e.g., 's0', 'x8') to its 5-bit number."""
    reg_name = reg_name.strip(',').lower()
    if reg_name in REG_MAP:
        return REG_MAP[reg_name]
    raise ValueError(f"Invalid register name: {reg_name}")

def sign_extend(value, bits):
    """Sign extends a value to 32 bits."""
    sign_bit = 1 << (bits - 1)
    return (value & (sign_bit - 1)) - (value & sign_bit)

def encode_r_type(parts, instr_info):
    """Encodes R-Type: add rd, rs1, rs2"""
    opcode, funct3, funct7 = instr_info
    # rd, rs1, rs2 are the 2nd, 3rd, and 4th parts
    rd = get_reg_num(parts[1])
    rs1 = get_reg_num(parts[2])
    rs2 = get_reg_num(parts[3])

    # Instruction layout: [funct7 | rs2 | rs1 | funct3 | rd | opcode]
    instr = (int(funct7, 2) << 25) | \
            (rs2 << 20) | \
            (rs1 << 15) | \
            (int(funct3, 2) << 12) | \
            (rd << 7) | \
            int(opcode, 2)
    return instr

def encode_i_type(parts, instr_info, labels, pc):
    """Encodes I-Type: addi rd, rs1, imm OR lw rd, imm(rs1)"""
    opcode, funct3 = instr_info
    
    rd = get_reg_num(parts[1])
    
    # Handle Load type (lw rd, imm(rs1))
    if parts[0] in ['lw', 'lb', 'lbu']:
        # Format: lw rd, imm(rs1) -> parts[2] is "imm(rs1)"
        match = re.match(r"(-?\d+)\s*\(\s*(\w+)\s*\)", parts[2])
        if not match:
            raise SyntaxError(f"Invalid I-type load format: {parts[2]}")
        imm_val, rs1_reg = match.groups()
        rs1 = get_reg_num(rs1_reg)
        imm = int(imm_val)
    # Handle Arithmetic type (addi rd, rs1, imm)
    else:
        rs1 = get_reg_num(parts[2])
        imm = int(parts[3])
    
    if not (-2048 <= imm <= 2047):
        raise ValueError(f"Immediate value {imm} out of 12-bit signed range.")
    
    imm_12 = imm & 0xFFF # Take the lower 12 bits

    # Instruction layout: [imm[11:0] | rs1 | funct3 | rd | opcode]
    instr = (imm_12 << 20) | \
            (rs1 << 15) | \
            (int(funct3, 2) << 12) | \
            (rd << 7) | \
            int(opcode, 2)
    return instr

def encode_s_type(parts, instr_info):
    """Encodes S-Type: sw rs2, imm(rs1)"""
    opcode, funct3 = instr_info
    
    rs2 = get_reg_num(parts[1]) # rs2 is the value to be stored
    
    # Format: sw rs2, imm(rs1) -> parts[2] is "imm(rs1)"
    match = re.match(r"(-?\d+)\s*\(\s*(\w+)\s*\)", parts[2])
    if not match:
        raise SyntaxError(f"Invalid S-type store format: {parts[2]}")
    imm_val, rs1_reg = match.groups()
    rs1 = get_reg_num(rs1_reg)
    imm = int(imm_val)

    if not (-2048 <= imm <= 2047):
        raise ValueError(f"Immediate value {imm} out of 12-bit signed range.")

    imm_12 = imm & 0xFFF

    # S-type splits the 12-bit immediate:
    # imm[11:5] goes to bits 31:25
    # imm[4:0] goes to bits 11:7
    imm_11_5 = (imm_12 >> 5) & 0x7F # Bits 11 down to 5
    imm_4_0  = imm_12 & 0x1F         # Bits 4 down to 0

    # Instruction layout: [imm[11:5] | rs2 | rs1 | funct3 | imm[4:0] | opcode]
    instr = (imm_11_5 << 25) | \
            (rs2 << 20) | \
            (rs1 << 15) | \
            (int(funct3, 2) << 12) | \
            (imm_4_0 << 7) | \
            int(opcode, 2)
    return instr

def encode_b_type(parts, instr_info, labels, pc):
    """Encodes B-Type (Branch): beq rs1, rs2, label"""
    opcode, funct3 = instr_info
    
    rs1 = get_reg_num(parts[1])
    rs2 = get_reg_num(parts[2])
    target_label = parts[3]

    if target_label not in labels:
        raise ValueError(f"Label '{target_label}' not found.")

    target_addr = labels[target_label]
    offset = target_addr - pc
    
    if offset % 2 != 0:
        raise ValueError("Branch target must be 2-byte aligned (even address).")

    # B-type immediate is 13 bits (12:1)
    if not (-4096 <= offset <= 4094): # Check range for 12-bit signed offset * 2 (13 bits effectively)
        raise ValueError(f"Branch offset {offset} out of 13-bit signed range.")

    # B-type requires complex immediate field rearrangement:
    # imm[12] -> bit 31
    # imm[10:5] -> bits 30:25
    # imm[4:1] -> bits 11:8
    # imm[11] -> bit 7

    imm = offset & 0x1FFF # Mask for the 13 bits (12:1)
    
    imm_12 = (imm >> 12) & 0x1       # Bit 12 (sign bit)
    imm_10_5 = (imm >> 5) & 0x3F     # Bits 10 down to 5
    imm_4_1 = (imm >> 1) & 0x0F      # Bits 4 down to 1
    imm_11 = (imm >> 11) & 0x1       # Bit 11

    # Instruction layout: [imm[12] | imm[10:5] | rs2 | rs1 | funct3 | imm[4:1] | imm[11] | opcode]
    instr = (imm_12 << 31) | \
            (imm_10_5 << 25) | \
            (rs2 << 20) | \
            (rs1 << 15) | \
            (int(funct3, 2) << 12) | \
            (imm_4_1 << 8) | \
            (imm_11 << 7) | \
            int(opcode, 2)
    return instr


def assemble(filename="test.asm", output_file="OUTPUT.dat"):
    """
    Main assembly function: Two passes + Big-Endian output.
    """
    try:
        with open(filename, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: Assembly file '{filename}' not found.")
        sys.exit(1)

    # Clean lines: remove comments, strip whitespace, handle empty lines
    cleaned_lines = []
    for line in lines:
        line = line.split('#')[0].strip()
        if line:
            cleaned_lines.append(line)

    # --- Pass 1: Collect Labels ---
    labels = {}
    pc = 0 # Program Counter / Address in bytes
    for line in cleaned_lines:
        if ':' in line:
            label = line.split(':')[0].strip()
            labels[label] = pc
            # Instruction part on the same line, e.g., 'loop: addi t0, t0, 1'
            instruction = line.split(':')[1].strip()
            if instruction:
                pc += 4
        else:
            pc += 4

    # --- Pass 2: Encode Instructions ---
    machine_code_bytes = []
    pc = 0
    for line in cleaned_lines:
        # Skip pure label lines
        instruction_line = line.split(':')[1].strip() if ':' in line else line
        if not instruction_line:
            continue

        parts = re.split(r'[,\s]+', instruction_line)
        instruction_name = parts[0].lower()

        try:
            instr_info = INSTR_MAP.get(instruction_name)
            if not instr_info:
                raise ValueError(f"Unknown instruction: {instruction_name}")
            
            # Select correct encoding function based on instruction map size (R=3, I/S/B=2)
            if len(instr_info) == 3: # R-Type
                machine_word = encode_r_type(parts, instr_info)
            elif instruction_name in ['addi', 'andi', 'ori', 'lw']: # I-Type
                machine_word = encode_i_type(parts, instr_info, labels, pc)
            elif instruction_name in ['sw']: # S-Type
                machine_word = encode_s_type(parts, instr_info)
            elif instruction_name in ['beq', 'bne']: # B-Type
                machine_word = encode_b_type(parts, instr_info, labels, pc)
            else:
                raise ValueError(f"Unhandled instruction type for {instruction_name}")

            # --- Big-Endian Byte Generation ---
            # Your Verilog memory is Big-Endian: MSB at lowest address (readAddr)
            # We must break the 32-bit word into bytes MSB first (inst[31:24], inst[23:16], ...)
            
            # Byte 4 (MSB)
            machine_code_bytes.append(f"{((machine_word >> 24) & 0xFF):02X}")
            # Byte 3
            machine_code_bytes.append(f"{((machine_word >> 16) & 0xFF):02X}")
            # Byte 2
            machine_code_bytes.append(f"{((machine_word >> 8) & 0xFF):02X}")
            # Byte 1 (LSB)
            machine_code_bytes.append(f"{((machine_word) & 0xFF):02X}")
            
            pc += 4

        except (ValueError, SyntaxError) as e:
            print(f"Error at address 0x{pc:02X} ({instruction_line}): {e}")
            sys.exit(1)

    # --- Write Output File (for $readmemb) ---
    with open(output_file, 'w') as f:
        f.write('\n'.join(machine_code_bytes) + '\n')

    print(f"Assembly successful: {pc // 4} instructions encoded.")
    print(f"Output saved to '{output_file}' in Big-Endian byte order.")
    print("\n--- Generated Machine Code (Big-Endian Bytes) ---")
    for i in range(0, len(machine_code_bytes), 4):
        byte_group = machine_code_bytes[i:i+4]
        addr = i
        print(f"0x{addr:02X}: {' '.join(byte_group)}")

if __name__ == "__main__":
    assemble()