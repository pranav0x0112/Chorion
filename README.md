# Chorion - ChaCha20 FPGA Accelerator

## Overview

Hardware implementation of the **ChaCha20 stream cipher** on the **PYNQ-Z2 FPGA** (Xilinx Zynq-7000 SoC).

ChaCha20 is a high-speed stream cipher designed by Daniel J. Bernstein, widely used for its security and performance.

**Target Platform:** PYNQ-Z2 (XC7Z020CLG400-1)  
**HDL:** SystemVerilog  
**Algorithm:** ChaCha20 (20 rounds, RFC 8439 compliant)

## Features

- **Pure HDL Core** – Iterative 20-round ChaCha20 block function
- **Simulation Verified** – 100% match with RFC 8439 test vectors
- **Synthesizable** – 2,118 LUTs (10%), 1,807 FFs (4%) on Artix-7 equivalent
- **Python Reference** – Complete software implementation for validation

## References

### Algorithm Specification
- [RFC 8439 - ChaCha20 and Poly1305](https://datatracker.ietf.org/doc/html/rfc8439)
- [ChaCha, a variant of Salsa20 (D. J. Bernstein, 2008)](https://cr.yp.to/chacha/chacha-20080128.pdf)
- [The Salsa20 family of stream ciphers](https://cr.yp.to/snuffle/salsafamily-20071225.pdf)

### Hardware Platform
- [PYNQ-Z2 Board Documentation](http://www.pynq.io/board.html)
- [Zynq-7000 SoC Technical Reference Manual (UG585)](https://www.xilinx.com/support/documentation/user_guides/ug585-Zynq-7000-TRM.pdf)
- [PYNQ Documentation](http://pynq.readthedocs.io/)  


