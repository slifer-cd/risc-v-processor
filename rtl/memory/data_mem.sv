module data_mem(
    input logic clk, we,
    input logic [31:0] wd,
    input logic [11:0] a,
    input logic [1:0] func3,
    output logic [31:0] rd
);

    logic [31:0] DMEM [0:1023];
    assign rd = DMEM[a[11:2]];

    logic [3:0] write_mask;


    always_comb begin 
        write_mask = 4'b0000;
        case(func3)
            2'b10: write_mask = 4'b1111;
            2'b01: write_mask = a[1] ? 4'b1100: 4'b0011;
            2'b00: write_mask = 4'b0001 << a[1:0];
            default: write_mask = 4'b0000;
        endcase
    end

    logic [31:0] aligned_wd;

    always_comb begin 
        case(func3) 
            2'b01: aligned_wd = {2{wd[15:0]}};
            2'b00: aligned_wd = {4{wd[7:0]}};
            default: aligned_wd = wd;
        endcase
    end

    always_ff @(posedge clk) begin
        if (we) begin
            if(write_mask[0]) DMEM[a[11:2]][7:0] <= aligned_wd[7:0];
            if(write_mask[1]) DMEM[a[11:2]][15:8] <= aligned_wd[15:8];
            if(write_mask[2]) DMEM[a[11:2]][23:16] <= aligned_wd[23:16];
            if(write_mask[3]) DMEM[a[11:2]][31:24] <= aligned_wd[31:24];
        end
    end

endmodule
