`timescale 1ns / 1ps

// ============================================================================
// AXI-Lite Wrapper for ChaCha20 Core
// ----------------------------------------------------------------------------
// Register Map (byte offsets):
//   0x00        CONTROL   - bit[0] = start (write 1 to trigger, auto-clears)
//   0x04        STATUS    - bit[0] = done (1 = keystream ready)
//   0x08-0x24   KEY       - 8 x 32-bit words (KEY[0] at 0x08 ... KEY[7] at 0x24)
//   0x28-0x30   NONCE     - 3 x 32-bit words
//   0x34        COUNTER   - 32-bit block counter
//   0x38-0x74   KEYSTREAM - 16 x 32-bit words (read-only, valid when done=1)
// ============================================================================

module axi_chacha20 #(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 8
)(
    input  logic                          S_AXI_ACLK,
    input  logic                          S_AXI_ARESETN,   // Active-low reset
    input  logic [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input  logic                          S_AXI_AWVALID,
    output logic                          S_AXI_AWREADY,
    input  logic [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input  logic [3:0]                    S_AXI_WSTRB,
    input  logic                          S_AXI_WVALID,
    output logic                          S_AXI_WREADY,
    output logic [1:0]                    S_AXI_BRESP,
    output logic                          S_AXI_BVALID,
    input  logic                          S_AXI_BREADY,
    input  logic [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input  logic                          S_AXI_ARVALID,
    output logic                          S_AXI_ARREADY,
    output logic [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output logic [1:0]                    S_AXI_RRESP,
    output logic                          S_AXI_RVALID,
    input  logic                          S_AXI_RREADY
);
    logic [31:0] reg_key    [0:7]; 
    logic [31:0] reg_nonce  [0:2];  
    logic [31:0] reg_counter;       
    logic [31:0] reg_keystream [0:15]; 

    logic        core_start;          
    logic        core_done;
    logic [511:0] core_keystream;

    // AXI handshake internal signals
    logic [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr;
    logic                          axi_awready;
    logic                          axi_wready;
    logic [1:0]                    axi_bresp;
    logic                          axi_bvalid;
    logic [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr;
    logic                          axi_arready;
    logic [31:0]                   axi_rdata;
    logic [1:0]                    axi_rresp;
    logic                          axi_rvalid;

    logic aw_active; 
    logic w_active; 

    chacha20_top core (
        .clk       (S_AXI_ACLK),
        .reset     (~S_AXI_ARESETN),       // AXI uses active-low, core uses active-high
        .start     (core_start),
        .key       ({reg_key[7], reg_key[6], reg_key[5], reg_key[4],
                     reg_key[3], reg_key[2], reg_key[1], reg_key[0]}),
        .counter   (reg_counter),
        .nonce     ({reg_nonce[2], reg_nonce[1], reg_nonce[0]}),
        .keystream (core_keystream),
        .done      (core_done)
    );

    always_ff @(posedge S_AXI_ACLK) begin
        if (core_done) begin
            for (int i = 0; i < 16; i++)
                reg_keystream[i] <= core_keystream[i*32 +: 32];
        end
    end

    assign S_AXI_AWREADY = axi_awready;

    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_awready <= 1'b0;
            aw_active   <= 1'b0;
        end else begin
            if (!axi_awready && S_AXI_AWVALID && S_AXI_WVALID) begin
                axi_awready <= 1'b1;
                axi_awaddr  <= S_AXI_AWADDR;
                aw_active   <= 1'b1;
            end else begin
                axi_awready <= 1'b0;
            end
        end
    end

    assign S_AXI_WREADY = axi_wready;

    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_wready <= 1'b0;
            w_active   <= 1'b0;
        end else begin
            if (!axi_wready && S_AXI_WVALID && S_AXI_AWVALID) begin
                axi_wready <= 1'b1;
                w_active   <= 1'b1;
            end else begin
                axi_wready <= 1'b0;
            end
        end
    end

    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            reg_counter  <= 32'd1;
            core_start   <= 1'b0;
            for (int i = 0; i < 8; i++) reg_key[i]   <= 32'd0;
            for (int i = 0; i < 3; i++) reg_nonce[i] <= 32'd0;
        end else begin
            core_start <= 1'b0; // auto-clear every cycle

            if (axi_wready && S_AXI_WVALID && aw_active) begin
                case (axi_awaddr[7:2])
                    6'h00: core_start   <= S_AXI_WDATA[0]; // CONTROL - pulse start
                    // 6'h01 = STATUS (read-only, writes ignored)
                    6'h02: reg_key[0]   <= S_AXI_WDATA;    // 0x08
                    6'h03: reg_key[1]   <= S_AXI_WDATA;    // 0x0C
                    6'h04: reg_key[2]   <= S_AXI_WDATA;    // 0x10
                    6'h05: reg_key[3]   <= S_AXI_WDATA;    // 0x14
                    6'h06: reg_key[4]   <= S_AXI_WDATA;    // 0x18
                    6'h07: reg_key[5]   <= S_AXI_WDATA;    // 0x1C
                    6'h08: reg_key[6]   <= S_AXI_WDATA;    // 0x20
                    6'h09: reg_key[7]   <= S_AXI_WDATA;    // 0x24
                    6'h0A: reg_nonce[0] <= S_AXI_WDATA;    // 0x28
                    6'h0B: reg_nonce[1] <= S_AXI_WDATA;    // 0x2C
                    6'h0C: reg_nonce[2] <= S_AXI_WDATA;    // 0x30
                    6'h0D: reg_counter  <= S_AXI_WDATA;    // 0x34
                    default: ; // keystream registers are read-only
                endcase
            end
        end
    end

    assign S_AXI_BRESP  = axi_bresp;
    assign S_AXI_BVALID = axi_bvalid;

    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_bvalid <= 1'b0;
            axi_bresp  <= 2'b00;
        end else begin
            if (aw_active && w_active && !axi_bvalid) begin
                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b00; 
            end else if (S_AXI_BREADY && axi_bvalid) begin
                axi_bvalid <= 1'b0;
            end
        end
    end

    assign S_AXI_ARREADY = axi_arready;

    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_arready <= 1'b0;
            axi_araddr  <= '0;
        end else begin
            if (!axi_arready && S_AXI_ARVALID) begin
                axi_arready <= 1'b1;
                axi_araddr  <= S_AXI_ARADDR;
            end else begin
                axi_arready <= 1'b0;
            end
        end
    end

    assign S_AXI_RDATA  = axi_rdata;
    assign S_AXI_RRESP  = axi_rresp;
    assign S_AXI_RVALID = axi_rvalid;

    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_rvalid <= 1'b0;
            axi_rresp  <= 2'b00;
        end else begin
            if (axi_arready && S_AXI_ARVALID && !axi_rvalid) begin
                axi_rvalid <= 1'b1;
                axi_rresp  <= 2'b00; // OKAY
            end else if (axi_rvalid && S_AXI_RREADY) begin
                axi_rvalid <= 1'b0;
            end
        end
    end

    always_ff @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_rdata <= 32'd0;
        end else begin
            if (axi_arready && S_AXI_ARVALID) begin
                case (axi_araddr[7:2])
                    6'h00: axi_rdata <= {31'd0, core_start};  // CONTROL
                    6'h01: axi_rdata <= {31'd0, core_done};   // STATUS
                    6'h02: axi_rdata <= reg_key[0];
                    6'h03: axi_rdata <= reg_key[1];
                    6'h04: axi_rdata <= reg_key[2];
                    6'h05: axi_rdata <= reg_key[3];
                    6'h06: axi_rdata <= reg_key[4];
                    6'h07: axi_rdata <= reg_key[5];
                    6'h08: axi_rdata <= reg_key[6];
                    6'h09: axi_rdata <= reg_key[7];
                    6'h0A: axi_rdata <= reg_nonce[0];
                    6'h0B: axi_rdata <= reg_nonce[1];
                    6'h0C: axi_rdata <= reg_nonce[2];
                    6'h0D: axi_rdata <= reg_counter;
                    6'h0E: axi_rdata <= reg_keystream[0];    // 0x38
                    6'h0F: axi_rdata <= reg_keystream[1];    // 0x3C
                    6'h10: axi_rdata <= reg_keystream[2];    // 0x40
                    6'h11: axi_rdata <= reg_keystream[3];    // 0x44
                    6'h12: axi_rdata <= reg_keystream[4];    // 0x48
                    6'h13: axi_rdata <= reg_keystream[5];    // 0x4C
                    6'h14: axi_rdata <= reg_keystream[6];    // 0x50
                    6'h15: axi_rdata <= reg_keystream[7];    // 0x54
                    6'h16: axi_rdata <= reg_keystream[8];    // 0x58
                    6'h17: axi_rdata <= reg_keystream[9];    // 0x5C
                    6'h18: axi_rdata <= reg_keystream[10];   // 0x60
                    6'h19: axi_rdata <= reg_keystream[11];   // 0x64
                    6'h1A: axi_rdata <= reg_keystream[12];   // 0x68
                    6'h1B: axi_rdata <= reg_keystream[13];   // 0x6C
                    6'h1C: axi_rdata <= reg_keystream[14];   // 0x70
                    6'h1D: axi_rdata <= reg_keystream[15];   // 0x74
                    default: axi_rdata <= 32'hDEADBEEF;      // unmapped
                endcase
            end
        end
    end

endmodule
