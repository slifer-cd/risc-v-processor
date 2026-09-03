module load_extender (
    input  logic [31:0] data_in,
    input  logic [1:0]  size_select,  //00=Byte, 01=Halfword, 10=Word
    input  logic        is_unsigned,
    input  logic [1:0] offset, 
    output logic [31:0] data_out 
);

    always_comb begin
        case(size_select)
            2'b00: begin
                if (offset[1:0] == 2'b00) begin
                    data_out[7:0]= data_in[7:0];
                end else if (offset[1:0] == 2'b01) begin
                    data_out[7:0]= data_in[15:8];
                end else if(offset[1:0] == 2'b10) begin
                    data_out[7:0]= data_in[23:16];
                end else begin
                    data_out[7:0] = data_in[31:24];
                end
                if(is_unsigned) begin
                    data_out[31:8] = 24'b0;
                end else begin
                    data_out[31:8] = {24{data_out[7]}};
                end
            end
            2'b01: begin
                if(offset[1] == 1'b1) begin
                    data_out[15:0] = data_in[31:16];
                end else begin 
                    data_out[15:0] = data_in[15:0];
                end
                if(is_unsigned) begin
                    data_out[31:16] = 16'b0;
                end else begin
                    data_out[31:16] = {16{data_out[15]}};
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
