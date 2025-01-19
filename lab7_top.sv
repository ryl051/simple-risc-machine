`define MNONE 2'b00
`define MWRITE 2'b10
`define MREAD 2'b01

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire N,V,Z, write_input;

    wire clk = ~KEY[0];           // Use KEY[0] as clock
    wire reset = ~KEY[1];
    wire [8:0] mem_addr;
    wire [15:0] write_data, dout;
    wire [15:0] read_data;
    wire msel, read_sel, write_sel;
    wire [1:0] mem_cmd;

    reg SWOut, LEDOut;

    assign HEX5[0] = ~Z;  
    assign HEX5[6] = ~N;
    assign HEX5[3] = ~V;

  // fill in sseg to display 4-bits in hexidecimal 0,1,2...9,A,B,C,D,E,F
    sseg H0(write_data[3:0],   HEX0);
    sseg H1(write_data[7:4],   HEX1);
    sseg H2(write_data[11:8],  HEX2);
    sseg H3(write_data  [15:12], HEX3);
    assign HEX4 = 7'b1111111;
    assign {HEX5[2:1],HEX5[5:4]} = 4'b1111; // disabled
    assign LEDR[8] = 1'b0;

    cpu CPU (
        .clk(clk),
        .reset(reset),
        .read_data(read_data),
        .mdata(read_data),
        .write_data(write_data),
        .N(N),
        .V(V),
        .Z(Z),
        .mem_addr(mem_addr),
        .mem_cmd(mem_cmd)
    );
    // Instantiate Memory
    RAM #(
        .data_width(16),
        .addr_width(8),
        .filename("data.txt")
    ) MEM (
        .clk(clk),
        .read_address(mem_addr[7:0]),
        .write_address(mem_addr[7:0]),  
        .write(write_input),
        .din(write_data),
        .dout(dout)
    );

    //block 7
    assign read_data = (msel & read_sel) ? dout : {16{1'bz}};

    //block 8
    assign msel = (mem_addr[8:8] == 1'b0) ? 1'b1 : 1'b0;

    //block 9
    assign read_sel = (mem_cmd == `MREAD) ? 1'b1 : 1'b0;

    //block for input to write for RAM
    assign write_sel =  (`MWRITE == mem_cmd) ? 1'b1 : 1'b0;
    assign write_input = (write_sel & msel);

    //block for switches
    //tri-state for switches
    assign read_data[7:0] = (SWOut) ? SW[7:0] : {16{1'bz}};
    //tri-state from the circuit
    assign read_data[15:8] = (SWOut) ? 8'h00 : {16{1'bz}};
    //circuit
    always_comb begin
        if(mem_cmd == `MREAD && mem_addr == 9'b101000000)
          SWOut = 1;
        else
          SWOut = 0;
    end

    //block for LED
    //LED register
    vDFFE #(8) LEDReg(clk, LEDOut, write_data[7:0], LEDR[7:0]);
    //circuit
    always_comb begin
      if(mem_cmd == `MWRITE && mem_addr == 9'b100000000)
        LEDOut = 1;
      else
        LEDOut = 0;
    end
endmodule

module RAM(clk,read_address,write_address,write,din,dout);
  parameter data_width = 32; 
  parameter addr_width = 4;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule

module sseg(in,segs);
  input [3:0] in;
  output reg [6:0] segs;

  always_comb begin
    //converts binary to relevant seven segment display code
    case (in)
      4'b0000: segs = 7'b1000000; // 0
      4'b0001: segs = 7'b1111001; // 1
      4'b0010: segs = 7'b0100100; // 2
      4'b0011: segs = 7'b0110000; // 3
      4'b0100: segs = 7'b0011001; // 4
      4'b0101: segs = 7'b0010010; // 5
      4'b0110: segs = 7'b0000010; // 6
      4'b0111: segs = 7'b1111000; // 7
      4'b1000: segs = 7'b0000000; // 8
      4'b1001: segs = 7'b0011000; // 9
      4'b1010: segs = 7'b0001000; // A
      4'b1011: segs = 7'b0000011; // B
      4'b1100: segs = 7'b1000110; // C
      4'b1101: segs = 7'b0100001; // d
      4'b1110: segs = 7'b0000110; // E
      4'b1111: segs = 7'b0001110; // F
      default: segs = 7'b1111111; // blank
    endcase
  end

endmodule