// Code your design here
module chacha20_state(input logic clk, reset, input logic [255:0] key, input logic [31:0] counter, input logic [95:0] nonce, output logic [511:0] state);
  
  localparam logic [31:0] C0 = 32'h61707865;
  localparam logic [31:0] C1 = 32'h3320646e;
  localparam logic [31:0] C2 = 32'h79622d32;
  localparam logic [31:0] C3 = 32'h6b206574;
  
  always_ff@(posedge clk or posedge reset)
    begin
      if(reset)
        begin
          state <= 512'b0;
        end
      else
        begin
          state <= {C0,C1,C2,C3,key,counter,nonce};
        end
    end
endmodule
