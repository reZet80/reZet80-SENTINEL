;=============================================================================
; SENTINEL Asteroid Belt (ab.asm) [last modified: 2026-02-19]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
_abentry:	ld de, _datab
		call _lcdtext0		; welcome
		ld de, _databcc
		ld b, 38h		; send 56 bytes (7 chars)
		call _lcdload		; load custom characters to LCD CGRAM
		rst 38h			; wait for keypress
_ab0:		rst 18h			; clear display
		call _clrbuf 		; clear buffer
		ld hl, _buffer 		; use as display buffer
		ld (hl), 31h		; player (ASCII 2D)
		ld l, 8dh
		xor a
		ld (hl), a		; score
		inc hl
		ld (hl), a
		inc hl
		ld (hl), a
		call _lcdupdate		; update game display
		ld iyl, 31h		; iyl = player
		ld ix, 0700h		; ix = asteroids speed
_ab1:		ld hl, 0081h
		ld de, 0080h		; player location
		ld a, (de)
		push de
		ld bc, 000bh		; 11 asteroids max
		ldir			; move asteroids
		pop hl
		ld b, a			; save player
		ld a, (hl) 
		ld c, a			; save asteroid type | empty
		cp 24h			; player hit ?
		jr nz, _ab5		; maybe hit
		;TODO code
		ld a, b
		cp 43h			; asteroid top + player bottom ?
		jr nz, _ab2
		ld b, 3eh		; remove asteroid
		jr _ab4
_ab2:		cp 44h			; player center + belt ?
		jr nz, _ab3
		ld b, 31h		; remove belt
		jr _ab4
_ab3:		cp 45h			; player top + asteroid bottom ?
		jr nz, _ab4
		inc b			; remove asteroid
_ab4:		ld (hl), b		; write back player
		jr _ab8
_ab5:		sub 40h
		ld c, a
		ld de, _databhit
		add a, e
		ld e, a
		ld a, (de)		; pos player should be
		cp iyl			; check if hit
		jr z, _ab6		; player dodged
		;TODO hit animation
		ld hl, _databgo		; player hit
		ld de, 0081h
		ld bc, 000bh
		ldir			; game over
		call _lcdupdate		; update game display
		rst 38h			; wait for any key
		cp 82h			; ESC ?
		jp z, _clientry		; back to CLI
		jr _ab0			; next try
_ab6:		ld a, 43h
		add c
		ld (hl), a		; show player + asteroid
		ld l, 90h		; update score
		ld a, 10h
		ld b, 03h		; 3 digits max to change
_ab7:		dec hl			; next score digit
		inc (hl)		; score digit +1
		cp (hl)
		jr nz, _ab8		; < 10h ?
		ld (hl), 00h		; roll over score digit
		djnz _ab7
_ab8:		ld hl, 008ah
		ld a, 24h
		cp (hl)			; ' ' ?
		inc hl
		jr z, _ab9
		ld (hl), a		; insert one empty slot
		jr _ab10
_ab9:		;TODO random if emply slot or asteroid after empty slot
		ld a, r			; random refresh register
		and 03h			; 0-2 needed
		cp 03h			; 3 ?
		jr z, _ab9		; repeat
		add a, 40h		; custom characters
		ld (hl), a		; insert new asteroid
_ab10:		dec ix			; increase asteroids speed
		ld b, ixh
		ld c, ixl
_ab11:		push bc
		call _iskey		; check if key pressed
		cp 80h			; ENTER ?
		jr nz, _ab14
		;TODO code
		ld a, iyl		; fly down
		cp 3eh
		jr z, _ab16		; ignore down movement
		cp 31h
		jr z, _ab12
		ld a, 31h
		jr _ab13
_ab12:		ld a, 3eh
_ab13:		ld iyl, a
		ld (_buffer), a		; display new position
		jr _ab16
_ab14:		cp 81h			; BACK ?
		jr nz, _ab16
		ld a, iyl		; fly up
		cp 46h
		jr z, _ab16		; ignore up movement
		cp 31h
		jr z, _ab15
		ld a, 31h
		jr _ab13
_ab15:		ld a, 46h
		jr _ab13
_ab16:		call _lcdupdate		; update game display
		pop bc
		dec bc
		ld a, b
		or c			; delay
		jr nz, _ab11		; inner loop
		jp _ab1			; outer loop
;-----------------------------------------------------------------------------
_datab:
; "ASTEROID BELT"
db 0ah, 1ch, 1dh, 0eh, 1bh, 18h, 12h, 0dh, 24h, 0bh, 0eh, 15h, 1dh, ffh
;-----------------------------------------------------------------------------
; player position in order to dodge asteroids (bottom/center/top)
; player bottom pos: '_' (ASCII 5F)
; player center pos: '-' (ASCII 2D)
; player top pos: custom character 06h
_databhit:
db 3eh, 31h, 46h
;-----------------------------------------------------------------------------
_databgo:
; " GAME OVER "
db 24h, 10h, 0ah, 16h, 0eh, 24h, 18h, 1fh, 0eh, 1bh, 24h
;-----------------------------------------------------------------------------
; custom characters
_databcc:
; [GF   BA] 00h: asteroid top (survive pos = bottom)
; "#####"
; "#   #"
; "#   #"
; "#####"
; "     "
; "     "
; "     "
; "     "
db 1fh, 11h, 11h, 1fh, 00h, 00h, 00h, 00h
; [   D  A] 01h: belt (survive pos = center)
; "#####"
; "     "
; "     "
; "     "
; "     "
; "     "
; "#####"
; "     "
db 1fh, 00h, 00h, 00h, 00h, 00h, 1fh, 00h
; [G EDC  ] 02h: asteroid bottom (survive pos = top)
; "     "
; "     "
; "     "
; "#####"
; "#   #"
; "#   #"
; "#####"
; "     "
db 00h, 00h, 00h, 1fh, 11h, 11h, 1fh, 00h
; [GF D BA] 03h: asteroid top + player bottom
; "#####"
; "#   #"
; "#   #"
; "#####"
; "     "
; "     "
; "#####"
; "     "
db 1fh, 11h, 11h, 1fh, 00h, 00h, 1fh, 00h
; [G  D  A] 04h: player center + belt
; "#####"
; "     "
; "     "
; "#####"
; "     "
; "     "
; "#####"
; "     "
db 1fh, 00h, 00h, 1fh, 00h, 00h, 1fh, 00h
; [G EDC A] 05h: player top + asteroid bottom
; "#####"
; "     "
; "     "
; "#####"
; "#   #"
; "#   #"
; "#####"
; "     "
db 1fh, 00h, 00h, 1fh, 11h, 11h, 1fh, 00h
; [      A] 06h: player top pos
; "#####"
; "     "
; "     "
; "     "
; "     "
; "     "
; "     "
; "     "
db 1fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h
;=============================================================================
