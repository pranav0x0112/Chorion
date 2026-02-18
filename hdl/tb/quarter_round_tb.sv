`timescale 1ns / 1ps

module quarter_round_tb;

  logic [31:0] a, b, c, d;
  logic [31:0] a_out, b_out, c_out, d_out;

  quarter_round DUT(
    .a(a), .b(b), .c(c), .d(d),
    .a_out(a_out), .b_out(b_out), .c_out(c_out), .d_out(d_out)
  );

  initial begin
    $display("Testing Quarter Round...");
    
    // Test vector from RFC 8439
    a = 32'h11111111; 
    b = 32'h01020304; 
    c = 32'h9b8d6f43; 
    d = 32'h01234567;
    
    #10; 
    
    $display("Input:  A=%h, B=%h, C=%h, D=%h", a, b, c, d);
    $display("Output: A=%h, B=%h, C=%h, D=%h", a_out, b_out, c_out, d_out);
    
    // Expected values from RFC 8439
    if (a_out == 32'hea2a92f4 && 
        b_out == 32'hcb1cf8ce && 
        c_out == 32'h4581472e && 
        d_out == 32'h5881c4bb) begin
      $display("PASS: Quarter round test passed!");
    end else begin
      $display("FAIL: Quarter round mismatch!");
      $display("Expected: A=ea2a92f4, B=cb1cf8ce, C=4581472e, D=5881c4bb");
    end
    
    #10 $finish;
  end

endmodule
