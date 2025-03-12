// Code your testbench here
// or browse Examples
module chacha20_top_tb;
  logic clk, reset, start;
  logic [255:0] key;
  logic [31:0] counter;
  logic [95:0] nonce;
  logic [511:0] keystream;
  logic done;
  
  chacha20_top DUT(.clk(clk), .reset(reset), .start(start), .key(key), .counter(counter), .nonce(nonce), .keystream(keystream), .done(done));
  
  always #5
    clk = ~clk;
  
  initial
    begin
      clk = 0;
      reset = 1;
      start = 0;
      key = 256'h000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F;
      nonce = 96'h000000090000004A00000000;
      counter = 32'h00000001;
      
      #20 reset = 0;
      #10 start = 1;
      #10 start = 0;
      
      wait(done);
      
      $display("Keystream : %h", keystream);
      #10 $finish;
    end
endmodule