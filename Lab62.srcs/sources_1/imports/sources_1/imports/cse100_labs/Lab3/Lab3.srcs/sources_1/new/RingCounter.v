`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2025 04:26:54 PM
// Design Name: 
// Module Name: RingCounter
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


module RingCounter(
    input clk,
    input advance,
    output [3:0] o
    );
    wire [3:0] q, next;
    wire allzero = ~(q[0] | q[1] | q[2] | q[3]);
    
    assign next[0] = allzero | (~advance & q[0]) | (advance & q[3]);
    assign next[1] = (~advance & q[1]) | (advance & q[0]);
    assign next[2] = (~advance & q[2]) | (advance & q[1]);
    assign next[3] = (~advance & q[3]) | (advance & q[2]);
    
    FDRE #(.INIT(1'b0)) ff0 (.C(clk), .R(0), .CE(1), .D(next[0]), .Q(q[0]));
    FDRE #(.INIT(1'b0)) ff1 (.C(clk), .R(0), .CE(1), .D(next[1]), .Q(q[1]));
    FDRE #(.INIT(1'b0)) ff2 (.C(clk), .R(0), .CE(1), .D(next[2]), .Q(q[2]));
    FDRE #(.INIT(1'b0)) ff3 (.C(clk), .R(0), .CE(1), .D(next[3]), .Q(q[3]));
    
    assign o = q;
endmodule
