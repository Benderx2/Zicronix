;; Get Cursor
;; Returns in screen_x and screen_y
screen_x db 0
screen_y db 0
getcursor32:
	pushad
	mov ah, 0x18
	int 0x50
	mov byte [screen_x], bl
	mov byte [screen_y], bh
	popad
	ret
;; Set cursor
;; Should be in screen_x and screen_y
movecursor32:
	pushad
	mov ah, 0x19
	mov byte bl, [screen_x]
	mov byte bh, [screen_y]
	int 0x50
	;; Upadate them
	call getcursor32
	popad
	ret
;; Get Cursor C
;; Lower 8-bits contain the X value and higher 8-bits contain the Y value
getcur_c:
	mov al, [screen_x]
	mov ah, [screen_y]
	ret
	
_video_mode:
	mov eax, [ebp + 8]
	cmp eax, 0x13
	je ._vga_13
	cmp eax, 0x03
	je ._vga_3
	cmp eax, 0x96
	je ._vga_90x60
	mov eax, -1
	jmp .exit
._vga_90x60:
	mov ah, 0x03
	int 0x33
	jmp .exit
._vga_3:
	mov ah, 0x02
	int 0x33
	jmp .exit
._vga_13:
	mov ah, 0x01
	int 0x33
	jmp .exit
.exit:
	leave
	ret