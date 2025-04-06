module top (
    input  logic  clk,
    input  logic  reset
);
    /* internal signals */
    logic [31:0] inst;
    logic [31:0] read_data;
    logic [31:0] pc;
    logic [31:0] address;
    logic [31:0] write_data;
    logic [ 3:0] wmask;
    logic        wen;
    
    processor processor_inst (
        .clk        	(clk         ),
        .reset      	(reset       ),
        .inst       	(inst        ),
        .read_data  	(read_data   ),
        .pc         	(pc          ),
        .address    	(address     ),
        .write_data 	(write_data  ),
        .wmask      	(wmask       ),
        .wen        	(wen         )
    );
    
    memory memory_inst (
        .clk    	    (clk         ),
        .wen    	    (wen         ),
        .addr1  	    (pc          ),
        .addr2  	    (address     ),
        .wdata  	    (write_data  ),
        .wmask  	    (wmask       ),
        .rdata1 	    (inst        ),
        .rdata2 	    (read_data   )
    );
    
endmodule
