// Flip-flop with synchronous reset, enable and clear
module flopenrc #(
    parameter WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  reset, // can't use 'set' as the verilator gives a warning
    input  logic                  clear,
    input  logic                  en,
    input  logic [WIDTH-1 : 0]    d,
    output logic [WIDTH-1 : 0]    q
);
   always_ff @( posedge clk ) begin
        if (reset) begin
            q <= 0;
        end 
        else if (en) begin
            if (clear) begin
                q <= 0;
            end
            else begin
                q <= d;

            end
        end
    end

endmodule
