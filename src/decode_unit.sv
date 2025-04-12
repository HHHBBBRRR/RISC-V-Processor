/*
* Pipelined Datapath:
* Decode Unit
* Read the source register and immediate data
*/
module decode_unit (
    /* external signals */
    input  logic          clk,
    input  logic          reset,
    /* data path internal signals */
    input  logic  [31:7]  D_inst,
    input  logic  [ 4:0]  W_rd_addr,   // rd address from Write back stage
    input  logic  [31:0]  W_rd,        // rd data from Write back stage
    output logic  [31:0]  D_rs1,
    output logic  [31:0]  D_rs2,
    output logic  [ 4:0]  D_rd_addr,
    output logic  [31:0]  D_imm_ext,
    /* control signals */
    input  logic  [ 2:0]  D_imm_control,
    input  logic          W_gpr_wen,
    /* hazard signals */
    output logic  [ 4:0]  D_rs1_addr,
    output logic  [ 4:0]  D_rs2_addr
);
    /*******
    * GPR
    ********/
    register_file GPR (
        .clk        (clk),
        .reset      (reset),
        .wen        (W_gpr_wen),
        .raddr1     (D_inst[19:15]),
        .raddr2     (D_inst[24:20]),
        .waddr      (W_rd_addr),
        .wdata      (W_rd),
        .rdata1     (D_rs1),
        .rdata2     (D_rs2)
    );

    /********************
    * Imm extension Unit
    ********************/
    imm_extend imm_extension_unit (
        .inst       (D_inst[31:7]),
        .control    (D_imm_control),
        .imm_ext    (D_imm_ext)
    );

    assign D_rd_addr = D_inst[11:7];
    assign D_rs1_addr = D_inst[19:15];
    assign D_rs2_addr = D_inst[24:20];
    
endmodule
