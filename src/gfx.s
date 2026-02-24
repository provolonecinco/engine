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
    SETDMA 0, $00, OAMbuf, 544, OAMDATA
    LDA #1
    STA COPYSTART
    RTS
.endproc
;--------------------------------------
.proc load_raw_tilemap ; 16bit AXY - A = VRAM location 
    setaxy16
    STA PPUADDR
    SETDMAI 0, $01, pointer, 2048, PPUDATA
    LDA #1
    STA COPYSTART
    RTS 
.endproc