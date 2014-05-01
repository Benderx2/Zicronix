;; CHDIR - Change Directory Function
chdir_f:
	pushad
	;; Save Current Directory
  	;; Store pointer to directory name
	mov [.directory_name], eax
 	mov eax, [current_directory.offset]
	mov [.save_dir], eax
	mov ax, [current_directory.cluster]
	mov [.cluster], ax
	mov edi, .temp_dir_buf
	mov al, 0x00
	mov ecx, 13
	rep stosb
	mov esi, [.directory_name]
	mov edi, .temp_dir_buf
	xor ecx, ecx
	;; is esi '/usr'?
	push esi
	push edi
	push ecx
	mov esi, USR_DIR_VFS
	mov edi, [.directory_name]
	mov ecx, 4
	repe cmpsb
	pop ecx
	pop edi
	pop esi
	jne .loop_dir
	mov eax, [BPB.root_dir_start]
	mov [current_directory.offset], eax
	mov eax, USR_DIR
	;; And switch to USR
	call chdir
	;; Add 5 to esi
	add esi, 5
	;; Else 
.loop_dir:
	lodsb
	;; End of string?
	cmp al, 0
	je .done
	;; is AL a '/' or '\' = Directory Ident
	cmp al, '\'
	je .chdir_now
	cmp al, '/'
	je .chdir_now
	;; FAT-Name can't be longer than 11-bytes
	cmp ecx, 11
	jg .error
	;; else increment counter
	inc ecx
	;; and store it into buffer
	stosb
	;; loop again
	jmp .loop_dir
.chdir_now:
	mov eax, .temp_dir_buf
	call chdir
	;; error?
	jnc .error
	;; else loop back
	;; empty dir_buf in case
	mov edi, .temp_dir_buf
	mov ecx, 13
	mov al, 0
	rep stosb
	xor ecx, ecx
	mov edi, .temp_dir_buf
	jmp .loop_dir
.error:
	;; store current_directory back
	mov eax, [.save_dir]
	mov [current_directory.offset], eax
	mov ax, [.cluster]
	mov [current_directory.cluster], ax
	;; pop all registers
	popad
	;; set no carry
	clc
	;; return 
	ret
.done:
	;; switch to final directory ^_^
	mov eax, .temp_dir_buf
	;; eax = 0?
	cmp dword [eax], 0
	je .f_n_ish
	cmp dword [eax+1], 0
	je .f_n_ish
	call chdir
	jnc .error
.f_n_ish:
	;; pop and ret
	popad
	stc 
	ret

.directory_name dd 0x0000000
.temp_dir_buf: times 13 db 0
.save_dir: dd 0x000000
.cluster dw 0x0000
USR_DIR_VFS: 
	db '/USR', 0