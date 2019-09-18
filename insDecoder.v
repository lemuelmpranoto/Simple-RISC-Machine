//instruction decoder module
module insDecoder (instructions, opcode, op, shift, sximm5, sximm8, readnum,
                   writenum, nsel, cond);
                   
//declaring inputs and outputs                   
input [15:0] instructions;
input [2:0] nsel;
output [2:0] opcode, readnum, writenum, cond;
output [1:0] op, shift;
output [15:0] sximm5, sximm8;

//assigning opcode to the inputs from bits 16-14
assign opcode = instructions[15:13];

//assigning op to the inputs from bits 13-12
assign op = instructions[12:11];

//assigning shift to the inputs from bits 5-4
assign shift = instructions[4:3];

//assigning sign extend 5 to value from bit 5 to the 11 bits and concatenating it with bits 1-5 
assign sximm5 = {{11{instructions[4]}}, instructions [4:0]};

//assigning sign extend 8 to value from bit 8 to the 8 bits and concatenating it with bits 1-8
assign sximm8 = {{8{instructions[7]}}, instructions [7:0]};

//assigning readnum to values from the instruction
assign readnum = ({3{nsel[2]}} & instructions[10:8]) |
                 ({3{nsel[1]}} & instructions[7:5])  |
                 ({3{nsel[0]}} & instructions[2:0]);
                 
//assigning writenum to values from the instruction                 
assign writenum = ({3{nsel[2]}} & instructions[10:8]) |
                 ({3{nsel[1]}} & instructions[7:5])  |
                 ({3{nsel[0]}} & instructions[2:0]);

assign cond = instructions [10:8];
endmodule

