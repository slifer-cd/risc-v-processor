module pipeline_pc_reg (
    input logic clk, rst_n, enable,
    input logic [31:0] next_pc,
    output logic [31:0] pc
);
    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n) 
            pc <= 32'h00000000;
        else begin 
            if (enable)
                pc <= next_pc;
        end
    end
endmodule
