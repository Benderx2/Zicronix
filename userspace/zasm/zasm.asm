include '../znu/libasm/applib.s'
_start:
	call os_get_args
	mov dword [file_name], esi
	mov ah, 0x01
	call os_file_exists
	cmp ax, -1
	je fail_all
	mov dword [file_size], ecx
	;; Load the source into memory
	mov esi, dword [file_name]
	mov edi, _END_OF_EXE
	call os_load_file
	;; Next we'll find the memory address of the executable buffer
	;; Address of the source load location
	mov eax, _END_OF_EXE
	mov ebx, [file_size]
	;; next add that to get the memory location where we'll store the output
	add eax, ebx
	mov dword [start_of_bin], eax
	;; okay cool. now start asm'ing :D
	call assembler_init
_BSS_SECTION:
	file_size: dd 0x0
	file_name: dd 0x0
	start_of_bin: dd 0x0
	exe_buf: dd 0x0
_END_OF_EXE:
	
	
	
	