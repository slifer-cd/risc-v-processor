module instr_mem #(
    parameter INITFILE = "program.hex";
)(
    input logic [31:0] a,
    output logic [31:0] rd,
);

    logic [31:0] IMEM [0:1023];
    initial begin
        $readmemh(INITFILE, IMEM);
    end
    
    assign rd = IMEM[a[11:2]];
endmodule