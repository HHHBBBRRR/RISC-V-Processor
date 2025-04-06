// Data path module
module data_path #(
    parameter PC_START = 32'h8000_0000
)(
    input  logic          clk,
    input  logic          reset,
    /* instruction/data input */
    input  logic  [31:7]  inst,         // data path will not use inst[7:0] because it's opcode
    input  logic  [31:0]  read_data,     // raw data from memory
    /* control signals */
    input  logic  [ 2:0]  imm_control,
    input  logic  [ 2:0]  load_control,
    input  logic          alu_src_a_sel,
    input  logic          alu_src_b_sel,
    input  logic  [ 3:0]  alu_control,
    input  logic  [ 1:0]  pc_src_sel,
    input  logic  [ 1:0]  rd_src_sel,
    input  logic          gpr_wen,
    /* address/data output */
    output logic  [31:0]  pc,            // pc used for instruction fetch
    output logic  [31:0]  address,       // address used for memory read/write
    output logic  [31:0]  write_data,    // data to be written to memory
    /* branch signals */
    output logic          negative,
    output logic          zero,
    output logic          carry,
    output logic          overflow
);
    // Internal signals
    logic [31:0] pc_current;
    logic [31:0] pc_next;
    logic [31:0] pc_plus_4;
    logic [31:0] pc_branch_jal_target;
    logic [31:0] pc_jalr_target;
    logic [31:0] imm_ext;
    logic [31:0] rs1;
    logic [31:0] rs2;
    logic [31:0] rd;
    logic [31:0] alu_src_a;
    logic [31:0] alu_src_b;
    logic [31:0] alu_result;
    logic [31:0] load_ext;

    /*******
    * PC 
    ********/
    flops #(
        .WIDTH      (32),
        .SET_VALUE  (PC_START)
    ) pc_reg (
        .clk        (clk),
        .s          (reset),
        .d          (pc_next),
        .q          (pc_current)
    );

    mux3 #(
        .WIDTH      (32)
    ) pc_mux3 (
        .d0         (pc_plus_4),
        .d1         (pc_branch_jal_target),
        .d2         (pc_jalr_target),
        .s          (pc_src_sel),
        .y          (pc_next)
    );

    /* verilator lint_off PINMISSING */
    half_adder #(
        .WIDTH      (32)
    ) pc_plus_4_adder (
        .a          (pc_current),
        .b          (32'h0000_0004),
        .sum        (pc_plus_4)
    );

    half_adder #(
        .WIDTH      (32)
    ) pc_branch_jal_adder (
        .a          (pc_current),
        .b          (imm_ext),
        .sum        (pc_branch_jal_target)
    );
    /* verilator lint_on PINMISSING */

    assign pc = pc_current;

    /********************
    * Imm extension Unit
    ********************/
    imm_extend imm_extension_unit (
        .inst       (inst[31:7]),
        .control    (imm_control),
        .imm_ext    (imm_ext)
    );

    /*******
    * GPR
    ********/
    register_file GPR (
        .clk        (clk),
        .reset      (reset),
        .wen        (gpr_wen),
        .raddr1     (inst[19:15]),
        .raddr2     (inst[24:20]),
        .waddr      (inst[11:7]),
        .wdata      (rd),
        .rdata1     (rs1),
        .rdata2     (rs2)
    );

    assign write_data = rs2;

    /*********
    * ALU
    *********/ 
    mux2 #(
        .WIDTH      (32)
    ) alu_src_a_mux (
        .d0         (rs1),
        .d1         (32'b0), // lui
        .s          (alu_src_a_sel),
        .y          (alu_src_a)
    );

    mux2 #(
        .WIDTH      (32)
    ) alu_src_b_mux (
        .d0         (rs2),
        .d1         (imm_ext),
        .s          (alu_src_b_sel),
        .y          (alu_src_b)
    );

    alu ALU (
        .a          (alu_src_a),
        .b          (alu_src_b),
        .control    (alu_control),
        .result     (alu_result),
        .negative   (negative),
        .zero       (zero),
        .carry      (carry),
        .overflow   (overflow)
    );

    assign pc_jalr_target = alu_result;
    assign address = alu_result;

    /**************************
    * Load data extension unit
    **************************/
    load_extend load_extension_unit (
        .data       (read_data),
        .funct3     (load_control),
        .result     (load_ext)
    );

    /*************
    * Write back
    **************/
    mux4 #(
        .WIDTH      (32)
    ) rd_mux (
        .d0         (alu_result),
        .d1         (load_ext),
        .d2         (pc_branch_jal_target), // auipc
        .d3         (pc_plus_4),            // jal/jalr
        .s          (rd_src_sel),
        .y          (rd)
    );

endmodule
