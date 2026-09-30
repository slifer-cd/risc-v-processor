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

    pipeline_hazard_detection_unit pipeline_hazard_detection_unit_ins(
        .id_rs1_addr(id_rs1_addr),
        .id_rs2_addr(id_rs2_addr),
        .ex_rd_addr(ex_rd_addr),
        .ex_result_src(ex_result_src),
        .pc_write(pc_write),
        .if_id_write(if_id_write),
        .id_ex_flush(id_ex_flush)
    );
    /* Control Section */ 

    logic id_alu_src, id_mem_write, id_write_back, id_result_src, id_jump, id_branch;
    logic [3:0] id_alu_ctrl;
    logic [2:0] id_imm_select; // imm_gen 

    pipeline_control_unit pipeline_control_unit_ins(
        .id_opcode(id_instr[6:0]),
        .id_func3(id_instr[14:12]),
        .id_instr30(id_instr[30]),
        .id_branch(id_branch),
        .id_jump(id_jump),
        .id_alu_src(id_alu_src),
        .id_alu_ctrl(id_alu_ctrl),
        .id_write_back(id_write_back),
        .id_result_src(id_result_src),
        .id_mem_write(id_mem_write),
        .id_imm_select(id_imm_select)
    );
    /* Control Section */ 

    logic [4:0] wb_rd_addr;
    logic [31:0] rd_data; // write back data
    

    /* from the control and last stage register 
    depeneds from where that data is coming from
    */
    logic [4:0] id_rs1_addr, id_rs2_addr, id_rd_addr;
    assign id_rs1_addr = id_instr[19:15];
    assign id_rs2_addr = id_instr[24:20];
    assign id_rd_addr = id_instr[11:7];
    logic [2:0]id_func3;
    assign id_func3 = id_instr[14:12];
    logic [31:0] id_rs1_data, id_rs2_data;
    register_file register_file_ins(
        .clk(clk),
        .rst_n(rst_n),
        .we(wb_write_back),
        .rs1_addr(id_rs1_addr),
        .rs2_addr(id_rs2_addr),
        .rd_addr(wb_rd_addr),
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
        .select(id_imm_select),
        .immediate(id_immediate)
    );

    logic [31:0] ex_pc, ex_rs1,ex_rs2,ex_imm;
    logic [4:0] ex_rs1_addr, ex_rs2_addr, ex_rd_addr;
    logic [3:0] ex_alu_ctrl;
    logic ex_alu_src, ex_mem_write, ex_write_back, ex_result_src, id_instr_5, ex_instr_5, ex_jump, id_ex_flush;
    logic [2:0] ex_func3, ex_imm_select;
    assign id_instr_5 = id_instr[5];
    id_ex_reg id_ex_register(
        .clk(clk),
        .rst_n(rst_n),
        .id_pc(id_pc),
        .id_rs1(id_rs1_data),
        .id_rs2(id_rs2_data),
        .id_imm(id_immediate),
        .id_rs1_addr(id_rs1_addr),
        .id_rs2_addr(id_rs2_addr),
        .id_rd_addr(id_rd_addr),
        .id_alu_ctrl(id_alu_ctrl),
        .id_alu_src(id_alu_src),
        .id_mem_write(id_mem_write),
        .id_write_back(id_write_back),
        .id_result_src(id_result_src),
        .id_func3(id_func3),
        .id_imm_select(id_imm_select),
        .id_instr_5(id_instr_5),
        .id_jump(id_jump),
        .id_ex_flush(id_ex_flush),
        .ex_pc(ex_pc),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_imm(ex_imm),
        .ex_rs1_addr(ex_rs1_addr),
        .ex_rs2_addr(ex_rs2_addr),
        .ex_rd_addr(ex_rd_addr),
        .ex_alu_ctrl(ex_alu_ctrl),
        .ex_alu_src(ex_alu_src),
        .ex_mem_write(ex_mem_write),
        .ex_write_back(ex_write_back),
        .ex_result_src(ex_result_src),
        .ex_func3(ex_func3),
        .ex_imm_select(ex_imm_select),
        .ex_instr_5(ex_instr_5),
        .ex_jump(ex_jump)
    );


    // EX stage

    // Forwarding unit
    logic [31:0] ex_rs1_forwarded, ex_rs2_forwarded;
    logic [1:0] rs1_mux_stage, rs1_mux_data, rs2_mux_stage, rs2_mux_data;
    pipeline_forwarding_unit pipeline_forwarding_unit_ins(
        .mem_write_back(mem_write_back),
        .wb_write_back(wb_write_back),
        .mem_jump(mem_jump),
        .wb_jump(wb_jump),
        .wb_result_src(wb_result_src),
        .mem_rd_addr(mem_rd_addr),
        .wb_rd_addr(wb_rd_addr),
        .ex_rs1_addr(ex_rs1_addr),
        .ex_rs2_addr(ex_rs2_addr),
        .mem_imm_select(mem_imm_select),
        .wb_imm_select(wb_imm_select),
        .rs1_mux_stage(rs1_mux_stage),
        .rs2_mux_stage(rs2_mux_stage),
        .rs1_mux_data(rs1_mux_data),
        .rs2_mux_data(rs2_mux_data)
    ); 

    logic [31:0] rs1_back_mem_mux, rs1_back_wb_mux, rs2_back_mem_mux, rs2_back_wb_mux;
    always_comb begin
        
        case (rs1_mux_data)
            2'b10: begin
                rs1_back_mem_mux = mem_pc + 32'd4;
                rs1_back_wb_mux = wb_pc_plus_4;
            end
            2'b01 : begin
                rs1_back_mem_mux = mem_instr_5 ? mem_imm : (mem_pc + mem_imm);
                rs1_back_wb_mux = wb_instr_5 ? wb_imm : (wb_pc + wb_imm);
            end
            2'b11: begin
                rs1_back_mem_mux = mem_alu_result;
                rs1_back_wb_mux = wb_load_data;
            end
            2'b00: begin
                rs1_back_mem_mux = mem_alu_result;
                rs1_back_wb_mux = wb_alu_result;
            end
        endcase

        case (rs2_mux_data)
            2'b10: begin
                rs2_back_mem_mux = mem_pc + 32'd4;
                rs2_back_wb_mux = wb_pc_plus_4;
            end
            2'b01 : begin
                rs2_back_mem_mux = mem_instr_5 ? mem_imm : (mem_pc + mem_imm);
                rs2_back_wb_mux = wb_instr_5 ? wb_imm : (wb_pc + wb_imm);
            end
            2'b11: begin
                rs2_back_mem_mux = mem_alu_result;
                rs2_back_wb_mux = wb_load_data;
            end
            2'b00: begin
                rs2_back_mem_mux = mem_alu_result;
                rs2_back_wb_mux = wb_alu_result;
            end
        endcase

        case(rs1_mux_stage)
            2'b10: begin
                ex_rs1_forwarded = rs1_back_wb_mux;
            end

            2'b01: begin
                ex_rs1_forwarded = rs1_back_mem_mux;
            end
            default: ex_rs1_forwarded = ex_rs1;
        endcase

        case(rs2_mux_stage)
            2'b10: begin
                ex_rs2_forwarded = rs2_back_wb_mux;
            end

            2'b01: begin
                ex_rs2_forwarded = rs2_back_mem_mux;
            end
            default: ex_rs2_forwarded = ex_rs2;
        endcase
    end

    logic [31:0] ex_alu_b, ex_alu_result;
    assign ex_alu_b = ex_alu_src ? ex_imm: ex_rs2_forwarded;
    pipeline_alu pipeline_alu_ins(
        .a(ex_rs1_forwarded),
        .b(ex_alu_b),
        .alu_ctrl(ex_alu_ctrl),
        .result(ex_alu_result)
    );




    logic mem_mem_write, mem_write_back, mem_result_src, mem_instr_5, mem_jump;
    logic [31:0] mem_alu_result, mem_rs2, mem_pc, mem_imm;
    logic [2:0] mem_func3, mem_imm_select;
    logic [4:0] mem_rd_addr;
    ex_mem_reg ex_mem_register(
        .clk(clk),
        .rst_n(rst_n),
        .ex_mem_write(ex_mem_write),
        .ex_write_back(ex_write_back),
        .ex_result_src(ex_result_src),
        .ex_func3(ex_func3),
        .ex_rs2(ex_rs2_forwarded),
        .ex_alu_result(ex_alu_result),
        .ex_rd_addr(ex_rd_addr),
        .ex_pc(ex_pc),
        .ex_imm(ex_imm),
        .ex_imm_select(ex_imm_select),
        .ex_instr_5(ex_instr_5),
        .ex_jump(ex_jump),
        .mem_rd_addr(mem_rd_addr),
        .mem_mem_write(mem_mem_write),
        .mem_write_back(mem_write_back),
        .mem_result_src(mem_result_src),
        .mem_func3(mem_func3),
        .mem_rs2(mem_rs2),
        .mem_alu_result(mem_alu_result),
        .mem_pc(mem_pc),
        .mem_imm(mem_imm),
        .mem_imm_select(mem_imm_select),
        .mem_instr_5(mem_instr_5),
        .mem_jump(mem_jump)
    );

    // Mem stage
    logic [31:0] mem_mem_data, mem_load_data;
    data_mem data_mem_ins(
        .clk(clk),
        .we(mem_mem_write),
        .a(mem_alu_result[11:0]),
        .wd(mem_rs2),
        .func3(mem_func3[1:0]),
        .rd(mem_mem_data)
    );

    load_data_ext load_data_ext_ins(
        .data_in(mem_mem_data),
        .size_select(mem_func3[1:0]),
        .is_unsigned(mem_func3[2]),
        .offset(mem_alu_result[1:0]),
        .data_out(mem_load_data)
    );

    logic wb_write_back, wb_result_src, wb_instr_5, wb_jump;
    logic [31:0] wb_alu_result, wb_load_data, wb_pc, wb_imm, wb_imm_select;
    mem_wb_reg mem_wb_register(
        .clk(clk),
        .rst_n(rst_n),
        .mem_write_back(mem_write_back),
        .mem_result_src(mem_result_src),
        .mem_alu_result(mem_alu_result),
        .mem_load_data(mem_load_data),
        .mem_rd_addr(mem_rd_addr),
        .mem_pc(mem_pc),
        .mem_imm(mem_imm),
        .mem_imm_select(mem_imm_select),
        .mem_instr_5(mem_instr_5),
        .mem_jump(mem_jump),
        .wb_write_back(wb_write_back),
        .wb_result_src(wb_result_src),
        .wb_alu_result(wb_alu_result),
        .wb_load_data(wb_load_data),
        .wb_rd_addr(wb_rd_addr),
        .wb_pc(wb_pc),
        .wb_imm(wb_imm),
        .wb_imm_select(wb_imm_select),
        .wb_instr_5(wb_instr_5),
        .wb_jump(wb_jump)
    );

    logic [31:0] wb_pc_plus_4, wb_pc_plus_imm;
    assign wb_pc_plus_4 = wb_pc + 32'd4; 
    assign wb_pc_plus_imm = wb_pc + wb_imm;

    logic [31:0] bottom_mux_1,bottom_mux_2, mid_mux;
    assign bottom_mux_1 = wb_result_src ? wb_load_data: wb_alu_result; // 1 load, 0 alu
    assign bottom_mux_2 = wb_instr_5 ? wb_imm : wb_pc_plus_imm; // 1 imm, 0 pc + imm
    assign mid_mux = wb_imm_select == 3'b100 ? bottom_mux_2 : bottom_mux_1; // 1 U type, 0 for nun U type
    assign rd_data = wb_jump ? wb_pc_plus_4 : mid_mux;// 1 jump 0 from other
endmodule
