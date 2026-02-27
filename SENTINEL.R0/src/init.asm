;=============================================================================
; SENTINEL system init (init.asm) [last modified: 2026-02-16]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
; init code starts here
_init:		ld sp, hl		; stack at top of RAM
		ld a, ffh		; FF = no key pressed
		ld i, a			; init I
;-----------------------------------------------------------------------------
; set 8-bit LCD interface
		ld bc, 0300h
		ld a, 30h		; 00110000b set 8-bit interface
_lcdinit8:	out (_IO_LCD_CMD), a	; send command
_lcdinit8_:	dec c			; T = 4*256 + 12*255 + 7
		jr nz, _lcdinit8_	; delay ~ 2 ms @ 2 MHz
		djnz _lcdinit8		; repeat 3 times for reliable init
;-----------------------------------------------------------------------------
; copy ROM to RAM while in ROM
		ld d, h
		ld e, l			; de = 0000
		ld b, 10h		; bc = 1000 = 4 KiB
		ldir			; copy
		ld a, 80h		; RXM = 1
		out (_IO_CONFIG), a	; disable ROM
;-----------------------------------------------------------------------------
; LCD initialization
		ld hl, _datlcd		; table
		ld b, 04h		; 4 commands to send
_lcdinit:	ld c, (hl)		; load command
		inc hl
		rst 20h			; send command to LCD
		djnz _lcdinit
;-----------------------------------------------------------------------------
		ld de, _datsentinel
		call _lcdtext0		; say hi
		rst 38h			; wait for keypress
		jr _clientry
;-----------------------------------------------------------------------------
; "SENTINEL R0"
_datsentinel:
db 1ch, 0eh, 17h, 1dh, 12h, 17h, 0eh, 15h, 24h, 1bh, 00h, ffh
;-----------------------------------------------------------------------------
; initialization data
_datlcd:
db 30h	; 00110000b: 8-bit, 1 line, 5x7 dots
db 06h	; 00000110b: address inc, no shift
db 0ch	; 00001100b: display on, cursor/blink off
db 01h	; 00000001b: clear display, address = 00h
;-----------------------------------------------------------------------------
; update LCD display [uses A, DE]
_lcdupdate:	call _lcdhome		; back to 1st display position
		ld de, _buffer
		call _lcdtext0
		ret
;-----------------------------------------------------------------------------
; load custom characters to LCD CGRAM [uses C, DE]
_lcdload:	ld c, 40h		; 01000000b CGRAM address = 00h
		rst 20h			; send command to LCD
_lcdload1:	ld a, (de)
		inc de
		call _lcdnoascii	; send data to LCD w/o ASCII conversion
		djnz _lcdload1
		ld c, 80h		; 10000000b DDRAM address = 00h
		rst 20h			; send command to LCD
		ret
;-----------------------------------------------------------------------------
; display text on LCD [uses A, B (input), DE (input)]
; call "_lcdtext" for fixed-size strings
; call "_lcdtext0" for EOS-terminated strings
_lcdtext0:	ld b, 00h		; max char count = 256
_lcdtext:	ld a, (de)
		inc de
		cp ffh			; EOS ?
		ret z
		rst 28h			; send data to LCD
		djnz _lcdtext
		ret
;=============================================================================
