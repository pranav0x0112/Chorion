def chacha20_state(key: bytes, counter: int, nonce: bytes):
    constants = [0x61707865, 0x3320646e, 0x79622d32, 0x6b206574]

    key_words = [int.from_bytes(key[i:i+4], 'little') for i in range(0,32,4)]
    nonce_words = [int.from_bytes(nonce[i:i+4], 'little') for i in range(0,12,4)]

    return constants + key_words + [counter] + nonce_words
