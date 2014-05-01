;; ZMAC.ASM - Zicronix Macros
define PIC1 0x20
define PIC2 0xA0
define PIC1_COMMAND 0x20 + 1
define PIC2_COMMAND 0xA0 + 1
define KEYBOARD 0x64
? equ 0
macro out32 out_port, out_value
{
	push dx
	push ax
	mov dx, out_port
	mov al, out_value
	out dx, al
	pop ax
	pop dx
}
macro out64 out_port_64, out_value
{
	push dx
	push ax
	mov dx, out_port_64
	mov eax, out_value
	out dx, ax
	pop ax
	pop dx
}
macro PUSH_ALL
{
	pushad
} 
macro POP_ALL
{
	popad
}
macro SEND_EOI
{
	call send_eoi
}
macro HALT_ALL
{
	cli
	hlt
	jmp $
}
macro SET_RM_SELECTORS {
	push ds
	push es
	push eax
	mov ax, 0x18
	mov es, ax
	mov ds, ax
	pop eax
	cld
}
macro PUSH_GPR 
{
	push edx
	push ecx
	push ebx
	push eax
}
macro POP_GPR
{
	pop eax
	pop ebx
	pop ecx
	pop edx
}
macro IN32_4
{
	in al, dx
	in al, dx
	in al, dx
	in al, dx
}
macro POP_GPR_EAX_ECX
{
	pop ecx
	pop eax
	pop ebx
	add eax, ecx
	pop ecx
	pop edx
}
macro CLEAR_CARRY_RETURN
{
	clc
	ret
}
macro SET_CARRY_RETURN
{
	stc
	ret
}
