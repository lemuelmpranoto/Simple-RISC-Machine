module cpu_tb ();
reg [15:0] in;
reg clk, reset,s, load;
wire N, V, Z, w;
wire [15:0] out;
reg err;

  initial begin
    clk = 1'b0; #5;

  forever begin
    clk = 1'b1; #5;		//keeps clock cycling throughout testing in order to test sequential logic
    clk = 1'b0; #5;
    end
  end

cpu DUT(clk,reset,s,load,in,out,N,V,Z,w);    //instantiate device under test


  initial begin
    err = 0;					
    reset = 1; s = 0; load = 0; in = 16'b0;
    #10;
    reset = 0; 
    #10;

    in = 16'b1101000000000111;    //attempting to write number 7 into R0
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w);  //waits until FSM is back to wait state
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'h7) begin
      err = 1;
      $display("FAILED: MOV R0, #7");
      $stop;
    end

    in = 16'b1101000100000010;    //attempting to write number 2 into R1
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'h2) begin
      err = 1;
      $display("FAILED: MOV R1, #2");
      $stop;
    end

    in = 16'b110_10_011_000_01_010;    //attempting to write number 10 into R3
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R3 !== 16'd10) begin
      err = 1;
      $display("FAILED: MOV R3, #10");
      $stop;
    end

    in = 16'b110_00_000_100_00_000;    //attempting to write contents of R0 (7) into R4
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R4 !== 16'd7) begin
      err = 1;
      $display("FAILED: MOV R4, R0");
      $stop;
    end

    in = 16'b110_00_000_101_01_001;    //attempting to write contents of R1 shifted to left (4) into R5
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R5 !== 16'd4) begin
      err = 1;
      $display("FAILED: MOV R5, R1, LSL#1");
      $stop;
    end

    in = 16'b110_00_000_101_10_001;    //attempting to write contents of R1 shifted to right (1) into R5
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R5 !== 16'd1) begin
      err = 1;
      $display("FAILED: MOV R5, R1, LSR#1");
      $stop;
    end

    in = 16'b101_00_001_010_01_000;    //adding contents of R1 (2) with contents of R0 shifted to left (14), should get 16 in R2
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'h10) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0, LSL#1");
      $stop;
    end

    in = 16'b101_00_001_010_00_000;    //adding contents of R1 (2) with contents of R0 (7), should get 9 in R2
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'h9) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0");
      $stop;
    end

    in = 16'b101_00_000_010_10_001;    //adding contents of 
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'h8) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0, LSR#1");
      $stop;
    end

    in = 16'b101_01_001_000_00_000;
    load = 1;
    #10;
    load = 0;
    s = 1; 
    #10;
    s = 0;
    @(posedge w); 
    #10;
    if ((cpu_tb.DUT.DP.out !== 16'hFFFB) || ~(cpu_tb.DUT.N)) begin
      err = 1;
      $display("FAILED: CMP R1, R0");
      $stop;
    end

    in = 16'b101_01_000_000_00_000;
    load = 1;
    #10;
    load = 0;
    s = 1; 
    #10;
    s = 0;
    @(posedge w); 
    #10;
    if ((cpu_tb.DUT.DP.out !== 16'h0) || ~(cpu_tb.DUT.Z)) begin
      err = 1;
      $display("FAILED: CMP R0, R0");
      
    end

    in = 16'b101_01_000_000_10_001;
    load = 1;
    #10;
    load = 0;
    s = 1; 
    #10;
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.out !== 16'd6) begin
      err = 1;
      $display("FAILED: CMP R1, R0, LSR#1");
      $stop;
    end

    in = 16'b101_10_000_010_00_001;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10;
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'd2) begin
      err = 1;
      $display("FAILED: AND R2, R1, R0");
    
    end

    in = 16'b101_10_000_010_01_001;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10;
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'd4) begin
      err = 1;
      $display("FAILED: AND R2, R1, R0, LSL#1");
      
    end

    in = 16'b101_10_000_010_10_001;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10;
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'd1) begin
      err = 1;
      $display("FAILED: AND R2, R1, R0, LSR#1");
     
    end

    in = 16'b101_11_000_010_00_000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10;
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'hFFF8) begin
      err = 1;
      $display("FAILED: MVN R2, R0");
      
    end

    in = 16'b101_11_000_010_01_000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10;
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'hFFF1) begin
      err = 1;
      $display("FAILED: MVN R2, R0, LSL#1");
      
    end

    in = 16'b101_11_000_010_10_000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10;
    s = 0;
    @(posedge w); 
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'hFFFC) begin
      err = 1;
      $display("FAILED: MVN R2, R0, LSR#1");
      
    end

    if (~err) $display("PASSED ALL!!!!!!!!!!!!! ");
    $stop;

 end
endmodule