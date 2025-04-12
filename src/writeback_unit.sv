/*
* Pipelined Datapath:
* Writeback Unit
* Write the result to the register file
*/
module writeback_unit (
    /* data path internal signals */
    input  logic  [31:0]  W_alu_result,
    input  logic  [31:0]  W_load_ext,
    input  logic  [31:0]  W_pc_auipc_target,
    input  logic  [31:0]  W_pc_plus_4,
    output logic  [31:0]  W_rd,        // rd data from Write back stage
    /* control signals */
    input  logic  [ 1:0]  W_rd_src_sel,
    /* hazard signals */
    output logic  [31:0]  W_forward_result
);
    /****************
    * Write back mux
    *****************/
    mux4 #(
        .WIDTH      (32)
    ) rd_mux (
        .d0         (W_alu_result),
        .d1         (W_load_ext),
        .d2         (W_pc_auipc_target), // auipc
        .d3         (W_pc_plus_4),       // jal/jalr
        .s          (W_rd_src_sel),
        .y          (W_rd)
    );

    assign W_forward_result = W_rd;
    
endmodule
