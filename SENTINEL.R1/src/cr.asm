;=============================================================================
; SENTINEL Camel Race (cr.asm) [last modified: 2026-06-28]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
if _LCD_16x2
_crentry:	ld de, _datcr
		call _lcdtext0		; welcome
		ld b, 40h		; send 64 bytes (8 chars)
		call _lcdload		; load custom characters to LCD CGRAM
		rst 38h			; wait for keypress
_cr1:		rst 18h			; clear display
		call _clrbuf 		; clear buffer
		ld hl, 80h 		; HL = top camel location
		ld de, 91h 		; DE = bottom camel location
		ld a, 5ah
		ld (hl), a		; top camel back
		inc hl
		ld (de), a		; bottom camel back
		inc de
		inc a
		ld (hl), a		; top camel front
		ld (de), a		; bottom camel front
		ld a, 03h		; display countdown
		inc hl
		inc de
_cr00:		ld (hl), a
		ld (de), a
		push af
		call _lcdupdate		; update game display
		call _delay0		; some delay
		pop af
		dec a
		cp ffh
		jr nz, _cr00
		ld a, 24h		; ' '
		ld (hl), a
		ld (de), a
		call _lcdupdate		; update game display
		dec hl
		dec de
		ld bc, 0101h		; B = last 1UP key, C = last 2UP key
		ld ix, 0000h		; IXH = 1UP cnt, IXL = 2UP cnt
		ld iy, 0000h		; IYH = 1UP camel, IYL = 2UP camel
_cr2:		push bc
		rst 38h			; wait for keypress
		pop bc
		or a			; '0' ?
		jr nz, _crX
		cp b
		jr z, _cr2
		dec b			; valid key press
		inc ixh
		jr _crV
_crX:		cp 80h			; ENTER ?
		jr nz, _crY
		sub 80h
		cp c
		jr z, _cr2
		dec c			; valid key press
		inc ixl
		jr _crVV
_crY:		cp 81h			; BACK ?
		jr nz, _crW
		sub 80h
		cp c
		jr z, _cr2
		inc c			; valid key press
		inc ixl
		jr _crVV
_crW:		cp 01h			; '1' ?
		jr nz, _cr2
		cp b
		jr z, _cr2
		inc b			; valid key press
		inc ixh
_crV:		ld a, ixh
		cp 02h			; 1UP 2 alternating key presses ?
		jr nz, _crVV
		ld ixh, 00h
		dec hl
		ld a, iyh
		or a
		jr nz, _crWW
		call _crdc2
		inc iyh
		jr _crZ
_crWW:		cp 01h
		jr nz, _crWWW
		call _crdc3
		inc iyh
		jr _crZ
_crWWW:		call _crdc1
		ld iyh, 00h
		ld a, 8fh		; finish line ?
		cp l
		jr nz, _crZ
		ld l, 80h
		ld (hl), 01h		; "1"
		jr _crZZZ
_crVV:		ld a, ixl
		cp 02h			; 2 UP 2 alternating key presses ?
		jr nz, _cr2
		ld ixl, 00h
		ex de, hl
		dec hl
		ld a, iyl
		or a
		jr nz, _crXX
		call _crdc2
		inc iyl
		jr _crZZ
_crXX:		cp 01h
		jr nz, _crXXX
		call _crdc3
		inc iyl
		jr _crZZ
_crXXX:		call _crdc1
		ld iyl, 00h
		ld a, a0h		; finish line ?
		cp l
		jr nz, _crZZ
		ld l, 91h
		ld (hl), 02h		; "2"
_crZZZ:		inc hl
		ld de, _datcrw
		ld bc, 0007h
		ex de, hl
		ldir
		call _lcdupdate		; update game display
		rst 38h			; wait for any key
		cp 82h			; ESC ?
		jp z, _clientry		; back to CLI
		jp _cr1			; next try;
_crZZ:		ex de, hl
_crZ:		push bc
		call _lcdupdate		; update game display
		pop bc
		jp _cr2
;-----------------------------------------------------------------------------
; draw camel #1: sprites = 24h, 5ah, 5bh
_crdc1:		dec hl
		ld (hl), 24h		; remove camel #3 back
		inc hl
		ld (hl), 5ah
		inc hl
		ld (hl), 5bh
		ret
;-----------------------------------------------------------------------------
; draw camel #2: sprites = 5ch, 5dh, 5eh
_crdc2:		ld (hl), 5ch
		inc hl
		ld (hl), 5dh
		inc hl
		ld (hl), 5eh
		ret
;-----------------------------------------------------------------------------
; draw camel #3: sprites = 5fh, 60h, 61h
_crdc3:		dec hl
		ld (hl), 5fh
		inc hl
		ld (hl), 60h
		inc hl
		ld (hl), 61h
		ret
;-----------------------------------------------------------------------------
_datcrw:
; "UP WINS"
db 1eh, 19h, 24h, 20h, 12h, 17h, 1ch
;-;-----------------------------------------------------------------------------
_datcr:
; "CAMEL RACE"
db 0ch, 0ah, 16h, 0eh, 15h, 24h, 1bh, 0ah, 0ch, 0eh, ffh
;-----------------------------------------------------------------------------
; custom characters
; "  ###  ###" - "    ###  ###   " - "      ###  ### "
; " ##### #  " - "   ##### #     " - "     ##### #   "
; "########  " - "  ########     " - "    ########   "
; "########  " - "  ########     " - "    ########   "
; " ######   " - "   ######      " - "     ######    "
; " #    #   " - "   #    #      " - "     #    #    "
; " #    #   " - "   #    #      " - "      #  #     "
; " #    #   " - "    #  #       " - "     #   #     "
; 5A: camel #1 back
; "  ###"
; " ####"
; "#####"
; "#####"
; " ####"
; " #   "
; " #   "
; " #   "
db 07h, 0fh, 1fh, 1fh, 0fh, 08h, 08h, 08h
; 5B: camel #1 front
; "  ###"
; "# #  "
; "###  "
; "###  "
; "##   "
; " #   "
; " #   "
; " #   "
db 07h, 14h, 1ch, 1ch, 18h, 08h, 08h, 08h
; 5C: camel #2 back
; "    #"
; "   ##"
; "  ###"
; "  ###"
; "   ##"
; "   # "
; "   # "
; "    #"
db 01h, 03h, 07h, 07h, 03h, 02h, 02h, 01h
; 5D: camel #2 middle
; "##  #"
; "### #"
; "#####"
; "#####"
; "#### "
; "   # "
; "   # "
; "  #  "
db 19h, 1dh, 1fh, 1fh, 1eh, 02h, 02h, 04h
; 5E: camel #2 front
; "##   "
; "     "
; "     "
; "     "
; "     "
; "     "
; "     "
; "     "
db 18h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
; 5F: camel #3 back
; "     "
; "     "
; "    #"
; "    #"
; "     "
; "     "
; "     "
; "     "
db 00h, 00h, 01h, 01h, 00h, 00h, 00h, 00h
; 60: camel #3 middle
; " ### "
; "#####"
; "#####"
; "#####"
; "#####"
; "#    "
; " #  #"
; "#   #"
db 0eh, 1fh, 1fh, 1fh, 1fh, 10h, 09h, 11h
; 61: camel #3 front
; " ### "
; " #   "
; "##   "
; "##   "
; "#    "
; "#    "
; "     "
; "     "
db 0eh, 08h, 18h, 18h, 10h, 10h, 00h, 00h
endif
;=============================================================================
