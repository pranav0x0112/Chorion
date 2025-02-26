# ChaCha20 Hardware Accelerator on PYNQ FPGA  

## Overview  
This project aims to implement the **ChaCha20** encryption algorithm on the **PYNQ-Z2 FPGA**. ChaCha20 is a high-speed stream cipher used in modern cryptographic applications, known for its simplicity and security. The goal is to create a **hardware-accelerated** implementation that efficiently processes ChaCha20 operations on FPGA.  

## Features  
 **ChaCha20 Stream Cipher** – 20-round encryption implementation  
 **FPGA Acceleration** – Designed for efficient parallel processing  
 **Python API** – Interface for testing and verification  
 **Optimized for PYNQ** – Using FPGA hardware overlays  


ChaCha20-PYNQ

``` 
│── src         
│── tb            
│── tools         
│── docs          
│── README.md      
``` 
### Prerequisites  
- **PYNQ-Z2 FPGA** with PYNQ OS installed  
- **Vivado & Vitis** for FPGA development  
- **Python 3.x** with PYNQ libraries  

### Installation  
1. Clone the repository:  
   ```bash
   git clone https://github.com/prxnav2005/ChaCha20-PYNQ.git  
   cd ChaCha20-PYNQ 
   ```
2. Setup PYNQ environment:
    ```bash
    pip install pynq  
    ```
3. Run the Python test script:
    ```bash
    python tools/test_chacha20.py  
    ```

## Roadmap  

- [ ] **Phase 1**: Design ChaCha20 in **SystemVerilog**  
- [ ] **Phase 2**: Test encryption flow in software (Python)  
- [ ] **Phase 3**: Implement FPGA acceleration using PYNQ  
- [ ] **Phase 4**: Performance analysis and optimization  

## References  

- [RFC 8439 - ChaCha20 Specification](https://datatracker.ietf.org/doc/html/rfc8439)  
- [Daniel J. Bernstein's ChaCha20 Paper](https://cr.yp.to/chacha/chacha-20080128.pdf)  
- [ChaCha20 on Wikipedia](https://en.wikipedia.org/wiki/Salsa20#ChaCha_variant)  
- [PYNQ Official Documentation](https://pynq.readthedocs.io/en/latest/)  
- [Xilinx Vivado Documentation](https://www.xilinx.com/products/design-tools/vivado.html)  

