module mux3 #(
    parameter WIDTH = 32
) 
(
    input  logic [WIDTH-1 : 0] d0,
    input  logic [WIDTH-1 : 0] d1,
    input  logic [WIDTH-1 : 0] d2,
    input  logic       [1 : 0]  s,
    output logic [WIDTH-1 : 0]  y
);
    always_comb begin
        if (s[1] == 1'b1) begin
            y = d2;
        end 
        else if (s[0] == 1'b1) begin
            y = d1;
        end 
        else begin
            y = d0;
        end
    end
    
endmodule
