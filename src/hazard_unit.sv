module hazard_unit (
    /* Data hazard: forwarding */
    input  logic  [ 4:0]  E_rs1_addr,
    input  logic  [ 4:0]  E_rs2_addr,
    input  logic  [ 4:0]  M_rd_addr,
    input  logic  [ 4:0]  W_rd_addr,
    input  logic          W_gpr_wen,
    output logic  [ 1:0]  E_forward_src_a_sel,
    output logic  [ 1:0]  E_forward_src_b_sel
);
    /**************
    * Forwarding
    **************/
    always_comb begin
        if (E_rs1_addr == M_rd_addr && W_gpr_wen == 1'b1 && E_rs1_addr != 5'b0) begin      // forwarding from Memory stage
            E_forward_src_a_sel = 2'b01;
        end
        else if (E_rs1_addr == W_rd_addr && W_gpr_wen == 1'b1 && E_rs1_addr != 5'b0) begin // forwarding from Writeback stage
            E_forward_src_a_sel = 2'b10;
        end
        else begin  // no forwarding
            E_forward_src_a_sel = 2'b00;
        end
    end

    always_comb begin
        if (E_rs2_addr == M_rd_addr && W_gpr_wen == 1'b1 && E_rs2_addr != 5'b0) begin      // forwarding from Memory stage
            E_forward_src_b_sel = 2'b01;
        end
        else if (E_rs2_addr == W_rd_addr && W_gpr_wen == 1'b1 && E_rs2_addr != 5'b0) begin // forwarding from Writeback stage
            E_forward_src_b_sel = 2'b10;
        end
        else begin  // no forwarding
            E_forward_src_b_sel = 2'b00;
        end
    end
    
endmodule
