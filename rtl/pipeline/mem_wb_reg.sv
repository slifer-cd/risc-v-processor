module mem_wb_reg(
    input logic clk, rst_n, mem_write_back, mem_result_src,mem_instr_5, mem_jump,
    input logic [31:0] mem_alu_result, mem_load_data, mem_pc, mem_imm,
    input logic [4:0] mem_rd_addr,
    input logic [2:0] mem_imm_select,
    output logic wb_write_back, wb_result_src,wb_instr_5, wb_jump,
    output logic [31:0] wb_alu_result, wb_load_data, wb_pc, wb_imm,
    output logic [4:0] wb_rd_addr,
    output logic [2:0] wb_imm_select
);

    always_ff @( posedge clk or negedge rst_n ) begin 
        if(!rst_n) begin
            wb_write_back <= 'b0;
            wb_result_src <= 'b0;
            wb_alu_result <= 32'b0;
            wb_load_data <= 32'b0;
            wb_rd_addr <= 5'b0;
            wb_pc <= 32'b0;
            wb_imm <= 32'b0;
            wb_imm_select<= 3'b0;
            wb_instr_5 <= 'b0;
            wb_jump <= 'b0;
        end else begin
            wb_write_back <= mem_write_back;
            wb_result_src <= mem_result_src;
            wb_alu_result <= mem_alu_result;
            wb_load_data <= mem_load_data;
            wb_rd_addr <= mem_rd_addr;
            wb_pc <= mem_pc;
            wb_imm <= mem_imm;
            wb_imm_select<= mem_imm_select;
            wb_instr_5 <= mem_instr_5;
            wb_jump <= mem_jump;
        end
    end


endmodule
