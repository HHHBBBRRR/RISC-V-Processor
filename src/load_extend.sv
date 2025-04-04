// extend load data from memory to register
module load_extend(
    input  logic [31:0]     data,
    input  logic [ 2:0]   funct3,
    output logic [31:0]   result
);
    always_comb begin
        case (funct3)
            3'b000: result = { {24{data[7]}}, data[7:0] };
            3'b001: result = { {16{data[15]}}, data[15:0] };
            3'b010: result = data;
            3'b100: result = { 24'b0,data[7:0] };
            3'b101: result = { 16'b0,data[15:0] };
            default: result = 32'bx;
        endcase
    end

endmodule
