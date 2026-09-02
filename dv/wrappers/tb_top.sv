`timescale 1ns/1ps

module tb_top (
    input  logic clk,
    input  logic rst_n
    
    // TODO: Route out memory interfaces or PC if you need to monitor them 
    // at the top level, or let Cocotb peer directly into the hierarchy.
);

    // Instantiate your RV32I core
    /*
    rv32i_core u_core (
        .clk(clk),
        .rst_n(rst_n)
    );
    */

    // Enable waveform dumping (Required for Verilator)
    initial begin
        // Verilator supports .vcd (standard) or .fst (faster, smaller files)
        $dumpfile("sim/waves.vcd"); 
        
        // Dump all signals in tb_top and its descendants
        $dumpvars(0, tb_top);
    end

endmodule