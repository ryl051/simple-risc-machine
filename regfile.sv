module regfile(data_in, writenum, write, readnum, clk, data_out);
  input [15:0] data_in;
  input [2:0] writenum, readnum;
  input write, clk;
  output [15:0] data_out;

  wire [7:0] writenumDecoded;
  wire [7:0] readnumDecoded;

  //decoding writenum and readnum into 8-bit one hot code from 3 bit binary
  Decoder write_decoder (writenum, writenumDecoded);
  Decoder read_decoder (readnum, readnumDecoded);

  //bitwise & with the write input to find which register to write to
  wire [7:0] load = writenumDecoded & {8{write}};
  wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

  //instantiate the load-enable registers
  vDFFE register0 (clk, load[0], data_in, R0);
  vDFFE register1 (clk, load[1], data_in, R1);
  vDFFE register2 (clk, load[2], data_in, R2);
  vDFFE register3 (clk, load[3], data_in, R3);
  vDFFE register4 (clk, load[4], data_in, R4);
  vDFFE register5 (clk, load[5], data_in, R5);
  vDFFE register6 (clk, load[6], data_in, R6);
  vDFFE register7 (clk, load[7], data_in, R7);

  //logic for mux to select which register to read from
  assign data_out = (readnumDecoded[0] ? R0 :
                       readnumDecoded[1] ? R1 :
                       readnumDecoded[2] ? R2 :
                       readnumDecoded[3] ? R3 :
                       readnumDecoded[4] ? R4 :
                       readnumDecoded[5] ? R5 :
                       readnumDecoded[6] ? R6 : R7);
  
endmodule

//Load-enable register
module vDFFE(clk, load, in, out) ;
  parameter n = 16;
  input clk, load ;
  input  [n-1:0] in ;
  output [n-1:0] out ;
  reg    [n-1:0] out ;
  wire   [n-1:0] next_out ;

  assign next_out = load ? in : out;

  always @(posedge clk)
    out = next_out;  
endmodule

//3 bit binary to 8 bit one hot code decoder
module Decoder(a, b) ;
  input  [2:0] a ;
  output [7:0] b ;

  wire [7:0] b = 1 << a ;
endmodule

