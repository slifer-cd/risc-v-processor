module register_file (
    input logic clk, rst_n, we,
    input logic [4:0] rs1_addr,rs2_addr, rd_addr,
    input logic [31:0] rd_data,
    output logic [31:0] rs1_data, rs2_data
);

logic [31:0] rf [32];

assign rs1_data = (rs1_addr == 5'd0) ? 32'b0: rf[rs1_addr];
assign rs2_data = (rs2_addr == 5'd0) ? 32'b0: rf[rs2_addr];

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(int i = 0;i < 32;i++) begin
            rf[i] <= 32'b0;
        end
    end else if (we && (rd_addr != 5'd0)) begin
        rf[rd_addr] <= rd_data;
    end
end

endmodule
