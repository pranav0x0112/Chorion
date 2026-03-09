`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// chacha20_top_tb — AXI-Stream testbench (FIFO-backed model)
//
// Models upstream/downstream AXIS Data FIFOs:
//   • Upstream  (TX): drives tvalid/tdata, waits for tready from DUT
//   • Downstream (RX): m_axis_tready held high (FIFO always has space)
//
// Tests RFC 8439 §2.4.2 test vector.
// -----------------------------------------------------------------------------
module chacha20_top_tb;

    // ── Clock & reset ──────────────────────────────────────────────────────
    logic aclk    = 0;
    logic aresetn = 0;
    always #5 aclk = ~aclk;   // 100 MHz

    // ── AXI-Stream signals ─────────────────────────────────────────────────
    logic [31:0] s_axis_tdata  = 0;
    logic        s_axis_tvalid = 0;
    logic        s_axis_tready;
    logic        s_axis_tlast  = 0;

    logic [31:0] m_axis_tdata;
    logic        m_axis_tvalid;
    logic        m_axis_tready = 1;   // downstream FIFO always ready
    logic        m_axis_tlast;

    // ── DUT ────────────────────────────────────────────────────────────────
    chacha20_top DUT (
        .aclk          (aclk),
        .aresetn       (aresetn),
        .s_axis_tdata  (s_axis_tdata),
        .s_axis_tvalid (s_axis_tvalid),
        .s_axis_tready (s_axis_tready),
        .s_axis_tlast  (s_axis_tlast),
        .m_axis_tdata  (m_axis_tdata),
        .m_axis_tvalid (m_axis_tvalid),
        .m_axis_tready (m_axis_tready),
        .m_axis_tlast  (m_axis_tlast)
    );

    // ── RFC 8439 §2.4.2 test vectors ──────────────────────────────────────
    // Input: 12 words in stream order (key[0..7], nonce[0..2], counter)
    logic [31:0] input_words [0:11] = '{
        32'h03020100, 32'h07060504, 32'h0b0a0908, 32'h0f0e0d0c,  // key[0..3]
        32'h13121110, 32'h17161514, 32'h1b1a1918, 32'h1f1e1d1c,  // key[4..7]
        32'h09000000, 32'h4a000000, 32'h00000000,                 // nonce[0..2]
        32'h00000001                                               // counter
    };

    // Expected keystream (RFC 8439 §2.4.2)
    logic [31:0] expected [0:15] = '{
        32'he4e7f110, 32'h15593bd1, 32'h1fdd0f50, 32'hc47120a3,
        32'hc7f4d1c7, 32'h0368c033, 32'h9aaa2204, 32'h4e6cd4c3,
        32'h466482d2, 32'h09aa9f07, 32'h05d7c214, 32'ha2028bd9,
        32'hd19c12b5, 32'hb94e16de, 32'he883d0cb, 32'h4e3c50a2
    };

    // ── Received keystream storage ─────────────────────────────────────────
    logic [31:0] received [0:15];

    // ── Task: send one word — models upstream AXIS FIFO output ────────────
    // FIFO presents data with tvalid=1 and waits for tready from DUT.
    task automatic fifo_send(input logic [31:0] data, input logic last);
        @(posedge aclk);           // align to clock edge first
        s_axis_tdata  = data;
        s_axis_tvalid = 1'b1;
        s_axis_tlast  = last;
        // Wait until DUT accepts (tready high on this or a future posedge)
        while (!s_axis_tready) @(posedge aclk);
        @(posedge aclk);           // one more cycle so DUT latches the word
        s_axis_tvalid = 1'b0;
        s_axis_tlast  = 1'b0;
    endtask

    // ── Main test ──────────────────────────────────────────────────────────
    integer i;
    integer pass_count;

    initial begin
        $display("=== ChaCha20 AXI-Stream TB — RFC 8439 §2.4.2 ===");

        // Reset
        aresetn = 0;
        repeat (4) @(posedge aclk);
        aresetn = 1;
        repeat (2) @(posedge aclk);
        $display("Reset released at %0t ns", $time);

        // ── Send 12-word input stream (upstream FIFO model) ────────────────
        $display("Sending 12-word input stream...");
        for (i = 0; i < 12; i++)
            fifo_send(input_words[i], (i == 11));
        $display("Input stream sent at %0t ns", $time);

        // ── Receive 16-word output stream (downstream FIFO model) ──────────
        // m_axis_tready is held high; capture each word when tvalid fires.
        $display("Waiting for keystream output...");
        for (i = 0; i < 16; i++) begin
            @(posedge aclk);
            while (!m_axis_tvalid) @(posedge aclk);
            received[i] = m_axis_tdata;
        end
        $display("Keystream received at %0t ns", $time);

        // ── Check results ──────────────────────────────────────────────────
        $display("");
        $display("Word  Got       Expected   Result");
        $display("----  ---------  ---------  ------");
        pass_count = 0;
        for (i = 0; i < 16; i++) begin
            if (received[i] === expected[i]) begin
                $display("  %2d  %08h   %08h   OK", i, received[i], expected[i]);
                pass_count++;
            end else begin
                $display("  %2d  %08h   %08h   FAIL <<<", i, received[i], expected[i]);
            end
        end
        $display("");
        if (pass_count == 16)
            $display("ALL 16 WORDS MATCH — RFC 8439 compliant!");
        else
            $display("FAILED: %0d/16 words correct", pass_count);

        #100;
        $finish;
    end

    // ── Timeout watchdog ───────────────────────────────────────────────────
    initial begin
        #500_000_000;
        $display("ERROR: Timeout at %0t ns", $time);
        $finish;
    end

endmodule