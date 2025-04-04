// Two ports RAM
// port1 is read-only, port2 is read-write.
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
    logic [7:0] RAM[1024:0]; // 1KB

    /*************
    * Read Ports
    *************/
    // little endian!!!
    assign rdata1 = { RAM[addr1+3], // Combinational read
                      RAM[addr1+2],
                      RAM[addr1+1],
                      RAM[addr1]  }; // Read 4 bytes
    assign rdata2 = { RAM[addr2+3],
                      RAM[addr2+2],
                      RAM[addr2+1],
                      RAM[addr2]  };
    /************
    * Write Port
    *************/
    always_ff @(posedge clk) begin
        if (wen) begin // Synchronous write
        /* verilator lint_off CASEINCOMPLETE */
            case (wmask)
                4'b0001: begin
                    RAM[addr2] <= wdata[7:0];
                end 
                4'b0011: begin
                    RAM[addr2] <= wdata[7:0];
                    RAM[addr2+1] <= wdata[15:8];
                end 
                4'b1111: begin
                    RAM[addr2] <= wdata[7:0];
                    RAM[addr2+1] <= wdata[15:8];
                    RAM[addr2+2] <= wdata[23:16];
                    RAM[addr2+3] <= wdata[31:24];
                end
            endcase
        /* verilator lint_on CASEINCOMPLETE */
        end
    end

endmodule
