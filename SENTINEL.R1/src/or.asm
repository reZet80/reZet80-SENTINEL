;=============================================================================
; SENTINEL Obstacle Runner (or.asm) [last modified: 2026-06-28]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
if _LCD_16x2
_orentry:	ld de, _dator
		call _lcdtext0		; welcome
		ld b, 30h		; send 48 bytes (6 chars)
		call _lcdload		; load custom characters to LCD CGRAM
		rst 38h			; wait for keypress
_or1:		rst 18h			; clear display
		call _clrbuf 		; clear buffer
		ld ix, 4000h		; IX = obstacle speed
		ld iy, 0000h		; IYH=empty space cnt, IYL=obstacle cnt
		ld hl, 0091h		; bottom left
		ld (hl), 5ah		; running man #1
		ld l, a0h		; bottom right
		ld (hl), 5dh		; left obstacle comes first
		xor a
		ld l, 8dh		; score
		ld (hl), a		; '0'
		inc hl
		ld (hl), a		; '0'
		inc hl
		ld (hl), a		; '0'
_or2:		ld l, 92h
		ld de, 0091h
		ld a, (de)		; player bottom
		ld bc, 000fh		; 15x
		ldir			; move bottom row
		ld c, a			; save
		ld l, 91h
		ld a, (hl)		; empty | obstacle
		cp 5dh
		jr c, _or7		; not hit
		ld a, c			; mybe hit
		cp 5ah
		jr nz, _or6		; not hit
_or3:		ld de, _datorhit	; hit
_or4:		ld a, (de)
		inc de
		cp ffh
		jr z, _or5
		ld (hl), a
		call _lcdupdate		; update game display
		call _delay0		; some delay
		jr _or4
_or5:		rst 38h			; wait for any key
		cp 82h			; ESC ?
		jp z, _clientry		; back to CLI
		jr _or1			; next try
_or6:		cp 5bh
		jr z, _or3		; hit
_or7:		ld e, 80h
		ld a, (de)
		cp 32h			; jumping man top ?
		jr nz, _or9
		ld a, (hl)
		cp 5dh			; left obstacle ?
		jr z, _or8
		ld a, 5ah		; -> running man #1
		ld (hl), a
		ld a, 24h		; fall back down
		jr _or17
_or8:		ld a, 5ah		; -> running man #1
		jr _or14
_or9:		cp 5ah			; running man #1 ?
		jr nz, _or12
		ld a, (hl)
		cp 5dh			; obstacle ?
		jr nc, _or11
_or10:		ld a, 5ch		; -> jumping man bottom
		ld (hl), a
		ld a, 32h		; fly back down
		jr _or17
_or11:		ld a, 5bh		; -> running man #2
		jr _or14
_or12:		cp 5bh			; running man #2 ?
		jr nz, _or18
		ld a, (hl)
		cp 5dh			; obstacle ?
		jr nc, _or13
		jr _or10	
_or13:		ld a, 5ah		; -> running man #1
_or14:		push af
		push hl			; score + 1
		ld l, 90h		; update score
		ld a, 10h
		ld b, 03h		; 3 digits max to change
_or15:		dec hl			; next score digit
		inc (hl)		; score digit +1
		cp (hl)
		jr nz, _or16		; < 10h
		ld (hl), 00h		; roll over score digit
		djnz _or15
_or16:		pop hl
		pop af
_or17:		ld (de), a		; advance running man top
_or18:		ld a, c			; restore
		cp 5ah			; running man #1 ?
		jr nz, _or20
		ld a, 5bh		; -> running man #2
_or19:		ld (hl), a		; advance running man bottom
		jr _or23
_or20:		cp 5bh			; running man #2 ?
		jr nz, _or22
_or21:		ld a, 5ah		; -> running man #1
		jr _or19
_or22:		cp 5ch			; jumping man ?
		jr nz, _or23
		ld a, (hl)
		cp 5dh			; left obstacle ?
		jr z, _or23
		jr _or21
_or23:		ld l, a0h		; last bottom pos
		ld a, (hl)
		cp 5dh			; left obstacle ?
		jr z, _or24
		cp 5eh			; middle obstacle ?
		jr nz, _or26
_or24:		inc iyl
		ld a, iyl
		cp 05h
		jr nz, _or25		; max 5 obstacles
		ld a, 5fh		; add right obstacle
		jr _or30
_or25:		ld a, r			; random refresh register
		cpl
		and 01h			; 0-1 needed
		add a, 5eh		; add random middle or right obstacle
		jr _or30
_or26:		cp 5fh			; right obstacle ?
		jr nz, _or28
		ld iyl, 00h
_or27:		inc iyh			; add one empty space
		ld a, 24h
		jr _or30
_or28:		ld a, iyh		; it's space
		cp 03h
		jr c, _or27		; 3 empty spaces min
		ld a, r			; random refresh register
		and 01h			; 0-1 needed
		or a
		jr nz, _or29
		ld a, iyh
		cp 04h			; 4 empty spaces max
		jr nz, _or27		; add one more empty space
_or29:		inc iyl
		ld a, 5dh		; add left obstacle
		ld iyh, 00h
_or30:		ld (hl), a
		call _lcdupdate		; update game display
		dec ix			; increase obstacle speed
		ld b, ixh
		ld c, ixl
_or31:		push bc
		call _iskey		; check if key pressed
		cp 80h			; ENTER ?
		jr nz, _or34
		ld l, 91h
		ld a, (hl)
		cp 5ah			; running man #1 ?
		jr nz, _or33
_or32:		ld (hl), 5ch		; -> jumping man bottom
		ld l, 80h
		ld (hl), 32h		; -> jumping man top
		call _lcdupdate		; update game display
		jr _or34
_or33:		cp 5bh			; running man #2 ?
		jr z, _or32		; ignore jump if not running man #1|#2
_or34:		pop bc
		dec bc			; delay cnt
		ld a, b
		or c
		jr nz, _or31		; inner loop
		jp _or2			; outer loop
;-----------------------------------------------------------------------------
_datorhit:
; "OUCH!"
db 18h, 1eh, 0ch, 11h, 25h, ffh
;-----------------------------------------------------------------------------
; "OBSTACLE RUNNER"
_dator:
db 18h, 0bh, 1ch, 1dh, 0ah, 0ch, 15h, 0eh
db 24h, 1bh, 1eh, 17h, 17h, 0eh, 1bh, ffh
;-----------------------------------------------------------------------------
; custom characters
; 5A: run #1
; " ##  "
; " ##  "
; "     "
; " ### "
; "###  "
; " ##  "
; "## # "
; "#  ##"
db 0ch, 0ch, 00h, 0eh, 1ch, 0ch, 1ah, 13h
; 5B: run #2
; " ##  "
; " ##  "
; "     "
; "###  "
; " ### "
; " ##  "
; "# ## "
; "#  ##"
db 0ch, 0ch, 00h, 1ch, 0eh, 0ch, 16h, 13h
; jump top is '.'
; 5C: jump bottom
; "#### "
; " ## #"
; "#####"
; "#    "
; "     "
; "     "
; "     "
; "     "
db 1eh, 0dh, 1fh, 10h, 00h, 00h, 00h, 00h
; 5D: left obstacle
; "   ##"
; "   ##"
; "   ##"
; "   ##"
; "   ##"
; "   ##"
; "   ##"
; "   ##"
db 03h, 03h, 03h, 03h, 03h, 03h, 03h, 03h
; 5E: middle obstacle
; "#####"
; "#####"
; "#####"
; "#####"
; "#####"
; "#####"
; "#####"
; "#####"
db 1fh, 1fh, 1fh, 1fh, 1fh, 1fh, 1fh, 1fh
; 5F: right obstacle
; "##   "
; "##   "
; "##   "
; "##   "
; "##   "
; "##   "
; "##   "
; "##   "
db 18h, 18h, 18h, 18h, 18h, 18h, 18h, 18h
endif
;=============================================================================
