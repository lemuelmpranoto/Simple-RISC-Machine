//cpu module
module cpu (clk, reset, read_data, out, mem_cmd, mem_addr, N,V,Z, halt);
//declaring inputs, outputs, and wires
input clk, reset;
input [15:0] read_data;
output [15:0] out;
output N,V,Z, halt;
output [1:0] mem_cmd;
output [8:0] mem_addr;
wire [15:0] ins_out, mdata, sximm5, sximm8;
wire [3:0] vsel;
wire [2:0] opcode, status, readnum, writenum, cond;
wire [1:0] op, shift;
wire loada,loadb,loadc,loads,asel,bsel, load_ir, load_addr, addr_sel;
wire [7:0] PC1;
wire [2:0] nsel;
wire [8:0] dataAddr_out, PC, next_PC, Ninebitsximm8, oldPC;


assign mdata = read_data;

//assigning the flags to values in status in the alu.v file
assign N = status [1];
assign V = status [0];
assign Z = status [2];
//assigning sign extended value
assign Ninebitsximm8 = sximm8[8:0];

//instantiating instruction register
insRegister #(16) insReg (read_data, clk, load_ir, ins_out);

//instantiating instruction decoder
insDecoder insDec (ins_out, opcode, op, shift, sximm5, sximm8, readnum,
                   writenum, nsel, cond);
                   
//instantiating datapath                   
datapath DP (mdata, vsel, writenum,
                 sximm5, sximm8, oldPC,
                 write, readnum, clk, loada, 
                 loadb, shift, asel, bsel, 
         op, loadc, out, status);

//instantiating state machine
state_machine FSM (opcode, op, reset, clk, load_ir, addr_sel,
                    load_pc, reset_pc, mem_cmd, vsel, 
                     write, loada, loadb, loadc, 
                     loads, asel, bsel, nsel, load_addr, halt);

//instantiating data address register
insRegister #(9) dataAddress (out[8:0], clk, load_addr, dataAddr_out);

//instantiating Program Counter
ProgramCounter ProgramCounter (load_pc, reset_pc, next_PC, clk, PC);

//instantiating pcLogic
pcLogic PCL (opcode, op, cond, Ninebitsximm8, out, PC, N, V, Z, next_PC);

//MUX for assigning mem_addr
assign mem_addr = addr_sel ? PC : dataAddr_out;

//Storing previous state PC's value
insRegister #(9) old_PC (PC, clk, load_pc, oldPC);

endmodule

//module for PC 
module ProgramCounter (load_pc, reset_pc, next_PC, clk, out);
input load_pc, reset_pc, clk;
input [8:0] next_PC;
output reg [8:0] out;
wire [8:0] next_out;

//always block when load_pc is high to let value of out go through
always @ (posedge clk) begin
if (load_pc) begin
    out <= next_out;
end
end

//MUX assigning what output for PC is
assign next_out = reset_pc ? 9'b0 : next_PC;

endmodule

//pcLogic module
module pcLogic (opcode, op, cond, sxim8, linkReg, PC, N, V, Z, out);
    //declare input and outputs
    input N, V, Z;
    input [2:0] opcode, cond;
    input [1:0] op;
    input [8:0] PC; 
    input [15:0] linkReg;
    input [8:0] sxim8;
    output reg [8:0] out;

    //always block for casex
    always @* begin
        casex ( {opcode, op, cond} )
            {3'b001, 2'b00, 3'b000}: out = PC + 1 + sxim8;              //B instruction
            {3'b001, 2'b00, 3'b001}: if (Z == 1)                        //BEQ instruction
                                        out = PC + 1 +sxim8;
                                     else 
                                        out = PC + 1;
            {3'b001, 2'b00, 3'b010}: if (Z == 0)                        //BNE instruction
                                        out = PC + 1 + sxim8;
                                     else 
                                        out = PC + 1;
            {3'b001, 2'b00, 3'b011}: if (N !== V)                       //BLT instruction
                                        out = PC + 1 + sxim8;
                                     else 
                                        out = PC + 1;                            
            {3'b001, 2'b00, 3'b100}: if (N !== V || Z == 1)             //BLE instruction
                                        out = PC + 1 + sxim8;
                                     else 
                                        out = PC + 1;
	    {3'b010, 2'b11, 3'bxxx}: out = PC + 1 + sxim8;              //BL instruction
	    {3'b010, 2'bxx, 3'bxxx}: out = linkReg [8:0] + 1;           //BX instruction
            default: out = PC + 1;                                      //default state
        endcase
    end

    
endmodule
