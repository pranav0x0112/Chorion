module chacha20_block(input logic clk, reset, start, input logic [31:0] state_in [0:15], output logic [31:0] keystream [0:15], output logic done);

  logic [31:0] state_reg [0:15], qr_out [0:15];  
  logic [4:0] round_counter;  
  logic processing;

  generate
    genvar i;
    for (i = 0; i < 4; i++) begin : qr_even
      quarter_round qr_even_inst(state_reg[i], state_reg[i+4], state_reg[i+8], state_reg[i+12], qr_out[i], qr_out[i+4], qr_out[i+8], qr_out[i+12]);
    end
  endgenerate

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      round_counter <= 0; processing <= 0; done <= 0;
    end else if (start) begin
      state_reg <= state_in; round_counter <= 0; processing <= 1; done <= 0;
    end else if (processing) begin
      if (round_counter < 20) begin
        if (round_counter % 2 == 0) state_reg <= qr_out;
        round_counter <= round_counter + 1;
      end else begin
        for (int i = 0; i < 16; i++) keystream[i] = state_in[i] + state_reg[i];
        done <= 1; processing <= 0;
      end
    end
  end
endmodule