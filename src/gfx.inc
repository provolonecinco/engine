; RAM symbols (global for now idk if they should be)
.global OAMbuf, OAMbuf_hi

; functions 
.global oam_dma
.global cgram_dma
.global load_raw_tilemap
.global buffer_palette
.global cgrambuf_clear
.global load_2bpp_tiles
.global load_4bpp_tiles
.global buffer_sprite
.global clear_oam

; palette slot references
PAL_0   = $00
PAL_1   = $20
PAL_2   = $40
PAL_3   = $60
PAL_4   = $80
PAL_5   = $A0
PAL_6   = $C0
PAL_7   = $E0
;------------
PAL_8   = $100
PAL_9   = $120
PAL_A   = $140
PAL_B   = $160
PAL_C   = $180
PAL_D   = $1A0
PAL_E   = $1C0
PAL_F   = $1E0