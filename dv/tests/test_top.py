import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def test_cpu(dut):    
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    if hasattr(dut, 'rst_n'):
        dut.rst_n.value = 1
        await Timer(10, unit="ns")
        dut.rst_n.value = 0
        await Timer(10, unit="ns")
        dut.rst_n.value = 1

    dut._log.info("Running the CPU")
    for _ in range(80):
        await RisingEdge(dut.clk)

    try:
        x7_val = dut.u_reg_file.rf[7].value.to_unsigned()
        
        dut._log.info(f"x2 = {x7_val}")
        num = (4 * 5 ** 3) - (3 * 5)
        assert x7_val == num, f"Expected x2 to be {num}, got {x7_val}"
        
    except AttributeError:
        dut._log.error("Could not find the register file. Check your module instantiation names!")