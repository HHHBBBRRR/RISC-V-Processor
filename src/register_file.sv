// Register File (x0 - x31)
module register_file(
    input  logic         clk,
    input  logic         wen,
    input  logic  [4:0]  ra1,
    input  logic  [4:0]  ra2,
    input  logic  [4:0]   wa,
    input  logic [31:0]   wd,
    output logic [31:0]  rd1,
    output logic [31:0]  rd2
);
    logic [31:0] rf[31:0];

    /************
    * Write Port
    *************/
    always_ff @(posedge clk) begin  // Write on posedge
        if (wen) begin              // Synchronous write
            rf[wa] <= wd;
        end
    end

    /*************
    * Read Ports
    *************/
    assign rd1 = (ra1 == 5'b0) ? 32'b0 : rf[ra1];   // Register x0 is hardwired with all bits equal to 0
    assign rd2 = (ra2 == 5'b0) ? 32'b0 : rf[ra2];   // Asynchronous read

endmodule