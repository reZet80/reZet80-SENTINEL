;=============================================================================
; SENTINEL system init (init.asm) [last modified: 2026-06-28]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
; after init: 41-char buffer incl EOS (0080-00A8)
_buffer:	
; init code starts here
_init:		ld bc, 0300h		; set 8-bit LCD interface
		ld a, 30h		; 00110000b set 8-bit interface
_lcdinit8:	out (_IO_LCD_CMD), a	; send command
_lcdinit8_:	dec c			; T = 4*256 + 12*255 + 7
		jr nz, _lcdinit8_	; delay ~ 2 ms @ 2 MHz
		djnz _lcdinit8		; repeat 3 times for reliable init
;-----------------------------------------------------------------------------
		ld hl, 0000h		; copy ROM to RAM while in ROM
		ld d, h
		ld e, l			; de = 0000
		ld b, 10h		; bc = 1000 = 4 KiB = 16 chunks
		ldir			; copy
		ld a, 81h		; RAMSEL = 1, A15SEL = 1, A16SEL = 0
		out (_IO_CONFIG), a	; disable ROM, high RAM = bank 1
;-----------------------------------------------------------------------------
		ld hl, _datlcdinit	; LCD initialization
		ld b, 04h		; 4 commands to send
_lcdinit:	ld c, (hl)		; load command
		inc hl
		rst 20h			; send command to LCD
		djnz _lcdinit
;-----------------------------------------------------------------------------
		ld sp, 8000h		; stack
;-----------------------------------------------------------------------------
		ld de, _datrcc
		ld b, 30h		; send 48 bytes (6 chars)
		call _lcdload		; load custom characters to LCD CGRAM
;-----------------------------------------------------------------------------
		ld de, _datsentinel
		call _lcdtext0		; say hi
		rst 38h			; wait for keypress
		jr _clientry
;-----------------------------------------------------------------------------
_datsentinel:
; "reZet80 SENTINEL"
db 5ah, 5bh, 5ch, 5bh, 5dh, 5eh, 5fh, 24h
db 1ch, 0eh, 17h, 1dh, 12h, 17h, 0eh, 15h, ffh
;-----------------------------------------------------------------------------
; LCD initialization data
_datlcdinit:
if _LCD_40x1
db 30h	; 00110000b 8-bit, 1 line, 5x7 dots
elseif _LCD_16x2
db 38h	; 00111000b 8-bit, 2 lines, 5x7 dots
else
db 30h	; 00110000b 8-bit, 1 line, 5x7 dots
endif
db 06h	; 00000110b: address inc, no shift
db 0ch	; 00001100b: display on, cursor/blink off
db 01h	; 00000001b: clear display, address = 00h
;-----------------------------------------------------------------------------
; LCD line addresses
_datlcd:
if _LCD_16x2
db 00h, 40h
endif
;=============================================================================
