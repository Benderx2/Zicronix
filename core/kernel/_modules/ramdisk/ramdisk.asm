;; RAMDISK Routines.
;; These are specifically for the ramdisk format used by 
;; Zicronix, please see /root/ramdisk.img
;; Some constants
define END_FILE_SIG 0xEBDAFFFF
define END_RAMD_SIG 0x5550FFF1
define END_ROOT_SIG 0xE0FD0000
define FILE_HEADER 'ZXRM'
;; RAM Disk Get Directory
;; IN:
;; 	 -EDI: Buffer for directory (Should be atlease 110 bytes)
;; OUT:
;;   -Registers preserved
;;   -Buffer filled :)
ram_disk_get_dir:
	pushad
	;; Set ESI to load point to point + 4, (remember, 4 bytes is the header)
	mov esi, RAMDISK_LOAD_POINT
	add esi, 4
	;; Copy a newline
	mov al, 0x0A
	stosb
	;; Cool, now ESI points to the root directory, of RAMDISK, remember,
	;; a Zicronix RAMDISK root directory is just after the header :)
	;; Now set EBX to number of entries
	;; A Zicronix RAMDISK can have a maximum of 10 entries.
	mov ebx, 10
.check_loop:
	;; Now enter a loop we'll copy file names :)
	;; Alright ESI points to the start of root directory,
	;; inside a root directory, we have 10 entries, 
	;; in which one entry looks like this:
	;; 1 byte - Attribute (1 if it's a file, 0 if it's deleted or unused)
	;; 11 bytes - File Name (MUST BE PADDED!)
	;; 4 bytes (DWORD) - Pointer to the contents of the file. Cool?
	;; One entry = 16 bytes
	;; Check if it's deleted or unused
	cmp byte [esi], 0x0
	je .skip
	;; End of Directory?
	cmp esi, 'EOFD'
	je .done
	;; Decrement counter
	dec ebx
	;; All entries done?
	cmp ebx, 0x00000000
	je .done
	;; Or else grab the file name.
.grab_file_name:
	;; Set counter to NUL
	xor ecx, ecx
	;; Set EAX to 0
	xor eax, eax
	;; After the attribute byte
	mov ecx, 1
.grab_loop:
	mov al, [esi + ecx]
	;; Increment Counter
	inc ecx
	;; Is ECX is 9, end of file name?
	cmp ecx, 10
	je .add_extension
	;; Or it's a space
	cmp al, ' '
	je .grab_loop
	;; Ok, it's all good.
	stosb
	jmp .grab_loop
.add_extension:
	;; Add a '.'
	mov al, '.'
	stosb
	;; Copy the extension
	mov al, [esi + 9]
	stosb
	mov al, [esi + 10]
	stosb
	mov al, [esi + 11]
	stosb
	;; Newline
	mov al, 0x0A
	stosb
.skip:
	;; Skip that entry
	add esi, 16
	jmp .check_loop 
.done:
	;; Never forget to null terminate
	mov al, 0x00
	stosb
	popad
	ret
;; Ramdisk File Exists
;; Query for the existence of a file in a ramdisk
;; In :
;; 		-EAX Name of file
;; Out:
;; 	    -CF if it exists
;;	    -If it exists, content offset
;;		 passed in EAX.
ramdisk_file_exists:
	push edi
	push esi
	push edx
	push ecx
	push ebx
	;; Convert the file i.e. pad it.
	call file_convert
	;; Set ESI to ramdisk load offset
	mov esi, RAMDISK_LOAD_POINT
	;; 4 bytes is the header
	add esi, 4
	;; EBX to number of entries
	mov ebx, 10
	;; Cool. Now browse the root directory.
.browse_directory:
	;; Set EDI to file name
	mov edi, eax
	;; It's a used entry
	;; Save ESI
	push esi
	;; Increment it such that 
	;; it points to the file name
	;; attribute
	inc esi
	;; 11 bytes file name
	mov ecx, 11
	;; Equal?
	repe cmpsb
	;; Restore ESI
	pop esi
	;; Is the equal flag set
	je .found
	;; Or decrement EBX
	dec ebx
	;; Is EBX = 0
	cmp ebx, 0
	;; All entries passed
	;; couldn't find a file.
	je .not_found
	;; Else next entry
	add esi, 16
	jmp .browse_directory
.found:
	;; ESI should point to the start of filename
	;; ESI + 12 = Start of Contents
	mov eax, [esi + 12]
	;; Set carry
	stc
	;; Return
	pop ebx
	pop ecx
	pop edx
	pop esi
	pop edi
	ret
.not_found:
	;; Null out EAX
	xor eax, eax
	;; Clear Carry
	clc
	;; Return
	pop ebx
	pop ecx
	pop edx
	pop esi
	pop edi
	ret
;; RAMDISK - Load file
;; Loads a file from ramdisk
;; EDI - Memory location to load
;; ESI - File Name
ramdisk_load_file:
	push edi
	push esi
	push edx
	push ecx
	push ebx
	;; Does it exist?
	mov eax, esi
	call ramdisk_file_exists
	cmp eax, 0x00000000
	je .error
.load_file:
	;; Yes it does.
	;; EAX points to starting contents
	;; EDI - Points to memory location
	;; ESI should point to the stuff
	mov esi, eax
.loop:
	;inc [esi]
	;cmp dword [esi], END_FILE_SIG
	je .done
	jmp .loop
.done:
	stc
	pop ebx
	pop ecx
	pop edx
	pop esi
	pop edi
	ret
.error:
	clc
	pop ebx
	pop ecx
	pop edx
	pop esi
	pop edi
	ret
	
	