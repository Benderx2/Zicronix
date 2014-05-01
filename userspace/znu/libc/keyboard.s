_ascii_value equ ascii_value
;; Get Keyboard Status
;; OUT : AL - Scan Code, AH - Key Pressed or Not.
get_kbd_status:
	pushad
	mov ah, 0x01
	int 0x50
	mov byte [scan_code], 0x00
	mov byte [key_pressed], 0x00
	mov byte [ascii_value], 0x00
	mov byte [scan_code], ah
	mov byte [ascii_value], al
	mov byte [key_pressed], bh
	popad
	ret
scan_code db 0x00
key_pressed db 0x00
ascii_value db 0x00
wait_key:
	;; Enter a loop
	.loop:
		hlt
		call get_kbd_status
		cmp byte [key_pressed], 1
		je .done
		jmp .loop
	.done:
		mov byte [key_pressed], 0
		ret
get_char:
	call wait_key
	mov ah, 0x06
	mov byte al, [ascii_value]
	int 0x50
	xor eax, eax
	mov byte al, [ascii_value]
	ret
;; Get String Implementation
;; IN : ESI pointer to buffer
;; IN/OUT EAX : Location of the input string (Recommended 256-bytes)
;; ECX : Number of characters out.
get_string:
	pushad
	;; Let EDI be where we'll store the input
	mov edi, eax
 	;; Character Counter
	mov ecx, 0x00
.check_for_key:
	call wait_key
	;; Check whether scan code is ENTER
	cmp al, 13
	;; If it is then exit
	je .done
	;; Is it a backspace?
	cmp al, 8
	;; Then Call the appropriate handler
	je .back_space
	;; Ignore most non-printing chars
	cmp al, ' '
	jb .check_for_key
	cmp al, '~'
	ja .check_for_key
	;; Else print it.
	push eax
	mov ah, 0x06
	int 0x50
	pop eax
	inc ecx
	;; And store it in buffer
	jmp .store_into_buffer
.back_space:
	;; Back Space at start of String?
	cmp ecx, 0x00
	je .check_for_key
	;; Get cursor values
	call getcursor32
	;; Move the Screen_X attrribute one byte behind
	dec byte [screen_x]
	;; Check whether we're at the start of the line
	cmp byte [screen_x], 0
	je .new_line_backspace
	;; Print a BackSpace There
	push eax
	mov al, 0x20
	mov ah, 0x06
	int 0x50
	pop eax
	;; Decrement Screen_X
	dec byte [screen_x]
	;; Move the Cursor
	call movecursor32
	;; Decrement Counter
	dec ecx
	;; Decrement String
	dec edi
	;; Get Back
	jmp .check_for_key
.new_line_backspace:
	;; If there is a backspace at the start of a line
	;; We will print the backspace at the start of the line,
	;; then jump back to last line.
	;; I.e 
	;; screen_x = max_x - 1
	;; screen_y = screen_y - 1
	call getcursor32
	mov byte [screen_x], 0
	push eax
	mov al, ' '
	mov ah, 0x06
	int 0x50
	pop eax
	;; Jump back to the last line
	dec byte [screen_y]
	;; And set the cursor position to max_x - 1
	mov byte [screen_x], 89
	push eax
	mov al, ' '
	mov ah, 0x06
	int 0x50
	pop eax
	;; Decrement screen_y and set screen_x
	;; back as printc32 modifies these values.
	dec byte [screen_y]
	mov byte [screen_x], 89
	;; Move the cursors
	call movecursor32
	;; Decrement counter 2 times
	dec ecx
	dec ecx
	;; Decrement Destination 1 time
	dec edi
	;; Get back.
	jmp .check_for_key
.store_into_buffer:
	mov al, bl
	stosb
	;; Make sure not to exhaust buffer
	cmp ecx, 254
	;; If greater then we've had enough
	jae near .done
	;; Else Get back
	jmp .check_for_key
.done:
	;; If the user pressed [ENTER] jump to a newline
	;; 0x0A - Newline Character
	push eax
	mov al, 0x0A
	mov ah, 0x06
	int 0x50
	pop eax
	;; Null-Terminate String
	mov eax, 0
	stosb
	;; POPAD will destroy ECX, so store it.
	mov dword [number_of_chars], ecx
	popad
	;; Set ECX back.
	mov ecx, [number_of_chars]
	;; Return
	ret
number_of_chars dd 0
get_string_c:
	;; Empty Buffer
	pushad
	mov edi, input_buffer			; Clear input buffer each time
	mov al, 0
	mov ecx, 256
	rep stosb
	mov eax, input_buffer
	call get_string
	popad
	mov eax, input_buffer
	ret
	input_buffer: times 256 db 0
	