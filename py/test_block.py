import unittest
from block import chacha20_block
from state import chacha20_state

class TestBlock(unittest.TestCase):
    def setUp(self):
        self.key = bytes.fromhex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f")
        self.nonce = bytes.fromhex("000000090000004a00000000")
        self.counter = 1
        self.initial_state = chacha20_state(self.key, self.counter, self.nonce)

    def test_block_output(self):
        output = chacha20_block(self.initial_state)
        self.assertEqual(len(output),16)

    def test_different_counters(self):
        state1 = chacha20_state(self.key, self.counter, self.nonce)
        state2 = chacha20_state(self.key, self.counter + 1, self.nonce)
        output1 = chacha20_block(state1)
        output2 = chacha20_block(state2)
        self.assertNotEqual(output1,output2)

if __name__ == "__main__":
    unittest.main()
