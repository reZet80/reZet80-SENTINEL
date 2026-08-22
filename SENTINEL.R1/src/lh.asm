;=============================================================================
; SENTINEL The Lighthouse (lh.asm) [last modified: 2026-07-24]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
_lhentry:	ld iyl, 05h		; IYL = room number
		ld ix, _lhdir		; pointer
		ld de, _lht		; welcome
		call _lcdtext0
_lh00:		ld de, _lhy		; "you are"
		call _lcdtext0
		ld de, _lhx		; "in the"
		ld a, iyl
		cp 05h
		jr c, _lh01
		ld de, _lhz		; "on the"
_lh01:		call _lcdtext0
		ld a, iyl
		ld hl, _lhrooms		; display room description
		call _tabval
		call _lcdtext0
		ld a, iyl
		cp 03h			; room number = 0|1|2 ?
		jr c, _lh02
		cp 08h			; room number = 8|9 ?
		jr c, _lh03
_lh02:		ld de, _lhg		; game over
		call _lcdtext0
		jp _clientry		; back to CLI
_lh03:		ld b, 1eh		; no of items
		ld de, _lhilast
_lh04:		ld a, (de)
		dec de
		and 3fh			; mask pick up and inventory bits
		cp iyl			; item in current room ?
		jr nz, _lh05
		ld a, b
		ld hl, _lhitems		; output item description
		call _tabval
		push bc
		call _lcdtext0
		pop bc
		ex de, hl
_lh05:		djnz _lh04		; last item ?
_lh06:		ld a, 01h		; external CLI call
		call _cli
		ld l, 81h		; 1st buffer entry
		ld a, (hl)		; evaluate command
		call _toupper		; to upper case
		ld c, a			; C = verb
		cp 15h			; 'L' ?
		jr nz, _lh08
_lh07:		rst 18h			; clear display
		jr _lh00
_lh08:		cp 12h			; 'I' ?
		jr nz, _lh0C
		rst 18h			; clear display
		ld b, 1eh		; object no
		ld de, _lhilast		; object address
_lh09:		ld a, (de)
		dec de
		and 40h			; object in inventory ?
		jr z, _lh0A
		ld a, b
		ld hl, _lhinv		; short object name
		push bc
		push de
		call _tabval		; output
		call _lcdtext0
		pop de
		pop bc
_lh0A:		djnz _lh09		; last object ?
_lh0B:		jr _lh06
_lh0C:		inc hl			; read noun
		ld a, l
if _LCD_40x1
		cp a8h			; stay inside buffer
else
		cp 90h			; stay inside buffer
endif
		jr z, _lh0B
		ld a, (hl)
		cp ffh
		jr z, _lh0D
		cp 24h			; ' ' ?
		jr nz, _lh0C
		inc hl
		ld a, (hl)
		call _toupper		; to upper case
_lh0D:		ld iyh, a		; iyh = noun
		ld a, c
		cp 1dh			; 'T' ?
		jr nz, _lh12
		ld hl, _lhtcmd
		ld b, 0ah		; b = number of items/commands
_lh0E:		ld d, h
		ld e, l
		ld a, (hl)
		cp iyh			; noun matches ?
		jr nz, _lh10
		inc hl
		ld a, (hl)		; item no
		ld hl, _lhi00
		call _tab
		ld c, a
		and 80h			; bit 7 ?
		jr z, _lh10
		ld a, c
		and 3fh			; room no
		cp iyl			; room matches ?
		jr nz, _lh10
		ld (hl), 7fh		; object now in inventory
		ld de, _lhmsg00		; OK.
_lh0F:		rst 18h			; clear display
		call _lcdtext0
		jr _lh06
_lh10:		inc de			; next take command
		inc de
		ex de, hl
		djnz _lh0E
_lh11:		ld de, _lhmsg01		; NO!
		jr _lh0F
_lh12:		ld b, 00h		; b = 0 : UP
		cp 1eh			; 'U' ?
		jr nz, _lh14
		jr _lh15
_lh13:		ld hl, _lhdir
		ld a, iyl
		sub 03h			; rooms 0-2 not used
		add a, a		; * 2
		add a, b		; UP or DOWN
		call _tab		; table lookup
		cp ffh			; can we go there ?
		jr z, _lh11
		ld iyl, a		; new room number
		jp _lh07
_lh14:		inc b			; b = 1 : DOWN
		cp 0dh			; 'D' ?
		jr nz, _lh16
_lh15:		ld a, iyh
		cp ffh			; is it "D ..." or "U ..." ?
		jr z, _lh13
_lh16:		ld hl, _lhcmd		; list of commands
		ld b, 19h		; number of commands
_lh17:		push hl
		push bc
		ld a, (hl)
		cp c			; verb matches ?
		jr nz, _lh1A
		inc hl
		ld a, (hl)
		cp iyh			; noun matches ?
		jr nz, _lh1A
		inc hl
		ld a, (hl)
		cp 3fh			; shall match room?
		jr z, _lh18
		cp iyl			; room matches ?
		jr nz, _lh1A
_lh18:		inc hl
		ld a, (hl)
		cp 3fh			; shall match item?
		jr z, _lh19
		push hl
		ld hl, _lhi00		; get item
		call _tab
		pop hl
		ld c, a
		and 3fh
		cp iyl			; room matches ?
		jr z, _lh19
		ld a, c
		and 40h			; bit 6 set ?
		jr z, _lh1A
_lh19:		inc hl
		ld a, (hl)
		inc hl
		push hl
		ld h, (hl)
		ld l, a
		ex de, hl
		rst 18h			; clear display
		call _lcdtext0		; display message
		pop hl
		inc hl
		ld a, (hl)
		inc hl
		ld h, (hl)
		ld l, a
		pop de			; adjust stack
		jp (hl)			; jump to action
_lh1A:		pop bc
		pop hl
		ld de, 0008h
		add hl, de		; next command
		djnz _lh17
		jr _lh11
;-----------------------------------------------------------------------------
; examine devices
_lhact00:	ld (ix + 27h), 83h	; generator visible
		ld (ix + 1bh), 3fh	; devices invisible
_lhact01:	jp _lh06
;-----------------------------------------------------------------------------
; examine tools
_lhact02:	ld (ix + 26h), 83h	; crowbar visible
		ld (ix + 1ch), 3fh	; tools invisible
		jr _lhact01
;-----------------------------------------------------------------------------
; examine desk
_lhact03:	ld (ix + 11h), 06h	; box visible
		ld (ix + 13h), 3fh	; desk invisible
		jr _lhact01
;-----------------------------------------------------------------------------
; examine open box
_lhact04:	ld (ix + 1fh), 86h	; light bulb visible
		ld (ix + 12h), 3fh	; open box invisible
		jr _lhact01
;-----------------------------------------------------------------------------
; examine dog collar
_lhact05:	ld (ix + 24h), 87h	; key visible
		ld (ix + 23h), 3fh	; dog collar invisible
;;		ld (ix + 28h), 40h	; invisible item now in inventory
		jr _lhact01
;-----------------------------------------------------------------------------
; examine boots
_lhact06:	ld (ix + 25h), 87h	; matches visible
		ld (ix + 15h), 3fh	; boots invisible
		jr _lhact01
;-----------------------------------------------------------------------------
; drop mirror
_lhact07:	ld a, iyl
		or 80h			; set bit 7: cracked mirror visible
		ld (_lhicrackedmirror), a
		ld (ix + 22h), 3fh	; mirror invisible
		jr _lhact01
;-----------------------------------------------------------------------------
; kick dog
_lhact08:	ld iyl, 02h		; you die
_lhact09:	jp _lh00
;-----------------------------------------------------------------------------
; open window
_lhact0A:	ld iyl, 08h		; you die
		jr _lhact09
;-----------------------------------------------------------------------------
; use telephone
_lhact0B:	ld iyl, 01h		; you die
		jr _lhact09
;-----------------------------------------------------------------------------
; wake dog
_lhact0C:	ld (ix + 23h), 87h	; collar visible
		ld (ix + 17h), 3fh	; dog invisible
_lhact0D:	jr _lhact01
;-----------------------------------------------------------------------------
; open trapdoor
_lhact0E:	ld (ix + 1ah), 07h	; open trapdoor visible
		ld (ix + 19h), 3fh	; trapdoor invisible
_lhact0F:	ld a, (_lhiburn)
		and 40h			; burning torch in inventory ?
		ld a, 03h		; dir[07][DOWN]=03
		jr nz, _lhact10
		xor a			; dir[07][DOWN]=00: you die
_lhact10:	ld (ix + 09h), a
		jr _lhact0D
;-----------------------------------------------------------------------------
; move rug 
_lhact11:	ld (ix + 19h), 07h	; trapdoor visible
		ld (ix + 18h), 3fh	; rug invisible
		jr _lhact0D
;-----------------------------------------------------------------------------
; use matches
_lhact12:	ld a, (_lhitorch)
		and 40h			; torch in inventory ?
		ret z
		ld (ix + 25h), 3fh	; matches invisible
		ld (ix + 1eh), 3fh	; torch invisible
		ld (ix + 1dh), 7fh	; burning torch now in inventory
		jr _lhact0F
;-----------------------------------------------------------------------------
; use key 
_lhact13:	ld (ix + 12h), 06h	; open box visible
		ld (ix + 11h), 3fh	; box invisible
		jr _lhact0D
;-----------------------------------------------------------------------------
; use crowbar
_lhact14:	ld (ix + 0eh), 3fh	; iron gate invisible
		ld (ix + 04h), 04h	; dir[05][UP]=04
		jr _lhact0D
;-----------------------------------------------------------------------------
; use cracked mirror
_lhact15:	ld (ix + 21h), 3fh	; cracked mirror invisible
		ld (ix + 0ch), 3fh	; missing mirror invisible
_lhact16:	inc (ix + 28h)		; counter to victory++
		ld a, (ix + 28h)
		cp 03h
		jr nz, _lhact0D
		ld iyl, 09h		; you win
		jr _lhact09
;-----------------------------------------------------------------------------
; use light bulb
_lhact17:	ld (ix + 1fh), 3fh	; light bulb invisible
		ld (ix + 0bh), 3fh	; missing light bulb invisible
		jr _lhact16
;-----------------------------------------------------------------------------
; use generator
_lhact18:	ld (ix + 27h), 3fh	; generator invisible
		jr _lhact16
;-----------------------------------------------------------------------------
; directions: UP DOWN
_lhdir:
; 00: dark basement (you die)
; 01: detention cell (game over)
; 02: worst possible condition (you die)
; 03: basement
db 07h, ffh
; 04: lantern room
db ffh, 05h
; 05: top floor
db ffh, 06h
; 06: middle floor
db 05h, 07h
; 07: ground floor
db 06h
_lhi00:
db ffh
; 08: the outside (you die)
; 09: ship (you win)
;-----------------------------------------------------------------------------
; items
; bit 7: can be picked up, bit 6: in inventory, bits 0-5: room number
db 04h	; 01: (electric) lamp
db 04h	; 02: missing light bulb
db 04h	; 03: missing mirror
db 05h	; 04: staircase
db 05h	; 05: (iron) gate
db 05h	; 06: window
db 06h	; 07: painting
db 3fh	; 08: box
db 3fh	; 09: (open) box
db 06h	; 0A: desk
db 06h	; 0B: telephone
db 07h	; 0C: boots
db 07h	; 0D: shelf
db 07h	; 0E: dog
db 07h	; 0F: rug
db 3fh	; 10: trapdoor
db 3fh	; 11: (open) trapdoor
db 03h	; 12: devices
db 03h	; 13: tools
; you can take the following items
_lhiburn:
db 3fh	; 14: (burning) torch
_lhitorch:
db 85h	; 15: torch
db 3fh	; 16: (light) bulb
db 86h	; 17: note
_lhicrackedmirror:
db 3fh	; 18: (cracked) mirror
db 86h	; 19: mirror
db 3fh  ; 1A: (dog) collar
db 3fh	; 1B: key
db 3fh	; 1C: matches
db 3fh	; 1D: crowbar
_lhilast:
db 3fh	; 1E: generator (last visible item)
db 00h	; 20: counter to victory
;-----------------------------------------------------------------------------
; TAKE command: noun, item
_lhtcmd:
; T[ORCH]
db 1dh, 15h
; B[ULB]
db 0bh, 16h
; N[OTE]
db 17h, 17h
; M[IRROR]
db 16h, 18h
; M[IRROR]
db 16h, 19h
; C[OLLAR]
db 0ch, 1ah
; K[EY]
db 14h, 1bh
; M[ATCHES]
db 16h, 1ch
; C[ROWBAR]
db 0ch, 1dh
; G[ENERATOR]
db 10h, 1eh
;-----------------------------------------------------------------------------
; commands:
; verb-noun-room-item-message-jump address
; room = 3F : only location of item is relevant
; item = 3F : no item needed
_lhcmd:
; E[XAMINE] D[EVICES]
db 0eh, 0dh, 03h, 12h
dw _lhi1E, _lhact00
; E[XAMINE] T[OOLS]
db 0eh, 1dh, 03h, 13h
dw _lhi1D, _lhact02
; E[XAMINE] W[INDOW]
db 0eh, 20h, 05h, 06h
dw _lhmsg02, _lh06
; E[XAMINE] D[ESK]
db 0eh, 0dh, 06h, 0ah
dw _lhi08, _lhact03
; E[XAMINE] B[OX] (box)
db 0eh, 0bh, 06h, 08h
dw _lhmsg03, _lh06
; E[XAMINE] B[OX] (open box)
db 0eh, 0bh, 06h, 09h
dw _lhi16, _lhact04
; E[XAMINE] P[AINTING]
db 0eh, 19h, 06h, 07h
dw _lhmsg04, _lh06
; E[XAMINE] C[OLLAR]
db 0eh, 0ch, 3fh, 1ah
dw _lhmsg05, _lhact05
; E[XAMINE] S[HELF]
db 0eh, 1ch, 07h, 0dh
dw _lhmsg06, _lh06
; E[XAMINE] B[OOTS]
db 0eh, 0bh, 07h, 0ch
dw _lhi1C, _lhact06
; D[ROP] M[IRROR]
db 0dh, 16h, 3fh, 19h
dw _lhi18, _lhact07
; K[ICK] D[OG]
db 14h, 0dh, 07h, 0eh
dw _lhmsg07, _lhact08
; M[OVE] R[UG]
db 16h, 1bh, 07h, 0fh
dw _lhi10, _lhact11
; O[PEN] T[RAPDOOR]
db 18h, 1dh, 07h, 10h
dw _lhi11, _lhact0E
; O[PEN] W[INDOW]
db 18h, 20h, 05h, 06h
dw _lhmsg07, _lhact0A
; R[EAD] N[OTE]
db 1bh, 17h, 3fh, 17h
dw _lhmsg09, _lh06
; U[SE] B[ULB]
db 1eh, 0bh, 04h, 16h
dw _lhmsg00, _lhact17
; U[SE] C[ROWBAR]
db 1eh, 0ch, 05h, 1dh
dw _lhmsg0A, _lhact14
; U[SE] G[ENERATOR]
db 1eh, 10h, 04h, 1eh
dw _lhmsg00, _lhact18
; U[SE] K[EY]
db 1eh, 14h, 06h, 08h
dw _lhi09, _lhact13
; U[SE] M[ATCHES]
db 1eh, 16h, 3fh, 1ch
dw _lhmsg08, _lhact12
; U[SE] T[ELEPHONE]
db 1eh, 1dh, 06h, 0bh
dw _lhmsg07, _lhact0B
; U[SE] M[IRROR]
db 1eh, 16h, 04h, 19h
dw _lhmsg0B, _lh06
; U[SE] M[IRROR]
db 1eh, 16h, 04h, 18h
dw _lhmsg00, _lhact15
; W[AKE] D[OG]
db 20h, 0dh, 07h, 0eh
dw _lhi1A, _lhact0C
;-----------------------------------------------------------------------------
; room descriptions
_lhrooms:
dw _lhr0, _lhr1, _lhr2, _lhr3, _lhr4, _lhr5, _lhr6, _lhr7, _lhr8
_lhitems:
dw _lhr9
;-----------------------------------------------------------------------------
; item descriptions
dw _lhi01, _lhi02, _lhi03, _lhi04, _lhi05, _lhi06, _lhi07, _lhi08, _lhi09, _lhi0A
_lhinv:
dw _lhi0B, _lhi0C, _lhi0D, _lhi0E, _lhi0F, _lhi10, _lhi11, _lhi12
dw _lhi13, _lhi14, _lhi14, _lhi16, _lhi17, _lhi18, _lhi19, _lhi1A, _lhi1B
dw _lhi1C, _lhi1D, _lhi1E
;-----------------------------------------------------------------------------
; short item names in inventory
dw _lhinv14, _lhinv15, _lhinv16, _lhinv17, _lhinv18, _lhinv19
dw _lhinv1A, _lhinv1B, _lhinv1C, _lhinv1D, _lhinv1E
;-----------------------------------------------------------------------------
_lht:
; "The Lighthouse[ENTER]"
db 1dh, 47h, 44h, 24h, 15h, 48h, 46h, 47h, 53h, 47h, 4eh, 54h, 52h, 44h, 80h, ffh
;-----------------------------------------------------------------------------
_lhy:
; "You are "
db 22h, 4eh, 54h, 24h, 40h, 51h, 44h, 24h, ffh
_lhx:
db 48h, 4dh, 24h, 53h, 47h, 44h
if _LCD_40x1
; "in the "
db 24h
else
; "in the[ENTER]"
db 80h
endif
db ffh
_lhz:
db 4eh, 4dh, 24h, 53h, 47h, 44h
if _LCD_40x1
; "on the "
db 24h
else
; "on the[ENTER]"
db 80h
endif
db ffh
_lhg:
; "GAME OVER![ENTER]"
db 10h, 0ah, 16h, 0eh, 24h, 18h, 1fh, 0eh, 1bh, 25h, 80h, ffh
;-----------------------------------------------------------------------------
_lhr0:
db 43h, 40h, 51h, 4ah, 24h, 41h, 40h, 52h, 44h, 4ch
db 44h, 4dh, 53h, 32h, 80h, 22h, 4eh, 54h, 24h, 45h
db 44h, 4bh, 4bh, 24h, 53h, 47h, 51h, 4eh, 54h, 46h, 47h
if _LCD_40x1
; "dark basement.[ENTER]You fell through a trap door to[ENTER]your death.[ENTER]"
db 24h
else
; "dark basement.[ENTER]You fell through[ENTER]"
; "a trap door to[ENTER]your death.[ENTER]"
db 80h
endif
db 40h, 24h, 53h, 51h, 40h, 4fh, 24h, 43h, 4eh, 4eh, 51h, 24h, 53h, 4eh
db 80h, 58h, 4eh, 54h, 51h, 24h, 43h, 44h, 40h, 53h, 47h, 32h, 80h, ffh
_lhr1:
db 43h, 44h, 53h, 44h, 4dh, 53h, 48h, 4eh, 4dh, 24h, 42h, 44h, 4bh, 4bh, 32h
db 80h, 22h, 4eh, 54h, 24h, 43h, 48h, 40h, 4bh, 44h, 43h, 24h, 53h, 47h, 44h
if _LCD_40x1
; "detention cell.[ENTER]You dialed the emergency call.[ENTER]"
; "The police arrested you.[ENTER]"
db 24h
else
; "detention cell.[ENTER]You dialed the[ENTER]emergency call.[ENTER]"
; "The police[ENTER]arrested you.[ENTER]"
db 80h
endif
db 44h, 4ch, 44h, 51h, 46h, 44h, 4dh, 42h, 58h, 24h, 42h, 40h, 4bh, 4bh
db 32h, 80h, 1dh, 47h, 44h, 24h, 4fh, 4eh, 4bh, 48h, 42h, 44h
if _LCD_40x1
db 24h
else
db 80h
endif
db 40h, 51h, 51h, 44h, 52h, 53h, 44h, 43h, 24h, 58h, 4eh, 54h, 32h, 80h, ffh
_lhr2:
db 56h, 4eh, 51h, 52h, 53h, 24h, 4fh, 4eh, 52h, 52h, 48h, 41h, 4bh, 44h
if _LCD_40x1
; "worst possible condition.[ENTER]The dog tore "
; "you to pieces.[ENTER]You are dead.[ENTER]"
db 24h
else
; "worst possible[ENTER]condition.[ENTER]The dog tore[ENTER]"
; "you to pieces.[ENTER]You are dead.[ENTER]"
db 80h
endif
db 42h, 4eh, 4dh, 43h, 48h, 53h, 48h, 4eh, 4dh, 32h, 80h
db 1dh, 47h, 44h, 24h, 43h, 4eh, 46h, 24h, 53h, 4eh, 51h, 44h
if _LCD_40x1
db 24h
else
db 80h
endif
db 58h, 4eh, 54h, 24h, 53h, 4eh, 24h, 4fh, 48h, 44h
db 42h, 44h, 52h, 32h, 80h, 22h, 4eh, 54h, 24h, 40h
db 51h, 44h, 24h, 43h, 44h, 40h, 43h, 32h, 80h, ffh
_lhr3:
; "basement.[ENTER]"
db 41h, 40h, 52h, 44h, 4ch, 44h, 4dh, 53h, 32h, 80h, ffh
_lhr4:
; "lantern room.[ENTER]"
db 4bh, 40h, 4dh, 53h, 44h, 51h, 4dh, 24h, 51h, 4eh, 4eh, 4ch, 32h, 80h, ffh
_lhr5:
; "top floor.[ENTER]"             
db 53h, 4eh, 4fh, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_lhr6:
; "middle floor.[ENTER]"
db 4ch, 48h, 43h, 43h, 4bh, 44h, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_lhr7:
; "ground floor.[ENTER]"
db 46h, 51h, 4eh, 54h, 4dh, 43h, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_lhr8:
db 4eh, 54h, 53h, 52h, 48h, 43h, 44h, 32h, 80h, 22h, 4eh
db 54h, 24h, 49h, 54h, 4ch, 4fh, 44h, 43h, 24h, 4eh, 54h, 53h
if _LCD_40x1
; "outside.[ENTER]You jumped out of the window.[ENTER]You are dead.[ENTER]"
db 24h
else
; "outside.[ENTER]You jumped out[ENTER]of the window.[ENTER]You are dead.[ENTER]"
db 80h
endif
db 4eh, 45h, 24h, 53h, 47h, 44h, 24h, 56h, 48h, 4dh, 43h, 4eh, 56h, 32h, 80h
db 22h, 4eh, 54h, 24h, 40h, 51h, 44h, 24h, 43h, 44h, 40h, 43h, 32h, 80h, ffh
_lhr9:
db 52h, 47h, 48h, 4fh, 32h
if _LCD_40x1
; "ship.[ENTER]You lit the lamp and saved the ship.[ENTER]YOU WIN![ENTER]"
db 80h
else
; "ship. You lit[ENTER]the lamp and[ENTER]saved the ship.[ENTER]YOU WIN![ENTER]"
db 24h
endif
db 22h, 4eh, 54h, 24h, 4bh, 48h, 53h
if _LCD_40x1
db 24h
else
db 80h
endif
db 53h, 47h, 44h, 24h, 4bh, 40h, 4ch, 4fh, 24h, 40h, 4dh, 43h,
if _LCD_40x1
db 24h
else
db 80h
endif
db 52h, 40h, 55h, 44h, 43h, 24h, 53h, 47h, 44h, 24h, 52h, 47h, 48h
db 4fh, 32h, 80h, 22h, 18h, 1eh, 24h, 20h, 12h, 17h, 25h, 80h, ffh
;-----------------------------------------------------------------------------
_lhi01:
db 22h, 4eh, 54h, 24h, 52h, 44h, 44h, 24h, 40h, 24h, 4bh, 40h, 51h, 46h, 44h
if _LCD_40x1
; "You see a large electric lamp here. The[ENTER]light "
; "is off because the power socket[ENTER]is broken.[ENTER]"
db 24h
else
; "You see a large[ENTER]electric lamp[ENTER]here. The light[ENTER]"
; "is off because[ENTER]the power socket[ENTER]is broken.[ENTER]"
db 80h
endif
db 44h, 4bh, 44h, 42h, 53h, 51h, 48h, 42h, 24h, 4bh, 40h, 4ch, 4fh
if _LCD_40x1
db 24h
else
db 80h
endif
db 47h, 44h, 51h, 44h, 32h, 24h, 1dh, 47h, 44h
if _LCD_40x1
db 80h
else
db 24h
endif
db 24h, 4bh, 48h, 46h, 47h, 53h
if _LCD_40x1
db 24h
else
db 80h
endif
db 48h, 52h, 24h, 4eh, 45h, 45h, 24h, 41h, 44h, 42h, 40h, 54h, 52h, 44h
if _LCD_40x1
db 24h
else
db 80h
endif
db 53h, 47h, 44h, 24h, 4fh, 4eh, 56h, 44h, 51h, 24h, 52h, 4eh, 42h, 4ah
db 44h, 53h, 80h, 48h, 52h, 24h, 41h, 51h, 4eh, 4ah, 44h, 4dh, 32h, 80h, ffh
_lhi02:
db 1dh, 47h, 44h, 24h, 4bh, 48h, 46h, 47h, 53h, 24h, 41h, 54h, 4bh, 41h
if _LCD_40x1
; "The light bulb is missing.[ENTER]
db 24h
else
; "The light bulb[ENTER]is missing.[ENTER]
db 80h
endif
db 48h, 52h, 24h, 4ch, 48h, 52h, 52h, 48h, 4dh, 46h, 32h, 80h, ffh
_lhi03:
db 1dh, 47h, 44h, 24h, 4ch, 48h, 51h, 51h, 4eh, 51h
if _LCD_40x1
; "The mirror is missing.[ENTER]
db 24h
else
; "The mirror[ENTER]is missing.[ENTER]
db 80h
endif
db 48h, 52h, 24h, 4ch, 48h, 52h, 52h, 48h, 4dh, 46h, 32h, 80h, ffh
_lhi04:
db 0ah, 24h, 52h, 53h, 40h, 48h, 51h, 42h, 40h, 52h, 44h
if _LCD_40x1
; "A staircase runs from top to bottom.[ENTER]"
db 24h
else
; "A staircase[ENTER]runs from top[ENTER]to bottom.[ENTER]"
db 80h
endif
db 51h, 54h, 4dh, 52h, 24h, 45h, 51h, 4eh, 4ch, 24h, 53h, 4eh, 4fh
if _LCD_40x1
db 24h
else
db 80h
endif
db 53h, 4eh, 24h, 41h, 4eh, 53h, 53h, 4eh, 4ch, 32h, 80h, ffh
_lhi05:
db 0ah, 4dh, 24h, 48h, 51h, 4eh, 4dh, 24h, 46h, 40h, 53h, 44h
if _LCD_40x1
; "An iron gate blocks the way to[ENTER]the lantern room.[ENTER]"
db 24h
else
; "An iron gate[ENTER]blocks the way[ENTER]to the lantern[ENTER]room.[ENTER]"
db 80h
endif
db 41h, 4bh, 4eh, 42h, 4ah, 52h, 24h, 53h, 47h, 44h, 24h, 56h, 40h, 58h
if _LCD_40x1
db 24h
else
db 80h
endif
db 53h, 4eh
if _LCD_40x1
db 80h
else
db 24h
endif
db 53h, 47h, 44h, 24h, 4bh, 40h, 4dh, 53h, 44h, 51h, 4dh
if _LCD_40x1
db 24h
else
db 80h
endif
db 51h, 4eh, 4eh, 4ch, 32h, 80h, ffh
_lhi06:
db 1dh, 47h, 44h, 51h, 44h, 24h, 48h, 52h, 24h, 40h
if _LCD_40x1
; "There is a round window.[ENTER]"
db 24h
else
; "There is a[ENTER]round window.[ENTER]"
db 80h
endif
db 51h, 4eh, 54h, 4dh, 43h, 24h, 56h, 48h, 4dh, 43h, 4eh, 56h, 32h, 80h, ffh
_lhi07:
db 0ah, 24h, 4fh, 40h, 48h, 4dh, 53h, 48h
db 4dh, 46h, 24h, 47h, 40h, 4dh, 46h, 52h
if _LCD_40x1
; "A painting hangs on the wall.[ENTER]"
db 24h
else
; "A painting hangs[ENTER]on the wall.[ENTER]"
db 80h
endif
db 4eh, 4dh, 24h, 53h, 47h, 44h, 24h, 56h, 40h, 4bh, 4bh, 32h, 80h, ffh
_lhi08:
; "You see a box.[ENTER]"
db 22h, 4eh, 54h, 24h, 52h, 44h, 44h, 24h, 40h, 24h, 41h, 4eh, 57h, 32h, 80h, ffh
_lhi09:
db 22h, 4eh, 54h, 24h, 52h, 44h, 44h
if _LCD_40x1
; "You see an open box.[ENTER]"
db 24h
else
; "You see[ENTER]an open box.[ENTER]"
db 80h
endif
db 40h, 4dh, 24h, 4eh, 4fh, 44h, 4dh, 24h, 41h, 4eh, 57h, 32h, 80h, ffh
_lhi0A:
; "Here is a desk.[ENTER]"
db 11h, 44h, 51h, 44h, 24h, 48h, 52h, 24h, 40h, 24h, 43h, 44h, 52h, 4ah, 32h
db 80h, ffh
_lhi0B:
db 22h, 4eh, 54h, 24h, 42h, 40h, 4dh, 24h, 52h, 44h, 44h
if _LCD_40x1
; "You can see a telephone on the wall.[ENTER]"
db 24h
else
; "You can see[ENTER]a telephone[ENTER]on the wall.[ENTER]"
db 80h
endif
db 40h, 24h, 53h, 44h, 4bh, 44h, 4fh, 47h, 4eh, 4dh, 44h
if _LCD_40x1
db 24h
else
db 80h
endif
db 4eh, 4dh, 24h, 53h, 47h, 44h, 24h, 56h, 40h, 4bh, 4bh, 32h, 80h, ffh
_lhi0C:
db 0ah, 24h, 4fh, 40h, 48h, 51h, 24h, 4eh, 45h, 24h, 41h, 4eh, 4eh, 53h, 52h
if _LCD_40x1
; "A pair of boots lies under the shelf.[ENTER]"
db 24h
else
; "A pair of boots[ENTER]lies under[ENTER]the shelf.[ENTER]"
db 80h
endif
db 4bh, 48h, 44h, 52h, 24h, 54h, 4dh, 43h, 44h, 51h,
if _LCD_40x1
db 24h
else
db 80h
endif
db 53h, 47h, 44h, 24h, 52h, 47h, 44h, 4bh, 45h, 32h, 80h, ffh
_lhi0D:
db 1dh, 47h, 44h, 51h, 44h, 24h, 48h, 52h
db 24h, 40h, 24h, 52h, 47h, 44h, 4bh, 45h
if _LCD_40x1
; "There is a shelf on one wall.[ENTER]"
db 24h
else
; "There is a shelf[ENTER]on one wall.[ENTER]"
db 80h
endif
db 4eh, 4dh, 24h, 4eh, 4dh, 44h, 24h, 56h, 40h, 4bh, 4bh, 32h, 80h, ffh
_lhi0E:
db 0ah, 24h, 43h, 4eh, 46h, 24h, 52h, 4bh, 44h, 44h, 4fh, 52h
if _LCD_40x1
; "A dog sleeps on the floor.[ENTER]"
db 24h
else
; "A dog sleeps[ENTER]on the floor.[ENTER]"
db 80h
endif
db 4eh, 4dh, 24h, 53h, 47h, 44h, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_lhi0F:
db 22h, 4eh, 54h, 24h, 52h, 44h, 44h, 24h, 40h, 24h, 51h, 54h, 46h
if _LCD_40x1
; "You see a rug on the floor.[ENTER]"
db 24h
else
; "You see a rug[ENTER]on the floor.[ENTER]"
db 80h
endif
db 4eh, 4dh, 24h, 53h, 47h, 44h, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_lhi10:
db 1dh, 47h, 44h, 51h, 44h, 24h, 48h, 52h, 24h, 40h
if _LCD_40x1
; "There is a trapdoor in the floor.[ENTER]"
db 24h
else
; "There is a[ENTER]trapdoor[ENTER]in the floor.[ENTER]"
db 80h
endif
db 53h, 51h, 40h, 4fh, 43h, 4eh, 4eh, 51h
if _LCD_40x1
db 24h
else
db 80h
endif
db 48h, 4dh, 24h, 53h, 47h, 44h, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_lhi11:
db 1dh, 47h, 44h, 51h, 44h, 24h, 48h, 52h, 24h, 40h, 4dh
if _LCD_40x1
; "There is an open trapdoor in the floor.[ENTER]"
db 24h
else
; "There is an[ENTER]open trapdoor[ENTER]in the floor.[ENTER]"
db 80h
endif
db 4eh, 4fh, 44h, 4dh, 24h, 53h, 51h, 40h, 4fh, 43h, 4eh, 4eh, 51h
if _LCD_40x1
db 24h
else
db 80h
endif
db 48h, 4dh, 24h, 53h, 47h, 44h, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_lhi12:
db 22h, 4eh, 54h, 24h, 52h, 44h, 44h, 24h, 4ch, 40h, 4dh, 58h
if _LCD_40x1
; "You see many discarded devices.[ENTER]"
db 24h
else
; "You see many[ENTER]discarded[ENTER]devices.[ENTER]"
db 80h
endif
db 43h, 48h, 52h, 42h, 40h, 51h, 43h, 44h, 43h
if _LCD_40x1
db 24h
else
db 80h
endif
db 43h, 44h, 55h, 48h, 42h, 44h, 52h, 32h, 80h, ffh
_lhi13:
db 1ch, 4eh, 4ch, 44h, 24h, 53h, 4eh, 4eh, 4bh, 52h, 24h, 40h, 51h, 44h
if _LCD_40x1
; "Some tools are lying around.[ENTER]"
db 24h
else
; "Some tools are[ENTER]lying around.[ENTER]"
db 80h
endif
db 4bh, 58h, 48h, 4dh, 46h, 24h, 40h, 51h, 4eh, 54h, 4dh, 43h, 32h, 80h, ffh
_lhi14:
; "You see a torch.[ENTER]"
db 22h, 4eh, 54h, 24h, 52h, 44h, 44h, 24h, 40h, 24h, 53h, 4eh, 51h, 42h, 47h
db 32h, 80h, ffh
_lhi16:
db 22h, 4eh, 54h, 24h, 52h, 44h, 44h, 24h, 40h 
if _LCD_40x1
; "You see a light bulb.[ENTER]"
db 24h
else
; "You see a[ENTER]light bulb.[ENTER]"
db 80h
endif
db 4bh, 48h, 46h, 47h, 53h, 24h, 41h, 54h, 4bh, 41h, 32h, 80h, ffh
_lhi17:
db 0ah, 24h, 4dh, 4eh, 53h, 44h, 24h, 4bh, 48h, 44h, 52h, 24h, 4eh, 4dh
if _LCD_40x1
; "A note lies on the floor.[ENTER]"
db 24h
else
; "A note lies on[ENTER]the floor.[ENTER]"
db 80h
endif
db 53h, 47h, 44h, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_lhi18:
db 22h, 4eh, 54h, 24h, 52h, 44h, 44h, 24h, 40h
if _LCD_40x1
; "You see a cracked mirror.[ENTER]"
db 24h
else
; "You see a[ENTER]cracked mirror.[ENTER]"
db 80h
endif
db 42h, 51h, 40h, 42h, 4ah, 44h, 43h, 24h
db 4ch, 48h, 51h, 51h, 4eh, 51h, 32h, 80h, ffh
_lhi19:
db 22h, 4eh, 54h, 24h, 52h, 44h, 44h, 24h, 40h, 24h, 4bh, 40h, 51h, 46h, 44h
if _LCD_40x1
; "You see a large curved mirror.[ENTER]"
db 24h
else
; "You see a large[ENTER]curved mirror.[ENTER]"
db 80h
endif
db 42h, 54h, 51h, 55h, 44h, 43h, 24h, 4ch
db 48h, 51h, 51h, 4eh, 51h, 32h, 80h, ffh
_lhi1A:
db 0ah, 24h, 43h, 4eh, 46h, 24h, 42h, 4eh, 4bh, 4bh, 40h, 51h
if _LCD_40x1
; "A dog collar lies on the rug.[ENTER]"
db 24h
else
; "A dog collar[ENTER]lies on the rug.[ENTER]"
db 80h
endif
db 4bh, 48h, 44h, 52h, 24h, 4eh, 4dh, 24h, 53h
db 47h, 44h, 24h, 51h, 54h, 46h, 32h, 80h, ffh
_lhi1B:
db 0ah, 24h, 4ah, 44h, 58h, 24h, 4bh, 48h, 44h, 52h, 24h, 4eh, 4dh
if _LCD_40x1
; "A key lies on the floor.[ENTER]"
db 24h
else
; "A key lies on[ENTER]the floor.[ENTER]"
db 80h
endif
db 53h, 47h, 44h, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_lhi1C:
db 22h, 4eh, 54h, 24h, 52h, 44h, 44h, 24h, 40h, 24h, 41h, 4eh, 57h
if _LCD_40x1
; "You see a box of matches.[ENTER]"
db 24h
else
; "You see a box[ENTER]of matches.[ENTER]"
db 80h
endif
db 4eh, 45h, 24h, 4ch, 40h, 53h, 42h, 47h, 44h, 52h, 32h, 80h, ffh
_lhi1D:
db 0ah, 24h, 42h, 51h, 4eh, 56h, 41h, 40h, 51h, 24h, 4bh, 48h, 44h, 52h
if _LCD_40x1
; "A crowbar lies between the tools.[ENTER]"
db 24h
else
; "A crowbar lies[ENTER]between the[ENTER]tools.[ENTER]"
db 80h
endif
db 41h, 44h, 53h, 56h, 44h, 44h, 4dh, 24h, 53h, 47h, 44h
if _LCD_40x1
db 24h
else
db 80h
endif
db 53h, 4eh, 4eh, 4bh, 52h, 32h, 80h, ffh
_lhi1E:
db 0ah, 24h, 46h, 44h, 4dh, 44h, 51h, 40h, 53h, 4eh, 51h, 24h, 48h, 52h
if _LCD_40x1
; "A generator is located between[ENTER]the devices.[ENTER]"
db 24h
else
; "A generator is[ENTER]located between[ENTER]the devices.[ENTER]"
db 80h
endif
db 4bh, 4eh, 42h, 40h, 53h, 44h, 43h, 24h, 41h, 44h, 53h, 56h, 44h, 44h, 4dh
db 80h, 53h, 47h, 44h, 24h, 43h, 44h, 55h, 48h, 42h, 44h, 52h, 32h, 80h, ffh
;-----------------------------------------------------------------------------
_lhinv14:
; "(burning) torch[ENTER]"
db 2ch, 41h, 54h, 51h, 4dh, 48h, 4dh, 46h, 2dh, 24h, 53h, 4eh, 51h, 42h, 47h
db 80h, ffh
_lhinv15:
; "torch[ENTER]"
db 53h, 4eh, 51h, 42h, 47h, 80h, ffh
_lhinv16:
; "(light) bulb[ENTER]"
db 2ch, 4bh, 48h, 46h, 47h, 53h, 2dh, 24h, 41h, 54h, 4bh, 41h, 80h, ffh
_lhinv17:
; "note[ENTER]"
db 4dh, 4eh, 53h, 44h, 80h, ffh
_lhinv18:
; "(cracked) mirror[ENTER]"
db 2ch, 42h, 51h, 40h, 42h, 4ah, 44h, 43h, 2dh, 24h, 4ch, 48h, 51h, 51h, 4eh
db 51h, 80h, ffh
_lhinv19:
; "mirror[ENTER]"
db 4ch, 48h, 51h, 51h, 4eh, 51h, 80h, ffh
_lhinv1A:
; "(dog) collar[ENTER]"
db 2ch, 43h, 4eh, 46h, 2dh, 24h, 42h, 4eh, 4bh, 4bh, 40h, 51h, 80h, ffh
_lhinv1B:
; "key[ENTER]"
db 4ah, 44h, 58h, 80h, ffh
_lhinv1C:
; "matches[ENTER]"
db 4ch, 40h, 53h, 42h, 47h, 44h, 52h, 80h, ffh
_lhinv1D:
; "crowbar[ENTER]"
db 42h, 51h, 4eh, 56h, 41h, 40h, 51h, 80h, ffh
_lhinv1E:
; "generator[ENTER]"
db 46h, 44h, 4dh, 44h, 51h, 40h, 53h, 4eh, 51h, 80h, ffh
;-----------------------------------------------------------------------------
_lhmsg00:
; "OK.[ENTER]"
db 18h, 14h, 32h, 80h, ffh
_lhmsg01:
; "NO![ENTER]"
db 17h, 18h, 25h, 80h, ffh
_lhmsg02:
db 22h, 4eh, 54h, 24h, 42h, 40h, 4dh, 24h, 52h, 44h, 44h, 24h, 53h, 47h, 44h
if _LCD_40x1
; "You can see the lights of a ship[ENTER]sailing towards "
; "the lighthouse.[ENTER]"
db 24h
else
; "You can see the[ENTER]lights of a ship[ENTER]sailing towards[ENTER]"
; "the lighthouse.[ENTER]"
db 80h
endif
db 4bh, 48h, 46h, 47h, 53h, 52h, 24h, 4eh, 45h, 24h, 40h
db 24h, 52h, 47h, 48h, 4fh, 80h, 52h, 40h, 48h, 4bh, 48h
db 4dh, 46h, 24h, 53h, 4eh, 56h, 40h, 51h, 43h, 52h
if _LCD_40x1
db 24h
else
db 80h
endif
db 53h, 47h, 44h, 24h, 4bh, 48h, 46h, 47h, 53h
db 47h, 4eh, 54h, 52h, 44h, 32h, 80h, ffh
_lhmsg03:
; "It is locked.[ENTER]"
db 12h, 53h, 24h, 48h, 52h, 24h, 4bh, 4eh, 42h, 4ah, 44h, 43h, 32h, 80h, ffh
_lhmsg04:
db 1dh, 47h, 44h, 24h, 4fh, 40h, 48h, 4dh, 53h, 48h, 4dh, 46h
if _LCD_40x1
; "The painting shows a dog wearing[ENTER]a collar with a key.[ENTER]"
db 24h
else
; "The painting[ENTER]shows a dog[ENTER]wearing a collar[ENTER]with a key.[ENTER]"
db 80h
endif
db 52h, 47h, 4eh, 56h, 52h, 24h, 40h, 24h, 43h, 4eh, 46h
if _LCD_40x1
db 24h
else
db 80h
endif
db 56h, 44h, 40h, 51h, 48h, 4dh, 46h
if _LCD_40x1
db 80h
else
db 24h
endif
db 40h, 24h, 42h, 4eh, 4bh, 4bh, 40h, 51h
if _LCD_40x1
db 24h
else
db 80h
endif
db 56h, 48h, 53h, 47h, 24h, 40h, 24h, 4ah, 44h, 58h, 32h, 80h, ffh
_lhmsg05:
db 0ah, 24h, 4ah, 44h, 58h, 24h, 45h, 40h, 4bh, 4bh, 52h, 24h, 53h, 4eh
if _LCD_40x1
; "A key falls to the floor.[ENTER]"
db 24h
else
; "A key falls to[ENTER]the floor.[ENTER]"
db 80h
endif
db 53h, 47h, 44h, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_lhmsg06:
; "Nothing special.[ENTER]"
db 17h, 4eh, 53h, 47h, 48h, 4dh, 46h, 24h, 52h, 4fh, 44h, 42h, 48h, 40h, 4bh
db 32h, 80h, ffh
_lhmsg07:
; "Bad decision![ENTER]"
db 0bh, 40h, 43h, 24h, 43h, 44h, 42h, 48h, 52h, 48h, 4eh, 4dh, 25h, 80h, ffh
_lhmsg08:
; "Hmm...[ENTER]"
db 11h, 4ch, 4ch, 32h, 32h, 32h, 80h, ffh
_lhmsg09:
db 0ch, 40h, 4bh, 4bh, 24h, 44h, 4ch, 44h, 51h, 46h, 44h, 4dh, 42h, 58h
if _LCD_40x1
; "Call emergency services if you[ENTER]are stuck.[ENTER]"
db 24h
else
; "Call emergency[ENTER]services if you[ENTER]are stuck.[ENTER]"
db 80h
endif
db 52h, 44h, 51h, 55h, 48h, 42h, 44h, 52h, 24h, 48h, 45h, 24h, 58h, 4eh, 54h
db 80h, 40h, 51h, 44h, 24h, 52h, 53h, 54h, 42h, 4ah, 32h, 80h, ffh
_lhmsg0A:
db 22h, 4eh, 54h, 24h, 41h, 51h, 44h, 40h, 4ah, 24h, 4eh, 4fh, 44h, 4dh
if _LCD_40x1
; "You break open the iron gate.[ENTER]"
db 24h
else
; "You break open[ENTER]the iron gate.[ENTER]"
db 80h
endif
db 53h, 47h, 44h, 24h, 48h, 51h, 4eh, 4dh
db 24h, 46h, 40h, 53h, 44h, 32h, 80h, ffh
; "It does not fit.[ENTER]"
_lhmsg0B:
db 12h, 53h, 24h, 43h, 4eh, 44h, 52h, 24h, 4dh
db 4eh, 53h, 24h, 45h, 48h, 53h, 32h, 80h, ffh
;-----------------------------------------------------------------------------
; CHANGES:
; - R1: added UP and DOWN directions
;=============================================================================
