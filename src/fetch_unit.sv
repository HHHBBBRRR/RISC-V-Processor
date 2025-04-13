/*
* Pipelined Datapath:
* Fetch Unit
* Read the instruction from memory
*/
module fetch_unit #(
    parameter PC_START = 32'h8000_0000
)(
    /* external signals */
    input  logic          clk,
    input  logic          reset,
    output logic  [31:0]  pc,
    /* data path internal signals */
    input  logic  [31:0]  E_pc_branch_jal_target,
    input  logic  [31:0]  E_pc_jalr_target,
    output logic  [31:0]  F_pc_current,
    output logic  [31:0]  F_pc_plus_4,
    /* control signals */
    input  logic  [ 1:0]  E_pc_src_sel,
    /* hazard signals */
    input  logic          F_stall_pc
);
    /* verilator lint_off UNOPTFLAT */
    logic [31:0] F_pc_next;
    /* verilator lint_on UNOPTFLAT */

    /*******
    * PC 
    ********/
    flopens #(
        .WIDTH      (32),
        .SET_VALUE  (PC_START)
    ) pc_reg (
        .clk        (clk),
        .s          (reset),
        .en         (F_stall_pc), // enable signal set to high
        .d          (F_pc_next),
        .q          (F_pc_current)
    );

    export "DPI-C" function get_pc;
    function void get_pc(output int pc_value);
        pc_value = F_pc_current;
    endfunction

    mux3 #(
        .WIDTH      (32)
    ) pc_mux3 (
        .d0         (F_pc_plus_4),
        .d1         (E_pc_branch_jal_target),
        .d2         (E_pc_jalr_target),
        .s          (E_pc_src_sel),
        .y          (F_pc_next)
    );

    /* verilator lint_off PINMISSING */
    half_adder #(
        .WIDTH      (32)
    ) pc_plus_4_adder (
        .a          (F_pc_current),
        .b          (32'h0000_0004),
        .sum        (F_pc_plus_4)
    );
    /* verilator lint_on PINMISSING */

    assign pc = F_pc_current;
    
endmodule
