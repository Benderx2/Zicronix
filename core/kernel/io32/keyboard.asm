use32
;; Some Defines 
define RSHIFT_KEY 54
define LSHIFT_KEY 42
define ALT_KEY 56
define KEY_UP 128
keyboard_handler:
	;; Push all the required stuff
	pushad
	push es
	push ds
	;mov byte [key_pressed], 0x0
	;; Clear DF
	cld
	;; Clear the EAX as we'll use this for scan code
	xor eax, eax
	;; Get a scancode from the keyboard port
	in al, 0x60
	;; Check if a key is pressed
	test al, 10000000b
	;; Hang on....
	jnz @f
	;; Okay keypress
	mov byte [key_pressed], 1
@@:
		;; Empty the scancode
		mov byte [scan_code], 0
		;; Put the Scan Code in AL
		mov byte [scan_code], al
.check_ALT:
		cmp al, 56
		je .DEBUG
.check_LSHIFT_DOWN:
		;; Do we've LSHIFT Down?
		cmp al, LSHIFT_KEY
		jne .check_LSHIFT_UP
		;; Yes, set the shift key attribute to 0x01
		mov byte [shift_key], 0x01
		jmp .convert_ASCII
.check_LSHIFT_UP:
		;; Maybe it's up
		cmp al, LSHIFT_KEY + KEY_UP
		jne .check_RSHIFT_DOWN
		;; Yes, then set the shift key attribute to 0x00
		mov byte [shift_key], 0x00
		jmp .convert_ASCII
		;; Do we've Right Shift Down?
.check_RSHIFT_DOWN:
		cmp al, RSHIFT_KEY
		jne .check_RSHIFT_UP
		;; Then Set SHIFT_KEY attribute as 0x01
		mov byte [shift_key], 0x01
		jmp .convert_ASCII
		;; Maybe it's up?
.check_RSHIFT_UP:
		cmp al, RSHIFT_KEY + KEY_UP
		jne .convert_ASCII
		;; Maybe Not, set the SHIFT_KEY attribute to 0x00
		mov byte [shift_key], 0x00
		jmp .convert_ASCII
.convert_ASCII:
		;; If it's lesser than 128 it has an ASCII Value
		cmp al, 128
		jae .done
		;; Set EDI to scan code
		mov edi, eax
		;; Convert to PS/2 Scancode ---> ASCII
		cmp byte [shift_key], 0x00
		je .NORMAL
		cmp byte [shift_key], 0x01
		je .SHIFT
.NORMAL:
		mov al, [edi + key_map_en_US]
		jmp .OK_KEY
.SHIFT:
		mov al, [edi + key_map_shift_US]
		jmp .OK_KEY
.DEBUG:
		call os_debug_exception
		jmp .done
.OK_KEY:
		;; Set ascii_value as the converted ASCII Value
		;; Empty the ASCII Value
        mov byte [ascii_value], 0
		mov byte [ascii_value], al
.done:
		;; Store the scancode
		;; Tell the PIC we're done
		call send_eoi
		pop ds
		pop es
		popad
		iretd
key_pressed db 0	
scan_code db 0	
ascii_value db 0
shift_key db 0
;; Zicronix Keyboard API
WaitKey:
	;; Set keypressed to 0
	mov [key_pressed], 0
.wait_for_keypress:
	;; HLT - Consumes less CPU Power
	hlt
	;; Did we get a key press, remember that the when the Keyboard IRQ will
	;; fire, (no shooting btw), the key_pressed attrubute will be set to 1
	cmp [key_pressed], 1
	;; Hang on
	jne .wait_for_keypress
	;; Pressed?
	;; Then we set it to 0 back, since we'll use it again
	mov byte [key_pressed], 0
	;; Pass AH as Scan Code
	mov ah, [scan_code]
	;; And AL as ASCII Converted ScanCode
	mov al, [ascii_value]
	;; bl to 1
	mov bl, 1
	;; Return
	ret
;; IN/OUT EAX : Location of the input string (Recommended 256-bytes)
;; ECX : Number of characters out.
GetString:
	pushad
	;; Let EDI be where we'll store the input
	mov edi, eax
 	;; Character Counter
	mov ecx, 0x00
.check_for_key:
	call WaitKey
	;; Check whether scan code is ENTER
	cmp al, 0x0D
	;; If it is then exit
	je .done
	;; Is it a backspace?
	cmp al, 0x08
	;; Then Call the appropriate handler
	je .back_space
	;; Ignore most non-printing chars
	cmp al, 0x20
	jb .check_for_key
	cmp al, 0x7E
	ja .check_for_key
	;; Else print it.
	mov bl, al
	call printc32
	inc ecx
	;; And store it in buffer
	jmp .store_into_buffer
.back_space:
	;; Back Space at start of String?
	cmp ecx, 0x00
	je .check_for_key
	;; Move the Screen_X attrribute one byte behind
	dec byte [screen_x]
	;; Check whether we're at the start of the line
	cmp byte [screen_x], 0
	je .new_line_backspace
	;; Print a BackSpace There
	mov bl, 0x20
	call printc32
	;; Decrement Screen_X
	dec byte [screen_x]
	;; Move the Cursor
	call movecursor32_INTERNAL
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
	mov byte [screen_x], 0
	mov bl, ' '
	call printc32
	;; Jump back to the last line
	dec byte [screen_y]
	;; And set the cursor position to max_x - 1
	mov byte [screen_x], 89
	mov bl, ' '
	call printc32
	;; Decrement screen_y and set screen_x
	;; back as printc32 modifies these values.
	dec byte [screen_y]
	mov byte [screen_x],  89
	;; Move the cursor
	call movecursor32_INTERNAL
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
	mov bl, 0x0A
	call printc32
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
KEY_MAPS:
;; Contains KeyMaps
key_map_en_US:
db	0, 27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 8,   9
db	'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 13,  0,   'a', 's'
db	'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', 39,  '`', 0,   '#',  'z', 'x', 'c', 'v'
db	'b', 'n', 'm', ',', '.', '/', 0,   '*', 0,   ' ', 0,   3,   3,	 3,   3,   3
db	3,   3,   3,   3,   3,	 0,   0,   0,	0,   0,   '-', 0,   0,	 0,   '+', 0
db	0,   0,   0,   127, 0,	 0,   92,  3,	3,   0,   0,   0,   0,	 0,   0,   0
db	13,  0,   '/', 0,   0,	 0,   0,   0,	0,   0,   0,   0,   0,	 0,   0,   127
db	0,   0,   0,   0,   0,	 0,   0,   0,	0,   0,   '/', 0,   0,	 0,   0,   0
times 16 * 8 db 255
;; When shift is pressed this shit comes in
key_map_shift_US:
db	0, '~', '!', '@','#', '$', '%', '^', '&', '*', '(', ')', '_', '+', 126, 126
db	'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', 126, 0,   'A', 'S'
db	'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '@',  '~', 0, '~', 'Z', 'X', 'C', 'V'
db	'B', 'N', 'M', '<', '>', '?', 0,   '*', 0,  ' ',   0,	1,   1,   1,   1,   1
db	1,   1,   1,   1,   1,	 0,   0,   0,	0,   0,   '-', 0,   0,	 0,   '+', 0
db	0,   0,   1,   127, 0,	 0, '|',   1,	1,   0,   0,   0,   0,	 0,   0,   0
db	13,  0,  '/',  0,   0,	 0,   0,   0,	0,   0,   0,   0,   0,	 0,   0,   127
db	0,   0,   0,   0,   0,	 0,   0,   0,	0,   0,   '/', 0,   0,	 0,   0,   0
times 16 * 8 db 255
	