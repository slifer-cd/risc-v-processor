module instr_mem #(
    parameter string INIT_FILE = ""
)(
    input logic [11:2] a,
    output logic [31:0] rd
);

    logic [31:0] IMEM [0:1023];
    initial begin
        if(INIT_FILE != "") begin
            $readmemh(INIT_FILE, IMEM);
        end
    end
    assign rd = IMEM[a[11:2]];
endmodule
