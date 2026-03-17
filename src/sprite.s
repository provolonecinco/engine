.include "include/snes.inc"
.include "include/general.inc"
.include "include/zp.inc"
.include "include/gfx.inc"
;--------------------------------------
.segment "ZEROPAGE"
oampos:         .res 2
;--------------------------------------
.segment "LORAM"
OAMbuf:         .res 512
OAMbuf_hi:      .res 3
;--------------------------------------
.segment "BANK0"
;--------------------------------------
.proc oam_dma
    setaxy16    
    LDA #0 
    STA OAMADDL
    ; Setup DMA for 544 bytes (low/high OAM tables) to OAM
    SETDMA 0, $00, OAMbuf, 544, OAMDATA
    LDA #1
    STA COPYSTART
    RTS
.endproc
;--------------------------------------
.proc clear_oam
    setaxy16 
    LDY #0
    TYX
    LDA #$F000
clear: 
    STA OAMbuf, X
    INX 
    INX 
    INX 
    INX 
    INY 
    CPY #128 
    BNE clear 

    STZ oampos  ; reset oam position for this frame

    RTS 
.endproc 
;--------------------------------------
.proc buffer_sprite
xpos = r0
ypos = r1

    seta8 
    setxy16 
    LDY #0
    LDX oampos 
load: 
    LDA [pointer], Y ; X Position
    BMI done
    CLC 
    ADC xpos
    STA OAMbuf, X
    INY 
    INX 
    
    LDA [pointer], Y ; Y Position
    CLC 
    ADC ypos
    STA OAMbuf, X
    INY 
    INX 
    
    LDA [pointer], Y ; Tile Index
    STA OAMbuf, X
    INY 
    INX 
    
    LDA [pointer], Y ; Attributes
    STA OAMbuf, X
    INY 
    INX 
    JMP load
done: 
    STX oampos  ; save position in OAM 
    setaxy16  
    RTS 
.endproc 


