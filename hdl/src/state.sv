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
      state[4]  <= key[31:0];    // reg_key[0]  = RFC key bytes  0- 3
      state[5]  <= key[63:32];   // reg_key[1]  = RFC key bytes  4- 7
      state[6]  <= key[95:64];   // reg_key[2]  = RFC key bytes  8-11
      state[7]  <= key[127:96];  // reg_key[3]  = RFC key bytes 12-15
      state[8]  <= key[159:128]; // reg_key[4]  = RFC key bytes 16-19
      state[9]  <= key[191:160]; // reg_key[5]  = RFC key bytes 20-23
      state[10] <= key[223:192]; // reg_key[6]  = RFC key bytes 24-27
      state[11] <= key[255:224]; // reg_key[7]  = RFC key bytes 28-31
      // Counter
      state[12] <= counter;
      state[13] <= nonce[31:0];    // reg_nonce[0] = RFC nonce bytes 0-3
      state[14] <= nonce[63:32];   // reg_nonce[1] = RFC nonce bytes 4-7
      state[15] <= nonce[95:64];   // reg_nonce[2] = RFC nonce bytes 8-11
    end
  end
  
endmodule