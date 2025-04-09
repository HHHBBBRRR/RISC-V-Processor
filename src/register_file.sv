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

    /************
    * Write Port
    *************/
    always_ff @(posedge clk) begin  // Write on posedge
        if (reset == 1'b1) begin // Synchronous reset
            for (i = 0; i < 32; i = i + 1) begin
                reg_array[i] <= 32'b0;
            end
        end 
        else if (wen == 1'b1) begin
            reg_array[waddr] <= wdata;  // Synchronous write
        end
    end

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
