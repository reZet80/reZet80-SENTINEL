;=============================================================================
; SENTINEL ASCII conversion (ascii.asm) [last modified: 2026-02-17]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
; convert SENTINEL char encoding to ASCII [uses A, preserves HL]
_ascii:		cp 0ah			; 0 - 9
		jr nc, _ascii1
		add 30h
		ret
_ascii1:	cp 24h			; A - Z
		jr nc, _ascii2
		add 37h
		ret
_ascii2:	cp 34h			; ' ' - '/'
		jr nc, _ascii3
		sub 04h
		ret
_ascii3:	cp 3bh			; ':' - '@'
		jr nc, _ascii4
		add 06h
		ret
_ascii4:	cp 40h
		jr nc, _ascii5
		sub 3bh			; '[' - '|'
		push hl
		ld hl, _datascii
		add a, l
		ld l, a
		ld a, (hl)
		pop hl
		ret
_ascii5:	sub 40h			; custom characters
		ret
;-----------------------------------------------------------------------------
_datascii:
db 5bh, 5ch, 5dh, 5fh, 7ch
;=============================================================================
