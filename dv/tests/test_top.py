import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def test_cpu(dut):
    """Test the RISC-V Single Cycle CPU with a basic addition program."""
    
    # 1. Start a 10ns clock running in the background
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    # 2. Reset the CPU 
    # (If you don't have a reset pin on your top module yet, you can delete this section)
    # Assuming active-high reset named 'rst'. If it's active-low (rst_n), flip the 1 and 0.
    if hasattr(dut, 'rst_n'):
        dut.rst_n.value = 1
        await Timer(10, unit="ns")
        dut.rst_n.value = 0
        await Timer(10, unit="ns")
        dut.rst_n.value = 1

    # 3. Let the CPU run for 5 clock cycles
    # Our program is 3 instructions long. In a single-cycle CPU, it takes exactly 
    # 3 clock cycles to finish. We run for 5 just to give it a little buffer.
    dut._log.info("Running the CPU for 5 cycles...")
    for _ in range(4):
        await RisingEdge(dut.clk)

    # 4. Read the internal Register File
    # WARNING: You must update the names here to match your exact SystemVerilog code!
    # Format: dut.<name_of_regfile_instance_in_top>.<name_of_array_inside_regfile>[index].value
    
    # Example assumption: top.sv instantiates it as `rf`, and inside regfile.sv the array is `registers`
    try:
        x1_val = dut.u_reg_file.rf[1].value.to_unsigned()
        x2_val = dut.u_reg_file.rf[2].value.to_unsigned()
        x3_val = dut.u_reg_file.rf[3].value.to_unsigned()
        
        # Print the results to the terminal
        dut._log.info(f"x1 = {x1_val}")
        dut._log.info(f"x2 = {x2_val}")
        dut._log.info(f"x3 = {x3_val}")

        # 5. The actual test check
        assert x1_val == 10, f"Expected x1 to be 10, got {x1_val}"
        assert x2_val == 20, f"Expected x2 to be 20, got {x2_val}"
        assert x3_val == 30, f"Expected x3 to be 30, got {x3_val} - ALU or Writeback failed!"
        
        dut._log.info("SUCCESS: x3 is exactly 30!")
        
    except AttributeError:
        dut._log.error("Could not find the register file. Check your module instantiation names!")