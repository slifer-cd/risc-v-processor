import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

async def reset_dut(dut):
    """
    Helper coroutine to apply an active-low reset to the DUT.
    """
    dut._log.info("Asserting reset...")
    dut.rst_n.value = 0
    
    # Hold reset for 5 clock cycles
    for _ in range(5):
        await RisingEdge(dut.clk)
        
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    dut._log.info("Reset de-asserted.")

@cocotb.test()
async def test_rv32i_boot(dut):
    """
    Starter test to boot the RV32I core and verify clock/reset behavior.
    """
    # 1. Start a 10ns period clock on the 'clk' pin
    # cocotb.start_soon() runs this in the background concurrently
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # 2. Initialize inputs to avoid 'X' (unknown) states at time 0
    dut.rst_n.value = 1

    # 3. Apply reset sequence
    await reset_dut(dut)

    # 4. Run the simulation for a set number of cycles
    dut._log.info("Running simulation for 20 clock cycles...")
    for cycle in range(20):
        await RisingEdge(dut.clk)
        
        # ---------------------------------------------------------
        # Example: Peering into the hierarchy (uncomment once built)
        # ---------------------------------------------------------
        # You can access internal signals using dot notation based 
        # on your SystemVerilog instance names.
        # 
        # try:
        #     pc_val = dut.u_core.pc.value
        #     dut._log.info(f"Cycle {cycle}: PC = 0x{pc_val.integer:08x}")
        # except AttributeError:
        #     pass 

    dut._log.info("Boot test completed successfully!")