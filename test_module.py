import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_immediate_formats(dut):
    """Test all immediate formats for the RISC-V immediateextender."""
    
    # Format: (Test Name, Select Signal, Instruction Hex, Expected Immediate Hex)
    test_cases = [
        # I-Type: addi x5, x0, -2048 (12-bit max negative)
        ("I-Type", 0b000, 0x80000293, 0xFFFFF800),
        
        # S-Type: sw x5, -4(x6) 
        ("S-Type", 0b001, 0xfe532e23, 0xFFFFFFFC),
        
        # B-Type: beq x5, x6, -8 (Branch backward by 8 bytes)
        ("B-Type", 0b010, 0xfe628ce3, 0xFFFFFFF8),
        
        # J-Type: jal x1, -4 (Infinite loop, jump to self)
        ("J-Type", 0b011, 0xffdff0ef, 0xFFFFFFFC),
        
        # U-Type: lui x5, 0x12345 
        ("U-Type", 0b100, 0x123452b7, 0x12345000),
        
        # Default latch prevention: invalid select code should output 0
        ("Default", 0b111, 0xFFFFFFFF, 0x00000000),
    ]

    dut._log.info("Starting Immediate Extender Tests...")

    for name, select, inst, expected in test_cases:
        # 1. Drive inputs
        dut.instruction.value = inst
        dut.select.value = select

        # 2. Wait 1 nanosecond for combinational logic to evaluate
        await Timer(10, unit="ns")

        # 3. Read output
        actual = int(dut.immediate.value)

        # 4. Assert correctness (with a helpful error message if it fails)
        assert actual == expected, \
            f"{name} Failed: Inst=0x{inst:08X}, Expected=0x{expected:08X}, Got=0x{actual:08X}"
            
        dut._log.info(f"{name} Passed: Got expected 0x{actual:08X}")