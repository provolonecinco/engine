; Global Variables

; General purpose registers 
; you may clobber these
.globalzp r0, r1, r2, r3, r4, r5, r6, r7

; Generic pointer
.globalzp pointer

; increments once per frame in NMI. 
; Signals main loop to continue program 
.globalzp framecounter

; Updates once per frame in NMI. 
.globalzp joyState      ; state of controller at any given time
.globalzp joyPressed    ; Newly pressed buttons this frame
.globalzp joyHeld       ; Buttons held for >=1 frame(s)