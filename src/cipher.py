from block import chacha20_block
from state import chacha20_state

def chacha20_encrypt(key: bytes, nonce: bytes, counter: int, plaintext: bytes)-> bytes:
    if len(key) != 32:
        raise ValueError("Key must be 32 bytes long!")
    if len(nonce) != 12:
        raise ValueError("Nonce must be 12 bytes long!")
    ciphertext = bytearray(len(plaintext))

    for block_index, offset in enumerate(range(0,len(plaintext), 64)):
        state = chacha20_state(key, counter + block_index, nonce)
        keystream = b''.join(word.to_bytes(4,'little') for word in chacha20_block(state))

        block_size = min(64,len(plaintext) - offset)
        ciphertext[offset:offset+block_size] = bytes(p ^ k for p, k in zip(plaintext[offset:offset+block_size], keystream[:block_size]))

    return bytes(ciphertext)

def chacha20_decrypt(key: bytes, nonce: bytes, counter: int, ciphertext: bytes):
    return chacha20_encrypt(key,nonce,counter,ciphertext)