module chacha20_top(input logic clk, reset, start, input logic [255:0] key, input logic [31:0] counter, input logic [95:0] nonce, output logic [511:0] keystream, output logic done);
  
  logic [31:0] state [0:15];
  logic [31:0] keystream_words [0:15];
  
  chacha20_state DUT1(.clk(clk), .reset(reset), .key(key), .counter(counter), .nonce(nonce), .state(state));
  
  chacha20_block DUT2(.clk(clk), .reset(reset), .start(start), .state_in(state), .keystream(keystream_words), .done(done));
  
  generate
    genvar i;
    for(i = 0; i < 16; i++)
      begin
        assign keystream[i*32 +: 32] = keystream_words[i];
      end
  endgenerate
endmodule