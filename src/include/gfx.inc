; sprite.s ----------
.global oam_dma 
; Call once per frame during blank to DMA OAM
; buffer into PPU OAM 
.global buffer_sprite ; (source: pointer, xpos: r0, ypos: r1)
; load a sprite directly into the OAM buffer. 
; Metasprite definitions are terminated with $80. 
.global clear_oam
; Call once per frame before loading sprites.
; Clears entire buffer to y position $F0. 
; Resets OAM position.

; palette.s ----------
.global cgram_dma
; Call once per frame during blank to DMA 
; CGRAM buffer into PPU CGRAM 
.global buffer_palette ; (source: pointer, slot: X (see below))
; buffers a 32-byte palette directly into RAM via pointer
    PAL_0   = $00
    PAL_1   = $20
    PAL_2   = $40
    PAL_3   = $60
    PAL_4   = $80
    PAL_5   = $A0
    PAL_6   = $C0
    PAL_7   = $E0
    PAL_8   = $100
    PAL_9   = $120
    PAL_A   = $140
    PAL_B   = $160
    PAL_C   = $180
    PAL_D   = $1A0
    PAL_E   = $1C0
    PAL_F   = $1E0
.global cgrambuf_clear ; (color: A)
; clears CGRAM buffer to any given color in A.

; tilemap.s ----------
.global load_raw_tilemap ; (source: pointer, VRAM address: A)
; loads a single 2048-byte tilemap from a pointer directly 
; into VRAM at address in A.
.global load_2bpp_tiles ; (source: pointer, VRAM address: A)
; loads 256 2bpp tiles (4096 bytes) from a pointer directly
; into VRAM at address in A.
.global load_4bpp_tiles; (source: pointer, VRAM address: A)
; loads 256 4bpp tiles (8192 bytes) from a pointer directly
; into VRAM at address in A.