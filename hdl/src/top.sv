`timescale 1ns / 1ps

module chacha20_top(
  input  logic clk, 
  input  logic reset, 
  input  logic start, 
  input  logic [255:0] key, 
  input  logic [31:0] counter, 
  input  logic [95:0] nonce, 
  output logic [511:0] keystream, 
  output logic done
);
  
  logic [31:0] state [0:15];
  logic [31:0] keystream_words [0:15];
  logic state_loaded;
  logic block_start;
  
  chacha20_state state_inst (
    .clk(clk), 
    .reset(reset), 
    .enable(start),  // Load state when start is asserted
    .key(key), 
    .counter(counter), 
    .nonce(nonce), 
    .state(state)
  );
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state_loaded <= 1'b0;
      block_start <= 1'b0;
    end else begin
      if (start && !state_loaded) begin
        state_loaded <= 1'b1;  
        block_start <= 1'b0;
      end else if (state_loaded && !block_start) begin
        block_start <= 1'b1;   
      end else begin
        block_start <= 1'b0;
        if (!start) state_loaded <= 1'b0;  
      end
    end
  end

  chacha20_block block_inst (
    .clk(clk), 
    .reset(reset), 
    .start(block_start),  
    .state_in(state), 
    .keystream(keystream_words), 
    .done(done)
  );
  
  generate
    genvar i;
    for (i = 0; i < 16; i++) begin : pack_keystream
      assign keystream[i*32 +: 32] = keystream_words[i];
    end
  endgenerate
  
endmodule