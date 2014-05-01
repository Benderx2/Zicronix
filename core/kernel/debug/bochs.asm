;; Bochs Debugging Routines.
use32
;; IN : ESI - String to Write
;; OUT : Nothing Registers preserved.
BOCHS_WRITE_TO_CONSOLE:
	;; Save All registers
	pushad
	;; Enter a loop
	push esi
	pop edi
.loop:
	;; Grab one byte from ESI into BL
	mov bl, byte [edi]
	;; Check if BL = 0
	cmp bl, 0
	;; Done.
	je .done
	;; Else write to port
	out32 0xE9, bl
	inc edi
	jmp .loop
.done:
	popad
	ret
;; Bochs Magic Break
BOCHS_MAGIC_BREAK:
	pushad
	mov dx, 0x8A00
	mov ax, 0x8A00
	out dx, ax
	mov ax, 0x8AE0
	out dx, ax
	popad
	ret