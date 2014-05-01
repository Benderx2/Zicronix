os_debug_exception:
	;; called when control key is pressed.
	pushad
	mov ch, [textcolor]
	mov [_save_colr], ch
	mov byte [textcolor], 0x02
	mov esi, _debug_exception_msg
	call printf32
	popad
	mov byte [textcolor], 0x07
	mov ah, 0x04
	int 0x30
	mov ch, [_save_colr]
	mov byte [textcolor], ch
wait_k:
	xor eax, eax
	;; Get a scancode from the keyboard port
	in al, 0x60
	;; Check if a key is pressed
	test al, 10000000b
	;; Hang on....
	jnz @f
	ret
@@:
	cmp al, 56
	je shell32
	jmp wait_k
	
	_debug_exception_msg db 0x0a, 'Debug Gates are now activated [Press ALT again to quit to shell or ENTER to return to previous execution]', 0x0a, 0
	_save_colr: db 0x0