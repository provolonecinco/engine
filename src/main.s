.include "include/snes.inc"
.include "include/general.inc"
.include "include/zp.inc"
.include "include/gfx.inc"
.include "include/text.inc"
;--------------------------------------
.segment "BANK0"
;--------------------------------------

sample_palette:
    .incbin "pal/font.pal"

sample_text:
    .byte "A", TXT::END

.proc main     
    setaxy16 
    SET BGMODE, #%00000001          ; background mode 1
    ; BG1 Tilemap Location 
    SET BG1SC, #(BG1MAP_BASE >> 10) << 2  
    ; BG2 Tilemap Location
    SET BG2SC, #(BG2MAP_BASE >> 10) << 2  
    ; BG3 Tilemap Location
    SET BG3SC, #(BG3MAP_BASE >> 10) << 2      
    ; BG CHR locations
    SET BGCHRADDR, #(BG3CHR_BASE >> 4) | (BG2CHR_BASE >> 8) | (BG1CHR_BASE >> 12)   
    ; Sprite CHR locations 
    SET OBSEL, #(SPRITECHR_BASE >> 14) | OBSIZE_8_16 

    LDX #PAL_0
    LDPT pointer, sample_palette
    JSR buffer_palette

    LDPT textptr, sample_text
    JSR update_text

    seta8     
    SET NMITIMEN, #$80  ; enable NMI at VBlank
    SET TM, #$10        ; enable sprites 
    SET PPUBRIGHT, #$0F ; turn screen ON
loop:
    setaxy16
    LDA #$00
    TAX 
    TAY 

    JSR clear_oam

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
    PHP 
    PHA         
    PHX         
    PHY         
    BIT a:NMISTATUS

    JSR cgram_dma
    JSR oam_dma

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
    PLP    
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
    WAI
    RTI
.endproc
;--------------------------------------