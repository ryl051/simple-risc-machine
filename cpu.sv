// instanstiate and connect together the instruction register, instruction decoder block, sstate machine, and datapath
module cpu(clk,reset, read_data, mdata, write_data,N,V,Z, mem_addr, mem_cmd);
    
    input clk, reset;
    input [15:0] read_data, mdata;
    output [15:0] write_data;
    output N, V, Z;
    output [8:0] mem_addr;
    output [1:0] mem_cmd;

    // Internal signals
    wire [15:0] instruction_register_out;
    wire [1:0] vsel, ALUop, shift, nsel; 
    wire [2:0] opcode;
    wire [2:0] readnum, writenum;
    wire write, loada, loadb, loadc, loads, asel, bsel;
    wire [15:0] sximm5, sximm8;

    // Connect outputs to datapath signals
    wire N_out, V_out, Z_out;
   // wire [15:0] datapath_out;

    //lab 7 additions
    wire[8:0] PC, next_pc, incremented_PC;
    wire load_pc, load_ir, reset_pc, load_addr, addr_sel;

    wire[8:0] data_addr_out;
    
    assign N = N_out;
    assign V = V_out;
    assign Z = Z_out;
    
    //stage 1 mem_addr mux
    assign mem_addr = addr_sel ? PC : data_addr_out;

    //stage 1 pc block
    assign next_pc = reset_pc ? 9'b0 : incremented_PC;
    assign incremented_PC = PC + 1;
    vDFFE #(9) pc(clk, load_pc, next_pc, PC);

    //stage 2 data reg
    vDFFE #(9) data_addr(clk, load_addr, write_data[8:0], data_addr_out);

    vDFFE instruction_register(clk, load_ir, read_data, instruction_register_out);
    
    instructionDecoder instruction_decoder(
        .instruction(instruction_register_out),
        .nsel(nsel),
        .opcode(opcode),
        .ALUop(ALUop),
        .shift(shift),
        .sximm5(sximm5),
        .sximm8(sximm8),
        .readnum(readnum),
        .writenum(writenum)
    );

    fsmController fsmController(
        .clk(clk),
        .reset(reset),       
        .opcode(opcode),
        .ALUop(ALUop),
        .vsel(vsel),
        .write(write),
        .nsel(nsel),
        .loada(loada),
        .loadb(loadb),
        .loadc(loadc),
        .loads(loads),
        .asel(asel),
        .bsel(bsel),
        .load_pc(load_pc),
        .load_ir(load_ir),
        .reset_pc(reset_pc),
        .load_addr(load_addr),
        .addr_sel(addr_sel),
        .mem_cmd(mem_cmd)
    );

    datapath DP(
        .clk(clk),
        .readnum(readnum),
        .vsel(vsel),
        .loada(loada),
        .loadb(loadb),
        .shift(shift),
        .asel(asel),
        .bsel(bsel),
        .ALUop(ALUop),
        .loadc(loadc),
        .loads(loads),
        .writenum(writenum),
        .write(write),
        .sximm8(sximm8),
        .sximm5(sximm5),
        .mdata(read_data),
        .pc(PC),
        .Z_out(Z_out),
        .N_out(N_out),
        .V_out(V_out),
        .datapath_out(write_data)
    );
    
endmodule

