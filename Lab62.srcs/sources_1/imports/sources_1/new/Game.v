`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/15/2025 07:38:22 PM
// Design Name: 
// Module Name: Game
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
module NegEdgeDetector(
    input clk,
    input i,
    output o
    );
    wire q1, q2;
    FDRE #(.INIT(1'b0)) FLIP (.C(clk), .R(0), .CE(1), .D(i), .Q(q1));
    FDRE #(.INIT(1'b0)) FLIP2 (.C(clk), .R(0), .CE(1), .D(q1), .Q(q2));
    
    assign o = q2 & ~q1;
    
endmodule

module Game(
    input press,
    input btnL,
    input btnR,
    input start,
    input clk,
    input [15:0] sw,
    input [15:0] V,
    input [15:0] H,
    output [15:0] testnums,
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue
    );

    //Wires and important signals -------------------------------------------------------------------------------------------

    wire frame, belowFloor, scrollBall, flashBall, resetTimer, twoSec, resetBallActual, collision, stateBall;
    wire noLives, releas, peak, grounded, scrollHole, holeReset, increaseScore, changeColor;
    wire fall, rise, increaseBar, blink, newLife, blinkSel;
    wire startPulse, startTemp;
    wire startGame;
    wire [15:0] floor, currentTime;
    wire [15:0] playerPos, holePos, ballPos, ballHeight;
    wire [5:0] ballTemp;
    wire [6:0]  barPos, holeWidth;
    wire [4:0] holeTemp;
    wire [7:0] random, score;
    wire [3:0] state, lives, playerColorIndex;
    wire [11:0] color, playerColor;
    wire [11:0] Yellow, Green, Purple, Gray, Red, Black, White, Blue, Sky, Dirt, Grass;

    //frame
    EdgeDetector frameGen(.clk(clk), .i(~((V >= 489) & (V <= 490))), .o(frame));

    //start pulse:
    FDRE ffstartPulse (.Q(startTemp), .C(clk), .CE(frame), .R(1'b0), .D(1'b1));
    EdgeDetector startpulseedge(.clk(clk), .i(startTemp), .o(startPulse));

    //random
    lfsr randomval (.clk_i(clk), .q_o(random));

    //currentTime
    countUD16L timeCount (
        .clk_i(clk),
        .up_i(1'b0),                
        .dw_i(frame),                 
        .ld_i(resetTimer | currentTime == 16'h0000),                
        .din_i(16'hffff), 
        .q_o(currentTime)                      
    );

    //blinkSel
    assign blinkSel = currentTime[3];




    //Value handling -------------------------------------------------------------------------------------------


    //Energy Bar handling
    countUD16L barCount (
        .clk_i(clk),
        .up_i(increaseBar  & frame & (barPos < 64)),                
        .dw_i(~increaseBar & frame & (barPos > 0)),                 
        .ld_i(1'b0),                
        .din_i(16'b0000000000000000), 
        .q_o(barPos)                      
    );

    //Player Position handling
    countUD16L heightCount (
        .clk_i(clk),
        .up_i(rise & frame),                
        .dw_i(fall & frame),                 
        .ld_i(startPulse | newLife),             
        .din_i(75), 
        .q_o(playerPos)                      
    );

    //Hole position handling
    assign holeReset = startGame | (holePos <= 7) | newLife;
    countUD16L holeCount (
        .clk_i(clk),
        .up_i(0),                
        .dw_i(scrollHole & frame),                 
        .ld_i(holeReset),              
        .din_i(702), 
        .q_o(holePos)                      
    );

    FDRE #(.INIT(1'b0)) ffholewidth0  (.C(clk), .R(1'b0), .CE(holeReset), .D(random[0]), .Q(holeTemp[0]));
    FDRE #(.INIT(1'b0)) ffholewidth1  (.C(clk), .R(1'b0), .CE(holeReset), .D(random[1]), .Q(holeTemp[1]));
    FDRE #(.INIT(1'b0)) ffholewidth2  (.C(clk), .R(1'b0), .CE(holeReset), .D(random[2]), .Q(holeTemp[2]));
    FDRE #(.INIT(1'b0)) ffholewidth3  (.C(clk), .R(1'b0), .CE(holeReset), .D(random[3]), .Q(holeTemp[3]));
    FDRE #(.INIT(1'b0)) ffholewidth4  (.C(clk), .R(1'b0), .CE(holeReset), .D(random[4]), .Q(holeTemp[4]));

    assign holeWidth = holeTemp + 6'd40;

    //Ball position handling
    assign resetBallActual = resetBall | (ballPos <= 4) | startPulse;
    countUD16L ballCount (
        .clk_i(clk),
        .up_i(0),                
        .dw_i(scrollBall & frame),                 
        .ld_i(resetBallActual),              
        .din_i(322), 
        .q_o(ballPos)                      
    );

    FDRE #(.INIT(1'b0)) ffballheight0  (.C(clk), .R(1'b0), .CE(resetBallActual), .D(random[0]), .Q(ballTemp[0]));
    FDRE #(.INIT(1'b0)) ffballheight1  (.C(clk), .R(1'b0), .CE(resetBallActual), .D(random[1]), .Q(ballTemp[1]));
    FDRE #(.INIT(1'b0)) ffballheight2  (.C(clk), .R(1'b0), .CE(resetBallActual), .D(random[2]), .Q(ballTemp[2]));
    FDRE #(.INIT(1'b0)) ffballheight3  (.C(clk), .R(1'b0), .CE(resetBallActual), .D(random[3]), .Q(ballTemp[3]));
    FDRE #(.INIT(1'b0)) ffballheight4  (.C(clk), .R(1'b0), .CE(resetBallActual), .D(random[4]), .Q(ballTemp[4]));
    FDRE #(.INIT(1'b0)) ffballheight5  (.C(clk), .R(1'b0), .CE(resetBallActual), .D(random[5]), .Q(ballTemp[5]));

    assign ballHeight = 190 + ballTemp;


    assign underPit = ((holePos - holeWidth) < 40) & (55 < holePos);
    assign floor = 75;

    //score handling
    countUD16L scoreCount (
        .clk_i(clk),
        .up_i(increaseScore),                
        .dw_i(0),                 
        .ld_i(startPulse),              
        .din_i(0), 
        .q_o(score)                      
    );

    //life handling
    countUD16L lifeCount (
        .clk_i(clk),
        .up_i(newLife),                
        .dw_i(0), 
        .ld_i(startPulse | btnL),              
        .din_i(0), 
        .q_o(lives)                      
    );

    //playerColorIndex handling

    EdgeDetector changeColorPulse (.clk(clk), .i(flashBall), .o(changeColor));

    countUD16L colorCount (
        .clk_i(clk),
        .up_i(changeColor),                
        .dw_i(0), 
        .ld_i(startPulse | playerColorIndex == 4),              
        .din_i(0), 
        .q_o(playerColorIndex)                      
    );
    
    //Player State Machine -------------------------------------------------------------------------------------------

    //inputs
    assign noLives = lives == 2 & playerPos <= 20;
    NegEdgeDetector releaseDetect(.clk(clk), .i(press), .o(releas)); //releas
    assign peak = barPos == 0; //peak
    assign grounded = (underPit & ~sw[15]) ? playerPos <= 2 : playerPos <= floor; //grounded

    //outputs
    assign blink = playerPos < floor;
    assign newLife = (playerPos < floor) & grounded & ~noLives;

    PlayerFSM playerfsm(
        .clk(clk),
        .noLives(noLives),
        .releas(releas),
        .peak(peak),
        .grounded(grounded),
        .press(press),
        .fall(fall),
        .rise(rise),
        .increaseBar(increaseBar),
        .state(state)
    );

    //Ball State Machine -------------------------------------------------------------------------------------------
    //inputs
    assign belowFloor = playerPos < floor;
    assign twoSec = currentTime[5:0] == 0;
    assign collision = (55 > ballPos + ballPos - 4) & (ballPos + ballPos > 40) & (464 - playerPos - playerPos < ballHeight + 4) & (ballHeight < 480 - playerPos - playerPos);
    // assign collision = (40 < ballPos + ballPos) & (ballPos + ballPos > 55) & (464 - playerPos - playerPos > ballHeight) & (ballHeight > 480 - playerPos - playerPos);
    BallFSM ballfsm(
        .clk(clk),
        .start(start),
        .collision(collision),
        .twoSec(twoSec),
        .belowFloor(belowFloor),
        .noLives(noLives),
        .scrollHole(scrollHole),
        .scrollBall(scrollBall),
        .flashBall(flashBall),
        .resetTimer(resetTimer),
        .resetBall(resetBall),
        .increaseScore(increaseScore),
        .state(stateBall)
    );


    //graphics -------------------------------------------------------------------------------------------

    //color declerations
    assign Yellow = 12'hff0;
    assign Green  = 12'h0f0;
    assign Purple = 12'hf0f;
    assign Gray   = 12'h888;
    assign Red    = 12'hf00;
    assign Black  = 12'h000;
    assign White  = 12'hfff;
    assign Blue   = 12'h00f;
    assign Sky    = 12'h5bc;
    assign Dirt   = 12'h752;
    assign Grass  = 12'h294;

    //logic for positions
    assign outsideVisibleRange = (H > 639) | (V > 479);

    assign inBorder = (H < 8) | (H >= 632) | (V < 8) | (V >= 471);

    assign inPlayer = (~blink | blinkSel) & ((H >= 40) & (H <= 55) & (V <= 480 - playerPos - playerPos) & (V > 464 - playerPos - playerPos));

    assign inBar = (H >= 32) & (H < 48) & (V < 96) & (V > 96 - barPos);

    assign inBall = (~flashBall | blinkSel) & (H <= ballPos + ballPos) & (H > ballPos + ballPos - 4) & (V >= ballHeight) & (V < ballHeight + 4);

    wire [16:0] leftEdge;
    assign leftEdge = holePos - holeWidth;
    assign inHole = (H <= holePos) & ((H > holePos - holeWidth) | leftEdge[16]);

    assign inFloor = (V <= 350) & (V >= 331);

    assign inBasement = V >= 351;


    
    //color assignment

    assign playerColor = (playerColorIndex == 0) ? Purple :
                         (playerColorIndex == 1) ? Blue   :
                         (playerColorIndex == 2) ? Black    :
                         (playerColorIndex == 3) ? Dirt   :
                         Yellow;

    assign color = outsideVisibleRange ? 12'h000000    :
                   inBorder            ? Red      :
                   inPlayer            ? playerColor   :
                   inBar               ? Green    :
                   inBall              ? Yellow   :
                   inHole              ? Sky      :
                   inFloor             ? Grass    :
                   inBasement          ? Dirt     :
                   Sky;


    assign red = color[11:8];
    assign green = color[7:4];
    assign blue = color[3:0];

    //test values
    wire [7:0] toDisplay;
    assign toDisplay = noLives ? 0 : 3 - lives;
    assign testnums[7:0] = score;
    assign testnums[11:8] = 0;
    assign testnums[15:12] = toDisplay;

endmodule


