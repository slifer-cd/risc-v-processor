module top (
    input logic clk,rst_n
);

    // wires

    logic [31:0] pc, next_pc, pc_plus_4;
    logic [31:0] instr;


    logic reg_wirte, mem_write, alu_src, result_src;
    logic branch, jump, zero;
    logic [3:0] alu_ctrl;

    logic [31:0] rs1,rs2, imm;
    logic [31:0] alu_in_b, alu_result;
    logic [31:0] read_data, wd3;
    logic [2:0] imm_select;
    pc_reg u_pc_reg(
        .clk(clk),
        .rst_n(rst_n),
        .next_pc(next_pc),
        .pc(pc)
    );

    instr_mem u_instr_mem (
        .a(pc[11:2]),
        .rd(instr)
    );

    assign pc_plus_4 = pc + 32'd4;

    logic pc_src;
    assign pc_src = jump | (branch & zero);

    assign next_pc = pc_src ? (pc + imm) : pc_plus_4;

    control_unit u_control(
        .opcode(instr[6:0]),
        .reg_wirte(reg_wirte),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .result_src(result_src),
        .branch(branch),
        .jump(jump),
        .func3(instr[14:12]),
        .func7(instr[30]),
        .alu_ctrl(alu_ctrl[3:0]),
        .imm_select(imm_select)
    );

    register_file u_reg_file(
        .clk(clk),
        .rst_n(rst_n),
        .we(reg_wirte),
        .rs1_addr(instr[19:15]),
        .rs2_addr(instr[24:20]),
        .rd_addr(instr[11:7]),
        .rs1_data(rs1),
        .rs2_data(rs2),
        .rd_data(wd3)
    );

    imm_gen u_imm_gen(
        .instruction(instr[31:7]),
        .immediate(imm),
        .select(imm_select)
    );

    assign alu_in_b = alu_src ? imm: rs2;

    alu u_alu (
        .a(rs1),
        .b(alu_in_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .eq(zero)
    );

    data_mem u_data_mem(
        .clk(clk),
        .we(mem_write),
        .a(alu_result[11:2]),
        .wd(rs2),
        .rd(read_data)
    );

    assign wd3 = result_src? read_data:alu_result;

endmodule
