module processor (
    input  logic          clk,
    input  logic          reset,
    input  logic  [31:0]  inst,
    input  logic  [31:0]  read_data,
    output logic  [31:0]  pc,
    output logic  [31:0]  address,
    output logic  [31:0]  write_data,
    output logic  [ 3:0]  wmask,
    output logic          wen
);
    /* verilator lint_off UNOPTFLAT */
    /* verilator lint_off UNUSEDSIGNAL */
    logic  [31:0]  D_inst;
    logic  [ 2:0]  D_imm_control;
    logic          E_alu_src_a_sel;
    logic          E_alu_src_b_sel;
    logic  [ 3:0]  E_alu_control;
    logic  [ 1:0]  E_pc_src_sel;
    logic          E_negative;
    logic          E_zero;
    logic          E_carry;
    logic          E_overflow;
    logic  [ 2:0]  M_load_control;
    logic  [ 1:0]  W_rd_src_sel;
    logic          W_gpr_wen;
    /* verilator lint_on UNUSEDSIGNAL */
    /* verilator lint_on UNOPTFLAT */

    controller controller_inst(
        .clk             	(clk              ),
        .reset           	(reset            ),
        .D_opcode        	(D_inst[6:0]      ),
        .D_funct3        	(D_inst[14:12]    ),
        .D_funct7b5      	(D_inst[30]    ),
        .E_negative      	(E_negative       ),
        .E_zero          	(E_zero           ),
        .E_carry         	(E_carry          ),
        .E_overflow      	(E_overflow       ),
        .D_imm_control   	(D_imm_control    ),
        .E_alu_src_a_sel 	(E_alu_src_a_sel  ),
        .E_alu_src_b_sel 	(E_alu_src_b_sel  ),
        .E_alu_control   	(E_alu_control    ),
        .E_pc_src_sel    	(E_pc_src_sel     ),
        .M_load_control  	(M_load_control   ),
        .M_mem_wen       	(wen              ),
        .M_mem_wmask     	(wmask            ),
        .W_rd_src_sel    	(W_rd_src_sel     ),
        .W_gpr_wen       	(W_gpr_wen        )
    );
       
    data_path data_path_inst(
        .clk             	(clk              ),
        .reset           	(reset            ),
        .inst            	(inst             ),
        .read_data       	(read_data        ),
        .pc              	(pc               ),
        .address         	(address          ),
        .write_data      	(write_data       ),
        .D_imm_control   	(D_imm_control    ),
        .E_alu_src_a_sel 	(E_alu_src_a_sel  ),
        .E_alu_src_b_sel 	(E_alu_src_b_sel  ),
        .E_alu_control   	(E_alu_control    ),
        .E_pc_src_sel    	(E_pc_src_sel     ),
        .M_load_control  	(M_load_control   ),
        .W_rd_src_sel    	(W_rd_src_sel     ),
        .W_gpr_wen       	(W_gpr_wen        ),
        .D_inst          	(D_inst           ),
        .E_negative      	(E_negative       ),
        .E_zero          	(E_zero           ),
        .E_carry         	(E_carry          ),
        .E_overflow      	(E_overflow       )
    );

endmodule
