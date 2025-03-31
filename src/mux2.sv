module mux2 #(
    parameter WIDTH = 32
) 
(
    input  logic [WIDTH-1 : 0] d0,
    input  logic [WIDTH-1 : 0] d1,
    input  logic                s,
    output logic [WIDTH-1 : 0]  y
);
    always_comb begin
        if (s == 1'b1) begin
            y = d1;
        end
        else begin
            y = d0;
        end
    end
    
endmodule
