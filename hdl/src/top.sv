`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// chacha20_top — AXI-Stream wrapper for the ChaCha20 block function
//
// Designed to sit between two AXIS Data FIFOs (Vivado IP) which handle all
// tvalid/tready handshaking and backpressure.  This module only needs to:
//   • Read 12 words from the input FIFO when data is available
//   • Drive the core via start/done
//   • Write 16 keystream words into the output FIFO
//
// Input stream  (S_AXIS, 32-bit):  12 words
//   words  0-7  : key[0..7]    (little-endian 32-bit, word 0 = key bytes 0-3)
//   words  8-10 : nonce[0..2]  (little-endian 32-bit)
//   word  11    : counter       (TLAST must be asserted here)
//
// Output stream (M_AXIS, 32-bit): 16 words
//   words  0-15 : keystream[0..15]  (TLAST asserted on word 15)
// -----------------------------------------------------------------------------
module chacha20_top (
    input  logic        aclk,
    input  logic        aresetn,       // active-low synchronous reset

    // Slave AXI-Stream (input: key + nonce + counter)
    input  logic [31:0] s_axis_tdata,
    input  logic        s_axis_tvalid,
    output logic        s_axis_tready,
    input  logic        s_axis_tlast,

    // Master AXI-Stream (output: keystream)
    output logic [31:0] m_axis_tdata,
    output logic        m_axis_tvalid,
    input  logic        m_axis_tready,
    output logic        m_axis_tlast
);

    // ── Internal state registers ───────────────────────────────────────────
    logic [31:0] key     [0:7];
    logic [31:0] nonce   [0:2];
    logic [31:0] counter_reg;

    // ── Sub-module signals ─────────────────────────────────────────────────
    logic [255:0] key_flat;
    logic [95:0]  nonce_flat;
    logic [31:0]  state_words [0:15];
    logic [31:0]  keystream   [0:15];
    logic         state_enable;   // pulses to load state_inst
    logic         block_start;    // pulses to start block_inst (1 cycle after state_enable)
    logic         core_done;      // block_inst computation complete

    // Pack key/nonce flat vectors for state module
    // key[0] → key_flat[31:0], key[7] → key_flat[255:224]
    genvar gi;
    generate
        for (gi = 0; gi < 8; gi++) begin : pack_key
            assign key_flat[gi*32 +: 32] = key[gi];
        end
        for (gi = 0; gi < 3; gi++) begin : pack_nonce
            assign nonce_flat[gi*32 +: 32] = nonce[gi];
        end
    endgenerate

    chacha20_state state_inst (
        .clk     (aclk),
        .reset   (~aresetn),
        .enable  (state_enable),
        .key     (key_flat),
        .counter (counter_reg),
        .nonce   (nonce_flat),
        .state   (state_words)
    );

    chacha20_block block_inst (
        .clk      (aclk),
        .reset    (~aresetn),
        .start    (block_start),
        .state_in (state_words),
        .keystream(keystream),
        .done     (core_done)
    );

    // ── FSM ───────────────────────────────────────────────────────────────
    // Three states.  The upstream AXIS Data FIFO guarantees tvalid is only
    // asserted when data is present, so we never stall the FIFO — just
    // consume words whenever tvalid is high in RECV.
    // The downstream AXIS Data FIFO accepts data whenever its tready is high;
    // we keep tvalid asserted in SEND and only advance when the FIFO accepts.
    typedef enum logic [1:0] {
        RECV    = 2'd0,
        COMPUTE = 2'd1,
        SEND    = 2'd2
    } state_t;

    state_t fsm;
    logic [3:0] word_cnt;
    logic       state_loaded;

    always_ff @(posedge aclk) begin
        if (~aresetn) begin
            fsm          <= RECV;
            word_cnt     <= 4'd0;
            state_enable <= 1'b0;
            block_start  <= 1'b0;
            state_loaded <= 1'b0;
        end else begin
            state_enable <= 1'b0;
            block_start  <= 1'b0;

            case (fsm)

                RECV: begin
                    // Accept a word whenever the upstream FIFO has one ready.
                    // tready is hardwired high in RECV, so every tvalid is a transfer.
                    if (s_axis_tvalid) begin
                        if (word_cnt <= 4'd7)
                            key[word_cnt]          <= s_axis_tdata;
                        else if (word_cnt <= 4'd10)
                            nonce[word_cnt - 4'd8] <= s_axis_tdata;
                        else
                            counter_reg            <= s_axis_tdata;

                        if (word_cnt == 4'd11) begin
                            word_cnt     <= 4'd0;
                            state_enable <= 1'b1;   // latch key/nonce/ctr into state_inst
                            state_loaded <= 1'b0;
                            fsm          <= COMPUTE;
                        end else begin
                            word_cnt <= word_cnt + 4'd1;
                        end
                    end
                end

                COMPUTE: begin
                    if (!state_loaded) begin
                        // One cycle after state_enable: state_words are stable
                        block_start  <= 1'b1;
                        state_loaded <= 1'b1;
                    end else if (core_done) begin
                        word_cnt <= 4'd0;
                        fsm      <= SEND;
                    end
                end

                SEND: begin
                    // Drive tvalid=1; advance only when downstream FIFO accepts
                    if (m_axis_tready) begin
                        if (word_cnt == 4'd15) begin
                            word_cnt <= 4'd0;
                            fsm      <= RECV;
                        end else begin
                            word_cnt <= word_cnt + 4'd1;
                        end
                    end
                end

                default: fsm <= RECV;

            endcase
        end
    end

    // ── Output assignments ─────────────────────────────────────────────────
    // In RECV: tready=1 always — the upstream FIFO handles backpressure.
    // In SEND: tvalid=1 always — the downstream FIFO handles flow control.
    assign s_axis_tready = (fsm == RECV);
    assign m_axis_tvalid = (fsm == SEND);
    assign m_axis_tdata  = keystream[word_cnt];
    assign m_axis_tlast  = (fsm == SEND) && (word_cnt == 4'd15);

endmodule