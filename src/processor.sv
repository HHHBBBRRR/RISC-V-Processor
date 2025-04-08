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
    /* internal signals */
    logic  [ 2:0]  imm_control;
    logic  [ 2:0]  load_control;
    logic          alu_src_a_sel;
    logic          alu_src_b_sel;
    logic  [ 3:0]  alu_control;
    logic  [ 1:0]  pc_src_sel;
    logic  [ 1:0]  rd_src_sel;
    logic          gpr_wen;
    logic          negative;
    logic          zero;
    logic          carry;
    logic          overflow;
    /* verilator lint_on UNOPTFLAT */

    controller controller_inst (
        .opcode        	(inst[6:0]      ),
        .funct3        	(inst[14:12]    ),
        .funct7b5      	(inst[30]       ),
        .negative      	(negative       ),
        .zero          	(zero           ),
        .carry         	(carry          ),
        .overflow      	(overflow       ),
        .pc_src_sel    	(pc_src_sel     ),
        .imm_control   	(imm_control    ),
        .alu_src_a_sel 	(alu_src_a_sel  ),
        .alu_src_b_sel 	(alu_src_b_sel  ),
        .alu_control   	(alu_control    ),
        .load_control  	(load_control   ),
        .mem_wen       	(wen            ),
        .mem_wmask     	(wmask          ),
        .rd_src_sel    	(rd_src_sel     ),
        .gpr_wen       	(gpr_wen        )
    );
    
    data_path #(
        .PC_START 	( 32'h8000_0000  )
    ) data_path_inst (
        .clk           	(clk            ),
        .reset         	(reset          ),
        .inst          	(inst[31:7]     ),
        .read_data     	(read_data      ),
        .imm_control   	(imm_control    ),
        .load_control  	(load_control   ),
        .alu_src_a_sel 	(alu_src_a_sel  ),
        .alu_src_b_sel 	(alu_src_b_sel  ),
        .alu_control   	(alu_control    ),
        .pc_src_sel    	(pc_src_sel     ),
        .rd_src_sel    	(rd_src_sel     ),
        .gpr_wen       	(gpr_wen        ),
        .pc            	(pc             ),
        .address       	(address        ),
        .write_data    	(write_data     ),
        .negative      	(negative       ),
        .zero          	(zero           ),
        .carry         	(carry          ),
        .overflow      	(overflow       )
    );
    
endmodule
