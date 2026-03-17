.include "snes.inc"
.include "general.inc"
.include "zp.inc"
.include "gfx.inc"
;--------------------------------------
.segment "ZEROPAGE"
; oam position resets to 0 every frame
oampos:         .res 2
;--------------------------------------
.segment "LORAM"
; OAM buffer, DMA into VRAM every VBlank
OAMbuf:         .res 512
OAMbuf_hi:      .res 3
;--------------------------------------
.segment "BANK0"
;--------------------------------------
.proc oam_dma ; 16bit AXY
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
.proc clear_oam ; 16-bit AXY
; hides all sprites to prepare for frame
; we're handcrafting OAM the old fashioned way
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
.proc buffer_sprite ; 8-bit A, 16-bit XY
; pointer: source
; r0: x position 
; r1: y position
; buffers a sprite directly into OAMbuf
; terminated with a $80 byte
    seta8 
    setxy16 
    LDY #0
    LDX oampos 
load: 
    LDA [pointer], Y ; X Position
    BMI done
    CLC 
    ADC r0
    STA OAMbuf, X
    INY 
    INX 
    
    LDA [pointer], Y ; Y Position
    CLC 
    ADC r1
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


