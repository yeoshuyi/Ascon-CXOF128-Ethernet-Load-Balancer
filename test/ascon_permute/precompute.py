import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def ascon_test(dut):

    input_val = 0x0000080100cc0002000000000000000000000000000000000000000000000
    dut.state_in.value = input_val

    await Timer(1, unit="ns")

    print(dut.state_out.value.binstr)