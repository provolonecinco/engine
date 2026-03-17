.include "include/snes.inc"
.include "include/general.inc"
.include "include/zp.inc"
.include "include/gfx.inc"
;--------------------------------------
.segment "LORAM"
CGRAMbuf:       .res 512
;--------------------------------------
.segment "BANK0"
;--------------------------------------
.proc cgram_dma
    setaxy16
    ; Setup DMA for 512 bytes to CGRAM
    SETDMA 0, $00, CGRAMbuf, 512, CGDATA
    LDA #1
    STA COPYSTART
    RTS
.endproc
;--------------------------------------
.proc buffer_palette
    setaxy16
    LDY #0 
load:  
    LDA [pointer], Y ; assume long adressing for now
    STA CGRAMbuf, X
    INX 
    INX
    INY 
    INY 
    CPY #32 ; could make this buffer backwards for speed
    BNE load 
    RTS 
.endproc 
;--------------------------------------
.proc buffer_palette_indirect 
    setaxy16
    ; TO-DO: write the dam function yo
    RTS 
.endproc 
;--------------------------------------
.proc cgrambuf_clear
    setaxy16
    LDX #0 
clear: 
    STA CGRAMbuf, X
    INX 
    INX 
    CPX #512
    BNE clear 
    RTS
.endproc 
;--------------------------------------