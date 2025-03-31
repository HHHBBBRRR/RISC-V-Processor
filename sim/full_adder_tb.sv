`timescale 1ns / 100ps

module full_adder_tb();
    parameter WIDTH = 32;        // Width of the adder
    parameter SEED = 1;          // Seed for random number generator
    parameter NUM_TESTS = 10000; // Number of test vectors to generate

    logic [WIDTH-1:0] a;
    logic [WIDTH-1:0] b;
    logic cin;
    logic [WIDTH-1:0] sum;
    logic cout;

    logic [WIDTH-1:0] expect_sum;
    logic expect_cout;
    logic clk;
    integer i, errors;

    full_adder #(
        .WIDTH(WIDTH)
    )
    DUT (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    /**
     * Check the result of the adder is correct or not.
     */
    task check; begin
        if (sum !== expect_sum || cout !== expect_cout) begin
            errors = errors + 1;
            $display("ERROR: a=%h, b=%h, cin=%h, sum=%h, cout=%h, expect_sum=%h, expect_cout=%h", a, b, cin, sum, cout, expect_sum, expect_cout);
        end
    end   
    endtask //check

    initial begin
        $display("Running test...\n");
        errors = 0;
        a = $random(SEED);

        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            a = $random();
            b = $random();
            cin = {$random()} % 2;    // 0 or 1
            expect_sum = a + b + cin;
            expect_cout = ((a + b + cin) >= {1'b1, {WIDTH{1'b0}}});
            #10;
            check();
        end

        if (errors == 0) begin
            $display("PASSED");
        end else begin
            $display("FAILED, %d errors", errors);
        end

        $stop;
    end

endmodule