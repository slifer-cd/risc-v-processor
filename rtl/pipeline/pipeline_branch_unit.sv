module pipeline_branch_unit(
    input logic clk, rst_n,
    input logic [31:0] pc, id_target_address,
    input logic [6:0] opcode,
    input logic update_status, update_target_address,
    output logic [31:0] if_target_address,
    output logic pc_src
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
            and with all zeros if taken in the ID stage the using the comparator we change the status of it 
            and set the address
        - if the branch is presented we copy the register to the first one and set its valid bit to 0
            and in the ID stage only update the status only
*/ 

// 67 bit [66:35][34:33][32][31:0] pc, status, valid, target

logic [66:0] regs [8];


always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(int i=0;i<8;i++)
            regs[i] <= 67'b0;
    end else begin
    end
end


endmodule
