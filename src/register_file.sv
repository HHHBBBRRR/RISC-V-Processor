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

endmodule
