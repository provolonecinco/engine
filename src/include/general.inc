; main function 
.global main

; Interrupt/Exception handlers
.global IRQ, NMI, BRK_, COP_

; ----------
; Controller Defines
; bitwise AND with controller state
JOY_SIGNATURE   = 4 << 0
KEY_R           = 1 << 4
KEY_L           = 1 << 5
KEY_X           = 1 << 6
KEY_A           = 1 << 7
KEY_RIGHT       = 1 << 8
KEY_LEFT        = 1 << 9
KEY_DOWN        = 1 << 10
KEY_UP          = 1 << 11
KEY_START       = 1 << 12
KEY_SELECT      = 1 << 13
KEY_Y           = 1 << 14
KEY_B           = 1 << 15

; CHR positions in VRAM
SPRITECHR_BASE  = $0000
BG1CHR_BASE     = $2000 ; both 4bpp layers share chr data
BG2CHR_BASE     = $2000
BG3CHR_BASE     = $4000

; Tilemap positions in VRAM
BG1MAP_BASE     = $5000
BG2MAP_BASE     = $6000
BG3MAP_BASE     = $7000

; Handy macros ----------
.macro LDPT pointer, addr
; Direct pointer load from address    
    LDA #<addr
    STA pointer
    LDA #>addr
    STA pointer + 1
    LDA #^addr
    STA pointer + 2
.endmacro

.macro LDPTI pointer, addr
; Indirect pointer load from pointer
    LDA addr
    STA pointer
    LDA addr + 1
    STA pointer + 1
    LDA addr + 2
    STA pointer + 2
.endmacro

; sets up DMA registers
.macro SETDMA channel, type, source, size, dest
    LDA #type 
    STA DMAMODE | channel << 4
    LDA #<dest
    STA DMAPPUREG | channel << 4
    LDA #<source
    STA DMAADDR | channel << 4
    LDA #>source
    STA DMAADDRHI | channel << 4
    LDA #^source
    STA DMAADDRBANK | channel << 4
    LDA #size 
    STA DMALEN | channel << 4 
.endmacro

; indrect version, takes a pointer
.macro SETDMAI channel, type, source, size, dest
    LDA #type 
    STA DMAMODE | channel << 4
    LDA #<dest
    STA DMAPPUREG | channel << 4
    LDA source
    STA DMAADDR | channel << 4
    LDA source + 2
    STA DMAADDRBANK | channel << 4
    LDA #size 
    STA DMALEN | channel << 4 
.endmacro

; make code a little more readable
.macro SET register, value
    LDA value 
    STA register
.endmacro 