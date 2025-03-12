// Code your testbench here
// or browse Examples
module block_tb;
  logic clk, reset, start, done;
  logic [31:0] state_in [0:15];
  logic [31:0] state_in [0:15];
  
  chacha20_block DUT(.clk(clk), .reset(reset), .start(start), .state_in(state_in), .keystream(keystream), .done(done));
  
  always #5
    clk = ~clk;
  
  initial
    begin
      clk = 0;
      reset = 1;
      start = 0;
      state_in[0]  = 32'h61707865;
      state_in[1]  = 32'h3320646e;
      state_in[2]  = 32'h79622d32;
      state_in[3]  = 32'h6b206574;
      state_in[4]  = 32'h03020100;
      state_in[5]  = 32'h07060504;
      state_in[6]  = 32'h0b0a0908;
      state_in[7]  = 32'h0f0e0d0c;
      state_in[8]  = 32'h13121110;
      state_in[9]  = 32'h17161514;
      state_in[10] = 32'h1b1a1918;
      state_in[11] = 32'h1f1e1d1c;
      state_in[12] = 32'h00000001;  // Counter
      state_in[13] = 32'h09000000;  // Nonce
      state_in[14] = 32'h4a000000;
      state_in[15] = 32'h00000000;
      
      #20 reset = 0;
      #10 reset = 1;
      
      wait(done);
      
      $display("Keystream output : ");
      for(int i = 0; i < 16; i++)
        begin
          $display("Keystream[%0d]: %h", i, keystream[i]);
        end
      
      $100;
      $finish;
    end
endmodule
  
  