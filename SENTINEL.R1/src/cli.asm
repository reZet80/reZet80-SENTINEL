;=============================================================================
; SENTINEL command line interface (cli.asm) [last modified: 2026-07-26]
; (c) copyright 2016-2026 Adrian H. Hilgarth (all rights reserved)
; reZet80 - Z80-based retrocomputing and retrogaming (rezet80.blogspot.com)
; indentation setting: tab size = 8
;=============================================================================
_clieval:	ld (hl), ffh		; EOS
		ld a, (_climode)	; check CLI mode
		or a
		ret nz			; back to caller
		ld b, 0bh		; 11 files
		ld de, _cmddat		; compare with command list
_clieval1:	ld l, 81h		; go to 1st char entered
		ld a, (de)		; read 1st char
		cp (hl)			; compare
		jr nz, _clieval2
		inc de
		inc hl
		ld a, (de)		; read 2nd char
		cp (hl)			; compare
		jr nz, _clieval3
		ex de, hl		; command found
		inc hl			; load start address
		ld a, (hl)
		inc hl
		ld h, (hl)
		ld l, a
		rst 18h			; clear display first
		jp (hl)			; then run command
_clieval2:	inc de
_clieval3:	inc de
		inc de
		inc de
		djnz _clieval1		; command not found -> fall through
;-----------------------------------------------------------------------------
_clientry:	xor a			; internal CLI mode
_cli:		ld (_climode), a	; save CLI mode
		call _clrbuf		; clear buffer
		rst 18h			; clear display
		ld l, 80h		; 1st buffer position
		ld (hl), 38h		; '>'
		inc hl			; next buffer position
		call _lcdupdate		; show prompt
_cliloop:	rst 38h			; wait for keypress
		ld c, a
		cp 80h			; ENTER ?
		jr z, _clieval		; evaluate command line
		jr nc, _cliloop1	; > 80 ?
		ld a, l			; current buffer position
if _LCD_40x1
		cp a8h			; past last position ?
else
		cp 90h			; past last position ?
endif
		jr z, _cliloop		; then ignore key
		ld (hl), c		; save char
		inc hl			; next buffer position
		call _lcdupdate		; display char
		jr _cliloop
_cliloop1:	cp 81h			; BACK ?
		jr nz, _cliloop2
		ld a, l			; current buffer position
		cp 81h			; already 1st buffer position ?
		jr z, _cliloop		; then ignore BACK key
		dec hl			; previous buffer position
		ld (hl), 24h		; blank last char
		call _lcdupdate		; display
		jr _cliloop
_cliloop2:	cp 82h			; ESC ?
		jr nz, _cliloop3
		ld a, (_climode)	; check CLI mode
		or a
		jr z, _clientry		; restart CLI
		inc sp
		inc sp 			; adjust stack in external CLI mode
		jr _clientry
_cliloop3:	cp 83h			; SHIFT ?
		jr nz, _cliloop		; unknown key code
		ld a, 01h		; SHIFT key pressed
		ld (_shift), a
		jr _cliloop
;-----------------------------------------------------------------------------
; internal games table
_cmddat:
db 0ah, 0bh ; "AB"
dw _abentry
db 0bh, 13h ; "BJ"
dw _bjentry
db 0ch, 1bh ; "CR"
dw _crentry
db 0dh, 0ch ; "DC"
dw _dcentry
db 0dh, 1bh ; "DR"
dw _drentry
db 11h, 11h ; "HH"
dw _hhentry
db 11h, 12h ; "HI"
dw _hientry
db 11h, 16h ; "HM"
dw _hmentry
db 15h, 11h ; "LH"
dw _lhentry
db 18h, 1bh ; "OR"
dw _orentry
db 1bh, 1fh ; "RV"
dw _rventry
;=============================================================================
