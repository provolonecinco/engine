.include "include/snes.inc"
.include "include/general.inc"
.include "include/zp.inc"
.include "include/math.inc"
;--------------------------------------
.segment "BANK0"
;--------------------------------------
.proc divu16 
    dividend    = r0
    divisor     = r1 ; must be non-zero    
    remainder   = r2
    setaxy16
    STZ remainder   ; remainder starts at 0
    LDX #16         ; 8 bits to process
loop:
    ASL dividend    ; top dividend bit -> carry, 0 enters bit 0
    ROL remainder   ; carry -> bottom of remainder
    BCS sub         ; 9th bit fell out, so remainder >= DEN
    LDA remainder
    CMP divisor
    BCC skip        ; remainder < DEN, quotient bit stays 0
sub:
    LDA remainder
    SBC divisor     ; carry is already set here
    STA remainder
    INC dividend    ; set quotient bit 0 (safe, it's 0 after ASL)
skip:
    DEX
    BNE loop
    RTS             ; result in r0/dividend, r2/remainder
.endproc

