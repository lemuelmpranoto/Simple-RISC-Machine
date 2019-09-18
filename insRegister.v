//module instruction register
module insRegister (in, clk, load, out);

//declaring inputs and outputs, regs and wires
parameter n=8;
input [n-1:0] in;
input load, clk;
output [n-1:0] out;
reg [n-1:0] out;
wire [n-1:0] next_out;

//assigning next out to in if load is 1 or out if load is 0
assign next_out = load ? in : out;

//non blocking next out to out
always @(posedge clk)begin
    out <= next_out;
end
endmodule
 
