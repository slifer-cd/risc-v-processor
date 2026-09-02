module load_extender (
    input  logic [31:0] data_in,
    input  logic [1:0]  size_select,  //00=Byte, 01=Halfword, 10=Word
    input  logic        is_unsigned, 
    output logic [31:0] data_out 
);

    always_comb begin
        case(size_select)
            2'b00: begin
                if(is_unsigned) begin
                    data_out = {24'b0, data_in[7:0]};
                end else begin
                    data_out = {24{data_in[7]}, data_in[7:0]};
                end
            end
            2'b01: begin
                if(is_unsigned) begin
                    data_out = {16'b0, data_in[15:0]};
                end else begin
                    data_out = {16{data_in[15]}, data_in[15:0]};
                end
            end
            2'b10: begin
                data_out=data_in;
            end
            default: begin
                data_out = 32'b0;
            end
        endcase
    end

endmodule
