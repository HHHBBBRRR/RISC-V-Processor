// Two ports RAM
// port1 is read-only, port2 is read-write.

import "DPI-C" function int pmem_read(input int raddr);
import "DPI-C" function void pmem_write(input int waddr, input int wdata, input byte wmask);

module memory (
    input  logic           clk,
    input  logic           wen,
    input  logic [31:0]  addr1,
    input  logic [31:0]  addr2,
    input  logic [31:0]  wdata,
    input  logic [ 3:0]  wmask,
    output logic [31:0] rdata1,
    output logic [31:0] rdata2
);
    /*************
    * Read Ports
    *************/
    // little endian!!!
    always_comb begin
        rdata1 = pmem_read(addr1); // Combinational read
        rdata2 = pmem_read(addr2); // Read 4 bytes
    end

    /************
    * Write Port
    *************/
    always_ff @(posedge clk) begin
        if (wen) begin // Synchronous write
            /* verilator lint_off WIDTHEXPAND */
            pmem_write(addr2, wdata, wmask);
            /* verilator lint_on WIDTHEXPAND */
        end
    end

endmodule
