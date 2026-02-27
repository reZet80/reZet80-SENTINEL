;=============================================================================
; SENTINEL Black Jack (bj.asm) [last modified: 2026-02-19]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
; card status (not drawn = 0|drawn = 1), card face, value
_bjcards:
db 00h, 0ah, 0bh	; 'A'
db 00h, 02h, 02h	; '2'
db 00h, 13h, 0ah	; 'J'
db 00h, 05h, 05h	; '5'
db 00h, 09h, 09h	; '9'
db 00h, 03h, 03h	; '3'
db 00h, 14h, 0ah	; 'K'
db 00h, 06h, 06h	; '6'
db 00h, 1ah, 0ah	; 'Q'
db 00h, 07h, 07h	; '7'
db 00h, 04h, 04h	; '4'
db 00h, 08h, 08h	; '8'
db 00h, 1dh, 0ah	; 'T' for 10
db ffh			; end of list
;---------------------------------------------------------------------------
_bjentry:	ld de, _datbj
		call _lcdtext0		; welcome
		rst 38h			; wait for keypress
_bj0:		rst 18h			; clear display
		call _clrbuf 		; clear buffer
		ld iyl, 01h		; iyl = active player
_bj1:		ld ix, 0000h		; ixh = hand total, ixl = card count
		ld de, _buffer		; use as display buffer
		ld a, iyl
		ld (de), a		; show active player
		inc de
		ld hl, _datbjd
		ld bc, 0005h
		ldir
_bj2:		call _lcdupdate		; update game display
_bj3:		ld hl, _bjcards		; point to 1st card
_bj4:		call _iskey		; check if key pressed
		cp 80h			; ENTER ?
		jr z, _bj7
		cp 82h			; ESC ?
		jr z, _bj11
		inc hl
		inc hl
		inc hl			; next card
		ld a, ffh
		cp (hl)			; last card ?
		jr nz, _bj4
		jr _bj3			; restart with 1st card
_bj5:		ld a, ixh
		ld iyh, a		; iyh = 1UP hand total
		ld hl, 008eh
		call _bjhex2dec		; display it
		ld l, 87h
		ld b, 06h
_bj6:		ld (hl), 24h		; clear cards 1UP
		inc hl
		djnz _bj6
		call _bjreset		; reset card status
		inc iyl			; 2UP
		jr _bj1
_bj7:		xor a
		or (hl)			; card already drawn ?
		jr z, _bj8		; no
		inc hl			; try next card
		inc hl
		inc hl			; next card
		ld a, ffh
		cp (hl)			; last card ?
		jr nz, _bj7
		ld hl, _bjcards		; back to 1st card
		jr _bj7
_bj8:		inc (hl)		; card drawn
		inc hl
		ld de, _buffer
		ex de, hl
		ld a, ixl
		inc ixl
		add a, 87h
		ld l, a
		ld a, (de)		; card face
		inc de
		ld (hl), a		; display card drawn
		ld l, 84h
		ld a, (de)
		add a, ixh		; + card value
		cp 16h			; > 21 ?
		jr c, _bj9
		ld b, a			; bust
		ld a, (_bjcards)
		or a			; ace on the hand ?
		jr z, _bj10
		cp 02h			; already taken into account ?
		jr z, _bj10
		inc a			; subtract 10 only once
		ld (_bjcards), a
		ld a, b
		sub 0ah			; hand total - 10
_bj9:		ld ixh, a
		call _bjhex2dec		; display hand total
		jr _bj2
_bj10:		ld ixh, 00h		; bust -> hand total = 0
		;TODO you busted
_bj11:		ld a, iyl
		cp 01h			; player 1 ?
		jr z, _bj5
		rst 18h			; game over
		ld hl, _buffer
		ld b, iyl
		ld a, ixh
		cp iyh
		jr nz, _bj12
		ex de, hl
		ld hl, _datbjn		; display "NOBODY"
		ld bc, 0006h
		ldir
		jr _bj14
_bj12:		jr nc, _bj13
		dec b
		ld d, ixh		; exchange higher score
		ld e, iyh
		ld ixh, e
		ld iyh, d
_bj13:		ld a, ixh
		call _bjhex2dec		; display winner score
		ld (hl), 24h		; ' '
		inc hl
		ld (hl), 38h		; '>'
		inc hl
		ld (hl), 24h		; ' '
		inc hl
		ld a, iyh
		call _bjhex2dec		; display loser score
		ld (hl), 24h		; ' '
		inc hl
		ld (hl), b		; display '1' | '2'
		inc hl
		ld (hl), 1eh		; 'U'
		inc hl
		ld (hl), 19h		; 'P'
		inc hl
		ex de, hl
_bj14:		ld hl, _datbjw		; display " WINS"
		ld bc, 0006h
		ldir
		call _lcdupdate		; update game display
		rst 38h			; wait for any key
		cp 82h			; ESC ?
		jp z, _clientry		; back to CLI
		call _bjreset
		jp _bj0			; next try
;-----------------------------------------------------------------------------
; convert hex to decimal and display [uses A, C, HL]
_bjhex2dec:	ld c, 00h
_bjhex2dec0:	cp 0ah
		jr c, _bjhex2dec1
		inc c
		sub 0ah
		jr _bjhex2dec0
_bjhex2dec1:	ld (hl), c
		inc hl
		ld (hl), a
		inc hl
		ret
;-----------------------------------------------------------------------------
; mark all cards not drawn
_bjreset:	ld hl, _bjcards
		ld b, 0dh		; 13 cards
		xor a
_bjreset1:	ld (hl), a
		inc hl
		inc hl
		inc hl			; next card
		djnz _bjreset1
		ret
;-----------------------------------------------------------------------------
_datbj:
; "BLACK JACK"
db 0bh, 15h, 0ah, 0ch, 14h, 24h, 13h, 0ah, 0ch, 14h, ffh
;-----------------------------------------------------------------------------
_datbjd:
; "UP 00"
db 1eh, 19h, 24h, 00h, 00h
_datbjn:
; "NOBODY"
db 17h, 18h, 0bh, 18h, 0dh, 22h
_datbjw:
; " WINS"
db 24h, 20h, 12h, 17h, 1ch, ffh
;=============================================================================
