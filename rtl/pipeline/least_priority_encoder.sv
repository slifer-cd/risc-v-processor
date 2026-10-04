module least_priority_encoder (
    input logic [7:0] in,
    output logic [2:0] out,
    output logic valid
);

    assign valid = |in;

    always_comb begin
        out = 3'b0;
        for (int i = 0; i < 8; i++) begin
            if(in[i]) begin
                out = i[2:0];
                break;
            end
        end
    end

endmodule
