module ex_mem_reg (
    input logic clk, rst_n, ex_mem_write, ex_write_back, ex_result_src, ex_instr_5, ex_jump,
    input logic [31:0] ex_rs2, ex_alu_result, ex_pc, ex_imm,
    input logic [2:0] ex_func3,ex_imm_select,
    input logic [4:0] ex_rd_addr,
    output logic mem_mem_write, mem_write_back, mem_result_src, mem_instr_5, mem_jump,
    output logic [2:0] mem_func3,mem_imm_select,
    output logic [31:0] mem_rs2, mem_alu_result, mem_pc, mem_imm,
    output [4:0] mem_rd_addr
);


    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mem_mem_write <= 'b0;
            mem_write_back <= 'b0;
            mem_result_src<= 'b0;
            mem_instr_5 <= 'b0;
            mem_func3 <= 3'b0;
            mem_imm_select <= 3'b0;
            mem_rs2 <= 32'b0;
            mem_alu_result <= 32'b0;
            mem_rd_addr <= 5'b0;
            mem_pc <= 32'b0;
            mem_imm <= 32'b0;
            mem_jump <= 'b0;
        end else begin
            mem_mem_write <= ex_mem_write;
            mem_write_back <= ex_write_back;
            mem_result_src<= ex_result_src;
            mem_instr_5 <= ex_instr_5;
            mem_func3 <= ex_func3;
            mem_imm_select <= ex_imm_select;
            mem_rs2 <= ex_rs2;
            mem_alu_result <= ex_alu_result;
            mem_rd_addr <= ex_rd_addr;
            mem_pc <= ex_pc;
            mem_imm <= ex_imm;
            mem_jump <= ex_jump;
        end
    end

endmodule
