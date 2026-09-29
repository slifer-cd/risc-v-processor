module ex_mem_reg (
    input logic clk, rst_n, ex_mem_write, ex_write_back, ex_result_src,
    input logic [31:0] ex_rs2, ex_alu_result,
    input logic [2:0] ex_func3,
    output logic mem_mem_write, mem_write_back, mem_result_src,
    output logic [2:0] mem_func3,
    output logic [31:0] mem_rs2, mem_alu_result
);


    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mem_mem_write <= 'b0;
            mem_write_back <= 'b0;
            mem_result_src<= 'b0;
            mem_func3 <= 3'b0;
            mem_rs2 <= 32'b0;
            mem_alu_result <= 32'b0;
        end else begin
            mem_mem_write <= ex_mem_write;
            mem_write_back <= ex_write_back;
            mem_result_src<= ex_result_src;
            mem_func3 <= ex_func3;
            mem_rs2 <= ex_rs2;
            mem_alu_result <= ex_alu_result;
        end
    end

endmodule
