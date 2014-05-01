set90x60:
	use16	
	mov ax, 0x1112
	xor bl, bl
	int 0x10
	; Switch VGA Modes
	mov si, VGA_REGS
	call write_regs
	; Time to tell BIOS
	push es
	push ds
	mov ax, 0x0040
	mov ds, ax
	mov es, ax
	mov word [0x004A], 90	; 90 Colums
	mov word [0x004C], 90 * 60 * 2 ; Frame Buffer Size, 90(Length) * 60 (Columns) * 2 (Dimensions)
	mov cx, 8	
	mov di, 0x0050
	xor ax, ax
	rep stosw
	mov word [0x60], 0x607 ; Cursor Shape
	mov byte [0x84], 59 ; Rows on screen - 1
	mov byte [0x85], 8
	pop es
	pop ds
	ret
write_regs:
		pusha
		cld
; write MISC register
		mov dx, 0x3C2
		lodsb
		out dx, al

; write SEQuencer registers
		mov cx, 5
		mov ah, 0
write_seq:
		mov dx, 0x3C4
		mov al, ah
		out dx, al

		mov dx, 0x3C5
		lodsb
		out dx, al

		inc ah
		loop write_seq

; write CRTC registers
; Unlock CRTC registers: enable writes to CRTC regs 0-7
		mov dx, 0x3D4
		mov al, 17
		out dx, al

		mov dx, 0x3D5
		in al, dx
		and al, 0x7F
		out dx, al

; Unlock CRTC registers: enable access to vertical retrace regs
		mov dx, 0x3D4
		mov al, 3
		out dx, al

		mov dx, 0x3D5
		in al, dx
		or al, 0x80
		out dx, al

; make sure CRTC registers remain unlocked
		mov al,[si + 17]
		and al,7Fh
		mov [si + 17],al

		mov al,[si + 3]
		or al,80h
		mov [si + 3],al

; now, finally, write them
		mov cx, 25
		mov ah, 0
write_crtc:
		mov dx, 0x3D4
		mov al, ah
		out dx, al

		mov dx, 0x3D5
		lodsb
		out dx, al

		inc ah
		loop write_crtc
		popa
		ret
VGA_REGS:
; MISC
	db 0E7h
; SEQuencer
	db 03h, 01h, 03h, 00h, 02h
; CRTC
	db  6Bh, 59h,  5Ah, 82h, 60h,  8Dh, 0Bh,  3Eh
	db  00h, 47h,  06h, 07h, 00h,  00h, 00h,  00h
	db 0EAh, 0Ch, 0DFh, 2Dh, 08h, 0E8h, 05h, 0A3h
	db 0FFh
; GC (no)
; AC (no)
;; 32-bit code
use32
set_mode90x6032:
	mov esi, VGA_REGS
	call write_regs32
	ret
write_regs32:
		pushad
		cld
; write MISC register
		mov dx, 0x3C2
		lodsb
		out dx, al

; write SEQuencer registers
		mov ecx, 5
		mov ah, 0
write_seq32:
		mov dx, 0x3C4
		mov al, ah
		out dx, al

		mov dx, 0x3C5
		lodsb
		out dx, al

		inc ah
		loop write_seq32

; write CRTC registers
; Unlock CRTC registers: enable writes to CRTC regs 0-7
		mov dx, 0x3D4
		mov al, 17
		out dx, al

		mov dx, 0x3D5
		in al, dx
		and al, 0x7F
		out dx, al

; Unlock CRTC registers: enable access to vertical retrace regs
		mov dx, 0x3D4
		mov al, 3
		out dx, al

		mov dx, 0x3D5
		in al, dx
		or al, 0x80
		out dx, al

; make sure CRTC registers remain unlocked
		mov al,[esi + 17]
		and al,7Fh
		mov [esi + 17],al

		mov al,[esi + 3]
		or al,80h
		mov [si + 3],al

; now, finally, write them
		mov ecx, 25
		mov ah, 0
write_crtc32:
		mov dx, 0x3D4
		mov al, ah
		out dx, al

		mov dx, 0x3D5
		lodsb
		out dx, al

		inc ah
		loop write_crtc32
		popad
		ret