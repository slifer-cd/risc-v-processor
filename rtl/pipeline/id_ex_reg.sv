module id_ex_reg (
    input logic clk,rst_n, id_ex_flush, id_alu_src, id_mem_write, id_write_back, id_result_src, id_instr_5, id_jump,
    input logic [31:0] id_pc, id_rs1,id_rs2,id_imm,
    input logic [4:0] id_rs1_addr, id_rs2_addr, id_rd_addr,
    input logic [3:0] id_alu_ctrl,
    input logic [2:0] id_func3, id_imm_select,
    output logic [31:0] ex_pc, ex_rs1,ex_rs2,ex_imm,
    output logic [4:0] ex_rs1_addr, ex_rs2_addr, ex_rd_addr,
    output logic ex_alu_src ,ex_mem_write, ex_write_back, ex_result_src, ex_instr_5, ex_jump,
    output logic [3:0] ex_alu_ctrl,
    output logic [2:0] ex_func3, ex_imm_select

);

    always_ff @( posedge clk or negedge rst_n ) begin
        if(!rst_n || id_ex_flush) begin
            ex_pc <= 32'b0;
            ex_rs1 <= 32'b0;
            ex_rs2 <= 32'b0;
            ex_imm <= 32'b0;
            ex_rs1_addr <= 5'b0;
            ex_rs2_addr <= 5'b0;
            ex_rd_addr <= 5'b0;
            ex_alu_ctrl <= 4'b0;
            ex_alu_src <= 'b0;
            ex_mem_write <= 'b0;
            ex_write_back <= 'b0;
            ex_result_src <= 'b0;
            ex_func3 <= 3'b0;
            ex_imm_select <= 3'b0;
            ex_instr_5<= 'b0;
            ex_jump <= 'b0;


        end else begin 
            ex_pc <= id_pc;
            ex_rs1_addr <= id_rs1_addr;
            ex_rs1 <= id_rs1;
            ex_rs2_addr <= id_rs2_addr;
            ex_rs2 <= id_rs2;
            ex_imm <= id_imm;
            ex_rd_addr <= id_rd_addr;
            ex_alu_ctrl <= id_alu_ctrl;
            ex_alu_src <= id_alu_src;
            ex_mem_write <= id_mem_write;
            ex_write_back <= id_write_back;
            ex_result_src <= id_result_src;
            ex_func3 <= id_func3;
            ex_imm_select <= id_imm_select;
            ex_instr_5 <= id_instr_5;
            ex_jump <= id_jump;
        end
    end

endmodule
