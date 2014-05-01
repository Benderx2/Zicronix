;; zicronix shell interpreter
;; or zsi :)
;; color command
shell_color:
	mov esi, dword [shell_args]
	call atoi32
	;; is ecx greater than 0xff
	cmp cl, 0xFF
	ja .error
	;; else color should be set to cl
	mov byte [textcolor], cl
	jmp shell32
.error:
	jmp shell32
;; echo command
shell_echo:
	mov esi, dword [shell_args]
	call printf32
	jmp shell32
;; add command
;shell_add:
	;mov esi, dword [shell_args]
;	xor ebx, ebx
;	xor edx, edx
;	mov ebx, .buf
;.add_loop:
;	lodsb
;	cmp al, ','
;	je .next_operator
;	cmp al, 0x00
;	je .end
;	;; convert to integer
;;	sub al, 49
;	mov byte [ebx], al
;	inc ebx
;	jmp .add_loop
;.next_operator:
	;add edx, ebx
	;; empty buffer 
	;mov edi, .buf
	;mov ecx, 12
	;mov al, 0x00
	;rep stosb
	;mov ebx, .buf
	;jmp .add_loop
;.end:
	;mov eax, edx
	;call itoa32
	;mov esi, eax
	;call printf32
	;jmp shell32