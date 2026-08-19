`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2025 04:26:54 PM
// Design Name: 
// Module Name: EdgeDetector
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


module EdgeDetector(
    input clk,
    input i,
    output o
    );
    wire q1, q2;
    FDRE #(.INIT(1'b0)) FLIP (.C(clk), .R(0), .CE(1), .D(i), .Q(q1));
    FDRE #(.INIT(1'b0)) FLIP2 (.C(clk), .R(0), .CE(1), .D(q1), .Q(q2));
    
    assign o = ~q2 & q1;
    
endmodule
