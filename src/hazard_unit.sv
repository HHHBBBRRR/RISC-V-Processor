module hazard_unit (
    /* Data hazard: forwarding */
    input  logic  [ 4:0]  E_rs1_addr,
    input  logic  [ 4:0]  E_rs2_addr,
    input  logic  [ 4:0]  M_rd_addr,
    input  logic          M_gpr_wen,
    input  logic  [ 4:0]  W_rd_addr,
    input  logic          W_gpr_wen,
    output logic  [ 1:0]  E_forward_src_a_sel,
    output logic  [ 1:0]  E_forward_src_b_sel,
    /* Data hazard: stall */
    input  logic  [ 4:0]  D_rs1_addr,
    input  logic  [ 4:0]  D_rs2_addr,
    input  logic  [ 4:0]  E_rd_addr,
    input  logic  [ 1:0]  E_rd_src_sel,
    output logic          F_stall_pc,
    output logic          F_stall_fetch_reg,
    output logic          D_flush_decode_reg,
    /* Control hazard */
    input  logic  [ 1:0]  E_pc_src_sel,
    output logic          F_flush_fetch_reg             
);
    logic need_stall;
    logic control_hazard;

    /**************
    * Forwarding
    **************/
    always_comb begin
        if (E_rs1_addr == M_rd_addr && M_gpr_wen == 1'b1 && E_rs1_addr != 5'b0) begin      // forwarding from Memory stage
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
        if (E_rs2_addr == M_rd_addr && M_gpr_wen == 1'b1 && E_rs2_addr != 5'b0) begin      // forwarding from Memory stage
            E_forward_src_b_sel = 2'b01;
        end
        else if (E_rs2_addr == W_rd_addr && W_gpr_wen == 1'b1 && E_rs2_addr != 5'b0) begin // forwarding from Writeback stage
            E_forward_src_b_sel = 2'b10;
        end
        else begin  // no forwarding
            E_forward_src_b_sel = 2'b00;
        end
    end

    /**************
    * Stall
    **************/
    always_comb begin
        if (E_rd_src_sel == 2'b01 && (E_rd_addr == D_rs1_addr || E_rd_addr == D_rs2_addr)) begin
            need_stall = 1'b1;
        end
        else begin
            need_stall = 1'b0;
        end
    end

    assign F_stall_pc = need_stall;
    assign F_stall_fetch_reg = need_stall;

    /****************
    * Control hazard
    ****************/
    always_comb begin
        if (E_pc_src_sel == 2'b01 || E_pc_src_sel == 2'b10) begin
            control_hazard = 1'b1;
        end
        else begin
            control_hazard = 1'b0;      
        end
    end

    assign F_flush_fetch_reg = control_hazard;
    assign D_flush_decode_reg = need_stall | control_hazard;
 
endmodule
