
; TEXT ENGINE USAGE ----------
; Step 1:   set textptr to source text
; Step 2:   Call update_text once per frame
;           to decode each character until done
; ----------------------------

; Global Variables
.globalzp textFlags ; engine state
.globalzp textptr   ; pointer to text

; Functions ----------
.global update_text ; (source: textptr)
; call this function once every frame outside of VBlank to 
; decode a single character into the buffer. The engine will 
; automatically initialize itself the first time it's run
.global upload_text ; 
; call this every NMI to upload to CHR if needed

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
TEXT_UPLOAD     = 1 << 1    ; Set after a character has been written (0 = parse phase, 1 = upload phase)
; TEXT_NEWLINE    = 1 << 2
; TEXT_PAGE       = 1 << 3   
; TEXT_MOD_DEL    = 1 << 4    ; use modified speed instead of standard
; TEXT_WAIT_INPUT = 1 << 5
; TEXT_MUTE_SFX   = 1 << 6    ; printing SFX is enabled by default

; ----------------------------
; how it works
; 
; Writing to buffer:
;   - Track pixel position within two-tile buffer
; Step 1: write character to buffer, then look up the width and add that to the pixel position 
; Step 2: write next character to buffer. look up width and add that to pixel position
;   - if pixel position > 8, BEFORE writing next character but AFTER the tiles are written to VRAM,
;       copy tile 1 to tile 0 and clear tile 1.
;   - subtract 8 from pixel position
; Step 3: Repeat
;
; Writing to VRAM:
; Scenario 1: if pixel position in buffer <= 8, upload tile 0 to VRAM and do not increase position
; Scenario 2: if pixel position in buffer > 8, upload tile 0 and tile 1 to VRAM and increase position by 1
;
