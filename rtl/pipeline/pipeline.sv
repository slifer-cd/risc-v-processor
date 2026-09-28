module pipeline #(
    parameter string INIT_FILE = ""
)(
    input logic clk,rst_n
);
    logic pc_enable;
    logic [31:0] pc, next_pc, pc_plus_4;
    assign pc_plus_4 = pc + 32'd4; 
    pipeline_pc_reg pc_register (
        .clk(clk),
        .rst_n(rst_n),
        .next_pc(next_pc),
        .enable(pc_enable),
        .pc(pc)
    );

    logic [31:0] instr;

    instr_mem #(
            .INIT_FILE(INIT_FILE)
        )u_instr_mem (
            .a(pc[11:2]),
            .rd(instr)
    );

    logic [31:0] id_instr, id_pc, id_pc_plus_4;
    logic if_flush, if_id_write; // flush from branch unit, write from hazard detection unit
    if_id_reg if_id_register (
        .clk(clk),
        .rst_n(rst_n),
        .if_flush(if_flush),
        .if_id_write(if_id_write),
        .pc(pc),
        .instr(instr),
        .id_instr(id_instr),
        .id_pc(id_pc),
        .id_pc_plus_4(id_pc_plus_4)
    );

endmodule
