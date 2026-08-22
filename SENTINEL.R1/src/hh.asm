;=============================================================================
; SENTINEL Haunted House (hh.asm) [last modified: 2026-07-26]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
; Haunted House starts here
_hhentry:	ld iyl, 00h		; iyl = room number
		ld ix, _dir		; ptr to data
		ld de, _ht		; welcome
		call _lcdtext0
_hh0:		ld de, _hy		; display "you are..."
		call _lcdtext0
		ld de, _h1
		ld a, iyl
		cp 10h
		jr c, _hh1
		ld de, _h2
_hh1:		call _lcdtext0
		ld a, iyl
		ld hl, _rooms		; display room description
		call _tabval
		call _lcdtext0
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
		push bc
		call _lcdtext0
		pop bc
		ex de, hl
_hh3:		djnz _hh2		; last object ?
_hh4:		ld a, 01h		; external CLI call
		call _cli
;-----------------------------------------------------------------------------
; evaluate command
		ld l, 81h		; 1st buffer entry
		ld a, (hl)
		ld c, a			; c = verb
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
		push bc
		push de
		call _tabval
		call _lcdtext0
		pop de
		pop bc
_eval05:	djnz _eval04		; last object ?
_eval06:	jr _hh4
_eval07:	inc hl			; read noun
		ld a, l
if _LCD_40x1
		cp a8h			; stay inside buffer
else
		cp 90h			; stay inside buffer
endif
		jr z, _eval06
		ld a, (hl)
		cp ffh
		jr z, _eval088
		cp 24h			; ' ' ?
		jr nz, _eval07
		inc hl
		ld a, (hl)
		call _toupper		; to upper case
_eval088:	ld iyh, a		; iyh = noun
		ld a, c
		cp 1dh			; 'T' ?
		jr nz, _eval11
		ld hl, _tcmd
		ld bc, 08h		; b = number of items/commands
_eval08:	ld d, h
		ld e, l
		ld a, (hl)
		cp iyh			; noun matches ?
		jr nz, _eval09
		inc hl
		ld a, (hl)		; item no
		ld hl, _obj_00h
		call _tab
		ld c, a
		and 80h			; bit 7 ?
		jr z, _eval09
		ld a, c
		and 3fh			; room no
		cp iyl			; room matches ?
		jr nz, _eval09
		ld (hl), 7fh		; object now in inventory
		ld de, _msg_00		; OK.
_eval99:	rst 18h			; clear display
		call _lcdtext0
		jr _eval06
_eval09:	inc de			; next take command
		inc de
		ex de, hl
		djnz _eval08
_eval10:	ld de, _msg_01		; NO!
		jr _eval99
_eval11:	ld hl, _cmds
		ld b, 1ah		; number of commands
_eval12:	push hl
		push bc
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
		ld hl, _obj_00h		; get item
		call _tab
		pop hl
		ld c, a
		and 3fh
		cp iyl			; room matches ?
		jr z, _eval14
		ld a, c
		and 40h			; bit 6 set ?
		jr z, _eval15
_eval14:	inc hl
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
_eval15:	pop bc
		pop hl
		ld de, 0008h
		add hl, de		; next command
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
		db ddh, 36h, 63h, 3fh	; ld (ix+63h), 3fh - cabinet invisible
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
; take command: noun, item
_tcmd:
db 19h, 15h	; TAKE PAPER
db 14h, 16h	; TAKE KNIFE
db 1ch, 17h	; TAKE SCROLL
db 0bh, 18h	; TAKE BUCKET
db 14h, 19h	; TAKE KEY
db 1bh, 1ah	; TAKE ROPE
db 1ch, 1bh	; TAKE SWORD
db 1ch, 1ch	; TAKE SIGN
;-----------------------------------------------------------------------------
; commands: verb, noun, room, item, message, jump (room/item=3fh don't care)
_cmds:
db 18h, 0dh, 00h, 01h	; OPEN DOOR
dw _msg_02, _hh4
db 18h, 0dh, 0ah, 05h	; OPEN DOOR
dw _msg_06, _hh4
db 22h, 1bh, 00h, 3fh	; YELL REZET
dw _msg_03, _act_00
db 18h, 0ch, 06h, 03h	; OPEN CABINET
dw _msg_04, _hh4
db 18h, 0ch, 07h, 04h	; OPEN CABINET
dw _msg_05, _act_06
db 16h, 19h, 0bh, 06h	; MOVE PANEL
dw _msg_00, _act_01
db 16h, 19h, 0dh, 07h	; MOVE PANEL
dw _msg_00, _act_01
db 0dh, 1ch, 14h, 1bh	; DROP SWORD
dw _msg_00, _act_05
db 0dh, 1ch, 17h, 1ch	; DROP SIGN
dw _msg_00, _act_04
db 0dh, 20h, 3fh, 18h	; DRINK WATER
dw _msg_07, _clientry
db 13h, 11h, 10h, 0bh	; JUMP HOLE
dw _msg_08, _clientry
db 14h, 10h, 14h, 12h	; KILL GHOST
dw _msg_09, _hh4
db 14h, 10h, 15h, 13h	; KILL GHOST
dw _msg_0a, _hh4
db 14h, 10h, 16h, 14h	; KILL GHOST
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
_ht:
; "Haunted House[ENTER]"
db 11h, 40h, 54h, 4dh, 53h, 44h, 43h, 24h, 11h, 4eh, 54h, 52h, 44h, 80h, ffh
_hy:
; "You are "
db 22h, 4eh, 54h, 24h, 40h, 51h, 44h, 24h, ffh
_h1:
db 40h, 53h, 24h, 53h, 47h, 44h
if _LCD_40x1
; "at the "
db 24h
else
; "at the[ENTER]"
db 80h
endif
db ffh
_h2:
db 48h, 4dh, 24h, 40h
if _LCD_40x1
; "in a "
db 24h
else
; "in a[ENTER]"
db 80h
endif
db ffh
;-----------------------------------------------------------------------------
_room_00:
; "outside.[ENTER]"
db 4eh, 54h, 53h, 52h, 48h, 43h, 44h, 32h, 80h, ffh
_room_01:
; "foyer.[ENTER]"
db 45h, 4eh, 58h, 44h, 51h, 32h, 80h, ffh
_room_02:
; "living room.[ENTER]"
db 4bh, 48h, 55h, 48h, 4dh, 46h, 24h, 51h, 4eh, 4eh, 4ch, 32h, 80h, ffh
_room_03:
; "dining room.[ENTER]"
db 43h, 48h, 4dh, 48h, 4dh, 46h, 24h, 51h, 4eh, 4eh, 4ch, 32h, 80h, ffh
_room_04:
; "kitchen.[ENTER]"
db 4ah, 48h, 53h, 42h, 47h, 44h, 4dh, 32h, 80h, ffh
; "breakfast room.[ENTER]"
_room_05:
db 41h, 51h, 44h, 40h, 4ah, 45h, 40h, 52h
db 53h, 24h, 51h, 4eh, 4eh, 4ch, 32h, 80h, ffh
_room_06:
_room_07:
; "servants rooms.[ENTER]"
db 52h, 44h, 51h, 55h, 40h, 4dh, 53h, 52h
db 24h, 51h, 4eh, 4eh, 4ch, 52h, 32h, 80h, ffh
_room_08:
; "den.[ENTER]"
db 43h, 44h, 4dh, 32h, 80h, ffh
_room_09:
; "hall, east end.[ENTER]"
db 47h, 40h, 4bh, 4bh, 30h, 24h, 44h, 40h
db 52h, 53h, 24h, 44h, 4dh, 43h, 32h, 80h, ffh
_room_0a:
; "hall, west end.[ENTER]"
db 47h, 40h, 4bh, 4bh, 30h, 24h, 56h, 44h
db 52h, 53h, 24h, 44h, 4dh, 43h, 32h, 80h, ffh
_room_0b:
; "green bedroom.[ENTER]"
db 46h, 51h, 44h, 44h, 4dh, 24h, 41h, 44h
db 43h, 51h, 4eh, 4eh, 4ch, 32h, 80h, ffh
_room_0c:
; "secret passage.[ENTER]"
db 52h, 44h, 42h, 51h, 44h, 53h, 24h, 4fh
db 40h, 52h, 52h, 40h, 46h, 44h, 32h, 80h, ffh
_room_0d:
; "blue bedroom.[ENTER]"
db 41h, 4bh, 54h, 44h, 24h, 41h, 44h, 43h, 51h, 4eh, 4eh, 4ch, 32h, 80h, ffh
_room_0e:
; "master bedroom.[ENTER]"
db 4ch, 40h, 52h, 53h, 44h, 51h, 24h, 41h
db 44h, 43h, 51h, 4eh, 4eh, 4ch, 32h, 80h, ffh
_room_0f:
; "library.[ENTER]"
db 4bh, 48h, 41h, 51h, 40h, 51h, 58h, 32h, 80h, ffh
_room_10:
_room_11:
_room_12:
_room_13:
_room_14:
_room_15:
_room_16:
_room_17:
; "dimly lit room.[ENTER]"
db 43h, 48h, 4ch, 4bh, 58h, 24h, 4bh, 48h
db 53h, 24h, 51h, 4eh, 4eh, 4ch, 32h, 80h, ffh
_room_18:
db 42h, 44h, 4bh, 4bh, 40h, 51h, 32h
if _LCD_40x1
; "cellar. You fell[ENTER]through a trap door to your death.[ENTER]"
db 24h
else
; "cellar.[ENTER]You fell through[ENTER]a trap door to[ENTER]"
; "your death.[ENTER]"
db 80h
endif
db 22h, 4eh, 54h, 24h, 45h, 44h, 4bh, 4bh
if _LCD_40x1
db 80h
else
db 24h
endif
db 53h, 47h, 51h, 4eh, 54h, 46h, 47h
if _LCD_40x1
db 24h
else
db 80h
endif
db 40h, 24h, 53h, 51h, 40h, 4fh, 24h, 43h, 4eh, 4eh, 51h, 24h, 53h, 4eh
if _LCD_40x1
db 24h
else
db 80h
endif
db 58h, 4eh, 54h, 51h, 24h, 43h, 44h, 40h, 53h, 47h, 32h, 80h, ffh
_room_19:
db 4fh, 40h, 51h, 4ah, 32h
if _LCD_40x1
; "park. You escaped to[ENTER]a balcony and climbed down "
; "a huge tree.[ENTER]Congratulations. You made it.[ENTER]"
db 24h
else
; "park.[ENTER]You escaped to[ENTER]a balcony and[ENTER]climbed down[ENTER]"
; "a huge tree.[ENTER]Congratulations.[ENTER]You made it.[ENTER]"
db 80h
endif
db 22h, 4eh, 54h, 24h, 44h, 52h, 42h, 40h, 4fh, 44h, 43h, 24h, 53h, 4eh
db 80h, 40h, 24h, 41h, 40h, 4bh, 42h, 4eh, 4dh, 58h, 24h, 40h, 4dh, 43h
if _LCD_40x1
db 24h
else
db 80h
endif
db 42h, 4bh, 48h, 4ch, 41h, 44h, 43h, 24h, 43h, 4eh, 56h, 4dh
if _LCD_40x1
db 24h
else
db 80h
endif
db 40h, 24h, 47h, 54h, 46h, 44h, 24h, 53h, 51h, 44h, 44h, 32h, 80h, 0ch
db 4eh, 4dh, 46h, 51h, 40h, 53h, 54h, 4bh, 40h, 53h, 48h, 4eh, 4dh, 52h, 32h
if _LCD_40x1
db 24h
else
db 80h
endif
db 22h, 4eh, 54h, 24h, 4ch, 40h, 43h, 44h, 24h, 48h, 53h, 32h, 80h, ffh
;-----------------------------------------------------------------------------
_obj_01:
db 1dh, 47h, 44h, 24h, 45h, 51h, 4eh, 4dh, 53h, 24h, 43h, 4eh, 4eh, 51h
if _LCD_40x1
; "The front door is closed.[ENTER]"
db 24h
else
; "The front door[ENTER]is closed.[ENTER]"
db 80h
endif
db 48h, 52h, 24h, 42h, 4bh, 4eh, 52h, 44h, 43h, 32h, 80h, ffh
_obj_02:
db 0ah, 4dh, 24h, 40h, 4dh, 48h, 4ch, 40h
db 53h, 44h, 43h, 24h, 52h, 54h, 48h, 53h
if _LCD_40x1
; "An animated suit of armour blocks[ENTER]your way.[ENTER]"
db 24h
else
; "An animated suit[ENTER]of armour blocks[ENTER]your way.[ENTER]"
db 80h
endif
db 4eh, 45h, 24h, 40h, 51h, 4ch, 4eh, 54h, 51h, 24h, 41h, 4bh, 4eh, 42h
db 4ah, 52h, 80h, 58h, 4eh, 54h, 51h, 24h, 56h, 40h, 58h, 32h, 80h, ffh
_obj_03:
_obj_04:
db 0ah, 24h, 42h, 40h, 41h, 48h, 4dh, 44h, 53h, 24h, 48h, 52h, 24h, 4eh, 4dh
if _LCD_40x1
; "A cabinet is on one wall.[ENTER]"
db 24h
else
; "A cabinet is on[ENTER]one wall.[ENTER]"
db 80h
endif
db 4eh, 4dh, 44h, 24h, 56h, 40h, 4bh, 4bh, 32h, 80h, ffh
_obj_05:
db 0ah, 24h, 43h, 4eh, 4eh, 51h, 24h, 41h, 40h, 51h, 52h, 24h, 53h, 47h, 44h
if _LCD_40x1
; "A door bars the way south.[ENTER]"
db 24h
else
; "A door bars the[ENTER]way south.[ENTER]"
db 80h
endif
db 56h, 40h, 58h, 24h, 52h, 4eh, 54h, 53h, 47h, 32h, 80h, ffh
_obj_06:
db 18h, 4dh, 24h, 53h, 47h, 44h, 24h, 56h
db 44h, 52h, 53h, 24h, 56h, 40h, 4bh, 4bh
if _LCD_40x1
; "On the west wall you see a panel.[ENTER]"
db 24h
else
; "On the west wall[ENTER]you see a panel.[ENTER]"
db 80h
endif
db 58h, 4eh, 54h, 24h, 52h, 44h, 44h, 24h, 40h
db 24h, 4fh, 40h, 4dh, 44h, 4bh, 32h, 80h, ffh
_obj_07:
db 18h, 4dh, 24h, 53h, 47h, 44h, 24h, 44h
db 40h, 52h, 53h, 24h, 56h, 40h, 4bh, 4bh
if _LCD_40x1
; "On the east wall you see a panel.[ENTER]"
db 24h
else
; "On the east wall[ENTER]you see a panel.[ENTER]"
db 80h
endif
db 58h, 4eh, 54h, 24h, 52h, 44h, 44h, 24h, 40h
db 24h, 4fh, 40h, 4dh, 44h, 4bh, 32h, 80h, ffh
_obj_08:
db 0ah, 24h, 56h, 40h, 4bh, 4bh, 24h, 4eh
db 45h, 24h, 51h, 40h, 46h, 48h, 4dh, 46h
if _LCD_40x1
; "A wall of raging fire blocks the[ENTER]way east.[ENTER]"
db 24h
else
; "A wall of raging[ENTER]fire blocks the[ENTER]way east.[ENTER]"
db 80h
endif
db 45h, 48h, 51h, 44h, 24h, 41h, 4bh, 4eh, 42h, 4ah, 52h, 24h, 53h
db 47h, 44h, 80h, 56h, 40h, 58h, 24h, 44h, 40h, 52h, 53h, 32h, 80h, ffh
_obj_09:
db 1dh, 47h, 44h, 51h, 44h, 24h, 48h, 52h, 24h, 40h, 24h, 47h, 4eh, 4bh, 44h
if _LCD_40x1
; "There is a hole in the ceiling.[ENTER]"
db 24h
else
; "There is a hole[ENTER]in the ceiling.[ENTER]"
db 80h
endif
db 48h, 4dh, 24h, 53h, 47h, 44h, 24h, 42h
db 44h, 48h, 4bh, 48h, 4dh, 46h, 32h, 80h, ffh
_obj_0a:
db 0ah, 24h, 51h, 4eh, 4fh, 44h, 24h, 48h, 52h
if _LCD_40x1
; "A rope is stretching from the ground to[ENTER]"
; "the hole in the ceiling.[ENTER]"
db 24h
else
; "A rope is[ENTER]stretching from[ENTER]the ground to[ENTER]"
; "the hole in[ENTER]the ceiling.[ENTER]"
db 80h
endif
db 52h, 53h, 51h, 44h, 53h, 42h, 47h, 48h, 4dh, 46h, 24h, 45h, 51h, 4eh, 4ch
if _LCD_40x1
db 24h
else
db 80h
endif
db 53h, 47h, 44h, 24h, 46h, 51h, 4eh, 54h, 4dh, 43h, 24h, 53h
db 4eh, 80h, 53h, 47h, 44h, 24h, 47h, 4eh, 4bh, 44h, 24h, 48h, 4dh
if _LCD_40x1
db 24h
else
db 80h
endif
db 53h, 47h, 44h, 24h, 42h, 44h, 48h, 4bh, 48h, 4dh, 46h, 32h, 80h, ffh
_obj_0b:
db 1dh, 47h, 44h, 51h, 44h, 24h, 48h, 52h, 24h, 40h, 24h, 47h, 4eh, 4bh, 44h
if _LCD_40x1
; "There is a hole in the floor.[ENTER]"
db 24h
else
; "There is a hole[ENTER]in the floor.[ENTER]"
db 80h
endif
db 48h, 4dh, 24h, 53h, 47h, 44h, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_obj_0c:
_obj_0e:
_obj_10:
_obj_12:
_obj_13:
_obj_14:
; "A ghost is here.[ENTER]"
db 0ah, 24h, 46h, 47h, 4eh, 52h, 53h, 24h, 48h
db 52h, 24h, 47h, 44h, 51h, 44h, 32h, 80h, ffh
_obj_0d:
_obj_0f:
_obj_11:
db 0ah, 24h, 43h, 44h, 40h, 43h, 24h, 46h, 47h, 4eh, 52h, 53h, 24h, 48h, 52h
if _LCD_40x1
; "A dead ghost is on the floor.[ENTER]"
db 24h
else
; "A dead ghost is[ENTER]on the floor.[ENTER]"
db 80h
endif
db 4eh, 4dh, 24h, 53h, 47h, 44h, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_obj_15:
db 0ah, 24h, 42h, 51h, 54h, 4ch, 4fh, 4bh
db 44h, 43h, 24h, 4fh, 48h, 44h, 42h, 44h
if _LCD_40x1
; "A crumpled piece of paper is on[ENTER]the ground.[ENTER]"
db 24h
else
; "A crumpled piece[ENTER]of paper is on[ENTER]the ground.[ENTER]"
db 80h
endif
db 4eh, 45h, 24h, 4fh, 40h, 4fh, 44h, 51h, 24h, 48h, 52h, 24h, 4eh, 4dh
db 80h, 53h, 47h, 44h, 24h, 46h, 51h, 4eh, 54h, 4dh, 43h, 32h, 80h, ffh
_obj_16:
db 12h, 4dh, 24h, 53h, 47h, 44h, 24h, 4ch
db 48h, 43h, 43h, 4bh, 44h, 24h, 4eh, 45h
if _LCD_40x1
; "In the middle of the room a knife[ENTER]is levitating.[ENTER]"
db 24h
else
; "In the middle of[ENTER]the room a knife[ENTER]is levitating.[ENTER]"
db 80h
endif
db 53h, 47h, 44h, 24h, 51h, 4eh, 4eh, 4ch, 24h, 40h, 24h
db 4ah, 4dh, 48h, 45h, 44h, 80h, 48h, 52h, 24h, 4bh, 44h
db 55h, 48h, 53h, 40h, 53h, 48h, 4dh, 46h, 32h, 80h, ffh
_obj_17:
db 0ah, 24h, 52h, 42h, 51h, 4eh, 4bh, 4bh, 24h, 48h, 52h, 24h, 4eh, 4dh
if _LCD_40x1
; "A scroll is on the ground.[ENTER]"
db 24h
else
; "A scroll is on[ENTER]the ground.[ENTER]"
db 80h
endif
db 53h, 47h, 44h, 24h, 46h, 51h, 4eh, 54h, 4dh, 43h, 32h, 80h, ffh
_obj_18:
db 22h, 4eh, 54h, 24h, 52h, 44h, 44h, 24h
db 40h, 24h, 41h, 54h, 42h, 4ah, 44h, 53h
if _LCD_40x1
; "You see a bucket of water.[ENTER]"
db 24h
else
; "You see a bucket[ENTER]of water.[ENTER]"
db 80h
endif
db 4eh, 45h, 24h, 56h, 40h, 53h, 44h, 51h, 32h, 80h, ffh
_obj_19:
; "A key is here.[ENTER]"
db 0ah, 24h, 4ah, 44h, 58h, 24h, 48h, 52h
db 24h, 47h, 44h, 51h, 44h, 32h, 80h, ffh
_obj_1a:
; "You see a rope.[ENTER]"
db 22h, 4eh, 54h, 24h, 52h, 44h, 44h, 24h
db 40h, 24h, 51h, 4eh, 4fh, 44h, 32h, 80h, ffh
_obj_1b:
db 0ah, 24h, 4ch, 40h, 46h, 48h, 42h, 24h
db 52h, 56h, 4eh, 51h, 43h, 24h, 48h, 52h
if _LCD_40x1
; "A magic sword is on the floor.[ENTER]"
db 24h
else
; "A magic sword is[ENTER]on the floor.[ENTER]"
db 80h
endif
db 4eh, 4dh, 24h, 53h, 47h, 44h, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_obj_1c:
db 0ah, 24h, 51h, 54h, 52h, 53h, 58h, 24h
db 4eh, 4bh, 43h, 24h, 52h, 48h, 46h, 4dh
if _LCD_40x1
; "A rusty old sign is lying on the[ENTER]ground.[ENTER]"
db 24h
else
; "A rusty old sign[ENTER]is lying on the[ENTER]ground.[ENTER]"
db 80h
endif
db 48h, 52h, 24h, 4bh, 58h, 48h, 4dh, 46h, 24h, 4eh, 4dh, 24h
db 53h, 47h, 44h, 80h, 46h, 51h, 4eh, 54h, 4dh, 43h, 32h, 80h, ffh
;-----------------------------------------------------------------------------
_invn_15:
; "paper[ENTER]"
db 4fh, 40h, 4fh, 44h, 51h, 80h, ffh
_invn_16:
; "knife[ENTER]"
db 4ah, 4dh, 48h, 45h, 44h, 80h, ffh
_invn_17:
; "scroll[ENTER]"
db 52h, 42h, 51h, 4eh, 4bh, 4bh, 80h, ffh
_invn_18:
; "water bucket[ENTER]"
db 56h, 40h, 53h, 44h, 51h, 24h, 41h, 54h, 42h, 4ah, 44h, 53h, 80h, ffh
_invn_19:
; "key[ENTER]"
db 4ah, 44h, 58h, 80h, ffh
_invn_1a:
; "rope[ENTER]"
db 51h, 4eh, 4fh, 44h, 80h, ffh
_invn_1b:
; "sword[ENTER]"
db 52h, 56h, 4eh, 51h, 43h, 80h, ffh
_invn_1c:
; "sign[ENTER]"
db 52h, 48h, 46h, 4dh, 80h, ffh
;-----------------------------------------------------------------------------
_msg_00:
; "OK[ENTER]"
db 18h, 14h, 80h, ffh
_msg_01:
; "NO[ENTER]"
db 17h, 18h, 80h, ffh
_msg_02:
db 1dh, 47h, 44h, 24h, 43h, 4eh, 4eh, 51h, 24h, 42h, 40h, 4dh, 2bh, 53h
if _LCD_40x1
; "The door can't be opened.[ENTER]"
db 24h
else
; "The door can't[ENTER]be opened.[ENTER]"
db 80h
endif
db 41h, 44h, 24h, 4eh, 4fh, 44h, 4dh, 44h, 43h, 32h, 80h, ffh
_msg_03:
db 22h, 4eh, 54h, 24h, 4ch, 40h, 53h, 44h, 51h, 48h, 40h, 4bh, 48h, 59h, 44h
if _LCD_40x1
; "You materialize inside the door.[ENTER]"
db 24h
else
; "You materialize[ENTER]inside the door.[ENTER]"
db 80h
endif
db 48h, 4dh, 52h, 48h, 43h, 44h, 24h, 53h, 47h
db 44h, 24h, 43h, 4eh, 4eh, 51h, 32h, 80h, ffh
_msg_04:
; "It's empty.[ENTER]"
db 12h, 53h, 2bh, 52h, 24h, 44h, 4ch, 4fh, 53h, 58h, 32h, 80h, ffh
_msg_05:
; "You find a key.[ENTER]"
db 22h, 4eh, 54h, 24h, 45h, 48h, 4dh, 43h
db 24h, 40h, 24h, 4ah, 44h, 58h, 32h, 80h, ffh
_msg_06:
; "You need a key.[ENTER]"
db 22h, 4eh, 54h, 24h, 4dh, 44h, 44h, 43h
db 24h, 40h, 24h, 4ah, 44h, 58h, 32h, 80h, ffh
_msg_07:
db 22h, 4eh, 54h, 24h, 49h, 54h, 52h, 53h, 24h, 43h, 48h, 44h, 43h, 32h
if _LCD_40x1
; "You just died. It was poison.[ENTER]"
db 24h
else
; "You just died.[ENTER]It was poison.[ENTER]"
db 80h
endif
db 12h, 53h, 24h, 56h, 40h, 52h, 24h, 4fh
db 4eh, 48h, 52h, 4eh, 4dh, 32h, 80h, ffh
_msg_08:
db 22h, 4eh, 54h, 24h, 45h, 40h, 4bh, 4bh, 24h, 40h, 4dh, 43h
if _LCD_40x1
; "You fall and break your neck.[ENTER]You are dead.[ENTER]"
db 24h
else
; "You fall and[ENTER]break your neck.[ENTER]You are dead.[ENTER]"
db 80h
endif
db 41h, 51h, 44h, 40h, 4ah, 24h, 58h, 4eh, 54h, 51h, 24h
db 4dh, 44h, 42h, 4ah, 32h, 80h, 22h, 4eh, 54h, 24h, 40h
db 51h, 44h, 24h, 43h, 44h, 40h, 43h, 32h, 80h, ffh
_msg_09:
db 1dh, 47h, 44h, 24h, 46h, 47h, 4eh, 52h, 53h, 24h, 48h, 52h
if _LCD_40x1
; "The ghost is immune to your attack.[ENTER]"
db 24h
else
; "The ghost is[ENTER]immune to your[ENTER]attack.[ENTER]"
db 80h
endif
db 48h, 4ch, 4ch, 54h, 4dh, 44h, 24h, 53h, 4eh, 24h, 58h, 4eh, 54h, 51h
if _LCD_40x1
db 24h
else
db 80h
endif
db 40h, 53h, 53h, 40h, 42h, 4ah, 32h, 80h, ffh
_msg_0a:
db 22h, 4eh, 54h, 24h, 42h, 40h, 4dh, 2bh
db 53h, 24h, 4ah, 48h, 4bh, 4bh, 24h, 40h
if _LCD_40x1
; "You can't kill a ghost with your[ENTER]bare hands.[ENTER]"
db 24h
else
; "You can't kill a[ENTER]ghost with your[ENTER]bare hands.[ENTER]"
db 80h
endif
db 46h, 47h, 4eh, 52h, 53h, 24h, 56h, 48h, 53h, 47h, 24h, 58h, 4eh, 54h
db 51h, 80h, 41h, 40h, 51h, 44h, 24h, 47h, 40h, 4dh, 43h, 52h, 32h, 80h, ffh
_msg_0b:
db 12h, 53h, 24h, 52h, 40h, 58h, 52h, 30h, 24h, 2bh, 15h, 4eh, 54h, 43h
if _LCD_40x1
; "It says, 'Loud magic word is REZET'.[ENTER]"
db 24h
else
; "It says, 'Loud[ENTER]magic word is[ENTER]REZET'.[ENTER]"
db 80h
endif
db 4ch, 40h, 46h, 48h, 42h, 24h, 56h, 4eh, 51h, 43h, 24h, 48h, 52h
if _LCD_40x1
db 24h
else
db 80h
endif
db 1bh, 0eh, 23h, 0eh, 1dh, 2bh, 32h, 80h, ffh
_msg_0c:
db 12h, 53h, 24h, 52h, 40h, 58h, 52h, 30h
db 24h, 2bh, 0eh, 52h, 42h, 40h, 4fh, 44h
if _LCD_40x1
; "It says, 'Escape from the second floor'.[ENTER]"
db 24h
else
; "It says, 'Escape[ENTER]from the second[ENTER]floor'.[ENTER]"
db 80h
endif
db 45h, 51h, 4eh, 4ch, 24h, 53h, 47h, 44h, 24h, 52h, 44h, 42h, 4eh, 4dh, 43h
if _LCD_40x1
db 24h
else
db 80h
endif
db 45h, 4bh, 4eh, 4eh, 51h, 2bh, 32h, 80h, ffh
_msg_0d:
db 0ah, 4dh, 24h, 48h, 4dh, 52h, 42h, 51h, 48h, 4fh, 53h, 48h, 4eh, 4dh
if _LCD_40x1
; "An inscription reads 'GHOST KILLER'.[ENTER]"
db 24h
else
; "An inscription[ENTER]reads[ENTER]'GHOST KILLER'.[ENTER]"
db 80h
endif
db 51h, 44h, 40h, 43h, 52h
if _LCD_40x1
db 24h
else
db 80h
endif
db 2bh, 10h, 11h, 18h, 1ch, 1dh, 24h, 14h
db 12h, 15h, 15h, 0eh, 1bh, 2bh, 32h, 80h, ffh
_msg_0e:
db 12h, 53h, 24h, 52h, 40h, 58h, 52h, 30h, 24h, 2bh, 1dh, 47h, 51h, 44h, 44h
if _LCD_40x1
; "It says, 'Three exits from this room[ENTER]are true. "
; "But this clue is a burden'.[ENTER]"
db 24h
else
; "It says, 'Three[ENTER]exits from this[ENTER]room are true.[ENTER]"
; "But this clue is[ENTER]a burden'.[ENTER]"
db 80h
endif
db 44h, 57h, 48h, 53h, 52h, 24h, 45h, 51h, 4eh, 4ch, 24h, 53h, 47h, 48h, 52h
if _LCD_40x1
db 24h
else
db 80h
endif
db 51h, 4eh, 4eh, 4ch
if _LCD_40x1
db 80h
else
db 24h
endif
db 40h, 51h, 44h, 24h, 53h, 51h, 54h, 44h, 32h
if _LCD_40x1
db 24h
else
db 80h
endif
db 0bh, 54h, 53h, 24h, 53h, 47h, 48h, 52h
db 24h, 42h, 4bh, 54h, 44h, 24h, 48h, 52h
if _LCD_40x1
db 24h
else
db 80h
endif
db 40h, 24h, 41h, 54h, 51h, 43h, 44h, 4dh, 2bh, 32h, 80h, ffh
_msg_0f:
; "A wise decision.[ENTER]"
db 0ah, 24h, 56h, 48h, 52h, 44h, 24h, 43h, 44h
db 42h, 48h, 52h, 48h, 4eh, 4dh, 32h, 80h, ffh
_msg_10:
db 0ah, 24h, 52h, 54h, 48h, 53h, 24h, 4eh
db 45h, 24h, 40h, 51h, 4ch, 4eh, 54h, 51h
if _LCD_40x1
; "A suit of armour flees when it[ENTER]sees your knife.[ENTER]"
db 24h
else
; "A suit of armour[ENTER]flees when it[ENTER]sees your knife.[ENTER]"
db 80h
endif
db 45h, 4bh, 44h, 44h, 52h, 24h, 56h, 47h, 44h, 4dh, 24h
db 48h, 53h, 80h, 52h, 44h, 44h, 52h, 24h, 58h, 4eh, 54h
db 51h, 24h, 4ah, 4dh, 48h, 45h, 44h, 32h, 80h, ffh
_msg_11:
db 22h, 4eh, 54h, 24h, 40h, 53h, 53h, 40h, 42h, 47h, 24h, 53h, 47h, 44h
if _LCD_40x1
; "You attach the rope to the hole[ENTER]in the ceiling.[ENTER]"
db 24h
else
; "You attach the[ENTER]rope to the hole[ENTER]in the ceiling.[ENTER]"
db 80h
endif
db 51h, 4eh, 4fh, 44h, 24h, 53h, 4eh, 24h, 53h, 47h, 44h
db 24h, 47h, 4eh, 4bh, 44h, 80h, 48h, 4dh, 24h, 53h, 47h
db 44h, 24h, 42h, 44h, 48h, 4bh, 48h, 4dh, 46h, 32h, 80h, ffh
_msg_12:
db 22h, 4eh, 54h, 24h, 51h, 44h, 40h, 42h, 47h, 24h, 53h, 47h, 44h
if _LCD_40x1
; "You reach the second floor.[ENTER]"
db 24h
else
; "You reach the[ENTER]second floor.[ENTER]"
db 80h
endif
db 52h, 44h, 42h, 4eh, 4dh, 43h, 24h, 45h, 4bh, 4eh, 4eh, 51h, 32h, 80h, ffh
_msg_13:
db 22h, 4eh, 54h, 51h, 24h, 4ch, 40h, 46h
db 48h, 42h, 24h, 52h, 56h, 4eh, 51h, 43h
if _LCD_40x1
; "Your magic sword enables you to[ENTER]kill the ghost.[ENTER]"
db 24h
else
; "Your magic sword[ENTER]enables you to[ENTER]kill the ghost.[ENTER]"
db 80h
endif
db 44h, 4dh, 40h, 41h, 4bh, 44h, 52h, 24h, 58h, 4eh, 54h
db 24h, 53h, 4eh, 80h, 4ah, 48h, 4bh, 4bh, 24h, 53h, 47h
db 44h, 24h, 46h, 47h, 4eh, 52h, 53h, 32h, 80h, ffh
;-----------------------------------------------------------------------------
; CHANGES:
; - R0: runs from RAM, uses CLI keyboard handling, minor code optimizations
; - R1: engine bug fixes, use lower case letters, no text packer
;=============================================================================
