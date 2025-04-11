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
    input  logic  [ 2:0]  M_load_control
);
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
