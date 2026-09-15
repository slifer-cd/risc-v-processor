module branch_checker(
    input logic zero, lt, ltu,
    input logic [2:0] func3,
    output logic valid_branch
);
    always_comb begin
        valid_branch = 0;
        case (func3)
            3'b000: valid_branch = zero;
            3'b001: valid_branch = ~zero;
            3'b100: valid_branch = lt;
            3'b101: valid_branch = ~lt;
            3'b110: valid_branch = ltu;
            3'b111: valid_branch = ~ltu;
            default:valid_branch = 0;
        endcase
    end

endmodule
