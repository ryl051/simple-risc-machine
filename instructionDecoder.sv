module instructionDecoder (instruction, nsel, opcode, ALUop, shift, sximm5, sximm8, readnum, writenum);
    input [15:0] instruction;
    input [1:0] nsel; //intput from the fsm controller
    output [2:0] opcode;
    output [1:0] ALUop, shift; //Note that ALUop == op 
    output [15:0] sximm5, sximm8; 
    output reg [2:0] readnum, writenum;

    assign opcode = instruction[15:13];
    assign ALUop = instruction[12:11];
    assign shift = instruction[4:3];
    assign sximm5 = {{11{instruction[4]}}, instruction[4:0]}; //extend 8 bit 
    assign sximm8 = {{8{instruction[7]}}, instruction[7:0]}; //extend 5 bit

    wire [2:0] Rm, Rd, Rn;
    assign Rm = instruction[2:0];
    assign Rd = instruction[7:5];
    assign Rn = instruction[10:8];

    //nsel mux inside the instruction Decoder
    always_comb begin
        case(nsel)
            2'b00: begin
                readnum = Rm;
                writenum = Rm;
            end
            2'b01: begin
                readnum = Rd;
                writenum = Rd;
            end
            2'b10: begin
                readnum = Rn;
                writenum = Rn;
            end
            default: begin
                readnum = 3'bxxx;
                writenum = 3'bxxx;
            end
        endcase
    end
endmodule
