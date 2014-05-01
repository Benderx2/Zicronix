;; Zicronix Native Interface
;; prints string in ESI
os_print_string:
	push eax
	mov ah, 0x07
	int 0x50
	pop eax
	ret
;; os_get_cursor_pos
;; gets cursor position in dl/dh
os_get_cursor_pos:
	push ebx
	push eax
	mov ah, 0x18
	int 0x50
	;; 0x50, 0x18 returns values in bl/bh
	;; this isn't standard as bios returns
	;; in dl/dh.
	mov dl, bl
	mov dh, bh
	pop eax
	pop ebx
	ret
;; os_set_cursor_pos
;; set cursor position from dl/dh
os_set_cursor_pos:
	push ebx
	push eax
	;; the kernel expects BL = X and BH = Y
    ;; added for convenience since people 
    ;; who come from a RM background tend
    ;; to use DL/DH
	mov bl, dl
	mov bh, dh
	mov ah, 0x19
	int 0x50
	pop eax
	pop ebx
	ret
;; Added for convenience
os_move_cursor equ os_set_cursor_pos
;; os_get_time_string
;; gets the time.
;; edi - pointer to buffer
os_get_time_string:
	push eax
	mov ah, 0x20
	int 0x50
	pop eax
	ret
;; os_get_date_string
;; get the freakin' date. :)
;; edi - pointer to buffer
os_date_string:
	push eax
	mov ah, 0x21
	int 0x50
	pop eax
	ret
;; os_load_file - Load a file into buffer
;; esi - file name
;; edi - buffer
os_load_file:
	push eax
	mov ah,  0x03
	int 0x50
	pop eax
	ret
;; os_write_file - Write a file from buffer
;; esi - file name
;; edi - buffer
;; ecx - bytes to write
os_write_file:
	push edx
	push esi
	push edi
	;; int 0x31 expects the opposite
	;; esi=fname is given for comfort
	;; since most times esi is the filename
	mov [.fname], esi
	mov esi, edi
	mov edi, [.fname]
	mov dh, 0x08
	int 0x31
	pop edi
	pop esi
	pop edx
	ret
	.fname dd 0x0
os_set_text_color:
	push eax
	mov ah, 0x03
	int 0x30
	pop eax
	ret
;; os_print_color_char - Print a character with color
;; al = char, bl = color
os_print_color_char:
	push eax
	mov ah, 0x10
	int 0x30
	pop eax
	ret
	
;; os_create_dir - Create a directory in current directory
;; esi - directory name
os_create_dir:
	push edx
	mov dh, 0x03
	int 0x31
	pop edx
	ret
;; os_rm_dir - Removes a directory
;; esi - same as create dir
os_rm_dir:
	push edx
	mov dh, 0x05
	int 0x31
	pop edx
	ret
;; os_rm_file
;; removes a file
;; esi - file name
os_rm_file:
	push edx
	mov dh, 0x04
	int 0x31
	pop edx
	ret
;; os_get_file_list
;; edi - pointer to buffer
os_get_file_list:
	push edx
	mov dh, 0x06
	int 0x31
	pop edx
	ret
;; os_change_directory
;; change the current directory
;; esi - directory name
;; set esi to PARENTDIR for switching to previous directory
os_change_directory:
	push edx
	mov dh, 0x07
	int 0x31
	pop edx
	ret
.data_section:
	PARENTDIR: db '..', 0
;; os_file_exists
;; query existence of a file
;; ax = -1 on error
;; ax = start cluster if ok.
os_file_exists:
	push edx
	mov dh, 0x01
	int 0x31
	pop edx
	cmp ax, 0x000
	je .nf
	ret
.nf:
	mov ax, -1
	ret
;; os_clear_screen
;; clear screen
os_clear_screen:
	push eax
	mov ah, 0x26
	int 0x50
	pop eax
	ret
;; os_get_kbd_status
os_get_kbd_status:
	pushad
	;; don't wanna be interrupted :)
	cli
	mov ah, 0x01
	int 0x50
	mov byte [key_pressed], 0x00
	mov byte [ascii_value], 0x00
	mov byte [scan_code], 0x00
	mov byte [scan_code], ah
	mov byte [ascii_value], al
	mov byte [key_pressed], bh
	sti
	popad
	ret
scan_code db 0x00
key_pressed db 0x00
ascii_value db 0x00
;; wait for keypress
;; al - ascii value
;; ah - scan code
os_wait_for_key:
	;; Enter a loop
	mov byte [key_pressed], 0x00
	.loop:
		hlt
		;; k an interrupt happened.
		call os_get_kbd_status
		cmp byte [key_pressed], 1
		jne .loop
		mov al, [ascii_value]
		mov ah, [scan_code]
		mov byte [key_pressed], 0
		ret
;; waits for keypress and prints the character
os_wait_for_key_print:
	call os_wait_for_key
	mov ah, 0x06
	mov byte al, [ascii_value]
	mov byte ah, [scan_code]
	int 0x50
	xor eax, eax
	mov byte al, [ascii_value]
	ret
;; os_exit();
;; exits to the OS.
os_exit:
	xor eax, eax
	xor ebx, ebx
	int 0x50
;; os_abort();
;; aborts the execution and returns the error
;; code
;; ebx - error code
os_abort:
	xor eax, eax
	int 0x50
;; os_get_args();
;; gets the arguments  in ESI
os_get_args:
	mov esi, [__OS_ARGS]
	ret
;; os_print_char(); - Print char in AL
os_print_char:
	push ebx
	push eax
	mov bl, al
	mov ah, 0x06
	int 0x50
	pop eax
	pop ebx
	ret
;; os_print_newline(); - Print a newline
os_print_newline:
	push eax
	mov al, 0x0A
	call os_print_char
	pop eax
	ret
;; os_switch_to_graphics_mode(); - Switch to graphics mode (320x200 pixels, 40x25)
os_switch_to_graphics_mode:
	push eax
	mov ah, 0x01
	int 0x33
	pop eax
	ret
;; os_switch_to_text_mode(); - Switch to text mode (720x400 pixels, 90x60)
os_switch_to_text_mode:
	push eax
	mov ah, 0x01
	int 0x33
	mov ah, 0x02
	int 0x33
	mov ah, 0x03
	int 0x33
	pop eax
	ret
;; os_pci_read_register
;; DL/DX/EDX - Output
;; In:
;; EAX - Device+Vendor ID.
;; CL - Read Type (8/16/32)
;; Clear carry for sucess
;; Set if error.
os_pci_read_register:
	cmp cl, 8
	je ._read_8
	cmp cl, 16
	je ._read_16
	cmp al, 32
	je ._read_32
	jmp .error
._read_32:
	mov dh, 0x12
	int 0x50
	jmp .done
._read_16:	
	mov dh, 0x11
	int 0x50
	jmp .done
._read_8:
	mov dh, 0x10
	int 0x50
	jmp .done
.error:
	stc
	ret
.done:
	clc
	ret
;; os_pci_read_register
;; DL/DX/EDX - Input
;; EAX - Device+Vendor ID.
;; CL - Write Type (8/16/32)
;; Clear carry for sucess
;; Set if error.
os_pci_write_register:
	cmp cl, 8
	je ._write_8
	cmp cl, 16
	je ._write_16
	cmp cl, 32
	je ._write_32
	jmp .error
._write_8:
	push ecx
	mov cl, 0x13
	int 0x50
	pop ecx
	jmp .done
._write_16:
	push ecx
	mov cl, 0x14
	int 0x50
	pop ecx
	jmp .done
._write_32:
	push ecx
	mov cl, 0x15
	int 0x50
	pop ecx
	jmp .done
.done:
	clc 
	ret
.error:
	stc
	ret
;; os_pci_find_device - Query for the existence of a pci device
;; in : EAX - Device+VendorID
;; out: EAX - Address of device
;; cf set if nf.
os_pci_find_device:
	push edx
	mov dh, 0x16
	int 0x50
	pop edx
	ret
;; os_set_exception_gate
;; set the exception gate
;; al = number (0x35 to 0xFE)
;; edx = pointer to handler
os_set_exception_gate:
	cmp al, 0x35
	jl .error
	cmp al, 0xFF
	jge .error
	push eax
	mov ah, 0x02
	int 0x30
	pop eax
	ret
.error:
	stc
	ret
;; os_speaker_on
;; initialize the legacy PIC speaker
;; ecx - seconds*10
;; bx - frequency
os_speaker_on:
	push eax
	mov ah, 0x09
	int 0x30
	pop eax
	ret
;; ITOA32 - Int to String 32
;; Some of these were borrowed from MikeOS.
;; I converted it to 32-bit Mode, and FASM-Syntax
;; In : Decimal in EAX
;; Out : String in EAX
os_int_to_string:
	pushad
	xor ecx, ecx
	;; Decimal Calculation (BASE 10)
	mov ebx, BASE_10
	mov edi, .buffer			; Get our pointer ready
.push:
	xor edx, edx
	div ebx				; Remainder in EDX, quotient in EAX
	inc ecx				; Increase pop loop counter
	push edx				; Push remainder, so as to reverse order when popping
	test eax, eax			; Is quotient zero?
	jnz .push			; If not, loop again
.pop:
	pop edx				; Pop off values in reverse order, and add 48 to make them digits
	add dl, '0'			; And save them in the string, increasing the pointer each time
	mov [edi], dl
	inc edi
	dec ecx
	jnz .pop
	mov byte [edi], 0		; Zero-terminate string
	popad
	mov eax, .buffer			; Return location of string
	ret
	.buffer: times 7 db 0
strcmp:
	times 29 db 0

;; CMP_STR : Compare String (Uses REPE CMPSB)
;; IN : ES:ESI - String I
;; 	    DS:ESI - String II
;; OUT: Registers Preserved
;; 		Carry set if match	 
os_string_compare:
	;; Push All Registers
	pushad                                            
	push es                                        
	push ds           
	;; Set DS and ES to proper selectors
	mov	ax, 0x18                                   
	mov	ds, ax			                    
	mov	es, ax   
	;; Is ECX a null character
	cmp	ecx, 0                                     
	je .failure    
	;; Clear Direction Flag for CMPSB
	cld
	;; REPE CMPSB - 
	;; CMPSB - Compares bytes,
	;; REPE - Repeat if equal
	repe cmpsb 
	;; If equal then good
	je .success                                               
.failure:   
	;; POP All the preserved registers
	pop	ds                                        
	pop	es                                        
	popad                                             
	clc                                               
	ret                                               
.success: 
	;; POP All the preserved registers
	pop	ds                                        
	pop	es                                        
	popad 
	;; Set carry
	stc                                               
	ret        
;; String Length
os_string_length:
	xor eax, eax
	push esi
.loop:
	mov byte bl, [esi]
	cmp bl, 0
	je .done
	inc esi
	inc eax
	jmp .loop
.done:
	pop esi
	ret
;; EAX - String Location	
;; Captalizes String
os_string_capitalize:
	pushad
	mov esi, eax			
.loop:
	;; End of string
	cmp byte [esi], 0		
	je .finish
	;; Something lesser than 'a', nope
	cmp byte [esi], 'a'		
	jb .continue
	;; Something greater than z?
	cmp byte [esi], 'z'
	ja .continue
	sub byte [esi], 0x20
	inc esi
	jmp .loop
.continue:
	;; Increment ESI
	inc esi
	jmp .loop
.finish:
	;; POP registers
	popad
	ret
;; EAX - String Location	
;; Lower Cases Strings
os_string_decapitalize:
	pushad
	mov esi, eax			
.loop:
	;; End of string
	cmp byte [esi], 0		
	je .finish
	;; Something lesser than 'a', nope
	cmp byte [esi], 'A'		
	jb .continue
	;; Something greater than z?
	cmp byte [esi], 'Z'
	ja .continue
	add byte [esi], 0x20
	inc esi
	jmp .loop
.continue:
	;; Increment ESI
	inc esi
	jmp .loop
.finish:
	;; POP registers
	popad
	ret
;; Return separated string
;; BL - Separator
;; ESI - start
;; OUT:
;; EDI - Next String after separator
os_string_separate:
	push esi
.next:
	cmp byte [esi], bl
	je .finish_separator
	cmp byte [esi], 0
	jz .fail
	inc esi
	jmp .next
.finish_separator:
	mov byte [esi], 0
	inc esi
	mov edi, esi
	pop esi
	ret
.fail:
	mov edi, 0
	pop esi
	ret
;; Clear String
;; IN : EDI - String Location
;; 		ECX - Length
os_clear_string:
	pushad
	mov al, 0x00
	rep stosb
	popad
	ret
;; string to int
;; in: esi - string
;; out: ecx - Number
;; esi destroyed \* */
;				   _
os_string_to_int:
	push eax
	push ebx
	xor ecx, ecx
	xor eax, eax
	mov bl, 9
	cld
.loop:
	lodsb
	sub al, '0'
	js .exit
	cmp al, bl
	ja .exit
	lea ecx, [ecx+4*ecx]
	lea ecx, [2*ecx+eax]
	jmp .loop
.exit:
	pop ebx
	pop eax
	ret
os_get_date:
	push eax
	mov ah, 0x21
	int 0x50
	pop eax
	ret
os_get_time:
	push eax
	mov ah, 0x20
	int 0x50
	pop eax
	ret
;; ecx = seconds * 10 units
os_pause:
	push eax
	mov ah, 0x17
	int 0x50
	pop eax
	ret
os_start_timer:
	push eax
	mov ah, 0x23
	int 0x50
	pop eax
	ret
os_stop_timer:
	push eax
	mov ah, 0x24
	int 0x50
	pop eax
	ret
os_get_timer:
	push eax
	mov ah, 0x25
	int 0x50
	pop eax
	ret
os_draw_line:
	pushad
	mov ecx, 89
.looop:
	mov al, '_'
	call os_print_char
	loop .looop
	popad
	ret
os_string_copy:
  pusha
.more:
  mov al, [esi]                         ; Transfer contents (at least one byte terminator)
  mov [edi], al
  inc esi
  inc edi
  cmp byte al, 0                        ; If source string is empty, quit out
  jne .more
.done:
  popa
  ret
;; os_input_string() - Read String from user
;; IN:
;; EDI - Pointer to buffer
;; ECX - Number of Chars to read
;; OUT:
;; ECX - Number of chars actually read.
os_input_string:
	push edi
	push edx			
	push eax
	mov edx, ecx		
	xor ecx, ecx			
.more_input:
	call os_wait_for_key
	cmp al, 13			
	je .done
	cmp al, 8			
	je .backspace
	cmp al, 32			
	jl .more_input
	cmp al, 126
	jg .more_input
	cmp ecx, edx			
	je .more_input	
	stosb				
	inc ecx				
	call os_print_char		
	jmp .more_input
.backspace:
	cmp ecx, 0			
	je .more_input
	mov al, ' '			
	call os_print_char		
	call os_dec_cursor		
	call os_dec_cursor		
	dec edi				
	mov byte [edi], 0x00		
	dec ecx			
	jmp .more_input
.done:	
	mov al, 0x00
	stosb				
	mov al, ' '
	call os_print_char
	pop eax
	pop edx
	pop edi
	ret
os_dec_cursor:
	pushad
	call os_get_cursor_pos
	dec dl
	cmp dl, 0
	je .dec_Y
	call os_set_cursor_pos
	jmp .done
.dec_Y:
	dec dh
	mov dl, 89
	call os_set_cursor_pos
.done:
	popad
	ret
os_inc_cursor:
	pushad
	call os_get_cursor_pos
	inc dl
	cmp dl, 90
	je .inc_Y
	call os_set_cursor_pos
	jmp .done
.inc_Y:
	mov dl, 0
	inc dh
	call os_set_cursor_pos
.done:
	popad
	ret