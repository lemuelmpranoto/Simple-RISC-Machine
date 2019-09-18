//defining state widths and states for the FSM
`define SW 20
`define SReset 20'h0
`define SIF1 20'h10000
`define SIF2 20'h2
`define SUpdatePC 20'h3
`define SDecode 20'h4
`define SWait 20'h42
`define Sa 20'h5
`define Sb 20'h6
`define Sc 20'h7
`define Sd 20'h8
`define SMovA1 20'h9
`define SMovB1 20'h10
`define SMovB2 20'h11
`define SMovB3 20'h12
`define SAnd1 20'h13
`define SAnd2 20'h14
`define SAnd3 20'h15
`define SAnd4 20'h16
`define Scmp1 20'h17
`define Scmp2 20'h18
`define Scmp3 20'h19
`define Smvn1 20'h20
`define Smvn2 20'h21
`define Smvn3 20'h22
`define Smvn4 20'h23
`define LDR1 20'h24
`define LDR2 20'h25
`define LDR3 20'h26
`define LDR4 20'h27
`define STR1 20'h28
`define STR2 20'h29
`define STR3 20'h30
`define STR4 20'h31
`define STR5 20'h32
`define LDR5 20'h33
`define BL1  20'h34
`define BL2  20'h40
`define BX1  20'h35
`define BX2  20'h36
`define BX3  20'h37
`define BLX1 20'h38
`define HALT 20'h39

//state machine module
module state_machine (opcode, op, reset, clk, load_ir, 
                     addr_sel, load_pc, reset_pc, mem_cmd, 
                     vsel, write, loada, loadb, loadc, 
                     loads, asel, bsel, nsel, load_addr, halt);
    //declare inputs and outputs of the state machine
    input reset, clk;
    input [2:0] opcode;
    input [1:0] op; 
    output load_ir, addr_sel, load_pc, reset_pc, load_addr;
    output [1:0] mem_cmd;
    output [2:0] nsel;
    output [3:0] vsel;
    output write;
    output loada, loadb, loadc;
    output loads;
    output asel,bsel, halt;
    
    //adding reset, present, and next state 
    wire [`SW-1:0] state_next_reset, p;
    wire [`SW-1:0] state_next;
    //declaring for concatenations for output signals
    reg [(`SW+22)-1:0] next;

    //vDFF for checking what next state should be
    vDFF #(`SW) STATE(clk, state_next_reset, p);
    //mux for reset state
    assign state_next_reset = reset? `SReset : state_next;

   
    //always block to set next states with its corresponding outputs based on current state
    always @(*)
        casex ( {p, opcode, op} )

        //New states implemented for lab 7
        {`SReset,    5'bxxxxx}: next = {`SIF1,      22'b1_1_0_00_0_000_000_0000_000_0_0_0};	//reset state
        {`SIF1,      5'bxxxxx}: next = {`SIF2,      22'b0_0_1_01_0_000_000_0000_000_0_0_0};	//initial state	
	{`SIF2,      5'bxxxxx}: next = {`SUpdatePC, 22'b0_0_1_01_1_000_000_0000_000_0_0_0};	//second state, loads IR
	{`SUpdatePC, 5'bxxxxx}: next = {`SDecode,   22'b0_1_0_00_0_000_000_0000_000_0_0_0};	//PC gets updated

        //Into decode state and depends on opcode and op
        {`SDecode,   5'b11010}: next = {`SMovA1,    22'b0_0_0_00_0_000_000_0000_000_0_0_0};	//commence operation depending on opcode and op
        {`SDecode,   5'b11000}: next = {`SMovB1,    22'b0_0_0_00_0_000_000_0000_000_0_0_0};
        {`SDecode,   5'b10100}: next = {`Sa,        22'b0_0_0_00_0_000_000_0000_000_0_0_0};
        {`SDecode,   5'b10110}: next = {`SAnd1,     22'b0_0_0_00_0_000_000_0000_000_0_0_0};
        {`SDecode,   5'b10101}: next = {`Scmp1,     22'b0_0_0_00_0_000_000_0000_000_0_0_0};
        {`SDecode,   5'b10111}: next = {`Smvn1,     22'b0_0_0_00_0_000_000_0000_000_0_0_0}; 
        {`SDecode,   5'b01100}: next = {`LDR1,      22'b0_0_0_00_0_000_000_0000_000_0_0_0};
        {`SDecode,   5'b10000}: next = {`STR1,      22'b0_0_0_00_0_000_000_0000_000_0_0_0};
	{`SDecode,   5'b01011}: next = {`BL1, 		22'b0_0_0_00_0_000_000_0000_000_0_0};
	{`SDecode,   5'b01000}: next = {`BX1, 		22'b0_0_0_00_0_000_000_0000_000_0_0};
	{`SDecode,   5'b01010}: next = {`BLX1, 		22'b0_0_0_00_0_000_000_0000_000_0_0};
	{`SDecode,   3'b111, 2'bxx}: next = {`HALT, 	22'b0_0_0_00_0_000_000_0000_000_0_0};
	{`SDecode,   5'bxxxxx}: next = {`SIF1, 	22'b0_0_0_00_0_000_000_0000_000_0_0};

        //States for adding instruction
        {`Sa,        5'bxxxxx}: next = {`Sb,        22'b0_0_0_00_0_100_100_0100_000_0_0_0};	//load reg A from Rn
        {`Sb,        5'bxxxxx}: next = {`Sc,        22'b0_0_0_00_0_001_010_0100_000_0_0_0};	//load reg B from Rm
        {`Sc,        5'bxxxxx}: next = {`Sd,        22'b0_0_0_00_0_000_001_0000_000_0_0_0};   	//load reg C with sum
        {`Sd,        5'bxxxxx}: next = {`SIF1,      22'b0_0_0_00_0_010_000_0001_100_0_0_0};	//writeback to Rd

        //States for first MOV instruction
        {`SMovA1,    5'bxxxxx}: next = {`SIF1,      22'b0_0_0_00_0_100_000_0100_100_0_0_0};	//write to Rn

        //States for second MOV instruction
        {`SMovB1,    5'bxxxxx}: next = {`SMovB2,    22'b0_0_0_00_0_001_010_0100_000_0_0_0};	//load reg B from Rm
        {`SMovB2,    5'bxxxxx}: next = {`Sd,        22'b0_0_0_00_0_000_001_0000_010_0_0_0};	//load reg C then write back

        //States for AND instruction
        {`SAnd1,     5'bxxxxx}: next = {`SAnd2,     22'b0_0_0_00_0_100_100_0100_000_0_0_0};	//load reg A from Rn
        {`SAnd2,     5'bxxxxx}: next = {`SAnd3,     22'b0_0_0_00_0_001_010_0100_000_0_0_0};	//load reg B from Rm
        {`SAnd3,     5'bxxxxx}: next = {`SAnd4,     22'b0_0_0_00_0_000_001_0000_000_0_0_0};	//load reg C with AND
        {`SAnd4,     5'bxxxxx}: next = {`SIF1,      22'b0_0_0_00_0_010_000_0001_100_0_0_0};	//writeback to Rd

        //States for CMP instruction
        {`Scmp1,     5'bxxxxx}: next = {`Scmp2,     22'b0_0_0_00_0_100_100_0100_000_0_0_0};	//load reg A from Rn
        {`Scmp2,     5'bxxxxx}: next = {`Scmp3,     22'b0_0_0_00_0_001_010_0100_000_0_0_0};	//load reg B from Rm
        {`Scmp3,     5'bxxxxx}: next = {`SIF1,      22'b0_0_0_00_0_000_001_0000_000_0_0_0};	//load reg C with difference

        //States for MVN instruction
        {`Smvn1,     5'bxxxxx}: next = {`Smvn2,     22'b0_0_0_00_0_100_100_0100_000_0_0_0};	//load reg A from Rn
        {`Smvn2,     5'bxxxxx}: next = {`Smvn3,     22'b0_0_0_00_0_001_010_0100_000_0_0_0};	//load reg B from Rm
        {`Smvn3,     5'bxxxxx}: next = {`SAnd4,     22'b0_0_0_00_0_000_001_0000_000_0_0_0};	//load reg C with negation

        //States for LDR instruction           
        {`LDR1,      5'bxxxxx}: next = {`LDR2,      22'b0_0_0_00_0_100_100_0000_000_0_1_0};	//load reg A from Rn
        {`LDR2,      5'bxxxxx}: next = {`LDR3,      22'b0_0_0_00_0_000_001_0000_001_0_1_0};	//load reg C with reg A
        {`LDR3,      5'bxxxxx}: next = {`LDR4,      22'b0_0_0_00_0_000_000_0000_000_0_1_0};	//write to data address
        {`LDR4,      5'bxxxxx}: next = {`LDR5,      22'b0_0_0_01_0_000_000_0000_000_0_0_0};	//read from memory at data address
        {`LDR5,      5'bxxxxx}: next = {`SIF1,      22'b0_0_0_01_0_010_000_1000_100_0_0_0};	//write to Rd

        //States for STR instruction
        {`STR1,      5'bxxxxx}: next = {`STR2,      22'b0_0_0_00_0_100_100_0000_000_0_0_0};	//load reg A from Rn
        {`STR2,      5'bxxxxx}: next = {`STR3,      22'b0_0_0_00_0_000_001_0000_001_0_0_0};	//load reg C with A
        {`STR3,      5'bxxxxx}: next = {`STR4,      22'b0_0_0_00_0_010_010_0000_000_0_1_0};	//load reg B with Rd
        {`STR4,      5'bxxxxx}: next = {`STR5,      22'b0_0_0_00_0_000_001_0000_010_0_0_0};	//load reg C with reg A for address
        {`STR5,      5'bxxxxx}: next = {`SIF1,      22'b0_0_0_10_0_000_000_0000_000_0_0_0};	//write reg B to mem[reg A]

    	//State for BL instruction
	{`BL1, 	 5'bxxxxx}: next = {`SIF1, 22'b0_0_0_00_0_100_000_0010_100_0_0_0};		//write PC to Rn

	//States for BX instruction
	{`BX1, 	 5'bxxxxx}: next = {`BX2, 22'b0_0_0_00_0_010_010_0000_010_0_0_0};		//load reg B with Rd
	{`BX2, 	 5'bxxxxx}: next = {`BX3, 22'b0_0_0_00_0_000_001_0000_010_0_0_0};		//load reg C with B
	{`BX3, 	 5'bxxxxx}: next = {`SIF1, 22'b0_1_0_00_0_000_000_0000_000_0_0_0};		//output sum and load PC


        //States for HALT 
        {`HALT,      5'bxxxxx}: next = {`HALT, {21'bx}, 1'b1};		//stays in halt state indefinitely
        default:  next = {{`SW{1'bx}}, {22{1'bx}}};

     endcase

     //assigning concatenations of output signals into one signal 'next'
     assign {state_next, reset_pc, load_pc, addr_sel, mem_cmd, load_ir, nsel, loada, loadb, loadc, vsel, write, asel, bsel, loads, load_addr, halt} = next;
    
endmodule

