module datapath_tb();

    reg clk, vsel, loada, loadb, asel, bsel, loadc, loads, write;
    reg [2:0] writenum, readnum;
    reg [1:0] ALUop, shift;
    reg [15:0] datapath_in;
    wire [15:0] datapath_out;
    wire Z_out;
    reg err;

    datapath DUT(.clk         (clk),
                // register operand fetch stage
                .readnum     (readnum),
                .vsel        (vsel),
                .loada       (loada),
                .loadb       (loadb),

                // computation stage (sometimes called "execute")
                .shift       (shift),
                .asel        (asel),
                .bsel        (bsel),
                .ALUop       (ALUop),
                .loadc       (loadc),
                .loads       (loads),

                // set when "writing back" to register file
                .writenum    (writenum),
                .write       (write),  
                .datapath_in (datapath_in),

                // outputs
                .Z_out       (Z_out),
                .datapath_out(datapath_out));

    //checker to check datapath_out, and the individual registers
    task my_checker;
    input [15:0] expected_output;
    input [15:0] expected_reg0;
    input [15:0] expected_reg1;
    input [15:0] expected_reg2;
    input [15:0] expected_reg3;
    input [15:0] expected_reg4;
    input [15:0] expected_reg5;
    input [15:0] expected_reg6;
    input [15:0] expected_reg7;
        begin
            if(datapath_out != expected_output) begin
                $display("ERROR ** output is %b, expected %b", datapath_out, expected_output);
                err = 1'b1;
            end
            if(DUT.REGFILE.R0 != expected_reg0) begin
                $display("ERROR ** register is %b, expected %b", DUT.REGFILE.R0, expected_reg0);
                err = 1'b1;
            end
            if(DUT.REGFILE.R1 != expected_reg1) begin
                $display("ERROR ** register is %b, expected %b", DUT.REGFILE.R1, expected_reg1);
                err = 1'b1;
            end
            if(DUT.REGFILE.R2 != expected_reg2) begin
                $display("ERROR ** register is %b, expected %b", DUT.REGFILE.R2, expected_reg2);
                err = 1'b1;
            end
            if(DUT.REGFILE.R3 != expected_reg3) begin
                $display("ERROR ** register is %b, expected %b", DUT.REGFILE.R3, expected_reg3);
                err = 1'b1;
            end    
            if(DUT.REGFILE.R4 != expected_reg4) begin
                $display("ERROR ** register is %b, expected %b", DUT.REGFILE.R4, expected_reg4);
                err = 1'b1;
            end    
            if(DUT.REGFILE.R5 != expected_reg5) begin
                $display("ERROR ** register is %b, expected %b", DUT.REGFILE.R5, expected_reg5);
                err = 1'b1;
            end    
            if(DUT.REGFILE.R6 != expected_reg6) begin
                $display("ERROR ** register is %b, expected %b", DUT.REGFILE.R6, expected_reg6);
                err = 1'b1;
            end    
            if(DUT.REGFILE.R7 != expected_reg7) begin
                $display("ERROR ** register is %b, expected %b", DUT.REGFILE.R7, expected_reg7);
                err = 1'b1;
            end    
        end 
    endtask

    initial begin
        clk = 1'b0;
        #5;

        forever begin
            clk = 1'b1;
            #5;
            clk = 1'b0;
            #5;
        end
    end

    initial begin
         vsel = 0; loada = 0; loadb = 0; asel = 0; bsel = 0;
        loadc = 0; loads = 0; write = 0; ALUop = 2'b00; shift = 2'b00;
        err = 1'b0;

    
        //MOV R0, #7;
        writenum = 3'd0;
        write = 1'b1;
        datapath_in = 16'd7;
        vsel = 1'b1;
        #10; write = 1'b0;

        my_checker(16'bx, 16'd7, 16'bx, 16'bx, 16'bx, 16'bx, 16'bx, 16'bx, 16'bx);

        //MOV R1, #2;
        writenum = 3'd1;
        write = 1'b1;
        datapath_in = 16'd2;
        vsel = 1'b1;
        #10; write  = 1'b0;

       my_checker(16'bx, 16'd7, 16'd2, 16'bx, 16'bx, 16'bx, 16'bx, 16'bx, 16'bx);

        //ADD R2, R1, R0, LSL#1 
        //first step: load R0 into reg B
        readnum = 3'd0;
        loadb = 1'b1;
        #10; loadb = 1'b0;

        //second step: load R1 into reg A
        readnum = 3'd1;
        loada = 1'b1;
        #10; loada = 1'b0;

        //third step: do the computation
        shift = 2'b01;
        asel = 1'b0;
        bsel = 1'b0;
        ALUop = 2'b00;
        loadc = 1'b1;
        #10; loadc = 1'b0;

        //fourth step: load value back into R2
        writenum = 3'd2;
        write = 1'b1;
        vsel = 1'b0;
        #10; write = 1'b0;

        my_checker(16'd16, 16'd7, 16'd2, 16'd16, 16'bx, 16'bx, 16'bx, 16'bx, 16'bx);

        //MOV R4, R2
        readnum = 3'd2;
        loadb = 1'b1;
        #10; loadb = 1'b0;

        shift = 2'b00;
        asel = 1'b1;
        bsel = 1'b0;
        ALUop = 2'b00;
        loadc = 1'b1;
        #10; loadc = 1'b0;

        writenum = 3'd4;
        write = 1'b1;
        vsel = 1'b0;
        #10; write = 1'b0;

        my_checker(16'd16, 16'd7, 16'd2, 16'd16, 16'bx, 16'd16, 16'bx, 16'bx, 16'bx);

        //testing the mux for asel and bsel
        datapath_in = 16'b1111111111111111;
        asel = 1'b1;
        bsel = 1'b1;
        ALUop = 2'b00;
        loadc = 1'b1;
        #10; loadc = 1'b0;

        writenum = 3'd5;
        write = 1'b1;
        vsel = 1'b0;
        #10; write = 1'b0;

        my_checker(16'b0000000000011111, 16'd7, 16'd2, 16'd16, 16'bx, 16'd16, 16'b0000000000011111, 16'bx, 16'bx);

        if(err == 0)
            $display("All tests passed");
        else
            $display("Error occured");
    end
endmodule
