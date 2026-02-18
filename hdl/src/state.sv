`timescale 1ns / 1ps

module chacha20_state(
  input  logic clk, 
  input  logic reset,
  input  logic enable, 
  input  logic [255:0] key, 
  input  logic [31:0] counter, 
  input  logic [95:0] nonce, 
  output logic [31:0] state [0:15]
);
  
  localparam logic [31:0] C0 = 32'h61707865;  
  localparam logic [31:0] C1 = 32'h3320646e;  
  localparam logic [31:0] C2 = 32'h79622d32;  
  localparam logic [31:0] C3 = 32'h6b206574; 
  
  integer i;
  
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      for (i = 0; i < 16; i = i + 1) begin
        state[i] <= 32'h0;
      end
    end else if (enable) begin
      // Constants
      state[0]  <= C0;
      state[1]  <= C1;
      state[2]  <= C2;
      state[3]  <= C3;
      state[4]  <= {key[231:224], key[239:232], key[247:240], key[255:248]};  // bytes 0-3
      state[5]  <= {key[199:192], key[207:200], key[215:208], key[223:216]};  // bytes 4-7
      state[6]  <= {key[167:160], key[175:168], key[183:176], key[191:184]};  // bytes 8-11
      state[7]  <= {key[135:128], key[143:136], key[151:144], key[159:152]};  // bytes 12-15
      state[8]  <= {key[103:96], key[111:104], key[119:112], key[127:120]};   // bytes 16-19
      state[9]  <= {key[71:64], key[79:72], key[87:80], key[95:88]};          // bytes 20-23
      state[10] <= {key[39:32], key[47:40], key[55:48], key[63:56]};          // bytes 24-27
      state[11] <= {key[7:0], key[15:8], key[23:16], key[31:24]};             // bytes 28-31
      // Counter (32 bits = 1 word)
      state[12] <= counter;
      state[13] <= {nonce[71:64], nonce[79:72], nonce[87:80], nonce[95:88]};  // bytes 0-3
      state[14] <= {nonce[39:32], nonce[47:40], nonce[55:48], nonce[63:56]};  // bytes 4-7
      state[15] <= {nonce[7:0], nonce[15:8], nonce[23:16], nonce[31:24]};     // bytes 8-11
    end
  end
  
endmodule