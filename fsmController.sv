//MOV (with a number)
`define MOV_n 6'd1

//MOV (with a reg)
`define MOV1 6'd2
`define MOV2 6'd3
`define MOV3 6'd4

//MVN
`define MVN1 6'd5
`define MVN2 6'd6
`define MVN3 6'd7

//ADD
`define ADD1 6'd8
`define ADD2 6'd9
`define ADD3 6'd10
`define ADD4 6'd11

//AND
`define AND1 6'd12
`define AND2 6'd13
`define AND3 6'd14
`define AND4 6'd15

//CMP
`define CMP1 6'd16
`define CMP2 6'd17
`define CMP3 6'd18

`define RST 6'd19
`define IF1 6'd20
`define IF2 6'd21
`define UpdatePC 6'd22
`define DECODE 6'd23

`define HALT 6'd24

//LDR commands
/*
1: nsel = 2'b10;
    loada = 1;
2: asel = 0;
    bsel = 1;
    loadc = 1;
3: load_addr = 1;
4: addr_sel = 0;
mem_cmd = 'MREAD
5: vsel = 2'b11;
nsel = 2'b01;
write = 1;
mem_cmd = 'MREAD
*/

`define LDR1 6'd25
`define LDR2 6'd26
`define LDR3 6'd27
`define LDR4 6'd28
`define LDR5 6'd29

//STR commands
/*
1: nsel = 2'b10;
    loada = 1;
2. asel = 0;
    bsel = 1;
    loadc = 1;
3: load_addr = 1;
nsel = 2'b01;
loadb = 1;
4: addr_sel = 0; 
asel = 1;
bsel = 0;
loadc = 1;
5: mem_cmd = `MWRITE


*/

`define STR1 6'd30
`define STR2 6'd31
`define STR3 6'd32
`define STR4 6'd33
`define STR5 6'd34

`define MNONE 2'b00
`define MWRITE 2'b10
`define MREAD 2'b01

module fsmController(clk, reset, opcode, ALUop, 
                     vsel, write, nsel, 
                    loada, loadb, loadc, loads, asel, bsel, load_pc, load_ir, reset_pc, load_addr, addr_sel, mem_cmd);

    input clk, reset;
    input [2:0] opcode;
    input [1:0] ALUop;

    output reg asel, bsel, loada, loadb, loadc, loads, write, load_pc, load_ir, reset_pc, load_addr, addr_sel;
    output reg [1:0] nsel, vsel, mem_cmd;

    reg [5:0] present_state;
	
    always_ff @(posedge clk) begin
        if(reset) begin
            present_state = `RST;
            load_pc = 1;
            reset_pc = 1;
        end
        else begin
            //state transitions
            case(present_state)
                `RST: present_state = `IF1;
                `IF1: present_state = `IF2;
                `IF2: present_state = `UpdatePC;
                `UpdatePC: present_state = `DECODE;

                `DECODE : begin
                    if(opcode == 3'b110 && ALUop == 2'b10)
                        present_state = `MOV_n;
                    else if(opcode == 3'b110 && ALUop == 2'b00)
                        present_state = `MOV1;
                    else if(opcode == 3'b101 && ALUop == 2'b00)
                        present_state = `ADD1;
                    else if(opcode == 3'b101 && ALUop == 2'b01)
                        present_state = `CMP1;
                    else if(opcode == 3'b101 && ALUop == 2'b10)
                        present_state = `AND1;
                    else if(opcode == 3'b101 && ALUop == 2'b11)
                        present_state = `MVN1;
                    //stage 2
                    else if(opcode == 3'b011 && ALUop == 2'b00)
                        present_state = `LDR1;
                    else if(opcode == 3'b100 && ALUop == 2'b00)
                        present_state = `STR1;
                    else if(opcode == 3'b111)
                        present_state = `HALT;
                end

                //MOV (with a number)
                `MOV_n: present_state = `IF1;

                //MOV (with a reg)
                `MOV1: present_state = `MOV2;
                `MOV2: present_state = `MOV3;
                `MOV3: present_state = `IF1;

                //ADD
                `ADD1: present_state = `ADD2;
                `ADD2: present_state = `ADD3;
                `ADD3: present_state = `ADD4;
                `ADD4: present_state = `IF1;

                //CMP
                `CMP1: present_state = `CMP2;
                `CMP2: present_state = `CMP3;
                `CMP3: present_state = `IF1;

                //AND
                `AND1: present_state = `AND2;
                `AND2: present_state = `AND3;
                `AND3: present_state = `AND4;
                `AND4: present_state = `IF1;

                //MVN
                `MVN1: present_state = `MVN2;
                `MVN2: present_state = `MVN3;
                `MVN3: present_state = `IF1;

                //LDR
                `LDR1: present_state = `LDR2;
                `LDR2: present_state = `LDR3;
                `LDR3: present_state = `LDR4;
                `LDR4: present_state = `LDR5;
                `LDR5: present_state = `IF1;

                //STR
                `STR1: present_state = `STR2;
                `STR2: present_state = `STR3;
                `STR3: present_state = `STR4;
                `STR4: present_state = `STR5;
                `STR5: present_state = `IF1;

                `HALT: present_state = `HALT;
                default: present_state = `IF1;
            endcase
    
            nsel = 2'b00;
            vsel = 2'b00;
            mem_cmd = 2'b00; // MNONE
            loada = 0;
            loadb = 0;
            loadc = 0;
            write = 0;
            asel = 0;
            bsel = 0;
            load_pc = 0;
            load_ir = 0;
            reset_pc = 0;
            load_addr = 0;
            addr_sel = 0;

            // State-dependent outputs
            case (present_state)
                `RST: begin
                    load_pc = 1;
                    reset_pc = 1;
                end
                `IF1: begin
                    addr_sel = 1;
                    mem_cmd = `MREAD;
                end
                `IF2: begin
                    addr_sel = 1;
                    load_ir = 1;
                    mem_cmd = `MREAD;
                end
                `UpdatePC: begin
                    load_pc = 1;
                end
                `MOV_n: begin
                    nsel = 2'b10;
                    vsel = 2'b10;
                    write = 1;
                end
                `MOV1: begin
                    loadb = 1;
                end
                `MOV2: begin
                    asel = 1;
                    loadc = 1;
                end
                `MOV3: begin
                    nsel = 2'b01;
                    write = 1;
                end
                `ADD1: begin
                    nsel = 2'b10;
                    loada = 1;
                end
                `ADD2: begin
                    loadb = 1;
                end
                `ADD3: begin
                    loadc = 1;
                end
                `ADD4: begin
                    nsel = 2'b01;
                    write = 1;
                end
                `CMP1: begin
                    nsel = 2'b10;
                    loada = 1;
                end
                `CMP2: begin
                    loadb = 1;
                end
                `CMP3: begin
                    loads = 1;
                end
                `AND1: begin
                    nsel = 2'b10;
                    loada = 1;
                end
                `AND2: begin
                    loadb = 1;
                end
                `AND3: begin
                    loadc = 1;
                end
                `AND4: begin
                    nsel = 2'b01;
                    write = 1;
                end
                `MVN1: begin
                    loadb = 1;
                end
                `MVN2: begin
                    asel = 1;
                    loadc = 1;
                end
                `MVN3: begin
                    nsel = 2'b01;
                    write = 1;
                end
                //stage 2: LDR cycles
                `LDR1: begin
                    nsel = 2'b10;       
                    loada = 1;
                end
                `LDR2: begin
                    asel = 0;
                    bsel = 1;
                    loadc = 1;
                end
                `LDR3: begin
                    load_addr = 1;
                end
                `LDR4: begin
                    addr_sel = 0;
                    mem_cmd = `MREAD;
                end
                `LDR5: begin
                    vsel = 2'b11;
                    nsel = 2'b01;
                    write = 1;
                    mem_cmd = `MREAD;
                end
                //stage 2: STR cycles
                `STR1: begin
                    nsel = 2'b10;
                    loada = 1;
                end
                `STR2: begin
                    asel = 0;
                    bsel = 1;
                    loadc = 1;
                end
                `STR3: begin
                    load_addr = 1;
                    nsel = 2'b01;
                    loadb = 1;
                end
                `STR4: begin
                    addr_sel = 0;
                    asel = 1;
                    bsel = 0;
                    loadc = 1;
                end
                `STR5: begin
                    mem_cmd = `MWRITE;
                end
            endcase
        end
    end
endmodule