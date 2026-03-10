import cocotb
from cocotb.triggers import Timer
import random

def int_to_state(val):
    """Split 320 to 64 bit blocks"""
    return [(val >> (64 * i)) & 0xFFFFFFFFFFFFFFFF for i in reversed(range(5))]

def state_to_int(state):
    """Recombine"""
    res = 0
    for s in state:
        res = (res << 64) | s
    return res

def ascon_permutate(state):
    """Derived from meichlseder's Ascon Algo"""
    rounds = 12
    S = state.copy()

    for r in range(12-rounds, 12):
        S[2] ^= (0xf0 - r*0x10 + r*0x1)
        S[0] ^= S[4]
        S[4] ^= S[3]
        S[2] ^= S[1]
        T = [(S[i] ^ 0xFFFFFFFFFFFFFFFF) & S[(i+1)%5] for i in range(5)]
        for i in range(5):
            S[i] ^= T[(i+1)%5]
        S[1] ^= S[0]
        S[0] ^= S[4]
        S[3] ^= S[2]
        S[2] ^= 0XFFFFFFFFFFFFFFFF
        S[0] ^= rotr(S[0], 19) ^ rotr(S[0], 28)
        S[1] ^= rotr(S[1], 61) ^ rotr(S[1], 39)
        S[2] ^= rotr(S[2],  1) ^ rotr(S[2],  6)
        S[3] ^= rotr(S[3], 10) ^ rotr(S[3], 17)
        S[4] ^= rotr(S[4],  7) ^ rotr(S[4], 41)
    
    return S

def rotr(val: int, r: int) -> int:
    return (val >> r) | ((val & (1<<r)-1) << (64-r))

@cocotb.test()
async def ascon_test(dut):
    
    for i in range(100):
        input_val = random.getrandbits(320)
        dut.state_in.value = input_val

        await Timer(1, unit="ns")

        ref_input_state = int_to_state(input_val)
        ref_output_state = ascon_permutate(ref_input_state)
        expected_val = state_to_int(ref_output_state)

        actual_val = dut.state_out.value.integer

        assert actual_val == expected_val, (
            f"Trial {i} failed!\n"
            f"Input:    {hex(input_val)}\n"
            f"Expected: {hex(expected_val)}\n"
            f"Actual:   {hex(actual_val)}"
        )

    dut._log.info("Successfully verified 100 random permutations!")