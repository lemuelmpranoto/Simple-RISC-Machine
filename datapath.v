module datapath (mdata, vsel, writenum,
                 sximm5, sximm8, PC,
                 write, readnum, clk, loada, 
                 loadb, shift, asel, bsel, 
		 ALUop, loadc, datapath_out, status);
    input [15:0] mdata, sximm5, sximm8;
    input [8:0] PC;
    input [3:0] vsel;
    input [2:0] writenum, readnum;
    input write, clk;
    input loada, loadb, loadc;
    input [1:0] shift;
    input asel, bsel;
    input [1:0] ALUop;
    wire loads;
    output [2:0] status;
    output [15:0] datapath_out;
    wire [15:0] data_in, data_out, regAout, regBout, sout, Ain, Bin, out;
    wire [2:0] ZNF_out;
     
 //instantiates register file module that contains instructions for accessing contents of the register
 //specified by write_num and read_num
    regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);

//instantiates shift module to shift the number contained in register B by up to one bit position
    shifter shifterU1(regBout, shift, sout);

//instantiates arithmetic unit that performs 1 of 4 operations on the inputs from registers A and B
    ALU alu(Ain, Bin, ALUop, out, ZNF_out, loads);

//multiplexer that selects either manually inputted number (datapath_in)
//or previous calculation result (datapath_out) to be inputted to register file
    FourInMUXDatapath mux9(datapath_out, PC, sximm8, mdata, vsel, data_in);

//drives either the value contained in register A or the number zero into the ALU depending on selection input
    MUXDatapath mux6(16'b0, regAout, asel, Ain);

//drives either the shifted value from register B or the last 5 bits of datapath_in preceded by 0s into the ALU depending on selection input
    MUXDatapath mux7(sximm5, sout, bsel, Bin);

//1-bit register that stores the value of the Z signal, which is 1 when the output of the ALU is 0
    reg_status reg_status(ZNF_out, loads, clk, status);

//first of the two registers that store a 16-bit value to be inputted to the ALU
    register regA(data_out, loada, clk, regAout);

//other register that stores value to be inputted to ALU
    register regB(data_out, loadb, clk, regBout);

//register that stores calculation result outputted from ALU
    register regC(out, loadc, clk, datapath_out);

endmodule

module MUXDatapath(in1, in2, vsel, out);
    input [15:0] in1, in2;
    input vsel;
    output [15:0] out;
    assign out = vsel? in1 : in2;	//sets out to match input 1 for vsel = 1 and second input for vsel = 0
endmodule

module FourInMUXDatapath (in1, in2, in3, in4, vsel, out);
	input [15:0] in1, in3, in4;
	input [8:0] in2;
        wire [15:0] in2extended;
        assign in2extended = {7'b0, in2};
	input [3:0] vsel;
	output [15:0] out;
	assign out = ({16{vsel[0]}} & in1) | ({16{vsel[1]}} & in2extended) | ({16{vsel[2]}} & in3) | ({16{vsel[3]}} & in4);
endmodule

module reg_status(data_in, sel, clk, data_out);
    input [2:0] data_in;
    input sel;		//load signal
    input clk;
    output [2:0] data_out;
    reg [2:0] data_out;
    wire [2:0] next_out;

    assign next_out= sel ? data_in : data_out;		//sets next output to match input if sel is 1, else next output matches current output

	//sets output to match next output at each rising clock edge
        always @(posedge clk) 
            data_out=next_out;
endmodule