`timescale 1ns / 1ps

module chacha20_top_tb;
  
  logic clk;
  logic reset;
  logic start;
  logic [255:0] key;
  logic [31:0] counter;
  logic [95:0] nonce;
  logic [511:0] keystream;
  logic done;

  chacha20_top DUT(
    .clk(clk), 
    .reset(reset), 
    .start(start), 
    .key(key), 
    .counter(counter), 
    .nonce(nonce), 
    .keystream(keystream), 
    .done(done)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    $display("Starting ChaCha20 Top Module Test...");

    reset = 1;
    start = 0;
    key = 256'h1f1e1d1c_1b1a1918_17161514_13121110_0f0e0d0c_0b0a0908_07060504_03020100;
    nonce = 96'h00000000_4a000000_09000000;  // nonce[95:64]=0, [63:32]=0x4a000000, [31:0]=0x09000000
    counter = 32'h00000001;

    #20 reset = 0;
    $display("Reset released at time %0t", $time);

    #30;

    $display("Starting encryption at time %0t", $time);
    start = 1;
    
    repeat(3) @(posedge clk);
    start = 0;
    #1; 
    
    $display("Waiting for 20 rounds to complete...");
    $display("Initial state check:");
    $display("  State[0] = %h (should be 61707865)", DUT.state[0]);
    $display("  State[4] = %h (should be 03020100)", DUT.state[4]);
    $display("  State[12] = %h (should be 00000001)", DUT.state[12]);

    #10;
    $display("After start pulse - done=%b", done);

    repeat (30) begin
      @(posedge clk);
      if (DUT.block_inst.processing) begin
        $display("  Round %0d at time %0t", DUT.block_inst.round_counter, $time);
      end
      if (done) break;
    end

    fork
      begin
        wait(done);
        @(posedge clk);  
        $display("Encryption completed at time %0t", $time);
        $display("Debug - checking block internals:");
        $display("  initial_state[0] = %h", DUT.block_inst.initial_state[0]);
        $display("  state_reg[0] = %h", DUT.block_inst.state_reg[0]);
        $display("Keystream generated:");
        $display("  Word  0: %h", keystream[31:0]);
        $display("  Word  1: %h", keystream[63:32]);
        $display("  Word  2: %h", keystream[95:64]);
        $display("  Word  3: %h", keystream[127:96]);
        $display("  Word  4: %h", keystream[159:128]);
        $display("  Word  5: %h", keystream[191:160]);
        $display("  Word  6: %h", keystream[223:192]);
        $display("  Word  7: %h", keystream[255:224]);
        $display("  Word  8: %h", keystream[287:256]);
        $display("  Word  9: %h", keystream[319:288]);
        $display("  Word 10: %h", keystream[351:320]);
        $display("  Word 11: %h", keystream[383:352]);
        $display("  Word 12: %h", keystream[415:384]);
        $display("  Word 13: %h", keystream[447:416]);
        $display("  Word 14: %h", keystream[479:448]);
        $display("  Word 15: %h", keystream[511:480]);
      end
      begin
        #500000;  
        $display("ERROR: Timeout waiting for 'done' signal at time %0t", $time);
        $display("Check if the design is stuck in processing");
      end
    join_any
    
    #100;
    $display("Test completed at time %0t", $time);
    $finish;
  end
  
endmodule