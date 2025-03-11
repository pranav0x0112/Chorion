import unittest
from rounds import quarter_round

class TestQuarterRound(unittest.TestCase):
    def test_quarter_round(self):
        # Test vector from the ChaCha20 specification (RFC 8439)
        a, b, c, d = 0x11111111, 0x01020304, 0x9b8d6f43, 0x01234567
        
        # Expected output after one quarter round
        expected = (0xea2a92f4, 0xcb1cf8ce, 0x4581472e, 0x5881c4bb)
        
        # Run quarter round
        result = quarter_round(a, b, c, d)
        
        # Assert expected values match
        self.assertEqual(result, expected)

if __name__ == "__main__":
    unittest.main()
