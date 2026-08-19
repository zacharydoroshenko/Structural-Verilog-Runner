`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2025 08:20:09 PM
// Design Name: 
// Module Name: lfsr
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


module lfsr(
    input clk_i,
    output [7:0] q_o
);

    wire [7:0] rnd;
    wire xoro;


    FDRE #(.INIT(1'b0)) FLIP0 (.C(clk_i), .R(0), .CE(1), .D(xoro), .Q(rnd[0]));
    FDRE #(.INIT(1'b0)) FLIP1 (.C(clk_i), .R(0), .CE(1), .D(rnd[0]), .Q(rnd[1]));
    FDRE #(.INIT(1'b0)) FLIP2 (.C(clk_i), .R(0), .CE(1), .D(rnd[1]), .Q(rnd[2]));
    FDRE #(.INIT(1'b0)) FLIP3 (.C(clk_i), .R(0), .CE(1), .D(rnd[2]), .Q(rnd[3]));
    FDRE #(.INIT(1'b0)) FLIP4 (.C(clk_i), .R(0), .CE(1), .D(rnd[3]), .Q(rnd[4]));
    FDRE #(.INIT(1'b0)) FLIP5 (.C(clk_i), .R(0), .CE(1), .D(rnd[4]), .Q(rnd[5]));
    FDRE #(.INIT(1'b0)) FLIP6 (.C(clk_i), .R(0), .CE(1), .D(rnd[5]), .Q(rnd[6]));
    FDRE #(.INIT(1'b1)) FLIP7 (.C(clk_i), .R(0), .CE(1), .D(rnd[6]), .Q(rnd[7]));

    assign xoro = rnd[0] ^ rnd[5] ^ rnd[6] ^ rnd[7];
    assign q_o = rnd;


endmodule
