module control_unit (
    input logic [6:0] opcode,

    output logic branch, jump, mem_write,alu_src, reg_wirte, result_src,
    output logic [1:0] alu_op
);
    always_comb begin

        branch = 0;
        jump = 0;
        mem_write = 0;
        alu_src = 0;
        reg_wirte = 0;
        result_src = 0;

        case(opcode)

            7'b0110011: begin
                reg_wirte = 1;
                alu_op = 2'b10;
            end
            7'b0010011: begin
                reg_wirte = 1;
                alu_op = 2'b10;
                alu_src = 1;
            end
            7'b0000011: begin
                reg_wirte = 1;
                alu_src = 1;
                result_src = 1;
            end

            7'b0100011: begin
                alu_src = 1;
                mem_write = 1;
            end

            7'b1100011 :begin
                branch = 1;
                alu_op = 2'b01;
            end
            7'b1101111 : begin 
                jump = 1;
                reg_wirte = 1;
            end
            default : ;
        endcase


    end
endmodule