;=============================================================================
; SENTINEL (sentinel.asm) [last modified: 2026-02-11]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
; I/O ports:
_IO_CONFIG:	equ 00h			; SENTINEL configuration register
_IO_STATUS:	equ 10h			; SENTINEL status register
_IO_KEYB:	equ 60h			; keyboard
_IO_LCD_CMD:	equ 70h			; LCD command
_IO_LCD_DAT:	equ 71h			; LCD data
;-----------------------------------------------------------------------------
; memory:
; 10000-1FFFF : unused (65536 bytes)
; 0FF00-0FFFF : stack (256 bytes)
; 01000-0FEFF : free memory (61184 bytes)
; 00100-00FFF : CLI/ascii/games (3840 bytes)
; 00080-000FF : init/sys/vars (128 bytes)
; 00000-0007F : boot/sys/vars (128 bytes)
;-----------------------------------------------------------------------------
; sys vars:                                                                  
_buffer:	equ 0080h		; 17-char buffer incl EOS (0080-0090)
;-----------------------------------------------------------------------------
include "boot.asm"
include "init.asm"
		ds 0100h-$, ffh		; fill up
include "cli.asm"
include "ascii.asm"
include "ab.asm"
include "bj.asm"
include "hh.asm"
include "hi.asm"
include "hm.asm"
		ds 1000h-$, ffh		; fill up
;=============================================================================
