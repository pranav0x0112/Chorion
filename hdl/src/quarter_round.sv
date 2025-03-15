// Code your design here
module quarter_round(input logic [31:0] a,b,c,d, output logic [31:0] a_out, b_out, c_out, d_out);
  
  logic [31:0] t0,t1,t2,t3;
  
  always_comb
    begin
      t0 = a + b; d ^= t0; d = {d[15:0], d[31:16]};  // <<< 16
      t1 = c + d; b ^= t1; b = {b[11:0], b[31:12]};  // <<< 12
      t2 = t0 + b; d ^= t2; d = {d[23:0], d[31:24]}; // <<< 8
      t3 = t1 + d; b ^= t3; b = {b[6:0], b[31:7]};   // <<< 7
      
      a_out = t2;
      b_out = b;
      c_out = t3;
      d_out = d;
    end
endmodule