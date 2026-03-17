.include "snes.inc"
.include "general.inc"
.include "zp.inc"

.include "gfx.inc"
;--------------------------------------
.segment "LORAM"
; OAM buffer, DMA into VRAM every VBlank
OAMbuf:         .res 512
OAMbuf_hi:      .res 32
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
.proc load_raw_tilemap ; 16bit AXY (A: VRAM location, pointer: source) 
; loads a single-screen tilemap (32x32) directly into VRAM
    setaxy16
    STA PPUADDR
    SETDMAI 0, $01, pointer, 2048, PPUDATA
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