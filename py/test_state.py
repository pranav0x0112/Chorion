from state import chacha20_state

def test_state():
    key = bytes.fromhex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f")
    nonce = bytes.fromhex("000000090000004a00000000")
    counter = 1
    
    expected_state = [
        0x61707865, 0x3320646e, 0x79622d32, 0x6b206574,  # Constants
        0x03020100, 0x07060504, 0x0b0a0908, 0x0f0e0d0c,  # Key (part 1)
        0x13121110, 0x17161514, 0x1b1a1918, 0x1f1e1d1c,  # Key (part 2)
        counter,  # Counter
        0x09000000, 0x4a000000, 0x00000000  # Nonce
    ]

    state = chacha20_state(key,counter,nonce)
    assert state == expected_state, f"State mismatch! Expected {expected_state}, got {state}"
    print("State test passed!")

if __name__ == "__main__":
    test_state()