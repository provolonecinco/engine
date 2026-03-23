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
    .byte "Um, I made a comment earlier tonight that", TXT::NL
    .byte "I guess went out over the air that I am", TXT::NL
    .byte "deeply ashamed of. If I have hurt anyone", TXT::NL
    .byte "out there, I can't tell you how much I say", TXT::NL 
    .byte "from the bottom of my heart, I'm so very,", TXT::NL
    .byte "very sorry. I pride myself and think of", TXT::NL 
    .byte "myself as a man of faith-as there's a drive", TXT::NL 
    .byte "into deep left field by Castellanos, it will", TXT::NL
    .byte "be a home run, and so that'll make it a 4-0", TXT::NL 
    .byte "ballgame. I don't know if I'm gonna be putting", TXT::NL
    .byte "on this headset again.", TXT::END

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

    PRINT sample_text, 1, 8
    JSR upload_text

    seta8     
    SET NMITIMEN, #$81  ; enable NMI at VBlank, automatic joypad reading
    SET TM, #$14        ; enable sprites, BG3
    SET PPUBRIGHT, #$0F ; turn screen ON
loop:
    setaxy16
    LDA #$00
    TAX 
    TAY 


    JSR update_text

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

    JSR upload_text
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