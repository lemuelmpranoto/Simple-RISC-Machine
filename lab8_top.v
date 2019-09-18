`define MWRITE 2'b10
`define MREAD 2'b01
`define MNONE 2'b00

//module lab8_top
module lab8_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5, CLOCK_50);
  //declaring input outputs
  input [3:0] KEY;
  input [9:0] SW;
  input CLOCK_50;
  output [9:0] LEDR; 
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  //wire clk; 
  wire reset, halt;
  //assign clk = ~KEY[0];
  assign reset = ~KEY[1];
  wire [15:0] read_data, out, din, dout, read_dataMEM, read_dataSW;
  wire [8:0] mem_addr; 
  wire [7:0] read_address, write_address;
  wire [1:0] mem_cmd;
  wire N,V,Z, write, doutBuffer, inputBuffer, outputLoad;
  
  //instantiating RAM module
  RAM #(16,8) MEM (CLOCK_50, read_address, write_address, write, din, dout);
  //instantiating CPU module
  cpu CPU (CLOCK_50, reset, read_data, out, mem_cmd, mem_addr, N,V,Z, halt);

  //assigning halt to LEDR[8]
  assign LEDR[8] = halt;

  //designing logic that connects cpu module with RAM module
  assign read_address = mem_addr [7:0];
  //assigning write address to mem_addr
  assign write_address = mem_addr [7:0];
  //assigning write address to mem_addr
  assign din = out;
  //assigning write address to mem_addr
  assign write = ((mem_cmd == `MWRITE) && (mem_addr[8] == 1'b0));
  //assigning write address to mem_addr
  assign doutBuffer = ((mem_cmd == `MREAD) && (mem_addr[8] == 1'b0));
  //assigning write address to mem_addr
  assign read_dataMEM = doutBuffer ? dout : 16'bz;

  //assigning write address to mem_addr
  assign inputBuffer = ((mem_cmd == `MREAD) && (mem_addr == 9'h140));
  //assigning write address to mem_addr
  assign outputLoad = ((mem_cmd == `MWRITE) && (mem_addr == 9'h100));
  //assigning write address to mem_addr
  assign read_dataSW = inputBuffer ? {8'b0, SW[7:0]} : 16'bz;
  //assigning write address to mem_addr
  assign read_data = doutBuffer ? read_dataMEM : read_dataSW;
  
  //instantiating insRegister
  insRegister #(8) outputReg (out[7:0], CLOCK_50, outputLoad, LEDR[7:0]);

  assign HEX0 = 7'b1111111;
  assign HEX1 = 7'b1111111;
  assign HEX2 = 7'b1111111;
  assign HEX3 = 7'b1111111;
  assign HEX4 = 7'b1111111;
  assign HEX5 = 7'b1111111;
  assign LEDR[9] = 1'b0;

endmodule

module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output [n-1:0] Q;
  reg [n-1:0] Q;
  always @(posedge clk)
    Q <= D;
endmodule

`define SS_0 7'b1000000
`define SS_1 7'b1111001
`define SS_2 7'b0100100
`define SS_3 7'b0110000
`define SS_4 7'b0011001
`define SS_5 7'b0010010
`define SS_6 7'b0000010
`define SS_7 7'b1111000
`define SS_8 7'b0000000
`define SS_9 7'b0010000
`define SS_10 7'b0001000
`define SS_11 7'b0000011
`define SS_12 7'b1000110
`define SS_13 7'b0100001
`define SS_14 7'b0000110
`define SS_15 7'b0001110

module sseg(in,segs);
  input [3:0] in;
  output reg [6:0] segs;

    always @(*) begin
	case (in)
	4'b0000: segs = `SS_0;
	4'b0001: segs = `SS_1;
	4'b0010: segs = `SS_2;
	4'b0011: segs = `SS_3;
	4'b0100: segs = `SS_4;
	4'b0101: segs = `SS_5;
	4'b0110: segs = `SS_6;
	4'b0111: segs = `SS_7;
	4'b1000: segs = `SS_8;
	4'b1001: segs = `SS_9;
	4'b1010: segs = `SS_10;
	4'b1011: segs = `SS_11;
	4'b1100: segs = `SS_12;
	4'b1101: segs = `SS_13;
	4'b1110: segs = `SS_14;
	4'b1111: segs = `SS_15;
	default: segs = 7'b1111111;
	endcase
end

endmodule

module RAM (clk, read_address, write_address, write, din, dout);
    parameter data_width = 16;
    parameter addr_width = 8;
    parameter filename = "data2.txt";

    input clk;
    input [addr_width-1:0] read_address, write_address;
    input write;
    input [data_width-1:0] din;
    output [data_width-1:0] dout;
    reg [data_width-1:0] dout;

    reg [data_width-1:0] mem [2**addr_width-1:0];

    initial $readmemb (filename, mem);

    always @ (posedge clk) begin
        if(write)
            mem[write_address] <= din;
        dout <= mem [read_address];

    end
endmodule





