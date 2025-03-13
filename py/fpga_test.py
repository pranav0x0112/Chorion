import os
import time

def send_data_to_fpga(plaintext: bytes, key: bytes, nonce: bytes, counter: int):
    """Send input data to FPGA for encryption."""
    with open("/dev/fpga_input", "wb") as f:
        f.write(counter.to_bytes(4, 'little'))
        f.write(nonce)
        f.write(key)
        f.write(plaintext)

def read_data_from_fpga() -> bytes:
    """Read encrypted data from FPGA."""
    with open("/dev/fpga_output", "rb") as f:
        return f.read()

def main():
    key = bytes.fromhex("000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f")
    nonce = bytes.fromhex("000000090000004a00000000")
    counter = 1
    plaintext = b"Welcome to FPGA"

    print("Sending data to FPGA...")
    send_data_to_fpga(plaintext, key, nonce, counter)
    
    print("Waiting for FPGA computation...")
    time.sleep(0.1)  # Simulate processing delay

    ciphertext = read_data_from_fpga()
    print(f"Ciphertext: {ciphertext.hex()}")

if __name__ == "__main__":
    main()
