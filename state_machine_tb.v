//defining state widths and states for the FSM
`define SW 6
`define SReset 6'b000000
`define SIF1 6'b000001
`define SIF2 6'b000010
`define SUpdatePC 6'b000011
`define SDecode 6'b000100
`define Sa 6'b000101
`define Sb 6'b000110
`define Sc 6'b000111
`define Sd 6'b001000
`define SMovA1 6'b001001
`define SMovB1 6'b001010
`define SMovB2 6'b001011
`define SMovB3 6'b001100
`define SAnd1 6'b001101
`define SAnd2 6'b001110
`define SAnd3 6'b001111
`define SAnd4 6'b010000
`define Scmp1 6'b010001
`define Scmp2 6'b010010
`define Scmp3 6'b010011
`define Smvn1 6'b010100
`define Smvn2 6'b010101
`define Smvn3 6'b010110
`define Smvn4 6'b010111
`define LDR1 6'b011000
`define LDR2 6'b011001
`define LDR3 6'b011010
`define LDR4 6'b011011
`define STR1 6'b011100
`define STR2 6'b011101
`define STR3 6'b011110
`define STR4 6'b011111
`define STR5 6'b100000
`define HALT 6'b100001

module state_machine_tb;
    //declaring regs and wires based on inputs and outputs of FSM module
    reg reset, clk;
    //adding error signal
    reg err;
    reg [2:0] opcode; 
    reg [1:0] op;
    wire load_ir, addr_sel, load_pc, reset_pc;
    wire [1:0] mem_cmd;
    wire [2:0] nsel;
    wire [3:0]vsel;
    wire write;
    wire loada, loadb, loadc;
    wire loads;
    wire asel, bsel, load_addr;


    //instantiating device under test from the state machine module
    state_machine DUT (opcode, op, reset, clk, load_ir, 
                     addr_sel, load_pc, reset_pc, mem_cmd, 
                     vsel, write, loada, loadb, loadc, 
                     loads, asel, bsel, nsel, load_addr);

    //use task checker and declaring the signals to be checked
    task checker;
        input [`SW-1:0] expected_state;
        input [26:0] expected_output;

        begin 
	    //display error and set err to 1 if present state is not equal to expected state
            if (state_machine_tb.DUT.present_state !== expected_state) begin
                $display("ERROR ** state is %b, expected %b", state_machine_tb.DUT.present_state, expected_state);
                err = 1'b1;
                end
	    //display error and set err to 1 if next output is not equal to expected output
            if (state_machine_tb.DUT.next !== expected_output) begin
                $display("ERROR ** output is %b, expected %b", state_machine_tb.DUT.next, expected_output);
                err = 1'b1;
                end
        end
    endtask
    
    //set err, s and reset to 0 in the beginning
    initial begin
        err = 0;
        reset = 0; #5;
	//forever block for setting clock
        forever begin
            clk = 1; #5;
            clk = 0; #5;
        end
    end

    initial begin

    $display("Checking reset state");
    reset = 1; #10;
    checker(`SReset, {`SIF1, 21'b1_1_0_00_0_000_000_0000_000_0_0});
    
    reset = 0; #10;
    checker(`SIF1, {`SIF2, 21'b0_0_1_01_0_000_000_0000_000_0_0});
    #10; 
    checker(`SIF2, {`SUpdatePC, 21'b0_0_1_01_1_000_000_0000_000_0_0});
    #10;
    $display("Checking update pc");
    checker(`SUpdatePC, {`SDecode, 21'b0_1_0_00_0_000_000_0000_000_0_0});
    #10; opcode = 3'b101; op = 2'b00; #10;
    checker(`Sa, {`Sb, 21'b0_0_0_00_0_100_100_0100_000_0_0});
    #10; 
    checker(`Sb, {`Sc, 21'b0_0_0_00_0_001_010_0100_000_0_0});
    reset = 1; #10;
    checker(`SReset, {`SIF1, 21'b1_1_0_00_0_000_000_0000_000_0_0});

    reset = 0; #10;
    checker(`SIF1, {`SIF2, 21'b0_0_1_01_0_000_000_0000_000_0_0});
    #10; 
    checker(`SIF2, {`SUpdatePC, 21'b0_0_1_01_1_000_000_0000_000_0_0});
    #10;
    $display("Checking update pc");
    checker(`SUpdatePC, {`SDecode, 21'b0_1_0_00_0_000_000_0000_000_0_0});
    #10; opcode = 3'b101; op = 2'b11; #10;
    checker(`Smvn1, {`Smvn2, 21'b0_0_0_00_0_100_100_0100_000_0_0});

    $display("End tests");
    if (~err) $display("PASSED");
    else $display("FAILED");

    $stop;
    end
endmodule

            

