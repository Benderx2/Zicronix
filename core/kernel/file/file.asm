;; Open a File for reading
;; In: ESI File Name
;; OUT: EAX File handle
;; Structure of File handle
define ENTRY_SIZE 20
;; ___________________________________________________________________________________________________
;; Attribute (Open/Close) (1-byte) | File Name (11-bytes) | Current Pointer (4-bytes) | Size (4-bytes)
;; ___________________________________________________________________________________________________
fopen:
	pushad
	;; Convert file name to 11-bytes
	mov eax, esi
	call file_convert
	;; Store it into .tmp
	mov esi, eax
	mov edi, .tmp
	mov ecx, 11 ;; ---- 11-bytes file name 
	rep movsb 
	;; Query the Existence
	mov esi, eax
	call entry_exists
	;; Set Carry (for error)
	stc
	;; First cluster is 0x00000?
	cmp ax, 0x0000
	;; Error out.
	je .error
	;; Else copy the size too.
	mov dword [.tmp_size], ecx
	;; Search through entries and see if it has an Attribute of 0 -- File Closed
	mov esi, file_handle_buf
	;; Entry Start Number
	mov ecx, 0
.search_loop:
	;; grab char from ESI
	mov al, [esi]
	;; AL = 0x00? Closed File
	cmp al, 0x00
	je .found_entry
	;; Keep looping until we reach the last entry
	cmp ecx, 128
	je .error
	;; else add 20 to esi (next entry)
	add esi, ENTRY_SIZE
	;; looping
	jmp .search_loop
.found_entry:
	;; set Attribute as open
	mov edi, esi
	push edi
	mov al, 0x1 ; --- 1 - open Attribute
	stosb
	pop edi
	add edi, 1
	;; next copy the 11-byte file name
	push edi
	mov esi, .tmp
	mov ecx, 11
	rep movsb
	pop edi
	add edi, 11
	;; set current pointer as 0x00000000
	mov eax, 0x00000000
	push edi
	stosd
	pop edi
	;; copy file size
	mov eax, [.tmp_size]
	push edi
	stosd
	pop edi
	;; add one to esi
	;; increment number_of_entries
	inc dword [number_of_entries]
	clc
.error:
	popad
	mov eax, dword [number_of_entries]
	ret
	.tmp: times 13 db 0
	.tmp_size dd 0x0
;; Seek - Set Position in File.
;; EAX - File handle
;; EBX - 0x00 (Start of file), 0x01 - Current Position, 0x02 - EOF
lseek:
	pushad
	;; check whether the file is open
	mov esi, file_handle_buf
	;; calculate offset of handle
	;; each entry is 20-bytes
	mov ecx, 20
	;; next,
file_handle_buf:
		;; 4096 bytes for the handle buffer
		times 1280 dw 0x0000 ;; - 2560 bytes.
;; to keep a track of how many files we have opened
number_of_entries: dd 0x0