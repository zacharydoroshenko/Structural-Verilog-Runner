# FPGA Endless Runner

A VGA/HDMI arcade game built entirely in structural Verilog for a Digilent Basys 3 FPGA board (via AMD/Xilinx Vivado), written for UC San Diego's CSE 100 computer architecture course. No behavioral blocks anywhere: every register is an explicitly instantiated flip-flop primitive, and randomness comes from a hand-built linear feedback shift register rather than a software RNG.

## Features

**Structural-only design** — every stateful element is wired by hand as an explicit `FDRE` flip-flop primitive rather than an `always @(posedge clk)` block, so the entire game's state lives directly in the gate-level wiring instead of behind synthesizer inference.

**Player physics (`PlayerFSM.v`)** — a 4-state machine (Idle, Jumping, Falling, Dead). Holding the jump button while grounded charges a variable jump height, releasing triggers the rise, and it falls automatically once the peak is passed.

**Obstacle timing (`BallFSM.v`)** — a second 4-state machine (GameStart, Scroll, Flash, NoLives) that governs when pits scroll, when the game resets after a collision, and when score increments, gated by a 2-second timer.

**Procedural generation (`lfsr.v`)** — an 8-bit linear feedback shift register generates pseudo-randomness from nothing but flip-flops and XOR gates, used to randomize pit and coin placement as they scroll across the screen.

**Dual video output** — `top.v` drives a VGA port and an HDMI port simultaneously from the same pixel-color logic, plus a 4-digit 7-segment hex display and onboard LEDs for real-time debug output, since there's no console or print statement available on bare FPGA hardware.

## Structure

```
src/
  top.v              Top-level wiring: clock, sync, Game module, VGA/HDMI output, debug display
  Game.v              Main game logic: pixel-color rendering, collision detection, coin/score tracking
  PlayerFSM.v          Player jump/fall/death state machine
  BallFSM.v            Obstacle scroll/reset/scoring state machine
  PixelAddress.v        Pixel row/column position counter
  Syncs.v               VGA horizontal/vertical sync generation
  lfsr.v                8-bit linear feedback shift register for procedural randomness
  labVGA_clks.v         Pixel clock generation (course-provided resource)
  hex7seg.v             7-segment display decoder (from an earlier lab in the same course)
  RingCounter.v         Digit-select ring counter for the 7-segment display (from an earlier lab)
  Selector.v            Multiplexes debug values onto the 7-segment display (from an earlier lab)
constraints/
  Basys3_Master.xdc    Digilent's standard Basys 3 pin-mapping constraints file
docs/
  PseudoCode.txt        Original design notes and planning pseudocode
```

## Building and running

Requires AMD/Xilinx Vivado (built and tested on 2023.2) and a Digilent Basys 3 board.

1. Create a new Vivado project targeting the Basys 3 (part `xc7a35tcpg236-1`).
2. Add everything in `src/` as design sources.
3. Add `constraints/Basys3_Master.xdc` as a constraints file and uncomment the pins this design uses (VGA, HDMI, buttons, switches, 7-segment display).
4. Run Synthesis, then Implementation, then Generate Bitstream.
5. Program the board and connect a VGA or HDMI monitor.

Controls: hold the jump button to charge a jump, release to leap over the next pit.
