.include "snes.inc"
.include "general.inc"
.include "zp.inc"

.include "gfx.inc"
;--------------------------------------
.segment "BANK0"
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
.proc load_2bpp_tiles ; 16bit AXY (A: VRAM location, pointer: source) 
; loads 256 2bpp tiles into VRAM 
    setaxy16
    STA PPUADDR
    SETDMAI 0, $01, pointer, 4096, PPUDATA
    LDA #1
    STA COPYSTART
    RTS 
.endproc 
;--------------------------------------
.proc load_4bpp_tiles ; 16bit AXY (A: VRAM location, pointer: source) 
; loads 256 4bpp tiles into VRAM 
    setaxy16
    STA PPUADDR
    SETDMAI 0, $01, pointer, 8192, PPUDATA
    LDA #1
    STA COPYSTART
    RTS 
.endproc 
;--------------------------------------
