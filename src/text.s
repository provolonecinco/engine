.include "include/snes.inc"
.include "include/general.inc"
.include "include/zp.inc"

; size of text buffer, in 2bpp tiles
BUFFER_SIZE     = 16

.include "include/text.inc"
; See text.inc for usage information 
;--------------------------------------
.segment "ZEROPAGE"
textFlags:  .res 2 ; text engine status
source:     .res 4 ; source text address
fontptr:    .res 4 ; font to reference
;--------------------------------------
.segment "LORAM"
; reserve buffer in work ram
buffer:     .res 32 * BUFFER_SIZE
index:      .res 2 ; index into source text
;--------------------------------------
.segment "BANK0"
;--------------------------------------
.proc queue_text
    setaxy16
    
    LDPTI source, pointer ; copy pointer into engine state
    STZ index ; reset index 

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

    STA buffer, Y ; temporary: copy text into buffer so we know it works
    
    ; HERE: we know it's a character, so we need to 
    ; get the tile data from fontptr, and paste it into 
    ; our buffer

    ; ALSO: before we can do that, make sure to check we have 
    ; enough space to even print the character. run ahead
    ; to find the next space and if the total width exceeds
    ; the space in the buffer, clear the buffer and return carriage

    INY 
    STY index ; preserve index + 1
    setaxy16 
    ; all done with this iteration
    JMP update_text::done
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