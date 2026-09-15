module top (
    input logic clk,rst_n
);

    // wires

    logic [31:0] pc, next_pc, pc_plus_4;
    logic [31:0] instr;


    logic reg_write, mem_write, alu_src, result_src;
    logic branch, jump, zero, lt, ltu, valid_branch;
    logic [3:0] alu_ctrl;

    logic [31:0] rs1,rs2, imm;
    logic [31:0] alu_in_b, alu_result;
    logic [31:0] read_data, wd3, write_reg_data;
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
    assign pc_src = jump | (branch & valid_branch);
    
    logic [31:0] pc_jb;
    logic [31:0] pc_imm;
    assign pc_imm = pc + imm;
    assign pc_jb =(jump & alu_src) ? (alu_result & 32'hFFFFFFFE) : pc_imm;

    assign next_pc = pc_src ? pc_jb : pc_plus_4;

    control_unit u_control(
        .opcode(instr[6:0]),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .result_src(result_src),
        .branch(branch),
        .jump(jump),
        .func3(instr[14:12]),
        .instr30(instr[30]),
        .alu_ctrl(alu_ctrl[3:0]),
        .imm_select(imm_select)
    );
    
    register_file u_reg_file(
        .clk(clk),
        .rst_n(rst_n),
        .we(reg_write),
        .rs1_addr(instr[19:15]),
        .rs2_addr(instr[24:20]),
        .rd_addr(instr[11:7]),
        .rs1_data(rs1),
        .rs2_data(rs2),
        .rd_data(write_reg_data)
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
        .eq(zero),
        .lt(lt),
        .ltu(ltu)
    );

    branch_checker u_branch_checker(
        .zero(zero),
        .lt(lt),
        .ltu(ltu),
        .func3(instr[14:12]),
        .valid_branch(valid_branch)
    );



    data_mem u_data_mem(
        .clk(clk),
        .we(mem_write),
        .a(alu_result[11:0]),
        .wd(rs2),
        .func3(instr[13:12]),
        .rd(read_data)
    );
    logic [31:0] load_data;
    load_data_ext u_load_data_ext(
        .data_in(read_data),
        .size_select(instr[13:12]),
        .is_unsigned(instr[14]),
        .offset(alu_result[1:0]),
        .data_out(load_data)
        );

    assign wd3 = result_src? load_data:alu_result;

    always_comb begin
        if (jump) begin
            write_reg_data = pc_plus_4;
        end else begin 
            if (imm_select == 3'b100) begin// U type
                if(instr[5]) begin
                    write_reg_data = imm;
                end else begin 
                    write_reg_data = pc_imm;
                end
            end else begin
                write_reg_data = wd3;
            end 
        end
    end


endmodule
