module quarter_round(input logic [31:0] a,b,c,d, output logic [31:0] a_out, b_out, c_out, d_out);
  
  logic [31:0] t0,t1,t2,t3,d_temp, b_temp;
  
  always_comb
    begin
      t0 = a + b; d_temp = d ^ t0; d_temp = {d_temp[15:0], d_temp[31:16]};  // <<< 16
      t1 = c + d_temp; b_temp = b ^ t1; b_temp = {b_temp[11:0], b_temp[31:12]};  // <<< 12
      t2 = t0 + b_temp; d_temp = d_temp ^ t2; d_temp = {d_temp[23:0], d_temp[31:24]}; // <<< 8
      t3 = t1 + d_temp; b_temp = b_temp ^ t3; b_temp = {b_temp[6:0], b_temp[31:7]};   // <<< 7
      
      a_out = t2;
      b_out = b_temp;
      c_out = t3;
      d_out = d_temp;
    end
endmodule