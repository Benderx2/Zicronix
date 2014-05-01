;; FAT API Routines
fat_api_32:
	;; Clear carry
	clc
	;; DH = 0x01
	;; Query for existence
	;; of an entry.
	;; AX = 0x0000
	;; on error
	;; ESI - Entry Name
	;; AL = 1 if file, 0 if directory
	cmp dh, 0x01
	je .entry_query
	;; DH = 0x02
	;; Create a file
	;; ESI - Filename
	;; ECX - Size
	cmp dh, 0x02
	je .file_create
	;; DH = 0x03
	;; Create a directory
	;; ESI - Directory name
	;; Creates a directory in 
	;; the current directory.
	cmp dh, 0x03
	je .mkdir
	;; DH = 0x04
	;; Delete a File
	;; ESI - File Name,
	;; Deletes a file in the 
	;; current directory (CF on error)
	cmp dh, 0x04
	je .del_file
	;; DH = 0x05
	;; Delete a directory
	;; Deletes a directory
	;; in the current directory. (CF on error)
	cmp dh, 0x05
	je .del_dir
	;; DH = 0x06
	;; Get File list
	;; EDI - Pointer to buffer
	;; Gets the file list of
	;; current directory
	cmp dh, 0x06
	je .get_file_list
	;; DH = 0x07
	;; Switch Directory
	;; ESI - Name of directory.
	;; Looks for the directory
	;; in current directory
	cmp dh, 0x07
	je .ch_dir
	;; DH = 0x08
	;; Write to file
	;; Writes to a file
	;; in the current directory
	;; ECX - bytes to write
	;; EDI - file name
	;; ESI - Memory Location
	cmp dh, 0x08
	je .write_file
	;; Well pass the error
	;; code
	stc
	jmp fat16_exit
.entry_query:
	cmp ah, 0x00
	je .is_a_directory
	mov eax, esi
	call file_convert
	mov esi, eax
	call entry_exists
	jmp fat16_exit
.is_a_directory:
	mov eax, esi
	call dir_convert
	mov esi, eax
	call entry_exists
	jmp fat16_exit
.file_create:
	call createfile32
	jmp fat16_exit
.mkdir:
	mov eax, esi
	call dir_convert
	mov esi, eax
	call mkdir32
	jmp fat16_exit
.del_file:
	mov eax, esi
	call file_convert
	mov esi, eax
	call rm_file
	jmp fat16_exit
.del_dir:
	mov eax, esi
	call dir_convert
	mov esi, eax
	call rm_entry
	jmp fat16_exit
.get_file_list:
	call get_dir_list_32
	jmp fat16_exit
.ch_dir:
	mov eax, esi
	call dir_convert
	call ch_dir
	jmp fat16_exit
.write_file:
	push eax
	mov eax, edi
	call file_convert
	mov edi, eax
	call writefile32
	pop eax
	jmp fat16_exit
fat16_exit:
	iretd