module shifter(in, shift, sout);
    input [15:0] in;
    input [1:0] shift;
    output reg [15:0] sout;

    always_comb begin
        case(shift) 
            2'b01: sout = in << 1; //B shifted left 1-bit, least significant bit is zero
            2'b10: sout = in >> 1; //B shifted right 1-bit, most significant bit, MSB, is 0
            2'b11: begin
                sout = in >> 1; //B shifted right 1-bit, MSB is copy of B[15]
                sout[15] = in[15];
            end
            default: sout = in; //B
        endcase
    end
endmodule

