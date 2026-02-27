;=============================================================================
; SENTINEL Hex Man (hm.asm) [last modified: 2026-02-19]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
_hmentry:	ld de, _dathm
		call _lcdtext0		; welcome
		rst 38h			; wait for keypress
_hm0:		ld iyh, 06h		; iyh = 6 tries
		ld ixl, 00h		; ixl = total correct guesses
		call _clrbuf		; clear buffer
		ld b, 06h
		ld hl, 008ah
_hm1:		ld (hl), 27h		; 6x '#'
		inc hl
		djnz _hm1
		ld a, r			; random refresh register
		and 07h			; 8 hex numbers max
		ld b, a
		inc b
		ld iyl, b		; iyl = word length
		ld de, _buffer		; use as display buffer
		ld hl, 0091h		; hex numbers to guess
_hm2:		ld a, 3eh		; '_'
		ld (de), a
		inc de
		ld a, r			; random refresh register
		and 0fh			; 0 - F
		ld (hl), a
		inc hl
		djnz _hm2
_hm3:		call _lcdupdate		; update game display
_hm4:		rst 38h			; wait for any key
		cp 10h			; accept only 0 - F
		jr nc, _hm4
		ld c, a			; guessed hex number
		ld b, iyl
		ld hl, 0091h		; hex numbers to guess
		ld de, _buffer
		ld ixh, 00h		; ixh = correct guesses this turn
_hm5:		cp (hl)
		jr nz, _hm6
		inc ixl
		inc ixh
		ld (hl), 24h		; guessed correctly
		ld (de), a		; display correct guess
_hm6:		inc hl
		inc de
		djnz _hm5		; check all numbers
		xor a
		cp ixh			; correct guess ?
		jr z, _hm7
		ld a, ixl
		cp iyl			; won ?
		jr nz, _hm3
		ld hl, _dathmw		; game over won
		jr _hm9
_hm7:		ld b, 06h		; 6 incorrect guesses max
		ld hl, 008ah		; position of 1st "#"
_hm8:		ld a, 27h		; "#"
		cp (hl)
		jr nz, _hm10
		ld a, c
		ld (hl), a
		dec iyh
		jr nz, _hm3
		ld hl, _dathml		; game over lost
_hm9:		ld de, 008ah
		ld bc, 0006h
		ldir			; display winner or loser
		call _lcdupdate		; update game display
		rst 38h			; wait for key press
		cp 82h			; ESC ?
		jp z, _clientry		; back to CLI
		jp _hm0			; new game
_hm10:		inc hl
		djnz _hm8		; shall always find an empty slot
;-----------------------------------------------------------------------------
_dathm:
; "HEX MAN"
db 11h, 0eh, 21h, 24h, 16h, 0ah, 17h, ffh
;-----------------------------------------------------------------------------
_dathmw:
; "WINNER"
db 20h, 12h, 17h, 17h, 0eh, 1bh
_dathml:
; "LOSER "
db 15h, 18h, 1ch, 0eh, 1bh, 24h
;=============================================================================
