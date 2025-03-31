// Half Adder
module half_adder #(
    parameter WIDTH = 32
)
(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] sum,
    output logic cout
);
    assign { cout, sum } = a + b;

endmodule
