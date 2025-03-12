`timescale 1ns / 1ps

module quarter_round_tb;

  logic clk = 0, reset = 1, start = 0, done;
  logic [31:0] a, b, c, d, a_out, b_out, c_out, d_out;

  quarter_round DUT(clk, reset, start, a, b, c, d, a_out, b_out, c_out, d_out, done);

  always #5 clk = ~clk;

  initial begin
    #20 reset = 0; #10;
    a = 32'h11111111; b = 32'h01020304; c = 32'h9b8d6f43; d = 32'h01234567;
    start = 1; #10 start = 0;
    wait(done);
    $display("A_out: %h, B_out: %h, C_out: %h, D_out: %h", a_out, b_out, c_out, d_out);
    #50 $finish;
  end

endmodule
