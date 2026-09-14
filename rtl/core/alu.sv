module alu (
    input logic [31:0] a, b,
    input logic [3:0] alu_ctrl,
    output logic [31:0] result,
    output logic eq, lt, ltu
);

    always_comb begin 
        unique case (alu_ctrl)
            4'b0000: result = a+b; 
            4'b1000: result = a-b; 
            4'b0111: result = a&b; 
            4'b0110: result = a|b; 
            4'b0100: result = a^b;
            4'b0001: result = a << b[4:0]; 
            4'b0101: result = a >> b[4:0]; 
            4'b1101: result = $signed(a) >>> b[4:0]; 
            4'b0010: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0 ; 
            4'b0011: result = (a < b) ? 32'd1 : 32'd0 ; 
            default: result = 32'b0;
        endcase
    end

    /* 
        every op ctrl is with func3 and 
        if func7=0x20 then the forth bit of the control become 1
    */
    assign eq = (a==b);
    assign lt = ($signed(a) < $signed(b));
    assign ltu = (a<b);
endmodule
