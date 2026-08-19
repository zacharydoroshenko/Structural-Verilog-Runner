`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2025 06:34:27 PM
// Design Name: 
// Module Name: top
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


module top(
    input clkin,
    input btnC,
    input btnU,
    input btnL,
    input btnR,
    input [15:0] sw,
    output [15:0] led,
    output [3:0] an,
    output [6:0] seg,
    output dp,
    output [3:0] vgaRed,
    output [3:0] vgaBlue,
    output [3:0] vgaGreen,
    output [3:0] hdmiRed,
    output [3:0] hdmiBlue,
    output [3:0] hdmiGreen,
    output hdmi_hsync,
    output hdmi_vsync,
    output hdmi_dispen,
    output hdmi_clk,
    output Hsync,
    output Vsync



);



    wire clk, digsel, Hsynctemp, Vsynctemp, universalHsync, universalVsync;
    wire [15:0] V, H, testnums;
    wire [3:0] sel_i, hex_i, red, green, blue, Red, Green, Blue;

    //clock ------------------------------------------------------------------------------------------------------------------------------------------
    labVGA_clks not_so_slow (.clkin(clkin), .greset(btnR), .clk(clk), .digsel(digsel));

    //Pixel positions and Vsync/Hsync -------------------------------------------------------------------------------------------------------------------
    PixelAddress rowcolpos (.clk(clk), .V(V), .H(H));

    Syncs syncgen (.V(V), .H(H), .Vsync(Vsynctemp), .Hsync(Hsynctemp));

    FDRE #(.INIT(1'b1)) ffVsync (.Q(universalVsync), .C(clk), .CE(1'b1), .R(1'b0), .D(Vsynctemp));
    FDRE #(.INIT(1'b1)) ffHsync (.Q(universalHsync), .C(clk), .CE(1'b1), .R(1'b0), .D(Hsynctemp));

    assign hdmi_clk = clk;
    assign Hsync = universalHsync;
    assign hdmi_hsync = universalHsync;
    assign Vsync = universalVsync;
    assign hdmi_vsync = universalVsync;
    assign hdmi_dispen = ((H >= 0) & (H <= 639)) & ((V >= 0) & (V <= 479));

    //Game module ------------------------------------------------------------------------------------------------------------------------------------------

    wire press;
    FDRE ffPress (.Q(press), .C(clk), .CE(digsel), .R(1'b0), .D(btnU));

    wire start;
    FDRE ffStart (.Q(start), .C(clk), .CE(digsel), .R(1'b0), .D(btnC));

    Game mainGameModule (
        .V(V),
        .H(H),
        .start(start),
        .press(press),
        .btnL(btnL),
        .btnR(btnR),
        .sw(sw),
        .clk(clk),
        .red(red),
        .green(green),
        .blue(blue),
        .testnums(testnums)
    );


    FDRE ffRed0 (.Q(Red[0]), .C(clk), .CE(1'b1), .R(1'b0), .D(red[0]));
    FDRE ffRed1 (.Q(Red[1]), .C(clk), .CE(1'b1), .R(1'b0), .D(red[1]));
    FDRE ffRed2 (.Q(Red[2]), .C(clk), .CE(1'b1), .R(1'b0), .D(red[2]));
    FDRE ffRed3 (.Q(Red[3]), .C(clk), .CE(1'b1), .R(1'b0), .D(red[3]));

    FDRE ffGreen0 (.Q(Green[0]), .C(clk), .CE(1'b1), .R(1'b0), .D(green[0]));
    FDRE ffGreen1 (.Q(Green[1]), .C(clk), .CE(1'b1), .R(1'b0), .D(green[1]));
    FDRE ffGreen2 (.Q(Green[2]), .C(clk), .CE(1'b1), .R(1'b0), .D(green[2]));
    FDRE ffGreen3 (.Q(Green[3]), .C(clk), .CE(1'b1), .R(1'b0), .D(green[3]));

    FDRE ffBlue0 (.Q(Blue[0]), .C(clk), .CE(1'b1), .R(1'b0), .D(blue[0]));
    FDRE ffBlue1 (.Q(Blue[1]), .C(clk), .CE(1'b1), .R(1'b0), .D(blue[1]));
    FDRE ffBlue2 (.Q(Blue[2]), .C(clk), .CE(1'b1), .R(1'b0), .D(blue[2]));
    FDRE ffBlue3 (.Q(Blue[3]), .C(clk), .CE(1'b1), .R(1'b0), .D(blue[3]));

    assign vgaBlue = Blue;
    assign vgaRed = Red;
    assign vgaGreen = Green;
    
    assign hdmiBlue = Blue;
    assign hdmiRed = Red;
    assign hdmiGreen = Green;

    //debugging info ------------------------------------------------------------------------------------------------------------------------------------------

    //7seg display
    RingCounter ringcount(
        .clk(clk),
        .advance(digsel),
        .o(sel_i)
    );

    Selector select(
        .N(testnums),
        .sel(sel_i),
        .H(hex_i)
    );

    hex7seg hexconvert(
        .seg(seg),
        .n(hex_i)
    );

    // assign an = ~sel_i;

    assign an[0] = ~sel_i[0];
    assign an[1] = ~sel_i[1];
    assign an[2] = 1;
    assign an[3] = ~sel_i[3];


    assign dp = 1;

    //leds
    assign led = sw;


endmodule


// module top(
//     input clkin,
//     input btnC,
//     input btnU,
//     input btnL,
//     input btnR,
//     input [15:0] sw,
//     output [15:0] led,
//     output [3:0] an,
//     output [6:0] seg,
//     output dp,
//     output [3:0] vgaRed,
//     output [3:0] vgaBlue,
//     output [3:0] vgaGreen,
//     output Hsync,
//     output Vsync



// );

//     wire clk, digsel, Hsynctemp, Vsynctemp;
//     wire [15:0] V, H, testnums;
//     wire [3:0] sel_i, hex_i, red, green, blue;

//     //clock ------------------------------------------------------------------------------------------------------------------------------------------
//     labVGA_clks not_so_slow (.clkin(clkin), .greset(btnR), .clk(clk), .digsel(digsel));

//     //Pixel positions and Vsync/Hsync -------------------------------------------------------------------------------------------------------------------
//     PixelAddress rowcolpos (.clk(clk), .V(V), .H(H));

//     Syncs syncgen (.V(V), .H(H), .Vsync(Vsynctemp), .Hsync(Hsynctemp));

//     FDRE #(.INIT(1'b1)) ffVsync (.Q(Vsync), .C(clk), .CE(1'b1), .R(1'b0), .D(Vsynctemp));
//     FDRE #(.INIT(1'b1)) ffHsync (.Q(Hsync), .C(clk), .CE(1'b1), .R(1'b0), .D(Hsynctemp));

//     //Game module ------------------------------------------------------------------------------------------------------------------------------------------

//     wire press;
//     FDRE ffPress (.Q(press), .C(clk), .CE(digsel), .R(1'b0), .D(btnU));

//     wire start;
//     FDRE ffStart (.Q(start), .C(clk), .CE(digsel), .R(1'b0), .D(btnC));

//     Game mainGameModule (
//         .V(V),
//         .H(H),
//         .start(start),
//         .press(press),
//         .btnL(btnL),
//         .btnR(btnR),
//         .sw(sw),
//         .clk(clk),
//         .red(red),
//         .green(green),
//         .blue(blue),
//         .testnums(testnums)
//     );

//     FDRE ffRed0 (.Q(vgaRed[0]), .C(clk), .CE(1'b1), .R(1'b0), .D(red[0]));
//     FDRE ffRed1 (.Q(vgaRed[1]), .C(clk), .CE(1'b1), .R(1'b0), .D(red[1]));
//     FDRE ffRed2 (.Q(vgaRed[2]), .C(clk), .CE(1'b1), .R(1'b0), .D(red[2]));
//     FDRE ffRed3 (.Q(vgaRed[3]), .C(clk), .CE(1'b1), .R(1'b0), .D(red[3]));

//     FDRE ffGreen0 (.Q(vgaGreen[0]), .C(clk), .CE(1'b1), .R(1'b0), .D(green[0]));
//     FDRE ffGreen1 (.Q(vgaGreen[1]), .C(clk), .CE(1'b1), .R(1'b0), .D(green[1]));
//     FDRE ffGreen2 (.Q(vgaGreen[2]), .C(clk), .CE(1'b1), .R(1'b0), .D(green[2]));
//     FDRE ffGreen3 (.Q(vgaGreen[3]), .C(clk), .CE(1'b1), .R(1'b0), .D(green[3]));

//     FDRE ffBlue0 (.Q(vgaBlue[0]), .C(clk), .CE(1'b1), .R(1'b0), .D(blue[0]));
//     FDRE ffBlue1 (.Q(vgaBlue[1]), .C(clk), .CE(1'b1), .R(1'b0), .D(blue[1]));
//     FDRE ffBlue2 (.Q(vgaBlue[2]), .C(clk), .CE(1'b1), .R(1'b0), .D(blue[2]));
//     FDRE ffBlue3 (.Q(vgaBlue[3]), .C(clk), .CE(1'b1), .R(1'b0), .D(blue[3]));



//     //debugging info ------------------------------------------------------------------------------------------------------------------------------------------

//     //7seg display
//     RingCounter ringcount(
//         .clk(clk),
//         .advance(digsel),
//         .o(sel_i)
//     );

//     Selector select(
//         .N(testnums),
//         .sel(sel_i),
//         .H(hex_i)
//     );

//     hex7seg hexconvert(
//         .seg(seg),
//         .n(hex_i)
//     );

//     assign an = ~sel_i;
//     assign dp = 1;

//     //leds
//     assign led = sw;


// endmodule
