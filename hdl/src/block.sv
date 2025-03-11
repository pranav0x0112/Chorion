// Code your design here
module chacha20_block(input logic clk, reset, start, input logic [31:0] state_in [0:15], output logic [31:0] keystream [0:15], output logic done);
  
  logic [31:0] state_reg [0:15];
  logic [4:0] round_counter;
  logic processing;
  
  always_ff@(posedge clk or posedge reset)
    begin
      if(reset)
        begin
          round_counter <= 0;
          processing <= 0;
          done <= 0;
        end
      else if(start)
        begin
          state_reg <= state_in;
          round_counter <= 0;
          processing <= 1;
          done <= 0;
        end
      else if(processing)
        begin
          if(round_counter < 20)
            begin
              if(round_counter % 2 ==0)
                begin
                  quarter_round(state_reg[0], state_reg[4], state_reg[8], state_reg[12]);
                  quarter_round(state_reg[1], state_reg[5], state_reg[9], state_reg[13]);
                  quarter_round(state_reg[2], state_reg[6], state_reg[10], state_reg[14]);
                  quarter_round(state_reg[3], state_reg[7], state_reg[11], state_reg[15]);
                end
              else 
                begin
                  quarter_round(state_reg[0], state_reg[5], state_reg[10], state_reg[15]);
                  quarter_round(state_reg[1], state_reg[6], state_reg[11], state_reg[12]);
                  quarter_round(state_reg[2], state_reg[7], state_reg[8], state_reg[13]);
                  quarter_round(state_reg[3], state_reg[4], state_reg[9], state_reg[14]);
                end
              round_counter <= round_counter + 1;
            end
          else
            begin
              for(int i = 0; i < 16; i++)
                begin
                  keystream[i] = state_in[i] + state_reg[i];
                end
              done <= 1;
              processing <= 0;
            end
        end
    end
endmodule
                  
                  