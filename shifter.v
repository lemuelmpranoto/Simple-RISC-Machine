module shifter(in, shift, sout);
    input [15:0] in;				//the 16-bit number to be potentially shifted
    input [1:0] shift;				//a 2-bit input indicating direction of shift, if any
    output [15:0] sout;
    reg [15:0] sout;

    always @(*) begin
      case(shift)
         2'b00: sout = in;			//no change
         2'b01: sout = {in[14:0],1'b0};		//last 15 bits of in are moved 1 bit to the left and the rightmost bit becomes 0
         2'b10: sout = {1'b0,in[15:1]};		//first 15 bits of in are moved 1 bit to the right and the leftmost bit becomes 0
         2'b11: sout = {in[15], in[15:1]};	//15 bits of in are moved 1 bit to the left and the leftmost bit becomes the first bit of in
         default: sout = {16'bxxxx_xxxx_xxxx_xxxx};
      endcase
   end
endmodule

            