.include "include/snes.inc"
.include "include/general.inc"
.include "include/zp.inc"

; size of text buffer, in 2bpp tiles
BUFFER_SIZE     = 2

.include "include/text.inc"
; See text.inc for usage information 
;--------------------------------------
.segment "ZEROPAGE"
textFlags:  .res 2 ; text engine status
textptr:    .res 4 ; source text address
fontptr:    .res 4 ; font to reference
shift:      .res 2 ; shift amount
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

    STZ shift

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
    LDA #5
    STA shift

    seta16 
    INC textptr
    ; all done with this iteration
    JMP update_text::done
.endproc 
;--------------------------------------
.proc copy_tile ; local function 
; get tile from CHR data, shift by determined
; amount, and paste into buffer
    LDY #0
    ; A contains the ASCII char index. 
    ; multiply by 16 to get the tile data
    seta16
    ASL 
    ASL 
    ASL 
    ASL     
    TAX 
copy:
    seta8
    LDA sample_font, X  ; one bitplane at a time
    STA r1
    PHX                 ; preserve index
    LDX shift 
    BEQ paste

    shift_char:         ; rotate bitplane
    LSR r1              
    ROR r1 + 1 
    DEX 
    BNE shift_char
paste:
    ; first bitplane 
    LDA r1
    ORA buffer, Y
    STA buffer, Y
    ; second bitplane
    ; hard store so we can clear the 
    ; leading edge for the next char #tbh
    LDA r1 + 1
    STA buffer + 16, Y
    
    STZ r1              ; clear our scratchpad
    STZ r1 + 1

    PLX                 ; restore index
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
.proc opcode_eot ; End of Text
; Clear active status and exit
    LDA textFlags
    EOR #TEXT_ACTIVE
    STA textFlags
    JMP update_text::done
.endproc
;--------------------------------------
sample_font:
    .incbin "chr/font.chr"