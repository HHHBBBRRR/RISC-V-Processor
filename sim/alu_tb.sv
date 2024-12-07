`timescale 1ns / 100ps

module alu_tb();
    parameter SEED = 1;
    parameter NUM_TEST = 10000;

    logic [31:0] a;
    logic [31:0] b;
    logic [2:0] funct3;
    logic funct7b5;
    logic [31:0] result;
    logic negative;
    logic zero;
    logic carry;
    logic overflow;

    logic [31:0] expect_result;
    logic expect_negative;
    logic expect_zero;
    logic expect_carry;
    logic expect_overflow;
    logic clk;
    integer i, errors;

    alu DUT(
        .a(a), 
        .b(b), 
        .control({funct7b5 | funct3[1], funct3}), // trick!!!
        .result(result), 
        .negative(negative), 
        .zero(zero), 
        .carry(carry), 
        .overflow(overflow)
    );

    // check only alu result output
    task check; begin
        if (result !== expect_result) begin
            errors = errors + 1;
            $display("ERROR: a = %h, b = %h, expect %h, actual %h", a, b, expect_result, result);
        end 
    end   
    endtask //check

    // check all alu outputs (result + flags)
    task check_all; begin
        if (result !== expect_result || negative !== expect_negative || zero !== expect_zero || carry !== expect_carry || overflow !== expect_overflow) begin
            errors = errors + 1;
            $display("ERROR: a = %h, b = %h, \
                    expect %h, actual %h, \
                    expect negative %b, actual negative %b, \
                    expect zero %b, actual zero %b, \
                    expect carry %b, actual carry %b, \
                    expect overflow %b, actual overflow %b", 
                    a, b, expect_result, result, expect_negative, negative, expect_zero, zero, expect_carry, carry, expect_overflow, overflow);
        end
    end   
    endtask //check_all

    initial clk = 1;
    always #5 clk = ~clk;

    initial begin
        $display("ALU test begin");
        errors = 0;
        a = $random(SEED);
        b = 32'b0;
        expect_result = 32'b0;
        expect_negative = 0;
        expect_zero = 0;
        expect_carry = 0;
        expect_overflow = 0;

        /*******
        * add
        *******/
        $display("test add");
        funct3 = 3'b000;
        funct7b5 = 0;
        for (i = 0; i < NUM_TEST; i = i + 1) begin
            a = $random;
            b = $random;
            expect_result = a + b;
            #10;
            check();
        end
        $display("test add finish");

        /*******
        * sub
        *******/
        $display("test sub");
        funct3 = 3'b000;
        funct7b5 = 1;
        for (i = 0; i < NUM_TEST; i = i + 1) begin
            a = $random;
            b = $random;
            /* Only Branch Unit uses ALU flags.
               To compare inputs A and B, the ALU computes A - B and looks at the flags. 
               Therefore, we only check the flags when the ALU executes the sub instruction. */
            expect_result = a - b;
            expect_negative = expect_result[31];
            expect_zero = (expect_result == 32'b0);
            expect_carry = ($unsigned(a) < $unsigned(b) ? 0 : 1);
            if ($signed(a) >= 0 && $signed(b) < 0 && $signed(expect_result) < 0) begin
                expect_overflow = 1;
            end 
            else if ($signed(a) < 0 && $signed(b) >= 0 && $signed(expect_result) >= 0) begin
                expect_overflow = 1;
            end 
            else begin
                expect_overflow = 0;
            end

            #10;
            check_all();
        end
        $display("test sub finish");

        /******
        * sll
        ******/
        $display("test sll");
        funct3 = 3'b001;
        funct7b5 = 0;
        a = 32'hFFFF_FFFF;
        for (i = 0; i < 32; i = i + 1) begin
            b = i;
            expect_result = a << b;

            #10;
            check();
        end
        $display("test sll finish");

        /******
        * slt
        ******/
        $display("test slt");
        funct3 = 3'b010;
        funct7b5 = 0;
        for (i = 0; i < NUM_TEST; i = i + 1) begin
            a = $random;
            b = $random;
            expect_result = ($signed(a) < $signed(b)) ? 32'h1 : 32'h0;
            #10;
            check();
        end
        $display("test slt finish");

        /******
        * sltu
        ******/
        $display("test sltu");
        funct3 = 3'b011;
        funct7b5 = 0;
        for (i = 0; i < NUM_TEST; i = i + 1) begin
            a = $random;
            b = $random;
            expect_result = ($unsigned(a) < $unsigned(b)) ? 32'h1 : 32'h0;
            #10;
            check();
        end
        $display("test sltu finish");

        /******
        * xor
        ******/
        $display("test xor");
        funct3 = 3'b100;
        funct7b5 = 0;
        for (i = 0; i < NUM_TEST; i = i + 1) begin
            a = $random;
            b = $random;
            expect_result = a ^ b;
            #10;
            check();
        end
        $display("test xor finish");

        /******
        * srl
        ******/
        $display("test srl");
        funct3 = 3'b101;
        funct7b5 = 0;
        a = 32'hFFFF_FFFF;
        for (i = 0; i < 32; i = i + 1) begin
            b = i;
            expect_result = a >> b;

            #10;
            check();
        end

        /******
        * sra
        ******/
        $display("test sra");
        funct3 = 3'b101;
        funct7b5 = 1;
        // test unsigned val
        a = 32'h7FFF_FFFF;
        for (i = 0; i < 32; i = i + 1) begin
            b = i;
            expect_result = $signed(a) >>> b;
            #10;
            check();
        end
        // test signed val
        a = 32'h8000_0000;
        for (i = 0; i < 32; i = i + 1) begin
            b = i;
            expect_result = $signed(a) >>> b;
            #10;
            check();
        end
        $display("test sra finish");

        /******
        * or
        ******/
        $display("test or");
        funct3 = 3'b110;
        funct7b5 = 0;
        for (i = 0; i < NUM_TEST; i = i + 1) begin
            a = $random;
            b = $random;
            expect_result = a | b;
            #10;
            check();
        end
        $display("test or finish");

        /******
        * and
        ******/
        $display("test and");
        funct3 = 3'b111;
        funct7b5 = 0;
        for (i = 0; i < NUM_TEST; i = i + 1) begin
            a = $random;
            b = $random;
            expect_result = a & b;
            #10;
            check();
        end
        $display("test and finish");

        $display("ALU test finish");
        if (errors == 0) begin
            $display("PASSED");
        end 
        else begin
            $display("FAILED, %d errors", errors);
        end
        $stop;
    end

endmodule
