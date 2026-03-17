.include "snes.inc"
.include "general.inc"
.include "zp.inc"
.include "gfx.inc"

.include "main.inc"
;--------------------------------------
.segment "BANK0"
;--------------------------------------
sample_palette: 
    .incbin "pal/basic.pal"

sample_chr: 
    .incbin "chr/spr.chr"

sample_sprite:
    .byte $00, $00, $01, $00 
    .byte $80

.proc main     
    setaxy16 
    LDA #%00000001          ; background mode 1
    STA BGMODE

    ; BG1 Tilemap Location 
    LDA #(BG1MAP_BASE >> 10) << 2  
    STA BG1SC        
    ; BG2 Tilemap Location
    LDA #(BG2MAP_BASE >> 10) << 2  
    STA BG2SC          
    ; BG3 Tilemap Location
    LDA #(BG3MAP_BASE >> 10) << 2   
    STA BG3SC    

    ; BG CHR locations
    LDA #(BG3CHR_BASE >> 4) | (BG2CHR_BASE >> 8) | (BG1CHR_BASE >> 12)
    STA BGCHRADDR   

    ; Sprite CHR locations 
    LDA #(SPRITECHR_BASE >> 14) | OBSIZE_8_16
    STA OBSEL 

    LDPT pointer, sample_palette
    LDX #PAL_8
    JSR buffer_palette

    LDA #INC_DATAHI ; increment VRAM addrress on high byte
    STA PPUCTRL
    LDPT pointer, sample_chr
    LDA #SPRITECHR_BASE
    JSR load_4bpp_tiles

    seta8 
    LDA #$80        ; enable NMI at VBlank
    STA NMITIMEN
    
    LDA #$10 
    STA TM          ; enable sprites
    LDA #$0F         
    STA PPUBRIGHT   ; turn screen ON 
loop:
    setaxy16
    LDA #$00
    TAX 
    TAY 

    JSR clear_oam
    
    LDPT pointer, sample_sprite
    LDA #$7C 
    STA r0 
    LDA #$70
    STA r1
    JSR buffer_sprite

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