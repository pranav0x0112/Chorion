# Requirements

This document lists the hardware, software, and tools required to implement and test cryptographic algorithms (AES and SHA) on the PYNQ FPGA.

---

## 1. Hardware Requirements
- **PYNQ FPGA Board** (e.g., PYNQ-Z1 or PYNQ-Z2)
- USB cable for connecting the FPGA to the host system
- Host machine with **Linux** (recommended) or Windows OS

---

## 2. Software Requirements
### a) FPGA Toolchain
- **Xilinx Vivado Design Suite**  
  - Version: 2021.1 or higher  
  - Used for:  
    - Writing SystemVerilog code for AES and SHA  
    - Synthesizing and generating bitstreams for the PYNQ FPGA  

### b) PYNQ OS
- Pre-installed **PYNQ OS** on the FPGA board
  - Download from [PYNQ Downloads](http://www.pynq.io/board.html)  

---

## 3. Python Environment
Python is required to interact with the PYNQ FPGA and test the hardware design.

### Python Version
- **Python 3.8** or higher  

### Python Dependencies
Install the following Python libraries in your environment:

