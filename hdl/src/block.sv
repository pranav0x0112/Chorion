`timescale 1ns / 1ps

module chacha20_block(
  input  logic clk, 
  input  logic reset, 
  input  logic start, 
  input  logic [31:0] state_in [0:15], 
  output logic [31:0] keystream [0:15], 
  output logic done
);

  logic [31:0] state_reg [0:15];
  logic [31:0] initial_state [0:15]; 
  logic [31:0] qr_col_out [0:15];  
  logic [31:0] qr_diag_out [0:15];
  logic [4:0] round_counter;  
  logic processing;
  integer i;
  
  generate
    genvar j;
    for (j = 0; j < 4; j++) begin : qr_columns
      quarter_round qr_col_inst(
        .a(state_reg[j]), 
        .b(state_reg[j+4]), 
        .c(state_reg[j+8]), 
        .d(state_reg[j+12]),
        .a_out(qr_col_out[j]), 
        .b_out(qr_col_out[j+4]), 
        .c_out(qr_col_out[j+8]), 
        .d_out(qr_col_out[j+12])
      );
    end
  endgenerate

  // Diagonal quarter rounds (odd rounds: 1, 3, 5, ...)
  quarter_round qr_diag0(
    .a(state_reg[0]), .b(state_reg[5]), .c(state_reg[10]), .d(state_reg[15]),
    .a_out(qr_diag_out[0]), .b_out(qr_diag_out[5]), .c_out(qr_diag_out[10]), .d_out(qr_diag_out[15])
  );
  quarter_round qr_diag1(
    .a(state_reg[1]), .b(state_reg[6]), .c(state_reg[11]), .d(state_reg[12]),
    .a_out(qr_diag_out[1]), .b_out(qr_diag_out[6]), .c_out(qr_diag_out[11]), .d_out(qr_diag_out[12])
  );
  quarter_round qr_diag2(
    .a(state_reg[2]), .b(state_reg[7]), .c(state_reg[8]), .d(state_reg[13]),
    .a_out(qr_diag_out[2]), .b_out(qr_diag_out[7]), .c_out(qr_diag_out[8]), .d_out(qr_diag_out[13])
  );
  quarter_round qr_diag3(
    .a(state_reg[3]), .b(state_reg[4]), .c(state_reg[9]), .d(state_reg[14]),
    .a_out(qr_diag_out[3]), .b_out(qr_diag_out[4]), .c_out(qr_diag_out[9]), .d_out(qr_diag_out[14])
  );

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      round_counter <= 5'd0;
      processing <= 1'b0;
      done <= 1'b0;
      for (i = 0; i < 16; i = i + 1) begin
        state_reg[i] <= 32'd0;
        initial_state[i] <= 32'd0;
        keystream[i] <= 32'd0;
      end
    end else if (start && !processing) begin
      for (i = 0; i < 16; i = i + 1) begin
        state_reg[i] <= state_in[i];
        initial_state[i] <= state_in[i];
      end
      round_counter <= 5'd0;
      processing <= 1'b1;
      done <= 1'b0;
    end else if (processing) begin
      if (round_counter < 5'd20) begin
        if (round_counter[0] == 1'b0) begin
          state_reg <= qr_col_out;
        end else begin
          state_reg <= qr_diag_out;
        end
        round_counter <= round_counter + 5'd1;
      end else begin
        for (i = 0; i < 16; i = i + 1) begin
          keystream[i] <= initial_state[i] + state_reg[i];
        end
        done <= 1'b1;
        processing <= 1'b0;
      end
    end
  end

endmodule