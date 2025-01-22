# AES and SHA Implementation on PYNQ FPGA

This repository contains the implementation of **AES (Advanced Encryption Standard)** and **SHA (Secure Hash Algorithm)** on the **PYNQ FPGA** platform. The goal is to leverage the PYNQ's hardware acceleration capabilities to achieve efficient cryptographic operations.

---

## Project Overview

### AES (Advanced Encryption Standard)
AES is a symmetric key encryption standard used globally for secure data encryption. This project implements AES-128 with:
- Key expansion
- SubBytes, ShiftRows, MixColumns, and AddRoundKey operations
- Hardware-accelerated encryption and decryption.

### SHA (Secure Hash Algorithm)
SHA is a family of cryptographic hash functions. This project focuses on **SHA-256**, providing:
- Message preprocessing and padding
- Chunk processing and compression
- Hardware-accelerated hashing.

---

## Features
- Hardware-accelerated implementation of AES-128 and SHA-256.
- Optimized for PYNQ FPGA using Verilog/SystemVerilog.
- Python APIs for easy interaction with hardware modules.
- Testbench and verification scripts for design validation.

---
