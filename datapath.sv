module datapath (clk, // recall from Lab 4 that KEY0 is 1 when NOT pushed

                // register operand fetch stage
                readnum,
                vsel,
                loada,
                loadb,

                // computation stage (sometimes called "execute")
                shift,
                asel,
                bsel,
                ALUop,
                loadc,
                loads,

                // set when "writing back" to register file
                writenum,
                write,  

                //stage 1: modifications to datapath
                sximm8,
                sximm5,
                mdata,
                pc,

                // outputs
                Z_out,
                N_out,
                V_out,
                datapath_out);

    input clk, loada, loadb, asel, bsel, loadc, loads, write;
    input [2:0] writenum, readnum;
    input [1:0] ALUop, shift, vsel;
    input [15:0] sximm8, sximm5, mdata;
    input [8:0] pc; //changed in lab 7
    output [15:0] datapath_out;
    output Z_out, N_out, V_out;
   
    wire [15:0] sout, in, out, data_in, data_out, ARegOut, Ain, Bin;
    wire Z, N, V;

    regfile REGFILE (data_in, writenum, write, readnum, clk, data_out); //block 1
    ALU ALU (Ain, Bin, ALUop, out, Z, N, V); //block 2
    shifter shifter (in, shift, sout); //block 8

    vDFFE  A (clk, loada, data_out, ARegOut); //reg A
    vDFFE  B (clk, loadb, data_out, in); //reg B
    vDFFE  C (clk, loadc, out, datapath_out); //reg C
    vDFFE #(3) status(clk, loads, {Z, N, V}, {Z_out, N_out, V_out}); //reg status, updated with Z,N,V flags
    
    //stage 1: datapath modifications
    //vsel modification
    assign data_in = (vsel == 2'b00) ? datapath_out :
                     (vsel == 2'b01) ? {7'b0, pc} : //changed in lab 7
                     (vsel == 2'b10) ? sximm8 :
                     mdata; // Select data input for register file

    assign Ain = asel ? 16'b0 : ARegOut; // asel mux
    assign Bin = bsel ? sximm5 : sout;   // bsel mux
endmodule