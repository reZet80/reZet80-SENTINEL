;=============================================================================
; SENTINEL system calls (sys.asm) [last modified: 2026-07-18]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
; check if key pressed [uses A]
_iskey:		ld a, i
		cp ffh			; any key pressed ?
		ret z
		jp _key0		; get key
;-----------------------------------------------------------------------------
; display text on LCD [uses A, B (input), DE (input)]
; call "_lcdtext" for fixed-size strings
; call "_lcdtext0" for EOS-terminated strings
_lcdtext0:	ld b, 00h		; max char count = 256
_lcdtext:	ld a, (de)
		inc de
		cp ffh			; EOS ?
		ret z
		cp 80h			; wait for ENTER ?
		jr z, _lcdtext2
		rst 28h			; send char to LCD
_lcdtext1:	djnz _lcdtext
		ret
_lcdtext2:	rst 38h			; wait for keypress
		rst 18h			; clear display
		jr _lcdtext1
;-----------------------------------------------------------------------------
; load custom characters to LCD CGRAM [uses C, DE]
_lcdload:	ld c, 40h		; 01000000b CGRAM address = 00h
		rst 20h			; send command to LCD
_lcdload1:	ld a, (de)
		inc de
		call _lcdnoascii	; send data to LCD w/o ASCII conversion
		djnz _lcdload1
		ld c, 80h		; 10000000b DDRAM address = 00h
		rst 20h			; send command to LCD
		ret
;-----------------------------------------------------------------------------
; switch high RAM bank [uses A, HL, preserves C (input)]
_banksw:	ld hl, _config
		ld a, (hl)		; current stored value
		and fch			; reset bits 0-1
		or c			; set A15SEL and A16SEL
		ld (hl), a		; save new value
		out (_IO_CONFIG), a	; and set it
		ret
;-----------------------------------------------------------------------------
; table lookup [uses A (input)(output), HL (input)(output)]
_tab:		add a, l
		jr nc, _tab1
		inc h			; crossed 256-byte boundary
_tab1:		ld l, a
		ld a, (hl)
		ret
;-----------------------------------------------------------------------------
; load table value [uses A (input), DE (output), HL (input)]
_tabval:	add a, a		; * 2
		call _tab		; table lookup
		inc hl			; increment hl
		ld h, (hl)
		ld l, a
		ex de, hl
		ret
;-----------------------------------------------------------------------------
; convert lower case char to upper case [uses A (input)]
_toupper:	cp 40h
		ret c
		cp 5ah
		ret nc
		sub 36h
		ret
;-----------------------------------------------------------------------------
; convert upper case char to lower case [uses A (input)]
_tolower:	cp 24h
		ret nc
		cp 0ah
		ret c
		add 36h
		ret
;-----------------------------------------------------------------------------
; LCD: display hex number [uses A (input), C]
_hexout:	ld c, a			; save value
		and f0h			; high nibble only
		rrca
		rrca
		rrca
		rrca			; to low nibble
		rst 28h			; send char to LCD
		ld a, c			; save value
		and 0fh			; low nibble only
		rst 28h			; send char to LCD
		ret
;-----------------------------------------------------------------------------
; delay
_delay0:	ld bc, 8000h		; ~ 426 ms @ 2 MHz
_delay:		dec bc			; T=BC*(6+4+4+12)-5+10
		ld a, b
		or c
		jr nz, _delay
		ret
;-----------------------------------------------------------------------------
; convert hex to decimal [uses A, C, HL]
_hex2dec:	ld c, 00h
_hex2dec1:	cp 0ah
		jr c, _hex2dec2
		inc c
		sub 0ah
		jr _hex2dec1
_hex2dec2:	ld (hl), c
		inc hl
		ld (hl), a
		inc hl
		ret
;-----------------------------------------------------------------------------
; update LCD display [uses A, DE]
_lcdupdate:	call _lcdhome		; back to 1st display position
		push de
		ld de, _buffer
		call _lcdtext0
if _LCD_16x2
		push de
		ld a, 01h
		rst 10h			; move cursor to 2nd line
		pop de
		call _lcdtext0
endif
		pop de
		ret
;-----------------------------------------------------------------------------
; clear buffer [uses B, C, HL]
_clrbuf:	ld hl, _buffer
if _LCD_40x1
		ld b, 28h		; 40x
elseif _LCD_16x2
		ld c, 02h		; 2 lines
_clrbuf1:	ld b, 10h		; 16x
else
		ld b, 10h		; 16x
endif
_clrbuf2:	ld (hl), 24h		; clear buffer with ' '
		inc hl
		djnz _clrbuf2
		ld (hl), ffh		; EOS
if _LCD_16x2
		inc hl
		dec c
		jr nz, _clrbuf1
endif
		ret
;=============================================================================
