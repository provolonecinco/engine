.include "include/snes.inc"
.include "include/general.inc"
.include "include/zp.inc"

; size of text buffer, in 2bpp tiles
BUFFER_SIZE     = 2
DEFAULT_DELAY   = 2

.include "include/text.inc"
; See text.inc for usage information 
;--------------------------------------
.segment "ZEROPAGE"
textFlags:  .res 2 ; text engine status
textptr:    .res 4 ; source text address
fontptr:    .res 4 ; font to reference
;--------------------------------------
.segment "LORAM"
; reserve buffer in work ram
delay:      .res 2
timer:      .res 2 
pixel:      .res 2 ; pixel position in two-tile buffer, aka shift amount
vramBase:   .res 2 ; VRAM pointer for base tile address
vramPos:    .res 2 ; VRAM pointer for moving tile address
; canvas data 
width:      .res 2 ; how many tiles wide can we print
height:     .res 2 ; how many rows can we print
column:     .res 2 ; current tile 
row:        .res 2 ; current row
tilemapBase:.res 2 ; pointer to top right corner of canvas
buffer:     .res 16 * BUFFER_SIZE
;--------------------------------------
.segment "BANK0"
;--------------------------------------
.proc update_text ; entrypoint
    setaxy16
    ; if engine is already active, skip initialization
    LDA textFlags
    AND #TEXT_ACTIVE
    BNE skip_init
    JSR init
skip_init:

    ; check if the timer's out
    ; if so, then yeah
    DEC timer 
    BNE done 
    LDA delay
    STA timer

    ; before parsing the next character:
    ; Step 1: If pixel position >= 8, copy tile 1 into tile 0
    ; Step 2: Clear tile 1
    ; Step 3: Subtract 8 from pixel position
    LDA pixel
    CMP #8 
    BCC skip_reset
    LDX #16
    reset:
        LDA buffer + 16, X 
        STA buffer, X 
        STZ buffer + 16, X
        DEX 
        DEX 
        BPL reset

        LDA pixel
        SEC 
        SBC #8
        STA pixel    
skip_reset:

    JMP parse
done: 
    ; back to the ol ball and chain
    setaxy16 
    RTS 
.endproc
;--------------------------------------
.proc init ; local function
; X and Y contain the tilemap position to print to (top left corner) 
    setaxy16

    ; advance row(s) if Y != 0
    TYA 
    BEQ get_xpos
    LDA #0
get_ypos:
    CLC 
    ADC #32
    DEY 
    BNE get_ypos
get_xpos:
    ; shift x position by two to get byte position 
    STX r0 
    CLC 
    ADC r0 
    CLC 
    ADC #BG3MAP_BASE
    STA tilemapBase

    ; reset pixel position 
    STZ pixel

    ; zero out these
    STZ column
    STZ row 

    ; leave the first tile blank
    LDA #BG3CHR_BASE
    STA vramBase
    LDA #8
    STA vramPos

    ; initial delay 
    LDA #DEFAULT_DELAY
    STA delay
    STA timer

    ; set engine status
    LDA textFlags
    ORA #TEXT_ACTIVE
    STA textFlags
    RTS
.endproc 
;--------------------------------------
.proc parse ; local function 
get_byte:
    seta8
    LDA [textptr] 
    BMI opcode  ; handle opcode if neg flag set

    JMP copy_tile ; copy tile into buffer
done: 
    ; add width to move pixel position
    setaxy8
    LDA [textptr]
    TAX 
    LDA sample_widths, X
    CLC 
    ADC pixel
    STA pixel

    ; buffer is ready to be uploaded
    LDA textFlags
    ORA #TEXT_UPLOAD
    STA textFlags

    setaxy16 
    INC textptr
    ; all done with this iteration
    JMP update_text::done
.endproc 
;--------------------------------------
.proc copy_tile ; local function 
; get tile from CHR data, shift by determined
; amount, and paste into buffer
scratch = r1 ; scratchpad for rotating bitplanes
    ; A contains the ASCII char index. 
    ; multiply by 16 to get the tile data
    seta16
    ASL 
    ASL 
    ASL 
    ASL     
    TAX 
    LDY #0
copy:
    seta8
    LDA sample_font, X  ; one bitplane at a time
    STA scratch
    ; preserve index. Skip rotating
    ; if we're at the beginning of
    ; tile 0
    PHX                 
    LDX pixel        
    BEQ paste
    ; Rotate bitplane to the pixel
    ; position within the buffer
    shift_char:         
        LSR scratch              
        ROR scratch + 1 
        DEX 
        BNE shift_char
paste:
    ; first bitplane 
    LDA scratch
    ORA buffer, Y
    STA buffer, Y
    ; second bitplane
    ; hard store so we can clear the 
    ; leading edge for the next char #tbh
    LDA scratch + 1
    ORA buffer + 16, Y
    STA buffer + 16, Y
    
    ; clear our scratchpad
    STZ scratch     
    STZ scratch + 1

    ; restore index. If we haven't 
    ; copied all 16 bytes yet, run it back
    PLX                 
    INX
    INY
    CPY #16             
    BNE copy
 done:
    JMP parse::done
.endproc 
; OPCODES -----------------------------
jump:   ; jump table for opcodes
    .addr opcode_eot, opcode_nl
;--------------------------------------
.proc opcode ; local function 
    seta16 
    LDX #0
    ; mask out the index 
    AND #$000F 
    ASL 
    TAX 
    ; yippee 
    LDA jump, X 
    STA pointer 
    JMP (pointer)
.endproc 
;--------------------------------------
.proc upload_text ; local function
; uploads one or two tiles to VRAM at vramBase + vramPos
    setaxy16 

    LDA textFlags
    AND #TEXT_UPLOAD
    BEQ done

    ; tile 0 will ALWAYS be uploaded, regardless.
    ; Do that first
    SET VMAIN, #INC_DATAHI
    LDA vramBase
    CLC 
    ADC vramPos
    STA PPUADDR
    LDX #0  
copy1:
    LDA buffer, X 
    STA PPUDATA
    INX 
    INX 
    CPX #16
    BNE copy1

    ; if pixel position is greater
    ; than or equal to 8:
    ; Step 1: Write tile 2
    ; Step 2: increase vramPos by 16
    LDA pixel
    CMP #8 
    BCC skip_copy2
copy2: 
    LDA buffer, X 
    STA PPUDATA 
    INX 
    INX 
    CPX #32 
    BNE copy2

    LDA vramPos
    CLC 
    ADC #8
    STA vramPos

    ; advance tilemap position
    INC column
skip_copy2:



write_tilemap: 
    LDA tilemapBase

    LDY row 
    BEQ skip_row 
get_row:
    CLC 
    ADC #32
    DEY
    BNE get_row 
skip_row: 
    CLC 
    ADC column 
    STA PPUADDR

    ; get current tile ID 
    LDA vramPos
    LSR 
    LSR 
    LSR 
    STA PPUDATA 

    ; clear upload flag
    LDA textFlags
    EOR #TEXT_UPLOAD
    STA textFlags
done:
    RTS  
.endproc 
;--------------------------------------
.proc opcode_eot ; End of Text
; Clear active status and exit
    LDA textFlags
    EOR #TEXT_ACTIVE
    STA textFlags
    JMP update_text::done
.endproc
;--------------------------------------
.proc opcode_nl ; newline
    setaxy16 
    STZ column
    INC row 

    ; reset pixel position and clear buffer 
    STZ pixel
    LDX #32 
clear:
    STZ buffer, X 
    DEX 
    DEX
    BPL clear 

    ; advance vrampos to the next tile 
    LDA vramPos
    CLC 
    ADC #8
    STA vramPos

    INC textptr
    JMP update_text::done
.endproc 
;--------------------------------------

sample_widths: 
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 6, 5, 4, 7, 6, 6, 8, 3, 5, 5, 6, 6, 3, 6, 3, 7
    .byte 6, 4, 6, 6, 6, 6, 6, 6, 6, 6, 4, 4, 6, 6, 6, 6
    .byte 7, 6, 6, 6, 6, 6, 6, 6, 6, 5, 6, 6, 5, 6, 6, 6
    .byte 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 4, 5, 5, 6
    .byte 3, 6, 5, 5, 5, 5, 6, 6, 5, 3, 6, 5, 3, 6, 5, 5
    .byte 5, 5, 5, 6, 5, 6, 5, 6, 5, 5, 5, 6, 3, 6, 8, 0
sample_font:
    .incbin "chr/font.chr"