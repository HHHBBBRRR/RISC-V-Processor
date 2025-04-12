/*
* Pipelined Datapath:
* Execute Unit
* Perform the ALU operation
*/
module execute_unit (
    /* data path internal signals */
    input  logic  [31:0]  E_rs1,
    input  logic  [31:0]  E_rs2,
    input  logic  [31:0]  E_pc_current,
    input  logic  [31:0]  E_imm_ext,
    output logic  [31:0]  E_pc_branch_jal_target,
    output logic  [31:0]  E_pc_jalr_target,
    output logic  [31:0]  E_pc_auipc_target,
    output logic  [31:0]  E_alu_result,
    output logic          E_negative,
    output logic          E_zero,
    output logic          E_carry,
    output logic          E_overflow,
    output logic  [31:0]  E_write_data,    // data to be written to memory
    /* control signals */
    input  logic          E_alu_src_a_sel,
    input  logic          E_alu_src_b_sel,
    input  logic  [ 3:0]  E_alu_control,
    /* hazard signals */
    input  logic  [ 1:0]  E_forward_src_a_sel,
    input  logic  [ 1:0]  E_forward_src_b_sel,
    input  logic  [31:0]  M_forward_result,
    input  logic  [31:0]  W_forward_result
);
    /* verilator lint_off UNOPTFLAT */
    logic [31:0] E_alu_src_a;
    logic [31:0] E_alu_src_b;
    logic [31:0] E_pc_plus_imm;
    logic [31:0] E_forward_src_a;
    logic [31:0] E_forward_src_b;
    /* verilator lint_on UNOPTFLAT */

    mux3 #(
        .WIDTH      (32)
    ) forward_src_a_mux (
        .d0         (E_rs1),
        .d1         (M_forward_result), // EX hazard
        .d2         (W_forward_result), // MEM hazard
        .s          (E_forward_src_a_sel),
        .y          (E_forward_src_a)
    );

    mux3 #(
        .WIDTH      (32)
    ) forward_src_b_mux (
        .d0         (E_rs2),
        .d1         (M_forward_result), // EX hazard
        .d2         (W_forward_result), // MEM hazard
        .s          (E_forward_src_b_sel),
        .y          (E_forward_src_b)
    );

    mux2 #(
        .WIDTH      (32)
    ) alu_src_a_mux (
        .d0         (E_forward_src_a),
        .d1         (32'b0), // lui
        .s          (E_alu_src_a_sel),
        .y          (E_alu_src_a)
    );

    mux2 #(
        .WIDTH      (32)
    ) alu_src_b_mux (
        .d0         (E_forward_src_b),
        .d1         (E_imm_ext),
        .s          (E_alu_src_b_sel),
        .y          (E_alu_src_b)
    );

    assign E_write_data = E_forward_src_b;

    /*********
    * ALU
    *********/ 
    alu ALU (
        .a          (E_alu_src_a),
        .b          (E_alu_src_b),
        .control    (E_alu_control),
        .result     (E_alu_result),
        .negative   (E_negative),
        .zero       (E_zero),
        .carry      (E_carry),
        .overflow   (E_overflow)
    );

    /* verilator lint_off PINMISSING */
    half_adder #(
        .WIDTH      (32)
    ) pc_branch_jal_adder (
        .a          (E_pc_current),
        .b          (E_imm_ext),
        .sum        (E_pc_plus_imm)
    );
    /* verilator lint_on PINMISSING */

    assign E_pc_jalr_target = E_alu_result;
    assign E_pc_branch_jal_target = E_pc_plus_imm;
    assign E_pc_auipc_target = E_pc_plus_imm;
    
endmodule
