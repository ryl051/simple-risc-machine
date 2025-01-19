module ALU(Ain, Bin, ALUop, out, Z, N, V);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output reg [15:0] out;
    output reg Z, N, V;

    always_comb begin
        case (ALUop)
            2'b00: begin // Addition
                out = Ain + Bin;
                V = (Ain[15] & Bin[15] & ~out[15] | ~Ain[15] & ~Bin[15] & out[15]);
            end  
            2'b01: begin // Subtraction
                out = Ain - Bin;
                V = (Ain[15] & ~Bin[15] & ~out[15] | ~Ain[15] & Bin[15] & out[15]);
            end
            2'b10: begin
                out = Ain & Bin;  // AND operation (bitwise)
                V = 1'b0;
            end
            2'b11: begin 
                out = ~Bin;       // NOT operation (bitwise) on Bin
                V = 1'b0;
            end
            default: out = 16'bx;
        endcase
    end

    assign Z = (out == 16'b0) ? 1'b1 : 1'b0;
    assign N = (out[15] == 1'b1) ? 1'b1 : 1'b0;
endmodule