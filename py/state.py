def chacha20_state(key: bytes, counter: int, nonce: bytes):
    assert len(key) == 32, f"Key length is {len(key)}, must be 32 bytes!"
    assert len(nonce) == 12, f"Nonce length is {len(nonce)}, must be 12 bytes!"

    constants = [0x61707865, 0x3320646e, 0x79622d32, 0x6b206574]  # "expand 32-byte k"

    # Convert key and nonce into little-endian 32-bit words
    key_words = [int.from_bytes(key[i:i+4], 'little') for i in range(0, 32, 4)]
    nonce_words = [int.from_bytes(nonce[i:i+4], 'little') for i in range(0, 12, 4)]

    # Construct the ChaCha20 state
    return constants + key_words + [counter] + nonce_words
