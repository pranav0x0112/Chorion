module chacha20_top(input logic clk, reset, start, input logic [255:0] key, input logic [31:0] counter, input logic [95:0] nonce, output logic [511:0] keystream, output logic done);
  
  logic [31:0] state [0:15];
  logic [31:0] keystream_words [0:15];
  
  assign state[0] = 32'h61707865;
  assign state[1] = 32'h3320646e;
  assign state[2] = 32'h79622d32;
  assign state[3] = 32'h6b206574;
  
  assign state[4] = key[31:0];
  assign state[5] = key[63:32];
  assign state[6]  = key[95:64];
  assign state[7]  = key[127:96];
  assign state[8]  = key[159:128];
  assign state[9]  = key[191:160];
  assign state[10] = key[223:192];
  assign state[11] = key[255:224];
  assign state[12] = counter;
  assign state[13] = nonce[31:0];
  assign state[14] = nonce[63:32];
  assign state[15] = nonce[95:64];
  
  chacha20_block DUT(.clk(clk), .reset(reset), .start(start), .state_in(state), .keystream(keystream_words), .done(done));
  
  generate
    genvar i;
    for(i = 0; i < 16; i++)
      begin
        assign keystream[i*32 +: 32] = keystream_words[i];
      end
  endgenerate
endmodule