# Cryptography and AES

## Introduction to Cryptography
Cryptography is the practice of securing information by transforming it into an unreadable format, ensuring that only authorized parties can access the original data. It is widely used in securing communications, data integrity, and authentication.

### Types of Cryptography
1. **Symmetric-key Cryptography** – Uses a single key for encryption and decryption (e.g., AES, DES).
2. **Asymmetric-key Cryptography** – Uses a pair of keys (public and private) for encryption and decryption (e.g., RSA, ECC).
3. **Hash Functions** – One-way functions that convert data into a fixed-length string (e.g., SHA, MD5).

## Advanced Encryption Standard (AES)
AES is a widely used symmetric encryption algorithm that ensures secure data transmission. It was established by the U.S. National Institute of Standards and Technology (NIST) in 2001.

### Features of AES:
- **Block Cipher** – Operates on fixed-size blocks (128-bit).
- **Key Sizes** – Supports 128-bit, 192-bit, and 256-bit keys.
- **Rounds of Encryption** – The number of rounds depends on the key size:
  - 128-bit key → 10 rounds
  - 192-bit key → 12 rounds
  - 256-bit key → 14 rounds

### AES Encryption Process
AES consists of several transformation steps applied over multiple rounds:

1. **Key Expansion** – Generates round keys from the initial secret key.
2. **Initial Round:**
   - AddRoundKey: XORs the plaintext with the first round key.
3. **Main Rounds (Repeated N times):**
   - SubBytes: Non-linear byte substitution using an S-Box.
   - ShiftRows: Rows of the state are shifted cyclically.
   - MixColumns: Columns are mixed using matrix multiplication.
   - AddRoundKey: XOR with the corresponding round key.
4. **Final Round (Similar to main rounds but without MixColumns):**
   - SubBytes, ShiftRows, AddRoundKey.

### AES Decryption
Decryption is the reverse of encryption using the inverse transformations of each step.

### AES Hardware Implementation
AES can be efficiently implemented in hardware using FPGA-based designs, leveraging parallelism to accelerate encryption and decryption processes.

#### Benefits of FPGA Implementation:
- High-speed execution due to parallel processing.
- Customizable security features.
- Efficient power consumption compared to software implementations.

## Applications of AES
- **Secure communication (TLS, HTTPS)**
- **Data encryption for storage (SSD, HDD encryption)**
- **Wireless security (WPA2, WPA3)**
- **Embedded systems and IoT devices**

## Summary
AES is a powerful and widely used encryption standard that provides robust security. Implementing AES on FPGA offers hardware acceleration and improved performance for cryptographic applications.

