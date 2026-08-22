;=============================================================================
; SENTINEL release version (rv.asm) [last modified: 2026-07-14]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
_rventry:	ld de, _datrcc
		ld b, 30h		; send 48 bytes (6 chars)
		call _lcdload		; load custom characters to LCD CGRAM
		ld de, _datrv
		call _lcdtext0		; welcome
		jp _clientry		; back to CLI
;-----------------------------------------------------------------------------
_datrv:
; "SENTINEL R1[ENTER]"
db 1ch, 0eh, 17h, 1dh, 12h, 17h, 0eh, 15h, 24h, 1bh, 01h, 80h
db 4fh, 51h, 44h, 52h, 44h, 4dh, 53h, 44h
db 43h, 24h, 41h, 58h, 24h, 53h, 47h, 44h
if _LCD_40x1
; "presented by the reZet80 project[ENTER]"
db 24h
else
; "presented by the[ENTER]reZet80 project[ENTER]"
db 80h
endif
db 5ah, 5bh, 5ch, 5bh, 5dh, 5eh, 5fh, 24h
db 4fh, 51h, 4eh, 49h, 44h, 42h, 53h, 80h, ffh
;=============================================================================
