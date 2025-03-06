# ChaCha20 Hardware Accelerator on PYNQ FPGA

## Overview
This project aims to implement the **ChaCha20 encryption algorithm** on the **PYNQ-Z2 FPGA**.  
ChaCha20 is a **high-speed stream cipher** used in modern cryptographic applications, known for its simplicity and security.  
The goal is to create a **hardware-accelerated implementation** that efficiently processes ChaCha20 operations on FPGA.  

## Features
- **ChaCha20 Stream Cipher** – 20-round encryption implementation  
- **FPGA Acceleration** – Designed for efficient parallel processing  
- **Python API** – Interface for testing and verification  
- **Optimized for PYNQ** – Uses FPGA hardware overlays  

## Project Structure

```
│── src         # SystemVerilog implementation of ChaCha20
│── tb          # Testbenches for simulation and verification
│── tools       # Python scripts for FPGA communication
│── docs        # Documentation and research materials
│── interface   # Web & shell-based user interfaces
│── README.md   # Project description
```


## Prerequisites

- **PYNQ-Z2 FPGA** with PYNQ OS installed  
- **Xilinx Vivado & Vitis** for FPGA development  
- **Python 3.x** with PYNQ libraries  

## Installation  

Run these commands:   
```sh
git clone https://github.com/prxnav2005/ChaCha20-PYNQ.git  
cd ChaCha20-PYNQ  

pip install pynq  

python tools/test_chacha20.py  
```

# Roadmap

## Phase 1: Research & Planning
- [x] Understand the ChaCha20 algorithm
- [x] Study FPGA implementation strategies
- [x] Learn PYNQ framework and overlay development

## Phase 2: Initial Software Implementation
- [ ] Implement ChaCha20 in Python for verification
- [ ] Develop test cases and validate correctness

## Phase 3: Hardware Design
- [ ] Design ChaCha20 in SystemVerilog
- [ ] Simulate and verify functionality
- [ ] Optimize design for FPGA resource efficiency

## Phase 4: FPGA Integration
- [ ] Integrate the design with PYNQ
- [ ] Develop Python interface for hardware acceleration
- [ ] Test performance improvements

## Phase 5: User Interface
- [ ] Build CLI-based shell script for interaction
- [ ] Develop a web interface using Flask or Rust-based framework

## Phase 6: Optimization & Finalization
- [ ] Analyze FPGA resource usage and performance
- [ ] Optimize design for speed and efficiency
- [ ] Final testing and documentation

---

# References

- [Daniel J. Bernstein's Salsa20 Paper](https://cr.yp.to/snuffle/salsafamily-20071225.pdf)
- [Daniel J. Bernstein's ChaCha20 Paper](https://cr.yp.to/chacha/chacha-20080128.pdf)  
- [ChaCha20 on Wikipedia](https://en.wikipedia.org/wiki/Salsa20)  
- [PYNQ Official Documentation](http://www.pynq.io/documentation.html)  
- [Xilinx Vivado Documentation](https://www.xilinx.com/products/design-tools/vivado.html)  


