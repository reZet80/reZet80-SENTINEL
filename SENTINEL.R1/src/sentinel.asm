;=============================================================================
; SENTINEL (sentinel.asm) [last modified: 2026-07-26]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
; I/O ports:
_IO_CONFIG:	equ 00h			; SENTINEL configuration register
_IO_STATUS:	equ 10h			; SENTINEL status register
_IO_NAND_DAT:	equ 50h			; memcart data
_IO_NAND_CMD:	equ 51h			; memcart command (CLE)
_IO_NAND_ADR:	equ 52h			; memcart address (ALE)
_IO_KEYB:	equ 60h			; keyboard
_IO_LCD_CMD:	equ 70h			; LCD command
_IO_LCD_DAT:	equ 71h			; LCD data
;-----------------------------------------------------------------------------
include "lcd.asm"			; LCD configuration
;-----------------------------------------------------------------------------
; physical memory:
; 18000-1FFFF: bank 3
; 10000-17FFF: bank 2
; 08000-0FFFF: bank 1
; 00000-07FFF: bank 0
;-----------------------------------------------------------------------------
; high RAM (bank 1|bank 2|bank 3):
; 8000-FFFF: free memory (3x 32768 bytes)
;-----------------------------------------------------------------------------
; low RAM (bank 0):
; 7F00-7FFF: stack (256 bytes)
; 1000-7EFF: free memory (28416 bytes)
; 0100-0FFF: CLI/sys/ascii/games (3840 bytes)
; 0080-00FF: init|42-char key buffer/free (128 bytes)
; 0000-007F: boot/sys/vars (128 bytes)
;-----------------------------------------------------------------------------
include "boot.asm"
include "init.asm"
include "reZet80.asm"
		ds 0100h-$, ffh		; fill up
include "cli.asm"
include "sys.asm"
include "ascii.asm"
include "ab.asm"
include "bj.asm"
include "cr.asm"
include "dc.asm"
include "dr.asm"
include "hh.asm"
include "hi.asm"
include "hm.asm"
include "lh.asm"
include "or.asm"
include "rv.asm"
		ds 1000h-$, ffh		; fill up
;=============================================================================
