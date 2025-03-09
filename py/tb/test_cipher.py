import unittest
from src.cipher import chacha20_encrypt, chacha20_decrypt

class TestChaCha20Cipher(unittest.TestCase):
    def setUp(self):
        self.key = bytes(range(32))
        self.nonce = bytes(range(12))
        self.counter = 1
        self.plaintext = b"big cocks"

    def test_encryption(self):
        ciphertext = chacha20_encrypt(self.key, self.nonce, self.counter, self.plaintext)
        self.assertNotEqual(ciphertext, self.plaintext)

    def test_decryption(self):
        ciphertext = chacha20_encrypt(self.key, self.nonce, self.counter, self.plaintext)
        decrypted = chacha20_decrypt(self.key, self.nonce, self.counter, ciphertext)
        self.assertEqual(decrypted, self.plaintext)

if __name__ == "__main__":
    unittest.main()

