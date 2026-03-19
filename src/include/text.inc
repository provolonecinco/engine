
; TEXT ENGINE USAGE ----------
; Step 1: set pointer to source text
; Step 2: Call queue_text
; Step 3: set active flag to signal engine.
;   update_text has a check for this and
;   will not run otherwise!!
;       LDA textFlags
;       ORA #TEXT_ACTIVE
;       STA textFlags
; ----------------------------

; Global Variables
.globalzp textFlags ; engine state

; Functions ----------
.global queue_text ; (source: pointer)
; initializes text engine
.global update_text 
; parses next character in source text,
; writes it to buffer. decodes one
; character per frame. 

; TODO: add flag to forego delay and 
; render text all at once, maybe into
; larger buffers

; OPCODES ----------
.scope TXT 
END		        =	$F0     ; End of text
; NL          	=	$F1     ; Force newline
; PAGE		    =	$F2     ; Force Page
; SFX		    =	$F3	    ; Play Sound Effect     (byte 1 = opcode, byte 2 = SFX #)
; SPD         	=	$F4     ; Change Speed          (byte 1 = opcode, byte 2 = speed (if zero, use unmodified speed and di))
; PIC         	=	$F5     ; Swap Portrait Bank    (byte 1 = opcode, byte 2 = portrait #)
; MUTE          =   $F6     ; Mute Printing SFX
; UNMUTE        =   $F7     ; Unmute Printing SFX
.endscope 
; FLAGS ----------
TEXT_ACTIVE     = 1 << 0    ; Engine active? (0 = inactive, 1 = active)
; TEXT_READY      = 1 << 1
; TEXT_NEWLINE    = 1 << 2
; TEXT_PAGE       = 1 << 3   
; TEXT_MOD_DEL    = 1 << 4    ; use modified speed instead of standard
; TEXT_WAIT_INPUT = 1 << 5
; TEXT_MUTE_SFX   = 1 << 6    ; printing SFX is enabled by default