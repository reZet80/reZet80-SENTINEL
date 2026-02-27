;=============================================================================
; SENTINEL system boot (boot.asm) [last modified: 2026-02-19]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
; rst 00: Z80 boot
		di			; needed for soft reset
		im 1			; simple INT mode 1 (INT not used)
		ld hl, 0000h
		jr _init
;-----------------------------------------------------------------------------
		ds 08h, ffh		; rst 08
		ds 08h, ffh		; rst 10
;-----------------------------------------------------------------------------
; rst 18: clear LCD display [preserves C]
		push bc
		ld c, 01h		; clear display, address = 00h
		rst 20h			; send command to LCD
		pop bc
		ret
;-----------------------------------------------------------------------------
; set LCD display position [uses A, C]
_lcdhome:	ld c, 80h		; fall through
;-----------------------------------------------------------------------------
; rst 20: send command to LCD
_lcdcmd:	rst 30h			; wait until LCD ready
		out (_IO_LCD_CMD), a	; send command
		ret
		ds 04h, ffh		; fill up
;-----------------------------------------------------------------------------
; rst 28: send data (one char) to LCD [uses A, C]
		call _ascii		; SENTINEL to ASCII char encoding
_lcdnoascii:	ld c, a
		rst 30h			; wait until LCD ready
		out (_IO_LCD_DAT), a	; send
		ret
;-----------------------------------------------------------------------------
; rst 30: wait for LCD to finish [uses A]
_lcdready:	in a, (_IO_LCD_CMD)	; read status register
		rlca			; busy flag (bit 7) set ?
		jr c, _lcdready		; if set, wait until cleared
		ld a, c			; load input
		ret
_wd:		db 00h			; working directory = root directory
;-----------------------------------------------------------------------------
; rst 38: wait for key press [uses A, C, I]
_key:		ld a, i
		cp ffh			; any key pressed ?
		jr z, _key
_key0:		and 1fh			; only bits 0-4
		cp 10h			; special key ?
		jr c, _key1
		add 70h			; 10-13 -> 80-83
		jr _key3
_key1:		ld c, a			; 00-0F bits 0-3
		ld a, i
		rrca			; bits 5-7 -> bits 4-6
		and 70h			; only bits 4-6
		add a, c		; 'G'-'V' | 'W'-'+' | ','-'|'
_key2:		cp 40h			; ALT3 pressed ?
		jr c, _key3
		sub a, 10h
		jr _key2
_key3:		ld c, a
		ld a, ffh
		ld i, a			; reset I
		ld a, c			; key code in A and C
		ret
;-----------------------------------------------------------------------------
; check if key pressed [uses A, C]
_iskey:		ld a, i
		cp ffh			; any key pressed ?
		ret z
		jr _key0		; get key
_climode:	db 00h			; CLI mode: internal (0)|external (1)
;-----------------------------------------------------------------------------
; NMISR: read keyboard and ALT keys [preserves A, B, uses I]
		push af			; save A
		push bc			; save B
		in a, (_IO_KEYB)	; read key from key encoder
		and 1fh			; only bits 0-4
		ld b, a			; in B
		in a, (_IO_STATUS)	; read status of ALT1/ALT2/ALT3
		and e0h			; only bits 5-7
		or b			; combine values
		ld i, a			; I holds key code and ALT1/ALT2/ALT3
		pop bc			; restore B
		pop af			; restore A
		retn
;-----------------------------------------------------------------------------
		ds 08h, ffh		; fill up
;=============================================================================
