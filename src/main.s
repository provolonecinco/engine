.include "snes.inc"
.include "main.inc"
;--------------------------------------
.segment "ZEROPAGE" 
framecounter:       .res 2

joyState:           .res 2
joyPressed:         .res 2
joyHeld:            .res 2
;--------------------------------------
.segment "LORAM"
;--------------------------------------
.segment "BANK0"
;--------------------------------------
.proc main     
; here: init PPU and whatnot


loop:
    setaxy16
    LDA #$00
    TAX 
    TAY 


    LDA framecounter
WaitVBlank:
    ; NMI will modify framecounter and the 
    ; compare will fail, so we know NMI happened
    CMP framecounter
    BEQ WaitVBlank
    JMP loop
.endproc
;--------------------------------------
.proc NMI 
    ; preserve registers
    PHA         
    PHX         
    PHY         
    BIT a:NMISTATUS

    ; Read the controller 
    setaxy16
    LDY joyState
    LDA JOY1L
    STA joyState
    TYA 
    AND joyState
    STA joyHeld

    TYA             ; get the bits that were newly pressed this frame
    EOR #$FFFF
    STA joyPressed
    LDA joyState
    AND joyPressed
    STA joyPressed

    INC framecounter
	PLY       
    PLX
    PLA         
    RTI
.endproc
;--------------------------------------
.proc IRQ
    RTI
.endproc
;--------------------------------------
.proc COP_
    RTI
.endproc
;--------------------------------------
.proc BRK_
    RTI
.endproc
;--------------------------------------