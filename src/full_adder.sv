// Full Adder
module full_adder #(
    parameter WIDTH = 32
)(
    input  [WIDTH-1:0]    a,
    input  [WIDTH-1:0]    b,
    input               cin,
    output [WIDTH-1:0]  sum,
    output             cout
);
    /* verilator lint_off WIDTHEXPAND */
    assign {cout, sum} = a + b + cin;
    /* verilator lint_on WIDTHEXPAND */

endmodule
