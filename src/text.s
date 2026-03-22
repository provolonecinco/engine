.include "include/snes.inc"
.include "include/general.inc"
.include "include/zp.inc"

; size of text buffer, in 2bpp tiles
BUFFER_SIZE     = 2
DELAY           = 2

.include "include/text.inc"
; See text.inc for usage information 
;--------------------------------------
.segment "ZEROPAGE"
textFlags:  .res 2 ; text engine status
textptr:    .res 4 ; source text address
fontptr:    .res 4 ; font to reference
pixelPos:   .res 2 ; pixel position in two-tile buffer, aka shift amount
vramBase:   .res 2 ; VRAM pointer for base tile address
vramPos:    .res 2 ; VRAM pointer for moving tile address
timer:      .res 2 
;--------------------------------------
.segment "LORAM"
; reserve buffer in work ram
.align 16 ; aligning means I can see it in the tile viewer easier
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

    DEC timer 
    BNE done 
    LDA #DELAY
    STA timer


    ; before parsing the next character:
    ; Step 1: If pixel position >= 8, copy tile 1 into tile 0
    ; Step 2: Clear tile 1
    ; Step 3: Subtract 8 from pixel position
    LDA pixelPos
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

        LDA pixelPos
        SEC 
        SBC #8
        STA pixelPos    
skip_reset:

    JMP parse
done: 
    ; back to the ol ball and chain
    setaxy16 
    RTS 
.endproc
;--------------------------------------
.proc init ; local function
; initialize the text engine with whatever I guess
    setaxy16

    STZ pixelPos

    LDA #BG3CHR_BASE + 8
    STA vramBase
    STZ vramPos

    LDA #DELAY
    STA timer
    ; HERE: idk

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
    ; copy width for the tile we just pasted
    setaxy8
    LDA [textptr]
    TAX 
    LDA sample_widths, X
    CLC 
    ADC pixelPos
    STA pixelPos

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
    LDX pixelPos        
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
    .addr opcode_eot
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
    LDA pixelPos
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
skip_copy2:

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