;=============================================================================
; SENTINEL Donkey Race (dr.asm) [last modified: 2026-06-28]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
if _LCD_16x2
_drentry:	ld de, _datdr
		call _lcdtext0		; welcome
		ld b, 20h		; send 32 bytes (4 chars)
		call _lcdload		; load custom characters to LCD CGRAM
		rst 38h			; wait for keypress
_dr1:		rst 18h			; clear display
		call _clrbuf 		; clear buffer
		xor a
		ld d, a
		ld e, a			; DE = donkey location
		ld h, a
		ld l, 80h 		; HL = car location
		ld (hl), 5ah		; car back
		inc hl
		ld (hl), 5bh		; car front
		ld iyl, a		; IYL = car lane top 0 | bottom 1
		ld ix, 2000h		; IX = donkey speed
_dr2:		ld a, e
		or a			; donkey on the road ?
		jr nz, _dr4
		ld e, 8fh		; top lane rightmost pos
		ld iyh, 00h		; IYH = donkey lane top 0 | bottom 1
		ld a, r			; random donkey appearance
		cpl
		and 01h			; 0-1 needed
		or a
		jr z, _dr3
		ld e, a0h		; bottom lane rightmost pos
		inc iyh
_dr3:		ld a, 5ch		; donkey head
		ld (de), a
		jr _dr14
_dr4:		dec de			; donkey moves towards player
		ld a, 7dh
		cp e
		jr z, _dr5
		ld a, 8eh
		cp e
		jr nz, _dr8
		xor a
		or iyh 			; bottom lane only
		jr z, _dr8
_dr5:		dec hl	 		; car advances
		ld (hl), 24h		; remove old car back
		inc hl
		ld (hl), 5ah		; new car
		inc hl
		ld (hl), 5bh
		ld a, 8fh
		cp l			; end of top lane ?
		jr z, _dr6
		ld a, a0h
		cp l			; end of bottom lane ?
		jr nz, _dr7
_dr6:		call _lcdupdate		; update game display
		ld bc, 0000h
		call _delay		; some delay
		ld (hl), 24h		; remove car front
		dec hl
		ld (hl), 24h		; remove car back
		ld a, l
		sub 0eh
		ld l, a			; go back to leftmost pos
		ld (hl), 5ah		; new car
		inc hl
		ld (hl), 5bh
_dr7:		ld e, 00h		; new donkey
		jr _dr14
_dr8:		ld a, 7eh
		cp e
		jr z, _dr9
		ld a, 8fh
		cp e
		jr nz, _dr10
		xor a
		or iyh 			; bottom lane only
		jr z, _dr10
_dr9:		inc de
		jr _dr12
_dr10:		ld a, 7fh		; donkey moves off the screen ?
		cp e
		jr z, _dr11
		ld a, 90h
		cp e
		jr z, _dr11
		ld a, 5ch		; donkey head
		ld (de), a
_dr11:		ld a, 5dh		; donkey back
		inc de
		ld (de), a
		ld a, 8fh		; last display pos on 1st line ?
		cp e
		jr z, _dr13
		ld a, a0h		; last display pos on 2nd line ?
		cp e
		jr z, _dr13
_dr12:		inc de
		ld a, 24h		; ' '
		ld (de), a		; remove old donkey back
		dec de
_dr13:		dec de
_dr14:		call _lcdupdate		; update game display
		ld a, iyh
		cp 01h
		jr z, _dr16		; maintain constant maximum speed
		ld b, 10h
_dr15:		dec ix			; increase donkey speed
		djnz _dr15
_dr16:		ld b, ixh
		ld c, ixl
_dr17:		push bc
		call _iskey		; check if key pressed
		cp 80h			; ENTER ?
		jr nz, _dr20
		ld (hl), 24h		; delete old car
		dec hl
		ld (hl), 24h
		ld a, iyl		; change lanes
		or a
		jr nz, _dr18
		ld a, l
		add a, 11h		; move to bottom lane
		inc iyl
		jr _dr19
_dr18:		ld a, l
		sub a, 11h		; move to top lane
		dec iyl
_dr19:		ld l, a
		ld (hl), 5ah		; display car
		inc hl
		ld (hl), 5bh
		call _lcdupdate		; update game display
_dr20:		pop bc
		ld a, l			; collision check
		cp e
		jr z, _dr21
		dec a
		cp e
		jr z, _dr21
		dec a
		cp e
		jr nz, _dr24
_dr21:		ld de, _datdrb		; display "BOOM!"
_dr22:		ld a, (de)
		inc de
		cp ffh
		jr z, _dr23
		ld (hl), a
		call _lcdupdate		; update game display
		call _delay0		; some delay
		jr _dr22
_dr23:		rst 38h			; wait for any key
		cp 82h			; ESC ?
		jp z, _clientry		; back to CLI
		jp _dr1			; next try
_dr24:		dec bc			; delay cnt
		ld a, b
		or c
		jr nz, _dr17		; inner loop
		jp _dr2			; outer loop
;-----------------------------------------------------------------------------
_datdrb:
; "BOOM!"
db 0bh, 18h, 18h, 16h, 25h, ffh
;-----------------------------------------------------------------------------
; "DONKEY RACE"
_datdr:
db 0dh, 18h, 17h, 14h, 0eh, 22h, 24h, 1bh, 0ah, 0ch, 0eh, ffh
;-----------------------------------------------------------------------------
; custom characters
; "###   ### " - "# #       "
; " #     #  " - "##        "
; "######### " - "###       "
; "### ##  ##" - "##########"
; "### ##  ##" - " #########"
; "######### " - " # #  # ##"
; " #     #  " - " # #  # # "
; "###   ### " - " # #  # # "
; 5A: car #1 back
; "###  "
; " #   "
; "#####"
; "### #"
; "### #"
; "#####"
; " #   "
; "###  "
db 1ch, 08h, 1fh, 1dh, 1dh, 1fh, 08h, 1ch
; 5B: car #1 front
; " ### "
; "  #  "
; "#### "
; "#  ##"
; "#  ##"
; "#### "
; "  #  "
; " ### "
db 0eh, 04h, 1eh, 13h, 13h, 1eh, 04h, 0eh
; 5C: donkey head
; "# #  "
; "##   "
; "###  "
; "#####"
; " ####"
; " # # "
; " # # "
; " # # "
db 14h, 18h, 1ch, 1fh, 0fh, 0ah, 0ah, 0ah
; 5D: donkey back
; "     "
; "     "
; "     "
; "#####"
; "#####"
; " # ##"
; " # # "
; " # # "
db 00h, 00h, 00h, 1fh, 1fh, 0bh, 0ah, 0ah
endif
;=============================================================================
