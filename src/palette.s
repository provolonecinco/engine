.include "snes.inc"
.include "general.inc"
.include "zp.inc"
.include "gfx.inc"
;--------------------------------------
.segment "LORAM"
; palette buffer
CGRAMbuf:       .res 512
;--------------------------------------
.segment "BANK0"
;--------------------------------------
.proc cgram_dma ; 16bit AXY
    setaxy16
    ; Setup DMA for 512 bytes to CGRAM
    SETDMA 0, $00, CGRAMbuf, 512, CGDATA
    LDA #1
    STA COPYSTART
    RTS
.endproc
;--------------------------------------
.proc buffer_palette ; 16-bit AXY (X: CGRAM Index, pointer: source)
; buffers a 32-byte (16 color) palette from a pointer
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
.proc buffer_palette_indirect ; 16-bit AXY
; buffers a palette from the palette table 
    setaxy16
    ; TO-DO: write the dam function yo
    RTS 
.endproc 
;--------------------------------------
.proc cgrambuf_clear ;16-bit AXY
; Clears the entire CGRAM buffer
    setaxy16
    LDX #0 
clear: 
    STZ CGRAMbuf, X
    INX 
    INX 
    CPX #512
    BNE clear 
    RTS
.endproc 
;--------------------------------------