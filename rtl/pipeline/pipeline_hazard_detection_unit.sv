module pipeline_hazard_detection_unit (
    input logic [4:0] id_rs1_addr, id_rs2_addr, ex_rd_addr,
    input logic ex_result_src,
    output logic if_id_write, id_ex_flush, pc_write
);

    always_comb begin
        if_id_write = 'b1;
        pc_write = 'b1;
        id_ex_flush = 'b0;
        if(ex_rd_addr != 5'b0 && ex_result_src == 'b1 && (id_rs1_addr == ex_rd_addr ||  id_rs2_addr == ex_rd_addr)) begin
            if_id_write = 'b0;
            pc_write = 'b0;
            id_ex_flush = 'b1;
        end
    end

endmodule
