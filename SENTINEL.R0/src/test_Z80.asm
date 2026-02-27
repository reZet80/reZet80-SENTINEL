;=============================================================================
; Z80 NMOS/CMOS test (test_Z80.asm) [last modified: 2025-12-03]
; (c) copyright 2016-2025 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
; NMOS CPUs output 00h executing the undocumented instruction "out (c), 0"
; CMOS CPUs output ffh
		nop			; take it easy
		di			; disable interrupts
		ld c, 00h		; SENTINEL configuration register
		db edh, 71h		; out (c), 0
_loop:		jr _loop		; loop forever
		ds 1000h-$, ffh		; fill up 4 KiB ROM
;=============================================================================
