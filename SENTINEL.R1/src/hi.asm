;=============================================================================
; SENTINEL Hex Invaders (hi.asm) [last modified: 2026-05-23]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
_hientry:	ld de, _dathi
		call _lcdtext0		; welcome
		rst 38h			; wait for keypress
_hi0:		rst 18h			; clear display
		ld de, _dathire
		call _lcdtext0		; choose skill level
		ld a, 01h		; external CLI call
		call _cli
		ld l, 81h		; 1st buffer entry
		ld a, (hl)
		cp 02h
		jr nc, _hi0		; '0' or '1' expected
		ld iyl, a		; IYL = rookie (0) | expert (1)
		rst 18h			; clear display
		call _clrbuf 		; clear buffer
		ld hl, 0080h		; use as display buffer
		ld (hl), 03h		; '3'
		inc hl
		xor a
		ld (hl), a		; '0'
		inc hl
		ld (hl), 27h		; '#'
		ld l, 8ch
		ld (hl), a		; "0000"
		inc hl
		ld (hl), a 
		inc hl
		ld (hl), a
		inc hl
		ld (hl), a
		call _lcdupdate		; update game display
		ld ix, 8000h		; ix = invaders speed
_hi1:		ld hl, 0083h		; 1st invader position
		ld de, 0082h		; base position
		push de
		ld bc, 0008h
		ldir			; move invaders
		pop hl
		ld a, 24h
		cp (hl)			; base hit ?
		jr z, _hi4		; no
		ld l, 80h		; leftmost invader hit our base
		dec (hl)		; base--
		call _lcdupdate		; update game display
		xor a
		cp (hl)
		jr z, _hi3		; game over ?
		ld l, 81h
		ld (hl), a		; start with hex '0' again
		ld l, 83h
		ld b, 08h
_hi2:		ld (hl), 24h		; 8x ' '
		inc hl
		djnz _hi2		; empty all invaders
		jr _hi1			; continue game
_hi3:		ld hl, _dathigo		; game over
		ld de, 0081h
		ld bc, 000ah
		ldir
		call _lcdupdate		; update game display    
		rst 38h			; wait for any key
		cp 82h			; ESC ?
		jp z, _clientry		; back to CLI
		jr _hi0			; start new game
_hi4:		ld (hl), 27h		; write back base
		ld a, r			; random refresh register
		and 0fh			; 0-F
		ld e, 8ah		; last invader position
		ld (de), a		; insert new invader
		call _lcdupdate
		dec ix			; increase invaders speed
		ld b, ixh
		ld c, ixl
_hi5:		push bc
		ld l, 81h		; gun number
		call _iskey		; check if key pressed
		cp 80h			; ENTER ?
		jr nz, _hi12
		ld c, (hl)		; get current gun number
		ld b, 08h		; 8 invaders to check
		inc hl
_hi6:		inc hl			; invader position
		ld a, (hl)
		cp 24h
		jr z, _hi11		; ignore empty
		xor a
		or iyl
		jr z, _hi7
		ld b, 01h		; only one loop
		ld a, c
		cp (hl)
		jr z, _hi8
		jr _hi13
_hi7:		ld a, c
		cp (hl)
		jr nz, _hi11
_hi8:		ld de, 008fh		; rightmost score digit
		push af
		push bc
		add a, (hl)		; add invader score
		ld (hl), 24h		; hit invader
		ex de, hl
		ld (hl), a		; save new score
		cp 10h
		jr c, _hi10		; < 10h ?
		sub a, 10h
		ld (hl), a		; save new score - 10h
		ld a, 10h
		ld b, 03h		; 3 digits max to change
_hi9:		dec hl			; next score digit
		inc (hl)		; score digit +1
		cp (hl)
		jr nz, _hi10		; < 10h ?
		ld (hl), 00h		; roll over score digit
		djnz _hi9
_hi10:		ex de, hl
		pop bc
		pop af
_hi11:		djnz _hi6
		jr _hi13
_hi12:		cp 81h			; BACK ?
		jr nz, _hi14
		inc (hl)		; inc gun number
		ld a, 10h		; gun number past F ?
		cp (hl)
		jr nz, _hi13
		ld (hl), 00h		; roll over gun number to 0
_hi13:		call _lcdupdate		; update game display
_hi14:		pop bc
		dec bc
		ld a, b
		or c			; delay
		jr nz, _hi5		; inner loop
		jp _hi1			; outer loop
;-----------------------------------------------------------------------------
_dathi:
; "HEX INVADERS"
db 11h, 0eh, 21h, 24h, 12h, 17h, 1fh, 0ah, 0dh, 0eh, 1bh, 1ch, ffh
;-----------------------------------------------------------------------------
_dathigo:
; " GAME OVER"
db 24h, 10h, 0ah, 16h, 0eh, 24h, 18h, 1fh, 0eh, 1bh
;-----------------------------------------------------------------------------
_dathire:
; "Please select:[ENTER]"
; "0 = rookie[ENTER]"
; "1 = expert"
db 19h, 4bh, 44h, 40h, 52h, 44h, 24h, 52h, 44h, 4bh, 44h, 42h, 53h, 34h, 80h
db 00h, 24h, 37h, 24h, 51h, 4eh, 4eh, 4ah, 48h, 44h, 80h
db 01h, 24h, 37h, 24h, 44h, 57h, 4fh, 44h, 51h, 53h, 80h, ffh
;-----------------------------------------------------------------------------
; CHANGES:
; - R1: added rookie/expert mode, minor changes
;=============================================================================
