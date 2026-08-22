;=============================================================================
; SENTINEL Dino Chase (dc.asm) [last modified: 2026-06-28]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
if _LCD_16x2
_dcentry:	ld de, _datdc
		call _lcdtext0		; welcome
		ld b, 40h		; send 64 bytes (8 chars)
		call _lcdload		; load custom characters to LCD CGRAM
		rst 38h			; wait for keypress
_dc1:		rst 18h			; clear display
		call _clrbuf 		; clear buffer
		ld hl, 0091h		; bottom left
		ld (hl), 5ah		; running dino #1
		ld l, a0h		; bottom right
		ld (hl), 18h		; boulder comes first
		ld ix, 4000h		; IX = obstacle speed
		ld iy, 0000h		; IYH = 0 / IYL = 0
_dc2:		ld l, 81h
		ld de, 0080h
		ld a, (de)
		push af			; save player top
		ld bc, 000fh		; 15x
		push bc
		ldir			; move top row
		ld l, 92h
		ld e, 91h
		ld a, (de)
		pop bc
		ldir			; move bottom row
		ld c, a			; C = player bottom
		ld e, 80h		; top left
		ld l, 91h		; bottom left
		pop af			; A = player top
		cp 5ch			; jumping dino top ?
		jr nz, _dcFFF
		ld a, (hl)
		cp 18h			; boulder ?
		jr z, _dcFF
		cp 61h			; hit bottom asteroid fragment ?
		jr z, _dcH
		ld a, 5ah		; -> running dino #1
		ld (hl), a
		ld a, 24h		; fall back down
		ld (de), a
		jr _dcEEEE
_dcFF:		ld a, 5eh		; -> flying dino
		ld (de), a
		jr _dcEEEE
_dcFFF:		cp 5eh			; -> flying dino ?
		jr nz, _dcF
		ld a, 24h		; -> fly back down
		ld (de), a
		ld a, 5eh		; -> fly back down
		ld (hl), a
		jr _dcEEEE
_dcF:		ld a, c			; player bottom
		cp 5ah			; running dino #1 ?
		jr nz, _dcE
		ld a, (hl)
		cp 18h			; hit boulder ?
		jr z, _dcH
		cp 61h			; hit bottom asteroid fragment ?
		jr nz, _dcJ1
_dcH:		ld de, _datdchit	; hit
_dcJ4:		ld a, (de)
		inc de
		cp ffh
		jr z, _dcJ5
		ld (hl), a
		call _lcdupdate		; update game display
		call _delay0		; some delay
		jr _dcJ4
_dcJ5:		rst 38h			; wait for any key
		cp 82h			; ESC ?
		jp z, _clientry		; back to CLI
		jr _dc1			; next try
_dcJ1:		ld a, 5bh		; -> running dino #2
_dcEE:		ld (hl), a		; advance running dino bottom
		jr _dcEEEE
_dcE:		cp 5bh			; running dino #2 ?
		jr nz, _dcEEE
_dcH3:		ld a, (hl)
		cp 18h			; hit boulder ?
		jr z, _dcH
		cp 61h			; hit bottom asteroid fragment ?
		jr z, _dcH
_dcGG:		ld a, 5ah		; -> running dino #1
		jr _dcEE
_dcEEE:		cp 5eh			; -> flying dino ?
		jr nz, _dcG
		jr _dcGG		; -> running dino #1
_dcG:		cp 5fh			; -> ducking dino ?
		jr nz, _dcGGG
		ld a, (hl)
		cp 61h			; bottom asteroid fragment ?
		jr z, _dcH1
		cp 18h			; hit boulder ?
		jr z, _dcH
		jr _dcGG
_dcH1:		ld a, 60h		; -> ducking dino + bottom asteroid fragment
		jr _dcEE
_dcGGG:		cp 60h			; ducking dino + bottom asteroid fragment ?
		jr z, _dcGG
_dcEEEE:	ld l, a0h		; bottom right
		ld e, 8fh		; top right
		ld a, (hl)
		cp 18h			; boulder ?
		jr z, _dcA
		cp 2bh			; bottom asteroid fragment ?
		jr nz, _dcB
_dcA:		inc iyh			; add one empty space
		ld a, 24h		; top empty space
		ld (de), a
		ld a, 24h
		jr _dcAA
_dcB:		ld a, iyh		; it's space
		cp 03h
		jr c, _dcA		; 3 empty spaces min
		ld a, r			; random refresh register
		and 01h			; 0-1 needed
		or a
		jr nz, _dcC
		ld a, iyh
		cp 04h			; 4 empty spaces max
		jr nz, _dcA		; add one more empty space
_dcC:		ld iyh, 00h
		ld a, iyl		; IYL = boulder (0) | asteroid (1)
		or a			; boulder or asteroid next ?
		jr nz, _dcD
		inc iyl			; asteroid next
		ld a, 4eh		; top asteroid fragment 'o'
		ld (de), a
		ld a, 61h		; bottom asteroid fragment
		jr _dcAA
_dcD:		dec iyl			; boulder next
		ld a, 18h		; 'O'
_dcAA:		ld (hl), a
		call _lcdupdate		; update game display
		dec ix			; increase obstacle speed
		ld b, ixh
		ld c, ixl
_dcX:		push bc
		ld l, 91h
		call _iskey		; check if key pressed
		cp 80h			; ENTER ?
		jr nz, _dcY
		ld a, (hl)
		cp 5ah			; running dino #1 ?
		jr nz, _dcYYYY
_dcYYY:		ld (hl), 5fh		; -> ducking dino
_dcW:		call _lcdupdate		; update game display
		jr _dcZ
_dcYYYY:	cp 5bh			; running dino #2 ?
		jr z, _dcYYY
		jr _dcZ			; ignore duck if not running dino #1|#2
_dcY:		cp 81h			; BACK ?
		jr nz, _dcZ
		ld a, (hl)
		cp 5ah			; running dino #1 ?
		jr nz, _dcXXXX
_dcXXX:		ld (hl), 5dh		; -> jumping dino bottom
		ld l, 80h
		ld (hl), 5ch		; -> jumping dino top
		jr _dcW
_dcXXXX:	cp 5bh			; running dino #2 ?
		jr z, _dcXXX
		cp 60h			; ducking dino + bottom asteroid fragment ?
		jp z, _dcH		; don't jump while ducking
_dcZ:		pop bc
		dec bc			; delay cnt
		ld a, b
		or c
		jr nz, _dcX		; inner loop
		jp _dc2			; outer loop
;-----------------------------------------------------------------------------
_datdchit:
; "OUCH!"
db 18h, 1eh, 0ch, 11h, 25h, ffh
;-----------------------------------------------------------------------------
; "DINO CHASE"
_datdc:
db 0dh, 12h, 17h, 18h, 24h, 0ch, 11h, 0ah, 1ch, 0eh, ffh
;-----------------------------------------------------------------------------
; custom characters
; 5A: dino run #1
; "  ###"
; "  # #"
; "  ###"
; "# ## "
; "#### "
; "#####"
; " ### "
; " #   "
db 07h, 05h, 07h, 16h, 1eh, 1fh, 0eh, 08h
; 5B: dino run #2
; "  ###"
; "  # #"
; "  ###"
; "# ## "
; "#####"
; "#### "
; " ### "
; "   # "
db 07h, 05h, 07h, 16h, 1fh, 1eh, 0eh, 02h
; 5C: dino jump top
; "     "
; "     "
; "     "
; "     "
; "     "
; "  ###"
; "  # #"
; "  ###"
db 00h, 00h, 00h, 00h, 00h, 07h, 05h, 07h
; 5D: dino jump bottom
; "# ## "
; "#####"
; "#### "
; " ### "
; " # # "
; "     "
; "     "
; "     "
db 16h, 1fh, 1eh, 0eh, 0ah, 00h, 00h, 00h
; 5E: dino fly
; "  ###"
; "  # #"
; "  ###"
; "# ## "
; "#####"
; "#### "
; " ### "
; " # # "
db 07h, 05h, 07h, 16h, 1fh, 1eh, 0eh, 0ah
; 5F: dino duck
; "     "
; "     "
; "     "
; "  ###"
; "  # #"
; "# ###"
; "#####"
; "#### "
db 00h, 00h, 00h, 07h, 05h, 17h, 1fh, 1eh
; 60: dino duck + asteroid bottom
; " ### "
; "#   #"
; " ### "
; "  ###"
; "  # #"
; "# ###"
; "#####"
; "#### "
db 0eh, 11h, 0eh, 07h, 05h, 17h, 1fh, 1eh
; 61: asteroid bottom
; " ### "
; "#   #"
; " ### "
; "     "
; "     "
; "     "
; "     "
; "     "
db 0eh, 11h, 0eh, 00h, 00h, 00h, 00h, 00h
endif
;=============================================================================
