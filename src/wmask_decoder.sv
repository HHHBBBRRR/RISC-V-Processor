module wmask_decoder (
    input  logic  [2:0]  funct3,
    output logic  [3:0]  wmask
);
    always_comb begin
        case (funct3)
            3'b000: wmask = 4'b0001; // sb
            3'b001: wmask = 4'b0011; // sh
            3'b010: wmask = 4'b1111; // sw
            default: wmask = 4'b0000; // Error!!!
        endcase
    end
    
endmodule
