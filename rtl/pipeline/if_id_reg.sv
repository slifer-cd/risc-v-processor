module if_id_reg(
    input logic clk, rst_n, if_flush, if_id_write,
    input logic [31:0] pc, instr,
    output logic [31:0] id_pc, id_pc_plus_4, id_instr
);

    logic [31:0] saved_pc, saved_instr;
    assign id_pc = saved_pc;
    assign id_pc_plus_4 = saved_pc + 32'd4;
    assign id_instr = saved_instr;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n || if_flush) begin
            saved_pc <= 32'd0;
            saved_instr <= 32'h00000013;
        end else begin
            if (if_id_write) begin
                saved_pc <= pc;
                saved_instr <= instr;
            end
        end
    end

endmodule
