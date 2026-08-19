`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2025 04:14:17 AM
// Design Name: 
// Module Name: BallFSM
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


module BallFSM(
        input clk,
        input start,
        input collision,
        input twoSec,
        input belowFloor,
        input noLives,
        output scrollHole,
        output scrollBall,
        output flashBall,
        output resetTimer,
        output resetBall,
        output increaseScore,
        output [3:0] state
    );

    parameter GameStart = 4'b0001;
    parameter Scroll = 4'b0010;
    parameter Flash = 4'b0100;
    parameter NoLives  = 4'b1000;

    wire [3:0] cs;
    wire [3:0] ns;

    assign ns[0] = (cs[0] & ~start);
    assign ns[1] = (cs[0] & start) | (cs[2] & twoSec) | (cs[1] & ~noLives & ~collision);
    assign ns[2] = (cs[1] & collision) | (cs[2] & ~twoSec);
    assign ns[3] = (cs[1] & noLives) | (cs[3]);

    FDRE #(.INIT(1'b1)) ff  (.C(clk), .R(0), .CE(1), .D(ns[0]), .Q(cs[0]));
    FDRE #(.INIT(1'b0)) ff1 (.C(clk), .R(0), .CE(1), .D(ns[1]), .Q(cs[1]));
    FDRE #(.INIT(1'b0)) ff2 (.C(clk), .R(0), .CE(1), .D(ns[2]), .Q(cs[2]));
    FDRE #(.INIT(1'b0)) ff3 (.C(clk), .R(0), .CE(1), .D(ns[3]), .Q(cs[3]));

    assign scrollHole = ~belowFloor & (cs[1] | cs[2]);
    assign scrollBall = cs[1];
    assign flashBall = cs[2];
    assign resetTimer = collision & cs[1];
    assign increaseScore = cs[2] & twoSec;
    assign state = cs;
    assign resetBall = (cs[0] & start) | (cs[2] & twoSec) | cs[3];

    


endmodule
