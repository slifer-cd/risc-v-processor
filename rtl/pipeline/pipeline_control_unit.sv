module pipeline_control_unit(
    input logic [6:0] id_opcode,
    input logic [2:0] id_func3,
    input logic id_instr30, // bit 30

    output logic id_branch, id_jump, id_mem_write, id_alu_src, id_write_back, id_result_src,
    output logic [3:0] id_alu_ctrl,
    output logic [2:0] id_imm_select
);

    always_comb begin
        id_branch = 'b0;
        id_jump = 'b0;
        id_mem_write = 'b0;
        id_alu_src = 'b0;
        id_write_back = 'b0;
        id_result_src = 'b0;
        id_alu_ctrl = 4'b0;
        id_imm_select = 3'b0;

        casez(id_opcode)

            7'b0110011: begin //R
                id_write_back = 'b1;
                id_alu_ctrl = {id_instr30, id_func3};
            end
            7'b0010011: begin //I
                id_write_back = 1;
                id_alu_src = 1;
                if (id_func3 == 3'b101) begin
                    id_alu_ctrl = {id_instr30, id_func3};
                end else begin
                    id_alu_ctrl = {1'b0, id_func3};
                end
            end
            7'b0000011: begin // load
                id_write_back = 'b1;
                id_alu_src = 'b1;
                id_result_src = 'b1;
            end

            7'b0100011: begin //store
                id_alu_src = 'b1;
                id_mem_write = 'b1;
                id_imm_select = 3'b001;
            end

            7'b1100011 :begin // B
                id_branch = 'b1;
                id_alu_ctrl = 4'b1000;
                id_imm_select = 3'b010;
            end

            7'b1101111 : begin //J
                id_jump = 'b1;
                id_write_back = 'b1;
                id_imm_select = 3'b011;
            end
            7'b1100111:begin // I JALR
                id_alu_src = 'b1;
                id_jump = 'b1;
                id_write_back = 'b1;
            end
            7'b0?10111: begin
                id_imm_select = 3'b100;
                id_write_back = 'b1;
            end
            default:;
        endcase

    end

endmodule
