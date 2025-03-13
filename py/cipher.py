import time
from block import chacha20_block
from state import chacha20_state

def chacha20_process(key: bytes, nonce: bytes, counter: int, data: bytes) -> tuple[bytes, float]:
    """Performs ChaCha20 encryption or decryption (same operation)."""
    if len(key) != 32:
        raise ValueError("Key must be 32 bytes long!")
    if len(nonce) != 12:
        raise ValueError("Nonce must be 12 bytes long!")

    result = bytearray(len(data))
    start_time = time.time()

    for block_index, offset in enumerate(range(0, len(data), 64)):
        state = chacha20_state(key, counter + block_index, nonce)
        keystream = b''.join(word.to_bytes(4, 'little') for word in chacha20_block(state))
        block_size = min(64, len(data) - offset)
        result[offset:offset+block_size] = bytes(p ^ k for p, k in zip(data[offset:offset+block_size], keystream[:block_size]))

    end_time = time.time()
    elapsed_time = end_time - start_time

    return bytes(result), elapsed_time  # Return processed data and time taken

def chacha20_encrypt(key: bytes, nonce: bytes, counter: int, plaintext: bytes) -> tuple[bytes, float]:
    """Encrypts plaintext using ChaCha20."""
    return chacha20_process(key, nonce, counter, plaintext)

def chacha20_decrypt(key: bytes, nonce: bytes, counter: int, ciphertext: bytes) -> tuple[bytes, float]:
    """Decrypts ciphertext using ChaCha20."""
    return chacha20_process(key, nonce, counter, ciphertext)
