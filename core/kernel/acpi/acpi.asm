;; Contains f**ked up code, you've been warned.
;; init_acpi, initializes the acpi shit, and
;; gets the address.
DEFINE RDST_ADDRESS 0x000E0000
DEFINE ACPI_SIG_1 'RSD ' ; 'RSD '
DEFINE ACPI_SIG_2 'PTR ' ; 'PTR '
DEFINE RSDT_SIG 'RSDT' ; 'RSDT' ACPI 1.0
DEFINE XSDT_SIG 'XSDT' ; 'XSDT' - ACPI 2.0+
init_acpi:
	mov esi, RDST_ADDRESS
.detect_acpi:
	;; end of acpi tables? hope not.
	cmp esi, 0x0000FFFF
	je .acpi_error
	;; grab a dword from esi into eax and increment esi by 4-bytes,
	lodsd
	cmp eax, ACPI_SIG_1
	;; if it's not the acpi signature, next entry or check for ptr.
	je .check_for_ptr
	;; or maybe let's loop again.
	add esi, 4
	jmp .detect_acpi
.check_for_ptr:
	lodsd
	cmp eax, ACPI_SIG_2
	je .found_acpi
	jmp .detect_acpi
.found_acpi:
;; verify.
.verify_check_sum:
	push esi
	mov ebx, NULL
	;; only first 20 bytes are of use.
	mov ecx, 20
	;; decrement esi 8 bytes
	sub esi, 8
.add_loop:
	lodsb
	add bl, al
	dec cl
	cmp cl, NULL
	jne .add_loop
	pop esi
	cmp bl, 0x00
	;; sadly the checksum != 0, bye bye, see you
	;; after you've got the real deal son!
	jne .detect_acpi
	;; ok grab the required values
	lodsb
	mov [acpi.checksum], al
	lodsd 
	mov [acpi.oem_id], eax
	lodsw
	mov [acpi.oem_id_end], ax
	lodsb
	mov [acpi.ver], al
	;; al = 0, acpi ver 1
	cmp al, 0x00
	je .ver_1
	;; else higher than ver 1
	jmp .ver_1_hi
.ver_1:
	xor eax, eax
	lodsd
	mov esi, eax
	lodsd
	sub esi, 4
	;; got the table address
	mov dword [acpi.address], esi
	jmp .acpi_exit
.ver_1_hi:
	lodsd
	lodsd
	;; well it's a qword mostly, but since we're 32-bit 
	;; dword should work fine.
	lodsd
	lodsd
	mov esi, eax
	sub esi, 4
	mov [acpi.address], esi
    jmp .acpi_exit
.acpi_error:
	mov esi, ACPI_NF
	call printf32
	cli
	hlt
	jmp $
.acpi_exit:
	mov esi, ACPI_FOUND
	call printf32
	call print_ok
	mov esi, ACPI_OEM_ID_MSG
	call printf32
	mov esi, acpi.oem_id
	mov eax, 6
	call printmem32
	mov esi, ACPI_MEM_ADDR
	call printf32
	mov eax, [acpi.address]
	call itoa32
	mov esi, eax
	call printf32
	mov bl, 0x0a
	call printc32
	ret
acpi_data:
	ACPI_NF db 0x0a, 'ACPI not found.', 0
	ACPI_FOUND db 0x0a, '[CPU0:]ACPI Intialized             ', 0
	ACPI_OEM_ID_MSG: db 'OEM ID: ', 0
	ACPI_MEM_ADDR db 0x0a, 'ACPI Address Space: ', 0
acpi:	
	.checksum: db 0x00
	.oem_id: dd 0x00000000
	.oem_id_end: dw 0x0000
	.ver db 0x00
	.address: dd 0x00000000
	
	