// Arithmetic Logical Unit (ALU)
module alu(
    input logic  [31:0]         a,
    input logic  [31:0]         b,
    input logic   [3:0]   control,  // control = {funct7[5] | funct3[1], funct3}
    output logic [31:0]    result,
    output logic         negative,
    output logic             zero,
    output logic            carry,  // for unsigned
    output logic         overflow   // for signed
);
    logic cout;
    logic [31:0] invert_b;
    logic [31:0] add_result;
    logic [31:0] sll_result;
    logic [31:0] srl_result;
    logic [31:0] sra_result;
    logic [31:0] xor_result;
    logic [31:0] or_result;
    logic [31:0] and_result;
    logic [31:0] slt_result;
    logic [31:0] sltu_result;

    full_adder #(
        .WIDTH(32)
    ) adder(
        .a(a),
        .b(invert_b),
        .cin(control[3]),
        .sum(add_result),
        .cout(cout)
    );

    /******************
    * internal logic
    *******************/
    assign invert_b = control[3] ? ~b : b;
    assign sll_result = a << b[4:0];
    assign srl_result = a >> b[4:0];
    assign sra_result = $signed(a) >>> b[4:0];
    assign xor_result = a ^ b;
    assign or_result = a | b;
    assign and_result = a & b;
    /* verilator lint_off WIDTHEXPAND */
    assign slt_result = negative ^ overflow;
    assign sltu_result = (!carry);
    /* verilator lint_on WIDTHEXPAND */

    /*********
    * output
    **********/
    assign negative = add_result[31];
    assign zero = ~|add_result;
    assign carry = cout;
    assign overflow = ~(control[3] ^ a[31] ^ b[31]) & (a[31] ^ add_result[31]);

    always_comb begin
        case(control)
            4'b0000: result = add_result;
            4'b0001: result = sll_result;
            4'b0100: result = xor_result;
            4'b0101: result = srl_result;
            4'b1000: result = add_result; // sub
            4'b1010: result = slt_result;
            4'b1011: result = sltu_result;
            4'b1101: result = sra_result;
            4'b1110: result = or_result;
            4'b1111: result = and_result;
            default: result = 32'bx;
        endcase         
    end

endmodule
