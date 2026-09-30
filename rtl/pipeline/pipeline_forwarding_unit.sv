module pipeline_forwarding_unit(
    input logic mem_write_back, wb_write_back, mem_jump, wb_jump, wb_result_src,
    input logic [4:0] mem_rd_addr, wb_rd_addr, ex_rs1_addr, ex_rs2_addr,
    input logic [2:0] mem_imm_select, wb_imm_select,
    output logic [1:0] rs1_mux_stage, rs1_mux_data, rs2_mux_stage, rs2_mux_data
);
/*
    mux 
        no change // 00
        forward from mem // 01 
            if its R or I alu result // 00
            if its U either imm of pc + imm // 01
            if its jmp pc+4 // 10
        forward from wb // 10
            if its R or I alu result //00
            if its U either imm of pc + imm // 01
            if its jmp pc+4 // 10
            if its load wb_load_data // 11
*/ 



    always_comb begin
        rs1_mux_stage = 2'b0;
        rs2_mux_stage = 2'b0;
        rs1_mux_data = 2'b0;
        rs2_mux_data = 2'b0;
        if (ex_rs1_addr != 5'b0) begin
            if (ex_rs1_addr == mem_rd_addr && mem_write_back == 'b1) begin
                rs1_mux_stage = 2'b01;
                if (mem_jump == 'b1) begin
                    rs1_mux_data = 2'b10;
                end else if (mem_imm_select == 3'b100) begin 
                    rs1_mux_data = 2'b01;
                end else begin
                    rs1_mux_data = 2'b00;
                end
            end else if (ex_rs1_addr == wb_rd_addr && wb_write_back == 'b1) begin
                rs1_mux_stage = 2'b10;
                if (wb_jump == 'b1) begin
                    rs1_mux_data = 2'b10;
                end else if (wb_imm_select == 3'b100) begin 
                    rs1_mux_data = 2'b01;
                end else if(wb_result_src == 'b1) begin 
                    rs1_mux_data = 2'b11;
                end else begin
                    rs1_mux_data = 2'b00;
                end
            end
        end

        if (ex_rs2_addr != 5'b0) begin
            if (ex_rs2_addr == mem_rd_addr && mem_write_back == 'b1) begin
                rs2_mux_stage = 2'b01;
                if (mem_jump == 'b1) begin
                    rs2_mux_data = 2'b10;
                end else if (mem_imm_select == 3'b100) begin 
                    rs2_mux_data = 2'b01;
                end else begin
                    rs2_mux_data = 2'b00;
                end
            end else if (ex_rs2_addr == wb_rd_addr && wb_write_back == 'b1) begin
                rs2_mux_stage = 2'b10;
                if (wb_jump == 'b1) begin
                    rs2_mux_data = 2'b10;
                end else if (wb_imm_select == 3'b100) begin 
                    rs2_mux_data = 2'b01;
                end else if(wb_result_src == 'b1) begin 
                    rs2_mux_data = 2'b11;
                end else begin
                    rs2_mux_data = 2'b00;
                end
            end
        end
    end

endmodule
