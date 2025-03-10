from cipher import chacha20_encrypt, chacha20_decrypt

key = bytes.fromhex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f")
nonce = bytes.fromhex("000000090000004a00000000")
counter = 1
plaintext = b"Hello HSP"

# Encryption
ciphertext, enc_time = chacha20_encrypt(key, nonce, counter, plaintext)
print(f"Encryption Time: {enc_time:.6f} seconds")
print(f"Ciphertext: {ciphertext.hex()}")

# Decryption
decrypted, dec_time = chacha20_decrypt(key, nonce, counter, ciphertext)
print(f"Decryption Time: {dec_time:.6f} seconds")
print(f"Decrypted: {decrypted.decode(errors='ignore')}")
