;; CPU Class
;; CPU.R1 - R6 Definitions
define CPU.R1 EAX
define CPU.R2 EBX
define CPU.R3 ECX
define CPU.R4 EDX
define CPU.R5 ESI
define CPU.R6 EDI
;; Stack and Base pointers
define CPU.STACK_POINTER ESP
define CPU.BASE_POINTER EBP
;; CPU.GetEIP - Get instruction address
;; EAX - Address of EIP
CPU.GetEIP:
	pop eax
	jmp eax
;; CPU.MemCpy - Copy some Memory crap
macro CPU.MemCpy source, size_of_crap, destination
{
	pushad
	mov esi, source
	mov edi, destination
	mov ecx, size_of_crap
.loop:
	lodsb
	stosb
	loop .loop
	popad
	ret
}
;; CPU.MemZero - Zero out Memory
macro CPU.MemZero source, size_ofcrap
{
	pushad
	mov edi, source
	mov ecx, size_ofcrap
.loop:
	mov al, 0x0
	stosb
	loop .loop
	popad
	ret
}
;; CPU.MemSet - Set a chunk of memory
macro CPU.MemSet dest, val, size_ofcrap
{
	pushad
	mov edi, dest
	mov al, val
	mov ecx, size_ofcrap
.loop:
	stosb
	loop .loop
	popad
	ret
}