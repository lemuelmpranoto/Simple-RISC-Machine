module regfile (data_in, writenum, write, readnum, clk, data_out);
  input [15:0] data_in;
  input [2:0] writenum, readnum;
  input write, clk;
  output [15:0] data_out;
  wire [7:0] writenum_out, readnum_out;
  wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
  wire [7:0] AND_gate;

 //converts user-entered binary code to 8-bit one-hot code
 //to specify register to be accessed
  Dec #(3,8) Decoder_in(writenum, writenum_out);
  Dec #(3,8) Decoder_out(readnum, readnum_out);

  //AND_gate takes on a value of either all 0s or a 1 corresponding to the desired writing register
  assign AND_gate = {8{write}} & writenum_out;
 

  //instantiates 8 registers, each of which is a flip-flop that stores a 16-bit number
  //that can be changed to an input at the rising edge of the clock or driven as an output

  register reg0(data_in, AND_gate[0], clk, R0); //register #0
  register reg1(data_in, AND_gate[1], clk, R1); //register #1
  register reg2(data_in, AND_gate[2], clk, R2); //register #2
  register reg3(data_in, AND_gate[3], clk, R3); //register #3
  register reg4(data_in, AND_gate[4], clk, R4); //register #4
  register reg5(data_in, AND_gate[5], clk, R5); //register #5
  register reg6(data_in, AND_gate[6], clk, R6); //register #6
  register reg7(data_in, AND_gate[7], clk, R7); //register #7

  //multiplexer selects one register value to drive along data_out based on user selection via readnum
  MUX_8x16 MUX(R0, R1, R2, R3, R4, R5, R6, R7, readnum_out, data_out);
endmodule

module Dec (in, out);
  parameter n = 2; 	//n = binary code width, m = one-hot code width
  parameter m = 4;
  input [n-1:0] in;
  output [m-1:0] out;
  wire [m-1:0] out = 1 << in;	//out becomes one-hot equivalent of binary in
endmodule


module register (data_in, load, clk, data_out);
  input [15:0]data_in;
  input load;
  input clk;
  output reg[15:0]data_out;
  wire [15:0]next_out;
 
  //assigns next output to become input at next rising clock edge if load is 1
  //next output stays the same if load is 0
  assign next_out = load ? data_in : data_out;

  //output becomes equal to next_out at each rising edge of clk
  //next_out could be equal to either the current output of input
  always @(posedge clk)
    data_out = next_out;
endmodule


module MUX_8x16 (R0, R1, R2, R3, R4, R5, R6, R7, readnum_out, datanum_out);
  input[15:0] R0, R1, R2, R3, R4, R5, R6, R7;
  input [7:0] readnum_out;	//one-hot code
  output [15:0] datanum_out;
  //datanum_out takes on the value contained in a particular register depending on which bit of readnum_out is hot
  wire [15:0] datanum_out = ({16{readnum_out[0]}} & R0) | ({16{readnum_out[1]}} & R1)|
                            ({16{readnum_out[2]}} & R2) | ({16{readnum_out[3]}} & R3)|
                            ({16{readnum_out[4]}} & R4) | ({16{readnum_out[5]}} & R5)|
                            ({16{readnum_out[6]}} & R6) | ({16{readnum_out[7]}} & R7);
endmodule








