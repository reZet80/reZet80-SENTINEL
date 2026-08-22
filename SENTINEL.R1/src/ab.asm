;=============================================================================
; SENTINEL Asteroid Belt (ab.asm) [last modified: 2026-05-04]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
_abentry:	ld de, _datab
		call _lcdtext0		; welcome
		ld b, 38h		; send 56 bytes (7 chars)
		call _lcdload		; load custom characters to LCD CGRAM
		rst 38h			; wait for keypress
_ab1:		rst 18h			; clear display
		call _clrbuf 		; clear buffer
		ld hl, _buffer 		; use as display buffer
		ld a, 31h		; player (ASCII 2D)
		ld iyl, a		; IYL = player
		ld (hl), a
		ld l, 8bh
		ld (hl), 5bh		; belt comes first
		ld l, 8dh
		xor a
		ld (hl), a		; score
		inc hl
		ld (hl), a
		inc hl
		ld (hl), a
		ld iyh, a		; IYH = empty space cnt
		call _lcdupdate		; update game display
		ld ix, 0200h		; IX = asteroids speed
_ab2:		ld hl, 0081h
		ld de, 0080h		; player location
		ld a, (de)
		push de
		ld bc, 000bh		; 11 asteroids max
		ldir			; move asteroids
		pop hl
		ld c, a			; save player
		ld a, (hl)		; empty | asteroid | combined 
		cp 24h			; player hit ?
		jr nz, _ab6		; maybe hit
		ld a, c
		cp 5dh			; asteroid top + player bottom ?
		jr nz, _ab3
		ld c, 3eh		; remove asteroid
		jr _ab5
_ab3:		cp 5eh			; player center + belt ?
		jr nz, _ab4
		ld c, 31h		; remove belt
		jr _ab5
_ab4:		cp 5fh			; player top + asteroid bottom ?
		jr nz, _ab5
		inc c			; remove asteroid
_ab5:		ld (hl), c		; write back player
		ld iyl, c
		jr _ab12
_ab6:		sub 5ah
		ld c, a
		ld de, _databpos
		add a, e
		ld e, a
		ld a, (de)		; pos player should be
		cp iyl			; check if hit
		jr z, _ab10		; player dodged
_ab7:		ld de, 0080h		; player hit
		push de
		ld hl, _databhit	; display "HIT ME!"
_ab8:		ld a, (hl)
		inc hl
		cp ffh
		jr z, _ab9
		ld (de), a
		call _lcdupdate		; update game display
		call _delay0		; some delay
		jr _ab8
_ab9:		pop de
		ld bc, 000ch
		ldir			; game over
		call _lcdupdate		; update game display
		rst 38h			; wait for any key
		cp 82h			; ESC ?
		jp z, _clientry		; back to CLI
		jp _ab1			; next try
_ab10:		ld a, 5dh
		add c
		ld (hl), a		; show player + asteroid
		ld iyl, a
		ld l, 90h		; update score
		ld a, 10h
		ld b, 03h		; 3 digits max to change
_ab11:		dec hl			; next score digit
		inc (hl)		; score digit +1
		cp (hl)
		jr nz, _ab12		; < 10h ?
		ld (hl), 00h		; roll over score digit
		djnz _ab11
_ab12:		ld hl, 008ah
		ld a, 24h
		cp (hl)			; ' ' ?
		inc hl
		jr z, _ab14
_ab13:		inc iyh
		ld a, iyh
		cp 03h			; max 2 spaces between asteroids
		jr z, _ab15
		ld (hl), 24h		; insert one empty slot
		jr _ab17
_ab14:		ld a, r			; random refresh register
		cpl
		and 01h			; 0-1 needed
		or a
		jr z, _ab13		; one more empty slot
_ab15:		ld iyh, 00h
		ld a, r			; random refresh register
		and 03h			; 0-3 needed
		cp 03h			; 3 = 1
		jr nz, _ab16		; repeat
		ld a, 01h		; insert a belt
_ab16:		add a, 5ah		; custom characters
		ld (hl), a		; insert new asteroid
_ab17:		dec ix			; increase asteroids speed
		ld b, ixh
		ld c, ixl
_ab18:		push bc
		call _iskey		; check if key pressed
		cp 80h			; ENTER ?
		jr nz, _ab21
		ld a, iyl		; fly down
		cp 5eh			; player + asteroid ?
		jr z, _ab8		; hit belt
		cp 5fh			; player + asteroid ?
		jp z, _ab7		; hit asteroid
		cp 3eh
		jr z, _ab23		; ignore down movement
		cp 5dh
		jr z, _ab23		; ignore down movement
		cp 31h
		jr nz, _ab19
		ld a, 3eh
		jr _ab20
_ab19:		ld a, 31h		; it's 60h
_ab20:		ld iyl, a
		ld (_buffer), a		; display new position
		jr _ab23
_ab21:		cp 81h			; BACK ?
		jr nz, _ab23
		ld a, iyl		; fly up
		cp 5eh			; player + asteroid ?
		jp z, _ab7		; hit belt
		cp 5dh			; player + asteroid ?
		jp z, _ab7		; hit asteroid
		cp 60h
		jr z, _ab23		; ignore up movement
		cp 5fh
		jr z, _ab23		; ignore down movement
		cp 31h
		jr nz, _ab22
		ld a, 60h
		jr _ab20
_ab22:		ld a, 31h		; it's 3eh	
		jr _ab20
_ab23:		call _lcdupdate		; update game display
		pop bc
		dec bc			; delay cnt
		ld a, b
		or c
		jr nz, _ab18		; inner loop
		jp _ab2			; outer loop
;-----------------------------------------------------------------------------
; player position in order to dodge asteroids (bottom/center/top)
; player bottom pos: '_' 3E (ASCII 5F)
; player center pos: '-' 31 (ASCII 2D)
; player top pos: custom character 60
_databpos:
db 3eh, 31h, 60h
;-----------------------------------------------------------------------------
_databhit:
; "HITME!"
db 11h, 12h, 1dh, 16h, 0eh, 25h, ffh
;-----------------------------------------------------------------------------
;_databgo:
; " GAME OVER  "
db 24h, 10h, 0ah, 16h, 0eh, 24h, 18h, 1fh, 0eh, 1bh, 24h, 24h
;-----------------------------------------------------------------------------
_datab:
; "ASTEROID BELT"
db 0ah, 1ch, 1dh, 0eh, 1bh, 18h, 12h, 0dh, 24h, 0bh, 0eh, 15h, 1dh, ffh
;-----------------------------------------------------------------------------
; custom characters
; 5A: asteroid top (survive pos = bottom)
; " ####"
; "##  #"
; "#  ##"
; "#### "
; "     "
; "     "
; "     "
; "     "
db 0fh, 19h, 13h, 1eh, 00h, 00h, 00h, 00h
; 5B: belt (survive pos = center)
; "#####"
; "     "
; "     "
; "     "
; "     "
; "     "
; "#####"
; "     "
db 1fh, 00h, 00h, 00h, 00h, 00h, 1fh, 00h
; 5C: asteroid bottom (survive pos = top)
; "     "
; "     "
; "     "
; "#### "
; "#  ##"
; "##  #"
; " ####"
; "     "
db 00h, 00h, 00h, 1eh, 13h, 19h, 0fh, 00h
; 5D: asteroid top + player bottom
; " ####"
; "##  #"
; "#  ##"
; "#### "
; "     "
; "     "
; "#####"
; "     "
db 0fh, 19h, 13h, 1eh, 00h, 00h, 1fh, 00h
; 5E: player center + belt
; "#####"
; "     "
; "     "
; "#####"
; "     "
; "     "
; "#####"
; "     "
db 1fh, 00h, 00h, 1fh, 00h, 00h, 1fh, 00h
; 5F: player top + asteroid bottom
; "#####"
; "     "
; "     "
; "#### "
; "#  ##"
; "##  #"
; " ####"
; "     "
db 1fh, 00h, 00h, 1eh, 13h, 19h, 0fh, 00h
; 60: player top pos
; "#####"
; "     "
; "     "
; "     "
; "     "
; "     "
; "     "
; "     "
db 1fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h
;-----------------------------------------------------------------------------
; CHANGES:
; - R1: asteroid shape, "HIT ME!" anim, bug fixes, code cleanup, minor changes
;=============================================================================
