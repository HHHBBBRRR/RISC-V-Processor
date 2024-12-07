`timescale 1ns / 100ps

module register_file_tb();
    logic         clk;
    logic         wen;
    logic  [4:0]  ra1;
    logic  [4:0]  ra2;
    logic  [4:0]   wa;
    logic [31:0]   wd;
    logic [31:0]  rd1;
    logic [31:0]  rd2;
    integer         i;  

    register_file DUT(
        .clk(clk),
        .wen(wen),
        .ra1(ra1),
        .ra2(ra2),
        .wa(wa),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Starting register file testbench");
        wen = 1;

        for (i = 0; i < 32; i = i + 1) begin
            wa = i;
            wd = i;
            ra1 = i;
            ra2 = i;
            #10;
        end

        $display("Register file testbench finished");
        $stop;  
    end

endmodule