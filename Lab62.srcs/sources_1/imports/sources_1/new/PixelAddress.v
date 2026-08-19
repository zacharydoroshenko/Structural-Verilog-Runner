`timescale 1ns / 1ps

module PixelAddress(
    input clk,
    output [15:0] V,
    output [15:0] H
    );

    wire Hloop, Vloop;

    // Horizontal counter (H)
    assign Hloop = (H == 16'd799); // H resets when it reaches 799
    countUD16L Hcount (
        .clk_i(clk),
        .up_i(1'b1),                  
        .dw_i(1'b0),                  
        .ld_i(Hloop),                 
        .din_i(16'b0000000000000000), 
        .q_o(H)                       
    );

    // Vertical counter (V)
    assign Vloop = (V == 16'd524) & Hloop; // V resets when it reaches 524 and H has reset
    countUD16L Vcount (
        .clk_i(clk),
        .up_i(Hloop),                
        .dw_i(1'b0),                 
        .ld_i(Vloop),                
        .din_i(16'b0000000000000000), 
        .q_o(V)                      
    );

endmodule
