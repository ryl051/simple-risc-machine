
module cpu_tb;

    //Ports
    reg clk;
    reg  reset;
    reg  s;
    reg  load;
    reg err; 
    reg [15:0] in;
    wire [15:0] out;
    wire N;
    wire V;
    wire Z;
    wire w;

    cpu DUT (
        .clk(clk),
        .reset(reset),
        .s(s),
        .load(load),
        .in(in),
        .out(out),
        .N(N),
        .V(V),
        .Z(Z),
        .w(w)
    );
    
    task my_checker;
        input [15:0] expected_out;
        input expected_N, expected_V, expected_Z;

        // check that output matches expected values 
        begin
            if (DUT.out !== expected_out) begin
                $display("ERROR ** out is %b, expected %b", DUT.out, expected_out);
                err = 1'b1;
            end
            if (DUT.N !== expected_N) begin
                $display("ERROR ** N output is %b, expected %b", DUT.N, expected_N);
                err = 1'b1;
            end
            if (DUT.V !== expected_V) begin
                $display("ERROR ** V output is %b, expected %b", DUT.V, expected_V);
                err = 1'b1;
            end
            if (DUT.Z !== expected_Z) begin
                $display("ERROR ** Z output is %b, expected %b", DUT.Z, expected_Z);
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

        err = 0;
        reset = 1; s = 0; load = 0; in = 16'b0;
        #10;
        reset = 0; 
        #10;
        my_checker(16'bx, 1'bx, 1'bx, 1'bx); // check that w = 1

        // MOV R0, #3
        in = 16'b110_10_000_00000011;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        @(posedge w); // wait for w to go high again
        #10;
        my_checker(16'bx, 1'bx, 1'bx, 1'bx); 

        // MOV R1, #2
        @(negedge clk); // wait for falling edge of clock before changing inputs
        in = 16'b110_10_001_00000010;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        @(posedge w); // wait for w to go high again
        #10;
        my_checker(16'bx, 1'bx, 1'bx, 1'bx); 

        // MOV R2, #10
        @(negedge clk); // wait for falling edge of clock before changing inputs
        in = 16'b110_10_010_00001010;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        @(posedge w); // wait for w to go high again
        #10;
        my_checker(16'bx, 1'bx, 1'bx, 1'bx); 

        // MOV R3, R0
        @(negedge clk); // wait for falling edge of clock before changing inputs
        in = 16'b110_00_000_011_00_000;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        @(posedge w); // wait for w to go high again
        #10;
        my_checker(16'd3, 1'bx, 1'bx, 1'bx); 

        // MOV R4, R2, LSL #1
        @(negedge clk); // wait for falling edge of clock before changing inputs
        in = 16'b110_00_000_100_01_010;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        @(posedge w); // wait for w to go high again
        #10;
        my_checker(16'd20, 1'bx, 1'bx, 1'bx); 

        // MOV R5, R1, LSR #1
        @(negedge clk); // wait for falling edge of clock before changing inputs
        in = 16'b110_00_000_101_10_001;
        load = 1;
        #10;
        load = 0;
        s = 1;
        #10
        s = 0;
        @(posedge w); // wait for w to go high again
        #10;
        my_checker(16'd1, 1'bx, 1'bx, 1'bx); 


        // ADD R4, R0, R1 
        @(negedge clk); 
        in = 16'b101_00_000_100_00_001;
        load = 1; 
        #10;
        load = 0;
        s = 1; 
        #10;
        s = 0; 
        @(posedge w);
        #10; 
        my_checker(16'd5, 1'bx, 1'bx, 1'bx); 

        // ADD R4, R0, R1, LSL #1  
        @(negedge clk); 
        in = 16'b101_00_000_100_01_001;
        load = 1; 
        #10;
        load = 0;
        s = 1; 
        #10;
        s = 0; 
        @(posedge w);
        #10; 
        my_checker(16'd7, 1'bx, 1'bx, 1'bx); 

        // ADD R4, R0, R1, LSR #1  
        @(negedge clk); 
        in = 16'b101_00_000_100_10_001;
        load = 1; 
        #10;
        load = 0;
        s = 1; 
        #10;
        s = 0; 
        @(posedge w);
        #10; 
        my_checker(16'd4, 1'bx, 1'bx, 1'bx); 

        // CMP R0, R0  
        @(negedge clk); 
        in = 16'b101_01_000_000_00_000;
        load = 1; 
        #10;
        load = 0;
        s = 1; 
        #10;
        s = 0; 
        @(posedge w);
        #10; 
        my_checker(16'd4, 1'b0, 1'b0, 1'b1); 

        // CMP R1, R0  
        @(negedge clk); 
        in = 16'b101_01_001_000_00_000;
        load = 1; 
        #10;
        load = 0;
        s = 1; 
        #10;
        s = 0; 
        @(posedge w);
        #10; 
        my_checker(16'd4, 1'b1, 1'b0, 1'b0); 

        // CMP R2, R1, LSR #1  
        @(negedge clk); 
        in = 16'b101_01_010_000_10_001;
        load = 1; 
        #10;
        load = 0;
        s = 1; 
        #10;
        s = 0; 
        @(posedge w);
        #10; 
        my_checker(16'd4, 1'b0, 1'b0, 1'b0);
        
        // AND R4, R0, R1 
        @(negedge clk); 
        in = 16'b101_10_000_100_00_001;
        load = 1; 
        #10;
        load = 0;
        s = 1; 
        #10;
        s = 0; 
        @(posedge w);
        #10; 
        my_checker(16'd2, 1'b0, 1'b0, 1'b0);

        // AND R4, R1, R2 
        @(negedge clk); 
        in = 16'b101_10_001_100_00_010;
        load = 1; 
        #10;
        load = 0;
        s = 1; 
        #10;
        s = 0; 
        @(posedge w);
        #10; 
        my_checker(16'd2, 1'b0, 1'b0, 1'b0);

        // AND R4, R2, R5 LSL #1  
        @(negedge clk); 
        in = 16'b101_10_010_100_01_101;
        load = 1; 
        #10;
        load = 0;
        s = 1; 
        #10;
        s = 0; 
        @(posedge w);
        #10; 
        my_checker(16'd2, 1'b0, 1'b0, 1'b0);

        // MVN R6, R0  
        @(negedge clk); 
        in = 16'b101_11_000_110_00_000;
        load = 1; 
        #10;
        load = 0;
        s = 1; 
        #10;
        s = 0; 
        @(posedge w);
        #10; 
        my_checker(16'b1111_1111_1111_1100, 1'b0, 1'b0, 1'b0);

        // MVN R6, R0, LSL #1  
        @(negedge clk); 
        in = 16'b101_11_000_110_01_000;
        load = 1; 
        #10;
        load = 0;
        s = 1; 
        #10;
        s = 0; 
        @(posedge w);
        #10; 
        my_checker(16'b1111_1111_1111_1001, 1'b0, 1'b0, 1'b0);

        // MVN R7, R5
        @(negedge clk); 
        in = 16'b101_11_000_111_00_101;
        load = 1; 
        #10;
        load = 0;
        s = 1; 
        #10;
        s = 0; 
        @(posedge w);
        #10; 
        my_checker(16'b1111_1111_1111_1110, 1'b0, 1'b0, 1'b0);

        if(err == 0)
            $display("All tests passed");
        else
            $display("Error occured");

        $stop;
    end
    
    
endmodule