module pipeline #(
    parameter string INIT_FILE = ""
)(
    input logic clk,rst_n
);

    // IF section
    // branch predection unit needed

    logic pc_write; // from hazard unit
    logic [31:0] pc, next_pc, pc_plus_4;
    assign pc_plus_4 = pc + 32'd4; 
    pipeline_pc_reg pc_register (
        .clk(clk),
        .rst_n(rst_n),
        .next_pc(next_pc),
        .enable(pc_write),
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

    // ID section

    // control unit and hazard detection unit needed

    /* Control Section */ 

    logic id_alu_src;
    logic [3:0] id_alu_ctrl;
    logic [2:0] select; // imm_gen 

    /* Control Section */ 

    logic write_back; 
    logic [4:0] rd_addr;
    logic [31:0] rd_data;
    

    /* from the control and last stage register 
    depeneds from where that data is coming from
    */
    logic id_rs1_addr = id_instr[19:15];
    logic id_rs2_addr = id_instr[24:20];
    logic [31:0] id_rs1_data, id_rs2_data;
    register_file register_file_ins(
        .clk(clk),
        .rst_n(rst_n),
        .we(write_back),
        .rs1_addr(id_instr[19:15]),
        .rs2_addr(id_instr[24:20]),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data)
    );


    logic equal, lt, ltu;
    comparator comparator_ins(
        .rs1(id_rs1_data),
        .rs2(id_rs2_data),
        .equal(equal),
        .lt(lt),
        .ltu(ltu)
    );



    logic [31:0] id_immediate;
    imm_gen imm_gen_ins(
        .instruction(id_instr[31:7]),
        .select(select),
        .immediate(id_immediate)
    );

    logic [31:0] ex_pc, ex_rs1,ex_rs2,ex_imm;
    logic [4:0] ex_rs1_addr, ex_rs2_addr, ex_rd_addr;
    logic [3:0] ex_alu_ctrl;
    logic ex_alu_src;
    id_ex_reg id_ex_register(
        .clk(clk),
        .rst_n(rst_n),
        .id_pc(id_pc),
        .id_rs1(id_rs1_data),
        .id_rs2(id_rs2_data),
        .id_imm(id_immediate),
        .id_rs1_addr(id_rs1_addr),
        .id_rs2_addr(id_rs1_addr),
        .id_rd_addr(rd_addr),
        .id_alu_ctrl(id_alu_ctrl),
        .id_alu_src(id_alu_src),
        .ex_pc(ex_pc),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_imm(ex_imm),
        .ex_rs1_addr(ex_rs1_addr),
        .ex_rs2_addr(ex_rs2_addr),
        .ex_rd_addr(ex_rd_addr),
        .ex_alu_ctrl(ex_alu_ctrl),
        .ex_alu_src(ex_alu_src)
    );


    // EX stage

    logic [31:0] ex_alu_b, ex_alu_result;
    assign ex_alu_b = ex_alu_src ? ex_imm: ex_rs2;
    pipeline_alu pipeline_alu_ins(
        .a(ex_rs1),
        .b(ex_alu_b),
        .alu_ctrl(ex_alu_ctrl),
        .result(ex_alu_result)
    );

    // Forwarding unit needed

endmodule
