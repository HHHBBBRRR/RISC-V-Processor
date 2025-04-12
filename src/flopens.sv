// Flip-flop with synchronous set and enable
module flopens #(
    parameter WIDTH = 32,
    parameter SET_VALUE = 0
) 
(
    input  logic                  clk,
    input  logic                    s, // can't use 'set' as the verilator gives a warning
    input  logic                   en,
    input  logic [WIDTH-1 : 0]      d,
    output logic [WIDTH-1 : 0]      q
);
    always_ff @( posedge clk ) begin
        if (s) begin    // synchronous set
            q <= SET_VALUE;
        end
        else if (en) begin // enable condition
            q <= d;
        end
    end
    
endmodule
