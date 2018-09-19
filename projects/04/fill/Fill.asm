// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// Spec:
// 16-bit bus;
// Screen is 256px by 512px, where each px corresponds to a pin inside RAM
// => Each row uses (512/16)=32 RAM addresses
// => Screen uses 256*32=8192 RAM addresses 

(KBDLOOP)
  @KBD
  D=M
  @KEYPRESSED 
  D;JNE // Jump to KEYPRESSED if key is pressed

  // Turn screen white
  //*******************

  // loop initialization
  @8191
  D=A
  @i
  M=D

  (LOOP1)
    @SCREEN
    D=A
    @i
    A=D+M
    M=0
    @i
    MD=M-1
    @LOOP1
    D;JGE

  // Restart loop
  @KBDLOOP
  0;JMP

  (KEYPRESSED)
    // Turn screen black
    //*******************

    // loop initialization
    @8191
    D=A
    @i
    M=D

    (LOOP2)
      @SCREEN
      D=A
      @i
      A=D+M
      M=-1
      @i
      MD=M-1
      @LOOP2
      D;JGE
    @KBDLOOP
    0;JMP
