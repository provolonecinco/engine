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
source:     .res 4 ; source text address
fontptr:    .res 4 ; font to reference
shift:      .res 2 ; shift amount
;--------------------------------------
.segment "LORAM"
; reserve buffer in work ram
buffer:     .res 16 * BUFFER_SIZE
index:      .res 2 ; index into source text
;--------------------------------------
.segment "BANK0"
;--------------------------------------
.proc queue_text
    setaxy16
    
    LDPTI source, pointer ; copy pointer into engine state
    STZ index ; reset index 
    LDA #4
    STA shift

    RTS
.endproc 
;--------------------------------------
.proc update_text
; it's possible this function is completely unnecessary but only exists
; just in case I need to set up state or do checks before actually parsing
    setaxy16

    ; the game has to set the active flag before we can 
    ; start parsing. check it and skip if not
    LDA textFlags
    AND #TEXT_ACTIVE
    BEQ done

    JMP parse
done: 
    ; back to the ol ball and chain
    setaxy16 
    RTS 
.endproc
;--------------------------------------
.proc parse ; local function 
    seta8 
    LDY index  ; restore index and grab next byte
get_byte:
    LDA [source], Y 
    BMI opcode  ; handle opcode if neg flag set

    JMP copy_tile ; copy tile into buffer
done: 
    INY 
    STY index ; preserve index + 1
    setaxy16 
    ; all done with this iteration
    JMP update_text::done
.endproc 

.proc copy_tile ; local function 
; get tile from CHR data, shift by determined
; amount, and paste into buffer
    PHY ; preserve 16-bit index 
    LDY #0
; A contains the ASCII char index
    seta16
    STZ r1
    STZ r1 + 1
    ASL 
    ASL 
    ASL 
    ASL     ; multiply by 16 to get tile index
    TAX 
copy_tile:
    seta8
    LDA sample_font, X ; one bitplane at a time
    STA r1
    PHX                 ; preserve 16-bit X
    LDX shift 
    BEQ paste

    shift_char:
    LSR r1              ; rotation
    ROR r1 + 1 
    DEX 
    BNE shift_char
    PLX 
paste:
    LDA r1
    ORA buffer, Y
    STA buffer, Y
    LDA r1 + 1
    ORA buffer + 16, Y
    STA buffer + 16, Y
    INY  
    INX 
    CPY #16
    BNE copy_tile

    PLY ; restore index 
    JMP parse::done
.endproc 

; OPCODES -----------------------------
jump:   ; jump table for opcodes
    .addr opcode_eot
;--------------------------------------
.proc opcode
    seta8 
    LDX #0
    ; filter out upper bits to get index  
    AND #$0F 
    ASL 
    TAX 
    ; get address 
    LDA jump, X 
    STA pointer 
    LDA jump + 1, X 
    STA pointer + 1
    ; booyah
    JMP (pointer)
.endproc 
;--------------------------------------
.proc opcode_eot 
    ; clear active flag
    LDA textFlags
    EOR #TEXT_ACTIVE
    STA textFlags

    JMP update_text::done
.endproc 

sample_font:
    .incbin "chr/font.chr"