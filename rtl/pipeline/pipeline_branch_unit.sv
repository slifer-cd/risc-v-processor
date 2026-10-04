module pipeline_branch_unit(
    input logic clk, rst_n, correct_prediction,
    input logic [31:0] pc, id_target_address,
    input logic [6:0] opcode,
    input logic update_status, update_target_address,
    output logic [31:0] if_target_address,
    output logic predict_pc, first_reg_status // 1 taken 0 nottaken
);
/* how does it work

    00 strong not taken
    01 weak not taken
    10 weak taken
    11 strong taken

    it will be 8 consucitive big resigters as SIPO every register will have
        - 32 bit pc, 2bits of status, valid bit, 32 bit address if its taken
        - the valid bit will be the write enable of the next register, the first register enable will be always 1
        - the 2 bits of status and 32bits of the second address can be updated alone on the negative edge from the ID stage
        - if the branch input is new we just put it in the first register with default status of 01
            and with all zeros if taken in the ID stage the ucorrect_predictionsing the comparator we change the status of it 
            and set the address
        - if the branch is presented we copy the register to the first one and set its valid bit to 0
            and in the ID stage only update the status only
*/ 

    // 67 bit [66:35][34:33][32][31:0] pc, status, valid, target
    logic [66:0] regs [7];
    logic [66:0] first_reg;
    logic [2:0] index_out;
    logic valid_out;

    logic [7:0] valid_bits;
    assign first_reg_status = first_reg[34];
    

    
    always_comb begin
        valid_bits[0] = (pc == first_reg[66:35]) & first_reg[32];
        for(int i=0;i<7;i++) begin
            valid_bits[i+1] = (pc == regs[i][66:35]) & regs[i][32];
        end
    end

    least_priority_encoder  least_priority_encoder_ins (
                .in(valid_bits),
                .out(index_out),
                .valid(valid_out)
            );


    always_comb begin
        if (index_out > 0) begin
            if_target_address = regs[index_out - 1][31:0];
            predict_pc = valid_out & regs[index_out - 1][32] & regs[index_out - 1][34];
        end else begin
            if_target_address = first_reg[31:0];
            predict_pc = valid_out & first_reg[32] & first_reg[34];
        end 
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(int i=0;i<7;i++)
                regs[i] <= 67'b0;
        end else begin
            if (opcode == 7'b1100011) begin
                for (int i = 6; i > 0;i--) begin
                    if(regs[i-1][32])
                        regs[i] <= regs[i-1];
                end
                if (first_reg[32])
                    regs[0] <= first_reg;
            end
        end
    end

    always_ff @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            first_reg <=67'b0;
        end else begin
            if (opcode == 7'b1100011) begin
                if (valid_out) begin
                    if(index_out > 0)
                        first_reg <= regs[index_out - 1];
                    else 
                        first_reg <= first_reg;
                end else begin
                    first_reg <= {pc,2'b01, 1'b0, 32'b0};
                end
            end
            if(update_target_address) begin
                first_reg[31:0] <= id_target_address;
            end

            if(update_status) begin
                if (correct_prediction) begin
                    first_reg[33] <= first_reg[34];
                end else begin
                    first_reg[33] <= ~first_reg[33];
                    if (first_reg[33] ^ first_reg [34]) begin
                        first_reg[34] <= ~first_reg[34];
                    end
                end
            end
        end
    end

endmodule
