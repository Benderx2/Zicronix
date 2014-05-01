;; Physical Memory Manager,
;; This provides a concrete interface
;; for the Virtual Memory Manager
;; One memory chunk is 4KB
DEFINE MEMORY_CHUNK 4096
init_pmm:
	;; Intialize the PMM.
	;; This stores the remainder
	xor edx, edx
	;; Reserved memory = 0x2000000 + kernel_32_size
	mov ebx, 0x2000000
	add ebx, [kernel_size]
	mov dword [heap_start_addr], ebx 
	;; Grab total memory in EAX
	;; Subtract Reserved Memory
	mov eax, [total_memory]
	sub eax, ebx
	mov ecx, MEMORY_CHUNK
	;; calculate number of chunks
	div ecx
	;; trash out remainder
	;; grab amount of chunks.
	mov [memory_chunks], eax
	;; print the message 
	mov esi, PMM_TOTAL_MEM
	call printf32
	mov eax, [total_memory]
	call itoa32
	mov esi, eax
	call printf32
	mov esi, PMM_TOTAL_CHUNKS
	call printf32
	mov eax, [memory_chunks]
	call itoa32
	mov esi, eax
	call printf32
	ret
	PMM_TOTAL_MEM: db 0x0a, 'Total Memory (Bytes): ', 0
	PMM_TOTAL_CHUNKS db 0x0a, 'Total (Free) 4KB Chunks: ', 0
	BASE_ADDR db 0x0a, 'Base Address: ', 0
	LEN_ADDR_RANGE db 0x0a, 'Length of Range: ', 0
	memory_chunks dd 0x00000000
	allocated_blocks dd 0x00000000
	heap_start_addr dd 0x0000000
;; get eip
get_eip: mov eax, [esp]
	 ret
;; allocate block
;; eax - number of blocks 
allocate_block:
	pushad
	push eax
	;; are all blocks allocated
	mov eax, [allocated_blocks]
	cmp eax, [memory_chunks]
	jge .error
	pop eax
	;; else allocated blocks
	mov ecx, eax
.loop:
	;; increment allocated blocks
	inc dword [allocated_blocks]
	mov esi, ALLOC_BLOCK_MSG
	call serial_write_string
	loop .loop
	;; now pass the pointer of the blocks
	mov eax, [heap_start_addr]
	call itoa32
	mov esi, eax
	call serial_write_string
	mov esi, BLOCK_NUMBER 
	call serial_write_string
	mov eax, [allocated_blocks]
	call itoa32
	mov esi, eax
	call serial_write_string
	mov edi, [heap_start_addr]
	mov ecx, eax
	mov al, 0x0
	rep stosb
	mov [heap_start_addr], edi
.done:
	popad
	ret
.error:
	pop eax
	;; lol, system went out of memory.
	;; seriously, man how many blocks did you allocate? :P
	mov esi, _MEMORY_FATAL_ERROR
	call printf32
	;; halt.
	cli
	hlt
.halt:
	jmp .halt
	
	_MEMORY_FATAL_ERROR db 0x0a, '=====FATAL==== System Out of memory. Halted.', 0
	ALLOC_BLOCK_MSG db 0x0a, 'Allocating one Block, Address= ', 0
	BLOCK_NUMBER db ' , Number of Allocated Blocks= ', 0
;; byte to blocks
;; convert a desired amount of bytes to blocks
;; in:
;; eax - number of bytes
;; out:
;; eax - number of equivalent blocks
byte2blocks:
	push edx
	xor edx, edx
	mov ecx, MEMORY_CHUNK
	;; calculate number of blocks
	div ecx
	pop edx
	ret
	
	