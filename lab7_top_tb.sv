module lab7_top_tb;

  //Ports
  reg [3:0] KEY;
  reg [9:0] SW;
  reg err; 
  wire [9:0] LEDR;
  wire [6:0] HEX0;
  wire [6:0]  HEX1;
  wire [6:0]  HEX2;
  wire [6:0]  HEX3;
  wire [6:0]  HEX4;
  wire [6:0]  HEX5;
  wire clk = ~KEY[0];           
  wire reset = ~KEY[1];

  lab7_top  DUT (
    .KEY(KEY),
    .SW(SW),
    .LEDR(LEDR),
    .HEX0(HEX0),
    . HEX1( HEX1),
    . HEX2( HEX2),
    . HEX3( HEX3),
    . HEX4( HEX4),
    . HEX5( HEX5)
  );

  initial forever begin
    KEY[0] = 0; #5;
    KEY[0] = 1; #5;
  end

  // Reset generation
  initial begin
    KEY[1] = 1'b1;
    #10;
    KEY[1] = 1'b0; // Assert reset
    #10;
    KEY[1] = 1'b1; // Release reset
  end

  // Test stimulus
  initial begin
    // Initialize
    SW = 10'd0;
    err = 1'b0; 
    
    // Wait for reset to complete
    @(posedge KEY[1]);
    @(posedge clk);
    
    // Set switches to test value 
    SW[7:0] = 8'h55; // Test pattern 01010101
    
    // Wait for program to execute
    // MOV R0, SW_BASE (1 cycle)
    // LDR R0, [R0] - load 0x140 (multiple cycles)
    // LDR R2, [R0] - read switches (multiple cycles) 
    // MOV R3, R2, LSL #1 (1 cycle)
    // MOV R1, LEDR_BASE (1 cycle)
    // LDR R1, [R1] - load 0x100 (multiple cycles)
    // STR R3, [R1] - write to LEDs (multiple cycles)
    repeat(60) @(posedge clk);
    
    // Check if LEDR shows shifted switch value
    if(LEDR[8:0] == {SW[7:0], 1'b0}) begin
      $display("TEST PASSED: LEDR = %b (SW shifted left)", LEDR[8:0]);
    end else begin
      $display("TEST FAILED: LEDR = %b, Expected = %b", LEDR[8:0], {SW[7:0], 1'b0});
      err = 1'b1; 
    end

    $stop;
  end

endmodule


