module data_mem(
    input logic clk, we,
    input logic [31:0] a, wd,
    output logic [31:0] rd
);

    logic [31:0] DMEM [0:1023];
    assign rd = DMEM[a[11:2]];

    always_ff @(posedge clk) begin
        if (we)
            DMEM[a[11:2]] <= wd;
    end

endmodule