module main_decoder (
    input   logic  [6:0]  opcode,
    /* controller internal signals */
    output  logic  [1:0]  alu_op,
    output  logic         is_branch,
    output  logic         is_jalr,
    output  logic         is_jal,
    /* control signals give to data path */
    output  logic  [2:0]  imm_control,
    output  logic         alu_src_a_sel,
    output  logic         alu_src_b_sel,
    output  logic  [1:0]  rd_src_sel,
    output  logic         gpr_wen,
    output  logic         mem_wen
);
    logic [13:0] internal;
    /*            3             1              1           2       1         2          1         1         1       1              */
    assign { imm_control, alu_src_a_sel, alu_src_b_sel, alu_op, mem_wen, rd_src_sel, gpr_wen, is_branch, is_jalr, is_jal } = internal;

    always_comb begin
        case (opcode)
            7'b0000011: internal = { 3'b000, 1'b0, 1'b1, 2'b00, 1'b0, 2'b01, 1'b1, 1'b0, 1'b0, 1'b0 }; // I-type: load
            7'b0010011: internal = { 3'b000, 1'b0, 1'b1, 2'b11, 1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0 }; // I-type: rs1 op imm
            7'b0010111: internal = { 3'b011, 1'bx, 1'bx, 2'bxx, 1'b0, 2'b10, 1'b1, 1'b0, 1'b0, 1'b0 }; // U-type: auipc
            7'b0100011: internal = { 3'b001, 1'b0, 1'b1, 2'b00, 1'b1, 2'bxx, 1'b0, 1'b0, 1'b0, 1'b0 }; // S-type
            7'b0110011: internal = { 3'bxxx, 1'b0, 1'b0, 2'b10, 1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0 }; // R-type
            7'b0110111: internal = { 3'b011, 1'b1, 1'b1, 2'b00, 1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0 }; // U-type: lui
            7'b1100011: internal = { 3'b010, 1'b0, 1'b0, 2'b01, 1'b0, 2'bxx, 1'b0, 1'b1, 1'b0, 1'b0 }; // B-type
            7'b1100111: internal = { 3'b000, 1'b0, 1'b1, 2'b00, 1'b0, 2'b11, 1'b1, 1'b0, 1'b1, 1'b0 }; // I-type: jalr
            7'b1101111: internal = { 3'b100, 1'bx, 1'bx, 2'bxx, 1'b0, 2'b11, 1'b1, 1'b0, 1'b0, 1'b1 }; // J-type: jal
            default: internal = 14'bx; // Error!!!
        endcase
    end

endmodule
