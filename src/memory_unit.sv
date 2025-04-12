/*
* Pipelined Datapath:
* Memory Unit
* read/write data to memory
*/
module memory_unit (
    /* external signals */
    input  logic  [31:0]  read_data,     // raw data from memory
    output logic  [31:0]  address,       // address used for memory read/write
    output logic  [31:0]  write_data,    // data to be written to memory
    /* data path internal signals */
    input  logic  [31:0]  M_alu_result,
    input  logic  [31:0]  M_write_data,
    output logic  [31:0]  M_load_ext,      // data after load extension
    /* control signals */
    input  logic  [ 2:0]  M_load_control,
    /* hazard signals */
    input  logic  [31:0]  M_pc_auipc_target,
    input  logic  [31:0]  M_pc_plus_4,
    input  logic  [ 1:0]  M_rd_src_sel,
    output logic  [31:0]  M_forward_result
);
    always_comb begin
        case (M_rd_src_sel)
            2'b00: M_forward_result = M_alu_result;
            2'b10: M_forward_result = M_pc_auipc_target;
            2'b11: M_forward_result = M_pc_plus_4;
            default: M_forward_result = 32'b0;
        endcase
    end

    /**************************
    * Load data extension unit
    **************************/
    load_extend load_extension_unit (
        .data       (read_data),
        .funct3     (M_load_control),
        .result     (M_load_ext)
    );

    assign address = M_alu_result;
    assign write_data = M_write_data;

endmodule
