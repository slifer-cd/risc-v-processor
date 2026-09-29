module comparator(
    input logic [31:0] rs1, rs2,
    output logic equal, lt,ltu 
);
    assign equal = (rs1==rs2);
    assign lt = ($signed(rs1) < $signed(rs2));
    assign ltu = (rs1<rs2);
endmodule
