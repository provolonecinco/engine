.include "include/zp.inc"
;--------------------------------------
.segment "ZEROPAGE" 
;--------------------------------------
; see zp.inc for descriptions
r0:                 .res 2
r1:                 .res 2
r2:                 .res 2
r3:                 .res 2
r4:                 .res 2
r5:                 .res 2
r6:                 .res 2
r7:                 .res 2
pointer:            .res 4
framecounter:       .res 2
joyState:           .res 2
joyPressed:         .res 2
joyHeld:            .res 2