# Zynq 7000 SoC - Processing System (PS) Overview

The **Processing System (PS)** is the ARM-based core of the Zynq 7000 SoC, featuring a dual-core ARM Cortex-A9 processor and essential peripherals for managing communication, memory, and I/O. The PS handles general-purpose computation, system management, and coordination between the PS and PL sections.

## Key Components of PS:

- **ARM Cortex-A9 Cores**: Dual-core processor providing high-performance computation.
- **Memory Controllers**: Controllers for interfacing with external memory such as DDR and Flash.
- **I/O Peripherals**:
  - **UART**: For serial communication.
  - **SPI**: For serial peripheral interface.
  - **I2C**: For inter-integrated circuit communication.
  - **GPIO**: For general-purpose I/O operations.
- **Interrupt Controller**: Manages interrupts between the PS and PL, and within the PS.

## PS Architecture:
- **ARM Cortex-A9 Cores**: Execute system software and perform high-level operations.
- **L2 Cache**: A secondary cache for faster access to frequently used data.
- **Memory Subsystem**: Handles the DDR controller and external memory interfaces.
- **AXI Interfaces**: Used to communicate with various system components, including the PL.

## Boot Process:
1. **First-Stage Bootloader (FSBL)**: Initializes the PS, configures the PL, and loads the system's OS.
2. **PL Configuration**: The PL is configured with the bitstream after the PS is initialized.
3. **Operating System (OS) Loading**: The PS loads the OS (e.g., Linux), which runs on the ARM cores and controls the overall system.

## PS-to-PL Integration:
The PS and PL interact using the **AXI protocol**. The PS can configure the PL and control its operation via **AXI4-Lite**, while **AXI4** and **AXI Stream** are used for high-speed data transfers between the PS and PL.

