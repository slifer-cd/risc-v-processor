module immediate_extender(
    input logic [31:0] instruction,
    input logic [2:0] select,
    output logic [31:0]immediate);

    /*
        000 for I immediate sign-extended
        001 for S immediate sign-extended
        010 for B immediate sign-extended
        011 for J immediate sign-extended
        100 for U immediate extended
    */ 



    always_comb begin 
        case(select)
        3'b000: begin
            immediate= {{21{instruction[31]}}, instruction[30:20]};
        end
        3'b001: begin
            immediate= {{21{instruction[31]}}, instruction[30:25], instruction[11:8],instruction[7]};
        end
        3'b010: begin
            immediate= {{20{instruction[31]}},instruction[7], instruction[30:25], instruction[11:8],1'b0};
        end
        3'b011:begin
            immediate= {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21],1'b0};
        end
        3'b100:begin 
            immediate = {instruction[31:12], 12'b0};
        end
        default: begin
                immediate = 32'b0; 
        end
        endcase
    end

endmodule
