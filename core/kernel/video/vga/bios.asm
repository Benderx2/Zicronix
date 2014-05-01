;; BIOS :)
use16
bios_printf:
	push ax
	mov ah, 0x0E
.loop:
	lodsb
	cmp al, 0
	je .done
	int 0x10
	jmp .loop
.done:
	pop ax
	ret