;; Memory Map code.
;; Get the memory map from the BIOS
use16
get_mem_map:
	mov ax, cs
	mov es, ax
	mov di, mm_buf
	xor ebx, ebx		; ebx must be 0 to start
	xor bp, bp		; keep an entry count in bp
	mov edx, 'PAMS'	; Place "SMAP" into edx
	mov eax, 0xe820
	mov [es:di + 20], dword 1	; force a valid ACPI 3.X entry
	mov ecx, 24		; ask for 24 bytes
	int 0x15
	jc short .failed	; carry set on first call means "unsupported function"
	mov edx, 'PAMS'	; Some BIOSes apparently trash this register?
	cmp eax, edx		; on success, eax must have been reset to "SMAP"
	jne short .failed
	test ebx, ebx		; ebx = 0 implies list is only 1 entry long (worthless)
	je short .failed
	jmp short .jmpin
.e820lp:
	mov eax, 0xe820		; eax, ecx get trashed on every int 0x15 call
	mov [es:di + 20], dword 1	; force a valid ACPI 3.X entry
	mov ecx, 24		; ask for 24 bytes again
	int 0x15
	jc short .e820f		; carry set means "end of list already reached"
	mov edx, 'PAMS'	; repair potentially trashed register
.jmpin:
	jcxz .skipent		; skip any 0 length entries
	cmp cl, 20		; got a 24 byte ACPI 3.X response?
	jbe short .notext
	test byte [es:di + 20], 1	; if so: is the "ignore this data" bit clear?
	je short .skipent
.notext:
	mov ecx, [es:di + 8]	; get lower dword of memory region length
	or ecx, [es:di + 12]	; "or" it with upper dword to test for zero
	jz .skipent		; if length qword is 0, skip entry
	inc bp			; got a good entry: ++count, move to next storage spot
	add di, 24
.skipent:
	test ebx, ebx		; if ebx resets to 0, list is complete
	jne short .e820lp
.e820f:
	mov [mmap_ent], bp	; store the entry count
	clc			; there is "jc" on end of list to this point, so the carry must be cleared
	ret
.failed:
	stc			; "function unsupported" error exit
	ret
	mm_buf: times 200 db 0
	mmap_ent dw 0
use32
;; Output the memory map
mm_output:
	mov bl, 0x0a
	call printc32
	;; Now search through the memory map -- Each entry = 24 bytes
	mov esi, mm_buf
	xor ecx, ecx
	mov cx, [mmap_ent]
.get_data:
	;; 8-bytes, first qword.
	lodsd
	lodsd
	;; Start address
	mov dword [start_range], eax
	;; Size of the address range (QWORD)
	lodsd
	lodsd
	mov dword [size_of_range], eax
	;; Type and ACPI 3.0 stuff.
	lodsd
	lodsd
	;; Is size 0?
	cmp dword [size_of_range], 0
	;; Ignore the entry
	je .get_data
	;; Else print it.
	mov eax, [start_range]
	call itoa32
	;; Save ESI
	push esi
	mov esi, eax
	call printf32
	;; Print a '-'
	mov bl, '-'
	call printc32
	;; Print the size
	mov eax, [size_of_range]
	call itoa32
	mov esi, eax 
	call printf32
	;; and then a newline
	mov bl, 0x0a
	call printc32
	;; Restore ESI
	pop esi
	;; Loop until we searched all entries
	loop .get_data
	ret
	start_range dd 0x0
	size_of_range dd 0x0