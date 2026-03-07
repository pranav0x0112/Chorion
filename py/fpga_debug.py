#!/usr/bin/env python3
"""
ChaCha20 FPGA Debug Script — run directly on PYNQ over SSH.

Usage (on the board, as root):
    sudo su -
    /usr/local/share/pynq-venv/bin/python3 /home/xilinx/fpga_debug.py [bitfile]

Default bitfile: /home/xilinx/jupyter_notebooks/chacha20.bit
"""

import sys
import time

BITFILE   = sys.argv[1] if len(sys.argv) > 1 else '/home/xilinx/jupyter_notebooks/chacha20.bit'
BASE_ADDR = 0x40000000   # axi_chacha20_0 base address from Vivado block design
ADDR_SPAN = 0x10000      # 64 KB window

# ─── Register offsets (byte addresses) ───────────────────────────────────────
REG_CONTROL   = 0x00
REG_STATUS    = 0x04
REG_KEY       = [0x08 + i * 4 for i in range(8)]
REG_NONCE     = [0x28 + i * 4 for i in range(3)]
REG_COUNTER   = 0x34
REG_KEYSTREAM = [0x38 + i * 4 for i in range(16)]

# ─── Module-level MMIO accessors (initialised in main) ───────────────────────
_mmio = None

def rd(offset):
    return _mmio.read(offset)

def wr(offset, val):
    _mmio.write(offset, val)


# ─── RFC 8439 Section 2.4.2 test vector ──────────────────────────────────────
# Key bytes 00..1f as little-endian 32-bit words (written directly to reg_key)
rfc_key = [
    0x03020100, 0x07060504, 0x0b0a0908, 0x0f0e0d0c,
    0x13121110, 0x17161514, 0x1b1a1918, 0x1f1e1d1c,
]
# Nonce bytes 000000090000004a00000000 as LE32 words
rfc_nonce = [0x09000000, 0x4a000000, 0x00000000]
counter = 1

# Expected keystream (RFC 8439 §2.4.2)
EXPECTED = [
    0xe4e7f110, 0x15593bd1, 0x1fdd0f50, 0xc47120a3,
    0xc7f4d1c7, 0x0368c033, 0x9aaa2204, 0x4e6cd4c3,
    0x466482d2, 0x09aa9f07, 0x05d7c214, 0xa2028bd9,
    0xd19c12b5, 0xb94e16de, 0xe883d0cb, 0x4e3c50a2,
]


def sep(label=""):
    print(f"\n{'─'*55}", flush=True)
    if label:
        print(f"  {label}", flush=True)
        print(f"{'─'*55}", flush=True)


def poll_done(max_ms=100):
    """
    Poll STATUS register until done=1 or timeout.
    Returns (done_flag, elapsed_ms, poll_iterations).
    50 µs sleep between polls — won't starve the Zynq CPU.
    """
    deadline   = time.perf_counter() + max_ms / 1000
    iterations = 0
    while time.perf_counter() < deadline:
        val = rd(REG_STATUS)
        iterations += 1
        if val & 0x1:
            elapsed = (max_ms / 1000 - (deadline - time.perf_counter())) * 1000
            return True, elapsed, iterations
        time.sleep(0.000050)   # 50 µs between polls
    return False, max_ms, iterations


def run_core(key, nonce, ctr, label="", clear_delay_ms=2):
    """
    Write inputs → trigger core → wait for done → return (ok, keystream).
    clear_delay_ms: sleep after CONTROL=1 so stale done from previous run clears.
    """
    if label:
        print(f"\n[{label}]  counter={ctr:#010x}", flush=True)

    for i, w in enumerate(key):   wr(REG_KEY[i],   w)
    for i, w in enumerate(nonce): wr(REG_NONCE[i], w)
    wr(REG_COUNTER, ctr)
    # Reset pulse: clear any stale done/start state, then assert start
    wr(REG_CONTROL, 0)
    time.sleep(0.000001)          # 1 µs — just enough for FSM to see deassert
    wr(REG_CONTROL, 1)

    # Core runs in ~240 ns; sleep ensures done is stable before poll
    time.sleep(clear_delay_ms / 1000)

    ok, elapsed_ms, iters = poll_done(max_ms=500)
    if label:
        print(f"  done={'YES' if ok else 'TIMEOUT'}  poll_iters={iters}  ~{elapsed_ms:.1f} ms after sleep", flush=True)

    ks = [rd(REG_KEYSTREAM[i]) for i in range(16)]
    return ok, ks


def main():
    global _mmio

    # ── 1. Program PL directly — bypasses Overlay/hwh/pkl cache entirely ──────
    sep("1. Program PL")
    print(f"  Bitfile : {BITFILE}")
    print(f"  Method  : pynq.Bitstream (no IP-discovery cache)")
    try:
        from pynq import Bitstream, MMIO
        # Release any existing MMIO mapping before reprogramming
        global _mmio
        if _mmio is not None:
            del _mmio
            _mmio = None
        bs = Bitstream(BITFILE)
        bs.download()
        time.sleep(0.5)   # let AXI interconnect settle after PL reprogram
        print("  PL programmed OK", flush=True)
    except Exception as e:
        print(f"  FAILED: {e}")
        sys.exit(1)

    # ── 2. Map registers at known base address ─────────────────────────────────
    sep("2. MMIO at 0x40000000")
    try:
        _mmio = MMIO(BASE_ADDR, ADDR_SPAN)
        print(f"  MMIO window: {hex(BASE_ADDR)} + {hex(ADDR_SPAN)}")
    except Exception as e:
        print(f"  FAILED to map address: {e}")
        sys.exit(1)

    # ── 3. AXI sanity — write / read-back key registers ───────────────────────
    sep("3. AXI Sanity (write/read-back key regs)")
    sanity_ok = True
    for i, v in enumerate(rfc_key):
        wr(REG_KEY[i], v)
        rb = rd(REG_KEY[i])
        ok = rb == v
        if not ok:
            sanity_ok = False
        print(f"  key[{i}]: wrote {v:08x}  read {rb:08x}  {'OK' if ok else 'MISMATCH'}")
    print(f"\n  AXI bus: {'OK' if sanity_ok else 'BROKEN — stop here'}")
    if not sanity_ok:
        sys.exit(1)

    # ── 4. RFC 8439 correctness test ──────────────────────────────────────────
    sep("4. RFC 8439 Correctness Test")
    ok, ks = run_core(rfc_key, rfc_nonce, counter, label="RFC test", clear_delay_ms=2)

    if not ok:
        print("\n  TIMEOUT — done never asserted. Possible causes:", flush=True)
        print("    • core_start pulse not triggering FSM", flush=True)
        print("    • block.sv FSM stuck from a previous bad run", flush=True)
        print("    • Try re-running the script (step 1 reprograms PL each time)", flush=True)
        sys.exit(1)

    print("\n  Keystream vs expected:")
    passed = True
    for i, (got, exp) in enumerate(zip(ks, EXPECTED)):
        tag = "OK" if got == exp else f"FAIL  (got {got:08x})"
        print(f"    word[{i:2d}]: expected {exp:08x}  {tag}")
        if got != exp:
            passed = False

    print()
    if passed:
        print("  *** ALL 16 WORDS MATCH — hardware is RFC 8439 compliant! ***")
    else:
        print("  MISMATCH — checking common endian mistakes:")
        print("    raw output: " + " ".join(f"{w:08x}" for w in ks))
        ks_bswap = [((w&0xFF)<<24)|((w&0xFF00)<<8)|((w>>8)&0xFF00)|((w>>24)&0xFF) for w in ks]
        if ks_bswap == EXPECTED:
            print("    HINT: bswap(output) == expected → byte order flipped in keystream regs")
        if list(reversed(ks)) == EXPECTED:
            print("    HINT: reversed(output) == expected → word order flipped")

    # ── 5. Repeatability test ─────────────────────────────────────────────────
    sep("5. Repeatability Test (same inputs, second run)")
    ok2, ks2 = run_core(rfc_key, rfc_nonce, counter, label="repeat", clear_delay_ms=2)
    same = (ks2 == ks)
    print(f"  Output same as first run: {'YES' if same else 'NO — non-deterministic!'}")
    if not same:
        print("  First:  " + " ".join(f"{w:08x}" for w in ks))
        print("  Second: " + " ".join(f"{w:08x}" for w in ks2))

    # ── 6. Counter increment test ─────────────────────────────────────────────
    sep("6. Counter Increment Test")
    _, ks_c1 = run_core(rfc_key, rfc_nonce, 1, label="counter=1", clear_delay_ms=2)
    _, ks_c2 = run_core(rfc_key, rfc_nonce, 2, label="counter=2", clear_delay_ms=2)
    different = (ks_c1 != ks_c2)
    print(f"\n  counter=1 word[0]: {ks_c1[0]:08x}")
    print(f"  counter=2 word[0]: {ks_c2[0]:08x}")
    print(f"  Different outputs for different counters: {'YES (correct)' if different else 'NO (broken!)'}")

    # ── 7. FPGA timing: write+trigger+poll (no readback in tight loop) ───────
    N          = 20
    BLOCK_BYTES = 64
    sep(f"7. FPGA Timing ({N} runs, write+trigger+poll, no readback)")
    t0 = time.perf_counter()
    for c in range(N):
        for i, w in enumerate(rfc_key):   wr(REG_KEY[i],   w)
        for i, w in enumerate(rfc_nonce): wr(REG_NONCE[i], w)
        wr(REG_COUNTER, c + 1)
        wr(REG_CONTROL, 0)             # reset pulse
        time.sleep(0.000001)
        wr(REG_CONTROL, 1)
        time.sleep(0.002)              # 2 ms: ensures done deasserts before polling
        poll_done(max_ms=500)
    t1 = time.perf_counter()
    fpga_ms_blk = (t1 - t0) * 1000 / N
    fpga_mbps   = (BLOCK_BYTES / (fpga_ms_blk / 1000)) / 1e6
    print(f"  {fpga_ms_blk:.2f} ms/block  =>  {fpga_mbps:.3f} MB/s  (AXI-limited, incl. 2 ms sync sleep)", flush=True)
    axi_only_ms = fpga_ms_blk - 2.0          # subtract the forced sleep
    axi_mbps    = (BLOCK_BYTES / (axi_only_ms / 1000)) / 1e6
    print(f"  AXI overhead only (subtract 2 ms sleep): {axi_only_ms:.2f} ms/block  =>  {axi_mbps:.3f} MB/s", flush=True)

    # ── 8. ARM software ChaCha20 (pure Python) ───────────────────────────────
    sep(f"8. ARM Software Timing ({N} runs, pure Python ChaCha20)")
    def _rotl32(v, n): return ((v << n) | (v >> (32 - n))) & 0xFFFFFFFF
    def _qr(a, b, c, d):
        a=(a+b)&0xFFFFFFFF; d^=a; d=_rotl32(d,16)
        c=(c+d)&0xFFFFFFFF; b^=c; b=_rotl32(b,12)
        a=(a+b)&0xFFFFFFFF; d^=a; d=_rotl32(d, 8)
        c=(c+d)&0xFFFFFFFF; b^=c; b=_rotl32(b, 7)
        return a, b, c, d
    def chacha20_sw(key, ctr, nonce):
        C  = [0x61707865, 0x3320646e, 0x79622d32, 0x6b206574]
        st = C + list(key) + [ctr] + list(nonce); x = st[:]
        for _ in range(10):
            x[0],x[4],x[8],x[12]  = _qr(x[0],x[4],x[8],x[12])
            x[1],x[5],x[9],x[13]  = _qr(x[1],x[5],x[9],x[13])
            x[2],x[6],x[10],x[14] = _qr(x[2],x[6],x[10],x[14])
            x[3],x[7],x[11],x[15] = _qr(x[3],x[7],x[11],x[15])
            x[0],x[5],x[10],x[15] = _qr(x[0],x[5],x[10],x[15])
            x[1],x[6],x[11],x[12] = _qr(x[1],x[6],x[11],x[12])
            x[2],x[7],x[8],x[13]  = _qr(x[2],x[7],x[8],x[13])
            x[3],x[4],x[9],x[14]  = _qr(x[3],x[4],x[9],x[14])
        return [(x[i]+st[i])&0xFFFFFFFF for i in range(16)]
    t0 = time.perf_counter()
    for c in range(N):
        chacha20_sw(rfc_key, c + 1, rfc_nonce)
    t1 = time.perf_counter()
    sw_ms_blk = (t1 - t0) * 1000 / N
    sw_mbps   = (BLOCK_BYTES / (sw_ms_blk / 1000)) / 1e6
    print(f"  {sw_ms_blk:.2f} ms/block  =>  {sw_mbps:.3f} MB/s", flush=True)

    # ── 9. Comparison table ───────────────────────────────────────────────────
    core_ns   = 20 / 100e6 * 1e9          # 20 cycles @ 100 MHz
    core_mbps = (BLOCK_BYTES / (core_ns * 1e-9)) / 1e6
    sep("9. Performance Summary")
    W = 58
    print(f"  {'Metric':<33}  {'ms/block':>9}  {'MB/s':>8}", flush=True)
    print(f"  {'-'*33}  {'-'*9}  {'-'*8}", flush=True)
    print(f"  {'FPGA core (theoretical, 20 cyc@100MHz)':<33}  {core_ns/1e6:>9.6f}  {core_mbps:>8.0f}", flush=True)
    print(f"  {'FPGA AXI overhead only':<33}  {axi_only_ms:>9.3f}  {axi_mbps:>8.3f}", flush=True)
    print(f"  {'ARM Python (software)':<33}  {sw_ms_blk:>9.3f}  {sw_mbps:>8.3f}", flush=True)
    print(flush=True)
    print(f"  Core speedup vs Python   :  {core_mbps/sw_mbps:>8.0f}x  (pure compute)", flush=True)
    print(f"  AXI speedup vs Python    :  {axi_mbps/sw_mbps:>8.2f}x  (excl. forced sleep)", flush=True)
    print(flush=True)
    print(f"  ★ RTL core is ~{core_mbps/sw_mbps:.0f}x faster than Python — but the", flush=True)
    print(f"    AXI bus ({8+3+1+1} writes/block) costs {axi_only_ms:.2f} ms, dominating latency.", flush=True)

    sep("Done")


if __name__ == "__main__":
    main()
