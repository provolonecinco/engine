; Global zeropage defines
.include "zp.inc"
;--------------------------------------
.segment "ZEROPAGE" 
;--------------------------------------
; General purpose registers 
; you may clobber these
r0:                 .res 2
r1:                 .res 2
r2:                 .res 2
r3:                 .res 2
r4:                 .res 2
r5:                 .res 2
r6:                 .res 2
r7:                 .res 2
; pointers
pointer:            .res 4
; increments once per frame in NMI
framecounter:       .res 2
; controller state
joyState:           .res 2
joyPressed:         .res 2
joyHeld:            .res 2