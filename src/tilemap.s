.include "include/snes.inc"
.include "include/general.inc"
.include "include/zp.inc"

.include "include/gfx.inc"
;--------------------------------------
.segment "BANK0"
;--------------------------------------
.proc load_raw_tilemap
    setaxy16
    STA PPUADDR
    SETDMAI 0, $01, pointer, 2048, PPUDATA
    LDA #1
    STA COPYSTART
    RTS 
.endproc
;--------------------------------------
.proc load_2bpp_tiles
    setaxy16
    STA PPUADDR
    SETDMAI 0, $01, pointer, 4096, PPUDATA
    LDA #1
    STA COPYSTART
    RTS 
.endproc 
;--------------------------------------
.proc load_4bpp_tiles
    setaxy16
    STA PPUADDR
    SETDMAI 0, $01, pointer, 8192, PPUDATA
    LDA #1
    STA COPYSTART
    RTS 
.endproc 
;--------------------------------------
