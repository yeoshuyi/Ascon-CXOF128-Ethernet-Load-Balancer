import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from collections import deque
import random

def rotate_right(val, r):
    return ((val >> r) | (val << (64 - r))) & 0xFFFFFFFFFFFFFFFF

def full_8_round_ref(input_state):
    """
    Reference model for the full 8-round p_b permutation.
    Matches rounds 4 through 11.
    """

    state = list(input_state)
    for rc in range(4, 12):
        ascon_const = (((0xf - rc) << 4) | rc) & 0xFF
        state[2] ^= ascon_const
        
        x0, x1, x2, x3, x4 = state
        x0 ^= x4; x4 ^= x3; x2 ^= x1
        
        t0 = (x0 ^ (~x1 & x2)) & 0xFFFFFFFFFFFFFFFF
        t1 = (x1 ^ (~x2 & x3)) & 0xFFFFFFFFFFFFFFFF
        t2 = (x2 ^ (~x3 & x4)) & 0xFFFFFFFFFFFFFFFF
        t3 = (x3 ^ (~x4 & x0)) & 0xFFFFFFFFFFFFFFFF
        t4 = (x4 ^ (~x0 & x1)) & 0xFFFFFFFFFFFFFFFF
        
        t1 ^= t0; t0 ^= t4; t3 ^= t2
        t2 = (t2 ^ 0xFFFFFFFFFFFFFFFF) & 0xFFFFFFFFFFFFFFFF

        state[0] = t0 ^ rotate_right(t0, 19) ^ rotate_right(t0, 28)
        state[1] = t1 ^ rotate_right(t1, 61) ^ rotate_right(t1, 39)
        state[2] = t2 ^ rotate_right(t2, 1)  ^ rotate_right(t2, 6)
        state[3] = t3 ^ rotate_right(t3, 10) ^ rotate_right(t3, 17)
        state[4] = t4 ^ rotate_right(t4, 7)  ^ rotate_right(t4, 41)
        
    return state

@cocotb.test()
async def test_ascon_pipeline(dut):
    """Verifies pipeline integrity and 322MHz timing."""
    
    cocotb.start_soon(Clock(dut.clk, 3104, unit="ps").start())

    # Reset Sequence
    dut.rst_n.value = 0
    await Timer(10, unit="ns")
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    scoreboard = deque()
    LATENCY = 4
    TEST_COUNT = 50

    for i in range(TEST_COUNT + LATENCY):
        await FallingEdge(dut.clk)
        
        if i < TEST_COUNT:
            payload = [random.getrandbits(64) for _ in range(5)]
            dut.x0_in.value = payload[0]
            dut.x1_in.value = payload[1]
            dut.x2_in.value = payload[2]
            dut.x3_in.value = payload[3]
            dut.x4_in.value = payload[4]
            
            expected = full_8_round_ref(payload)
            scoreboard.append(expected)
    
        if i >= LATENCY:
            expected_val = scoreboard.popleft()
            actual_val = [
                int(dut.x0_out.value), int(dut.x1_out.value),
                int(dut.x2_out.value), int(dut.x3_out.value),
                int(dut.x4_out.value)
            ]
            
            for j in range(5):
                assert actual_val[j] == expected_val[j], \
                    f"Mismatch at cycle {i}! Stage x{j} failed."
            
            dut._log.info(f"Packet {i-LATENCY} verified successfully.")