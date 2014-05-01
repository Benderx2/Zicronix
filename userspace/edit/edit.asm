include '..\znu\libasm\applib.s'
LOAD_BUFFER equ 0xA00000
DEFINE MAX_X 89
DEFINE MAX_Y 60
__start:
	;; clear screen before hand
	call os_clear_screen
	;; grab the arguments
	call os_get_args
	;; Save file name
	mov dword [file_name], esi
	mov ah, 0x01
	call os_file_exists
	cmp ax, -1
	je failure
	mov dword [file_size], ecx
	;; Store file size
	mov eax, [file_size]
	call os_int_to_string
	;; Empty memory range from 10MB - ?????
	mov edi, LOAD_BUFFER
	mov ecx, [file_size]
	mov al, 0x00
	rep stosb
	;; Load the file at 10MB in RAM
	mov esi, [file_name]
	mov edi, LOAD_BUFFER
	call os_load_file
	;; grab the last byte of file
	mov ebx, [file_size]
	add ebx, LOAD_BUFFER
	mov dword [last_byte_addr], ebx
	;; is the last byte 0
	cmp ebx, LOAD_BUFFER
	jne .continue
	;; if the file is empty add a newline char
	mov byte [ebx], NEWLINE
	inc ebx
	mov dword [last_byte_addr], ebx
	inc dword [file_size]
.continue:
	mov ecx, 0
	;; Lines to skip
	mov dword [skip_lines], 0
	;; start displaying the text at 0, 3
	mov byte [cur_X], 0
	mov byte [cur_Y], 3
render_text:
	;; Wait for vsync to complete
	vsync_active:
	mov	dx, 03DAh	; input status port for checking retrace
	in	al, dx
	test al, 8
	jz	vsync_active	; Bit 3 on signifies activity
	vsync_retrace:
	in	al, dx
	test al, 8
	jnz	vsync_retrace	; Bit 3 off signifies retrace
	mov al, 0x0F
	call os_set_text_color
	call os_clear_screen
	mov dh, 3
	mov dl, 0
	call os_move_cursor
	mov dx, -1
	mov esi, LOAD_BUFFER
.print_file:
	cmp dword esi, [last_byte_addr]
	jge get_input
	cmp dword esi, [current_pos]
	je .get_cursor_pos
.print_char_continue:
	cmp dx, -1
	je .print
	push edx
	call os_get_cursor_pos
	mov ch, dh
	pop edx
	cmp ch, 56
	jl .print
	lodsb
	cmp al, 0
	jne .possible_end_2
	jmp .print_file
.print:
	lodsb
	cmp byte [HIGHLIGHT_MODE], 0
	je .normal_char
	;; Numbers must be in Light Blue
	cmp al, '1'
	je .number
	cmp al, '2'
	je .number
	cmp al, '3'
	je .number
	cmp al, '4'
	je .number
	cmp al, '5' 
	je .number
	cmp al, '6'
	je .number
	cmp al, '7'
	je .number
	cmp al, '8'
	je .number
	cmp al, '9'
	je .number
	cmp al, '0'
	je .number
	;; Symbols must be in green
	cmp al, ';'
	je .comment
	cmp al, '~'
	je .symbol
	cmp al, '%'
	je .symbol
	cmp al, '$'
	je .symbol
	cmp al, '@'
	je .symbol
	cmp al, '^'
	je .symbol
	cmp al, '&'
	je .symbol
	cmp al, '#'
	je .symbol
	cmp al, '`'
	je .symbol
	cmp al, '<'
	je .symbol
	cmp al, '>'
	je .symbol
	cmp al, '?'
	je .symbol
	cmp al, '/'
	je .symbol
	cmp al, '.'
	je .symbol
	cmp al, ','
	je .symbol
	cmp al, '*'
	je .symbol
	cmp al, '-'
	je .symbol
	cmp al, '='
	je .symbol
	cmp al, '_'
	je .symbol
	cmp al, '-'
	je .symbol
	cmp al, '+'
	je .symbol
	cmp al, '\'
	je .symbol
	cmp al, '|'
	je .symbol
	cmp al, ':'
	je .symbol
	;; Brackets in yellow
	cmp al, '['
	je .bracket
	cmp al, ']'
	je .bracket
	cmp al, '{'
	je .bracket
	cmp al, '}'
	je .bracket
	cmp al, '('
	je .bracket
	cmp al, ')'
	je .bracket
	;; and brown for strings
	cmp al, '"'
	je .string
	cmp al, "'"
	je .string
.normal_char:
	call os_print_char
	jmp .skip_print
.number:
	mov bl, 0x09
	call os_print_color_char
	jmp .skip_print
.bracket:
	mov bl, 0x0E
	call os_print_color_char
	jmp .skip_print
.symbol:
	mov bl, 0x0A
	call os_print_color_char
	jmp .skip_print
.comment:
	mov bl, 0x02
	call os_print_color_char
.com_loop:
	lodsb
	cmp al, 0
	je .skip_print
	cmp al, 0x0A
	je .skip_print
	cmp esi, [last_byte_addr]
	je .skip_print
	call os_print_color_char
	jmp .com_loop
.string:
	mov bl, 0x06
	call os_print_color_char
.ploop:
	lodsb
	cmp al, 0
	je .skip_print
	cmp al, 0x0A
	je .skip_print
	cmp al, '"'
	je .skip_print
	cmp al, "'"
	je .skip_print
	cmp esi, [last_byte_addr]
	je .skip_print
	call os_print_color_char
	jmp .ploop
.skip_print:
	cmp al, 0
	jne .possible_end
.print_char_display:
	cmp al, 0x0a
	jne .print_file
	;mov al, 0x0a
	;call os_print_char
	;jne .print_file
	jmp .print_file
.get_cursor_pos:
	call os_get_cursor_pos
	jmp .print_char_continue
.possible_end:
	mov dword [last_byte_addr2], esi
	jmp .print_char_display

.possible_end_2:
	mov dword [last_byte_addr2], esi
	jmp .print_file
get_input:
	call setup_screen
	call os_move_cursor
	call os_wait_for_key
	cmp al, 8
	je backspace
	mov ecx, 1
	cmp ah, KEY_LEFT		
	je left_arrow		
	cmp ah, KEY_RIGHT		
	je right_arrow	
	mov ecx, 89
	cmp ah, KEY_DOWN		
	je left_arrow		
	cmp ah, KEY_UP		
	je right_arrow
	cmp al, KEY_ESC
	je finish
	;; F1??
	cmp ah, 0x3B
	je help
	;; F2??
	cmp ah, 0x3C
	je highlight
	;; F3??
	cmp ah, 0x3D
	je save_file_render
	jmp enter_text
	jmp render_text
left_arrow:
	mov eax, LOAD_BUFFER - 1
	add eax, ecx
	cmp dword [current_pos], eax
	jle .done
	sub dword [current_pos], ecx
.done:
	jmp render_text
enter_text:
	cmp al, 13
	je  newline
	cmp al, ' '
	jl render_text
	cmp al, '~'
	jg render_text
	call shift_right
	mov edi, dword [current_pos]
	stosb
	mov ecx, 1
right_arrow:
	mov eax, [last_byte_addr]
	inc eax
	sub eax, ecx
	cmp dword [current_pos], eax
	jge .done
	add dword [current_pos], ecx
.done:
	jmp render_text
newline:
	call shift_right
	mov edi, dword [current_pos]
	mov al, 0x0A
	stosb
	mov ecx, 1
	call right_arrow
	jmp render_text
;; this routine will shift all chars to right+backspace :)
backspace:
	cmp dword [current_pos], LOAD_BUFFER
	jle render_text		
	call shift_left
	jmp render_text
shift_right:
	push eax
	mov esi, [last_byte_addr]
	dec esi
	mov edi, esi
	inc edi
	std
.repeat:
	cmp esi, dword [current_pos]
	jl .done
	lodsb
	stosb
	jmp .repeat

.done:
	cld
	pop eax
	inc dword [last_byte_addr]
	inc dword [file_size]
	ret

shift_left:
	push eax
	mov esi, dword [current_pos]
	mov edi, esi
	dec edi
.repeat:
	mov ebx, [last_byte_addr]
	inc ebx
	cmp esi, ebx 
	jge .done
	lodsb
	stosb
	jmp .repeat
.done:
	pop eax
	dec dword [last_byte_addr]
	dec dword [file_size]
	dec dword [current_pos]
	ret
setup_screen:
	pushad
	mov dh, 1
	mov dl, 0
	call os_move_cursor
	mov esi, text_edit_msg
	call os_print_string
	mov esi, [file_name]
	call os_print_string
	mov dh, 2
	mov dl, 0
	call os_move_cursor
	call os_draw_line
	mov dh, 57
	mov dl, 0
	call os_move_cursor
	call os_draw_line
	popad
	ret
help:
	call os_clear_screen
	call setup_screen
	mov dh, 4
	mov dl, 0x0
	call os_move_cursor
	mov esi, HELP_STRING
	call os_print_string
	call os_wait_for_key
	jmp render_text
failure:
	mov esi, failstring
	call os_print_string
	mov ebx, 'NF  '
	call os_abort
finish:
	mov dl, 0
	mov dh, 1
	call os_move_cursor
	mov ecx, 89
.empty_loop:
	mov al, ' '
	call os_print_char
	loop .empty_loop
	mov dh, 1
	mov dl, 0
	call os_move_cursor
	mov esi, are_you_sure
	call os_print_string
	call os_wait_for_key
	cmp al, 'n'
	je .exit
	cmp al, 'y'
	je .save_file 
	cmp al, 'r'
	je render_text
	;; if anything else...
	;; render text, they could have pressed it by mistake
	jmp render_text
.save_file:
	;; remember to null terminate the file
	mov edi, [last_byte_addr]
	mov al, 0x0
	stosb
	mov esi, [file_name]
	mov edi, LOAD_BUFFER
	mov ecx, [file_size]
	call os_write_file
.exit:
	call os_exit
highlight:
	cmp byte [HIGHLIGHT_MODE], 1
	je .disable
	mov byte [HIGHLIGHT_MODE], 1
	jmp render_text
.disable:
	mov byte [HIGHLIGHT_MODE], 0
	jmp render_text
save_file_render:
	pushad
	call os_clear_screen
	call setup_screen
	mov dh, 4
	mov dl, 0
	call os_move_cursor
	;; remember to null terminate the file
	mov edi, [last_byte_addr]
	mov al, 0x0
	stosb
	mov esi, [file_name]
	mov edi, LOAD_BUFFER
	mov ecx, [file_size]
	call os_write_file
	mov esi, FILE_SAVED
	call os_print_string
	popad
	call os_wait_for_key
	jmp render_text
.data_seg:
	failstring db 'EDIT: Cannot Load file. Does not exits. Error Code "NF"', NULL
	text_edit_msg db 'Zicronix Text Editor 0.46.09, Editing File: ', NULL
	are_you_sure db 'Are you sure to exit? Y = Save and Exit, N = Exit, R = Return: ', NULL
	HELP_STRING:
	db 'Zicronix Text Editor - Beta (0.46.09)', NEWLINE
	db 'Use: ./edit.znx [file name]', NEWLINE
	db 'Summary: ', NEWLINE
	db 'Zicronix Text Editor is a small text editor', NEWLINE
	db 'written for the Zicronix Operating System', NEWLINE
	db "it's meant to be used for editing the Zicronix", NEWLINE
	db 'source code under Zicronix, and provide basic', NEWLINE
	db "text editing. It's pretty portable to small OSes", NEWLINE
	db 'because it has very less requirements as compared to', NEWLINE
	db 'bloated word-processors/text editors.', NEWLINE
	db 'Controls: ', NEWLINE
	db 'F1 - Help (This screen)', NEWLINE
	db 'F2 - Enable/Disable Highlight Mode (Usually for programmers)', NEWLINE
	db 'F3 - Save File', NEWLINE
	db 'Up, Down, Right, Left - Move the cursor', NEWLINE
	db 'Backspace - Delete a character, deletes the whole line if done', NEWLINE
	db 'at first char', NEWLINE
	db 'Esc - Exit, Press "Y" if you want to save', NEWLINE
	db '"N" to quit without saving, and "R" to return back', NEWLINE
	db 'Press any key to return to editor', NEWLINE
	db 0x0
	FILE_SAVED: 
	db 'File Has been saved. Press a key to return to editor', NULL
.bss_seg:
	file_name dd 0x00000000
	file_size dd 0x00000000
	last_byte_addr dd 0x00000000
	last_byte_addr2 dd 0x0000000
	skip_lines dd 0x00000000
	cursor_byte dd 0x0
	cur_X db 0x00
	cur_Y db 0x00
	current_pos dd LOAD_BUFFER
	HIGHLIGHT_MODE db 0x00