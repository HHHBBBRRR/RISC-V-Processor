// Register File (x0 - x31)
module register_file(
    input  logic            clk,
    input  logic            reset,
    input  logic            wen,
    input  logic [ 4:0]     raddr1,
    input  logic [ 4:0]     raddr2,
    input  logic [ 4:0]     waddr,
    input  logic [31:0]     wdata,
    output logic [31:0]     rdata1,
    output logic [31:0]     rdata2
);
    logic [31:0] reg_array[31:0];
    integer i;
    logic is_write;

    /************
    * Write Port
    *************/
    always_ff @(negedge clk) begin  // Write on negedge
        if (reset == 1'b1) begin // Synchronous reset
            for (i = 0; i < 32; i = i + 1) begin
                reg_array[i] <= 32'b0;
            end
            is_write <= 1'b0;
        end 
        else if (wen == 1'b1) begin
            reg_array[waddr] <= wdata;  // Synchronous write
            is_write <= 1'b1;   // the 'is_write' signal is 1 only on the writeback stage
        end 
        else begin
            is_write <= 1'b0;
        end
    end

    export "DPI-C" function gpr_is_write;
    function int gpr_is_write();
        return is_write ? 1 : 0;
    endfunction

    /*************
    * Read Ports
    *************/
    assign rdata1 = (raddr1 == 5'b0) ? 32'b0 : reg_array[raddr1];   // Register x0 is hardwired with all bits equal to 0
    assign rdata2 = (raddr2 == 5'b0) ? 32'b0 : reg_array[raddr2];   // Asynchronous read

    // DPI-C 导出函数，供 C++ 仿真环境调用，读取寄存器堆数据
    export "DPI-C" function get_gpr;
    function void get_gpr(output int gpr[32]);
        integer j;
        for (j = 0; j < 32; j = j + 1) begin
            gpr[j] = reg_array[j];
        end
    endfunction

endmodule
