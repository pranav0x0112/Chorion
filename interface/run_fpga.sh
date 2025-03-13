#!/bin/bash

# run_fpga.sh: Load bitstream and run FPGA tests

echo "Loading ChaCha20 bitstream onto FPGA..."

BITSTREAM_PATH = "../bitstreams/chacha20.bit"
if [[ ! -f "$BITSTREAM_PATH" ]]; then
    echo "Error: Bitstream not found at $BITSTREAM_PATH"
    exit 1
fi

sudo cat "$BITSTREAM_PATH" > /dev/xdevcfg
echo "Running FPGA test script..."
python3 ../py/fpga_test.py


