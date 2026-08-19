`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 04:49:20 PM
// Design Name: 
// Module Name: mux8bit
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


module mux8bit(
    input [7:0] A,
    input [7:0] B,
    input s0,
    output [7:0] o
    );
    
    assign o = ({8{~s0}} & A | {8{s0}} & B);
    
endmodule
