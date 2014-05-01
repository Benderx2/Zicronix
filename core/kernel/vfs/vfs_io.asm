;; vfs_open -
;; Open a File From the Virtual File System
;; ESI - File Name
;; AL = 0/1 - R/W
;; EAX - Pointer to buffer (if read or write)
;; EBX - 0/1 (R/W Success) or 2 - Fail, or -1 - R/W N.A.
;; ECX - Return Value (File Handle for files)
vfs_open:	
	push edi
	push esi
	;; COM1?
	mov edi, vfs_std_const.COM1
	mov ecx, 4
	repe cmpsb
	je .vfs_open_COM1
	;; CONSOLE?
	mov edi, vfs_std_const.CONSOLE
	repe cmpsb
	je .vfs_open_CONSOLE
	;; KEYBOARD?
	mov edi, vfs_std_const.KBRD 
	repe cmpsb
	je .vfs_open_KEYBOARD
	;; else it's a file.
	pop esi 
	;; Open the file for reading
	call fopen
	mov ecx, eax 
	;; Return dude
	jmp .return_from_call
.vfs_open_CONSOLE:
	