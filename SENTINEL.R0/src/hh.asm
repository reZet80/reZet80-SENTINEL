;=============================================================================
; SENTINEL Haunted House (hh.asm) [last modified: 2026-02-20]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
; directions N S E W
_dir:
; 00h: outside
db 00h, 00h, 00h, 00h
; 01h: foyer
db 01h, 08h, 02h, 09h
; 02h: living room
db 02h, 02h, 03h, 01h
; 03h: dining room
db 03h, 04h, 03h, 02h
; 04h: kitchen
db 03h, 05h, 04h, 08h
; 05h: breakfast room
db 04h, 05h
_dir_05h:
db 05h, 05h
; 06h: servants quarters
db 07h, 06h, 06h, 05h
; 07h: servants quarters
db 07h, 06h, 07h, 07h
; 08h: den
db 01h, 08h, 04h, 08h
; 09h: hall east end
db 0bh, 09h, 01h, 0ah
; 0ah: hall west end
db 0dh
_dir_0ah:
db 0ah, 09h, 0ah
; 0bh: green bedroom
db 0bh, 09h, 0bh, 0bh
; 0ch: secret passage
db 0ch, 0ch, 0bh, 0dh
; 0dh: blue bedroom
db 0dh, 0ah, 0dh, 0dh
; 0eh: master bedroom
db 0ah, 0eh
_dir_0eh:
db 0eh, 0eh
; 0fh: library
db 0fh, 0fh, 0fh, 0eh
; 10h: dimly lit room
;db 10h, 12h, 11h, 13h
db 10h
_dir_10h:
db 10h, 10h, 10h
; 11h: dimly lit room
db 11h, 11h, 11h
_dir_11h:
db 11h
; 12h: dimly lit room
_dir_12h:
db 12h, 12h, 12h, 12h
; 13h: dimly lit room
db 13h, 13h, 13h
_dir_13h:
db 13h
; 14h: dimly lit room
_dir_14h:
db 14h, 14h, 13h, 14h
; 15h: dimly lit room
db 15h, 14h, 15h, 16h
; 16h: dimly lit room
db 16h, 17h, 15h, 16h
; 17h: dimly lit room
db 17h
_dir_17h:
db 17h, 17h
_obj_00h:
db 17h
;-----------------------------------------------------------------------------
; objects
; bit 7: can be picked up, bit 6: in inventory, bits 0-5: room number
db 00h	; 01h: DOOR
_obj_armor:
db 05h	; 02h: ARMOUR
db 06h	; 03h: CABINET
db 07h	; 04h: CABINET
_obj_door:
db 0ah	; 05h: DOOR
db 0bh	; 06h: PANEL
db 0dh	; 07h: PANEL
_obj_fire:
db 0eh	; 08h: FIRE
_obj_hole:
db 0fh	; 09h: HOLE
_obj_ceiling:
db 3fh	; 0ah: ROPE ON CEILING
db 10h	; 0bh: HOLE
_obj_ghost1:
db 11h	; 0ch: GHOST
_obj_ghost_1:
db 3fh	; 0dh: DEAD GHOST
_obj_ghost2:
db 12h	; 0eh: GHOST
_obj_ghost_2:
db 3fh	; 0fh: DEAD GHOST
_obj_ghost3:
db 13h	; 10h: GHOST
_obj_ghost_3:
db 3fh	; 11h: DEAD GHOST
db 14h	; 12h: (BOSS) GHOST
db 15h	; 13h: GHOST
db 16h	; 14h: GHOST
_obj_paper:
db 80h	; 15h: PAPER
_obj_knife:
db 82h	; 16h: KNIFE
_obj_scroll:
db 82h	; 17h: SCROLL
_obj_water:
db 84h	; 18h: WATER BUCKET
_obj_key:
db bfh	; 19h: KEY
_obj_rope:
db 8ch	; 1ah: ROPE
_obj_sword:
db 90h	; 1bh: SWORD
_obj_sign:
db 97h	; 1ch: SIGN
_obj_invisible:
db ffh	; 1dh: invisible ROPE
;-----------------------------------------------------------------------------
; Haunted House starts here
_hhentry:	ld iyl, 00h		; iyl = room number
		ld ix, _dir		; ptr to data
		ld hl, _ht		; welcome
		call _unpack
_hh0:		ld hl, _hy		; display "you are..."
		call _unpack
		ld hl, _h1
		ld a, iyl
		cp 10h
		jr c, _hh1
		ld hl, _h2
_hh1:		call _unpack
		ld a, iyl
		ld hl, _rooms		; display room description
		call _tabval
		ld a, iyl
		cp 18h			; game exit ?
		jp nc, _clientry	; back to CLI
		ld b, 1ch		; object no
		ld de, _obj_sign
_hh2:		ld a, (de)
		dec de
		and 3fh			; mask pick up and inventory bits
		cp iyl			; object in current room ?
		jr nz, _hh3
		ld a, b
		ld hl, _objs		; output object description
		call _tabval
_hh3:		djnz _hh2		; last object ?
_hh4:		ld a, 01h		; external CLI call
		call _cli
;-----------------------------------------------------------------------------
; evaluate command
; A[TTACK] A[RMOUR]
; C[LIMB] R[OPE]
; D[RINK] W[ATER]
; D[ROP] S[IGN]|S[WORD]
; E[AST] : go east
; I[NVENTORY] : list inventory
; J[UMP] H[OLE]
; K[ILL] G[HOST]
; L[OOK] : look around
; M[OVE] P[ANEL]
; N[ORTH] : go north
; O[PEN] D[OOR]|C[ABINET]
; P[OUR] W[ATER]
; R[EAD] P[APER]|S[CROLL]|S[IGN]|S[WORD]
; S[OUTH] : go south
; T[AKE] B[UCKET]|K[EY]|K[NIFE]|P[APER]|R[OPE]|S[CROLL]|S[IGN]|S[WORD]
; U[SE] K[EY]|R[OPE]
; W[EST] : go west
; Y[ELL] R[EZET80]
		ld l, 81h		; 1st buffer entry
		ld a, (hl)
		ld c, a			; c = verb
		cp 82h			; ESC ?
		jp z, _clientry		; back to CLI
		cp 15h			; 'L' ?
		jr nz, _eval01
_eval00:	rst 18h			; clear display
		jr _hh0
_eval01:	ld b, 00h
		cp 17h			; 'N' ?
		jr nz, _eval03
_eval02:	ld hl, _dir
		ld a, iyl
		add a, a
		add a, a		; * 4
		add a, b
		add a, l
		ld l, a
		ld a, (hl)
		ld iyl, a		; new room number
		jr _eval00
_eval03:	inc b
		cp 1ch			; 'S' ?
		jr z, _eval02
		inc b
		cp 0eh			; 'E' ?
		jr z, _eval02
		inc b
		cp 20h			; 'W' ?
		jr z, _eval02
		cp 12h			; 'I' ?
		jr nz, _eval07
		rst 18h			; clear display
		ld b, 1ch		; object no
		ld de, _obj_sign
_eval04:	ld a, (de)
		dec de
		and 40h			; object in inventory ?
		jr z, _eval05
		ld a, b
		ld hl, _invn		; output short object name
		call _tabval
_eval05:	djnz _eval04		; last object ?
_eval06:	jp _hh4
_eval07:	inc hl			; read noun
		ld a, l
		cp 0fh			; stay inside buffer
		jr z, _eval06
		ld a, (hl)
		cp 24h			; ' ' ?
		jr nz, _eval07
		inc hl
		ld a, (hl)
		ld iyh, a		; iyh = noun
		ld a, c
		cp 1dh			; 'T' ?
		jr nz, _eval11
		rst 18h			; clear display
		ld hl, _tcmd
		ld bc, 0800h		; b = number of items, c = counter
_eval08:	ld d, h
		ld e, l
		ld a, iyh
		cp (hl)			; noun matches ?
		jr nz, _eval09
		inc hl
		ld a, iyl
		cp (hl)			; room matches ?
		jr nz, _eval09
		ld hl, _msg_00		; object found
		call _unpack
_take:		ld hl, _obj_paper	; take
		ld a, c
		add l
		ld l, a
		ld (hl), 7fh		; object now in inventory
		jr _eval06
_eval09:	inc c			; next command
		inc de
		inc de
		ex de, hl
		djnz _eval08
_eval10:	ld hl, _msg_01		; object not found
		call _unpack
		jr _eval06
_eval11:	rst 18h			; clear display
		ld hl, _cmds
		ld b, 1ah		; number of commands
_eval12:	ld d, h
		ld e, l
		ld a, (hl)
		cp c			; verb matches ?
		jr nz, _eval15
		inc hl
		ld a, (hl)
		cp iyh			; noun matches ?
		jr nz, _eval15
		inc hl
		ld a, (hl)
		cp 3fh			; shall match room?
		jr z, _eval13
		cp iyl			; room matches ?
		jr nz, _eval15
_eval13:	inc hl
		ld a, (hl)
		cp 3fh			; shall match item?
		jr z, _eval14
		push hl
		ld hl, _obj_00h		; check if item in inventory
		call _tab
		pop hl
		and 40h			; bit 6 set ?
		jr z, _eval15
_eval14:	inc hl
		ld a, (hl)
		inc hl
		push hl
		ld h, (hl)
		ld l, a
		call _unpack		; display message
		pop hl
		inc hl
		ld a, (hl)
		inc hl
		ld h, (hl)
		ld l, a
		jp (hl)			; jump to action
_eval15:	ld hl, 0008h		; next command
		add hl, de
		djnz _eval12
		jr _eval10
;-----------------------------------------------------------------------------
; read sword
_act_0e:	ld hl, _dir_10h
		ld (hl), 12h		; dir[10h][S] = 12
		inc hl
		ld (hl), 11h		; dir[10h][E] = 11
		inc hl
		ld (hl), 13h		; dir[10h][W] = 13
		jr _jpeval06
;-----------------------------------------------------------------------------
; yell reZet80
_act_00:	db ddh, 36h, 74h, 3fh	; ld (ix+74h), 3fh - remove paper
		ld iyl, 01h		; room = foyer
_jpeval00:	jp _eval00
;-----------------------------------------------------------------------------
; move panel
_act_01:	ld iyl, 0ch		; room = secret passage
		jr _jpeval00
;-----------------------------------------------------------------------------
; use key
_act_02:	db ddh, 36h, 29h, 0eh	; ld (ix+29h), 0eh - dir[0ah][S] = 0E
		ld a, 3fh
		ld (_obj_key), a	; remove key
		ld (_obj_door), a	; remove door
		ld iyl, 0eh		; room = master bedroom
		jr _jpeval00
;-----------------------------------------------------------------------------
; read sign
_act_03:	ld a, 18h		; trap door
_act_03_:	ld hl, _dir_17h
		ld (hl), a		; dir[17h][S] = 18|19
		inc hl
		ld (hl), a		; dir[17h][E] = 18|19
		inc hl
		ld (hl), a		; dir[17h][W] = 18|19
_jpeval06:	jp _eval06
;-----------------------------------------------------------------------------
; drop sign
_act_04:	db ddh, 36h, 7bh, 97h	; ld (ix+7bh), 97h
		ld a, 19h		; escape
		jr _act_03_
;-----------------------------------------------------------------------------
; drop sword
_act_05:	db ddh, 36h, 7ah, 3fh	; ld (ix+7ah), 3fh - remove sword
		db ddh, 36h, 50h, 15h	; ld (ix+50h), 15h - dir[14h][N] = 15
		jr _jpeval06
;-----------------------------------------------------------------------------
; find key
_act_06:	db ddh, 36h, 78h, 87h	; ld (ix+78h), 87h - key visible
		jr _jpeval06
;-----------------------------------------------------------------------------
; pour water
_act_07:	db ddh, 36h, 3ah, 0fh	; ld (ix+3ah), 0fh - dir[0eh][E] = 0F
		ld a, 3fh
		ld (_obj_fire), a	; remove fire
		ld (_obj_water), a	; remove water
		jr _jpeval06
;-----------------------------------------------------------------------------
; attack armour
_act_08:	ld a, 3fh
		ld (_obj_armor), a	; remove armor
		ld (_obj_knife), a 	; remove knife
		db ddh, 36h, 16h, 06h	; ld (ix+16h), 06h - dir[05h][E] = 06
		jr _jpeval06
;-----------------------------------------------------------------------------
; use rope
_act_09:	ld a, 3fh
		ld (_obj_hole), a	; remove hole
		ld (_obj_rope), a	; remove rope
		db ddh, 36h, 69h, 0fh	; ld (ix+69h), 0fh - rope on ceiling
		db ddh, 36h, 7ch, 7fh	; ld (ix+7ch), 7fh - invisible rope
		jr _jpeval06
;-----------------------------------------------------------------------------
; climb rope
_act_0a:	db ddh, 36h, 76h, 3fh	; ld (ix+76h), 3fh - remove scroll
		ld iyl, 10h		; room = upstairs
		jr _jpeval00
;-----------------------------------------------------------------------------
; kill ghost in room 11
_act_0b:	db ddh, 36h, 47h, 10h	; ld (ix+47h), 10h - dir[11h][W] = 10
		ld hl, _obj_ghost_1
		ld a, 11h
_act_0b_:	ld (hl), a		; dead ghost visible
		dec hl
		ld (hl), 3fh		; remove ghost
		jr _jpeval06
;-----------------------------------------------------------------------------
; kill ghost in room 12
_act_0c:	db ddh, 36h, 48h, 10h	; ld (ix+48h), 10h - dir[12h][N] = 10
		ld hl, _obj_ghost_2
		ld a, 12h
		jr _act_0b_
;-----------------------------------------------------------------------------
; kill ghost in room 13
_act_0d:	ld hl, _dir_13h
		ld (hl), 14h		; dir[13h][W] = 14
		dec hl
		ld (hl), 10h		; dir[13h][E] = 10
		ld hl, _obj_ghost_3
		ld a, 13h
		jr _act_0b_
;-----------------------------------------------------------------------------
; table lookup [uses A (input)(output), HL (input)]
_tab:		add a, l
		jr nc, _tab1
		inc h			; crossed 256-byte boundary
_tab1:		ld l, a
		ld a, (hl)
		inc hl
		ret
;-----------------------------------------------------------------------------
; load table value [uses A (input), HL (input)(output)]
_tabval:	add a, a		; * 2
		call _tab
		ld h, (hl)
		ld l, a
;-----------------------------------------------------------------------------
; unpack & display string [uses A, HL (ptr str input), preserves  B, C, D, E]
_unpack:	push bc
		push de
		ld de, 0005h
_unpack0:	ld b, 08h
		ld a, (hl)
		inc hl
_unpack1:	rlca
		rl d
		dec e
		jr nz, _unpack3
		ld c, a
		ld a, d
		;TODO code
		cp 1bh
		jr nz, _unpackA
		add a, 0dh		; adjust for '.'
		jr _unpackD
_unpackA:	cp 1ch
		jr nz, _unpackB
		add a, 0ah		; adjust for ','
		jr _unpackD
_unpackB:	cp 1dh
		jr nz, _unpackC
		add a, 04h		; adjust for '''
		jr _unpackD
_unpackC:	cp 1eh			; ENTER ?
		jr z, _unpack4
		cp 1fh			; EOS ?
		jr z, _unpack5
_unpackD:	add a, 0ah		; jump over 0-9
		exx
		rst 28h			; display char
		exx
_unpack2:	ld a, c
		ld de, 0005h
_unpack3:	djnz _unpack1
		jr _unpack0
_unpack4:	exx
		rst 38h			; wait for key press
		rst 18h			; clear display
		exx
		jr _unpack2
_unpack5:	pop de
		pop bc
		ret
;-----------------------------------------------------------------------------
; 5-bit packed chars, no numbers, 30 chars and punctuation symbols max:
; 00h = 00000b: 'A'
; 01h = 00001b: 'B'
; 02h = 00010b: 'C'
; 03h = 00011b: 'D'
; 04h = 00100b: 'E'
; 05h = 00101b: 'F'
; 06h = 00110b: 'G'
; 07h = 00111b: 'H'
; 08h = 01000b: 'I'
; 09h = 01001b: 'J'
; 0ah = 01010b: 'K'
; 0bh = 01011b: 'L'
; 0ch = 01100b: 'M'
; 0dh = 01101b: 'N'
; 0eh = 01110b: 'O'
; 0fh = 01111b: 'P'
; 10h = 10000b: 'Q'
; 11h = 10001b: 'R'
; 12h = 10010b: 'S'
; 13h = 10011b: 'T'
; 14h = 10100b: 'U'
; 15h = 10101b: 'V'
; 16h = 10110b: 'W'
; 17h = 10111b: 'X'
; 18h = 11000b: 'Y'
; 19h = 11001b: 'Z'
; 1ah = 11010b: ' '
; 1bh = 11011b: '.'
; 1ch = 11100b: ','
; 1dh = 11101b: '''
; 1eh = 11110b: ENTER
; 1fh = 11111b: EOS
;-----------------------------------------------------------------------------
; "HAUNTED HOUSE[ENTER]"
_ht:
db 38h, 28h, d9h, 90h, 7ah, 3bh, a9h, 22h, 7bh, ffh
; "YOU ARE "
_hy:
db c3h, a9h, a0h, 44h, 9ah, ffh
; "AT THE[ENTER]"
_h1:
db 04h, f5h, 33h, 93h, dfh
; "IN A[ENTER]"
_h2:
db 43h, 74h, 0fh, 7fh
;-----------------------------------------------------------------------------
; "OUTSIDE.[ENTER]" (original: "outside of the house")
_room_00:	db 75h, 27h, 24h, 0ch, 9bh, f7h, ffh
; "FOYER.[ENTER]"
_room_01:	db 2bh, b0h, 48h, efh, dfh
; "LIVING ROOM.[ENTER]"
_room_02:	db 5ah, 2ah, 86h, 9bh, 51h, 73h, 99h, bfh, 7fh
; "DINING ROOM.[ENTER]"
_room_03:	db 1ah, 1ah, 86h, 9bh, 51h, 73h, 99h, bfh, 7fh
; "KITCHEN.[ENTER]"
_room_04:	db 52h, 26h, 23h, 91h, bbh, f7h, ffh
; "BREAKFAST ROOM.[ENTER]"
_room_05:	db 0ch, 48h, 05h, 14h, 12h, 9eh, a2h, e7h, 33h, 7eh, ffh
; "SERVANTS ROOMS.[ENTER]" (original: "Servants quarters")
_room_06:
_room_07:	db 91h, 23h, 50h, 36h, 72h, d4h, 5ch, e6h, 4bh, 7eh, ffh
; "DEN.[ENTER]"
_room_08:	db 19h, 1bh, bfh, 7fh
; "HALL, EAST END.[ENTER]" (original: "east end of the hall")
_room_09:	db 38h, 16h, beh, 68h, 80h, 94h, f4h, 46h, 8fh, 7eh, ffh
; "HALL, WEST END.[ENTER]" (original: "west end of the hall")
_room_0a:	db 38h, 16h, beh, 6ah, c4h, 94h, f4h, 46h, 8fh, 7eh, ffh
; "GREEN BEDROOM.[ENTER]"
_room_0b:	db 34h, 48h, 46h, e8h, 24h, 1ch, 5ch, e6h, 6fh, dfh
; "SECRET PASSAGE.[ENTER]"
_room_0c:	db 91h, 05h, 12h, 4fh, 4fh, 04h, a4h, 03h, 13h, 7eh, ffh
; "BLUE BEDROOM.[ENTER]"
_room_0d:	db 0ah, e8h, 4dh, 04h, 83h, 8bh, 9ch, cdh, fbh, ffh
; "MASTER BEDROOM.[ENTER]"
_room_0e:	db 60h, 25h, 32h, 47h, 41h, 20h, e2h, e7h, 33h, 7eh, ffh
; "LIBRARY.[ENTER]"
_room_0f:	db 5ah, 03h, 10h, 47h, 1bh, f7h, ffh
; "DIMLY LIT ROOM.[ENTER]"
_room_10:
_room_11:
_room_12:
_room_13:
_room_14:
_room_15:
_room_16:
_room_17:	db 1ah, 18h, bch, 69h, 68h, 9eh, a2h, e7h, 33h, 7eh, ffh
; "CELLAR.[ENTER]YOU FELL THROUGH[ENTER]A TRAP DOOR TO[ENTER]YOUR DEATH.[ENTER]"
_room_18:	db 11h, 16h, b0h, 47h, 7eh, c3h, a9h, a2h, 91h, 6bh, d4h
		db cfh, 17h, 50h, c7h, f0h, 35h, 38h, 81h, fah, 1bh, 9dh
		db 1dh, 4dh, deh, c3h, a9h, 1dh, 0ch, 80h, 99h, f7h, efh, ffh
; "PARK.[ENTER]YOU ESCAPED TO[ENTER]A BALCONY AND[ENTER]CLIMBED DOWN[ENTER]"
; "A HUGE TREE.[ENTER]CONGRATULATIONS.[ENTER]YOU MADE IT.[ENTER]"
; (original: "You walk through a door and find yourself on a balcony."
;  You climb down a tree and escape to safety!Congratulations!You made it!")
_room_19:	db 78h, 22h, adh, fbh, 0eh, a6h, 89h, 21h, 01h, e4h, 1eh, a6h
		db efh, 03h, 41h, 02h, c4h, e6h, e3h, 40h, 68h, fch, 25h, a1h
		db 81h, 20h, f4h, 37h, 59h, beh, 06h, 8fh, 43h, 13h, 53h, 89h
		db 09h, bfh, 09h, cdh, 34h, 41h, 3ah, 2ch, 13h, 43h, 9bh
		db 2dh, fbh, 0eh, a6h, 98h, 01h, 93h, 48h, 9eh, fdh, ffh
;-----------------------------------------------------------------------------
; "THE FRONT DOOR[ENTER]IS CLOSED.[ENTER]"
_obj_01:	db 99h, c9h, a2h, c5h, cdh, 9eh, 86h, e7h, 47h
		db c8h, 96h, 84h, b7h, 48h, 83h, dfh, bfh
; "AN ANIMATED SUIT[ENTER]OF ARMOUR BLOCKS[ENTER]YOUR WAY.[ENTER]"
_obj_02:	db 03h, 74h, 06h, a1h, 80h, 99h, 07h, a9h, 51h, 13h
		db f3h, 8bh, a0h, 45h, 8eh, a4h, 74h, 15h, b8h, 4ah
		db 97h, b0h, eah, 47h, 56h, 06h, 37h, efh, ffh
; "A CABINET IS ON[ENTER]ONE WALL.[ENTER]"
; (original: "There is a cabinet on one wall.")
_obj_03:
_obj_04:	db 06h, 84h, 00h, a1h, a4h, 9eh, 91h, 2dh, 39h
		db beh, 73h, 49h, abh, 01h, 6bh, dfh, bfh
; "A DOOR BARS THE[ENTER]WAY SOUTH.[ENTER]"
_obj_05:	db 06h, 86h, e7h, 47h, 41h, 04h, 65h, a9h, 9ch
		db 9eh, b0h, 31h, a9h, 3ah, 93h, 3eh, fdh, ffh
; "ON THE WEST WALL[ENTER]YOU SEE A PANEL.[ENTER]"
; (original: "There's a panel on the west wall.")
_obj_06:	db 73h, 75h, 33h, 93h, 56h, 24h, a7h, abh, 01h, 6bh, f6h
		db 1dh, 4dh, 48h, 84h, d0h, 34h, f0h, 34h, 8bh, dfh, bfh
; "ON THE EAST WALL[ENTER]YOU SEE A PANEL.[ENTER]"
; (original: "There's a panel on the east wall.")
_obj_07:	db 73h, 75h, 33h, 93h, 44h, 04h, a7h, abh, 01h, 6bh, f6h
		db 1dh, 4dh, 48h, 84h, d0h, 34h, f0h, 34h, 8bh, dfh, bfh
; "A WALL OF RAGING[ENTER]FIRE BLOCKS THE[ENTER]WAY EAST.[ENTER]"
_obj_08:	db 06h, ach, 05h, afh, 4eh, 2eh, a2h, 03h, 21h
		db a6h, f1h, 51h, 12h, 68h, 2bh, 70h, 95h, 2dh
		db 4ch, e4h, f5h, 81h, 8dh, 10h, 12h, 9eh, fdh, ffh
; "THERE IS A HOLE[ENTER]IN THE CEILING.[ENTER]"
_obj_09:	db 99h, c9h, 12h, 69h, 12h, d0h, 34h, 77h, 2ch, 9eh
		db 43h, 75h, 33h, 93h, 42h, 22h, 16h, 86h, 9bh, 7eh, ffh
; "A ROPE IS[ENTER]STRETCHING FROM[ENTER]THE GROUND TO[ENTER]THE HOLE IN[ENTER]
;  THE CEILING.[ENTER]"
_obj_0a:	db 06h, a2h, e7h, 93h, 48h, 97h, a5h, 38h, 92h, 62h
		db 3ah, 1ah, 6dh, 16h, 2eh, 67h, a6h, 72h, 68h, d1h
		db 75h, 1ah, 3dh, 4dh, deh, 99h, c9h, a3h, b9h, 64h, d2h
		db 1bh, e9h, 9ch, 9ah, 11h, 10h, b4h, 34h, dbh, f7h, ffh
; "THERE IS A HOLE[ENTER]IN THE FLOOR.[ENTER]"
_obj_0b:	db 99h, c9h, 12h, 69h, 12h, d0h, 34h, 77h, 2ch, 9eh
		db 43h, 75h, 33h, 93h, 45h, 5bh, 9dh, 1dh, fbh, ffh
; "A GHOST IS HERE.[ENTER]" (original: There is a ghost here.)
_obj_0c:
_obj_0e:
_obj_10:
_obj_12:
_obj_13:
_obj_14:	db 06h, 8ch, 77h, 4ah, 7ah, 44h, b4h, 72h, 44h, 9bh, f7h, ffh
; "A DEAD GHOST IS[ENTER]ON THE FLOOR.[ENTER]"
; (original: The body of a dead ghost is on the floor.)
_obj_0d:
_obj_0f:
_obj_11:	db 06h, 86h, 40h, 0fh, 46h, 3bh, a5h, 3dh, 22h, 5eh
		db 73h, 75h, 33h, 93h, 45h, 5bh, 9dh, 1dh, fbh, ffh
; "A CRUMPLED PIECE[ENTER]OF PAPER IS ON[ENTER]THE GROUND.[ENTER]"
; (original: "There is a crumpled piece of paper on the ground."
_obj_15:	db 06h, 85h, 1ah, 31h, ebh, 20h, f4h, f4h, 10h, 44h
		db f3h, 8bh, a7h, 81h, e4h, 8eh, 91h, 2dh, 39h, beh
		db 99h, c9h, a3h, 45h, d4h, 68h, f7h, efh, ffh
; "IN THE MIDDLE OF[ENTER]THE ROOM A KNIFE[ENTER]IS LEVITATING.[ENTER]"
; (original: "A knife is levitating in the middle of the room.")
_obj_16:	db 43h, 75h, 33h, 93h, 4ch, 40h, c6h, b2h, 69h, c5h, f4h
		db ceh, 4dh, 45h, ceh, 66h, 81h, a5h, 35h, 05h, 27h, 91h
		db 2dh, 2ch, 95h, 44h, c1h, 34h, 34h, dbh, f7h, ffh
; "A SCROLL IS ON[ENTER]THE GROUND.[ENTER]"
; (original: "There is a mysterious scroll on the ground.")
_obj_17:	db 06h, a4h, 28h, b9h, 6bh, d2h, 25h, a7h, 37h
		db d3h, 39h, 34h, 68h, bah, 8dh, 1eh, fdh, ffh
; "YOU SEE A BUCKET[ENTER]OF WATER.[ENTER]"
; (original: "A bucket of water is on the floor.")
_obj_18:	db c3h, a9h, a9h, 10h, 9ah, 06h, 83h, 41h, 28h
		db 93h, f3h, 8bh, abh, 02h, 64h, 8eh, fdh, ffh
; "A KEY IS HERE.[ENTER]"
_obj_19:	db 06h, 94h, 4ch, 69h, 12h, d1h, c9h, 12h, 6fh, dfh
; "YOU SEE A ROPE.[ENTER]"
; (original: "A rope is nearby.")
_obj_1a:	db c3h, a9h, a9h, 10h, 9ah, 06h, a2h, e7h, 93h, 7eh, ffh
; "A MAGIC SWORD IS[ENTER]ON THE FLOOR.[ENTER]"
; (original: There is a magic sword on the floor.)
_obj_1b:	db 06h, 98h, 03h, 20h, 5ah, 95h, 9dh, 11h, e9h, 12h
		db f3h, 9bh, a9h, 9ch, 9ah, 2ah, dch, e8h, efh, dfh
; "A RUSTY OLD SIGN[ENTER]IS LAYING ON THE[ENTER]GROUND.[ENTER]"
; (original: There is a rusty old sign laying on the ground.)
_obj_1c:	db 06h, a3h, 49h, 4fh, 1ah, 72h, c7h, a9h, 20h
		db cdh, f2h, 25h, a5h, 83h, 08h, 69h, b4h, e6h
		db eah, 67h, 27h, 8dh, 17h, 51h, a3h, dfh, bfh
;-----------------------------------------------------------------------------
; "PAPER[ENTER]"
_invn_15:	db 78h, 1eh, 48h, fbh, ffh
; "KNIFE[ENTER]"
_invn_16:	db 53h, 50h, 52h, 7bh, ffh
; "SCROLL[ENTER]"
_invn_17:	db 90h, a2h, e5h, afh, dfh
; "WATER BUCKET[ENTER]"
_invn_18:	db b0h, 26h, 48h, e8h, 34h, 12h, 89h, 3fh, 7fh
; "KEY[ENTER]"
_invn_19:	db 51h, 31h, efh, ffh
; "ROPE[ENTER]"
_invn_1a:	db 8bh, 9eh, 4fh, 7fh
; "SWORD[ENTER]"
_invn_1b:	db 95h, 9dh, 11h, fbh, ffh
; "SIGN[ENTER]"
_invn_1c:	db 92h, 0ch, dfh, 7fh
;-----------------------------------------------------------------------------
; "OK[ENTER]"
; (original: OK.)
_msg_00:	db 72h, bdh, ffh
; "NO[ENTER]"
; (original: NO.)
_msg_01:	db 6bh, bdh, ffh
; "THE DOOR CAN'T[ENTER]BE OPENED.[ENTER]"
_msg_02:	db 99h, c9h, a1h, b9h, d1h, d0h, 80h, deh
		db cfh, c1h, 26h, 9ch, f2h, 34h, 83h, dfh, bfh
; "YOU MATERIALIZE[ENTER]INSIDE THE DOOR.[ENTER]"
_msg_03:	db c3h, a9h, a6h, 02h, 64h, 8ah, 00h, b4h, 64h, 9eh, 43h
		db 64h, 81h, 93h, 53h, 39h, 34h, 37h, 3ah, 3bh, f7h, ffh
; "IT'S EMPTY.[ENTER]"
_msg_04:	db 44h, fbh, 2dh, 11h, 8fh, 9eh, 37h, efh, ffh
; "YOU FIND A KEY.[ENTER]"
; (original: There is a key in it.)
_msg_05:	db c3h, a9h, a2h, a1h, a3h, d0h, 34h, a2h, 63h, 7eh, ffh
; "YOU NEED A KEY.[ENTER]"
; (original: You'll need a key to get through that door.)
_msg_06:	db c3h, a9h, a6h, 90h, 83h, d0h, 34h, a2h, 63h, 7eh, ffh
; "YOU JUST DIED.[ENTER]IT WAS POISON.[ENTER]"
; (original: You feel sick. In fact, you just died. It was poison!)
_msg_07:	db c3h, a9h, a4h, d2h, 53h, d0h, d0h, 41h, efh, c8h
		db 9eh, ach, 09h, 69h, eeh, 44h, 9ch, ddh, fbh, ffh
; "YOU FALL AND[ENTER]BREAK YOUR NECK.[ENTER]YOU ARE DEAD.[ENTER]"
; (original: You fall through the hole and break your neck. You are dead.)
_msg_08:	db c3h, a9h, a2h, 81h, 6bh, d0h, 1ah, 3fh, 06h, 24h
		db 02h, b5h, 87h, 52h, 3ah, 69h, 04h, adh, fbh, 0eh
		db a6h, 81h, 12h, 68h, 64h, 00h, f7h, efh, ffh
; "THE GHOST IS[ENTER]IMMUNE TO YOUR[ENTER]ATTACK.[ENTER]"
_msg_09:	db 99h, c9h, a3h, 1dh, d2h, 9eh, 91h, 2fh, 21h, 8ch, a3h, 49h
		db a9h, bbh, 58h, 75h, 23h, e0h, 4eh, 60h, 12h, b7h, efh, ffh
; "YOU CAN'T KILL A[ENTER]GHOST WITH YOUR[ENTER]BARE HANDS.[ENTER]"
_msg_0a:	db c3h, a9h, a1h, 01h, bdh, 9eh, 94h, 85h, afh, 40h
		db f1h, 8eh, e9h, 4fh, 56h, 44h, cfh, ach, 3ah, 91h
		db f0h, 41h, 12h, 68h, e0h, 68h, e5h, bfh, 7fh
; "IT SAYS, 'LOUD[ENTER]MAGIC WORD IS[ENTER]REZET'.[ENTER]"
; (original: It says, "Magic word - Plugh.")
_msg_0b:	db 44h, f5h, 20h, 62h, 5ch, d7h, 56h, eah, 0fh, cch, 01h, 90h
		db 2dh, 59h, d1h, 1eh, 91h, 2fh, 44h, 99h, 24h, fbh, bfh, 7fh
; "IT SAYS, 'ESCAPE[ENTER]FROM THE SECOND[ENTER]FLOOR'.[ENTER]"
; (original: "It says "There is escape from the second floor!")
_msg_0c:	db 44h, f5h, 20h, 62h, 5ch, d7h, 49h, 21h, 01h
		db e4h, f1h, 62h, e6h, 6ah, 67h, 26h, a4h, 41h
		db 39h, a3h, f1h, 56h, e7h, 47h, bbh, f7h, ffh
; "AN INSCRIPTION[ENTER]READS[ENTER]'GHOST KILLER'.[ENTER]
_msg_0d:	db 03h, 74h, 86h, c8h, 51h, 43h, e6h, 87h, 37h, d1h, 20h, 07h
		db 2fh, 74h, c7h, 74h, a7h, a5h, 21h, 6bh, 24h, 7bh, bfh, 7fh
; "IT SAYS, 'THREE[ENTER]EXITS FROM THIS[ENTER]ROOM ARE TRUE.[ENTER]
;  BUT THIS CLUE IS[ENTER]A BURDEN'.[ENTER]"
; (original: "The sign says 'There are three exits from this room.
;  Only one is true... You must know, but not be burdened by, this clue!'")
_msg_0e:	db 44h, f5h, 20h, 62h, 5ch, d7h, 66h, 78h, 90h, 9eh, 25h, d1h
		db 39h, 68h, b1h, 73h, 35h, 33h, a2h, 5eh, 8bh, 9ch, cdh, 02h
		db 24h, d4h, e3h, 42h, 6fh, c1h, a4h, f5h, 33h, a2h, 5ah, 12h
		db e8h, 4dh, 22h, 5eh, 06h, 83h, 48h, 8ch, 8dh, eeh, fdh, ffh
; "A WISE DECISION.[ENTER]"
_msg_0f:	db 06h, ach, 89h, 13h, 43h, 20h, 91h, 24h, 39h, bbh, f7h, ffh
; "A SUIT OF ARMOUR[ENTER]FLEES WHEN IT[ENTER]SEES YOUR KNIFE.[ENTER]"
; (original: "A suit of armour here flees when it spots your knife.")
_msg_10:	db 06h, a5h, 44h, 4fh, 4eh, 2eh, 81h, 16h, 3ah, 91h
		db f1h, 56h, 42h, 4bh, 56h, 39h, 1bh, a4h, 4fh, d2h
		db 21h, 25h, ach, 3ah, 91h, d2h, 9ah, 82h, 93h, 7eh, ffh
; "YOU ATTACH THE[ENTER]ROPE TO THE HOLE[ENTER]IN THE CEILING.[ENTER]"
; (original: "Instantly the rope unwinds and levitates to the hole in the ceiling!")
_msg_11:	db c3h, a9h, a0h, 4eh, 60h, 11h, f5h, 33h, 93h, d1h
		db 73h, c9h, a9h, bbh, 53h, 39h, 34h, 77h, 2ch, 9eh
		db 43h, 75h, 33h, 93h, 42h, 22h, 16h, 86h, 9bh, 7eh, ffh
; "YOU REACH THE[ENTER]SECOND FLOOR.[ENTER]"
; (original: "You drop everything you had to climb the rope. You reach the second floor.")
_msg_12:	db c3h, a9h, a8h, 90h, 02h, 3eh, a6h, 72h, 7ah
		db 44h, 13h, 9ah, 3dh, 15h, 6eh, 74h, 77h, efh, ffh
; "YOUR MAGIC SWORD[ENTER]ENABLES YOU TO[ENTER]KILL THE GHOST.[ENTER]"
_msg_13:	db c3h, a9h, 1dh, 30h, 06h, 40h, b5h, 2bh, 3ah, 23h
		db f1h, 1ah, 00h, ach, 92h, d6h, 1dh, 4dh, 4dh, deh
		db 52h, 16h, bdh, 4ch, e4h, d1h, 8eh, e9h, 4fh, 7eh, ffh
;-----------------------------------------------------------------------------
; room descriptions
_rooms:
dw _room_00, _room_01, _room_02, _room_03, _room_04, _room_05
dw _room_06, _room_07, _room_08, _room_09, _room_0a, _room_0b
dw _room_0c, _room_0d, _room_0e, _room_0f, _room_10, _room_11
dw _room_12, _room_13, _room_14, _room_15, _room_16, _room_17, _room_18
_objs:
dw _room_19
;-----------------------------------------------------------------------------
; object descriptions
dw _obj_01, _obj_02, _obj_03, _obj_04, _obj_05, _obj_06, _obj_07
_invn:
dw _obj_08, _obj_09, _obj_0a, _obj_0b, _obj_0c, _obj_0d, _obj_0e, _obj_0f
dw _obj_10, _obj_11, _obj_12, _obj_13, _obj_14, _obj_15, _obj_16, _obj_17
dw _obj_18, _obj_19, _obj_1a, _obj_1b, _obj_1c
;-----------------------------------------------------------------------------
; short object names in inventory
dw _invn_15, _invn_16, _invn_17, _invn_18
dw _invn_19, _invn_1a, _invn_1b, _invn_1c
;-----------------------------------------------------------------------------
; take command: noun, room
_tcmd:
db 19h, 00h	; TAKE PAPER
db 14h, 02h	; TAKE KNIFE
db 1ch, 02h	; TAKE SCROLL
db 0bh, 04h	; TAKE BUCKET
db 14h, 07h	; TAKE KEY
db 1bh, 0ch	; TAKE ROPE
db 1ch, 10h	; TAKE SWORD
db 1ch, 17h	; TAKE SIGN
;-----------------------------------------------------------------------------
; commands: verb, noun, room, item, message, jump (room/item=3fh don't care)
_cmds:
db 18h, 0dh, 00h, 3fh	; OPEN DOOR
dw _msg_02, _hh4
db 18h, 0dh, 0ah, 3fh	; OPEN DOOR
dw _msg_06, _hh4
db 22h, 1bh, 00h, 3fh	; YELL REZET80
dw _msg_03, _act_00
db 18h, 0ch, 06h, 3fh	; OPEN CABINET
dw _msg_04, _hh4
db 18h, 0ch, 07h, 3fh	; OPEN CABINET
dw _msg_05, _act_06
db 16h, 19h, 0bh, 3fh	; MOVE PANEL
dw _msg_00, _act_01
db 16h, 19h, 0dh, 3fh	; MOVE PANEL
dw _msg_00, _act_01
db 0dh, 1ch, 14h, 1bh	; DROP SWORD
dw _msg_00, _act_05
db 0dh, 1ch, 17h, 1ch	; DROP SIGN
dw _msg_00, _act_04
db 0dh, 20h, 3fh, 18h	; DRINK WATER
dw _msg_07, _clientry
db 13h, 11h, 10h, 3fh	; JUMP HOLE
dw _msg_08, _clientry
db 14h, 10h, 14h, 3fh	; KILL GHOST
dw _msg_09, _hh4
db 14h, 10h, 15h, 3fh	; KILL GHOST
dw _msg_0a, _hh4
db 14h, 10h, 16h, 3fh	; KILL GHOST
dw _msg_0a, _hh4
db 1bh, 19h, 3fh, 15h	; READ PAPER
dw _msg_0b, _hh4
db 1bh, 1ch, 3fh, 17h	; READ SCROLL
dw _msg_0c, _hh4
db 1bh, 1ch, 3fh, 1bh	; READ SWORD
dw _msg_0d, _act_0e
db 1bh, 1ch, 17h, 1ch	; READ SIGN
dw _msg_0e, _act_03
db 1eh, 14h, 0ah, 19h	; USE KEY
dw _msg_00, _act_02
db 19h, 20h, 0eh, 18h	; POUR WATER
dw _msg_0f, _act_07
db 0ah, 0ah, 05h, 16h	; ATTACK ARMOUR
dw _msg_10, _act_08
db 1eh, 1bh, 0fh, 1ah	; USE ROPE
dw _msg_11, _act_09
db 0ch, 1bh, 0fh, 1dh	; CLIMB ROPE
dw _msg_12, _act_0a
db 14h, 10h, 11h, 1bh	; KILL GHOST
dw _msg_13, _act_0b
db 14h, 10h, 12h, 1bh	; KILL GHOST
dw _msg_13, _act_0c
db 14h, 10h, 13h, 1bh	; KILL GHOST
dw _msg_13, _act_0d
;-----------------------------------------------------------------------------
; original bugs:
; - take bucket/key/knife/paper/rope/scroll/sign/sword only once
; - empty cabinet after key taken
; - take key only if cabinet open
; - kill ghosts only once
;-----------------------------------------------------------------------------
; original strings not used:
; - "I DON'T UNDERSTAND."
; - "WHAT?"
; - "WHAT SHOULD I DO WITH IT?"
; - "THERE'S NOT ONE HERE."
; - "YOU AREN'T CARRYING IT."
; - "THE KNIFE FLOATS OUT OF YOUR REACH."
; - "DON'T BE RIDICULOUS!"
; - "THE GROUND IS WET. THE BUCKET MAGICALLY REFILLS!"
; - "ARE YOU JUST GOING TO WALK RIGHT THROUGH THAT RAGING FIRE?"
; - "THE GHOST WILL NOT LET YOU PASS!"
; - "OUCH! YOU HURT YOUR HAND."
; - "THE POOR THING'S ALREADY DEAD."
; - "SUDDENLY THE KNIFE WHOOSHES DOWN AND SLITS YOUR THROAT! YOU ARE DEAD."
; - "QUIT"
;=============================================================================
