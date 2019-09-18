module ALU(Ain, Bin, ALUop, out, ZNF, loads);
    input [15:0] Ain, Bin;
    input [1:0] ALUop; 		//determines arithmetic operation to be performed on inputs
    output [15:0] out;
    reg [15:0] out;	//result of operation
    output [2:0] ZNF;	//indicates status
    wire ovf;
    output loads;

    always @(*) begin
     case(ALUop)  
      2'b00 : out = Ain + Bin;	//inputs are added for ALUop = 00
      2'b01 : out = Ain - Bin;	//second input subtracted from first for 01
      2'b10 : out = Ain & Bin;	//inputs ANDed together for 10
      2'b11 : out = ~Bin;	//output is second input with bits flipped for 11 
      default: out = 16'bxxxx_xxxx_xxxx_xxxx;
     endcase
    end
     assign ovf =  (out[15] & (~Ain[15] & Bin[15])) |
                   (~out[15] & (Ain[15] & ~Bin[15]));

     assign ZNF = {(~(|out[15:0])), out[15], ovf};
     assign loads = (ALUop == 2'b01);

endmodule

  