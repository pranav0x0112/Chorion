`timescale 1ns / 1ps

module quarter_round(input logic [31:0] a,b,c,d, output logic [31:0] a_out, b_out, c_out, d_out);
  
  logic [31:0] a_tmp, b_tmp, c_tmp, d_tmp;
  
  always_comb begin
    // First quarter round operations
    a_tmp = a + b;
    d_tmp = d ^ a_tmp;
    d_tmp = {d_tmp[15:0], d_tmp[31:16]};  // Rotate left by 16
    
    c_tmp = c + d_tmp;
    b_tmp = b ^ c_tmp;
    b_tmp = {b_tmp[19:0], b_tmp[31:20]};  // Rotate left by 12
    
    // Second quarter round operations
    a_tmp = a_tmp + b_tmp;
    d_tmp = d_tmp ^ a_tmp;
    d_tmp = {d_tmp[23:0], d_tmp[31:24]};  // Rotate left by 8
    
    c_tmp = c_tmp + d_tmp;
    b_tmp = b_tmp ^ c_tmp;
    b_tmp = {b_tmp[24:0], b_tmp[31:25]};  // Rotate left by 7

    a_out = a_tmp;
    b_out = b_tmp;
    c_out = c_tmp;
    d_out = d_tmp;
  end
  
endmodule