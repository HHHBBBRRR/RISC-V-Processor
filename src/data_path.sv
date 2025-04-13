// Pipelined data path
module data_path (
    /* external signals */
    input  logic          clk,
    input  logic          reset,
    input  logic  [31:0]  inst,         // instruction from memory
    input  logic  [31:0]  read_data,    // raw data from memory
    output logic  [31:0]  pc,           // pc used for instruction fetch
    output logic  [31:0]  address,      // address used for memory read/write
    output logic  [31:0]  write_data,   // data to be written to memory
    /* control signals */
    input  logic  [ 2:0]  D_imm_control,
    input  logic          E_alu_src_a_sel,
    input  logic          E_alu_src_b_sel,
    input  logic  [ 3:0]  E_alu_control,
    input  logic  [ 1:0]  E_pc_src_sel,
    input  logic  [ 2:0]  M_load_control,
    input  logic  [ 1:0]  W_rd_src_sel,
    input  logic          W_gpr_wen,
    /* instruction opcode signal */
    output logic  [31:0]  D_inst,
    /* branch signals */
    output logic          E_negative,
    output logic          E_zero,
    output logic          E_carry,
    output logic          E_overflow,
    /* hazard signals */
    /* data hazard: forward */
    input  logic  [ 1:0]  E_forward_src_a_sel,
    input  logic  [ 1:0]  E_forward_src_b_sel,
    input  logic  [ 1:0]  M_rd_src_sel,
    output logic  [ 4:0]  E_rs1_addr,
    output logic  [ 4:0]  E_rs2_addr,
    output logic  [ 4:0]  M_rd_addr,
    output logic  [ 4:0]  W_rd_addr,
    /* data hazard: stall */
    input  logic          F_stall_pc,
    input  logic          F_stall_fetch_reg,
    input  logic          D_flush_decode_reg,
    output logic  [ 4:0]  D_rs1_addr,
    output logic  [ 4:0]  D_rs2_addr,
    output logic  [ 4:0]  E_rd_addr
);
    /* verilator lint_off UNOPTFLAT */
    
    /* Fetch stage signals */
    logic [31:0] F_inst;
    logic [31:0] F_pc_current;
    logic [31:0] F_pc_plus_4;

    /* Decode stage signals */
    logic [31:0] D_pc_current;
    logic [31:0] D_pc_plus_4;
    logic [31:0] D_rs1;
    logic [31:0] D_rs2;
    logic [ 4:0] D_rd_addr;
    logic [31:0] D_imm_ext;

    /* Execute stage signals */
    logic [31:0] E_pc_current;
    logic [31:0] E_pc_plus_4;
    logic [31:0] E_rs1;
    logic [31:0] E_rs2;
    logic [31:0] E_imm_ext;
    logic [31:0] E_write_data;
    logic [31:0] E_alu_result;
    logic [31:0] E_pc_jalr_target;
    logic [31:0] E_pc_auipc_target;
    logic [31:0] E_pc_branch_jal_target;

    /* Memory stage signals */
    logic [31:0] M_pc_plus_4;
    logic [31:0] M_alu_result;
    logic [31:0] M_write_data;
    logic [31:0] M_pc_auipc_target;
    logic [31:0] M_load_ext;
    logic [31:0] M_forward_result;

    /* Write back stage signals */
    logic [31:0] W_alu_result;
    logic [31:0] W_load_ext;
    logic [31:0] W_pc_auipc_target;
    logic [31:0] W_pc_plus_4;
    logic [31:0] W_rd;
    logic [31:0] W_forward_result;

    /* verilator lint_on UNOPTFLAT */

    /************
    * Fetch Unit
    ************/
    fetch_unit #(
        .PC_START 	(32'h8000_0000))
    FU(
        .clk                    	(clk                   ),
        .reset                  	(reset                 ),
        .pc                     	(pc                    ),
        .E_pc_branch_jal_target 	(E_pc_branch_jal_target),
        .E_pc_jalr_target       	(E_pc_jalr_target      ),
        .F_pc_current           	(F_pc_current          ),
        .F_pc_plus_4            	(F_pc_plus_4           ),
        .E_pc_src_sel           	(E_pc_src_sel          ),
        .F_stall_pc             	(F_stall_pc           )
    );

    assign F_inst = inst;

    /* Fetch stage pipeline register */
    flopenr #(
        .WIDTH      (96)
    ) FU_pipe_reg (
        .clk        (clk),
        .reset      (reset),
        .en         (F_stall_fetch_reg),
        .d          ({F_inst, F_pc_current, F_pc_plus_4}),
        .q          ({D_inst, D_pc_current, D_pc_plus_4})
    );

    /*************
    * Decode Unit
    *************/
    decode_unit DU(
        .clk           	(clk          ),
        .reset         	(reset        ),
        .D_inst        	(D_inst[31:7] ),
        .W_rd_addr     	(W_rd_addr    ),
        .W_rd          	(W_rd         ),
        .D_rs1         	(D_rs1        ),
        .D_rs2         	(D_rs2        ),
        .D_rd_addr     	(D_rd_addr    ),
        .D_imm_ext     	(D_imm_ext    ),
        .D_imm_control 	(D_imm_control),
        .W_gpr_wen     	(W_gpr_wen    ),
        .D_rs1_addr   	(D_rs1_addr   ),
        .D_rs2_addr   	(D_rs2_addr   )
    );
    
    /* Decode stage pipeline register */ 
    floprc #(
        .WIDTH      (175)
    ) DU_pipe_reg (
        .clk        (clk),
        .reset      (reset),
        .clear      (D_flush_decode_reg),
        .d          ({D_pc_current, D_pc_plus_4, D_rs1, D_rs2, D_rd_addr, D_imm_ext, D_rs1_addr, D_rs2_addr}),
        .q          ({E_pc_current, E_pc_plus_4, E_rs1, E_rs2, E_rd_addr, E_imm_ext, E_rs1_addr, E_rs2_addr})
    );

    /*************
    * Execute Unit
    *************/    
    execute_unit EU(
        .E_rs1                  	(E_rs1                 ),
        .E_rs2                  	(E_rs2                 ),
        .E_pc_current           	(E_pc_current          ),
        .E_imm_ext              	(E_imm_ext             ),
        .E_pc_branch_jal_target 	(E_pc_branch_jal_target),
        .E_pc_jalr_target       	(E_pc_jalr_target      ),
        .E_pc_auipc_target      	(E_pc_auipc_target     ),
        .E_alu_result           	(E_alu_result          ),
        .E_negative             	(E_negative            ),
        .E_zero                 	(E_zero                ),
        .E_carry                	(E_carry               ),
        .E_overflow             	(E_overflow            ),
        .E_write_data           	(E_write_data          ),
        .E_alu_src_a_sel        	(E_alu_src_a_sel       ),
        .E_alu_src_b_sel        	(E_alu_src_b_sel       ),
        .E_alu_control          	(E_alu_control         ),
        .E_forward_src_a_sel    	(E_forward_src_a_sel   ),
        .E_forward_src_b_sel    	(E_forward_src_b_sel   ),
        .M_forward_result       	(M_forward_result      ),
        .W_forward_result       	(W_forward_result      )
    );
    
    /* Execute stage pipeline register */
    flopr #(
        .WIDTH 	(133)
    ) EU_pipe_reg(
        .clk   	(clk),
        .reset 	(reset),
        .d     	({E_pc_plus_4, E_rd_addr, E_alu_result, E_write_data, E_pc_auipc_target}),
        .q     	({M_pc_plus_4, M_rd_addr, M_alu_result, M_write_data, M_pc_auipc_target})
    );
    
    /*************
    * Memory Unit
    *************/
    memory_unit MU(
        .read_data      	(read_data     ),
        .address        	(address       ),
        .write_data     	(write_data    ),
        .M_alu_result   	(M_alu_result  ),
        .M_write_data   	(M_write_data  ),
        .M_load_ext     	(M_load_ext    ),
        .M_load_control 	(M_load_control),
        .M_pc_auipc_target	(M_pc_auipc_target),
        .M_pc_plus_4    	(M_pc_plus_4    ),
        .M_rd_src_sel   	(M_rd_src_sel   ),
        .M_forward_result 	(M_forward_result)
    );

    /* Memory stage pipeline register */ 
    flopr #(
        .WIDTH 	(133)
    ) MU_pipe_reg (
        .clk   	(clk),
        .reset 	(reset),
        .d     	({M_alu_result, M_load_ext, M_pc_auipc_target, M_pc_plus_4, M_rd_addr}),
        .q     	({W_alu_result, W_load_ext, W_pc_auipc_target, W_pc_plus_4, W_rd_addr})
    );
    
    /****************
    * Writeback Unit
    ****************/   
    writeback_unit u_writeback_unit(
        .W_alu_result      	(W_alu_result     ),
        .W_load_ext        	(W_load_ext       ),
        .W_pc_auipc_target 	(W_pc_auipc_target),
        .W_pc_plus_4       	(W_pc_plus_4      ),
        .W_rd              	(W_rd             ),
        .W_rd_src_sel      	(W_rd_src_sel     ),
        .W_forward_result  	(W_forward_result  )
    );

endmodule
