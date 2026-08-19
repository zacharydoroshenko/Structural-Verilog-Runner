`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2025 07:38:22 PM
// Design Name: 
// Module Name: Syncs
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Syncs(
    input [15:0] V,
    input [15:0] H,
    output Vsync,
    output Hsync
    );

    assign Hsync = ~((H >= 655) & (H <= 750));
    assign Vsync = ~((V >= 489) & (V <= 490));

    
endmodule
