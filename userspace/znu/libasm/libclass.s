;; libclass - Defines classes required.
;; string - ASCIIZ
struc string DATA
{
	jmp .x
	.string_data: db DATA, 0x0, '$' ;; DOS Crap may need '$'
	.end:
	.size: dd .end - .string_data
	.address: dd .string_data
	.display:
	push esi
	mov esi, .string_data
	call os_print_string
	pop esi
	ret
.x:
	;; End of function
}
;; INT - Integer
struc int32_t DATA
{
	jmp .x
	.integer_data: dd DATA
	.display:
	push eax
	push esi
	mov eax, [.integer_data]
	call os_int_to_string
	mov esi, eax
	call os_print_string
	pop esi
	pop eax
	ret
	.ToString:
	;; IN: EDI Pointer to Buffer
	push eax
	mov eax, [.integer_data]
	call os_int_to_string
	stosd
	pop eax
	ret
.x:
}
;; INT16_T - 16-bit Integer
struc int16_t DATA
{
	jmp .x
	.integer_data: dw DATA
	.display:
	push eax
	push esi
	xor eax, eax
	mov ax, [.integer_data]
	call os_int_to_string
	mov esi, eax
	call os_print_string
	pop esi
	pop eax
	ret
	.ToString:
	push eax
	xor eax, eax
	mov ax, [.integer_data]
	call os_int_to_string
	stosd
	pop eax
	ret
.x:
}
;; INT8_T - 8-bit Integer
struc int8_t DATA
{
	jmp .x
	.integer_data: db DATA
	.display:
	push eax
	push esi
	xor eax, eax
	mov al, [.integer_data]
	call os_int_to_string
	mov esi, eax
	call os_print_string
	pop esi
	pop eax
	ret
	.ToString:
	;; EDI - Pointer to 1-byte buf
	push eax
	xor eax, eax
	mov al, [.integer_data]
	call os_int_to_string
	stosb
	pop eax
	ret
.x:
}
;; Reserve some bytes
struc buffer len
{
	jmp .x
	.data_buf: rb len
	.x:
}
