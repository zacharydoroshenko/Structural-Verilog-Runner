`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2025 04:26:54 PM
// Design Name: 
// Module Name: countUD4L
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


module countUD4L(
    input clk_i,
    input up_i,
    input dw_i,
    input ld_i,
    input [3:0] din_i,
    output [3:0] q_o,
    output utc_o,
    output dtc_o
    );
    
    wire [3:0] q;
    wire [3:0] next;

    // Increment and decrement logic
    wire [3:0] inc, dec;

    // Bitwise logic to handle up/down count (ripple-carry style)
    assign inc[0] = q[0] ^ up_i;
    assign inc[1] = q[1] ^ (up_i & q[0]);
    assign inc[2] = q[2] ^ (up_i & q[0] & q[1]);
    assign inc[3] = q[3] ^ (up_i & q[0] & q[1] & q[2]);

    assign dec[0] = q[0] ^ dw_i;
    assign dec[1] = q[1] ^ (dw_i & ~q[0]);
    assign dec[2] = q[2] ^ (dw_i & ~q[0] & ~q[1]);
    assign dec[3] = q[3] ^ (dw_i & ~q[0] & ~q[1] & ~q[2]);

    // Select between load, increment, and decrement
    assign next[0] = (ld_i & din_i[0]) | (~ld_i & ((up_i & inc[0]) | (dw_i & dec[0]) | (~up_i & ~dw_i & q[0])));
    assign next[1] = (ld_i & din_i[1]) | (~ld_i & ((up_i & inc[1]) | (dw_i & dec[1]) | (~up_i & ~dw_i & q[1])));
    assign next[2] = (ld_i & din_i[2]) | (~ld_i & ((up_i & inc[2]) | (dw_i & dec[2]) | (~up_i & ~dw_i & q[2])));
    assign next[3] = (ld_i & din_i[3]) | (~ld_i & ((up_i & inc[3]) | (dw_i & dec[3]) | (~up_i & ~dw_i & q[3])));

    // FDRE Flip-Flops (no async reset)
    FDRE ff0 (.Q(q[0]), .C(clk_i), .CE(1'b1), .R(1'b0), .D(next[0]));
    FDRE ff1 (.Q(q[1]), .C(clk_i), .CE(1'b1), .R(1'b0), .D(next[1]));
    FDRE ff2 (.Q(q[2]), .C(clk_i), .CE(1'b1), .R(1'b0), .D(next[2]));
    FDRE ff3 (.Q(q[3]), .C(clk_i), .CE(1'b1), .R(1'b0), .D(next[3]));

    assign q_o = q;

    // Terminal counts
    assign utc_o = q[3] & q[2] & q[1] & q[0];            // 4'b1111 = 15
    assign dtc_o = ~q[3] & ~q[2] & ~q[1] & ~q[0];         // 4'b0000 = 0
    
endmodule


module tc_pulse_gen (
    input wire clk,
    input wire utc_i,
    input wire dtc_i,
    output wire up_pulse_o,
    output wire dw_pulse_o
);
    wire utc_d1, utc_d2;
    wire dtc_d1, dtc_d2;

    FDRE ff_utc1 (.Q(utc_d1), .C(clk), .CE(1'b1), .R(1'b0), .D(utc_i));
    FDRE ff_utc2 (.Q(utc_d2), .C(clk), .CE(1'b1), .R(1'b0), .D(utc_d1));

    FDRE ff_dtc1 (.Q(dtc_d1), .C(clk), .CE(1'b1), .R(1'b0), .D(dtc_i));
    FDRE ff_dtc2 (.Q(dtc_d2), .C(clk), .CE(1'b1), .R(1'b0), .D(dtc_d1));

    // up_pulse when utc falls and dtc rises
    assign up_pulse_o = utc_d2 & ~utc_d1 & ~dtc_d2 & dtc_d1;

    // dw_pulse when dtc falls and utc rises
    assign dw_pulse_o = dtc_d2 & ~dtc_d1 & ~utc_d2 & utc_d1;
endmodule


// module countUD16L (
//     input clk_i,
//     input up_i,
//     input dw_i,
//     input ld_i,
//     input [15:0] din_i,
//     output [15:0] q_o,
//     output utc_o,
//     output dtc_o
// );

//     wire [3:0] q0, q1, q2, q3;
// wire utc0, utc1, utc2, utc3;
// wire dtc0, dtc1, dtc2, dtc3;
// wire up1, up2, up3;
// wire dw1, dw2, dw3;

// // Pulse gens between counters
// tc_pulse_gen tcg0 (.clk(clk_i), .utc_i(utc0), .dtc_i(dtc0), .up_pulse_o(up1), .dw_pulse_o(dw1));
// tc_pulse_gen tcg1 (.clk(clk_i), .utc_i(utc1), .dtc_i(dtc1), .up_pulse_o(up2), .dw_pulse_o(dw2));
// tc_pulse_gen tcg2 (.clk(clk_i), .utc_i(utc2), .dtc_i(dtc2), .up_pulse_o(up3), .dw_pulse_o(dw3));

// // Counter 0 gets top-level up/dw signals
// countUD4L c0 (
//     .clk_i(clk_i), .up_i(up_i), .dw_i(dw_i), .ld_i(ld_i),
//     .din_i(din_i[3:0]), .q_o(q0), .utc_o(utc0), .dtc_o(dtc0)
// );

// // Counter 1 gets pulse from c0 transition
// countUD4L c1 (
//     .clk_i(clk_i), .up_i(up1), .dw_i(dw1), .ld_i(ld_i),
//     .din_i(din_i[7:4]), .q_o(q1), .utc_o(utc1), .dtc_o(dtc1)
// );

// // Counter 2 gets pulse from c1 transition
// countUD4L c2 (
//     .clk_i(clk_i), .up_i(up2), .dw_i(dw2), .ld_i(ld_i),
//     .din_i(din_i[11:8]), .q_o(q2), .utc_o(utc2), .dtc_o(dtc2)
// );

// // Counter 3 gets pulse from c2 transition
// countUD4L c3 (
//     .clk_i(clk_i), .up_i(up3), .dw_i(dw3), .ld_i(ld_i),
//     .din_i(din_i[15:12]), .q_o(q3), .utc_o(utc3), .dtc_o(dtc3)
// );

// // Combined output
// assign q_o = {q3, q2, q1, q0};
// assign utc_o = utc0 & utc1 & utc2 & utc3;
// assign dtc_o = dtc0 & dtc1 & dtc2 & dtc3;


// endmodule

module countUD16L (
    input clk_i,
    input up_i,
    input dw_i,
    input ld_i,
    input [15:0] din_i,
    output [15:0] q_o,
    output utc_o,
    output dtc_o
);

    wire [3:0] q0, q1, q2, q3;
    wire utc0, utc1, utc2, utc3;
    wire dtc0, dtc1, dtc2, dtc3;

    // Counter 0 gets top-level up/dw signals
    countUD4L c0 (
        .clk_i(clk_i), .up_i(up_i), .dw_i(dw_i), .ld_i(ld_i),
        .din_i(din_i[3:0]), .q_o(q0), .utc_o(utc0), .dtc_o(dtc0)
    );

    // Counter 1 directly controlled by overflow of Counter 0
    countUD4L c1 (
        .clk_i(clk_i), 
        .up_i(up_i & utc0), 
        .dw_i(dw_i & dtc0), 
        .ld_i(ld_i),
        .din_i(din_i[7:4]), 
        .q_o(q1), 
        .utc_o(utc1), 
        .dtc_o(dtc1)
    );

    // Counter 2 directly controlled by overflow of Counter 1
    countUD4L c2 (
        .clk_i(clk_i), 
        .up_i(up_i & utc0 & utc1), 
        .dw_i(dw_i & dtc0 & dtc1), 
        .ld_i(ld_i),
        .din_i(din_i[11:8]), 
        .q_o(q2), 
        .utc_o(utc2), 
        .dtc_o(dtc2)
    );

    // Counter 3 directly controlled by overflow of Counter 2
    countUD4L c3 (
        .clk_i(clk_i), 
        .up_i(up_i & utc0 & utc1 & utc2), 
        .dw_i(dw_i & dtc0 & dtc1 & dtc2), 
        .ld_i(ld_i),
        .din_i(din_i[15:12]), 
        .q_o(q3), 
        .utc_o(utc3), 
        .dtc_o(dtc3)
    );

    // Combined output
    assign q_o = {q3, q2, q1, q0};
    assign utc_o = utc0 & utc1 & utc2 & utc3;
    assign dtc_o = dtc0 & dtc1 & dtc2 & dtc3;

endmodule

