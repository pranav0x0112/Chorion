// Code your design here
module chacha20_state(input logic clk, reset, input logic [255:0] key, input logic [31:0] counter, input logic [95:0] nonce, output logic [31:0] state [0:15]);
  
  localparam logic [31:0] C0 = 32'h61707865;
  localparam logic [31:0] C1 = 32'h3320646e;
  localparam logic [31:0] C2 = 32'h79622d32;
  localparam logic [31:0] C3 = 32'h6b206574;
  
  always_ff@(posedge clk or posedge reset)
    begin
      if(reset)
        begin
          for(int i = 0; i < 16; i++)
            state[i] <= 32'b0;
        end
      else
        begin
          state[0]  <= C0;
          state[1]  <= C1;
          state[2]  <= C2;
          state[3]  <= C3;
          state[4]  <= key[31:0];
          state[5]  <= key[63:32];
          state[6]  <= key[95:64];
          state[7]  <= key[127:96];
          state[8]  <= key[159:128];
          state[9]  <= key[191:160];
          state[10] <= key[223:192];
          state[11] <= key[255:224];
          state[12] <= counter;
          state[13] <= nonce[31:0];
          state[14] <= nonce[63:32];
          state[15] <= nonce[95:64];
        end
    end
endmodule

  
  
