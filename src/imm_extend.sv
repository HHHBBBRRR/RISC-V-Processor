// Immediate Extension Unit
module imm_extend (
    input  logic [31 : 7]       inst,
    input  logic [ 2 : 0]    control, // generate by decoder
    output logic [31 : 0]    imm_ext  // signed extension
); 
    always_comb begin
        case (control)
            /* I-Type */       
            3'b000 : imm_ext = { {21{inst[31]}}, inst[30 : 20] };
            /* S-Type */                                                
            3'b001 : imm_ext = { {21{inst[31]}}, inst[30 : 25], inst[11 : 7] };
            /* B-Type */
            3'b010 : imm_ext = { {20{inst[31]}}, inst[7], inst[30 : 25], inst[11 : 8], 1'b0 };
            /* U-Type */
            3'b011 : imm_ext = { inst[31 : 12], 12'b0 };
            /* J-Type */
            3'b100 : imm_ext = { {12{inst[31]}}, inst[19 : 12], inst[20], inst[30 : 21], 1'b0 };
            /* Unknown */
            default: imm_ext = 32'bx;
        endcase
    end
 
endmodule
