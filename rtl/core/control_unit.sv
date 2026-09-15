module control_unit (
    input logic [6:0] opcode,
    input logic [2:0] func3,
    input logic instr30, // bit 30

    output logic branch, jump, mem_write,alu_src, reg_write, result_src,
    output logic [3:0] alu_ctrl,
    output logic [2:0] imm_select
);
    always_comb begin

        branch = 0;
        jump = 0;
        mem_write = 0;
        alu_src = 0;
        reg_write = 0;
        result_src = 0;
        alu_ctrl = 4'b0000;
        imm_select = 3'b000;
        casez(opcode)

            7'b0110011: begin //R
                reg_write = 1;
                alu_ctrl = {instr30, func3};
            end
            7'b0010011: begin //I
                reg_write = 1;
                alu_src = 1;
                if (func3 == 3'b101) begin
                    alu_ctrl = {instr30, func3};
                end else begin
                    alu_ctrl = {1'b0, func3};
                end
            end
            7'b0000011: begin // load
                reg_write = 1;
                alu_src = 1;
                result_src = 1;
            end

            7'b0100011: begin //store
                alu_src = 1;
                mem_write = 1;
                imm_select = 3'b001;
            end

            7'b1100011 :begin // B
                branch = 1;
                alu_ctrl = 4'b1000;
                imm_select = 3'b010;
            end
            7'b1101111 : begin //J
                jump = 1;
                reg_write = 1;
                imm_select = 3'b011;
            end
            7'b0?10111: begin
                imm_select = 3'b100;
                reg_write = 1;
            end
            default:;
        endcase


    end
endmodule
